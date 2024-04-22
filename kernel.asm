
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc b0 49 1c 80       	mov    $0x801c49b0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 20 32 10 80       	mov    $0x80103220,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	57                   	push   %edi
80100044:	89 d7                	mov    %edx,%edi
80100046:	56                   	push   %esi
80100047:	89 c6                	mov    %eax,%esi
80100049:	53                   	push   %ebx
8010004a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
8010004d:	68 20 b5 10 80       	push   $0x8010b520
80100052:	e8 49 53 00 00       	call   801053a0 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100057:	8b 1d 70 fc 10 80    	mov    0x8010fc70,%ebx
8010005d:	83 c4 10             	add    $0x10,%esp
80100060:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100066:	75 13                	jne    8010007b <bget+0x3b>
80100068:	eb 26                	jmp    80100090 <bget+0x50>
8010006a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100070:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100073:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100079:	74 15                	je     80100090 <bget+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010007b:	39 73 04             	cmp    %esi,0x4(%ebx)
8010007e:	75 f0                	jne    80100070 <bget+0x30>
80100080:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100083:	75 eb                	jne    80100070 <bget+0x30>
      b->refcnt++;
80100085:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100089:	eb 3f                	jmp    801000ca <bget+0x8a>
8010008b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010008f:	90                   	nop
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100090:	8b 1d 6c fc 10 80    	mov    0x8010fc6c,%ebx
80100096:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
8010009c:	75 0d                	jne    801000ab <bget+0x6b>
8010009e:	eb 4f                	jmp    801000ef <bget+0xaf>
801000a0:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000a3:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
801000a9:	74 44                	je     801000ef <bget+0xaf>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000ab:	8b 43 4c             	mov    0x4c(%ebx),%eax
801000ae:	85 c0                	test   %eax,%eax
801000b0:	75 ee                	jne    801000a0 <bget+0x60>
801000b2:	f6 03 04             	testb  $0x4,(%ebx)
801000b5:	75 e9                	jne    801000a0 <bget+0x60>
      b->dev = dev;
801000b7:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000ba:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000c3:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000ca:	83 ec 0c             	sub    $0xc,%esp
801000cd:	68 20 b5 10 80       	push   $0x8010b520
801000d2:	e8 69 52 00 00       	call   80105340 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 de 4f 00 00       	call   801050c0 <acquiresleep>
      return b;
801000e2:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e8:	89 d8                	mov    %ebx,%eax
801000ea:	5b                   	pop    %ebx
801000eb:	5e                   	pop    %esi
801000ec:	5f                   	pop    %edi
801000ed:	5d                   	pop    %ebp
801000ee:	c3                   	ret
  panic("bget: no buffers");
801000ef:	83 ec 0c             	sub    $0xc,%esp
801000f2:	68 20 82 10 80       	push   $0x80108220
801000f7:	e8 b4 03 00 00       	call   801004b0 <panic>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100100 <binit>:
{
80100100:	55                   	push   %ebp
80100101:	89 e5                	mov    %esp,%ebp
80100103:	53                   	push   %ebx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100104:	bb 54 b5 10 80       	mov    $0x8010b554,%ebx
{
80100109:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010010c:	68 31 82 10 80       	push   $0x80108231
80100111:	68 20 b5 10 80       	push   $0x8010b520
80100116:	e8 95 50 00 00       	call   801051b0 <initlock>
  bcache.head.next = &bcache.head;
8010011b:	83 c4 10             	add    $0x10,%esp
8010011e:	b8 1c fc 10 80       	mov    $0x8010fc1c,%eax
  bcache.head.prev = &bcache.head;
80100123:	c7 05 6c fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc6c
8010012a:	fc 10 80 
  bcache.head.next = &bcache.head;
8010012d:	c7 05 70 fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc70
80100134:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100137:	eb 09                	jmp    80100142 <binit+0x42>
80100139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100140:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100142:	89 43 54             	mov    %eax,0x54(%ebx)
    initsleeplock(&b->lock, "buffer");
80100145:	83 ec 08             	sub    $0x8,%esp
80100148:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010014b:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100152:	68 38 82 10 80       	push   $0x80108238
80100157:	50                   	push   %eax
80100158:	e8 23 4f 00 00       	call   80105080 <initsleeplock>
    bcache.head.next->prev = b;
8010015d:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100162:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
80100168:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010016b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010016e:	89 d8                	mov    %ebx,%eax
80100170:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100176:	81 fb c0 f9 10 80    	cmp    $0x8010f9c0,%ebx
8010017c:	75 c2                	jne    80100140 <binit+0x40>
}
8010017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100181:	c9                   	leave
80100182:	c3                   	ret
80100183:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010018a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100190 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100190:	55                   	push   %ebp
80100191:	89 e5                	mov    %esp,%ebp
80100193:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100196:	8b 55 0c             	mov    0xc(%ebp),%edx
80100199:	8b 45 08             	mov    0x8(%ebp),%eax
8010019c:	e8 9f fe ff ff       	call   80100040 <bget>
  if((b->flags & B_VALID) == 0) {
801001a1:	f6 00 02             	testb  $0x2,(%eax)
801001a4:	74 0a                	je     801001b0 <bread+0x20>
    iderw(b);
  }
  return b;
}
801001a6:	c9                   	leave
801001a7:	c3                   	ret
801001a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop
    iderw(b);
801001b0:	83 ec 0c             	sub    $0xc,%esp
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	50                   	push   %eax
801001b7:	e8 44 22 00 00       	call   80102400 <iderw>
801001bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001bf:	83 c4 10             	add    $0x10,%esp
}
801001c2:	c9                   	leave
801001c3:	c3                   	ret
801001c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001cf:	90                   	nop

801001d0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001d0:	55                   	push   %ebp
801001d1:	89 e5                	mov    %esp,%ebp
801001d3:	53                   	push   %ebx
801001d4:	83 ec 10             	sub    $0x10,%esp
801001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001da:	8d 43 0c             	lea    0xc(%ebx),%eax
801001dd:	50                   	push   %eax
801001de:	e8 7d 4f 00 00       	call   80105160 <holdingsleep>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	85 c0                	test   %eax,%eax
801001e8:	74 0f                	je     801001f9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ea:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001ed:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001f3:	c9                   	leave
  iderw(b);
801001f4:	e9 07 22 00 00       	jmp    80102400 <iderw>
    panic("bwrite");
801001f9:	83 ec 0c             	sub    $0xc,%esp
801001fc:	68 3f 82 10 80       	push   $0x8010823f
80100201:	e8 aa 02 00 00       	call   801004b0 <panic>
80100206:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010020d:	8d 76 00             	lea    0x0(%esi),%esi

80100210 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100210:	55                   	push   %ebp
80100211:	89 e5                	mov    %esp,%ebp
80100213:	56                   	push   %esi
80100214:	53                   	push   %ebx
80100215:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
80100218:	8d 73 0c             	lea    0xc(%ebx),%esi
8010021b:	83 ec 0c             	sub    $0xc,%esp
8010021e:	56                   	push   %esi
8010021f:	e8 3c 4f 00 00       	call   80105160 <holdingsleep>
80100224:	83 c4 10             	add    $0x10,%esp
80100227:	85 c0                	test   %eax,%eax
80100229:	74 63                	je     8010028e <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
8010022b:	83 ec 0c             	sub    $0xc,%esp
8010022e:	56                   	push   %esi
8010022f:	e8 ec 4e 00 00       	call   80105120 <releasesleep>

  acquire(&bcache.lock);
80100234:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010023b:	e8 60 51 00 00       	call   801053a0 <acquire>
  b->refcnt--;
80100240:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100243:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100246:	83 e8 01             	sub    $0x1,%eax
80100249:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010024c:	85 c0                	test   %eax,%eax
8010024e:	75 2c                	jne    8010027c <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100250:	8b 53 54             	mov    0x54(%ebx),%edx
80100253:	8b 43 50             	mov    0x50(%ebx),%eax
80100256:	89 42 50             	mov    %eax,0x50(%edx)
    b->prev->next = b->next;
80100259:	8b 53 54             	mov    0x54(%ebx),%edx
8010025c:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
8010025f:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
    b->prev = &bcache.head;
80100264:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    b->next = bcache.head.next;
8010026b:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
8010026e:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
80100273:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100276:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  }
  
  release(&bcache.lock);
8010027c:	c7 45 08 20 b5 10 80 	movl   $0x8010b520,0x8(%ebp)
}
80100283:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100286:	5b                   	pop    %ebx
80100287:	5e                   	pop    %esi
80100288:	5d                   	pop    %ebp
  release(&bcache.lock);
80100289:	e9 b2 50 00 00       	jmp    80105340 <release>
    panic("brelse");
8010028e:	83 ec 0c             	sub    $0xc,%esp
80100291:	68 46 82 10 80       	push   $0x80108246
80100296:	e8 15 02 00 00       	call   801004b0 <panic>
8010029b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010029f:	90                   	nop

801002a0 <write_pag_to_disk>:
// Blank page.



void 
write_pag_to_disk(uint dev, char* page,uint block_id){
801002a0:	55                   	push   %ebp
801002a1:	89 e5                	mov    %esp,%ebp
801002a3:	57                   	push   %edi
801002a4:	56                   	push   %esi
801002a5:	53                   	push   %ebx
801002a6:	83 ec 1c             	sub    $0x1c,%esp
801002a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
801002ac:	8b 75 0c             	mov    0xc(%ebp),%esi
801002af:	8d 43 08             	lea    0x8(%ebx),%eax
801002b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801002b5:	8d 76 00             	lea    0x0(%esi),%esi
  struct buf* buff;
  for(int i = 0;i<8;i++){
    buff = bget(ROOTDEV,block_id+i);
801002b8:	89 da                	mov    %ebx,%edx
801002ba:	b8 01 00 00 00       	mov    $0x1,%eax
801002bf:	e8 7c fd ff ff       	call   80100040 <bget>
    memmove(buff->data,page+i*512,512);
801002c4:	83 ec 04             	sub    $0x4,%esp
    buff = bget(ROOTDEV,block_id+i);
801002c7:	89 c7                	mov    %eax,%edi
    memmove(buff->data,page+i*512,512);
801002c9:	8d 40 5c             	lea    0x5c(%eax),%eax
801002cc:	68 00 02 00 00       	push   $0x200
801002d1:	56                   	push   %esi
801002d2:	50                   	push   %eax
801002d3:	e8 58 52 00 00       	call   80105530 <memmove>
  if(!holdingsleep(&b->lock))
801002d8:	8d 47 0c             	lea    0xc(%edi),%eax
801002db:	89 04 24             	mov    %eax,(%esp)
801002de:	e8 7d 4e 00 00       	call   80105160 <holdingsleep>
801002e3:	83 c4 10             	add    $0x10,%esp
801002e6:	85 c0                	test   %eax,%eax
801002e8:	74 2f                	je     80100319 <write_pag_to_disk+0x79>
  iderw(b);
801002ea:	83 ec 0c             	sub    $0xc,%esp
  b->flags |= B_DIRTY;
801002ed:	83 0f 04             	orl    $0x4,(%edi)
  for(int i = 0;i<8;i++){
801002f0:	83 c3 01             	add    $0x1,%ebx
801002f3:	81 c6 00 02 00 00    	add    $0x200,%esi
  iderw(b);
801002f9:	57                   	push   %edi
801002fa:	e8 01 21 00 00       	call   80102400 <iderw>
    bwrite(buff);
    brelse(buff);
801002ff:	89 3c 24             	mov    %edi,(%esp)
80100302:	e8 09 ff ff ff       	call   80100210 <brelse>
  for(int i = 0;i<8;i++){
80100307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010030a:	83 c4 10             	add    $0x10,%esp
8010030d:	39 c3                	cmp    %eax,%ebx
8010030f:	75 a7                	jne    801002b8 <write_pag_to_disk+0x18>
  }
}
80100311:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100314:	5b                   	pop    %ebx
80100315:	5e                   	pop    %esi
80100316:	5f                   	pop    %edi
80100317:	5d                   	pop    %ebp
80100318:	c3                   	ret
    panic("bwrite");
80100319:	83 ec 0c             	sub    $0xc,%esp
8010031c:	68 3f 82 10 80       	push   $0x8010823f
80100321:	e8 8a 01 00 00       	call   801004b0 <panic>
80100326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010032d:	8d 76 00             	lea    0x0(%esi),%esi

80100330 <read_page_from_disk>:


void
read_page_from_disk(uint slot,char* mem){
80100330:	55                   	push   %ebp
80100331:	89 e5                	mov    %esp,%ebp
80100333:	57                   	push   %edi
80100334:	56                   	push   %esi
80100335:	53                   	push   %ebx
80100336:	83 ec 1c             	sub    $0x1c,%esp
80100339:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010033c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010033f:	8d 43 08             	lea    0x8(%ebx),%eax
80100342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100345:	eb 36                	jmp    8010037d <read_page_from_disk+0x4d>
80100347:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010034e:	66 90                	xchg   %ax,%ax

  for(int i = 0; i < 8; i++){
    struct buf* buff = bread(ROOTDEV, slot+i);
    memmove(mem+i*512, buff->data, 512);
80100350:	83 ec 04             	sub    $0x4,%esp
80100353:	8d 47 5c             	lea    0x5c(%edi),%eax
  for(int i = 0; i < 8; i++){
80100356:	83 c3 01             	add    $0x1,%ebx
    memmove(mem+i*512, buff->data, 512);
80100359:	68 00 02 00 00       	push   $0x200
8010035e:	50                   	push   %eax
8010035f:	56                   	push   %esi
  for(int i = 0; i < 8; i++){
80100360:	81 c6 00 02 00 00    	add    $0x200,%esi
    memmove(mem+i*512, buff->data, 512);
80100366:	e8 c5 51 00 00       	call   80105530 <memmove>
    brelse(buff);
8010036b:	89 3c 24             	mov    %edi,(%esp)
8010036e:	e8 9d fe ff ff       	call   80100210 <brelse>
  for(int i = 0; i < 8; i++){
80100373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100376:	83 c4 10             	add    $0x10,%esp
80100379:	39 c3                	cmp    %eax,%ebx
8010037b:	74 23                	je     801003a0 <read_page_from_disk+0x70>
  b = bget(dev, blockno);
8010037d:	89 da                	mov    %ebx,%edx
8010037f:	b8 01 00 00 00       	mov    $0x1,%eax
80100384:	e8 b7 fc ff ff       	call   80100040 <bget>
80100389:	89 c7                	mov    %eax,%edi
  if((b->flags & B_VALID) == 0) {
8010038b:	f6 00 02             	testb  $0x2,(%eax)
8010038e:	75 c0                	jne    80100350 <read_page_from_disk+0x20>
    iderw(b);
80100390:	83 ec 0c             	sub    $0xc,%esp
80100393:	50                   	push   %eax
80100394:	e8 67 20 00 00       	call   80102400 <iderw>
80100399:	83 c4 10             	add    $0x10,%esp
8010039c:	eb b2                	jmp    80100350 <read_page_from_disk+0x20>
8010039e:	66 90                	xchg   %ax,%ax
  }
801003a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801003a3:	5b                   	pop    %ebx
801003a4:	5e                   	pop    %esi
801003a5:	5f                   	pop    %edi
801003a6:	5d                   	pop    %ebp
801003a7:	c3                   	ret
801003a8:	66 90                	xchg   %ax,%ax
801003aa:	66 90                	xchg   %ax,%ax
801003ac:	66 90                	xchg   %ax,%ax
801003ae:	66 90                	xchg   %ax,%ax

801003b0 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
801003b0:	55                   	push   %ebp
801003b1:	89 e5                	mov    %esp,%ebp
801003b3:	57                   	push   %edi
801003b4:	56                   	push   %esi
801003b5:	53                   	push   %ebx
801003b6:	83 ec 18             	sub    $0x18,%esp
801003b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
801003bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
801003bf:	ff 75 08             	push   0x8(%ebp)
  target = n;
801003c2:	89 df                	mov    %ebx,%edi
  iunlock(ip);
801003c4:	e8 e7 15 00 00       	call   801019b0 <iunlock>
  acquire(&cons.lock);
801003c9:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801003d0:	e8 cb 4f 00 00       	call   801053a0 <acquire>
  while(n > 0){
801003d5:	83 c4 10             	add    $0x10,%esp
801003d8:	85 db                	test   %ebx,%ebx
801003da:	0f 8e 94 00 00 00    	jle    80100474 <consoleread+0xc4>
    while(input.r == input.w){
801003e0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801003e5:	39 05 04 ff 10 80    	cmp    %eax,0x8010ff04
801003eb:	74 25                	je     80100412 <consoleread+0x62>
801003ed:	eb 59                	jmp    80100448 <consoleread+0x98>
801003ef:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801003f0:	83 ec 08             	sub    $0x8,%esp
801003f3:	68 20 ff 10 80       	push   $0x8010ff20
801003f8:	68 00 ff 10 80       	push   $0x8010ff00
801003fd:	e8 fe 3e 00 00       	call   80104300 <sleep>
    while(input.r == input.w){
80100402:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80100407:	83 c4 10             	add    $0x10,%esp
8010040a:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100410:	75 36                	jne    80100448 <consoleread+0x98>
      if(myproc()->killed){
80100412:	e8 d9 38 00 00       	call   80103cf0 <myproc>
80100417:	8b 48 28             	mov    0x28(%eax),%ecx
8010041a:	85 c9                	test   %ecx,%ecx
8010041c:	74 d2                	je     801003f0 <consoleread+0x40>
        release(&cons.lock);
8010041e:	83 ec 0c             	sub    $0xc,%esp
80100421:	68 20 ff 10 80       	push   $0x8010ff20
80100426:	e8 15 4f 00 00       	call   80105340 <release>
        ilock(ip);
8010042b:	5a                   	pop    %edx
8010042c:	ff 75 08             	push   0x8(%ebp)
8010042f:	e8 9c 14 00 00       	call   801018d0 <ilock>
        return -1;
80100434:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100437:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010043a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010043f:	5b                   	pop    %ebx
80100440:	5e                   	pop    %esi
80100441:	5f                   	pop    %edi
80100442:	5d                   	pop    %ebp
80100443:	c3                   	ret
80100444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100448:	8d 50 01             	lea    0x1(%eax),%edx
8010044b:	89 15 00 ff 10 80    	mov    %edx,0x8010ff00
80100451:	89 c2                	mov    %eax,%edx
80100453:	83 e2 7f             	and    $0x7f,%edx
80100456:	0f be 8a 80 fe 10 80 	movsbl -0x7fef0180(%edx),%ecx
    if(c == C('D')){  // EOF
8010045d:	80 f9 04             	cmp    $0x4,%cl
80100460:	74 37                	je     80100499 <consoleread+0xe9>
    *dst++ = c;
80100462:	83 c6 01             	add    $0x1,%esi
    --n;
80100465:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100468:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010046b:	83 f9 0a             	cmp    $0xa,%ecx
8010046e:	0f 85 64 ff ff ff    	jne    801003d8 <consoleread+0x28>
  release(&cons.lock);
80100474:	83 ec 0c             	sub    $0xc,%esp
80100477:	68 20 ff 10 80       	push   $0x8010ff20
8010047c:	e8 bf 4e 00 00       	call   80105340 <release>
  ilock(ip);
80100481:	58                   	pop    %eax
80100482:	ff 75 08             	push   0x8(%ebp)
80100485:	e8 46 14 00 00       	call   801018d0 <ilock>
  return target - n;
8010048a:	89 f8                	mov    %edi,%eax
8010048c:	83 c4 10             	add    $0x10,%esp
}
8010048f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100492:	29 d8                	sub    %ebx,%eax
}
80100494:	5b                   	pop    %ebx
80100495:	5e                   	pop    %esi
80100496:	5f                   	pop    %edi
80100497:	5d                   	pop    %ebp
80100498:	c3                   	ret
      if(n < target){
80100499:	39 fb                	cmp    %edi,%ebx
8010049b:	73 d7                	jae    80100474 <consoleread+0xc4>
        input.r--;
8010049d:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
801004a2:	eb d0                	jmp    80100474 <consoleread+0xc4>
801004a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801004ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801004af:	90                   	nop

801004b0 <panic>:
{
801004b0:	55                   	push   %ebp
801004b1:	89 e5                	mov    %esp,%ebp
801004b3:	56                   	push   %esi
801004b4:	53                   	push   %ebx
801004b5:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
801004b8:	fa                   	cli
  cons.locking = 0;
801004b9:	c7 05 54 ff 10 80 00 	movl   $0x0,0x8010ff54
801004c0:	00 00 00 
  getcallerpcs(&s, pcs);
801004c3:	8d 5d d0             	lea    -0x30(%ebp),%ebx
801004c6:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
801004c9:	e8 e2 25 00 00       	call   80102ab0 <lapicid>
801004ce:	83 ec 08             	sub    $0x8,%esp
801004d1:	50                   	push   %eax
801004d2:	68 4d 82 10 80       	push   $0x8010824d
801004d7:	e8 04 03 00 00       	call   801007e0 <cprintf>
  cprintf(s);
801004dc:	58                   	pop    %eax
801004dd:	ff 75 08             	push   0x8(%ebp)
801004e0:	e8 fb 02 00 00       	call   801007e0 <cprintf>
  cprintf("\n");
801004e5:	c7 04 24 82 87 10 80 	movl   $0x80108782,(%esp)
801004ec:	e8 ef 02 00 00       	call   801007e0 <cprintf>
  getcallerpcs(&s, pcs);
801004f1:	8d 45 08             	lea    0x8(%ebp),%eax
801004f4:	5a                   	pop    %edx
801004f5:	59                   	pop    %ecx
801004f6:	53                   	push   %ebx
801004f7:	50                   	push   %eax
801004f8:	e8 d3 4c 00 00       	call   801051d0 <getcallerpcs>
  for(i=0; i<10; i++)
801004fd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
80100500:	83 ec 08             	sub    $0x8,%esp
80100503:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
80100505:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
80100508:	68 61 82 10 80       	push   $0x80108261
8010050d:	e8 ce 02 00 00       	call   801007e0 <cprintf>
  for(i=0; i<10; i++)
80100512:	83 c4 10             	add    $0x10,%esp
80100515:	39 f3                	cmp    %esi,%ebx
80100517:	75 e7                	jne    80100500 <panic+0x50>
  panicked = 1; // freeze other CPU
80100519:	c7 05 58 ff 10 80 01 	movl   $0x1,0x8010ff58
80100520:	00 00 00 
  for(;;)
80100523:	eb fe                	jmp    80100523 <panic+0x73>
80100525:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010052c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100530 <consputc.part.0>:
consputc(int c)
80100530:	55                   	push   %ebp
80100531:	89 e5                	mov    %esp,%ebp
80100533:	57                   	push   %edi
80100534:	56                   	push   %esi
80100535:	53                   	push   %ebx
80100536:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
80100539:	3d 00 01 00 00       	cmp    $0x100,%eax
8010053e:	0f 84 cc 00 00 00    	je     80100610 <consputc.part.0+0xe0>
    uartputc(c);
80100544:	83 ec 0c             	sub    $0xc,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100547:	bf d4 03 00 00       	mov    $0x3d4,%edi
8010054c:	89 c3                	mov    %eax,%ebx
8010054e:	50                   	push   %eax
8010054f:	e8 ac 65 00 00       	call   80106b00 <uartputc>
80100554:	b8 0e 00 00 00       	mov    $0xe,%eax
80100559:	89 fa                	mov    %edi,%edx
8010055b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010055c:	be d5 03 00 00       	mov    $0x3d5,%esi
80100561:	89 f2                	mov    %esi,%edx
80100563:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100564:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100567:	89 fa                	mov    %edi,%edx
80100569:	b8 0f 00 00 00       	mov    $0xf,%eax
8010056e:	c1 e1 08             	shl    $0x8,%ecx
80100571:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100572:	89 f2                	mov    %esi,%edx
80100574:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100575:	0f b6 c0             	movzbl %al,%eax
  if(c == '\n')
80100578:	83 c4 10             	add    $0x10,%esp
  pos |= inb(CRTPORT+1);
8010057b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010057d:	83 fb 0a             	cmp    $0xa,%ebx
80100580:	75 76                	jne    801005f8 <consputc.part.0+0xc8>
    pos += 80 - pos%80;
80100582:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80100587:	f7 e2                	mul    %edx
80100589:	c1 ea 06             	shr    $0x6,%edx
8010058c:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010058f:	c1 e0 04             	shl    $0x4,%eax
80100592:	8d 70 50             	lea    0x50(%eax),%esi
  if(pos < 0 || pos > 25*80)
80100595:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
8010059b:	0f 8f 2f 01 00 00    	jg     801006d0 <consputc.part.0+0x1a0>
  if((pos/80) >= 24){  // Scroll up.
801005a1:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
801005a7:	0f 8f c3 00 00 00    	jg     80100670 <consputc.part.0+0x140>
  outb(CRTPORT+1, pos>>8);
801005ad:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
801005af:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
801005b6:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
801005b9:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801005bc:	bb d4 03 00 00       	mov    $0x3d4,%ebx
801005c1:	b8 0e 00 00 00       	mov    $0xe,%eax
801005c6:	89 da                	mov    %ebx,%edx
801005c8:	ee                   	out    %al,(%dx)
801005c9:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801005ce:	89 f8                	mov    %edi,%eax
801005d0:	89 ca                	mov    %ecx,%edx
801005d2:	ee                   	out    %al,(%dx)
801005d3:	b8 0f 00 00 00       	mov    $0xf,%eax
801005d8:	89 da                	mov    %ebx,%edx
801005da:	ee                   	out    %al,(%dx)
801005db:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801005df:	89 ca                	mov    %ecx,%edx
801005e1:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801005e2:	b8 20 07 00 00       	mov    $0x720,%eax
801005e7:	66 89 06             	mov    %ax,(%esi)
}
801005ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005ed:	5b                   	pop    %ebx
801005ee:	5e                   	pop    %esi
801005ef:	5f                   	pop    %edi
801005f0:	5d                   	pop    %ebp
801005f1:	c3                   	ret
801005f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801005f8:	0f b6 db             	movzbl %bl,%ebx
801005fb:	8d 70 01             	lea    0x1(%eax),%esi
801005fe:	80 cf 07             	or     $0x7,%bh
80100601:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
80100608:	80 
80100609:	eb 8a                	jmp    80100595 <consputc.part.0+0x65>
8010060b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010060f:	90                   	nop
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100610:	83 ec 0c             	sub    $0xc,%esp
80100613:	be d4 03 00 00       	mov    $0x3d4,%esi
80100618:	6a 08                	push   $0x8
8010061a:	e8 e1 64 00 00       	call   80106b00 <uartputc>
8010061f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100626:	e8 d5 64 00 00       	call   80106b00 <uartputc>
8010062b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100632:	e8 c9 64 00 00       	call   80106b00 <uartputc>
80100637:	b8 0e 00 00 00       	mov    $0xe,%eax
8010063c:	89 f2                	mov    %esi,%edx
8010063e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010063f:	bb d5 03 00 00       	mov    $0x3d5,%ebx
80100644:	89 da                	mov    %ebx,%edx
80100646:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100647:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010064a:	89 f2                	mov    %esi,%edx
8010064c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100651:	c1 e1 08             	shl    $0x8,%ecx
80100654:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100655:	89 da                	mov    %ebx,%edx
80100657:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100658:	0f b6 f0             	movzbl %al,%esi
    if(pos > 0) --pos;
8010065b:	83 c4 10             	add    $0x10,%esp
8010065e:	09 ce                	or     %ecx,%esi
80100660:	74 5e                	je     801006c0 <consputc.part.0+0x190>
80100662:	83 ee 01             	sub    $0x1,%esi
80100665:	e9 2b ff ff ff       	jmp    80100595 <consputc.part.0+0x65>
8010066a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100670:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100673:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100676:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010067d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100682:	68 60 0e 00 00       	push   $0xe60
80100687:	68 a0 80 0b 80       	push   $0x800b80a0
8010068c:	68 00 80 0b 80       	push   $0x800b8000
80100691:	e8 9a 4e 00 00       	call   80105530 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100696:	b8 80 07 00 00       	mov    $0x780,%eax
8010069b:	83 c4 0c             	add    $0xc,%esp
8010069e:	29 d8                	sub    %ebx,%eax
801006a0:	01 c0                	add    %eax,%eax
801006a2:	50                   	push   %eax
801006a3:	6a 00                	push   $0x0
801006a5:	56                   	push   %esi
801006a6:	e8 f5 4d 00 00       	call   801054a0 <memset>
  outb(CRTPORT+1, pos);
801006ab:	88 5d e7             	mov    %bl,-0x19(%ebp)
801006ae:	83 c4 10             	add    $0x10,%esp
801006b1:	e9 06 ff ff ff       	jmp    801005bc <consputc.part.0+0x8c>
801006b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801006bd:	8d 76 00             	lea    0x0(%esi),%esi
801006c0:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801006c4:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801006c9:	31 ff                	xor    %edi,%edi
801006cb:	e9 ec fe ff ff       	jmp    801005bc <consputc.part.0+0x8c>
    panic("pos under/overflow");
801006d0:	83 ec 0c             	sub    $0xc,%esp
801006d3:	68 65 82 10 80       	push   $0x80108265
801006d8:	e8 d3 fd ff ff       	call   801004b0 <panic>
801006dd:	8d 76 00             	lea    0x0(%esi),%esi

801006e0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801006e0:	55                   	push   %ebp
801006e1:	89 e5                	mov    %esp,%ebp
801006e3:	57                   	push   %edi
801006e4:	56                   	push   %esi
801006e5:	53                   	push   %ebx
801006e6:	83 ec 18             	sub    $0x18,%esp
801006e9:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801006ec:	ff 75 08             	push   0x8(%ebp)
801006ef:	e8 bc 12 00 00       	call   801019b0 <iunlock>
  acquire(&cons.lock);
801006f4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801006fb:	e8 a0 4c 00 00       	call   801053a0 <acquire>
  for(i = 0; i < n; i++)
80100700:	83 c4 10             	add    $0x10,%esp
80100703:	85 f6                	test   %esi,%esi
80100705:	7e 25                	jle    8010072c <consolewrite+0x4c>
80100707:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010070a:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
8010070d:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
    consputc(buf[i] & 0xff);
80100713:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
80100716:	85 d2                	test   %edx,%edx
80100718:	74 06                	je     80100720 <consolewrite+0x40>
  asm volatile("cli");
8010071a:	fa                   	cli
    for(;;)
8010071b:	eb fe                	jmp    8010071b <consolewrite+0x3b>
8010071d:	8d 76 00             	lea    0x0(%esi),%esi
80100720:	e8 0b fe ff ff       	call   80100530 <consputc.part.0>
  for(i = 0; i < n; i++)
80100725:	83 c3 01             	add    $0x1,%ebx
80100728:	39 fb                	cmp    %edi,%ebx
8010072a:	75 e1                	jne    8010070d <consolewrite+0x2d>
  release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 ff 10 80       	push   $0x8010ff20
80100734:	e8 07 4c 00 00       	call   80105340 <release>
  ilock(ip);
80100739:	58                   	pop    %eax
8010073a:	ff 75 08             	push   0x8(%ebp)
8010073d:	e8 8e 11 00 00       	call   801018d0 <ilock>

  return n;
}
80100742:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100745:	89 f0                	mov    %esi,%eax
80100747:	5b                   	pop    %ebx
80100748:	5e                   	pop    %esi
80100749:	5f                   	pop    %edi
8010074a:	5d                   	pop    %ebp
8010074b:	c3                   	ret
8010074c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100750 <printint>:
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	57                   	push   %edi
80100754:	56                   	push   %esi
80100755:	53                   	push   %ebx
80100756:	89 d3                	mov    %edx,%ebx
80100758:	83 ec 2c             	sub    $0x2c,%esp
  if(sign && (sign = xx < 0))
8010075b:	85 c0                	test   %eax,%eax
8010075d:	79 05                	jns    80100764 <printint+0x14>
8010075f:	83 e1 01             	and    $0x1,%ecx
80100762:	75 64                	jne    801007c8 <printint+0x78>
    x = xx;
80100764:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
8010076b:	89 c1                	mov    %eax,%ecx
  i = 0;
8010076d:	31 f6                	xor    %esi,%esi
8010076f:	90                   	nop
    buf[i++] = digits[x % base];
80100770:	89 c8                	mov    %ecx,%eax
80100772:	31 d2                	xor    %edx,%edx
80100774:	89 f7                	mov    %esi,%edi
80100776:	f7 f3                	div    %ebx
80100778:	8d 76 01             	lea    0x1(%esi),%esi
8010077b:	0f b6 92 e8 87 10 80 	movzbl -0x7fef7818(%edx),%edx
80100782:	88 54 35 d7          	mov    %dl,-0x29(%ebp,%esi,1)
  }while((x /= base) != 0);
80100786:	89 ca                	mov    %ecx,%edx
80100788:	89 c1                	mov    %eax,%ecx
8010078a:	39 da                	cmp    %ebx,%edx
8010078c:	73 e2                	jae    80100770 <printint+0x20>
  if(sign)
8010078e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80100791:	85 c9                	test   %ecx,%ecx
80100793:	74 07                	je     8010079c <printint+0x4c>
    buf[i++] = '-';
80100795:	c6 44 35 d8 2d       	movb   $0x2d,-0x28(%ebp,%esi,1)
  while(--i >= 0)
8010079a:	89 f7                	mov    %esi,%edi
8010079c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
8010079f:	01 df                	add    %ebx,%edi
  if(panicked){
801007a1:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
    consputc(buf[i]);
801007a7:	0f be 07             	movsbl (%edi),%eax
  if(panicked){
801007aa:	85 d2                	test   %edx,%edx
801007ac:	74 0a                	je     801007b8 <printint+0x68>
801007ae:	fa                   	cli
    for(;;)
801007af:	eb fe                	jmp    801007af <printint+0x5f>
801007b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801007b8:	e8 73 fd ff ff       	call   80100530 <consputc.part.0>
  while(--i >= 0)
801007bd:	8d 47 ff             	lea    -0x1(%edi),%eax
801007c0:	39 df                	cmp    %ebx,%edi
801007c2:	74 11                	je     801007d5 <printint+0x85>
801007c4:	89 c7                	mov    %eax,%edi
801007c6:	eb d9                	jmp    801007a1 <printint+0x51>
    x = -xx;
801007c8:	f7 d8                	neg    %eax
  if(sign && (sign = xx < 0))
801007ca:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    x = -xx;
801007d1:	89 c1                	mov    %eax,%ecx
801007d3:	eb 98                	jmp    8010076d <printint+0x1d>
}
801007d5:	83 c4 2c             	add    $0x2c,%esp
801007d8:	5b                   	pop    %ebx
801007d9:	5e                   	pop    %esi
801007da:	5f                   	pop    %edi
801007db:	5d                   	pop    %ebp
801007dc:	c3                   	ret
801007dd:	8d 76 00             	lea    0x0(%esi),%esi

801007e0 <cprintf>:
{
801007e0:	55                   	push   %ebp
801007e1:	89 e5                	mov    %esp,%ebp
801007e3:	57                   	push   %edi
801007e4:	56                   	push   %esi
801007e5:	53                   	push   %ebx
801007e6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801007e9:	8b 3d 54 ff 10 80    	mov    0x8010ff54,%edi
  if (fmt == 0)
801007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  if(locking)
801007f2:	85 ff                	test   %edi,%edi
801007f4:	0f 85 06 01 00 00    	jne    80100900 <cprintf+0x120>
  if (fmt == 0)
801007fa:	85 f6                	test   %esi,%esi
801007fc:	0f 84 b7 01 00 00    	je     801009b9 <cprintf+0x1d9>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100802:	0f b6 06             	movzbl (%esi),%eax
80100805:	85 c0                	test   %eax,%eax
80100807:	74 5f                	je     80100868 <cprintf+0x88>
  argp = (uint*)(void*)(&fmt + 1);
80100809:	8d 55 0c             	lea    0xc(%ebp),%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010080c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010080f:	31 db                	xor    %ebx,%ebx
80100811:	89 d7                	mov    %edx,%edi
    if(c != '%'){
80100813:	83 f8 25             	cmp    $0x25,%eax
80100816:	75 58                	jne    80100870 <cprintf+0x90>
    c = fmt[++i] & 0xff;
80100818:	83 c3 01             	add    $0x1,%ebx
8010081b:	0f b6 0c 1e          	movzbl (%esi,%ebx,1),%ecx
    if(c == 0)
8010081f:	85 c9                	test   %ecx,%ecx
80100821:	74 3a                	je     8010085d <cprintf+0x7d>
    switch(c){
80100823:	83 f9 70             	cmp    $0x70,%ecx
80100826:	0f 84 b4 00 00 00    	je     801008e0 <cprintf+0x100>
8010082c:	7f 72                	jg     801008a0 <cprintf+0xc0>
8010082e:	83 f9 25             	cmp    $0x25,%ecx
80100831:	74 4d                	je     80100880 <cprintf+0xa0>
80100833:	83 f9 64             	cmp    $0x64,%ecx
80100836:	75 76                	jne    801008ae <cprintf+0xce>
      printint(*argp++, 10, 1);
80100838:	8d 47 04             	lea    0x4(%edi),%eax
8010083b:	b9 01 00 00 00       	mov    $0x1,%ecx
80100840:	ba 0a 00 00 00       	mov    $0xa,%edx
80100845:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100848:	8b 07                	mov    (%edi),%eax
8010084a:	e8 01 ff ff ff       	call   80100750 <printint>
8010084f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100852:	83 c3 01             	add    $0x1,%ebx
80100855:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100859:	85 c0                	test   %eax,%eax
8010085b:	75 b6                	jne    80100813 <cprintf+0x33>
8010085d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  if(locking)
80100860:	85 ff                	test   %edi,%edi
80100862:	0f 85 bb 00 00 00    	jne    80100923 <cprintf+0x143>
}
80100868:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010086b:	5b                   	pop    %ebx
8010086c:	5e                   	pop    %esi
8010086d:	5f                   	pop    %edi
8010086e:	5d                   	pop    %ebp
8010086f:	c3                   	ret
  if(panicked){
80100870:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
80100876:	85 c9                	test   %ecx,%ecx
80100878:	74 19                	je     80100893 <cprintf+0xb3>
8010087a:	fa                   	cli
    for(;;)
8010087b:	eb fe                	jmp    8010087b <cprintf+0x9b>
8010087d:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
80100880:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
80100886:	85 c9                	test   %ecx,%ecx
80100888:	0f 85 f2 00 00 00    	jne    80100980 <cprintf+0x1a0>
8010088e:	b8 25 00 00 00       	mov    $0x25,%eax
80100893:	e8 98 fc ff ff       	call   80100530 <consputc.part.0>
      break;
80100898:	eb b8                	jmp    80100852 <cprintf+0x72>
8010089a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    switch(c){
801008a0:	83 f9 73             	cmp    $0x73,%ecx
801008a3:	0f 84 8f 00 00 00    	je     80100938 <cprintf+0x158>
801008a9:	83 f9 78             	cmp    $0x78,%ecx
801008ac:	74 32                	je     801008e0 <cprintf+0x100>
  if(panicked){
801008ae:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
801008b4:	85 d2                	test   %edx,%edx
801008b6:	0f 85 b8 00 00 00    	jne    80100974 <cprintf+0x194>
801008bc:	b8 25 00 00 00       	mov    $0x25,%eax
801008c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801008c4:	e8 67 fc ff ff       	call   80100530 <consputc.part.0>
801008c9:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
801008ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801008d1:	85 c0                	test   %eax,%eax
801008d3:	0f 84 cd 00 00 00    	je     801009a6 <cprintf+0x1c6>
801008d9:	fa                   	cli
    for(;;)
801008da:	eb fe                	jmp    801008da <cprintf+0xfa>
801008dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      printint(*argp++, 16, 0);
801008e0:	8d 47 04             	lea    0x4(%edi),%eax
801008e3:	31 c9                	xor    %ecx,%ecx
801008e5:	ba 10 00 00 00       	mov    $0x10,%edx
801008ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
801008ed:	8b 07                	mov    (%edi),%eax
801008ef:	e8 5c fe ff ff       	call   80100750 <printint>
801008f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
      break;
801008f7:	e9 56 ff ff ff       	jmp    80100852 <cprintf+0x72>
801008fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
80100900:	83 ec 0c             	sub    $0xc,%esp
80100903:	68 20 ff 10 80       	push   $0x8010ff20
80100908:	e8 93 4a 00 00       	call   801053a0 <acquire>
  if (fmt == 0)
8010090d:	83 c4 10             	add    $0x10,%esp
80100910:	85 f6                	test   %esi,%esi
80100912:	0f 84 a1 00 00 00    	je     801009b9 <cprintf+0x1d9>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100918:	0f b6 06             	movzbl (%esi),%eax
8010091b:	85 c0                	test   %eax,%eax
8010091d:	0f 85 e6 fe ff ff    	jne    80100809 <cprintf+0x29>
    release(&cons.lock);
80100923:	83 ec 0c             	sub    $0xc,%esp
80100926:	68 20 ff 10 80       	push   $0x8010ff20
8010092b:	e8 10 4a 00 00       	call   80105340 <release>
80100930:	83 c4 10             	add    $0x10,%esp
80100933:	e9 30 ff ff ff       	jmp    80100868 <cprintf+0x88>
      if((s = (char*)*argp++) == 0)
80100938:	8b 17                	mov    (%edi),%edx
8010093a:	8d 47 04             	lea    0x4(%edi),%eax
8010093d:	85 d2                	test   %edx,%edx
8010093f:	74 27                	je     80100968 <cprintf+0x188>
      for(; *s; s++)
80100941:	0f b6 0a             	movzbl (%edx),%ecx
      if((s = (char*)*argp++) == 0)
80100944:	89 d7                	mov    %edx,%edi
      for(; *s; s++)
80100946:	84 c9                	test   %cl,%cl
80100948:	74 68                	je     801009b2 <cprintf+0x1d2>
8010094a:	89 5d e0             	mov    %ebx,-0x20(%ebp)
8010094d:	89 fb                	mov    %edi,%ebx
8010094f:	89 f7                	mov    %esi,%edi
80100951:	89 c6                	mov    %eax,%esi
80100953:	0f be c1             	movsbl %cl,%eax
  if(panicked){
80100956:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
8010095c:	85 d2                	test   %edx,%edx
8010095e:	74 28                	je     80100988 <cprintf+0x1a8>
80100960:	fa                   	cli
    for(;;)
80100961:	eb fe                	jmp    80100961 <cprintf+0x181>
80100963:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100967:	90                   	nop
80100968:	b9 28 00 00 00       	mov    $0x28,%ecx
        s = "(null)";
8010096d:	bf 78 82 10 80       	mov    $0x80108278,%edi
80100972:	eb d6                	jmp    8010094a <cprintf+0x16a>
80100974:	fa                   	cli
    for(;;)
80100975:	eb fe                	jmp    80100975 <cprintf+0x195>
80100977:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010097e:	66 90                	xchg   %ax,%ax
80100980:	fa                   	cli
80100981:	eb fe                	jmp    80100981 <cprintf+0x1a1>
80100983:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100987:	90                   	nop
80100988:	e8 a3 fb ff ff       	call   80100530 <consputc.part.0>
      for(; *s; s++)
8010098d:	0f be 43 01          	movsbl 0x1(%ebx),%eax
80100991:	83 c3 01             	add    $0x1,%ebx
80100994:	84 c0                	test   %al,%al
80100996:	75 be                	jne    80100956 <cprintf+0x176>
      if((s = (char*)*argp++) == 0)
80100998:	89 f0                	mov    %esi,%eax
8010099a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
8010099d:	89 fe                	mov    %edi,%esi
8010099f:	89 c7                	mov    %eax,%edi
801009a1:	e9 ac fe ff ff       	jmp    80100852 <cprintf+0x72>
801009a6:	89 c8                	mov    %ecx,%eax
801009a8:	e8 83 fb ff ff       	call   80100530 <consputc.part.0>
      break;
801009ad:	e9 a0 fe ff ff       	jmp    80100852 <cprintf+0x72>
      if((s = (char*)*argp++) == 0)
801009b2:	89 c7                	mov    %eax,%edi
801009b4:	e9 99 fe ff ff       	jmp    80100852 <cprintf+0x72>
    panic("null fmt");
801009b9:	83 ec 0c             	sub    $0xc,%esp
801009bc:	68 7f 82 10 80       	push   $0x8010827f
801009c1:	e8 ea fa ff ff       	call   801004b0 <panic>
801009c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801009cd:	8d 76 00             	lea    0x0(%esi),%esi

801009d0 <consoleintr>:
{
801009d0:	55                   	push   %ebp
801009d1:	89 e5                	mov    %esp,%ebp
801009d3:	57                   	push   %edi
  int c, doprocdump = 0;
801009d4:	31 ff                	xor    %edi,%edi
{
801009d6:	56                   	push   %esi
801009d7:	53                   	push   %ebx
801009d8:	83 ec 18             	sub    $0x18,%esp
801009db:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&cons.lock);
801009de:	68 20 ff 10 80       	push   $0x8010ff20
801009e3:	e8 b8 49 00 00       	call   801053a0 <acquire>
  while((c = getc()) >= 0){
801009e8:	83 c4 10             	add    $0x10,%esp
801009eb:	ff d6                	call   *%esi
801009ed:	89 c3                	mov    %eax,%ebx
801009ef:	85 c0                	test   %eax,%eax
801009f1:	78 22                	js     80100a15 <consoleintr+0x45>
    switch(c){
801009f3:	83 fb 15             	cmp    $0x15,%ebx
801009f6:	74 47                	je     80100a3f <consoleintr+0x6f>
801009f8:	7f 76                	jg     80100a70 <consoleintr+0xa0>
801009fa:	83 fb 08             	cmp    $0x8,%ebx
801009fd:	74 76                	je     80100a75 <consoleintr+0xa5>
801009ff:	83 fb 10             	cmp    $0x10,%ebx
80100a02:	0f 85 f8 00 00 00    	jne    80100b00 <consoleintr+0x130>
  while((c = getc()) >= 0){
80100a08:	ff d6                	call   *%esi
    switch(c){
80100a0a:	bf 01 00 00 00       	mov    $0x1,%edi
  while((c = getc()) >= 0){
80100a0f:	89 c3                	mov    %eax,%ebx
80100a11:	85 c0                	test   %eax,%eax
80100a13:	79 de                	jns    801009f3 <consoleintr+0x23>
  release(&cons.lock);
80100a15:	83 ec 0c             	sub    $0xc,%esp
80100a18:	68 20 ff 10 80       	push   $0x8010ff20
80100a1d:	e8 1e 49 00 00       	call   80105340 <release>
  if(doprocdump) {
80100a22:	83 c4 10             	add    $0x10,%esp
80100a25:	85 ff                	test   %edi,%edi
80100a27:	0f 85 4b 01 00 00    	jne    80100b78 <consoleintr+0x1a8>
}
80100a2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a30:	5b                   	pop    %ebx
80100a31:	5e                   	pop    %esi
80100a32:	5f                   	pop    %edi
80100a33:	5d                   	pop    %ebp
80100a34:	c3                   	ret
80100a35:	b8 00 01 00 00       	mov    $0x100,%eax
80100a3a:	e8 f1 fa ff ff       	call   80100530 <consputc.part.0>
      while(input.e != input.w &&
80100a3f:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100a44:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100a4a:	74 9f                	je     801009eb <consoleintr+0x1b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100a4c:	83 e8 01             	sub    $0x1,%eax
80100a4f:	89 c2                	mov    %eax,%edx
80100a51:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100a54:	80 ba 80 fe 10 80 0a 	cmpb   $0xa,-0x7fef0180(%edx)
80100a5b:	74 8e                	je     801009eb <consoleintr+0x1b>
  if(panicked){
80100a5d:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.e--;
80100a63:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100a68:	85 d2                	test   %edx,%edx
80100a6a:	74 c9                	je     80100a35 <consoleintr+0x65>
80100a6c:	fa                   	cli
    for(;;)
80100a6d:	eb fe                	jmp    80100a6d <consoleintr+0x9d>
80100a6f:	90                   	nop
    switch(c){
80100a70:	83 fb 7f             	cmp    $0x7f,%ebx
80100a73:	75 2b                	jne    80100aa0 <consoleintr+0xd0>
      if(input.e != input.w){
80100a75:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100a7a:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100a80:	0f 84 65 ff ff ff    	je     801009eb <consoleintr+0x1b>
        input.e--;
80100a86:	83 e8 01             	sub    $0x1,%eax
80100a89:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100a8e:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
80100a93:	85 c0                	test   %eax,%eax
80100a95:	0f 84 ce 00 00 00    	je     80100b69 <consoleintr+0x199>
80100a9b:	fa                   	cli
    for(;;)
80100a9c:	eb fe                	jmp    80100a9c <consoleintr+0xcc>
80100a9e:	66 90                	xchg   %ax,%ax
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100aa0:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100aa5:	89 c2                	mov    %eax,%edx
80100aa7:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
80100aad:	83 fa 7f             	cmp    $0x7f,%edx
80100ab0:	0f 87 35 ff ff ff    	ja     801009eb <consoleintr+0x1b>
  if(panicked){
80100ab6:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
        input.buf[input.e++ % INPUT_BUF] = c;
80100abc:	8d 50 01             	lea    0x1(%eax),%edx
80100abf:	83 e0 7f             	and    $0x7f,%eax
80100ac2:	89 15 08 ff 10 80    	mov    %edx,0x8010ff08
80100ac8:	88 98 80 fe 10 80    	mov    %bl,-0x7fef0180(%eax)
  if(panicked){
80100ace:	85 c9                	test   %ecx,%ecx
80100ad0:	0f 85 ae 00 00 00    	jne    80100b84 <consoleintr+0x1b4>
80100ad6:	89 d8                	mov    %ebx,%eax
80100ad8:	e8 53 fa ff ff       	call   80100530 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100add:	83 fb 0a             	cmp    $0xa,%ebx
80100ae0:	74 68                	je     80100b4a <consoleintr+0x17a>
80100ae2:	83 fb 04             	cmp    $0x4,%ebx
80100ae5:	74 63                	je     80100b4a <consoleintr+0x17a>
80100ae7:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80100aec:	83 e8 80             	sub    $0xffffff80,%eax
80100aef:	39 05 08 ff 10 80    	cmp    %eax,0x8010ff08
80100af5:	0f 85 f0 fe ff ff    	jne    801009eb <consoleintr+0x1b>
80100afb:	eb 52                	jmp    80100b4f <consoleintr+0x17f>
80100afd:	8d 76 00             	lea    0x0(%esi),%esi
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100b00:	85 db                	test   %ebx,%ebx
80100b02:	0f 84 e3 fe ff ff    	je     801009eb <consoleintr+0x1b>
80100b08:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100b0d:	89 c2                	mov    %eax,%edx
80100b0f:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
80100b15:	83 fa 7f             	cmp    $0x7f,%edx
80100b18:	0f 87 cd fe ff ff    	ja     801009eb <consoleintr+0x1b>
        input.buf[input.e++ % INPUT_BUF] = c;
80100b1e:	8d 50 01             	lea    0x1(%eax),%edx
  if(panicked){
80100b21:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
        input.buf[input.e++ % INPUT_BUF] = c;
80100b27:	83 e0 7f             	and    $0x7f,%eax
        c = (c == '\r') ? '\n' : c;
80100b2a:	83 fb 0d             	cmp    $0xd,%ebx
80100b2d:	75 93                	jne    80100ac2 <consoleintr+0xf2>
        input.buf[input.e++ % INPUT_BUF] = c;
80100b2f:	89 15 08 ff 10 80    	mov    %edx,0x8010ff08
80100b35:	c6 80 80 fe 10 80 0a 	movb   $0xa,-0x7fef0180(%eax)
  if(panicked){
80100b3c:	85 c9                	test   %ecx,%ecx
80100b3e:	75 44                	jne    80100b84 <consoleintr+0x1b4>
80100b40:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b45:	e8 e6 f9 ff ff       	call   80100530 <consputc.part.0>
          input.w = input.e;
80100b4a:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
          wakeup(&input.r);
80100b4f:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100b52:	a3 04 ff 10 80       	mov    %eax,0x8010ff04
          wakeup(&input.r);
80100b57:	68 00 ff 10 80       	push   $0x8010ff00
80100b5c:	e8 5f 38 00 00       	call   801043c0 <wakeup>
80100b61:	83 c4 10             	add    $0x10,%esp
80100b64:	e9 82 fe ff ff       	jmp    801009eb <consoleintr+0x1b>
80100b69:	b8 00 01 00 00       	mov    $0x100,%eax
80100b6e:	e8 bd f9 ff ff       	call   80100530 <consputc.part.0>
80100b73:	e9 73 fe ff ff       	jmp    801009eb <consoleintr+0x1b>
}
80100b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b7b:	5b                   	pop    %ebx
80100b7c:	5e                   	pop    %esi
80100b7d:	5f                   	pop    %edi
80100b7e:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100b7f:	e9 1c 39 00 00       	jmp    801044a0 <procdump>
80100b84:	fa                   	cli
    for(;;)
80100b85:	eb fe                	jmp    80100b85 <consoleintr+0x1b5>
80100b87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b8e:	66 90                	xchg   %ax,%ax

80100b90 <consoleinit>:

void
consoleinit(void)
{
80100b90:	55                   	push   %ebp
80100b91:	89 e5                	mov    %esp,%ebp
80100b93:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100b96:	68 88 82 10 80       	push   $0x80108288
80100b9b:	68 20 ff 10 80       	push   $0x8010ff20
80100ba0:	e8 0b 46 00 00       	call   801051b0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100ba5:	58                   	pop    %eax
80100ba6:	5a                   	pop    %edx
80100ba7:	6a 00                	push   $0x0
80100ba9:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100bab:	c7 05 0c 09 11 80 e0 	movl   $0x801006e0,0x8011090c
80100bb2:	06 10 80 
  devsw[CONSOLE].read = consoleread;
80100bb5:	c7 05 08 09 11 80 b0 	movl   $0x801003b0,0x80110908
80100bbc:	03 10 80 
  cons.locking = 1;
80100bbf:	c7 05 54 ff 10 80 01 	movl   $0x1,0x8010ff54
80100bc6:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100bc9:	e8 c2 19 00 00       	call   80102590 <ioapicenable>
}
80100bce:	83 c4 10             	add    $0x10,%esp
80100bd1:	c9                   	leave
80100bd2:	c3                   	ret
80100bd3:	66 90                	xchg   %ax,%ax
80100bd5:	66 90                	xchg   %ax,%ax
80100bd7:	66 90                	xchg   %ax,%ax
80100bd9:	66 90                	xchg   %ax,%ax
80100bdb:	66 90                	xchg   %ax,%ax
80100bdd:	66 90                	xchg   %ax,%ax
80100bdf:	90                   	nop

80100be0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100be0:	55                   	push   %ebp
80100be1:	89 e5                	mov    %esp,%ebp
80100be3:	57                   	push   %edi
80100be4:	56                   	push   %esi
80100be5:	53                   	push   %ebx
80100be6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bec:	e8 ff 30 00 00       	call   80103cf0 <myproc>
80100bf1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100bf7:	e8 24 23 00 00       	call   80102f20 <begin_op>

  if((ip = namei(path)) == 0){
80100bfc:	83 ec 0c             	sub    $0xc,%esp
80100bff:	ff 75 08             	push   0x8(%ebp)
80100c02:	e8 a9 15 00 00       	call   801021b0 <namei>
80100c07:	83 c4 10             	add    $0x10,%esp
80100c0a:	85 c0                	test   %eax,%eax
80100c0c:	0f 84 30 03 00 00    	je     80100f42 <exec+0x362>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100c12:	83 ec 0c             	sub    $0xc,%esp
80100c15:	89 c7                	mov    %eax,%edi
80100c17:	50                   	push   %eax
80100c18:	e8 b3 0c 00 00       	call   801018d0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c1d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	50                   	push   %eax
80100c28:	57                   	push   %edi
80100c29:	e8 b2 0f 00 00       	call   80101be0 <readi>
80100c2e:	83 c4 20             	add    $0x20,%esp
80100c31:	83 f8 34             	cmp    $0x34,%eax
80100c34:	0f 85 01 01 00 00    	jne    80100d3b <exec+0x15b>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c3a:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100c41:	45 4c 46 
80100c44:	0f 85 f1 00 00 00    	jne    80100d3b <exec+0x15b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c4a:	e8 f1 71 00 00       	call   80107e40 <setupkvm>
80100c4f:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100c55:	85 c0                	test   %eax,%eax
80100c57:	0f 84 de 00 00 00    	je     80100d3b <exec+0x15b>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c5d:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100c64:	00 
80100c65:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100c6b:	0f 84 a1 02 00 00    	je     80100f12 <exec+0x332>
  sz = 0;
80100c71:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100c78:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c7b:	31 db                	xor    %ebx,%ebx
80100c7d:	e9 8c 00 00 00       	jmp    80100d0e <exec+0x12e>
80100c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c88:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100c8f:	75 6c                	jne    80100cfd <exec+0x11d>
      continue;
    if(ph.memsz < ph.filesz)
80100c91:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100c97:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100c9d:	0f 82 87 00 00 00    	jb     80100d2a <exec+0x14a>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100ca3:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100ca9:	72 7f                	jb     80100d2a <exec+0x14a>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cab:	83 ec 04             	sub    $0x4,%esp
80100cae:	50                   	push   %eax
80100caf:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100cb5:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100cbb:	e8 30 6f 00 00       	call   80107bf0 <allocuvm>
80100cc0:	83 c4 10             	add    $0x10,%esp
80100cc3:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100cc9:	85 c0                	test   %eax,%eax
80100ccb:	74 5d                	je     80100d2a <exec+0x14a>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccd:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100cd3:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100cd8:	75 50                	jne    80100d2a <exec+0x14a>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cda:	83 ec 0c             	sub    $0xc,%esp
80100cdd:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100ce3:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100ce9:	57                   	push   %edi
80100cea:	50                   	push   %eax
80100ceb:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100cf1:	e8 2a 6e 00 00       	call   80107b20 <loaduvm>
80100cf6:	83 c4 20             	add    $0x20,%esp
80100cf9:	85 c0                	test   %eax,%eax
80100cfb:	78 2d                	js     80100d2a <exec+0x14a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cfd:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100d04:	83 c3 01             	add    $0x1,%ebx
80100d07:	83 c6 20             	add    $0x20,%esi
80100d0a:	39 d8                	cmp    %ebx,%eax
80100d0c:	7e 52                	jle    80100d60 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d0e:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100d14:	6a 20                	push   $0x20
80100d16:	56                   	push   %esi
80100d17:	50                   	push   %eax
80100d18:	57                   	push   %edi
80100d19:	e8 c2 0e 00 00       	call   80101be0 <readi>
80100d1e:	83 c4 10             	add    $0x10,%esp
80100d21:	83 f8 20             	cmp    $0x20,%eax
80100d24:	0f 84 5e ff ff ff    	je     80100c88 <exec+0xa8>
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
80100d2a:	83 ec 0c             	sub    $0xc,%esp
80100d2d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d33:	e8 88 70 00 00       	call   80107dc0 <freevm>
  if(ip){
80100d38:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80100d3b:	83 ec 0c             	sub    $0xc,%esp
80100d3e:	57                   	push   %edi
80100d3f:	e8 1c 0e 00 00       	call   80101b60 <iunlockput>
    end_op();
80100d44:	e8 47 22 00 00       	call   80102f90 <end_op>
80100d49:	83 c4 10             	add    $0x10,%esp
    return -1;
80100d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return -1;
}
80100d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d54:	5b                   	pop    %ebx
80100d55:	5e                   	pop    %esi
80100d56:	5f                   	pop    %edi
80100d57:	5d                   	pop    %ebp
80100d58:	c3                   	ret
80100d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  sz = PGROUNDUP(sz);
80100d60:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100d66:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
80100d6c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d72:	8d 9e 00 20 00 00    	lea    0x2000(%esi),%ebx
  iunlockput(ip);
80100d78:	83 ec 0c             	sub    $0xc,%esp
80100d7b:	57                   	push   %edi
80100d7c:	e8 df 0d 00 00       	call   80101b60 <iunlockput>
  end_op();
80100d81:	e8 0a 22 00 00       	call   80102f90 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d86:	83 c4 0c             	add    $0xc,%esp
80100d89:	53                   	push   %ebx
80100d8a:	56                   	push   %esi
80100d8b:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100d91:	56                   	push   %esi
80100d92:	e8 59 6e 00 00       	call   80107bf0 <allocuvm>
80100d97:	83 c4 10             	add    $0x10,%esp
80100d9a:	89 c7                	mov    %eax,%edi
80100d9c:	85 c0                	test   %eax,%eax
80100d9e:	0f 84 86 00 00 00    	je     80100e2a <exec+0x24a>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100da4:	83 ec 08             	sub    $0x8,%esp
80100da7:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  sp = sz;
80100dad:	89 fb                	mov    %edi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100daf:	50                   	push   %eax
80100db0:	56                   	push   %esi
  for(argc = 0; argv[argc]; argc++) {
80100db1:	31 f6                	xor    %esi,%esi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100db3:	e8 a8 71 00 00       	call   80107f60 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dbb:	83 c4 10             	add    $0x10,%esp
80100dbe:	8b 10                	mov    (%eax),%edx
80100dc0:	85 d2                	test   %edx,%edx
80100dc2:	0f 84 56 01 00 00    	je     80100f1e <exec+0x33e>
80100dc8:	89 bd f0 fe ff ff    	mov    %edi,-0x110(%ebp)
80100dce:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100dd1:	eb 23                	jmp    80100df6 <exec+0x216>
80100dd3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100dd7:	90                   	nop
80100dd8:	8d 46 01             	lea    0x1(%esi),%eax
    ustack[3+argc] = sp;
80100ddb:	89 9c b5 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%esi,4)
80100de2:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
  for(argc = 0; argv[argc]; argc++) {
80100de8:	8b 14 87             	mov    (%edi,%eax,4),%edx
80100deb:	85 d2                	test   %edx,%edx
80100ded:	74 51                	je     80100e40 <exec+0x260>
    if(argc >= MAXARG)
80100def:	83 f8 20             	cmp    $0x20,%eax
80100df2:	74 36                	je     80100e2a <exec+0x24a>
80100df4:	89 c6                	mov    %eax,%esi
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	83 ec 0c             	sub    $0xc,%esp
80100df9:	52                   	push   %edx
80100dfa:	e8 91 48 00 00       	call   80105690 <strlen>
80100dff:	29 c3                	sub    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e01:	58                   	pop    %eax
80100e02:	ff 34 b7             	push   (%edi,%esi,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e05:	83 eb 01             	sub    $0x1,%ebx
80100e08:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e0b:	e8 80 48 00 00       	call   80105690 <strlen>
80100e10:	83 c0 01             	add    $0x1,%eax
80100e13:	50                   	push   %eax
80100e14:	ff 34 b7             	push   (%edi,%esi,4)
80100e17:	53                   	push   %ebx
80100e18:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100e1e:	e8 1d 73 00 00       	call   80108140 <copyout>
80100e23:	83 c4 20             	add    $0x20,%esp
80100e26:	85 c0                	test   %eax,%eax
80100e28:	79 ae                	jns    80100dd8 <exec+0x1f8>
    freevm(pgdir);
80100e2a:	83 ec 0c             	sub    $0xc,%esp
80100e2d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100e33:	e8 88 6f 00 00       	call   80107dc0 <freevm>
80100e38:	83 c4 10             	add    $0x10,%esp
80100e3b:	e9 0c ff ff ff       	jmp    80100d4c <exec+0x16c>
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e40:	8d 14 b5 08 00 00 00 	lea    0x8(,%esi,4),%edx
  ustack[3+argc] = 0;
80100e47:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100e4d:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100e53:	8d 46 04             	lea    0x4(%esi),%eax
  sp -= (3+argc+1) * 4;
80100e56:	8d 72 0c             	lea    0xc(%edx),%esi
  ustack[3+argc] = 0;
80100e59:	c7 84 85 58 ff ff ff 	movl   $0x0,-0xa8(%ebp,%eax,4)
80100e60:	00 00 00 00 
  ustack[1] = argc;
80100e64:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7a:	89 d8                	mov    %ebx,%eax
  sp -= (3+argc+1) * 4;
80100e7c:	29 f3                	sub    %esi,%ebx
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7e:	29 d0                	sub    %edx,%eax
80100e80:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e86:	56                   	push   %esi
80100e87:	51                   	push   %ecx
80100e88:	53                   	push   %ebx
80100e89:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100e8f:	e8 ac 72 00 00       	call   80108140 <copyout>
80100e94:	83 c4 10             	add    $0x10,%esp
80100e97:	85 c0                	test   %eax,%eax
80100e99:	78 8f                	js     80100e2a <exec+0x24a>
  for(last=s=path; *s; s++)
80100e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e9e:	8b 55 08             	mov    0x8(%ebp),%edx
80100ea1:	0f b6 00             	movzbl (%eax),%eax
80100ea4:	84 c0                	test   %al,%al
80100ea6:	74 17                	je     80100ebf <exec+0x2df>
80100ea8:	89 d1                	mov    %edx,%ecx
80100eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      last = s+1;
80100eb0:	83 c1 01             	add    $0x1,%ecx
80100eb3:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100eb5:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100eb8:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100ebb:	84 c0                	test   %al,%al
80100ebd:	75 f1                	jne    80100eb0 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ebf:	83 ec 04             	sub    $0x4,%esp
80100ec2:	6a 10                	push   $0x10
80100ec4:	52                   	push   %edx
80100ec5:	8b b5 ec fe ff ff    	mov    -0x114(%ebp),%esi
80100ecb:	8d 46 70             	lea    0x70(%esi),%eax
80100ece:	50                   	push   %eax
80100ecf:	e8 7c 47 00 00       	call   80105650 <safestrcpy>
  curproc->pgdir = pgdir;
80100ed4:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100eda:	89 f0                	mov    %esi,%eax
80100edc:	8b 76 08             	mov    0x8(%esi),%esi
  curproc->sz = sz;
80100edf:	89 38                	mov    %edi,(%eax)
  curproc->pgdir = pgdir;
80100ee1:	89 48 08             	mov    %ecx,0x8(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ee4:	89 c1                	mov    %eax,%ecx
80100ee6:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100eec:	8b 40 1c             	mov    0x1c(%eax),%eax
80100eef:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ef2:	8b 41 1c             	mov    0x1c(%ecx),%eax
80100ef5:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100ef8:	89 0c 24             	mov    %ecx,(%esp)
80100efb:	e8 70 6a 00 00       	call   80107970 <switchuvm>
  freevm(oldpgdir);
80100f00:	89 34 24             	mov    %esi,(%esp)
80100f03:	e8 b8 6e 00 00       	call   80107dc0 <freevm>
  return 0;
80100f08:	83 c4 10             	add    $0x10,%esp
80100f0b:	31 c0                	xor    %eax,%eax
80100f0d:	e9 3f fe ff ff       	jmp    80100d51 <exec+0x171>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f12:	bb 00 20 00 00       	mov    $0x2000,%ebx
80100f17:	31 f6                	xor    %esi,%esi
80100f19:	e9 5a fe ff ff       	jmp    80100d78 <exec+0x198>
  for(argc = 0; argv[argc]; argc++) {
80100f1e:	be 10 00 00 00       	mov    $0x10,%esi
80100f23:	ba 04 00 00 00       	mov    $0x4,%edx
80100f28:	b8 03 00 00 00       	mov    $0x3,%eax
80100f2d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100f34:	00 00 00 
80100f37:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
80100f3d:	e9 17 ff ff ff       	jmp    80100e59 <exec+0x279>
    end_op();
80100f42:	e8 49 20 00 00       	call   80102f90 <end_op>
    cprintf("exec: fail\n");
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	68 90 82 10 80       	push   $0x80108290
80100f4f:	e8 8c f8 ff ff       	call   801007e0 <cprintf>
    return -1;
80100f54:	83 c4 10             	add    $0x10,%esp
80100f57:	e9 f0 fd ff ff       	jmp    80100d4c <exec+0x16c>
80100f5c:	66 90                	xchg   %ax,%ax
80100f5e:	66 90                	xchg   %ax,%ax

80100f60 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f60:	55                   	push   %ebp
80100f61:	89 e5                	mov    %esp,%ebp
80100f63:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100f66:	68 9c 82 10 80       	push   $0x8010829c
80100f6b:	68 60 ff 10 80       	push   $0x8010ff60
80100f70:	e8 3b 42 00 00       	call   801051b0 <initlock>
}
80100f75:	83 c4 10             	add    $0x10,%esp
80100f78:	c9                   	leave
80100f79:	c3                   	ret
80100f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100f80 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f80:	55                   	push   %ebp
80100f81:	89 e5                	mov    %esp,%ebp
80100f83:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f84:	bb 94 ff 10 80       	mov    $0x8010ff94,%ebx
{
80100f89:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100f8c:	68 60 ff 10 80       	push   $0x8010ff60
80100f91:	e8 0a 44 00 00       	call   801053a0 <acquire>
80100f96:	83 c4 10             	add    $0x10,%esp
80100f99:	eb 10                	jmp    80100fab <filealloc+0x2b>
80100f9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f9f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa0:	83 c3 18             	add    $0x18,%ebx
80100fa3:	81 fb f4 08 11 80    	cmp    $0x801108f4,%ebx
80100fa9:	74 25                	je     80100fd0 <filealloc+0x50>
    if(f->ref == 0){
80100fab:	8b 43 04             	mov    0x4(%ebx),%eax
80100fae:	85 c0                	test   %eax,%eax
80100fb0:	75 ee                	jne    80100fa0 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100fb2:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100fb5:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100fbc:	68 60 ff 10 80       	push   $0x8010ff60
80100fc1:	e8 7a 43 00 00       	call   80105340 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100fc6:	89 d8                	mov    %ebx,%eax
      return f;
80100fc8:	83 c4 10             	add    $0x10,%esp
}
80100fcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fce:	c9                   	leave
80100fcf:	c3                   	ret
  release(&ftable.lock);
80100fd0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100fd3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100fd5:	68 60 ff 10 80       	push   $0x8010ff60
80100fda:	e8 61 43 00 00       	call   80105340 <release>
}
80100fdf:	89 d8                	mov    %ebx,%eax
  return 0;
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fe7:	c9                   	leave
80100fe8:	c3                   	ret
80100fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100ff0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100ff0:	55                   	push   %ebp
80100ff1:	89 e5                	mov    %esp,%ebp
80100ff3:	53                   	push   %ebx
80100ff4:	83 ec 10             	sub    $0x10,%esp
80100ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100ffa:	68 60 ff 10 80       	push   $0x8010ff60
80100fff:	e8 9c 43 00 00       	call   801053a0 <acquire>
  if(f->ref < 1)
80101004:	8b 43 04             	mov    0x4(%ebx),%eax
80101007:	83 c4 10             	add    $0x10,%esp
8010100a:	85 c0                	test   %eax,%eax
8010100c:	7e 1a                	jle    80101028 <filedup+0x38>
    panic("filedup");
  f->ref++;
8010100e:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80101011:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80101014:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80101017:	68 60 ff 10 80       	push   $0x8010ff60
8010101c:	e8 1f 43 00 00       	call   80105340 <release>
  return f;
}
80101021:	89 d8                	mov    %ebx,%eax
80101023:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101026:	c9                   	leave
80101027:	c3                   	ret
    panic("filedup");
80101028:	83 ec 0c             	sub    $0xc,%esp
8010102b:	68 a3 82 10 80       	push   $0x801082a3
80101030:	e8 7b f4 ff ff       	call   801004b0 <panic>
80101035:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101040 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101040:	55                   	push   %ebp
80101041:	89 e5                	mov    %esp,%ebp
80101043:	57                   	push   %edi
80101044:	56                   	push   %esi
80101045:	53                   	push   %ebx
80101046:	83 ec 28             	sub    $0x28,%esp
80101049:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
8010104c:	68 60 ff 10 80       	push   $0x8010ff60
80101051:	e8 4a 43 00 00       	call   801053a0 <acquire>
  if(f->ref < 1)
80101056:	8b 53 04             	mov    0x4(%ebx),%edx
80101059:	83 c4 10             	add    $0x10,%esp
8010105c:	85 d2                	test   %edx,%edx
8010105e:	0f 8e a5 00 00 00    	jle    80101109 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80101064:	83 ea 01             	sub    $0x1,%edx
80101067:	89 53 04             	mov    %edx,0x4(%ebx)
8010106a:	75 44                	jne    801010b0 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
8010106c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80101070:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80101073:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80101075:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
8010107b:	8b 73 0c             	mov    0xc(%ebx),%esi
8010107e:	88 45 e7             	mov    %al,-0x19(%ebp)
80101081:	8b 43 10             	mov    0x10(%ebx),%eax
80101084:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80101087:	68 60 ff 10 80       	push   $0x8010ff60
8010108c:	e8 af 42 00 00       	call   80105340 <release>

  if(ff.type == FD_PIPE)
80101091:	83 c4 10             	add    $0x10,%esp
80101094:	83 ff 01             	cmp    $0x1,%edi
80101097:	74 57                	je     801010f0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80101099:	83 ff 02             	cmp    $0x2,%edi
8010109c:	74 2a                	je     801010c8 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
8010109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010a1:	5b                   	pop    %ebx
801010a2:	5e                   	pop    %esi
801010a3:	5f                   	pop    %edi
801010a4:	5d                   	pop    %ebp
801010a5:	c3                   	ret
801010a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ad:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
801010b0:	c7 45 08 60 ff 10 80 	movl   $0x8010ff60,0x8(%ebp)
}
801010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010ba:	5b                   	pop    %ebx
801010bb:	5e                   	pop    %esi
801010bc:	5f                   	pop    %edi
801010bd:	5d                   	pop    %ebp
    release(&ftable.lock);
801010be:	e9 7d 42 00 00       	jmp    80105340 <release>
801010c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801010c7:	90                   	nop
    begin_op();
801010c8:	e8 53 1e 00 00       	call   80102f20 <begin_op>
    iput(ff.ip);
801010cd:	83 ec 0c             	sub    $0xc,%esp
801010d0:	ff 75 e0             	push   -0x20(%ebp)
801010d3:	e8 28 09 00 00       	call   80101a00 <iput>
    end_op();
801010d8:	83 c4 10             	add    $0x10,%esp
}
801010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010de:	5b                   	pop    %ebx
801010df:	5e                   	pop    %esi
801010e0:	5f                   	pop    %edi
801010e1:	5d                   	pop    %ebp
    end_op();
801010e2:	e9 a9 1e 00 00       	jmp    80102f90 <end_op>
801010e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ee:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
801010f0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
801010f4:	83 ec 08             	sub    $0x8,%esp
801010f7:	53                   	push   %ebx
801010f8:	56                   	push   %esi
801010f9:	e8 f2 25 00 00       	call   801036f0 <pipeclose>
801010fe:	83 c4 10             	add    $0x10,%esp
}
80101101:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101104:	5b                   	pop    %ebx
80101105:	5e                   	pop    %esi
80101106:	5f                   	pop    %edi
80101107:	5d                   	pop    %ebp
80101108:	c3                   	ret
    panic("fileclose");
80101109:	83 ec 0c             	sub    $0xc,%esp
8010110c:	68 ab 82 10 80       	push   $0x801082ab
80101111:	e8 9a f3 ff ff       	call   801004b0 <panic>
80101116:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010111d:	8d 76 00             	lea    0x0(%esi),%esi

80101120 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101120:	55                   	push   %ebp
80101121:	89 e5                	mov    %esp,%ebp
80101123:	53                   	push   %ebx
80101124:	83 ec 04             	sub    $0x4,%esp
80101127:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
8010112a:	83 3b 02             	cmpl   $0x2,(%ebx)
8010112d:	75 31                	jne    80101160 <filestat+0x40>
    ilock(f->ip);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	ff 73 10             	push   0x10(%ebx)
80101135:	e8 96 07 00 00       	call   801018d0 <ilock>
    stati(f->ip, st);
8010113a:	58                   	pop    %eax
8010113b:	5a                   	pop    %edx
8010113c:	ff 75 0c             	push   0xc(%ebp)
8010113f:	ff 73 10             	push   0x10(%ebx)
80101142:	e8 69 0a 00 00       	call   80101bb0 <stati>
    iunlock(f->ip);
80101147:	59                   	pop    %ecx
80101148:	ff 73 10             	push   0x10(%ebx)
8010114b:	e8 60 08 00 00       	call   801019b0 <iunlock>
    return 0;
  }
  return -1;
}
80101150:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101153:	83 c4 10             	add    $0x10,%esp
80101156:	31 c0                	xor    %eax,%eax
}
80101158:	c9                   	leave
80101159:	c3                   	ret
8010115a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101160:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101168:	c9                   	leave
80101169:	c3                   	ret
8010116a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101170 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101170:	55                   	push   %ebp
80101171:	89 e5                	mov    %esp,%ebp
80101173:	57                   	push   %edi
80101174:	56                   	push   %esi
80101175:	53                   	push   %ebx
80101176:	83 ec 0c             	sub    $0xc,%esp
80101179:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010117c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010117f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101182:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101186:	74 60                	je     801011e8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101188:	8b 03                	mov    (%ebx),%eax
8010118a:	83 f8 01             	cmp    $0x1,%eax
8010118d:	74 41                	je     801011d0 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010118f:	83 f8 02             	cmp    $0x2,%eax
80101192:	75 5b                	jne    801011ef <fileread+0x7f>
    ilock(f->ip);
80101194:	83 ec 0c             	sub    $0xc,%esp
80101197:	ff 73 10             	push   0x10(%ebx)
8010119a:	e8 31 07 00 00       	call   801018d0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010119f:	57                   	push   %edi
801011a0:	ff 73 14             	push   0x14(%ebx)
801011a3:	56                   	push   %esi
801011a4:	ff 73 10             	push   0x10(%ebx)
801011a7:	e8 34 0a 00 00       	call   80101be0 <readi>
801011ac:	83 c4 20             	add    $0x20,%esp
801011af:	89 c6                	mov    %eax,%esi
801011b1:	85 c0                	test   %eax,%eax
801011b3:	7e 03                	jle    801011b8 <fileread+0x48>
      f->off += r;
801011b5:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
801011b8:	83 ec 0c             	sub    $0xc,%esp
801011bb:	ff 73 10             	push   0x10(%ebx)
801011be:	e8 ed 07 00 00       	call   801019b0 <iunlock>
    return r;
801011c3:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
801011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011c9:	89 f0                	mov    %esi,%eax
801011cb:	5b                   	pop    %ebx
801011cc:	5e                   	pop    %esi
801011cd:	5f                   	pop    %edi
801011ce:	5d                   	pop    %ebp
801011cf:	c3                   	ret
    return piperead(f->pipe, addr, n);
801011d0:	8b 43 0c             	mov    0xc(%ebx),%eax
801011d3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011d9:	5b                   	pop    %ebx
801011da:	5e                   	pop    %esi
801011db:	5f                   	pop    %edi
801011dc:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
801011dd:	e9 ce 26 00 00       	jmp    801038b0 <piperead>
801011e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801011e8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801011ed:	eb d7                	jmp    801011c6 <fileread+0x56>
  panic("fileread");
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	68 b5 82 10 80       	push   $0x801082b5
801011f7:	e8 b4 f2 ff ff       	call   801004b0 <panic>
801011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101200 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101200:	55                   	push   %ebp
80101201:	89 e5                	mov    %esp,%ebp
80101203:	57                   	push   %edi
80101204:	56                   	push   %esi
80101205:	53                   	push   %ebx
80101206:	83 ec 1c             	sub    $0x1c,%esp
80101209:	8b 45 0c             	mov    0xc(%ebp),%eax
8010120c:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010120f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101212:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
80101215:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
80101219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
8010121c:	0f 84 bb 00 00 00    	je     801012dd <filewrite+0xdd>
    return -1;
  if(f->type == FD_PIPE)
80101222:	8b 03                	mov    (%ebx),%eax
80101224:	83 f8 01             	cmp    $0x1,%eax
80101227:	0f 84 bf 00 00 00    	je     801012ec <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010122d:	83 f8 02             	cmp    $0x2,%eax
80101230:	0f 85 c8 00 00 00    	jne    801012fe <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101239:	31 f6                	xor    %esi,%esi
    while(i < n){
8010123b:	85 c0                	test   %eax,%eax
8010123d:	7f 30                	jg     8010126f <filewrite+0x6f>
8010123f:	e9 94 00 00 00       	jmp    801012d8 <filewrite+0xd8>
80101244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101248:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010124b:	83 ec 0c             	sub    $0xc,%esp
        f->off += r;
8010124e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101251:	ff 73 10             	push   0x10(%ebx)
80101254:	e8 57 07 00 00       	call   801019b0 <iunlock>
      end_op();
80101259:	e8 32 1d 00 00       	call   80102f90 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010125e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101261:	83 c4 10             	add    $0x10,%esp
80101264:	39 c7                	cmp    %eax,%edi
80101266:	75 5c                	jne    801012c4 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101268:	01 fe                	add    %edi,%esi
    while(i < n){
8010126a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010126d:	7e 69                	jle    801012d8 <filewrite+0xd8>
      int n1 = n - i;
8010126f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
      if(n1 > max)
80101272:	b8 00 06 00 00       	mov    $0x600,%eax
      int n1 = n - i;
80101277:	29 f7                	sub    %esi,%edi
      if(n1 > max)
80101279:	39 c7                	cmp    %eax,%edi
8010127b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010127e:	e8 9d 1c 00 00       	call   80102f20 <begin_op>
      ilock(f->ip);
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	ff 73 10             	push   0x10(%ebx)
80101289:	e8 42 06 00 00       	call   801018d0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010128e:	57                   	push   %edi
8010128f:	ff 73 14             	push   0x14(%ebx)
80101292:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101295:	01 f0                	add    %esi,%eax
80101297:	50                   	push   %eax
80101298:	ff 73 10             	push   0x10(%ebx)
8010129b:	e8 40 0a 00 00       	call   80101ce0 <writei>
801012a0:	83 c4 20             	add    $0x20,%esp
801012a3:	85 c0                	test   %eax,%eax
801012a5:	7f a1                	jg     80101248 <filewrite+0x48>
801012a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
801012aa:	83 ec 0c             	sub    $0xc,%esp
801012ad:	ff 73 10             	push   0x10(%ebx)
801012b0:	e8 fb 06 00 00       	call   801019b0 <iunlock>
      end_op();
801012b5:	e8 d6 1c 00 00       	call   80102f90 <end_op>
      if(r < 0)
801012ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012bd:	83 c4 10             	add    $0x10,%esp
801012c0:	85 c0                	test   %eax,%eax
801012c2:	75 14                	jne    801012d8 <filewrite+0xd8>
        panic("short filewrite");
801012c4:	83 ec 0c             	sub    $0xc,%esp
801012c7:	68 be 82 10 80       	push   $0x801082be
801012cc:	e8 df f1 ff ff       	call   801004b0 <panic>
801012d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
801012d8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
801012db:	74 05                	je     801012e2 <filewrite+0xe2>
801012dd:	be ff ff ff ff       	mov    $0xffffffff,%esi
  }
  panic("filewrite");
}
801012e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012e5:	89 f0                	mov    %esi,%eax
801012e7:	5b                   	pop    %ebx
801012e8:	5e                   	pop    %esi
801012e9:	5f                   	pop    %edi
801012ea:	5d                   	pop    %ebp
801012eb:	c3                   	ret
    return pipewrite(f->pipe, addr, n);
801012ec:	8b 43 0c             	mov    0xc(%ebx),%eax
801012ef:	89 45 08             	mov    %eax,0x8(%ebp)
}
801012f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012f5:	5b                   	pop    %ebx
801012f6:	5e                   	pop    %esi
801012f7:	5f                   	pop    %edi
801012f8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801012f9:	e9 92 24 00 00       	jmp    80103790 <pipewrite>
  panic("filewrite");
801012fe:	83 ec 0c             	sub    $0xc,%esp
80101301:	68 c4 82 10 80       	push   $0x801082c4
80101306:	e8 a5 f1 ff ff       	call   801004b0 <panic>
8010130b:	66 90                	xchg   %ax,%ax
8010130d:	66 90                	xchg   %ax,%ax
8010130f:	90                   	nop

80101310 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101310:	55                   	push   %ebp
80101311:	89 e5                	mov    %esp,%ebp
80101313:	57                   	push   %edi
80101314:	56                   	push   %esi
80101315:	53                   	push   %ebx
80101316:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101319:	8b 0d c0 25 11 80    	mov    0x801125c0,%ecx
{
8010131f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101322:	85 c9                	test   %ecx,%ecx
80101324:	0f 84 8c 00 00 00    	je     801013b6 <balloc+0xa6>
8010132a:	31 ff                	xor    %edi,%edi
    bp = bread(dev, BBLOCK(b, sb));
8010132c:	89 f8                	mov    %edi,%eax
8010132e:	83 ec 08             	sub    $0x8,%esp
80101331:	89 fe                	mov    %edi,%esi
80101333:	c1 f8 0c             	sar    $0xc,%eax
80101336:	03 05 d8 25 11 80    	add    0x801125d8,%eax
8010133c:	50                   	push   %eax
8010133d:	ff 75 dc             	push   -0x24(%ebp)
80101340:	e8 4b ee ff ff       	call   80100190 <bread>
80101345:	89 7d d8             	mov    %edi,-0x28(%ebp)
80101348:	83 c4 10             	add    $0x10,%esp
8010134b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010134e:	a1 c0 25 11 80       	mov    0x801125c0,%eax
80101353:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101356:	31 c0                	xor    %eax,%eax
80101358:	eb 32                	jmp    8010138c <balloc+0x7c>
8010135a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101360:	89 c1                	mov    %eax,%ecx
80101362:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
      m = 1 << (bi % 8);
8010136a:	83 e1 07             	and    $0x7,%ecx
8010136d:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010136f:	89 c1                	mov    %eax,%ecx
80101371:	c1 f9 03             	sar    $0x3,%ecx
80101374:	0f b6 7c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%edi
80101379:	89 fa                	mov    %edi,%edx
8010137b:	85 df                	test   %ebx,%edi
8010137d:	74 49                	je     801013c8 <balloc+0xb8>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010137f:	83 c0 01             	add    $0x1,%eax
80101382:	83 c6 01             	add    $0x1,%esi
80101385:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010138a:	74 07                	je     80101393 <balloc+0x83>
8010138c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010138f:	39 d6                	cmp    %edx,%esi
80101391:	72 cd                	jb     80101360 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101393:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101396:	83 ec 0c             	sub    $0xc,%esp
80101399:	ff 75 e4             	push   -0x1c(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010139c:	81 c7 00 10 00 00    	add    $0x1000,%edi
    brelse(bp);
801013a2:	e8 69 ee ff ff       	call   80100210 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801013a7:	83 c4 10             	add    $0x10,%esp
801013aa:	3b 3d c0 25 11 80    	cmp    0x801125c0,%edi
801013b0:	0f 82 76 ff ff ff    	jb     8010132c <balloc+0x1c>
  }
  panic("balloc: out of blocks");
801013b6:	83 ec 0c             	sub    $0xc,%esp
801013b9:	68 ce 82 10 80       	push   $0x801082ce
801013be:	e8 ed f0 ff ff       	call   801004b0 <panic>
801013c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801013c7:	90                   	nop
        bp->data[bi/8] |= m;  // Mark block in use.
801013c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
801013cb:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
801013ce:	09 da                	or     %ebx,%edx
801013d0:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
801013d4:	57                   	push   %edi
801013d5:	e8 26 1d 00 00       	call   80103100 <log_write>
        brelse(bp);
801013da:	89 3c 24             	mov    %edi,(%esp)
801013dd:	e8 2e ee ff ff       	call   80100210 <brelse>
  bp = bread(dev, bno);
801013e2:	58                   	pop    %eax
801013e3:	5a                   	pop    %edx
801013e4:	56                   	push   %esi
801013e5:	ff 75 dc             	push   -0x24(%ebp)
801013e8:	e8 a3 ed ff ff       	call   80100190 <bread>
  memset(bp->data, 0, BSIZE);
801013ed:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
801013f0:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
801013f2:	8d 40 5c             	lea    0x5c(%eax),%eax
801013f5:	68 00 02 00 00       	push   $0x200
801013fa:	6a 00                	push   $0x0
801013fc:	50                   	push   %eax
801013fd:	e8 9e 40 00 00       	call   801054a0 <memset>
  log_write(bp);
80101402:	89 1c 24             	mov    %ebx,(%esp)
80101405:	e8 f6 1c 00 00       	call   80103100 <log_write>
  brelse(bp);
8010140a:	89 1c 24             	mov    %ebx,(%esp)
8010140d:	e8 fe ed ff ff       	call   80100210 <brelse>
}
80101412:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101415:	89 f0                	mov    %esi,%eax
80101417:	5b                   	pop    %ebx
80101418:	5e                   	pop    %esi
80101419:	5f                   	pop    %edi
8010141a:	5d                   	pop    %ebp
8010141b:	c3                   	ret
8010141c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101420 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101420:	55                   	push   %ebp
80101421:	89 e5                	mov    %esp,%ebp
80101423:	57                   	push   %edi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101424:	31 ff                	xor    %edi,%edi
{
80101426:	56                   	push   %esi
80101427:	89 c6                	mov    %eax,%esi
80101429:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010142a:	bb 94 09 11 80       	mov    $0x80110994,%ebx
{
8010142f:	83 ec 28             	sub    $0x28,%esp
80101432:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101435:	68 60 09 11 80       	push   $0x80110960
8010143a:	e8 61 3f 00 00       	call   801053a0 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010143f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101442:	83 c4 10             	add    $0x10,%esp
80101445:	eb 1b                	jmp    80101462 <iget+0x42>
80101447:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010144e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101450:	39 33                	cmp    %esi,(%ebx)
80101452:	74 6c                	je     801014c0 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101454:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010145a:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
80101460:	74 26                	je     80101488 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101462:	8b 43 08             	mov    0x8(%ebx),%eax
80101465:	85 c0                	test   %eax,%eax
80101467:	7f e7                	jg     80101450 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101469:	85 ff                	test   %edi,%edi
8010146b:	75 e7                	jne    80101454 <iget+0x34>
8010146d:	85 c0                	test   %eax,%eax
8010146f:	75 76                	jne    801014e7 <iget+0xc7>
      empty = ip;
80101471:	89 df                	mov    %ebx,%edi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101473:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101479:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
8010147f:	75 e1                	jne    80101462 <iget+0x42>
80101481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101488:	85 ff                	test   %edi,%edi
8010148a:	74 79                	je     80101505 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
8010148c:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
8010148f:	89 37                	mov    %esi,(%edi)
  ip->inum = inum;
80101491:	89 57 04             	mov    %edx,0x4(%edi)
  ip->ref = 1;
80101494:	c7 47 08 01 00 00 00 	movl   $0x1,0x8(%edi)
  ip->valid = 0;
8010149b:	c7 47 4c 00 00 00 00 	movl   $0x0,0x4c(%edi)
  release(&icache.lock);
801014a2:	68 60 09 11 80       	push   $0x80110960
801014a7:	e8 94 3e 00 00       	call   80105340 <release>

  return ip;
801014ac:	83 c4 10             	add    $0x10,%esp
}
801014af:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014b2:	89 f8                	mov    %edi,%eax
801014b4:	5b                   	pop    %ebx
801014b5:	5e                   	pop    %esi
801014b6:	5f                   	pop    %edi
801014b7:	5d                   	pop    %ebp
801014b8:	c3                   	ret
801014b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014c0:	39 53 04             	cmp    %edx,0x4(%ebx)
801014c3:	75 8f                	jne    80101454 <iget+0x34>
      ip->ref++;
801014c5:	83 c0 01             	add    $0x1,%eax
      release(&icache.lock);
801014c8:	83 ec 0c             	sub    $0xc,%esp
      return ip;
801014cb:	89 df                	mov    %ebx,%edi
      ip->ref++;
801014cd:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801014d0:	68 60 09 11 80       	push   $0x80110960
801014d5:	e8 66 3e 00 00       	call   80105340 <release>
      return ip;
801014da:	83 c4 10             	add    $0x10,%esp
}
801014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014e0:	89 f8                	mov    %edi,%eax
801014e2:	5b                   	pop    %ebx
801014e3:	5e                   	pop    %esi
801014e4:	5f                   	pop    %edi
801014e5:	5d                   	pop    %ebp
801014e6:	c3                   	ret
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014e7:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014ed:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801014f3:	74 10                	je     80101505 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014f5:	8b 43 08             	mov    0x8(%ebx),%eax
801014f8:	85 c0                	test   %eax,%eax
801014fa:	0f 8f 50 ff ff ff    	jg     80101450 <iget+0x30>
80101500:	e9 68 ff ff ff       	jmp    8010146d <iget+0x4d>
    panic("iget: no inodes");
80101505:	83 ec 0c             	sub    $0xc,%esp
80101508:	68 e4 82 10 80       	push   $0x801082e4
8010150d:	e8 9e ef ff ff       	call   801004b0 <panic>
80101512:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101520 <bfree>:
{
80101520:	55                   	push   %ebp
80101521:	89 c1                	mov    %eax,%ecx
  bp = bread(dev, BBLOCK(b, sb));
80101523:	89 d0                	mov    %edx,%eax
80101525:	c1 e8 0c             	shr    $0xc,%eax
{
80101528:	89 e5                	mov    %esp,%ebp
8010152a:	56                   	push   %esi
8010152b:	53                   	push   %ebx
  bp = bread(dev, BBLOCK(b, sb));
8010152c:	03 05 d8 25 11 80    	add    0x801125d8,%eax
{
80101532:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
80101534:	83 ec 08             	sub    $0x8,%esp
80101537:	50                   	push   %eax
80101538:	51                   	push   %ecx
80101539:	e8 52 ec ff ff       	call   80100190 <bread>
  m = 1 << (bi % 8);
8010153e:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
80101540:	c1 fb 03             	sar    $0x3,%ebx
80101543:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101546:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101548:	83 e1 07             	and    $0x7,%ecx
8010154b:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101550:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101556:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101558:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010155d:	85 c1                	test   %eax,%ecx
8010155f:	74 23                	je     80101584 <bfree+0x64>
  bp->data[bi/8] &= ~m;
80101561:	f7 d0                	not    %eax
  log_write(bp);
80101563:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101566:	21 c8                	and    %ecx,%eax
80101568:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010156c:	56                   	push   %esi
8010156d:	e8 8e 1b 00 00       	call   80103100 <log_write>
  brelse(bp);
80101572:	89 34 24             	mov    %esi,(%esp)
80101575:	e8 96 ec ff ff       	call   80100210 <brelse>
}
8010157a:	83 c4 10             	add    $0x10,%esp
8010157d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101580:	5b                   	pop    %ebx
80101581:	5e                   	pop    %esi
80101582:	5d                   	pop    %ebp
80101583:	c3                   	ret
    panic("freeing free block");
80101584:	83 ec 0c             	sub    $0xc,%esp
80101587:	68 f4 82 10 80       	push   $0x801082f4
8010158c:	e8 1f ef ff ff       	call   801004b0 <panic>
80101591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101598:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010159f:	90                   	nop

801015a0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801015a0:	55                   	push   %ebp
801015a1:	89 e5                	mov    %esp,%ebp
801015a3:	57                   	push   %edi
801015a4:	56                   	push   %esi
801015a5:	89 c6                	mov    %eax,%esi
801015a7:	53                   	push   %ebx
801015a8:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801015ab:	83 fa 0b             	cmp    $0xb,%edx
801015ae:	0f 86 8c 00 00 00    	jbe    80101640 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
801015b4:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
801015b7:	83 fb 7f             	cmp    $0x7f,%ebx
801015ba:	0f 87 a2 00 00 00    	ja     80101662 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801015c0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801015c6:	85 c0                	test   %eax,%eax
801015c8:	74 5e                	je     80101628 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
801015ca:	83 ec 08             	sub    $0x8,%esp
801015cd:	50                   	push   %eax
801015ce:	ff 36                	push   (%esi)
801015d0:	e8 bb eb ff ff       	call   80100190 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801015d5:	83 c4 10             	add    $0x10,%esp
801015d8:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
801015dc:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
801015de:	8b 3b                	mov    (%ebx),%edi
801015e0:	85 ff                	test   %edi,%edi
801015e2:	74 1c                	je     80101600 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801015e4:	83 ec 0c             	sub    $0xc,%esp
801015e7:	52                   	push   %edx
801015e8:	e8 23 ec ff ff       	call   80100210 <brelse>
801015ed:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801015f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801015f3:	89 f8                	mov    %edi,%eax
801015f5:	5b                   	pop    %ebx
801015f6:	5e                   	pop    %esi
801015f7:	5f                   	pop    %edi
801015f8:	5d                   	pop    %ebp
801015f9:	c3                   	ret
801015fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
80101603:	8b 06                	mov    (%esi),%eax
80101605:	e8 06 fd ff ff       	call   80101310 <balloc>
      log_write(bp);
8010160a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010160d:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
80101610:	89 03                	mov    %eax,(%ebx)
80101612:	89 c7                	mov    %eax,%edi
      log_write(bp);
80101614:	52                   	push   %edx
80101615:	e8 e6 1a 00 00       	call   80103100 <log_write>
8010161a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010161d:	83 c4 10             	add    $0x10,%esp
80101620:	eb c2                	jmp    801015e4 <bmap+0x44>
80101622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101628:	8b 06                	mov    (%esi),%eax
8010162a:	e8 e1 fc ff ff       	call   80101310 <balloc>
8010162f:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101635:	eb 93                	jmp    801015ca <bmap+0x2a>
80101637:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010163e:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
80101640:	8d 5a 14             	lea    0x14(%edx),%ebx
80101643:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101647:	85 ff                	test   %edi,%edi
80101649:	75 a5                	jne    801015f0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010164b:	8b 00                	mov    (%eax),%eax
8010164d:	e8 be fc ff ff       	call   80101310 <balloc>
80101652:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101656:	89 c7                	mov    %eax,%edi
}
80101658:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010165b:	5b                   	pop    %ebx
8010165c:	89 f8                	mov    %edi,%eax
8010165e:	5e                   	pop    %esi
8010165f:	5f                   	pop    %edi
80101660:	5d                   	pop    %ebp
80101661:	c3                   	ret
  panic("bmap: out of range");
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	68 07 83 10 80       	push   $0x80108307
8010166a:	e8 41 ee ff ff       	call   801004b0 <panic>
8010166f:	90                   	nop

80101670 <readsb>:
{
80101670:	55                   	push   %ebp
80101671:	89 e5                	mov    %esp,%ebp
80101673:	56                   	push   %esi
80101674:	53                   	push   %ebx
80101675:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101678:	83 ec 08             	sub    $0x8,%esp
8010167b:	6a 01                	push   $0x1
8010167d:	ff 75 08             	push   0x8(%ebp)
80101680:	e8 0b eb ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101685:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101688:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010168a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010168d:	6a 24                	push   $0x24
8010168f:	50                   	push   %eax
80101690:	56                   	push   %esi
80101691:	e8 9a 3e 00 00       	call   80105530 <memmove>
  brelse(bp);
80101696:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101699:	83 c4 10             	add    $0x10,%esp
}
8010169c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010169f:	5b                   	pop    %ebx
801016a0:	5e                   	pop    %esi
801016a1:	5d                   	pop    %ebp
  brelse(bp);
801016a2:	e9 69 eb ff ff       	jmp    80100210 <brelse>
801016a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801016ae:	66 90                	xchg   %ax,%ax

801016b0 <iinit>:
{
801016b0:	55                   	push   %ebp
801016b1:	89 e5                	mov    %esp,%ebp
801016b3:	53                   	push   %ebx
801016b4:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
801016b9:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801016bc:	68 1a 83 10 80       	push   $0x8010831a
801016c1:	68 60 09 11 80       	push   $0x80110960
801016c6:	e8 e5 3a 00 00       	call   801051b0 <initlock>
  for(i = 0; i < NINODE; i++) {
801016cb:	83 c4 10             	add    $0x10,%esp
801016ce:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
801016d0:	83 ec 08             	sub    $0x8,%esp
801016d3:	68 21 83 10 80       	push   $0x80108321
801016d8:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
801016d9:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
801016df:	e8 9c 39 00 00       	call   80105080 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801016e4:	83 c4 10             	add    $0x10,%esp
801016e7:	81 fb c0 25 11 80    	cmp    $0x801125c0,%ebx
801016ed:	75 e1                	jne    801016d0 <iinit+0x20>
  bp = bread(dev, 1);
801016ef:	83 ec 08             	sub    $0x8,%esp
801016f2:	6a 01                	push   $0x1
801016f4:	ff 75 08             	push   0x8(%ebp)
801016f7:	e8 94 ea ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801016fc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801016ff:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101701:	8d 40 5c             	lea    0x5c(%eax),%eax
80101704:	6a 24                	push   $0x24
80101706:	50                   	push   %eax
80101707:	68 c0 25 11 80       	push   $0x801125c0
8010170c:	e8 1f 3e 00 00       	call   80105530 <memmove>
  brelse(bp);
80101711:	89 1c 24             	mov    %ebx,(%esp)
80101714:	e8 f7 ea ff ff       	call   80100210 <brelse>
  initswap();
80101719:	e8 f2 30 00 00       	call   80104810 <initswap>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010171e:	ff 35 d8 25 11 80    	push   0x801125d8
80101724:	ff 35 d4 25 11 80    	push   0x801125d4
8010172a:	ff 35 d0 25 11 80    	push   0x801125d0
80101730:	ff 35 cc 25 11 80    	push   0x801125cc
80101736:	ff 35 c8 25 11 80    	push   0x801125c8
8010173c:	ff 35 c4 25 11 80    	push   0x801125c4
80101742:	ff 35 c0 25 11 80    	push   0x801125c0
80101748:	68 fc 87 10 80       	push   $0x801087fc
8010174d:	e8 8e f0 ff ff       	call   801007e0 <cprintf>
}
80101752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101755:	83 c4 30             	add    $0x30,%esp
80101758:	c9                   	leave
80101759:	c3                   	ret
8010175a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101760 <ialloc>:
{
80101760:	55                   	push   %ebp
80101761:	89 e5                	mov    %esp,%ebp
80101763:	57                   	push   %edi
80101764:	56                   	push   %esi
80101765:	53                   	push   %ebx
80101766:	83 ec 1c             	sub    $0x1c,%esp
80101769:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 3d c8 25 11 80 01 	cmpl   $0x1,0x801125c8
{
80101773:	8b 75 08             	mov    0x8(%ebp),%esi
80101776:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101779:	0f 86 91 00 00 00    	jbe    80101810 <ialloc+0xb0>
8010177f:	bf 01 00 00 00       	mov    $0x1,%edi
80101784:	eb 21                	jmp    801017a7 <ialloc+0x47>
80101786:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010178d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101790:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101793:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101796:	53                   	push   %ebx
80101797:	e8 74 ea ff ff       	call   80100210 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010179c:	83 c4 10             	add    $0x10,%esp
8010179f:	3b 3d c8 25 11 80    	cmp    0x801125c8,%edi
801017a5:	73 69                	jae    80101810 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
801017a7:	89 f8                	mov    %edi,%eax
801017a9:	83 ec 08             	sub    $0x8,%esp
801017ac:	c1 e8 03             	shr    $0x3,%eax
801017af:	03 05 d4 25 11 80    	add    0x801125d4,%eax
801017b5:	50                   	push   %eax
801017b6:	56                   	push   %esi
801017b7:	e8 d4 e9 ff ff       	call   80100190 <bread>
    if(dip->type == 0){  // a free inode
801017bc:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
801017bf:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
801017c1:	89 f8                	mov    %edi,%eax
801017c3:	83 e0 07             	and    $0x7,%eax
801017c6:	c1 e0 06             	shl    $0x6,%eax
801017c9:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
801017cd:	66 83 39 00          	cmpw   $0x0,(%ecx)
801017d1:	75 bd                	jne    80101790 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801017d3:	83 ec 04             	sub    $0x4,%esp
801017d6:	6a 40                	push   $0x40
801017d8:	6a 00                	push   $0x0
801017da:	51                   	push   %ecx
801017db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801017de:	e8 bd 3c 00 00       	call   801054a0 <memset>
      dip->type = type;
801017e3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801017e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801017ea:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801017ed:	89 1c 24             	mov    %ebx,(%esp)
801017f0:	e8 0b 19 00 00       	call   80103100 <log_write>
      brelse(bp);
801017f5:	89 1c 24             	mov    %ebx,(%esp)
801017f8:	e8 13 ea ff ff       	call   80100210 <brelse>
      return iget(dev, inum);
801017fd:	83 c4 10             	add    $0x10,%esp
}
80101800:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101803:	89 fa                	mov    %edi,%edx
}
80101805:	5b                   	pop    %ebx
      return iget(dev, inum);
80101806:	89 f0                	mov    %esi,%eax
}
80101808:	5e                   	pop    %esi
80101809:	5f                   	pop    %edi
8010180a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010180b:	e9 10 fc ff ff       	jmp    80101420 <iget>
  panic("ialloc: no inodes");
80101810:	83 ec 0c             	sub    $0xc,%esp
80101813:	68 27 83 10 80       	push   $0x80108327
80101818:	e8 93 ec ff ff       	call   801004b0 <panic>
8010181d:	8d 76 00             	lea    0x0(%esi),%esi

80101820 <iupdate>:
{
80101820:	55                   	push   %ebp
80101821:	89 e5                	mov    %esp,%ebp
80101823:	56                   	push   %esi
80101824:	53                   	push   %ebx
80101825:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101828:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010182b:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010182e:	83 ec 08             	sub    $0x8,%esp
80101831:	c1 e8 03             	shr    $0x3,%eax
80101834:	03 05 d4 25 11 80    	add    0x801125d4,%eax
8010183a:	50                   	push   %eax
8010183b:	ff 73 a4             	push   -0x5c(%ebx)
8010183e:	e8 4d e9 ff ff       	call   80100190 <bread>
  dip->type = ip->type;
80101843:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101847:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010184a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010184c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010184f:	83 e0 07             	and    $0x7,%eax
80101852:	c1 e0 06             	shl    $0x6,%eax
80101855:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101859:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101860:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101863:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101867:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010186b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010186f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101873:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101877:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010187a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010187d:	6a 34                	push   $0x34
8010187f:	53                   	push   %ebx
80101880:	50                   	push   %eax
80101881:	e8 aa 3c 00 00       	call   80105530 <memmove>
  log_write(bp);
80101886:	89 34 24             	mov    %esi,(%esp)
80101889:	e8 72 18 00 00       	call   80103100 <log_write>
  brelse(bp);
8010188e:	89 75 08             	mov    %esi,0x8(%ebp)
80101891:	83 c4 10             	add    $0x10,%esp
}
80101894:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101897:	5b                   	pop    %ebx
80101898:	5e                   	pop    %esi
80101899:	5d                   	pop    %ebp
  brelse(bp);
8010189a:	e9 71 e9 ff ff       	jmp    80100210 <brelse>
8010189f:	90                   	nop

801018a0 <idup>:
{
801018a0:	55                   	push   %ebp
801018a1:	89 e5                	mov    %esp,%ebp
801018a3:	53                   	push   %ebx
801018a4:	83 ec 10             	sub    $0x10,%esp
801018a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801018aa:	68 60 09 11 80       	push   $0x80110960
801018af:	e8 ec 3a 00 00       	call   801053a0 <acquire>
  ip->ref++;
801018b4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801018b8:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801018bf:	e8 7c 3a 00 00       	call   80105340 <release>
}
801018c4:	89 d8                	mov    %ebx,%eax
801018c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801018c9:	c9                   	leave
801018ca:	c3                   	ret
801018cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801018cf:	90                   	nop

801018d0 <ilock>:
{
801018d0:	55                   	push   %ebp
801018d1:	89 e5                	mov    %esp,%ebp
801018d3:	56                   	push   %esi
801018d4:	53                   	push   %ebx
801018d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801018d8:	85 db                	test   %ebx,%ebx
801018da:	0f 84 b7 00 00 00    	je     80101997 <ilock+0xc7>
801018e0:	8b 53 08             	mov    0x8(%ebx),%edx
801018e3:	85 d2                	test   %edx,%edx
801018e5:	0f 8e ac 00 00 00    	jle    80101997 <ilock+0xc7>
  acquiresleep(&ip->lock);
801018eb:	83 ec 0c             	sub    $0xc,%esp
801018ee:	8d 43 0c             	lea    0xc(%ebx),%eax
801018f1:	50                   	push   %eax
801018f2:	e8 c9 37 00 00       	call   801050c0 <acquiresleep>
  if(ip->valid == 0){
801018f7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801018fa:	83 c4 10             	add    $0x10,%esp
801018fd:	85 c0                	test   %eax,%eax
801018ff:	74 0f                	je     80101910 <ilock+0x40>
}
80101901:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101904:	5b                   	pop    %ebx
80101905:	5e                   	pop    %esi
80101906:	5d                   	pop    %ebp
80101907:	c3                   	ret
80101908:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010190f:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101910:	8b 43 04             	mov    0x4(%ebx),%eax
80101913:	83 ec 08             	sub    $0x8,%esp
80101916:	c1 e8 03             	shr    $0x3,%eax
80101919:	03 05 d4 25 11 80    	add    0x801125d4,%eax
8010191f:	50                   	push   %eax
80101920:	ff 33                	push   (%ebx)
80101922:	e8 69 e8 ff ff       	call   80100190 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101927:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010192a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010192c:	8b 43 04             	mov    0x4(%ebx),%eax
8010192f:	83 e0 07             	and    $0x7,%eax
80101932:	c1 e0 06             	shl    $0x6,%eax
80101935:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101939:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010193c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
8010193f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101943:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101947:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010194b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010194f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101953:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101957:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010195b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010195e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101961:	6a 34                	push   $0x34
80101963:	50                   	push   %eax
80101964:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101967:	50                   	push   %eax
80101968:	e8 c3 3b 00 00       	call   80105530 <memmove>
    brelse(bp);
8010196d:	89 34 24             	mov    %esi,(%esp)
80101970:	e8 9b e8 ff ff       	call   80100210 <brelse>
    if(ip->type == 0)
80101975:	83 c4 10             	add    $0x10,%esp
80101978:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010197d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101984:	0f 85 77 ff ff ff    	jne    80101901 <ilock+0x31>
      panic("ilock: no type");
8010198a:	83 ec 0c             	sub    $0xc,%esp
8010198d:	68 3f 83 10 80       	push   $0x8010833f
80101992:	e8 19 eb ff ff       	call   801004b0 <panic>
    panic("ilock");
80101997:	83 ec 0c             	sub    $0xc,%esp
8010199a:	68 39 83 10 80       	push   $0x80108339
8010199f:	e8 0c eb ff ff       	call   801004b0 <panic>
801019a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801019af:	90                   	nop

801019b0 <iunlock>:
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	56                   	push   %esi
801019b4:	53                   	push   %ebx
801019b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801019b8:	85 db                	test   %ebx,%ebx
801019ba:	74 28                	je     801019e4 <iunlock+0x34>
801019bc:	83 ec 0c             	sub    $0xc,%esp
801019bf:	8d 73 0c             	lea    0xc(%ebx),%esi
801019c2:	56                   	push   %esi
801019c3:	e8 98 37 00 00       	call   80105160 <holdingsleep>
801019c8:	83 c4 10             	add    $0x10,%esp
801019cb:	85 c0                	test   %eax,%eax
801019cd:	74 15                	je     801019e4 <iunlock+0x34>
801019cf:	8b 43 08             	mov    0x8(%ebx),%eax
801019d2:	85 c0                	test   %eax,%eax
801019d4:	7e 0e                	jle    801019e4 <iunlock+0x34>
  releasesleep(&ip->lock);
801019d6:	89 75 08             	mov    %esi,0x8(%ebp)
}
801019d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801019dc:	5b                   	pop    %ebx
801019dd:	5e                   	pop    %esi
801019de:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
801019df:	e9 3c 37 00 00       	jmp    80105120 <releasesleep>
    panic("iunlock");
801019e4:	83 ec 0c             	sub    $0xc,%esp
801019e7:	68 4e 83 10 80       	push   $0x8010834e
801019ec:	e8 bf ea ff ff       	call   801004b0 <panic>
801019f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019ff:	90                   	nop

80101a00 <iput>:
{
80101a00:	55                   	push   %ebp
80101a01:	89 e5                	mov    %esp,%ebp
80101a03:	57                   	push   %edi
80101a04:	56                   	push   %esi
80101a05:	53                   	push   %ebx
80101a06:	83 ec 28             	sub    $0x28,%esp
80101a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101a0c:	8d 7b 0c             	lea    0xc(%ebx),%edi
80101a0f:	57                   	push   %edi
80101a10:	e8 ab 36 00 00       	call   801050c0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101a15:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101a18:	83 c4 10             	add    $0x10,%esp
80101a1b:	85 d2                	test   %edx,%edx
80101a1d:	74 07                	je     80101a26 <iput+0x26>
80101a1f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101a24:	74 32                	je     80101a58 <iput+0x58>
  releasesleep(&ip->lock);
80101a26:	83 ec 0c             	sub    $0xc,%esp
80101a29:	57                   	push   %edi
80101a2a:	e8 f1 36 00 00       	call   80105120 <releasesleep>
  acquire(&icache.lock);
80101a2f:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101a36:	e8 65 39 00 00       	call   801053a0 <acquire>
  ip->ref--;
80101a3b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101a3f:	83 c4 10             	add    $0x10,%esp
80101a42:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
80101a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a4c:	5b                   	pop    %ebx
80101a4d:	5e                   	pop    %esi
80101a4e:	5f                   	pop    %edi
80101a4f:	5d                   	pop    %ebp
  release(&icache.lock);
80101a50:	e9 eb 38 00 00       	jmp    80105340 <release>
80101a55:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101a58:	83 ec 0c             	sub    $0xc,%esp
80101a5b:	68 60 09 11 80       	push   $0x80110960
80101a60:	e8 3b 39 00 00       	call   801053a0 <acquire>
    int r = ip->ref;
80101a65:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101a68:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101a6f:	e8 cc 38 00 00       	call   80105340 <release>
    if(r == 1){
80101a74:	83 c4 10             	add    $0x10,%esp
80101a77:	83 fe 01             	cmp    $0x1,%esi
80101a7a:	75 aa                	jne    80101a26 <iput+0x26>
80101a7c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101a82:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101a85:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101a88:	89 df                	mov    %ebx,%edi
80101a8a:	89 cb                	mov    %ecx,%ebx
80101a8c:	eb 09                	jmp    80101a97 <iput+0x97>
80101a8e:	66 90                	xchg   %ax,%ax
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101a90:	83 c6 04             	add    $0x4,%esi
80101a93:	39 de                	cmp    %ebx,%esi
80101a95:	74 19                	je     80101ab0 <iput+0xb0>
    if(ip->addrs[i]){
80101a97:	8b 16                	mov    (%esi),%edx
80101a99:	85 d2                	test   %edx,%edx
80101a9b:	74 f3                	je     80101a90 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101a9d:	8b 07                	mov    (%edi),%eax
80101a9f:	e8 7c fa ff ff       	call   80101520 <bfree>
      ip->addrs[i] = 0;
80101aa4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101aaa:	eb e4                	jmp    80101a90 <iput+0x90>
80101aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101ab0:	89 fb                	mov    %edi,%ebx
80101ab2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101ab5:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	75 2d                	jne    80101aec <iput+0xec>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101abf:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101ac2:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101ac9:	53                   	push   %ebx
80101aca:	e8 51 fd ff ff       	call   80101820 <iupdate>
      ip->type = 0;
80101acf:	31 c0                	xor    %eax,%eax
80101ad1:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101ad5:	89 1c 24             	mov    %ebx,(%esp)
80101ad8:	e8 43 fd ff ff       	call   80101820 <iupdate>
      ip->valid = 0;
80101add:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	e9 3a ff ff ff       	jmp    80101a26 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101aec:	83 ec 08             	sub    $0x8,%esp
80101aef:	50                   	push   %eax
80101af0:	ff 33                	push   (%ebx)
80101af2:	e8 99 e6 ff ff       	call   80100190 <bread>
    for(j = 0; j < NINDIRECT; j++){
80101af7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101afa:	83 c4 10             	add    $0x10,%esp
80101afd:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101b03:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101b06:	8d 70 5c             	lea    0x5c(%eax),%esi
80101b09:	89 cf                	mov    %ecx,%edi
80101b0b:	eb 0a                	jmp    80101b17 <iput+0x117>
80101b0d:	8d 76 00             	lea    0x0(%esi),%esi
80101b10:	83 c6 04             	add    $0x4,%esi
80101b13:	39 fe                	cmp    %edi,%esi
80101b15:	74 0f                	je     80101b26 <iput+0x126>
      if(a[j])
80101b17:	8b 16                	mov    (%esi),%edx
80101b19:	85 d2                	test   %edx,%edx
80101b1b:	74 f3                	je     80101b10 <iput+0x110>
        bfree(ip->dev, a[j]);
80101b1d:	8b 03                	mov    (%ebx),%eax
80101b1f:	e8 fc f9 ff ff       	call   80101520 <bfree>
80101b24:	eb ea                	jmp    80101b10 <iput+0x110>
    brelse(bp);
80101b26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101b2f:	50                   	push   %eax
80101b30:	e8 db e6 ff ff       	call   80100210 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101b35:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101b3b:	8b 03                	mov    (%ebx),%eax
80101b3d:	e8 de f9 ff ff       	call   80101520 <bfree>
    ip->addrs[NDIRECT] = 0;
80101b42:	83 c4 10             	add    $0x10,%esp
80101b45:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101b4c:	00 00 00 
80101b4f:	e9 6b ff ff ff       	jmp    80101abf <iput+0xbf>
80101b54:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101b5f:	90                   	nop

80101b60 <iunlockput>:
{
80101b60:	55                   	push   %ebp
80101b61:	89 e5                	mov    %esp,%ebp
80101b63:	56                   	push   %esi
80101b64:	53                   	push   %ebx
80101b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b68:	85 db                	test   %ebx,%ebx
80101b6a:	74 34                	je     80101ba0 <iunlockput+0x40>
80101b6c:	83 ec 0c             	sub    $0xc,%esp
80101b6f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101b72:	56                   	push   %esi
80101b73:	e8 e8 35 00 00       	call   80105160 <holdingsleep>
80101b78:	83 c4 10             	add    $0x10,%esp
80101b7b:	85 c0                	test   %eax,%eax
80101b7d:	74 21                	je     80101ba0 <iunlockput+0x40>
80101b7f:	8b 43 08             	mov    0x8(%ebx),%eax
80101b82:	85 c0                	test   %eax,%eax
80101b84:	7e 1a                	jle    80101ba0 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101b86:	83 ec 0c             	sub    $0xc,%esp
80101b89:	56                   	push   %esi
80101b8a:	e8 91 35 00 00       	call   80105120 <releasesleep>
  iput(ip);
80101b8f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101b92:	83 c4 10             	add    $0x10,%esp
}
80101b95:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101b98:	5b                   	pop    %ebx
80101b99:	5e                   	pop    %esi
80101b9a:	5d                   	pop    %ebp
  iput(ip);
80101b9b:	e9 60 fe ff ff       	jmp    80101a00 <iput>
    panic("iunlock");
80101ba0:	83 ec 0c             	sub    $0xc,%esp
80101ba3:	68 4e 83 10 80       	push   $0x8010834e
80101ba8:	e8 03 e9 ff ff       	call   801004b0 <panic>
80101bad:	8d 76 00             	lea    0x0(%esi),%esi

80101bb0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101bb0:	55                   	push   %ebp
80101bb1:	89 e5                	mov    %esp,%ebp
80101bb3:	8b 55 08             	mov    0x8(%ebp),%edx
80101bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101bb9:	8b 0a                	mov    (%edx),%ecx
80101bbb:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101bbe:	8b 4a 04             	mov    0x4(%edx),%ecx
80101bc1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101bc4:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101bc8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101bcb:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101bcf:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101bd3:	8b 52 58             	mov    0x58(%edx),%edx
80101bd6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101bd9:	5d                   	pop    %ebp
80101bda:	c3                   	ret
80101bdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101bdf:	90                   	nop

80101be0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101be0:	55                   	push   %ebp
80101be1:	89 e5                	mov    %esp,%ebp
80101be3:	57                   	push   %edi
80101be4:	56                   	push   %esi
80101be5:	53                   	push   %ebx
80101be6:	83 ec 1c             	sub    $0x1c,%esp
80101be9:	8b 75 08             	mov    0x8(%ebp),%esi
80101bec:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bef:	8b 7d 10             	mov    0x10(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bf2:	66 83 7e 50 03       	cmpw   $0x3,0x50(%esi)
{
80101bf7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101bfa:	89 75 d8             	mov    %esi,-0x28(%ebp)
80101bfd:	8b 45 14             	mov    0x14(%ebp),%eax
  if(ip->type == T_DEV){
80101c00:	0f 84 aa 00 00 00    	je     80101cb0 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101c06:	8b 75 d8             	mov    -0x28(%ebp),%esi
80101c09:	8b 56 58             	mov    0x58(%esi),%edx
80101c0c:	39 fa                	cmp    %edi,%edx
80101c0e:	0f 82 bd 00 00 00    	jb     80101cd1 <readi+0xf1>
80101c14:	89 f9                	mov    %edi,%ecx
80101c16:	31 db                	xor    %ebx,%ebx
80101c18:	01 c1                	add    %eax,%ecx
80101c1a:	0f 92 c3             	setb   %bl
80101c1d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101c20:	0f 82 ab 00 00 00    	jb     80101cd1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101c26:	89 d3                	mov    %edx,%ebx
80101c28:	29 fb                	sub    %edi,%ebx
80101c2a:	39 ca                	cmp    %ecx,%edx
80101c2c:	0f 42 c3             	cmovb  %ebx,%eax

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c2f:	85 c0                	test   %eax,%eax
80101c31:	74 73                	je     80101ca6 <readi+0xc6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101c33:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101c36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c40:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101c43:	89 fa                	mov    %edi,%edx
80101c45:	c1 ea 09             	shr    $0x9,%edx
80101c48:	89 d8                	mov    %ebx,%eax
80101c4a:	e8 51 f9 ff ff       	call   801015a0 <bmap>
80101c4f:	83 ec 08             	sub    $0x8,%esp
80101c52:	50                   	push   %eax
80101c53:	ff 33                	push   (%ebx)
80101c55:	e8 36 e5 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c5a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101c5d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c62:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101c64:	89 f8                	mov    %edi,%eax
80101c66:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c6b:	29 f3                	sub    %esi,%ebx
80101c6d:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101c6f:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c73:	39 d9                	cmp    %ebx,%ecx
80101c75:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c78:	83 c4 0c             	add    $0xc,%esp
80101c7b:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c7c:	01 de                	add    %ebx,%esi
80101c7e:	01 df                	add    %ebx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
80101c80:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101c83:	50                   	push   %eax
80101c84:	ff 75 e0             	push   -0x20(%ebp)
80101c87:	e8 a4 38 00 00       	call   80105530 <memmove>
    brelse(bp);
80101c8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101c8f:	89 14 24             	mov    %edx,(%esp)
80101c92:	e8 79 e5 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c97:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101c9a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101c9d:	83 c4 10             	add    $0x10,%esp
80101ca0:	39 de                	cmp    %ebx,%esi
80101ca2:	72 9c                	jb     80101c40 <readi+0x60>
80101ca4:	89 d8                	mov    %ebx,%eax
  }
  return n;
}
80101ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ca9:	5b                   	pop    %ebx
80101caa:	5e                   	pop    %esi
80101cab:	5f                   	pop    %edi
80101cac:	5d                   	pop    %ebp
80101cad:	c3                   	ret
80101cae:	66 90                	xchg   %ax,%ax
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101cb0:	0f bf 56 52          	movswl 0x52(%esi),%edx
80101cb4:	66 83 fa 09          	cmp    $0x9,%dx
80101cb8:	77 17                	ja     80101cd1 <readi+0xf1>
80101cba:	8b 14 d5 00 09 11 80 	mov    -0x7feef700(,%edx,8),%edx
80101cc1:	85 d2                	test   %edx,%edx
80101cc3:	74 0c                	je     80101cd1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101cc5:	89 45 10             	mov    %eax,0x10(%ebp)
}
80101cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ccb:	5b                   	pop    %ebx
80101ccc:	5e                   	pop    %esi
80101ccd:	5f                   	pop    %edi
80101cce:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101ccf:	ff e2                	jmp    *%edx
      return -1;
80101cd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cd6:	eb ce                	jmp    80101ca6 <readi+0xc6>
80101cd8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cdf:	90                   	nop

80101ce0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ce0:	55                   	push   %ebp
80101ce1:	89 e5                	mov    %esp,%ebp
80101ce3:	57                   	push   %edi
80101ce4:	56                   	push   %esi
80101ce5:	53                   	push   %ebx
80101ce6:	83 ec 1c             	sub    $0x1c,%esp
80101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cec:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101cef:	8b 75 14             	mov    0x14(%ebp),%esi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101cf2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101cf7:	89 7d dc             	mov    %edi,-0x24(%ebp)
80101cfa:	89 75 e0             	mov    %esi,-0x20(%ebp)
80101cfd:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
80101d00:	0f 84 ba 00 00 00    	je     80101dc0 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101d06:	39 78 58             	cmp    %edi,0x58(%eax)
80101d09:	0f 82 ea 00 00 00    	jb     80101df9 <writei+0x119>
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101d0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101d12:	89 f2                	mov    %esi,%edx
80101d14:	01 fa                	add    %edi,%edx
80101d16:	0f 82 dd 00 00 00    	jb     80101df9 <writei+0x119>
80101d1c:	81 fa 00 18 01 00    	cmp    $0x11800,%edx
80101d22:	0f 87 d1 00 00 00    	ja     80101df9 <writei+0x119>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d28:	85 f6                	test   %esi,%esi
80101d2a:	0f 84 85 00 00 00    	je     80101db5 <writei+0xd5>
80101d30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101d37:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d40:	8b 75 d8             	mov    -0x28(%ebp),%esi
80101d43:	89 fa                	mov    %edi,%edx
80101d45:	c1 ea 09             	shr    $0x9,%edx
80101d48:	89 f0                	mov    %esi,%eax
80101d4a:	e8 51 f8 ff ff       	call   801015a0 <bmap>
80101d4f:	83 ec 08             	sub    $0x8,%esp
80101d52:	50                   	push   %eax
80101d53:	ff 36                	push   (%esi)
80101d55:	e8 36 e4 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101d5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101d5d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101d60:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d65:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
80101d67:	89 f8                	mov    %edi,%eax
80101d69:	25 ff 01 00 00       	and    $0x1ff,%eax
80101d6e:	29 d3                	sub    %edx,%ebx
80101d70:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101d72:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101d76:	39 d9                	cmp    %ebx,%ecx
80101d78:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101d7b:	83 c4 0c             	add    $0xc,%esp
80101d7e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d7f:	01 df                	add    %ebx,%edi
    memmove(bp->data + off%BSIZE, src, m);
80101d81:	ff 75 dc             	push   -0x24(%ebp)
80101d84:	50                   	push   %eax
80101d85:	e8 a6 37 00 00       	call   80105530 <memmove>
    log_write(bp);
80101d8a:	89 34 24             	mov    %esi,(%esp)
80101d8d:	e8 6e 13 00 00       	call   80103100 <log_write>
    brelse(bp);
80101d92:	89 34 24             	mov    %esi,(%esp)
80101d95:	e8 76 e4 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d9a:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101da0:	83 c4 10             	add    $0x10,%esp
80101da3:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101da6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101da9:	39 d8                	cmp    %ebx,%eax
80101dab:	72 93                	jb     80101d40 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101dad:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101db0:	39 78 58             	cmp    %edi,0x58(%eax)
80101db3:	72 33                	jb     80101de8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dbb:	5b                   	pop    %ebx
80101dbc:	5e                   	pop    %esi
80101dbd:	5f                   	pop    %edi
80101dbe:	5d                   	pop    %ebp
80101dbf:	c3                   	ret
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101dc0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101dc4:	66 83 f8 09          	cmp    $0x9,%ax
80101dc8:	77 2f                	ja     80101df9 <writei+0x119>
80101dca:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101dd1:	85 c0                	test   %eax,%eax
80101dd3:	74 24                	je     80101df9 <writei+0x119>
    return devsw[ip->major].write(ip, src, n);
80101dd5:	89 75 10             	mov    %esi,0x10(%ebp)
}
80101dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ddb:	5b                   	pop    %ebx
80101ddc:	5e                   	pop    %esi
80101ddd:	5f                   	pop    %edi
80101dde:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101ddf:	ff e0                	jmp    *%eax
80101de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    iupdate(ip);
80101de8:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101deb:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
80101dee:	50                   	push   %eax
80101def:	e8 2c fa ff ff       	call   80101820 <iupdate>
80101df4:	83 c4 10             	add    $0x10,%esp
80101df7:	eb bc                	jmp    80101db5 <writei+0xd5>
      return -1;
80101df9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dfe:	eb b8                	jmp    80101db8 <writei+0xd8>

80101e00 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101e00:	55                   	push   %ebp
80101e01:	89 e5                	mov    %esp,%ebp
80101e03:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101e06:	6a 0e                	push   $0xe
80101e08:	ff 75 0c             	push   0xc(%ebp)
80101e0b:	ff 75 08             	push   0x8(%ebp)
80101e0e:	e8 8d 37 00 00       	call   801055a0 <strncmp>
}
80101e13:	c9                   	leave
80101e14:	c3                   	ret
80101e15:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101e20 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101e20:	55                   	push   %ebp
80101e21:	89 e5                	mov    %esp,%ebp
80101e23:	57                   	push   %edi
80101e24:	56                   	push   %esi
80101e25:	53                   	push   %ebx
80101e26:	83 ec 1c             	sub    $0x1c,%esp
80101e29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101e2c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101e31:	0f 85 85 00 00 00    	jne    80101ebc <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101e37:	8b 53 58             	mov    0x58(%ebx),%edx
80101e3a:	31 ff                	xor    %edi,%edi
80101e3c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e3f:	85 d2                	test   %edx,%edx
80101e41:	74 3e                	je     80101e81 <dirlookup+0x61>
80101e43:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e47:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e48:	6a 10                	push   $0x10
80101e4a:	57                   	push   %edi
80101e4b:	56                   	push   %esi
80101e4c:	53                   	push   %ebx
80101e4d:	e8 8e fd ff ff       	call   80101be0 <readi>
80101e52:	83 c4 10             	add    $0x10,%esp
80101e55:	83 f8 10             	cmp    $0x10,%eax
80101e58:	75 55                	jne    80101eaf <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101e5a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e5f:	74 18                	je     80101e79 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101e61:	83 ec 04             	sub    $0x4,%esp
80101e64:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e67:	6a 0e                	push   $0xe
80101e69:	50                   	push   %eax
80101e6a:	ff 75 0c             	push   0xc(%ebp)
80101e6d:	e8 2e 37 00 00       	call   801055a0 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101e72:	83 c4 10             	add    $0x10,%esp
80101e75:	85 c0                	test   %eax,%eax
80101e77:	74 17                	je     80101e90 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e79:	83 c7 10             	add    $0x10,%edi
80101e7c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101e7f:	72 c7                	jb     80101e48 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101e84:	31 c0                	xor    %eax,%eax
}
80101e86:	5b                   	pop    %ebx
80101e87:	5e                   	pop    %esi
80101e88:	5f                   	pop    %edi
80101e89:	5d                   	pop    %ebp
80101e8a:	c3                   	ret
80101e8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e8f:	90                   	nop
      if(poff)
80101e90:	8b 45 10             	mov    0x10(%ebp),%eax
80101e93:	85 c0                	test   %eax,%eax
80101e95:	74 05                	je     80101e9c <dirlookup+0x7c>
        *poff = off;
80101e97:	8b 45 10             	mov    0x10(%ebp),%eax
80101e9a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101e9c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101ea0:	8b 03                	mov    (%ebx),%eax
80101ea2:	e8 79 f5 ff ff       	call   80101420 <iget>
}
80101ea7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101eaa:	5b                   	pop    %ebx
80101eab:	5e                   	pop    %esi
80101eac:	5f                   	pop    %edi
80101ead:	5d                   	pop    %ebp
80101eae:	c3                   	ret
      panic("dirlookup read");
80101eaf:	83 ec 0c             	sub    $0xc,%esp
80101eb2:	68 68 83 10 80       	push   $0x80108368
80101eb7:	e8 f4 e5 ff ff       	call   801004b0 <panic>
    panic("dirlookup not DIR");
80101ebc:	83 ec 0c             	sub    $0xc,%esp
80101ebf:	68 56 83 10 80       	push   $0x80108356
80101ec4:	e8 e7 e5 ff ff       	call   801004b0 <panic>
80101ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ed0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ed0:	55                   	push   %ebp
80101ed1:	89 e5                	mov    %esp,%ebp
80101ed3:	57                   	push   %edi
80101ed4:	56                   	push   %esi
80101ed5:	53                   	push   %ebx
80101ed6:	89 c3                	mov    %eax,%ebx
80101ed8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101edb:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101ede:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ee1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101ee4:	0f 84 9e 01 00 00    	je     80102088 <namex+0x1b8>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101eea:	e8 01 1e 00 00       	call   80103cf0 <myproc>
  acquire(&icache.lock);
80101eef:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101ef2:	8b 70 6c             	mov    0x6c(%eax),%esi
  acquire(&icache.lock);
80101ef5:	68 60 09 11 80       	push   $0x80110960
80101efa:	e8 a1 34 00 00       	call   801053a0 <acquire>
  ip->ref++;
80101eff:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101f03:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101f0a:	e8 31 34 00 00       	call   80105340 <release>
80101f0f:	83 c4 10             	add    $0x10,%esp
80101f12:	eb 07                	jmp    80101f1b <namex+0x4b>
80101f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f18:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101f1b:	0f b6 03             	movzbl (%ebx),%eax
80101f1e:	3c 2f                	cmp    $0x2f,%al
80101f20:	74 f6                	je     80101f18 <namex+0x48>
  if(*path == 0)
80101f22:	84 c0                	test   %al,%al
80101f24:	0f 84 06 01 00 00    	je     80102030 <namex+0x160>
  while(*path != '/' && *path != 0)
80101f2a:	0f b6 03             	movzbl (%ebx),%eax
80101f2d:	84 c0                	test   %al,%al
80101f2f:	0f 84 10 01 00 00    	je     80102045 <namex+0x175>
80101f35:	89 df                	mov    %ebx,%edi
80101f37:	3c 2f                	cmp    $0x2f,%al
80101f39:	0f 84 06 01 00 00    	je     80102045 <namex+0x175>
80101f3f:	90                   	nop
80101f40:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101f44:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101f47:	3c 2f                	cmp    $0x2f,%al
80101f49:	74 04                	je     80101f4f <namex+0x7f>
80101f4b:	84 c0                	test   %al,%al
80101f4d:	75 f1                	jne    80101f40 <namex+0x70>
  len = path - s;
80101f4f:	89 f8                	mov    %edi,%eax
80101f51:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101f53:	83 f8 0d             	cmp    $0xd,%eax
80101f56:	0f 8e ac 00 00 00    	jle    80102008 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101f5c:	83 ec 04             	sub    $0x4,%esp
80101f5f:	6a 0e                	push   $0xe
80101f61:	53                   	push   %ebx
80101f62:	89 fb                	mov    %edi,%ebx
80101f64:	ff 75 e4             	push   -0x1c(%ebp)
80101f67:	e8 c4 35 00 00       	call   80105530 <memmove>
80101f6c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101f6f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101f72:	75 0c                	jne    80101f80 <namex+0xb0>
80101f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f78:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101f7b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101f7e:	74 f8                	je     80101f78 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101f80:	83 ec 0c             	sub    $0xc,%esp
80101f83:	56                   	push   %esi
80101f84:	e8 47 f9 ff ff       	call   801018d0 <ilock>
    if(ip->type != T_DIR){
80101f89:	83 c4 10             	add    $0x10,%esp
80101f8c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101f91:	0f 85 b7 00 00 00    	jne    8010204e <namex+0x17e>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101f97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f9a:	85 c0                	test   %eax,%eax
80101f9c:	74 09                	je     80101fa7 <namex+0xd7>
80101f9e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101fa1:	0f 84 f7 00 00 00    	je     8010209e <namex+0x1ce>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101fa7:	83 ec 04             	sub    $0x4,%esp
80101faa:	6a 00                	push   $0x0
80101fac:	ff 75 e4             	push   -0x1c(%ebp)
80101faf:	56                   	push   %esi
80101fb0:	e8 6b fe ff ff       	call   80101e20 <dirlookup>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 c7                	mov    %eax,%edi
80101fba:	85 c0                	test   %eax,%eax
80101fbc:	0f 84 8c 00 00 00    	je     8010204e <namex+0x17e>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101fc2:	8d 4e 0c             	lea    0xc(%esi),%ecx
80101fc5:	83 ec 0c             	sub    $0xc,%esp
80101fc8:	51                   	push   %ecx
80101fc9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101fcc:	e8 8f 31 00 00       	call   80105160 <holdingsleep>
80101fd1:	83 c4 10             	add    $0x10,%esp
80101fd4:	85 c0                	test   %eax,%eax
80101fd6:	0f 84 02 01 00 00    	je     801020de <namex+0x20e>
80101fdc:	8b 56 08             	mov    0x8(%esi),%edx
80101fdf:	85 d2                	test   %edx,%edx
80101fe1:	0f 8e f7 00 00 00    	jle    801020de <namex+0x20e>
  releasesleep(&ip->lock);
80101fe7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101fea:	83 ec 0c             	sub    $0xc,%esp
80101fed:	51                   	push   %ecx
80101fee:	e8 2d 31 00 00       	call   80105120 <releasesleep>
  iput(ip);
80101ff3:	89 34 24             	mov    %esi,(%esp)
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
    ip = next;
80101ff6:	89 fe                	mov    %edi,%esi
  iput(ip);
80101ff8:	e8 03 fa ff ff       	call   80101a00 <iput>
80101ffd:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80102000:	e9 16 ff ff ff       	jmp    80101f1b <namex+0x4b>
80102005:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80102008:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010200b:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
    memmove(name, s, len);
8010200e:	83 ec 04             	sub    $0x4,%esp
80102011:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80102014:	50                   	push   %eax
80102015:	53                   	push   %ebx
    name[len] = 0;
80102016:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80102018:	ff 75 e4             	push   -0x1c(%ebp)
8010201b:	e8 10 35 00 00       	call   80105530 <memmove>
    name[len] = 0;
80102020:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80102023:	83 c4 10             	add    $0x10,%esp
80102026:	c6 01 00             	movb   $0x0,(%ecx)
80102029:	e9 41 ff ff ff       	jmp    80101f6f <namex+0x9f>
8010202e:	66 90                	xchg   %ax,%ax
  }
  if(nameiparent){
80102030:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102033:	85 c0                	test   %eax,%eax
80102035:	0f 85 93 00 00 00    	jne    801020ce <namex+0x1fe>
    iput(ip);
    return 0;
  }
  return ip;
}
8010203b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010203e:	89 f0                	mov    %esi,%eax
80102040:	5b                   	pop    %ebx
80102041:	5e                   	pop    %esi
80102042:	5f                   	pop    %edi
80102043:	5d                   	pop    %ebp
80102044:	c3                   	ret
  while(*path != '/' && *path != 0)
80102045:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80102048:	89 df                	mov    %ebx,%edi
8010204a:	31 c0                	xor    %eax,%eax
8010204c:	eb c0                	jmp    8010200e <namex+0x13e>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010204e:	83 ec 0c             	sub    $0xc,%esp
80102051:	8d 5e 0c             	lea    0xc(%esi),%ebx
80102054:	53                   	push   %ebx
80102055:	e8 06 31 00 00       	call   80105160 <holdingsleep>
8010205a:	83 c4 10             	add    $0x10,%esp
8010205d:	85 c0                	test   %eax,%eax
8010205f:	74 7d                	je     801020de <namex+0x20e>
80102061:	8b 4e 08             	mov    0x8(%esi),%ecx
80102064:	85 c9                	test   %ecx,%ecx
80102066:	7e 76                	jle    801020de <namex+0x20e>
  releasesleep(&ip->lock);
80102068:	83 ec 0c             	sub    $0xc,%esp
8010206b:	53                   	push   %ebx
8010206c:	e8 af 30 00 00       	call   80105120 <releasesleep>
  iput(ip);
80102071:	89 34 24             	mov    %esi,(%esp)
      return 0;
80102074:	31 f6                	xor    %esi,%esi
  iput(ip);
80102076:	e8 85 f9 ff ff       	call   80101a00 <iput>
      return 0;
8010207b:	83 c4 10             	add    $0x10,%esp
}
8010207e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102081:	89 f0                	mov    %esi,%eax
80102083:	5b                   	pop    %ebx
80102084:	5e                   	pop    %esi
80102085:	5f                   	pop    %edi
80102086:	5d                   	pop    %ebp
80102087:	c3                   	ret
    ip = iget(ROOTDEV, ROOTINO);
80102088:	ba 01 00 00 00       	mov    $0x1,%edx
8010208d:	b8 01 00 00 00       	mov    $0x1,%eax
80102092:	e8 89 f3 ff ff       	call   80101420 <iget>
80102097:	89 c6                	mov    %eax,%esi
80102099:	e9 7d fe ff ff       	jmp    80101f1b <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010209e:	83 ec 0c             	sub    $0xc,%esp
801020a1:	8d 5e 0c             	lea    0xc(%esi),%ebx
801020a4:	53                   	push   %ebx
801020a5:	e8 b6 30 00 00       	call   80105160 <holdingsleep>
801020aa:	83 c4 10             	add    $0x10,%esp
801020ad:	85 c0                	test   %eax,%eax
801020af:	74 2d                	je     801020de <namex+0x20e>
801020b1:	8b 7e 08             	mov    0x8(%esi),%edi
801020b4:	85 ff                	test   %edi,%edi
801020b6:	7e 26                	jle    801020de <namex+0x20e>
  releasesleep(&ip->lock);
801020b8:	83 ec 0c             	sub    $0xc,%esp
801020bb:	53                   	push   %ebx
801020bc:	e8 5f 30 00 00       	call   80105120 <releasesleep>
}
801020c1:	83 c4 10             	add    $0x10,%esp
}
801020c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020c7:	89 f0                	mov    %esi,%eax
801020c9:	5b                   	pop    %ebx
801020ca:	5e                   	pop    %esi
801020cb:	5f                   	pop    %edi
801020cc:	5d                   	pop    %ebp
801020cd:	c3                   	ret
    iput(ip);
801020ce:	83 ec 0c             	sub    $0xc,%esp
801020d1:	56                   	push   %esi
      return 0;
801020d2:	31 f6                	xor    %esi,%esi
    iput(ip);
801020d4:	e8 27 f9 ff ff       	call   80101a00 <iput>
    return 0;
801020d9:	83 c4 10             	add    $0x10,%esp
801020dc:	eb a0                	jmp    8010207e <namex+0x1ae>
    panic("iunlock");
801020de:	83 ec 0c             	sub    $0xc,%esp
801020e1:	68 4e 83 10 80       	push   $0x8010834e
801020e6:	e8 c5 e3 ff ff       	call   801004b0 <panic>
801020eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801020ef:	90                   	nop

801020f0 <dirlink>:
{
801020f0:	55                   	push   %ebp
801020f1:	89 e5                	mov    %esp,%ebp
801020f3:	57                   	push   %edi
801020f4:	56                   	push   %esi
801020f5:	53                   	push   %ebx
801020f6:	83 ec 20             	sub    $0x20,%esp
801020f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
801020fc:	6a 00                	push   $0x0
801020fe:	ff 75 0c             	push   0xc(%ebp)
80102101:	53                   	push   %ebx
80102102:	e8 19 fd ff ff       	call   80101e20 <dirlookup>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	85 c0                	test   %eax,%eax
8010210c:	75 67                	jne    80102175 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010210e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102111:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102114:	85 ff                	test   %edi,%edi
80102116:	74 29                	je     80102141 <dirlink+0x51>
80102118:	31 ff                	xor    %edi,%edi
8010211a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010211d:	eb 09                	jmp    80102128 <dirlink+0x38>
8010211f:	90                   	nop
80102120:	83 c7 10             	add    $0x10,%edi
80102123:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102126:	73 19                	jae    80102141 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102128:	6a 10                	push   $0x10
8010212a:	57                   	push   %edi
8010212b:	56                   	push   %esi
8010212c:	53                   	push   %ebx
8010212d:	e8 ae fa ff ff       	call   80101be0 <readi>
80102132:	83 c4 10             	add    $0x10,%esp
80102135:	83 f8 10             	cmp    $0x10,%eax
80102138:	75 4e                	jne    80102188 <dirlink+0x98>
    if(de.inum == 0)
8010213a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010213f:	75 df                	jne    80102120 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102141:	83 ec 04             	sub    $0x4,%esp
80102144:	8d 45 da             	lea    -0x26(%ebp),%eax
80102147:	6a 0e                	push   $0xe
80102149:	ff 75 0c             	push   0xc(%ebp)
8010214c:	50                   	push   %eax
8010214d:	e8 9e 34 00 00       	call   801055f0 <strncpy>
  de.inum = inum;
80102152:	8b 45 10             	mov    0x10(%ebp),%eax
80102155:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102159:	6a 10                	push   $0x10
8010215b:	57                   	push   %edi
8010215c:	56                   	push   %esi
8010215d:	53                   	push   %ebx
8010215e:	e8 7d fb ff ff       	call   80101ce0 <writei>
80102163:	83 c4 20             	add    $0x20,%esp
80102166:	83 f8 10             	cmp    $0x10,%eax
80102169:	75 2a                	jne    80102195 <dirlink+0xa5>
  return 0;
8010216b:	31 c0                	xor    %eax,%eax
}
8010216d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102170:	5b                   	pop    %ebx
80102171:	5e                   	pop    %esi
80102172:	5f                   	pop    %edi
80102173:	5d                   	pop    %ebp
80102174:	c3                   	ret
    iput(ip);
80102175:	83 ec 0c             	sub    $0xc,%esp
80102178:	50                   	push   %eax
80102179:	e8 82 f8 ff ff       	call   80101a00 <iput>
    return -1;
8010217e:	83 c4 10             	add    $0x10,%esp
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	eb e5                	jmp    8010216d <dirlink+0x7d>
      panic("dirlink read");
80102188:	83 ec 0c             	sub    $0xc,%esp
8010218b:	68 77 83 10 80       	push   $0x80108377
80102190:	e8 1b e3 ff ff       	call   801004b0 <panic>
    panic("dirlink");
80102195:	83 ec 0c             	sub    $0xc,%esp
80102198:	68 86 86 10 80       	push   $0x80108686
8010219d:	e8 0e e3 ff ff       	call   801004b0 <panic>
801021a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021b0 <namei>:

struct inode*
namei(char *path)
{
801021b0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801021b1:	31 d2                	xor    %edx,%edx
{
801021b3:	89 e5                	mov    %esp,%ebp
801021b5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801021b8:	8b 45 08             	mov    0x8(%ebp),%eax
801021bb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801021be:	e8 0d fd ff ff       	call   80101ed0 <namex>
}
801021c3:	c9                   	leave
801021c4:	c3                   	ret
801021c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801021d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801021d0:	55                   	push   %ebp
  return namex(path, 1, name);
801021d1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801021d6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801021d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801021db:	8b 45 08             	mov    0x8(%ebp),%eax
}
801021de:	5d                   	pop    %ebp
  return namex(path, 1, name);
801021df:	e9 ec fc ff ff       	jmp    80101ed0 <namex>
801021e4:	66 90                	xchg   %ax,%ax
801021e6:	66 90                	xchg   %ax,%ax
801021e8:	66 90                	xchg   %ax,%ax
801021ea:	66 90                	xchg   %ax,%ax
801021ec:	66 90                	xchg   %ax,%ax
801021ee:	66 90                	xchg   %ax,%ax

801021f0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801021f0:	55                   	push   %ebp
801021f1:	89 e5                	mov    %esp,%ebp
801021f3:	57                   	push   %edi
801021f4:	56                   	push   %esi
801021f5:	53                   	push   %ebx
801021f6:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
801021f9:	85 c0                	test   %eax,%eax
801021fb:	0f 84 c0 00 00 00    	je     801022c1 <idestart+0xd1>
    panic("idestart");
  if(b->blockno >= FSSIZE+SWAPBLOCKS){
80102201:	8b 70 08             	mov    0x8(%eax),%esi
80102204:	89 c3                	mov    %eax,%ebx
80102206:	81 fe b7 0b 00 00    	cmp    $0xbb7,%esi
8010220c:	0f 87 96 00 00 00    	ja     801022a8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102212:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102217:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010221e:	66 90                	xchg   %ax,%ax
80102220:	89 ca                	mov    %ecx,%edx
80102222:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102223:	83 e0 c0             	and    $0xffffffc0,%eax
80102226:	3c 40                	cmp    $0x40,%al
80102228:	75 f6                	jne    80102220 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010222a:	31 ff                	xor    %edi,%edi
8010222c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102231:	89 f8                	mov    %edi,%eax
80102233:	ee                   	out    %al,(%dx)
80102234:	b8 01 00 00 00       	mov    $0x1,%eax
80102239:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010223e:	ee                   	out    %al,(%dx)
8010223f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102244:	89 f0                	mov    %esi,%eax
80102246:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102247:	89 f0                	mov    %esi,%eax
80102249:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010224e:	c1 f8 08             	sar    $0x8,%eax
80102251:	ee                   	out    %al,(%dx)
80102252:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102257:	89 f8                	mov    %edi,%eax
80102259:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010225a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010225e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102263:	c1 e0 04             	shl    $0x4,%eax
80102266:	83 e0 10             	and    $0x10,%eax
80102269:	83 c8 e0             	or     $0xffffffe0,%eax
8010226c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010226d:	f6 03 04             	testb  $0x4,(%ebx)
80102270:	75 16                	jne    80102288 <idestart+0x98>
80102272:	b8 20 00 00 00       	mov    $0x20,%eax
80102277:	89 ca                	mov    %ecx,%edx
80102279:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010227a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010227d:	5b                   	pop    %ebx
8010227e:	5e                   	pop    %esi
8010227f:	5f                   	pop    %edi
80102280:	5d                   	pop    %ebp
80102281:	c3                   	ret
80102282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102288:	b8 30 00 00 00       	mov    $0x30,%eax
8010228d:	89 ca                	mov    %ecx,%edx
8010228f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80102290:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80102295:	8d 73 5c             	lea    0x5c(%ebx),%esi
80102298:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010229d:	fc                   	cld
8010229e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801022a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022a3:	5b                   	pop    %ebx
801022a4:	5e                   	pop    %esi
801022a5:	5f                   	pop    %edi
801022a6:	5d                   	pop    %ebp
801022a7:	c3                   	ret
    cprintf("b->blockno %d\n",b->blockno);
801022a8:	50                   	push   %eax
801022a9:	50                   	push   %eax
801022aa:	56                   	push   %esi
801022ab:	68 8d 83 10 80       	push   $0x8010838d
801022b0:	e8 2b e5 ff ff       	call   801007e0 <cprintf>
    panic("incorrect blockno");
801022b5:	c7 04 24 9c 83 10 80 	movl   $0x8010839c,(%esp)
801022bc:	e8 ef e1 ff ff       	call   801004b0 <panic>
    panic("idestart");
801022c1:	83 ec 0c             	sub    $0xc,%esp
801022c4:	68 84 83 10 80       	push   $0x80108384
801022c9:	e8 e2 e1 ff ff       	call   801004b0 <panic>
801022ce:	66 90                	xchg   %ax,%ax

801022d0 <ideinit>:
{
801022d0:	55                   	push   %ebp
801022d1:	89 e5                	mov    %esp,%ebp
801022d3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801022d6:	68 ae 83 10 80       	push   $0x801083ae
801022db:	68 20 26 11 80       	push   $0x80112620
801022e0:	e8 cb 2e 00 00       	call   801051b0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801022e5:	58                   	pop    %eax
801022e6:	a1 c4 27 11 80       	mov    0x801127c4,%eax
801022eb:	5a                   	pop    %edx
801022ec:	83 e8 01             	sub    $0x1,%eax
801022ef:	50                   	push   %eax
801022f0:	6a 0e                	push   $0xe
801022f2:	e8 99 02 00 00       	call   80102590 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801022f7:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022fa:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
801022ff:	90                   	nop
80102300:	89 ca                	mov    %ecx,%edx
80102302:	ec                   	in     (%dx),%al
80102303:	83 e0 c0             	and    $0xffffffc0,%eax
80102306:	3c 40                	cmp    $0x40,%al
80102308:	75 f6                	jne    80102300 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010230a:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010230f:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102314:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102315:	89 ca                	mov    %ecx,%edx
80102317:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102318:	84 c0                	test   %al,%al
8010231a:	75 1e                	jne    8010233a <ideinit+0x6a>
8010231c:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
80102321:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010232d:	8d 76 00             	lea    0x0(%esi),%esi
  for(i=0; i<1000; i++){
80102330:	83 e9 01             	sub    $0x1,%ecx
80102333:	74 0f                	je     80102344 <ideinit+0x74>
80102335:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102336:	84 c0                	test   %al,%al
80102338:	74 f6                	je     80102330 <ideinit+0x60>
      havedisk1 = 1;
8010233a:	c7 05 00 26 11 80 01 	movl   $0x1,0x80112600
80102341:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102344:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102349:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010234e:	ee                   	out    %al,(%dx)
}
8010234f:	c9                   	leave
80102350:	c3                   	ret
80102351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102358:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010235f:	90                   	nop

80102360 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102360:	55                   	push   %ebp
80102361:	89 e5                	mov    %esp,%ebp
80102363:	57                   	push   %edi
80102364:	56                   	push   %esi
80102365:	53                   	push   %ebx
80102366:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102369:	68 20 26 11 80       	push   $0x80112620
8010236e:	e8 2d 30 00 00       	call   801053a0 <acquire>

  if((b = idequeue) == 0){
80102373:	8b 1d 04 26 11 80    	mov    0x80112604,%ebx
80102379:	83 c4 10             	add    $0x10,%esp
8010237c:	85 db                	test   %ebx,%ebx
8010237e:	74 63                	je     801023e3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102380:	8b 43 58             	mov    0x58(%ebx),%eax
80102383:	a3 04 26 11 80       	mov    %eax,0x80112604

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102388:	8b 33                	mov    (%ebx),%esi
8010238a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102390:	75 2f                	jne    801023c1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102392:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102397:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010239e:	66 90                	xchg   %ax,%ax
801023a0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801023a1:	89 c1                	mov    %eax,%ecx
801023a3:	83 e1 c0             	and    $0xffffffc0,%ecx
801023a6:	80 f9 40             	cmp    $0x40,%cl
801023a9:	75 f5                	jne    801023a0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801023ab:	a8 21                	test   $0x21,%al
801023ad:	75 12                	jne    801023c1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801023af:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801023b2:	b9 80 00 00 00       	mov    $0x80,%ecx
801023b7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801023bc:	fc                   	cld
801023bd:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801023bf:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801023c1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801023c4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801023c7:	83 ce 02             	or     $0x2,%esi
801023ca:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801023cc:	53                   	push   %ebx
801023cd:	e8 ee 1f 00 00       	call   801043c0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801023d2:	a1 04 26 11 80       	mov    0x80112604,%eax
801023d7:	83 c4 10             	add    $0x10,%esp
801023da:	85 c0                	test   %eax,%eax
801023dc:	74 05                	je     801023e3 <ideintr+0x83>
    idestart(idequeue);
801023de:	e8 0d fe ff ff       	call   801021f0 <idestart>
    release(&idelock);
801023e3:	83 ec 0c             	sub    $0xc,%esp
801023e6:	68 20 26 11 80       	push   $0x80112620
801023eb:	e8 50 2f 00 00       	call   80105340 <release>

  release(&idelock);
}
801023f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023f3:	5b                   	pop    %ebx
801023f4:	5e                   	pop    %esi
801023f5:	5f                   	pop    %edi
801023f6:	5d                   	pop    %ebp
801023f7:	c3                   	ret
801023f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801023ff:	90                   	nop

80102400 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102400:	55                   	push   %ebp
80102401:	89 e5                	mov    %esp,%ebp
80102403:	53                   	push   %ebx
80102404:	83 ec 10             	sub    $0x10,%esp
80102407:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010240a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010240d:	50                   	push   %eax
8010240e:	e8 4d 2d 00 00       	call   80105160 <holdingsleep>
80102413:	83 c4 10             	add    $0x10,%esp
80102416:	85 c0                	test   %eax,%eax
80102418:	0f 84 c3 00 00 00    	je     801024e1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010241e:	8b 03                	mov    (%ebx),%eax
80102420:	83 e0 06             	and    $0x6,%eax
80102423:	83 f8 02             	cmp    $0x2,%eax
80102426:	0f 84 a8 00 00 00    	je     801024d4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010242c:	8b 53 04             	mov    0x4(%ebx),%edx
8010242f:	85 d2                	test   %edx,%edx
80102431:	74 0d                	je     80102440 <iderw+0x40>
80102433:	a1 00 26 11 80       	mov    0x80112600,%eax
80102438:	85 c0                	test   %eax,%eax
8010243a:	0f 84 87 00 00 00    	je     801024c7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102440:	83 ec 0c             	sub    $0xc,%esp
80102443:	68 20 26 11 80       	push   $0x80112620
80102448:	e8 53 2f 00 00       	call   801053a0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010244d:	a1 04 26 11 80       	mov    0x80112604,%eax
  b->qnext = 0;
80102452:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102459:	83 c4 10             	add    $0x10,%esp
8010245c:	85 c0                	test   %eax,%eax
8010245e:	74 60                	je     801024c0 <iderw+0xc0>
80102460:	89 c2                	mov    %eax,%edx
80102462:	8b 40 58             	mov    0x58(%eax),%eax
80102465:	85 c0                	test   %eax,%eax
80102467:	75 f7                	jne    80102460 <iderw+0x60>
80102469:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010246c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010246e:	39 1d 04 26 11 80    	cmp    %ebx,0x80112604
80102474:	74 3a                	je     801024b0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102476:	8b 03                	mov    (%ebx),%eax
80102478:	83 e0 06             	and    $0x6,%eax
8010247b:	83 f8 02             	cmp    $0x2,%eax
8010247e:	74 1b                	je     8010249b <iderw+0x9b>
    sleep(b, &idelock);
80102480:	83 ec 08             	sub    $0x8,%esp
80102483:	68 20 26 11 80       	push   $0x80112620
80102488:	53                   	push   %ebx
80102489:	e8 72 1e 00 00       	call   80104300 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010248e:	8b 03                	mov    (%ebx),%eax
80102490:	83 c4 10             	add    $0x10,%esp
80102493:	83 e0 06             	and    $0x6,%eax
80102496:	83 f8 02             	cmp    $0x2,%eax
80102499:	75 e5                	jne    80102480 <iderw+0x80>
  }


  release(&idelock);
8010249b:	c7 45 08 20 26 11 80 	movl   $0x80112620,0x8(%ebp)
}
801024a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024a5:	c9                   	leave
  release(&idelock);
801024a6:	e9 95 2e 00 00       	jmp    80105340 <release>
801024ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024af:	90                   	nop
    idestart(b);
801024b0:	89 d8                	mov    %ebx,%eax
801024b2:	e8 39 fd ff ff       	call   801021f0 <idestart>
801024b7:	eb bd                	jmp    80102476 <iderw+0x76>
801024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801024c0:	ba 04 26 11 80       	mov    $0x80112604,%edx
801024c5:	eb a5                	jmp    8010246c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801024c7:	83 ec 0c             	sub    $0xc,%esp
801024ca:	68 dd 83 10 80       	push   $0x801083dd
801024cf:	e8 dc df ff ff       	call   801004b0 <panic>
    panic("iderw: nothing to do");
801024d4:	83 ec 0c             	sub    $0xc,%esp
801024d7:	68 c8 83 10 80       	push   $0x801083c8
801024dc:	e8 cf df ff ff       	call   801004b0 <panic>
    panic("iderw: buf not locked");
801024e1:	83 ec 0c             	sub    $0xc,%esp
801024e4:	68 b2 83 10 80       	push   $0x801083b2
801024e9:	e8 c2 df ff ff       	call   801004b0 <panic>
801024ee:	66 90                	xchg   %ax,%ax

801024f0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801024f0:	55                   	push   %ebp
801024f1:	89 e5                	mov    %esp,%ebp
801024f3:	56                   	push   %esi
801024f4:	53                   	push   %ebx
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801024f5:	c7 05 54 26 11 80 00 	movl   $0xfec00000,0x80112654
801024fc:	00 c0 fe 
  ioapic->reg = reg;
801024ff:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102506:	00 00 00 
  return ioapic->data;
80102509:	8b 15 54 26 11 80    	mov    0x80112654,%edx
8010250f:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102512:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102518:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010251e:	0f b6 15 c0 27 11 80 	movzbl 0x801127c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102525:	c1 ee 10             	shr    $0x10,%esi
80102528:	89 f0                	mov    %esi,%eax
8010252a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010252d:	8b 43 10             	mov    0x10(%ebx),%eax
  id = ioapicread(REG_ID) >> 24;
80102530:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102533:	39 c2                	cmp    %eax,%edx
80102535:	74 16                	je     8010254d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102537:	83 ec 0c             	sub    $0xc,%esp
8010253a:	68 50 88 10 80       	push   $0x80108850
8010253f:	e8 9c e2 ff ff       	call   801007e0 <cprintf>
  ioapic->reg = reg;
80102544:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx
8010254a:	83 c4 10             	add    $0x10,%esp
{
8010254d:	ba 10 00 00 00       	mov    $0x10,%edx
80102552:	31 c0                	xor    %eax,%eax
80102554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapic->reg = reg;
80102558:	89 13                	mov    %edx,(%ebx)
8010255a:	8d 48 20             	lea    0x20(%eax),%ecx
  ioapic->data = data;
8010255d:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102563:	83 c0 01             	add    $0x1,%eax
80102566:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  ioapic->data = data;
8010256c:	89 4b 10             	mov    %ecx,0x10(%ebx)
  ioapic->reg = reg;
8010256f:	8d 4a 01             	lea    0x1(%edx),%ecx
  for(i = 0; i <= maxintr; i++){
80102572:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
80102575:	89 0b                	mov    %ecx,(%ebx)
  ioapic->data = data;
80102577:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx
8010257d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
  for(i = 0; i <= maxintr; i++){
80102584:	39 c6                	cmp    %eax,%esi
80102586:	7d d0                	jge    80102558 <ioapicinit+0x68>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102588:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010258b:	5b                   	pop    %ebx
8010258c:	5e                   	pop    %esi
8010258d:	5d                   	pop    %ebp
8010258e:	c3                   	ret
8010258f:	90                   	nop

80102590 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102590:	55                   	push   %ebp
  ioapic->reg = reg;
80102591:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
{
80102597:	89 e5                	mov    %esp,%ebp
80102599:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010259c:	8d 50 20             	lea    0x20(%eax),%edx
8010259f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801025a3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025a5:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025ab:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801025ae:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801025b4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025b6:	a1 54 26 11 80       	mov    0x80112654,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025bb:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801025be:	89 50 10             	mov    %edx,0x10(%eax)
}
801025c1:	5d                   	pop    %ebp
801025c2:	c3                   	ret
801025c3:	66 90                	xchg   %ax,%ax
801025c5:	66 90                	xchg   %ax,%ax
801025c7:	66 90                	xchg   %ax,%ax
801025c9:	66 90                	xchg   %ax,%ax
801025cb:	66 90                	xchg   %ax,%ax
801025cd:	66 90                	xchg   %ax,%ax
801025cf:	90                   	nop

801025d0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
801025d3:	53                   	push   %ebx
801025d4:	83 ec 04             	sub    $0x4,%esp
801025d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801025da:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801025e0:	0f 85 82 00 00 00    	jne    80102668 <kfree+0x98>
801025e6:	81 fb b0 49 1c 80    	cmp    $0x801c49b0,%ebx
801025ec:	72 7a                	jb     80102668 <kfree+0x98>
801025ee:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801025f4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
801025f9:	77 6d                	ja     80102668 <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801025fb:	83 ec 04             	sub    $0x4,%esp
801025fe:	68 00 10 00 00       	push   $0x1000
80102603:	6a 01                	push   $0x1
80102605:	53                   	push   %ebx
80102606:	e8 95 2e 00 00       	call   801054a0 <memset>

  if(kmem.use_lock)
8010260b:	8b 15 b4 26 11 80    	mov    0x801126b4,%edx
80102611:	83 c4 10             	add    $0x10,%esp
80102614:	85 d2                	test   %edx,%edx
80102616:	75 28                	jne    80102640 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102618:	a1 bc 26 11 80       	mov    0x801126bc,%eax
8010261d:	89 03                	mov    %eax,(%ebx)
  kmem.num_free_pages+=1;
  kmem.freelist = r;
  if(kmem.use_lock)
8010261f:	a1 b4 26 11 80       	mov    0x801126b4,%eax
  kmem.num_free_pages+=1;
80102624:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  kmem.freelist = r;
8010262b:	89 1d bc 26 11 80    	mov    %ebx,0x801126bc
  if(kmem.use_lock)
80102631:	85 c0                	test   %eax,%eax
80102633:	75 23                	jne    80102658 <kfree+0x88>
    release(&kmem.lock);
}
80102635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102638:	c9                   	leave
80102639:	c3                   	ret
8010263a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
80102640:	83 ec 0c             	sub    $0xc,%esp
80102643:	68 80 26 11 80       	push   $0x80112680
80102648:	e8 53 2d 00 00       	call   801053a0 <acquire>
8010264d:	83 c4 10             	add    $0x10,%esp
80102650:	eb c6                	jmp    80102618 <kfree+0x48>
80102652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102658:	c7 45 08 80 26 11 80 	movl   $0x80112680,0x8(%ebp)
}
8010265f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102662:	c9                   	leave
    release(&kmem.lock);
80102663:	e9 d8 2c 00 00       	jmp    80105340 <release>
    panic("kfree");
80102668:	83 ec 0c             	sub    $0xc,%esp
8010266b:	68 fb 83 10 80       	push   $0x801083fb
80102670:	e8 3b de ff ff       	call   801004b0 <panic>
80102675:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102680 <freerange>:
{
80102680:	55                   	push   %ebp
80102681:	89 e5                	mov    %esp,%ebp
80102683:	56                   	push   %esi
80102684:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102685:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102688:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010268b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102691:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102697:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010269d:	39 de                	cmp    %ebx,%esi
8010269f:	72 23                	jb     801026c4 <freerange+0x44>
801026a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801026b7:	50                   	push   %eax
801026b8:	e8 13 ff ff ff       	call   801025d0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026bd:	83 c4 10             	add    $0x10,%esp
801026c0:	39 de                	cmp    %ebx,%esi
801026c2:	73 e4                	jae    801026a8 <freerange+0x28>
}
801026c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026c7:	5b                   	pop    %ebx
801026c8:	5e                   	pop    %esi
801026c9:	5d                   	pop    %ebp
801026ca:	c3                   	ret
801026cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801026cf:	90                   	nop

801026d0 <kinit2>:
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	56                   	push   %esi
801026d4:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801026d5:	8b 45 08             	mov    0x8(%ebp),%eax
{
801026d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
801026db:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801026e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801026ed:	39 de                	cmp    %ebx,%esi
801026ef:	72 23                	jb     80102714 <kinit2+0x44>
801026f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102701:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102707:	50                   	push   %eax
80102708:	e8 c3 fe ff ff       	call   801025d0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010270d:	83 c4 10             	add    $0x10,%esp
80102710:	39 de                	cmp    %ebx,%esi
80102712:	73 e4                	jae    801026f8 <kinit2+0x28>
  kmem.use_lock = 1;
80102714:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
8010271b:	00 00 00 
}
8010271e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102721:	5b                   	pop    %ebx
80102722:	5e                   	pop    %esi
80102723:	5d                   	pop    %ebp
80102724:	c3                   	ret
80102725:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102730 <kinit1>:
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	56                   	push   %esi
80102734:	53                   	push   %ebx
80102735:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102738:	83 ec 08             	sub    $0x8,%esp
8010273b:	68 01 84 10 80       	push   $0x80108401
80102740:	68 80 26 11 80       	push   $0x80112680
80102745:	e8 66 2a 00 00       	call   801051b0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010274a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010274d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102750:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
80102757:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010275a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102760:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102766:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010276c:	39 de                	cmp    %ebx,%esi
8010276e:	72 1c                	jb     8010278c <kinit1+0x5c>
    kfree(p);
80102770:	83 ec 0c             	sub    $0xc,%esp
80102773:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102779:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010277f:	50                   	push   %eax
80102780:	e8 4b fe ff ff       	call   801025d0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102785:	83 c4 10             	add    $0x10,%esp
80102788:	39 de                	cmp    %ebx,%esi
8010278a:	73 e4                	jae    80102770 <kinit1+0x40>
}
8010278c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010278f:	5b                   	pop    %ebx
80102790:	5e                   	pop    %esi
80102791:	5d                   	pop    %ebp
80102792:	c3                   	ret
80102793:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801027a0 <kalloc>:
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
uint global_var = 0;
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	53                   	push   %ebx
801027a4:	83 ec 04             	sub    $0x4,%esp
801027a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027ae:	66 90                	xchg   %ax,%ax
  struct run *r;

  if(kmem.use_lock)
801027b0:	8b 0d b4 26 11 80    	mov    0x801126b4,%ecx
801027b6:	85 c9                	test   %ecx,%ecx
801027b8:	75 36                	jne    801027f0 <kalloc+0x50>
    acquire(&kmem.lock);
  r = kmem.freelist;
801027ba:	8b 1d bc 26 11 80    	mov    0x801126bc,%ebx
  // if(global_var>= 100)
    // cprintf("In kalloc %d %d\n",kmem.num_free_pages,r);
  if(r)
801027c0:	85 db                	test   %ebx,%ebx
801027c2:	0f 84 80 00 00 00    	je     80102848 <kalloc+0xa8>
  {
    kmem.freelist = r->next;
801027c8:	8b 03                	mov    (%ebx),%eax
    kmem.num_free_pages-=1;
801027ca:	83 2d b8 26 11 80 01 	subl   $0x1,0x801126b8
    kmem.freelist = r->next;
801027d1:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  }
    
  if(kmem.use_lock)
    release(&kmem.lock);
  global_var +=1;
801027d6:	a1 60 26 11 80       	mov    0x80112660,%eax
801027db:	83 c0 01             	add    $0x1,%eax
801027de:	a3 60 26 11 80       	mov    %eax,0x80112660
  if(r) return (char*)r;
  else{
    find_new_page_after_swapping();
    return kalloc();
  }
}
801027e3:	89 d8                	mov    %ebx,%eax
801027e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027e8:	c9                   	leave
801027e9:	c3                   	ret
801027ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
801027f0:	83 ec 0c             	sub    $0xc,%esp
801027f3:	68 80 26 11 80       	push   $0x80112680
801027f8:	e8 a3 2b 00 00       	call   801053a0 <acquire>
  r = kmem.freelist;
801027fd:	8b 1d bc 26 11 80    	mov    0x801126bc,%ebx
  if(r)
80102803:	83 c4 10             	add    $0x10,%esp
80102806:	85 db                	test   %ebx,%ebx
80102808:	74 56                	je     80102860 <kalloc+0xc0>
    kmem.freelist = r->next;
8010280a:	8b 03                	mov    (%ebx),%eax
    kmem.num_free_pages-=1;
8010280c:	83 2d b8 26 11 80 01 	subl   $0x1,0x801126b8
    kmem.freelist = r->next;
80102813:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(kmem.use_lock)
80102818:	a1 b4 26 11 80       	mov    0x801126b4,%eax
8010281d:	85 c0                	test   %eax,%eax
8010281f:	74 b5                	je     801027d6 <kalloc+0x36>
    release(&kmem.lock);
80102821:	83 ec 0c             	sub    $0xc,%esp
80102824:	68 80 26 11 80       	push   $0x80112680
80102829:	e8 12 2b 00 00       	call   80105340 <release>
  global_var +=1;
8010282e:	a1 60 26 11 80       	mov    0x80112660,%eax
80102833:	83 c4 10             	add    $0x10,%esp
80102836:	83 c0 01             	add    $0x1,%eax
80102839:	a3 60 26 11 80       	mov    %eax,0x80112660
}
8010283e:	89 d8                	mov    %ebx,%eax
80102840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102843:	c9                   	leave
80102844:	c3                   	ret
80102845:	8d 76 00             	lea    0x0(%esi),%esi
  global_var +=1;
80102848:	a1 60 26 11 80       	mov    0x80112660,%eax
8010284d:	83 c0 01             	add    $0x1,%eax
80102850:	a3 60 26 11 80       	mov    %eax,0x80112660
    find_new_page_after_swapping();
80102855:	e8 26 22 00 00       	call   80104a80 <find_new_page_after_swapping>
    return kalloc();
8010285a:	e9 51 ff ff ff       	jmp    801027b0 <kalloc+0x10>
8010285f:	90                   	nop
  if(kmem.use_lock)
80102860:	8b 15 b4 26 11 80    	mov    0x801126b4,%edx
80102866:	85 d2                	test   %edx,%edx
80102868:	74 de                	je     80102848 <kalloc+0xa8>
    release(&kmem.lock);
8010286a:	83 ec 0c             	sub    $0xc,%esp
8010286d:	68 80 26 11 80       	push   $0x80112680
80102872:	e8 c9 2a 00 00       	call   80105340 <release>
  global_var +=1;
80102877:	a1 60 26 11 80       	mov    0x80112660,%eax
8010287c:	83 c4 10             	add    $0x10,%esp
8010287f:	83 c0 01             	add    $0x1,%eax
  if(r) return (char*)r;
80102882:	eb cc                	jmp    80102850 <kalloc+0xb0>
80102884:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010288b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010288f:	90                   	nop

80102890 <num_of_FreePages>:
uint 
num_of_FreePages(void)
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
80102893:	53                   	push   %ebx
80102894:	83 ec 10             	sub    $0x10,%esp
  acquire(&kmem.lock);
80102897:	68 80 26 11 80       	push   $0x80112680
8010289c:	e8 ff 2a 00 00       	call   801053a0 <acquire>

  uint num_free_pages = kmem.num_free_pages;
801028a1:	8b 1d b8 26 11 80    	mov    0x801126b8,%ebx
  
  release(&kmem.lock);
801028a7:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028ae:	e8 8d 2a 00 00       	call   80105340 <release>
  
  return num_free_pages;
}
801028b3:	89 d8                	mov    %ebx,%eax
801028b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028b8:	c9                   	leave
801028b9:	c3                   	ret
801028ba:	66 90                	xchg   %ax,%ax
801028bc:	66 90                	xchg   %ax,%ax
801028be:	66 90                	xchg   %ax,%ax

801028c0 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028c0:	ba 64 00 00 00       	mov    $0x64,%edx
801028c5:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801028c6:	a8 01                	test   $0x1,%al
801028c8:	0f 84 c2 00 00 00    	je     80102990 <kbdgetc+0xd0>
{
801028ce:	55                   	push   %ebp
801028cf:	ba 60 00 00 00       	mov    $0x60,%edx
801028d4:	89 e5                	mov    %esp,%ebp
801028d6:	53                   	push   %ebx
801028d7:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801028d8:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
  data = inb(KBDATAP);
801028de:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
801028e1:	3c e0                	cmp    $0xe0,%al
801028e3:	74 5b                	je     80102940 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801028e5:	89 da                	mov    %ebx,%edx
801028e7:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
801028ea:	84 c0                	test   %al,%al
801028ec:	78 62                	js     80102950 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801028ee:	85 d2                	test   %edx,%edx
801028f0:	74 09                	je     801028fb <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028f2:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
801028f5:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
801028f8:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
801028fb:	0f b6 91 a0 8b 10 80 	movzbl -0x7fef7460(%ecx),%edx
  shift ^= togglecode[data];
80102902:	0f b6 81 a0 8a 10 80 	movzbl -0x7fef7560(%ecx),%eax
  shift |= shiftcode[data];
80102909:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
8010290b:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010290d:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
8010290f:	89 15 c0 26 11 80    	mov    %edx,0x801126c0
  c = charcode[shift & (CTL | SHIFT)][data];
80102915:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102918:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010291b:	8b 04 85 80 8a 10 80 	mov    -0x7fef7580(,%eax,4),%eax
80102922:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102926:	74 0b                	je     80102933 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102928:	8d 50 9f             	lea    -0x61(%eax),%edx
8010292b:	83 fa 19             	cmp    $0x19,%edx
8010292e:	77 48                	ja     80102978 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102930:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102936:	c9                   	leave
80102937:	c3                   	ret
80102938:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010293f:	90                   	nop
    shift |= E0ESC;
80102940:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102943:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102945:	89 1d c0 26 11 80    	mov    %ebx,0x801126c0
}
8010294b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010294e:	c9                   	leave
8010294f:	c3                   	ret
    data = (shift & E0ESC ? data : data & 0x7F);
80102950:	83 e0 7f             	and    $0x7f,%eax
80102953:	85 d2                	test   %edx,%edx
80102955:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102958:	0f b6 81 a0 8b 10 80 	movzbl -0x7fef7460(%ecx),%eax
8010295f:	83 c8 40             	or     $0x40,%eax
80102962:	0f b6 c0             	movzbl %al,%eax
80102965:	f7 d0                	not    %eax
80102967:	21 d8                	and    %ebx,%eax
80102969:	a3 c0 26 11 80       	mov    %eax,0x801126c0
    return 0;
8010296e:	31 c0                	xor    %eax,%eax
80102970:	eb d9                	jmp    8010294b <kbdgetc+0x8b>
80102972:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
80102978:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010297b:	8d 50 20             	lea    0x20(%eax),%edx
}
8010297e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102981:	c9                   	leave
      c += 'a' - 'A';
80102982:	83 f9 1a             	cmp    $0x1a,%ecx
80102985:	0f 42 c2             	cmovb  %edx,%eax
}
80102988:	c3                   	ret
80102989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80102990:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102995:	c3                   	ret
80102996:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010299d:	8d 76 00             	lea    0x0(%esi),%esi

801029a0 <kbdintr>:

void
kbdintr(void)
{
801029a0:	55                   	push   %ebp
801029a1:	89 e5                	mov    %esp,%ebp
801029a3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801029a6:	68 c0 28 10 80       	push   $0x801028c0
801029ab:	e8 20 e0 ff ff       	call   801009d0 <consoleintr>
}
801029b0:	83 c4 10             	add    $0x10,%esp
801029b3:	c9                   	leave
801029b4:	c3                   	ret
801029b5:	66 90                	xchg   %ax,%ax
801029b7:	66 90                	xchg   %ax,%ax
801029b9:	66 90                	xchg   %ax,%ax
801029bb:	66 90                	xchg   %ax,%ax
801029bd:	66 90                	xchg   %ax,%ax
801029bf:	90                   	nop

801029c0 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
801029c0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
801029c5:	85 c0                	test   %eax,%eax
801029c7:	0f 84 c3 00 00 00    	je     80102a90 <lapicinit+0xd0>
  lapic[index] = value;
801029cd:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
801029d4:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029d7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029da:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
801029e1:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029e4:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029e7:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801029ee:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801029f1:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029f4:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801029fb:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801029fe:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a01:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102a08:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a0b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a0e:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102a15:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a18:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a1b:	8b 50 30             	mov    0x30(%eax),%edx
80102a1e:	81 e2 00 00 fc 00    	and    $0xfc0000,%edx
80102a24:	75 72                	jne    80102a98 <lapicinit+0xd8>
  lapic[index] = value;
80102a26:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102a2d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a30:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a33:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102a3a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a3d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a40:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102a47:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a4a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a4d:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102a54:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a57:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a5a:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102a61:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a64:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a67:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102a6e:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102a71:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102a78:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102a7e:	80 e6 10             	and    $0x10,%dh
80102a81:	75 f5                	jne    80102a78 <lapicinit+0xb8>
  lapic[index] = value;
80102a83:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102a8a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a8d:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102a90:	c3                   	ret
80102a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102a98:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102a9f:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102aa2:	8b 50 20             	mov    0x20(%eax),%edx
}
80102aa5:	e9 7c ff ff ff       	jmp    80102a26 <lapicinit+0x66>
80102aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102ab0 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102ab0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102ab5:	85 c0                	test   %eax,%eax
80102ab7:	74 07                	je     80102ac0 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102ab9:	8b 40 20             	mov    0x20(%eax),%eax
80102abc:	c1 e8 18             	shr    $0x18,%eax
80102abf:	c3                   	ret
    return 0;
80102ac0:	31 c0                	xor    %eax,%eax
}
80102ac2:	c3                   	ret
80102ac3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102ad0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102ad0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102ad5:	85 c0                	test   %eax,%eax
80102ad7:	74 0d                	je     80102ae6 <lapiceoi+0x16>
  lapic[index] = value;
80102ad9:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102ae0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ae3:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102ae6:	c3                   	ret
80102ae7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aee:	66 90                	xchg   %ax,%ax

80102af0 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102af0:	c3                   	ret
80102af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102af8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aff:	90                   	nop

80102b00 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b00:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b01:	b8 0f 00 00 00       	mov    $0xf,%eax
80102b06:	ba 70 00 00 00       	mov    $0x70,%edx
80102b0b:	89 e5                	mov    %esp,%ebp
80102b0d:	53                   	push   %ebx
80102b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102b14:	ee                   	out    %al,(%dx)
80102b15:	b8 0a 00 00 00       	mov    $0xa,%eax
80102b1a:	ba 71 00 00 00       	mov    $0x71,%edx
80102b1f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102b20:	31 c0                	xor    %eax,%eax
  lapic[index] = value;
80102b22:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102b25:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102b2b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102b2d:	c1 e9 0c             	shr    $0xc,%ecx
  lapic[index] = value;
80102b30:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102b32:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102b35:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102b38:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102b3e:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102b43:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b49:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b4c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102b53:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b56:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b59:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102b60:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b63:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b66:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b6c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b6f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b75:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b78:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b7e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b81:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b87:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b8d:	c9                   	leave
80102b8e:	c3                   	ret
80102b8f:	90                   	nop

80102b90 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102b90:	55                   	push   %ebp
80102b91:	b8 0b 00 00 00       	mov    $0xb,%eax
80102b96:	ba 70 00 00 00       	mov    $0x70,%edx
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	57                   	push   %edi
80102b9e:	56                   	push   %esi
80102b9f:	53                   	push   %ebx
80102ba0:	83 ec 4c             	sub    $0x4c,%esp
80102ba3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ba4:	ba 71 00 00 00       	mov    $0x71,%edx
80102ba9:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102baa:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bad:	bf 70 00 00 00       	mov    $0x70,%edi
80102bb2:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102bb5:	8d 76 00             	lea    0x0(%esi),%esi
80102bb8:	31 c0                	xor    %eax,%eax
80102bba:	89 fa                	mov    %edi,%edx
80102bbc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bbd:	b9 71 00 00 00       	mov    $0x71,%ecx
80102bc2:	89 ca                	mov    %ecx,%edx
80102bc4:	ec                   	in     (%dx),%al
80102bc5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bc8:	89 fa                	mov    %edi,%edx
80102bca:	b8 02 00 00 00       	mov    $0x2,%eax
80102bcf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bd0:	89 ca                	mov    %ecx,%edx
80102bd2:	ec                   	in     (%dx),%al
80102bd3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bd6:	89 fa                	mov    %edi,%edx
80102bd8:	b8 04 00 00 00       	mov    $0x4,%eax
80102bdd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bde:	89 ca                	mov    %ecx,%edx
80102be0:	ec                   	in     (%dx),%al
80102be1:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be4:	89 fa                	mov    %edi,%edx
80102be6:	b8 07 00 00 00       	mov    $0x7,%eax
80102beb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bec:	89 ca                	mov    %ecx,%edx
80102bee:	ec                   	in     (%dx),%al
80102bef:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bf2:	89 fa                	mov    %edi,%edx
80102bf4:	b8 08 00 00 00       	mov    $0x8,%eax
80102bf9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bfa:	89 ca                	mov    %ecx,%edx
80102bfc:	ec                   	in     (%dx),%al
80102bfd:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bff:	89 fa                	mov    %edi,%edx
80102c01:	b8 09 00 00 00       	mov    $0x9,%eax
80102c06:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c07:	89 ca                	mov    %ecx,%edx
80102c09:	ec                   	in     (%dx),%al
80102c0a:	0f b6 d8             	movzbl %al,%ebx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c0d:	89 fa                	mov    %edi,%edx
80102c0f:	b8 0a 00 00 00       	mov    $0xa,%eax
80102c14:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c15:	89 ca                	mov    %ecx,%edx
80102c17:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102c18:	84 c0                	test   %al,%al
80102c1a:	78 9c                	js     80102bb8 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102c1c:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102c20:	89 f2                	mov    %esi,%edx
80102c22:	89 5d cc             	mov    %ebx,-0x34(%ebp)
80102c25:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c28:	89 fa                	mov    %edi,%edx
80102c2a:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102c2d:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102c31:	89 75 c8             	mov    %esi,-0x38(%ebp)
80102c34:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102c37:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102c3b:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102c3e:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102c42:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102c45:	31 c0                	xor    %eax,%eax
80102c47:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c48:	89 ca                	mov    %ecx,%edx
80102c4a:	ec                   	in     (%dx),%al
80102c4b:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c4e:	89 fa                	mov    %edi,%edx
80102c50:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102c53:	b8 02 00 00 00       	mov    $0x2,%eax
80102c58:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c59:	89 ca                	mov    %ecx,%edx
80102c5b:	ec                   	in     (%dx),%al
80102c5c:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c5f:	89 fa                	mov    %edi,%edx
80102c61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102c64:	b8 04 00 00 00       	mov    $0x4,%eax
80102c69:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c6a:	89 ca                	mov    %ecx,%edx
80102c6c:	ec                   	in     (%dx),%al
80102c6d:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c70:	89 fa                	mov    %edi,%edx
80102c72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102c75:	b8 07 00 00 00       	mov    $0x7,%eax
80102c7a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c7b:	89 ca                	mov    %ecx,%edx
80102c7d:	ec                   	in     (%dx),%al
80102c7e:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c81:	89 fa                	mov    %edi,%edx
80102c83:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102c86:	b8 08 00 00 00       	mov    $0x8,%eax
80102c8b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c8c:	89 ca                	mov    %ecx,%edx
80102c8e:	ec                   	in     (%dx),%al
80102c8f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c92:	89 fa                	mov    %edi,%edx
80102c94:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102c97:	b8 09 00 00 00       	mov    $0x9,%eax
80102c9c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c9d:	89 ca                	mov    %ecx,%edx
80102c9f:	ec                   	in     (%dx),%al
80102ca0:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ca3:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102ca6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ca9:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102cac:	6a 18                	push   $0x18
80102cae:	50                   	push   %eax
80102caf:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102cb2:	50                   	push   %eax
80102cb3:	e8 28 28 00 00       	call   801054e0 <memcmp>
80102cb8:	83 c4 10             	add    $0x10,%esp
80102cbb:	85 c0                	test   %eax,%eax
80102cbd:	0f 85 f5 fe ff ff    	jne    80102bb8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102cc3:	0f b6 75 b3          	movzbl -0x4d(%ebp),%esi
80102cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102cca:	89 f0                	mov    %esi,%eax
80102ccc:	84 c0                	test   %al,%al
80102cce:	75 78                	jne    80102d48 <cmostime+0x1b8>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102cd0:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102cd3:	89 c2                	mov    %eax,%edx
80102cd5:	83 e0 0f             	and    $0xf,%eax
80102cd8:	c1 ea 04             	shr    $0x4,%edx
80102cdb:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cde:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102ce1:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102ce4:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102ce7:	89 c2                	mov    %eax,%edx
80102ce9:	83 e0 0f             	and    $0xf,%eax
80102cec:	c1 ea 04             	shr    $0x4,%edx
80102cef:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cf2:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cf5:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102cf8:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102cfb:	89 c2                	mov    %eax,%edx
80102cfd:	83 e0 0f             	and    $0xf,%eax
80102d00:	c1 ea 04             	shr    $0x4,%edx
80102d03:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d06:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d09:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102d0c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d0f:	89 c2                	mov    %eax,%edx
80102d11:	83 e0 0f             	and    $0xf,%eax
80102d14:	c1 ea 04             	shr    $0x4,%edx
80102d17:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d1a:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d1d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102d20:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d23:	89 c2                	mov    %eax,%edx
80102d25:	83 e0 0f             	and    $0xf,%eax
80102d28:	c1 ea 04             	shr    $0x4,%edx
80102d2b:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d2e:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d31:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102d34:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d37:	89 c2                	mov    %eax,%edx
80102d39:	83 e0 0f             	and    $0xf,%eax
80102d3c:	c1 ea 04             	shr    $0x4,%edx
80102d3f:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d42:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d45:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102d48:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102d4b:	89 03                	mov    %eax,(%ebx)
80102d4d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102d50:	89 43 04             	mov    %eax,0x4(%ebx)
80102d53:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102d56:	89 43 08             	mov    %eax,0x8(%ebx)
80102d59:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d5c:	89 43 0c             	mov    %eax,0xc(%ebx)
80102d5f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d62:	89 43 10             	mov    %eax,0x10(%ebx)
80102d65:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d68:	89 43 14             	mov    %eax,0x14(%ebx)
  r->year += 2000;
80102d6b:	81 43 14 d0 07 00 00 	addl   $0x7d0,0x14(%ebx)
}
80102d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d75:	5b                   	pop    %ebx
80102d76:	5e                   	pop    %esi
80102d77:	5f                   	pop    %edi
80102d78:	5d                   	pop    %ebp
80102d79:	c3                   	ret
80102d7a:	66 90                	xchg   %ax,%ax
80102d7c:	66 90                	xchg   %ax,%ax
80102d7e:	66 90                	xchg   %ax,%ax

80102d80 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102d80:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
80102d86:	85 c9                	test   %ecx,%ecx
80102d88:	0f 8e 8a 00 00 00    	jle    80102e18 <install_trans+0x98>
{
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102d92:	31 ff                	xor    %edi,%edi
{
80102d94:	56                   	push   %esi
80102d95:	53                   	push   %ebx
80102d96:	83 ec 0c             	sub    $0xc,%esp
80102d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102da0:	a1 14 27 11 80       	mov    0x80112714,%eax
80102da5:	83 ec 08             	sub    $0x8,%esp
80102da8:	01 f8                	add    %edi,%eax
80102daa:	83 c0 01             	add    $0x1,%eax
80102dad:	50                   	push   %eax
80102dae:	ff 35 24 27 11 80    	push   0x80112724
80102db4:	e8 d7 d3 ff ff       	call   80100190 <bread>
80102db9:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dbb:	58                   	pop    %eax
80102dbc:	5a                   	pop    %edx
80102dbd:	ff 34 bd 2c 27 11 80 	push   -0x7feed8d4(,%edi,4)
80102dc4:	ff 35 24 27 11 80    	push   0x80112724
  for (tail = 0; tail < log.lh.n; tail++) {
80102dca:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dcd:	e8 be d3 ff ff       	call   80100190 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102dd2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dd5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102dd7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102dda:	68 00 02 00 00       	push   $0x200
80102ddf:	50                   	push   %eax
80102de0:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102de3:	50                   	push   %eax
80102de4:	e8 47 27 00 00       	call   80105530 <memmove>
    bwrite(dbuf);  // write dst to disk
80102de9:	89 1c 24             	mov    %ebx,(%esp)
80102dec:	e8 df d3 ff ff       	call   801001d0 <bwrite>
    brelse(lbuf);
80102df1:	89 34 24             	mov    %esi,(%esp)
80102df4:	e8 17 d4 ff ff       	call   80100210 <brelse>
    brelse(dbuf);
80102df9:	89 1c 24             	mov    %ebx,(%esp)
80102dfc:	e8 0f d4 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102e01:	83 c4 10             	add    $0x10,%esp
80102e04:	39 3d 28 27 11 80    	cmp    %edi,0x80112728
80102e0a:	7f 94                	jg     80102da0 <install_trans+0x20>
  }
}
80102e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e0f:	5b                   	pop    %ebx
80102e10:	5e                   	pop    %esi
80102e11:	5f                   	pop    %edi
80102e12:	5d                   	pop    %ebp
80102e13:	c3                   	ret
80102e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e18:	c3                   	ret
80102e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102e20 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102e20:	55                   	push   %ebp
80102e21:	89 e5                	mov    %esp,%ebp
80102e23:	53                   	push   %ebx
80102e24:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e27:	ff 35 14 27 11 80    	push   0x80112714
80102e2d:	ff 35 24 27 11 80    	push   0x80112724
80102e33:	e8 58 d3 ff ff       	call   80100190 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102e38:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e3b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102e3d:	a1 28 27 11 80       	mov    0x80112728,%eax
80102e42:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102e45:	85 c0                	test   %eax,%eax
80102e47:	7e 19                	jle    80102e62 <write_head+0x42>
80102e49:	31 d2                	xor    %edx,%edx
80102e4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e4f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102e50:	8b 0c 95 2c 27 11 80 	mov    -0x7feed8d4(,%edx,4),%ecx
80102e57:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102e5b:	83 c2 01             	add    $0x1,%edx
80102e5e:	39 d0                	cmp    %edx,%eax
80102e60:	75 ee                	jne    80102e50 <write_head+0x30>
  }
  bwrite(buf);
80102e62:	83 ec 0c             	sub    $0xc,%esp
80102e65:	53                   	push   %ebx
80102e66:	e8 65 d3 ff ff       	call   801001d0 <bwrite>
  brelse(buf);
80102e6b:	89 1c 24             	mov    %ebx,(%esp)
80102e6e:	e8 9d d3 ff ff       	call   80100210 <brelse>
}
80102e73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e76:	83 c4 10             	add    $0x10,%esp
80102e79:	c9                   	leave
80102e7a:	c3                   	ret
80102e7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e7f:	90                   	nop

80102e80 <initlog>:
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	53                   	push   %ebx
80102e84:	83 ec 3c             	sub    $0x3c,%esp
80102e87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102e8a:	68 06 84 10 80       	push   $0x80108406
80102e8f:	68 e0 26 11 80       	push   $0x801126e0
80102e94:	e8 17 23 00 00       	call   801051b0 <initlock>
  readsb(dev, &sb);
80102e99:	58                   	pop    %eax
80102e9a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80102e9d:	5a                   	pop    %edx
80102e9e:	50                   	push   %eax
80102e9f:	53                   	push   %ebx
80102ea0:	e8 cb e7 ff ff       	call   80101670 <readsb>
  log.start = sb.logstart;
80102ea5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102ea8:	59                   	pop    %ecx
  log.dev = dev;
80102ea9:	89 1d 24 27 11 80    	mov    %ebx,0x80112724
  log.size = sb.nlog;
80102eaf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  log.start = sb.logstart;
80102eb2:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80102eb7:	89 15 18 27 11 80    	mov    %edx,0x80112718
  struct buf *buf = bread(log.dev, log.start);
80102ebd:	5a                   	pop    %edx
80102ebe:	50                   	push   %eax
80102ebf:	53                   	push   %ebx
80102ec0:	e8 cb d2 ff ff       	call   80100190 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102ec5:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102ec8:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102ecb:	89 1d 28 27 11 80    	mov    %ebx,0x80112728
  for (i = 0; i < log.lh.n; i++) {
80102ed1:	85 db                	test   %ebx,%ebx
80102ed3:	7e 1d                	jle    80102ef2 <initlog+0x72>
80102ed5:	31 d2                	xor    %edx,%edx
80102ed7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102ede:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102ee0:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102ee4:	89 0c 95 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102eeb:	83 c2 01             	add    $0x1,%edx
80102eee:	39 d3                	cmp    %edx,%ebx
80102ef0:	75 ee                	jne    80102ee0 <initlog+0x60>
  brelse(buf);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	50                   	push   %eax
80102ef6:	e8 15 d3 ff ff       	call   80100210 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102efb:	e8 80 fe ff ff       	call   80102d80 <install_trans>
  log.lh.n = 0;
80102f00:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80102f07:	00 00 00 
  write_head(); // clear the log
80102f0a:	e8 11 ff ff ff       	call   80102e20 <write_head>
}
80102f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f12:	83 c4 10             	add    $0x10,%esp
80102f15:	c9                   	leave
80102f16:	c3                   	ret
80102f17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f1e:	66 90                	xchg   %ax,%ax

80102f20 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102f26:	68 e0 26 11 80       	push   $0x801126e0
80102f2b:	e8 70 24 00 00       	call   801053a0 <acquire>
80102f30:	83 c4 10             	add    $0x10,%esp
80102f33:	eb 18                	jmp    80102f4d <begin_op+0x2d>
80102f35:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102f38:	83 ec 08             	sub    $0x8,%esp
80102f3b:	68 e0 26 11 80       	push   $0x801126e0
80102f40:	68 e0 26 11 80       	push   $0x801126e0
80102f45:	e8 b6 13 00 00       	call   80104300 <sleep>
80102f4a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102f4d:	a1 20 27 11 80       	mov    0x80112720,%eax
80102f52:	85 c0                	test   %eax,%eax
80102f54:	75 e2                	jne    80102f38 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102f56:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80102f5b:	8b 15 28 27 11 80    	mov    0x80112728,%edx
80102f61:	83 c0 01             	add    $0x1,%eax
80102f64:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102f67:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102f6a:	83 fa 1e             	cmp    $0x1e,%edx
80102f6d:	7f c9                	jg     80102f38 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102f6f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102f72:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
80102f77:	68 e0 26 11 80       	push   $0x801126e0
80102f7c:	e8 bf 23 00 00       	call   80105340 <release>
      break;
    }
  }
}
80102f81:	83 c4 10             	add    $0x10,%esp
80102f84:	c9                   	leave
80102f85:	c3                   	ret
80102f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f8d:	8d 76 00             	lea    0x0(%esi),%esi

80102f90 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102f90:	55                   	push   %ebp
80102f91:	89 e5                	mov    %esp,%ebp
80102f93:	57                   	push   %edi
80102f94:	56                   	push   %esi
80102f95:	53                   	push   %ebx
80102f96:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102f99:	68 e0 26 11 80       	push   $0x801126e0
80102f9e:	e8 fd 23 00 00       	call   801053a0 <acquire>
  log.outstanding -= 1;
80102fa3:	a1 1c 27 11 80       	mov    0x8011271c,%eax
  if(log.committing)
80102fa8:	8b 35 20 27 11 80    	mov    0x80112720,%esi
80102fae:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102fb1:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102fb4:	89 1d 1c 27 11 80    	mov    %ebx,0x8011271c
  if(log.committing)
80102fba:	85 f6                	test   %esi,%esi
80102fbc:	0f 85 22 01 00 00    	jne    801030e4 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102fc2:	85 db                	test   %ebx,%ebx
80102fc4:	0f 85 f6 00 00 00    	jne    801030c0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102fca:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
80102fd1:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102fd4:	83 ec 0c             	sub    $0xc,%esp
80102fd7:	68 e0 26 11 80       	push   $0x801126e0
80102fdc:	e8 5f 23 00 00       	call   80105340 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102fe1:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
80102fe7:	83 c4 10             	add    $0x10,%esp
80102fea:	85 c9                	test   %ecx,%ecx
80102fec:	7f 42                	jg     80103030 <end_op+0xa0>
    acquire(&log.lock);
80102fee:	83 ec 0c             	sub    $0xc,%esp
80102ff1:	68 e0 26 11 80       	push   $0x801126e0
80102ff6:	e8 a5 23 00 00       	call   801053a0 <acquire>
    log.committing = 0;
80102ffb:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
80103002:	00 00 00 
    wakeup(&log);
80103005:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
8010300c:	e8 af 13 00 00       	call   801043c0 <wakeup>
    release(&log.lock);
80103011:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
80103018:	e8 23 23 00 00       	call   80105340 <release>
8010301d:	83 c4 10             	add    $0x10,%esp
}
80103020:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103023:	5b                   	pop    %ebx
80103024:	5e                   	pop    %esi
80103025:	5f                   	pop    %edi
80103026:	5d                   	pop    %ebp
80103027:	c3                   	ret
80103028:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010302f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103030:	a1 14 27 11 80       	mov    0x80112714,%eax
80103035:	83 ec 08             	sub    $0x8,%esp
80103038:	01 d8                	add    %ebx,%eax
8010303a:	83 c0 01             	add    $0x1,%eax
8010303d:	50                   	push   %eax
8010303e:	ff 35 24 27 11 80    	push   0x80112724
80103044:	e8 47 d1 ff ff       	call   80100190 <bread>
80103049:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010304b:	58                   	pop    %eax
8010304c:	5a                   	pop    %edx
8010304d:	ff 34 9d 2c 27 11 80 	push   -0x7feed8d4(,%ebx,4)
80103054:	ff 35 24 27 11 80    	push   0x80112724
  for (tail = 0; tail < log.lh.n; tail++) {
8010305a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010305d:	e8 2e d1 ff ff       	call   80100190 <bread>
    memmove(to->data, from->data, BSIZE);
80103062:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103065:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103067:	8d 40 5c             	lea    0x5c(%eax),%eax
8010306a:	68 00 02 00 00       	push   $0x200
8010306f:	50                   	push   %eax
80103070:	8d 46 5c             	lea    0x5c(%esi),%eax
80103073:	50                   	push   %eax
80103074:	e8 b7 24 00 00       	call   80105530 <memmove>
    bwrite(to);  // write the log
80103079:	89 34 24             	mov    %esi,(%esp)
8010307c:	e8 4f d1 ff ff       	call   801001d0 <bwrite>
    brelse(from);
80103081:	89 3c 24             	mov    %edi,(%esp)
80103084:	e8 87 d1 ff ff       	call   80100210 <brelse>
    brelse(to);
80103089:	89 34 24             	mov    %esi,(%esp)
8010308c:	e8 7f d1 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80103091:	83 c4 10             	add    $0x10,%esp
80103094:	3b 1d 28 27 11 80    	cmp    0x80112728,%ebx
8010309a:	7c 94                	jl     80103030 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
8010309c:	e8 7f fd ff ff       	call   80102e20 <write_head>
    install_trans(); // Now install writes to home locations
801030a1:	e8 da fc ff ff       	call   80102d80 <install_trans>
    log.lh.n = 0;
801030a6:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
801030ad:	00 00 00 
    write_head();    // Erase the transaction from the log
801030b0:	e8 6b fd ff ff       	call   80102e20 <write_head>
801030b5:	e9 34 ff ff ff       	jmp    80102fee <end_op+0x5e>
801030ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
801030c0:	83 ec 0c             	sub    $0xc,%esp
801030c3:	68 e0 26 11 80       	push   $0x801126e0
801030c8:	e8 f3 12 00 00       	call   801043c0 <wakeup>
  release(&log.lock);
801030cd:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
801030d4:	e8 67 22 00 00       	call   80105340 <release>
801030d9:	83 c4 10             	add    $0x10,%esp
}
801030dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030df:	5b                   	pop    %ebx
801030e0:	5e                   	pop    %esi
801030e1:	5f                   	pop    %edi
801030e2:	5d                   	pop    %ebp
801030e3:	c3                   	ret
    panic("log.committing");
801030e4:	83 ec 0c             	sub    $0xc,%esp
801030e7:	68 0a 84 10 80       	push   $0x8010840a
801030ec:	e8 bf d3 ff ff       	call   801004b0 <panic>
801030f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030ff:	90                   	nop

80103100 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103100:	55                   	push   %ebp
80103101:	89 e5                	mov    %esp,%ebp
80103103:	53                   	push   %ebx
80103104:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103107:	8b 15 28 27 11 80    	mov    0x80112728,%edx
{
8010310d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103110:	83 fa 1d             	cmp    $0x1d,%edx
80103113:	7f 7d                	jg     80103192 <log_write+0x92>
80103115:	a1 18 27 11 80       	mov    0x80112718,%eax
8010311a:	83 e8 01             	sub    $0x1,%eax
8010311d:	39 c2                	cmp    %eax,%edx
8010311f:	7d 71                	jge    80103192 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103121:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103126:	85 c0                	test   %eax,%eax
80103128:	7e 75                	jle    8010319f <log_write+0x9f>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010312a:	83 ec 0c             	sub    $0xc,%esp
8010312d:	68 e0 26 11 80       	push   $0x801126e0
80103132:	e8 69 22 00 00       	call   801053a0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103137:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
8010313a:	83 c4 10             	add    $0x10,%esp
8010313d:	31 c0                	xor    %eax,%eax
8010313f:	8b 15 28 27 11 80    	mov    0x80112728,%edx
80103145:	85 d2                	test   %edx,%edx
80103147:	7f 0e                	jg     80103157 <log_write+0x57>
80103149:	eb 15                	jmp    80103160 <log_write+0x60>
8010314b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010314f:	90                   	nop
80103150:	83 c0 01             	add    $0x1,%eax
80103153:	39 c2                	cmp    %eax,%edx
80103155:	74 29                	je     80103180 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103157:	39 0c 85 2c 27 11 80 	cmp    %ecx,-0x7feed8d4(,%eax,4)
8010315e:	75 f0                	jne    80103150 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80103160:	89 0c 85 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%eax,4)
  if (i == log.lh.n)
80103167:	39 c2                	cmp    %eax,%edx
80103169:	74 1c                	je     80103187 <log_write+0x87>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010316b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010316e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
80103171:	c7 45 08 e0 26 11 80 	movl   $0x801126e0,0x8(%ebp)
}
80103178:	c9                   	leave
  release(&log.lock);
80103179:	e9 c2 21 00 00       	jmp    80105340 <release>
8010317e:	66 90                	xchg   %ax,%ax
  log.lh.block[i] = b->blockno;
80103180:	89 0c 95 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%edx,4)
    log.lh.n++;
80103187:	83 c2 01             	add    $0x1,%edx
8010318a:	89 15 28 27 11 80    	mov    %edx,0x80112728
80103190:	eb d9                	jmp    8010316b <log_write+0x6b>
    panic("too big a transaction");
80103192:	83 ec 0c             	sub    $0xc,%esp
80103195:	68 19 84 10 80       	push   $0x80108419
8010319a:	e8 11 d3 ff ff       	call   801004b0 <panic>
    panic("log_write outside of trans");
8010319f:	83 ec 0c             	sub    $0xc,%esp
801031a2:	68 2f 84 10 80       	push   $0x8010842f
801031a7:	e8 04 d3 ff ff       	call   801004b0 <panic>
801031ac:	66 90                	xchg   %ax,%ax
801031ae:	66 90                	xchg   %ax,%ax

801031b0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801031b0:	55                   	push   %ebp
801031b1:	89 e5                	mov    %esp,%ebp
801031b3:	53                   	push   %ebx
801031b4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801031b7:	e8 14 0b 00 00       	call   80103cd0 <cpuid>
801031bc:	89 c3                	mov    %eax,%ebx
801031be:	e8 0d 0b 00 00       	call   80103cd0 <cpuid>
801031c3:	83 ec 04             	sub    $0x4,%esp
801031c6:	53                   	push   %ebx
801031c7:	50                   	push   %eax
801031c8:	68 4a 84 10 80       	push   $0x8010844a
801031cd:	e8 0e d6 ff ff       	call   801007e0 <cprintf>
  idtinit();       // load idt register
801031d2:	e8 29 35 00 00       	call   80106700 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801031d7:	e8 94 0a 00 00       	call   80103c70 <mycpu>
801031dc:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801031de:	b8 01 00 00 00       	mov    $0x1,%eax
801031e3:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  cprintf("Started running process\n");
801031ea:	c7 04 24 5e 84 10 80 	movl   $0x8010845e,(%esp)
801031f1:	e8 ea d5 ff ff       	call   801007e0 <cprintf>
  scheduler();     // start running processes
801031f6:	e8 25 0e 00 00       	call   80104020 <scheduler>
801031fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801031ff:	90                   	nop

80103200 <mpenter>:
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
80103203:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103206:	e8 55 47 00 00       	call   80107960 <switchkvm>
  seginit();
8010320b:	e8 c0 46 00 00       	call   801078d0 <seginit>
  lapicinit();
80103210:	e8 ab f7 ff ff       	call   801029c0 <lapicinit>
  mpmain();
80103215:	e8 96 ff ff ff       	call   801031b0 <mpmain>
8010321a:	66 90                	xchg   %ax,%ax
8010321c:	66 90                	xchg   %ax,%ax
8010321e:	66 90                	xchg   %ax,%ax

80103220 <main>:
{
80103220:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103224:	83 e4 f0             	and    $0xfffffff0,%esp
80103227:	ff 71 fc             	push   -0x4(%ecx)
8010322a:	55                   	push   %ebp
8010322b:	89 e5                	mov    %esp,%ebp
8010322d:	53                   	push   %ebx
8010322e:	51                   	push   %ecx
  initrmap();     // Initialize rmap
8010322f:	e8 7c 08 00 00       	call   80103ab0 <initrmap>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103234:	83 ec 08             	sub    $0x8,%esp
80103237:	68 00 00 40 80       	push   $0x80400000
8010323c:	68 b0 49 1c 80       	push   $0x801c49b0
80103241:	e8 ea f4 ff ff       	call   80102730 <kinit1>
  kvmalloc();      // kernel page table
80103246:	e8 75 4c 00 00       	call   80107ec0 <kvmalloc>
  mpinit();        // detect other processors
8010324b:	e8 80 01 00 00       	call   801033d0 <mpinit>
  lapicinit();     // interrupt controller
80103250:	e8 6b f7 ff ff       	call   801029c0 <lapicinit>
  seginit();       // segment descriptors
80103255:	e8 76 46 00 00       	call   801078d0 <seginit>
  picinit();       // disable pic
8010325a:	e8 81 03 00 00       	call   801035e0 <picinit>
  ioapicinit();    // another interrupt controller
8010325f:	e8 8c f2 ff ff       	call   801024f0 <ioapicinit>
  consoleinit();   // console hardware
80103264:	e8 27 d9 ff ff       	call   80100b90 <consoleinit>
  uartinit();      // serial port
80103269:	e8 a2 37 00 00       	call   80106a10 <uartinit>
  pinit();         // process table
8010326e:	e8 dd 09 00 00       	call   80103c50 <pinit>
  tvinit();        // trap vectors
80103273:	e8 08 34 00 00       	call   80106680 <tvinit>
  binit();         // buffer cache
80103278:	e8 83 ce ff ff       	call   80100100 <binit>
  fileinit();      // file table
8010327d:	e8 de dc ff ff       	call   80100f60 <fileinit>
  ideinit();       // disk 
80103282:	e8 49 f0 ff ff       	call   801022d0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103287:	83 c4 0c             	add    $0xc,%esp
8010328a:	68 8a 00 00 00       	push   $0x8a
8010328f:	68 8c b4 10 80       	push   $0x8010b48c
80103294:	68 00 70 00 80       	push   $0x80007000
80103299:	e8 92 22 00 00       	call   80105530 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010329e:	83 c4 10             	add    $0x10,%esp
801032a1:	69 05 c4 27 11 80 b0 	imul   $0xb0,0x801127c4,%eax
801032a8:	00 00 00 
801032ab:	05 e0 27 11 80       	add    $0x801127e0,%eax
801032b0:	3d e0 27 11 80       	cmp    $0x801127e0,%eax
801032b5:	76 79                	jbe    80103330 <main+0x110>
801032b7:	bb e0 27 11 80       	mov    $0x801127e0,%ebx
801032bc:	eb 1b                	jmp    801032d9 <main+0xb9>
801032be:	66 90                	xchg   %ax,%ax
801032c0:	69 05 c4 27 11 80 b0 	imul   $0xb0,0x801127c4,%eax
801032c7:	00 00 00 
801032ca:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801032d0:	05 e0 27 11 80       	add    $0x801127e0,%eax
801032d5:	39 c3                	cmp    %eax,%ebx
801032d7:	73 57                	jae    80103330 <main+0x110>
    if(c == mycpu())  // We've started already.
801032d9:	e8 92 09 00 00       	call   80103c70 <mycpu>
801032de:	39 c3                	cmp    %eax,%ebx
801032e0:	74 de                	je     801032c0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801032e2:	e8 b9 f4 ff ff       	call   801027a0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
801032e7:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
801032ea:	c7 05 f8 6f 00 80 00 	movl   $0x80103200,0x80006ff8
801032f1:	32 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801032f4:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801032fb:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
801032fe:	05 00 10 00 00       	add    $0x1000,%eax
80103303:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103308:	0f b6 03             	movzbl (%ebx),%eax
8010330b:	68 00 70 00 00       	push   $0x7000
80103310:	50                   	push   %eax
80103311:	e8 ea f7 ff ff       	call   80102b00 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103316:	83 c4 10             	add    $0x10,%esp
80103319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103320:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103326:	85 c0                	test   %eax,%eax
80103328:	74 f6                	je     80103320 <main+0x100>
8010332a:	eb 94                	jmp    801032c0 <main+0xa0>
8010332c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103330:	83 ec 08             	sub    $0x8,%esp
80103333:	68 00 00 40 80       	push   $0x80400000
80103338:	68 00 00 40 80       	push   $0x80400000
8010333d:	e8 8e f3 ff ff       	call   801026d0 <kinit2>
  userinit();      // first user process
80103342:	e8 d9 09 00 00       	call   80103d20 <userinit>
  mpmain();        // finish this processor's setup
80103347:	e8 64 fe ff ff       	call   801031b0 <mpmain>
8010334c:	66 90                	xchg   %ax,%ax
8010334e:	66 90                	xchg   %ax,%ax

80103350 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103350:	55                   	push   %ebp
80103351:	89 e5                	mov    %esp,%ebp
80103353:	57                   	push   %edi
80103354:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103355:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010335b:	53                   	push   %ebx
  e = addr+len;
8010335c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010335f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103362:	39 de                	cmp    %ebx,%esi
80103364:	72 10                	jb     80103376 <mpsearch1+0x26>
80103366:	eb 50                	jmp    801033b8 <mpsearch1+0x68>
80103368:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010336f:	90                   	nop
80103370:	89 fe                	mov    %edi,%esi
80103372:	39 df                	cmp    %ebx,%edi
80103374:	73 42                	jae    801033b8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103376:	83 ec 04             	sub    $0x4,%esp
80103379:	8d 7e 10             	lea    0x10(%esi),%edi
8010337c:	6a 04                	push   $0x4
8010337e:	68 77 84 10 80       	push   $0x80108477
80103383:	56                   	push   %esi
80103384:	e8 57 21 00 00       	call   801054e0 <memcmp>
80103389:	83 c4 10             	add    $0x10,%esp
8010338c:	85 c0                	test   %eax,%eax
8010338e:	75 e0                	jne    80103370 <mpsearch1+0x20>
80103390:	89 f2                	mov    %esi,%edx
80103392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
80103398:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
8010339b:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
8010339e:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801033a0:	39 fa                	cmp    %edi,%edx
801033a2:	75 f4                	jne    80103398 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033a4:	84 c0                	test   %al,%al
801033a6:	75 c8                	jne    80103370 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801033a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033ab:	89 f0                	mov    %esi,%eax
801033ad:	5b                   	pop    %ebx
801033ae:	5e                   	pop    %esi
801033af:	5f                   	pop    %edi
801033b0:	5d                   	pop    %ebp
801033b1:	c3                   	ret
801033b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801033b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801033bb:	31 f6                	xor    %esi,%esi
}
801033bd:	5b                   	pop    %ebx
801033be:	89 f0                	mov    %esi,%eax
801033c0:	5e                   	pop    %esi
801033c1:	5f                   	pop    %edi
801033c2:	5d                   	pop    %ebp
801033c3:	c3                   	ret
801033c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801033cf:	90                   	nop

801033d0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
801033d3:	57                   	push   %edi
801033d4:	56                   	push   %esi
801033d5:	53                   	push   %ebx
801033d6:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801033d9:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
801033e0:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
801033e7:	c1 e0 08             	shl    $0x8,%eax
801033ea:	09 d0                	or     %edx,%eax
801033ec:	c1 e0 04             	shl    $0x4,%eax
801033ef:	75 1b                	jne    8010340c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801033f1:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
801033f8:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
801033ff:	c1 e0 08             	shl    $0x8,%eax
80103402:	09 d0                	or     %edx,%eax
80103404:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103407:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010340c:	ba 00 04 00 00       	mov    $0x400,%edx
80103411:	e8 3a ff ff ff       	call   80103350 <mpsearch1>
80103416:	89 c3                	mov    %eax,%ebx
80103418:	85 c0                	test   %eax,%eax
8010341a:	0f 84 58 01 00 00    	je     80103578 <mpinit+0x1a8>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103420:	8b 73 04             	mov    0x4(%ebx),%esi
80103423:	85 f6                	test   %esi,%esi
80103425:	0f 84 3d 01 00 00    	je     80103568 <mpinit+0x198>
  if(memcmp(conf, "PCMP", 4) != 0)
8010342b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010342e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80103434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103437:	6a 04                	push   $0x4
80103439:	68 7c 84 10 80       	push   $0x8010847c
8010343e:	50                   	push   %eax
8010343f:	e8 9c 20 00 00       	call   801054e0 <memcmp>
80103444:	83 c4 10             	add    $0x10,%esp
80103447:	85 c0                	test   %eax,%eax
80103449:	0f 85 19 01 00 00    	jne    80103568 <mpinit+0x198>
  if(conf->version != 1 && conf->version != 4)
8010344f:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
80103456:	3c 01                	cmp    $0x1,%al
80103458:	74 08                	je     80103462 <mpinit+0x92>
8010345a:	3c 04                	cmp    $0x4,%al
8010345c:	0f 85 06 01 00 00    	jne    80103568 <mpinit+0x198>
  if(sum((uchar*)conf, conf->length) != 0)
80103462:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
80103469:	66 85 d2             	test   %dx,%dx
8010346c:	74 22                	je     80103490 <mpinit+0xc0>
8010346e:	8d 3c 32             	lea    (%edx,%esi,1),%edi
80103471:	89 f0                	mov    %esi,%eax
  sum = 0;
80103473:	31 d2                	xor    %edx,%edx
80103475:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103478:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
8010347f:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
80103482:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103484:	39 f8                	cmp    %edi,%eax
80103486:	75 f0                	jne    80103478 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103488:	84 d2                	test   %dl,%dl
8010348a:	0f 85 d8 00 00 00    	jne    80103568 <mpinit+0x198>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103490:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103499:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  lapic = (uint*)conf->lapicaddr;
8010349c:	a3 c4 26 11 80       	mov    %eax,0x801126c4
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034a1:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
801034a8:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
801034ae:	01 d7                	add    %edx,%edi
801034b0:	89 fa                	mov    %edi,%edx
  ismp = 1;
801034b2:	bf 01 00 00 00       	mov    $0x1,%edi
801034b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034be:	66 90                	xchg   %ax,%ax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034c0:	39 d0                	cmp    %edx,%eax
801034c2:	73 19                	jae    801034dd <mpinit+0x10d>
    switch(*p){
801034c4:	0f b6 08             	movzbl (%eax),%ecx
801034c7:	80 f9 02             	cmp    $0x2,%cl
801034ca:	0f 84 80 00 00 00    	je     80103550 <mpinit+0x180>
801034d0:	77 6e                	ja     80103540 <mpinit+0x170>
801034d2:	84 c9                	test   %cl,%cl
801034d4:	74 3a                	je     80103510 <mpinit+0x140>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801034d6:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034d9:	39 d0                	cmp    %edx,%eax
801034db:	72 e7                	jb     801034c4 <mpinit+0xf4>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801034dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801034e0:	85 ff                	test   %edi,%edi
801034e2:	0f 84 dd 00 00 00    	je     801035c5 <mpinit+0x1f5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
801034e8:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
801034ec:	74 15                	je     80103503 <mpinit+0x133>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034ee:	b8 70 00 00 00       	mov    $0x70,%eax
801034f3:	ba 22 00 00 00       	mov    $0x22,%edx
801034f8:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034f9:	ba 23 00 00 00       	mov    $0x23,%edx
801034fe:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801034ff:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103502:	ee                   	out    %al,(%dx)
  }
}
80103503:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103506:	5b                   	pop    %ebx
80103507:	5e                   	pop    %esi
80103508:	5f                   	pop    %edi
80103509:	5d                   	pop    %ebp
8010350a:	c3                   	ret
8010350b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010350f:	90                   	nop
      if(ncpu < NCPU) {
80103510:	8b 0d c4 27 11 80    	mov    0x801127c4,%ecx
80103516:	83 f9 07             	cmp    $0x7,%ecx
80103519:	7f 19                	jg     80103534 <mpinit+0x164>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010351b:	69 f1 b0 00 00 00    	imul   $0xb0,%ecx,%esi
80103521:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103525:	83 c1 01             	add    $0x1,%ecx
80103528:	89 0d c4 27 11 80    	mov    %ecx,0x801127c4
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010352e:	88 9e e0 27 11 80    	mov    %bl,-0x7feed820(%esi)
      p += sizeof(struct mpproc);
80103534:	83 c0 14             	add    $0x14,%eax
      continue;
80103537:	eb 87                	jmp    801034c0 <mpinit+0xf0>
80103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(*p){
80103540:	83 e9 03             	sub    $0x3,%ecx
80103543:	80 f9 01             	cmp    $0x1,%cl
80103546:	76 8e                	jbe    801034d6 <mpinit+0x106>
80103548:	31 ff                	xor    %edi,%edi
8010354a:	e9 71 ff ff ff       	jmp    801034c0 <mpinit+0xf0>
8010354f:	90                   	nop
      ioapicid = ioapic->apicno;
80103550:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103554:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103557:	88 0d c0 27 11 80    	mov    %cl,0x801127c0
      continue;
8010355d:	e9 5e ff ff ff       	jmp    801034c0 <mpinit+0xf0>
80103562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("Expect to run on an SMP");
80103568:	83 ec 0c             	sub    $0xc,%esp
8010356b:	68 81 84 10 80       	push   $0x80108481
80103570:	e8 3b cf ff ff       	call   801004b0 <panic>
80103575:	8d 76 00             	lea    0x0(%esi),%esi
{
80103578:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
8010357d:	eb 0b                	jmp    8010358a <mpinit+0x1ba>
8010357f:	90                   	nop
  for(p = addr; p < e; p += sizeof(struct mp))
80103580:	89 f3                	mov    %esi,%ebx
80103582:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
80103588:	74 de                	je     80103568 <mpinit+0x198>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010358a:	83 ec 04             	sub    $0x4,%esp
8010358d:	8d 73 10             	lea    0x10(%ebx),%esi
80103590:	6a 04                	push   $0x4
80103592:	68 77 84 10 80       	push   $0x80108477
80103597:	53                   	push   %ebx
80103598:	e8 43 1f 00 00       	call   801054e0 <memcmp>
8010359d:	83 c4 10             	add    $0x10,%esp
801035a0:	85 c0                	test   %eax,%eax
801035a2:	75 dc                	jne    80103580 <mpinit+0x1b0>
801035a4:	89 da                	mov    %ebx,%edx
801035a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801035ad:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801035b0:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801035b3:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801035b6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801035b8:	39 d6                	cmp    %edx,%esi
801035ba:	75 f4                	jne    801035b0 <mpinit+0x1e0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801035bc:	84 c0                	test   %al,%al
801035be:	75 c0                	jne    80103580 <mpinit+0x1b0>
801035c0:	e9 5b fe ff ff       	jmp    80103420 <mpinit+0x50>
    panic("Didn't find a suitable machine");
801035c5:	83 ec 0c             	sub    $0xc,%esp
801035c8:	68 84 88 10 80       	push   $0x80108884
801035cd:	e8 de ce ff ff       	call   801004b0 <panic>
801035d2:	66 90                	xchg   %ax,%ax
801035d4:	66 90                	xchg   %ax,%ax
801035d6:	66 90                	xchg   %ax,%ax
801035d8:	66 90                	xchg   %ax,%ax
801035da:	66 90                	xchg   %ax,%ax
801035dc:	66 90                	xchg   %ax,%ax
801035de:	66 90                	xchg   %ax,%ax

801035e0 <picinit>:
801035e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035e5:	ba 21 00 00 00       	mov    $0x21,%edx
801035ea:	ee                   	out    %al,(%dx)
801035eb:	ba a1 00 00 00       	mov    $0xa1,%edx
801035f0:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
801035f1:	c3                   	ret
801035f2:	66 90                	xchg   %ax,%ax
801035f4:	66 90                	xchg   %ax,%ax
801035f6:	66 90                	xchg   %ax,%ax
801035f8:	66 90                	xchg   %ax,%ax
801035fa:	66 90                	xchg   %ax,%ax
801035fc:	66 90                	xchg   %ax,%ax
801035fe:	66 90                	xchg   %ax,%ax

80103600 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103600:	55                   	push   %ebp
80103601:	89 e5                	mov    %esp,%ebp
80103603:	57                   	push   %edi
80103604:	56                   	push   %esi
80103605:	53                   	push   %ebx
80103606:	83 ec 0c             	sub    $0xc,%esp
80103609:	8b 75 08             	mov    0x8(%ebp),%esi
8010360c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010360f:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
80103615:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010361b:	e8 60 d9 ff ff       	call   80100f80 <filealloc>
80103620:	89 06                	mov    %eax,(%esi)
80103622:	85 c0                	test   %eax,%eax
80103624:	0f 84 a5 00 00 00    	je     801036cf <pipealloc+0xcf>
8010362a:	e8 51 d9 ff ff       	call   80100f80 <filealloc>
8010362f:	89 07                	mov    %eax,(%edi)
80103631:	85 c0                	test   %eax,%eax
80103633:	0f 84 84 00 00 00    	je     801036bd <pipealloc+0xbd>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103639:	e8 62 f1 ff ff       	call   801027a0 <kalloc>
8010363e:	89 c3                	mov    %eax,%ebx
80103640:	85 c0                	test   %eax,%eax
80103642:	0f 84 a0 00 00 00    	je     801036e8 <pipealloc+0xe8>
    goto bad;
  p->readopen = 1;
80103648:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010364f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103652:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103655:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010365c:	00 00 00 
  p->nwrite = 0;
8010365f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103666:	00 00 00 
  p->nread = 0;
80103669:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103670:	00 00 00 
  initlock(&p->lock, "pipe");
80103673:	68 99 84 10 80       	push   $0x80108499
80103678:	50                   	push   %eax
80103679:	e8 32 1b 00 00       	call   801051b0 <initlock>
  (*f0)->type = FD_PIPE;
8010367e:	8b 06                	mov    (%esi),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103680:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103683:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103689:	8b 06                	mov    (%esi),%eax
8010368b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010368f:	8b 06                	mov    (%esi),%eax
80103691:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103695:	8b 06                	mov    (%esi),%eax
80103697:	89 58 0c             	mov    %ebx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010369a:	8b 07                	mov    (%edi),%eax
8010369c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801036a2:	8b 07                	mov    (%edi),%eax
801036a4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801036a8:	8b 07                	mov    (%edi),%eax
801036aa:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801036ae:	8b 07                	mov    (%edi),%eax
801036b0:	89 58 0c             	mov    %ebx,0xc(%eax)
  return 0;
801036b3:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801036b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036b8:	5b                   	pop    %ebx
801036b9:	5e                   	pop    %esi
801036ba:	5f                   	pop    %edi
801036bb:	5d                   	pop    %ebp
801036bc:	c3                   	ret
  if(*f0)
801036bd:	8b 06                	mov    (%esi),%eax
801036bf:	85 c0                	test   %eax,%eax
801036c1:	74 1e                	je     801036e1 <pipealloc+0xe1>
    fileclose(*f0);
801036c3:	83 ec 0c             	sub    $0xc,%esp
801036c6:	50                   	push   %eax
801036c7:	e8 74 d9 ff ff       	call   80101040 <fileclose>
801036cc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801036cf:	8b 07                	mov    (%edi),%eax
801036d1:	85 c0                	test   %eax,%eax
801036d3:	74 0c                	je     801036e1 <pipealloc+0xe1>
    fileclose(*f1);
801036d5:	83 ec 0c             	sub    $0xc,%esp
801036d8:	50                   	push   %eax
801036d9:	e8 62 d9 ff ff       	call   80101040 <fileclose>
801036de:	83 c4 10             	add    $0x10,%esp
  return -1;
801036e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036e6:	eb cd                	jmp    801036b5 <pipealloc+0xb5>
  if(*f0)
801036e8:	8b 06                	mov    (%esi),%eax
801036ea:	85 c0                	test   %eax,%eax
801036ec:	75 d5                	jne    801036c3 <pipealloc+0xc3>
801036ee:	eb df                	jmp    801036cf <pipealloc+0xcf>

801036f0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	56                   	push   %esi
801036f4:	53                   	push   %ebx
801036f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801036f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	53                   	push   %ebx
801036ff:	e8 9c 1c 00 00       	call   801053a0 <acquire>
  if(writable){
80103704:	83 c4 10             	add    $0x10,%esp
80103707:	85 f6                	test   %esi,%esi
80103709:	74 65                	je     80103770 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010370b:	83 ec 0c             	sub    $0xc,%esp
8010370e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103714:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010371b:	00 00 00 
    wakeup(&p->nread);
8010371e:	50                   	push   %eax
8010371f:	e8 9c 0c 00 00       	call   801043c0 <wakeup>
80103724:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103727:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010372d:	85 d2                	test   %edx,%edx
8010372f:	75 0a                	jne    8010373b <pipeclose+0x4b>
80103731:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103737:	85 c0                	test   %eax,%eax
80103739:	74 15                	je     80103750 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010373b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010373e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103741:	5b                   	pop    %ebx
80103742:	5e                   	pop    %esi
80103743:	5d                   	pop    %ebp
    release(&p->lock);
80103744:	e9 f7 1b 00 00       	jmp    80105340 <release>
80103749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
80103750:	83 ec 0c             	sub    $0xc,%esp
80103753:	53                   	push   %ebx
80103754:	e8 e7 1b 00 00       	call   80105340 <release>
    kfree((char*)p);
80103759:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010375c:	83 c4 10             	add    $0x10,%esp
}
8010375f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103762:	5b                   	pop    %ebx
80103763:	5e                   	pop    %esi
80103764:	5d                   	pop    %ebp
    kfree((char*)p);
80103765:	e9 66 ee ff ff       	jmp    801025d0 <kfree>
8010376a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103770:	83 ec 0c             	sub    $0xc,%esp
80103773:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103779:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103780:	00 00 00 
    wakeup(&p->nwrite);
80103783:	50                   	push   %eax
80103784:	e8 37 0c 00 00       	call   801043c0 <wakeup>
80103789:	83 c4 10             	add    $0x10,%esp
8010378c:	eb 99                	jmp    80103727 <pipeclose+0x37>
8010378e:	66 90                	xchg   %ax,%ax

80103790 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103790:	55                   	push   %ebp
80103791:	89 e5                	mov    %esp,%ebp
80103793:	57                   	push   %edi
80103794:	56                   	push   %esi
80103795:	53                   	push   %ebx
80103796:	83 ec 28             	sub    $0x28,%esp
80103799:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010379c:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
8010379f:	53                   	push   %ebx
801037a0:	e8 fb 1b 00 00       	call   801053a0 <acquire>
  for(i = 0; i < n; i++){
801037a5:	83 c4 10             	add    $0x10,%esp
801037a8:	85 ff                	test   %edi,%edi
801037aa:	0f 8e ce 00 00 00    	jle    8010387e <pipewrite+0xee>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037b0:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801037b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801037b9:	89 7d 10             	mov    %edi,0x10(%ebp)
801037bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801037bf:	8d 34 39             	lea    (%ecx,%edi,1),%esi
801037c2:	89 75 e0             	mov    %esi,-0x20(%ebp)
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801037c5:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037cb:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d1:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037d7:	8d 90 00 02 00 00    	lea    0x200(%eax),%edx
801037dd:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
801037e0:	0f 85 b6 00 00 00    	jne    8010389c <pipewrite+0x10c>
801037e6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801037e9:	eb 3b                	jmp    80103826 <pipewrite+0x96>
801037eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801037ef:	90                   	nop
      if(p->readopen == 0 || myproc()->killed){
801037f0:	e8 fb 04 00 00       	call   80103cf0 <myproc>
801037f5:	8b 48 28             	mov    0x28(%eax),%ecx
801037f8:	85 c9                	test   %ecx,%ecx
801037fa:	75 34                	jne    80103830 <pipewrite+0xa0>
      wakeup(&p->nread);
801037fc:	83 ec 0c             	sub    $0xc,%esp
801037ff:	56                   	push   %esi
80103800:	e8 bb 0b 00 00       	call   801043c0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103805:	58                   	pop    %eax
80103806:	5a                   	pop    %edx
80103807:	53                   	push   %ebx
80103808:	57                   	push   %edi
80103809:	e8 f2 0a 00 00       	call   80104300 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010380e:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103814:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010381a:	83 c4 10             	add    $0x10,%esp
8010381d:	05 00 02 00 00       	add    $0x200,%eax
80103822:	39 c2                	cmp    %eax,%edx
80103824:	75 2a                	jne    80103850 <pipewrite+0xc0>
      if(p->readopen == 0 || myproc()->killed){
80103826:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
8010382c:	85 c0                	test   %eax,%eax
8010382e:	75 c0                	jne    801037f0 <pipewrite+0x60>
        release(&p->lock);
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	53                   	push   %ebx
80103834:	e8 07 1b 00 00       	call   80105340 <release>
        return -1;
80103839:	83 c4 10             	add    $0x10,%esp
8010383c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103841:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103844:	5b                   	pop    %ebx
80103845:	5e                   	pop    %esi
80103846:	5f                   	pop    %edi
80103847:	5d                   	pop    %ebp
80103848:	c3                   	ret
80103849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103850:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103853:	8d 42 01             	lea    0x1(%edx),%eax
80103856:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  for(i = 0; i < n; i++){
8010385c:	83 c1 01             	add    $0x1,%ecx
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010385f:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103865:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103868:	0f b6 41 ff          	movzbl -0x1(%ecx),%eax
8010386c:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103870:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103873:	39 c1                	cmp    %eax,%ecx
80103875:	0f 85 50 ff ff ff    	jne    801037cb <pipewrite+0x3b>
8010387b:	8b 7d 10             	mov    0x10(%ebp),%edi
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010387e:	83 ec 0c             	sub    $0xc,%esp
80103881:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103887:	50                   	push   %eax
80103888:	e8 33 0b 00 00       	call   801043c0 <wakeup>
  release(&p->lock);
8010388d:	89 1c 24             	mov    %ebx,(%esp)
80103890:	e8 ab 1a 00 00       	call   80105340 <release>
  return n;
80103895:	83 c4 10             	add    $0x10,%esp
80103898:	89 f8                	mov    %edi,%eax
8010389a:	eb a5                	jmp    80103841 <pipewrite+0xb1>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010389c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010389f:	eb b2                	jmp    80103853 <pipewrite+0xc3>
801038a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038af:	90                   	nop

801038b0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801038b0:	55                   	push   %ebp
801038b1:	89 e5                	mov    %esp,%ebp
801038b3:	57                   	push   %edi
801038b4:	56                   	push   %esi
801038b5:	53                   	push   %ebx
801038b6:	83 ec 18             	sub    $0x18,%esp
801038b9:	8b 75 08             	mov    0x8(%ebp),%esi
801038bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801038bf:	56                   	push   %esi
801038c0:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801038c6:	e8 d5 1a 00 00       	call   801053a0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038cb:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801038d1:	83 c4 10             	add    $0x10,%esp
801038d4:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
801038da:	74 2f                	je     8010390b <piperead+0x5b>
801038dc:	eb 37                	jmp    80103915 <piperead+0x65>
801038de:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
801038e0:	e8 0b 04 00 00       	call   80103cf0 <myproc>
801038e5:	8b 40 28             	mov    0x28(%eax),%eax
801038e8:	85 c0                	test   %eax,%eax
801038ea:	0f 85 80 00 00 00    	jne    80103970 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038f0:	83 ec 08             	sub    $0x8,%esp
801038f3:	56                   	push   %esi
801038f4:	53                   	push   %ebx
801038f5:	e8 06 0a 00 00       	call   80104300 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038fa:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103900:	83 c4 10             	add    $0x10,%esp
80103903:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80103909:	75 0a                	jne    80103915 <piperead+0x65>
8010390b:	8b 96 40 02 00 00    	mov    0x240(%esi),%edx
80103911:	85 d2                	test   %edx,%edx
80103913:	75 cb                	jne    801038e0 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103915:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103918:	31 db                	xor    %ebx,%ebx
8010391a:	85 c9                	test   %ecx,%ecx
8010391c:	7f 26                	jg     80103944 <piperead+0x94>
8010391e:	eb 2c                	jmp    8010394c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103920:	8d 48 01             	lea    0x1(%eax),%ecx
80103923:	25 ff 01 00 00       	and    $0x1ff,%eax
80103928:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
8010392e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103933:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103936:	83 c3 01             	add    $0x1,%ebx
80103939:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010393c:	74 0e                	je     8010394c <piperead+0x9c>
8010393e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
    if(p->nread == p->nwrite)
80103944:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010394a:	75 d4                	jne    80103920 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010394c:	83 ec 0c             	sub    $0xc,%esp
8010394f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103955:	50                   	push   %eax
80103956:	e8 65 0a 00 00       	call   801043c0 <wakeup>
  release(&p->lock);
8010395b:	89 34 24             	mov    %esi,(%esp)
8010395e:	e8 dd 19 00 00       	call   80105340 <release>
  return i;
80103963:	83 c4 10             	add    $0x10,%esp
}
80103966:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103969:	89 d8                	mov    %ebx,%eax
8010396b:	5b                   	pop    %ebx
8010396c:	5e                   	pop    %esi
8010396d:	5f                   	pop    %edi
8010396e:	5d                   	pop    %ebp
8010396f:	c3                   	ret
      release(&p->lock);
80103970:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103973:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103978:	56                   	push   %esi
80103979:	e8 c2 19 00 00       	call   80105340 <release>
      return -1;
8010397e:	83 c4 10             	add    $0x10,%esp
}
80103981:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103984:	89 d8                	mov    %ebx,%eax
80103986:	5b                   	pop    %ebx
80103987:	5e                   	pop    %esi
80103988:	5f                   	pop    %edi
80103989:	5d                   	pop    %ebp
8010398a:	c3                   	ret
8010398b:	66 90                	xchg   %ax,%ax
8010398d:	66 90                	xchg   %ax,%ax
8010398f:	90                   	nop

80103990 <allocproc>:
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc *
allocproc(void)
{
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103994:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
{
80103999:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010399c:	68 00 11 1c 80       	push   $0x801c1100
801039a1:	e8 fa 19 00 00       	call   801053a0 <acquire>
801039a6:	83 c4 10             	add    $0x10,%esp
801039a9:	eb 10                	jmp    801039bb <allocproc+0x2b>
801039ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801039af:	90                   	nop
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801039b0:	83 eb 80             	sub    $0xffffff80,%ebx
801039b3:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
801039b9:	74 75                	je     80103a30 <allocproc+0xa0>
    if (p->state == UNUSED)
801039bb:	8b 43 10             	mov    0x10(%ebx),%eax
801039be:	85 c0                	test   %eax,%eax
801039c0:	75 ee                	jne    801039b0 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
801039c2:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
801039c7:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
801039ca:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->pid = nextpid++;
801039d1:	89 43 14             	mov    %eax,0x14(%ebx)
801039d4:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
801039d7:	68 00 11 1c 80       	push   $0x801c1100
  p->pid = nextpid++;
801039dc:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
801039e2:	e8 59 19 00 00       	call   80105340 <release>

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
801039e7:	e8 b4 ed ff ff       	call   801027a0 <kalloc>
801039ec:	83 c4 10             	add    $0x10,%esp
801039ef:	89 43 0c             	mov    %eax,0xc(%ebx)
801039f2:	85 c0                	test   %eax,%eax
801039f4:	74 53                	je     80103a49 <allocproc+0xb9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801039f6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint *)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context *)sp;
  memset(p->context, 0, sizeof *p->context);
801039fc:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
801039ff:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103a04:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint *)sp = (uint)trapret;
80103a07:	c7 40 14 72 66 10 80 	movl   $0x80106672,0x14(%eax)
  p->context = (struct context *)sp;
80103a0e:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103a11:	6a 14                	push   $0x14
80103a13:	6a 00                	push   $0x0
80103a15:	50                   	push   %eax
80103a16:	e8 85 1a 00 00       	call   801054a0 <memset>
  p->context->eip = (uint)forkret;
80103a1b:	8b 43 20             	mov    0x20(%ebx),%eax

  return p;
80103a1e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103a21:	c7 40 10 60 3a 10 80 	movl   $0x80103a60,0x10(%eax)
}
80103a28:	89 d8                	mov    %ebx,%eax
80103a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a2d:	c9                   	leave
80103a2e:	c3                   	ret
80103a2f:	90                   	nop
  release(&ptable.lock);
80103a30:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103a33:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103a35:	68 00 11 1c 80       	push   $0x801c1100
80103a3a:	e8 01 19 00 00       	call   80105340 <release>
  return 0;
80103a3f:	83 c4 10             	add    $0x10,%esp
}
80103a42:	89 d8                	mov    %ebx,%eax
80103a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a47:	c9                   	leave
80103a48:	c3                   	ret
    p->state = UNUSED;
80103a49:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
  return 0;
80103a50:	31 db                	xor    %ebx,%ebx
80103a52:	eb ee                	jmp    80103a42 <allocproc+0xb2>
80103a54:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103a5f:	90                   	nop

80103a60 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
80103a60:	55                   	push   %ebp
80103a61:	89 e5                	mov    %esp,%ebp
80103a63:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103a66:	68 00 11 1c 80       	push   $0x801c1100
80103a6b:	e8 d0 18 00 00       	call   80105340 <release>

  if (first)
80103a70:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103a75:	83 c4 10             	add    $0x10,%esp
80103a78:	85 c0                	test   %eax,%eax
80103a7a:	75 04                	jne    80103a80 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103a7c:	c9                   	leave
80103a7d:	c3                   	ret
80103a7e:	66 90                	xchg   %ax,%ax
    first = 0;
80103a80:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103a87:	00 00 00 
    iinit(ROOTDEV);
80103a8a:	83 ec 0c             	sub    $0xc,%esp
80103a8d:	6a 01                	push   $0x1
80103a8f:	e8 1c dc ff ff       	call   801016b0 <iinit>
    initlog(ROOTDEV);
80103a94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103a9b:	e8 e0 f3 ff ff       	call   80102e80 <initlog>
}
80103aa0:	83 c4 10             	add    $0x10,%esp
80103aa3:	c9                   	leave
80103aa4:	c3                   	ret
80103aa5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103ab0 <initrmap>:
{
80103ab0:	55                   	push   %ebp
80103ab1:	b8 38 33 13 80       	mov    $0x80133338,%eax
80103ab6:	89 e5                	mov    %esp,%ebp
80103ab8:	53                   	push   %ebx
80103ab9:	83 ec 04             	sub    $0x4,%esp
80103abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    rmap[i].refcount = 0;
80103ac0:	c7 80 fc fd ff ff 00 	movl   $0x0,-0x204(%eax)
80103ac7:	00 00 00 
    for (uint j = 0; j < NPROC; j++)
80103aca:	8d 98 00 ff ff ff    	lea    -0x100(%eax),%ebx
      rmap[i].present_id[j] = 0;
80103ad0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    for (uint j = 0; j < NPROC; j++)
80103ad6:	83 c3 08             	add    $0x8,%ebx
      rmap[i].present_id[j] = 0;
80103ad9:	c7 43 fc 00 00 00 00 	movl   $0x0,-0x4(%ebx)
    for (uint j = 0; j < NPROC; j++)
80103ae0:	39 c3                	cmp    %eax,%ebx
80103ae2:	75 ec                	jne    80103ad0 <initrmap+0x20>
    initlock(&rmap[i].lock, "rmap");
80103ae4:	83 ec 08             	sub    $0x8,%esp
80103ae7:	8d 83 c8 fd ff ff    	lea    -0x238(%ebx),%eax
80103aed:	68 9e 84 10 80       	push   $0x8010849e
80103af2:	50                   	push   %eax
80103af3:	e8 b8 16 00 00       	call   801051b0 <initlock>
  for (uint i = 0; i < (PHYSTOP / PGSIZE); i++)
80103af8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103afe:	83 c4 10             	add    $0x10,%esp
80103b01:	81 fb 00 11 1c 80    	cmp    $0x801c1100,%ebx
80103b07:	75 b7                	jne    80103ac0 <initrmap+0x10>
}
80103b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b0c:	c9                   	leave
80103b0d:	c3                   	ret
80103b0e:	66 90                	xchg   %ax,%ax

80103b10 <check_rmap>:
{
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
  return (rmap[pgnum].refcount == 1);
80103b13:	69 45 08 38 02 00 00 	imul   $0x238,0x8(%ebp),%eax
}
80103b1a:	5d                   	pop    %ebp
  return (rmap[pgnum].refcount == 1);
80103b1b:	83 b8 34 31 13 80 01 	cmpl   $0x1,-0x7feccecc(%eax)
80103b22:	0f 94 c0             	sete   %al
80103b25:	0f b6 c0             	movzbl %al,%eax
}
80103b28:	c3                   	ret
80103b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103b30 <inc_sharing>:
{
80103b30:	55                   	push   %ebp
80103b31:	89 e5                	mov    %esp,%ebp
80103b33:	56                   	push   %esi
80103b34:	53                   	push   %ebx
80103b35:	8b 75 0c             	mov    0xc(%ebp),%esi
80103b38:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(page_num==73)cprintf("Increasing %d %d %d\n",pte,*pte,page_num);
80103b3b:	83 fe 49             	cmp    $0x49,%esi
80103b3e:	74 50                	je     80103b90 <inc_sharing+0x60>
  rmap[page_num].refcount++;
80103b40:	69 d6 38 02 00 00    	imul   $0x238,%esi,%edx
  for (uint i = 0; i < NPROC; i++)
80103b46:	31 c0                	xor    %eax,%eax
  rmap[page_num].refcount++;
80103b48:	83 82 34 31 13 80 01 	addl   $0x1,-0x7feccecc(%edx)
  for (uint i = 0; i < NPROC; i++)
80103b4f:	eb 0f                	jmp    80103b60 <inc_sharing+0x30>
80103b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b58:	83 c0 01             	add    $0x1,%eax
80103b5b:	83 f8 40             	cmp    $0x40,%eax
80103b5e:	74 25                	je     80103b85 <inc_sharing+0x55>
    if (!rmap[page_num].present_id[i])
80103b60:	8b 8c 82 38 32 13 80 	mov    -0x7feccdc8(%edx,%eax,4),%ecx
80103b67:	85 c9                	test   %ecx,%ecx
80103b69:	75 ed                	jne    80103b58 <inc_sharing+0x28>
      rmap[page_num].present_id[i] = 1;
80103b6b:	69 f6 8e 00 00 00    	imul   $0x8e,%esi,%esi
80103b71:	01 c6                	add    %eax,%esi
80103b73:	c7 04 b5 38 32 13 80 	movl   $0x1,-0x7feccdc8(,%esi,4)
80103b7a:	01 00 00 00 
      rmap[page_num].pte_id[i] = pte;
80103b7e:	89 1c b5 38 31 13 80 	mov    %ebx,-0x7feccec8(,%esi,4)
}
80103b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b88:	5b                   	pop    %ebx
80103b89:	5e                   	pop    %esi
80103b8a:	5d                   	pop    %ebp
80103b8b:	c3                   	ret
80103b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(page_num==73)cprintf("Increasing %d %d %d\n",pte,*pte,page_num);
80103b90:	6a 49                	push   $0x49
80103b92:	ff 33                	push   (%ebx)
80103b94:	53                   	push   %ebx
80103b95:	68 a3 84 10 80       	push   $0x801084a3
80103b9a:	e8 41 cc ff ff       	call   801007e0 <cprintf>
80103b9f:	83 c4 10             	add    $0x10,%esp
80103ba2:	eb 9c                	jmp    80103b40 <inc_sharing+0x10>
80103ba4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103bab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103baf:	90                   	nop

80103bb0 <dec_sharing>:
{
80103bb0:	55                   	push   %ebp
80103bb1:	89 e5                	mov    %esp,%ebp
80103bb3:	56                   	push   %esi
80103bb4:	53                   	push   %ebx
80103bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
80103bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(page_num==73)cprintf("Decreasing %d %d %d\n",pte,*pte,page_num);
80103bbb:	83 fe 49             	cmp    $0x49,%esi
80103bbe:	74 6d                	je     80103c2d <dec_sharing+0x7d>
  rmap[page_num].refcount--;
80103bc0:	69 d6 38 02 00 00    	imul   $0x238,%esi,%edx
  for (uint i = 0; i < NPROC; i++)
80103bc6:	31 c0                	xor    %eax,%eax
  rmap[page_num].refcount--;
80103bc8:	8b 8a 34 31 13 80    	mov    -0x7feccecc(%edx),%ecx
80103bce:	83 e9 01             	sub    $0x1,%ecx
80103bd1:	89 8a 34 31 13 80    	mov    %ecx,-0x7feccecc(%edx)
  for (uint i = 0; i < NPROC; i++)
80103bd7:	eb 0f                	jmp    80103be8 <dec_sharing+0x38>
80103bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103be0:	83 c0 01             	add    $0x1,%eax
80103be3:	83 f8 40             	cmp    $0x40,%eax
80103be6:	74 38                	je     80103c20 <dec_sharing+0x70>
    if (rmap[page_num].present_id[i] && rmap[page_num].pte_id[i] == pte)
80103be8:	83 bc 82 38 32 13 80 	cmpl   $0x0,-0x7feccdc8(%edx,%eax,4)
80103bef:	00 
80103bf0:	74 ee                	je     80103be0 <dec_sharing+0x30>
80103bf2:	39 9c 82 38 31 13 80 	cmp    %ebx,-0x7feccec8(%edx,%eax,4)
80103bf9:	75 e5                	jne    80103be0 <dec_sharing+0x30>
      rmap[page_num].present_id[i] = 0;
80103bfb:	69 f6 8e 00 00 00    	imul   $0x8e,%esi,%esi
80103c01:	8d 44 30 4c          	lea    0x4c(%eax,%esi,1),%eax
80103c05:	c7 04 85 08 31 13 80 	movl   $0x0,-0x7feccef8(,%eax,4)
80103c0c:	00 00 00 00 
  if (rmap[page_num].refcount == 0)
80103c10:	31 c0                	xor    %eax,%eax
80103c12:	85 c9                	test   %ecx,%ecx
80103c14:	0f 94 c0             	sete   %al
}
80103c17:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c1a:	5b                   	pop    %ebx
80103c1b:	5e                   	pop    %esi
80103c1c:	5d                   	pop    %ebp
80103c1d:	c3                   	ret
80103c1e:	66 90                	xchg   %ax,%ax
    panic("Trying to reduce refrence of page which is not refrenced");
80103c20:	83 ec 0c             	sub    $0xc,%esp
80103c23:	68 a4 88 10 80       	push   $0x801088a4
80103c28:	e8 83 c8 ff ff       	call   801004b0 <panic>
  if(page_num==73)cprintf("Decreasing %d %d %d\n",pte,*pte,page_num);
80103c2d:	6a 49                	push   $0x49
80103c2f:	ff 33                	push   (%ebx)
80103c31:	53                   	push   %ebx
80103c32:	68 b8 84 10 80       	push   $0x801084b8
80103c37:	e8 a4 cb ff ff       	call   801007e0 <cprintf>
80103c3c:	83 c4 10             	add    $0x10,%esp
80103c3f:	e9 7c ff ff ff       	jmp    80103bc0 <dec_sharing+0x10>
80103c44:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103c4f:	90                   	nop

80103c50 <pinit>:
{
80103c50:	55                   	push   %ebp
80103c51:	89 e5                	mov    %esp,%ebp
80103c53:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103c56:	68 cd 84 10 80       	push   $0x801084cd
80103c5b:	68 00 11 1c 80       	push   $0x801c1100
80103c60:	e8 4b 15 00 00       	call   801051b0 <initlock>
}
80103c65:	83 c4 10             	add    $0x10,%esp
80103c68:	c9                   	leave
80103c69:	c3                   	ret
80103c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103c70 <mycpu>:
{
80103c70:	55                   	push   %ebp
80103c71:	89 e5                	mov    %esp,%ebp
80103c73:	56                   	push   %esi
80103c74:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c75:	9c                   	pushf
80103c76:	58                   	pop    %eax
  if (readeflags() & FL_IF)
80103c77:	f6 c4 02             	test   $0x2,%ah
80103c7a:	75 46                	jne    80103cc2 <mycpu+0x52>
  apicid = lapicid();
80103c7c:	e8 2f ee ff ff       	call   80102ab0 <lapicid>
  for (i = 0; i < ncpu; ++i)
80103c81:	8b 35 c4 27 11 80    	mov    0x801127c4,%esi
80103c87:	85 f6                	test   %esi,%esi
80103c89:	7e 2a                	jle    80103cb5 <mycpu+0x45>
80103c8b:	31 d2                	xor    %edx,%edx
80103c8d:	eb 08                	jmp    80103c97 <mycpu+0x27>
80103c8f:	90                   	nop
80103c90:	83 c2 01             	add    $0x1,%edx
80103c93:	39 f2                	cmp    %esi,%edx
80103c95:	74 1e                	je     80103cb5 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103c97:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103c9d:	0f b6 99 e0 27 11 80 	movzbl -0x7feed820(%ecx),%ebx
80103ca4:	39 c3                	cmp    %eax,%ebx
80103ca6:	75 e8                	jne    80103c90 <mycpu+0x20>
}
80103ca8:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103cab:	8d 81 e0 27 11 80    	lea    -0x7feed820(%ecx),%eax
}
80103cb1:	5b                   	pop    %ebx
80103cb2:	5e                   	pop    %esi
80103cb3:	5d                   	pop    %ebp
80103cb4:	c3                   	ret
  panic("unknown apicid\n");
80103cb5:	83 ec 0c             	sub    $0xc,%esp
80103cb8:	68 d4 84 10 80       	push   $0x801084d4
80103cbd:	e8 ee c7 ff ff       	call   801004b0 <panic>
    panic("mycpu called with interrupts enabled\n");
80103cc2:	83 ec 0c             	sub    $0xc,%esp
80103cc5:	68 e0 88 10 80       	push   $0x801088e0
80103cca:	e8 e1 c7 ff ff       	call   801004b0 <panic>
80103ccf:	90                   	nop

80103cd0 <cpuid>:
{
80103cd0:	55                   	push   %ebp
80103cd1:	89 e5                	mov    %esp,%ebp
80103cd3:	83 ec 08             	sub    $0x8,%esp
  return mycpu() - cpus;
80103cd6:	e8 95 ff ff ff       	call   80103c70 <mycpu>
}
80103cdb:	c9                   	leave
  return mycpu() - cpus;
80103cdc:	2d e0 27 11 80       	sub    $0x801127e0,%eax
80103ce1:	c1 f8 04             	sar    $0x4,%eax
80103ce4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103cea:	c3                   	ret
80103ceb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103cef:	90                   	nop

80103cf0 <myproc>:
{
80103cf0:	55                   	push   %ebp
80103cf1:	89 e5                	mov    %esp,%ebp
80103cf3:	53                   	push   %ebx
80103cf4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103cf7:	e8 54 15 00 00       	call   80105250 <pushcli>
  c = mycpu();
80103cfc:	e8 6f ff ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80103d01:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103d07:	e8 94 15 00 00       	call   801052a0 <popcli>
}
80103d0c:	89 d8                	mov    %ebx,%eax
80103d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d11:	c9                   	leave
80103d12:	c3                   	ret
80103d13:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103d1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103d20 <userinit>:
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	53                   	push   %ebx
80103d24:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103d27:	e8 64 fc ff ff       	call   80103990 <allocproc>
80103d2c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103d2e:	a3 34 31 1c 80       	mov    %eax,0x801c3134
  if ((p->pgdir = setupkvm()) == 0)
80103d33:	e8 08 41 00 00       	call   80107e40 <setupkvm>
80103d38:	89 43 08             	mov    %eax,0x8(%ebx)
80103d3b:	85 c0                	test   %eax,%eax
80103d3d:	0f 84 bd 00 00 00    	je     80103e00 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d43:	83 ec 04             	sub    $0x4,%esp
80103d46:	68 2c 00 00 00       	push   $0x2c
80103d4b:	68 60 b4 10 80       	push   $0x8010b460
80103d50:	50                   	push   %eax
80103d51:	e8 2a 3d 00 00       	call   80107a80 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103d56:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103d59:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103d5f:	6a 4c                	push   $0x4c
80103d61:	6a 00                	push   $0x0
80103d63:	ff 73 1c             	push   0x1c(%ebx)
80103d66:	e8 35 17 00 00       	call   801054a0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d6b:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d6e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103d73:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d76:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d7b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d7f:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d82:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d86:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d89:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103d8d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d91:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d94:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103d98:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103d9c:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d9f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103da6:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103da9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0; // beginning of initcode.S
80103db0:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103db3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dba:	8d 43 70             	lea    0x70(%ebx),%eax
80103dbd:	6a 10                	push   $0x10
80103dbf:	68 fd 84 10 80       	push   $0x801084fd
80103dc4:	50                   	push   %eax
80103dc5:	e8 86 18 00 00       	call   80105650 <safestrcpy>
  p->cwd = namei("/");
80103dca:	c7 04 24 06 85 10 80 	movl   $0x80108506,(%esp)
80103dd1:	e8 da e3 ff ff       	call   801021b0 <namei>
80103dd6:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
80103dd9:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
80103de0:	e8 bb 15 00 00       	call   801053a0 <acquire>
  p->state = RUNNABLE;
80103de5:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
80103dec:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
80103df3:	e8 48 15 00 00       	call   80105340 <release>
}
80103df8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dfb:	83 c4 10             	add    $0x10,%esp
80103dfe:	c9                   	leave
80103dff:	c3                   	ret
    panic("userinit: out of memory?");
80103e00:	83 ec 0c             	sub    $0xc,%esp
80103e03:	68 e4 84 10 80       	push   $0x801084e4
80103e08:	e8 a3 c6 ff ff       	call   801004b0 <panic>
80103e0d:	8d 76 00             	lea    0x0(%esi),%esi

80103e10 <growproc>:
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	56                   	push   %esi
80103e14:	53                   	push   %ebx
80103e15:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103e18:	e8 33 14 00 00       	call   80105250 <pushcli>
  c = mycpu();
80103e1d:	e8 4e fe ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80103e22:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103e28:	e8 73 14 00 00       	call   801052a0 <popcli>
  sz = curproc->sz;
80103e2d:	8b 03                	mov    (%ebx),%eax
  if (n > 0)
80103e2f:	85 f6                	test   %esi,%esi
80103e31:	7f 1d                	jg     80103e50 <growproc+0x40>
  else if (n < 0)
80103e33:	75 3b                	jne    80103e70 <growproc+0x60>
  switchuvm(curproc);
80103e35:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103e38:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103e3a:	53                   	push   %ebx
80103e3b:	e8 30 3b 00 00       	call   80107970 <switchuvm>
  return 0;
80103e40:	83 c4 10             	add    $0x10,%esp
80103e43:	31 c0                	xor    %eax,%eax
}
80103e45:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e48:	5b                   	pop    %ebx
80103e49:	5e                   	pop    %esi
80103e4a:	5d                   	pop    %ebp
80103e4b:	c3                   	ret
80103e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e50:	83 ec 04             	sub    $0x4,%esp
80103e53:	01 c6                	add    %eax,%esi
80103e55:	56                   	push   %esi
80103e56:	50                   	push   %eax
80103e57:	ff 73 08             	push   0x8(%ebx)
80103e5a:	e8 91 3d 00 00       	call   80107bf0 <allocuvm>
80103e5f:	83 c4 10             	add    $0x10,%esp
80103e62:	85 c0                	test   %eax,%eax
80103e64:	75 cf                	jne    80103e35 <growproc+0x25>
      return -1;
80103e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e6b:	eb d8                	jmp    80103e45 <growproc+0x35>
80103e6d:	8d 76 00             	lea    0x0(%esi),%esi
    if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e70:	83 ec 04             	sub    $0x4,%esp
80103e73:	01 c6                	add    %eax,%esi
80103e75:	56                   	push   %esi
80103e76:	50                   	push   %eax
80103e77:	ff 73 08             	push   0x8(%ebx)
80103e7a:	e8 e1 3e 00 00       	call   80107d60 <deallocuvm>
80103e7f:	83 c4 10             	add    $0x10,%esp
80103e82:	85 c0                	test   %eax,%eax
80103e84:	75 af                	jne    80103e35 <growproc+0x25>
80103e86:	eb de                	jmp    80103e66 <growproc+0x56>
80103e88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e8f:	90                   	nop

80103e90 <fork>:
{
80103e90:	55                   	push   %ebp
80103e91:	89 e5                	mov    %esp,%ebp
80103e93:	57                   	push   %edi
80103e94:	56                   	push   %esi
80103e95:	53                   	push   %ebx
80103e96:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103e99:	e8 b2 13 00 00       	call   80105250 <pushcli>
  c = mycpu();
80103e9e:	e8 cd fd ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80103ea3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103ea9:	e8 f2 13 00 00       	call   801052a0 <popcli>
  if ((np = allocproc()) == 0)
80103eae:	e8 dd fa ff ff       	call   80103990 <allocproc>
80103eb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103eb6:	85 c0                	test   %eax,%eax
80103eb8:	0f 84 de 00 00 00    	je     80103f9c <fork+0x10c>
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, np)) == 0)
80103ebe:	83 ec 04             	sub    $0x4,%esp
80103ec1:	89 c7                	mov    %eax,%edi
80103ec3:	50                   	push   %eax
80103ec4:	ff 33                	push   (%ebx)
80103ec6:	ff 73 08             	push   0x8(%ebx)
80103ec9:	e8 e2 40 00 00       	call   80107fb0 <copyuvm>
80103ece:	83 c4 10             	add    $0x10,%esp
80103ed1:	89 47 08             	mov    %eax,0x8(%edi)
80103ed4:	85 c0                	test   %eax,%eax
80103ed6:	0f 84 a1 00 00 00    	je     80103f7d <fork+0xed>
  np->sz = curproc->sz;
80103edc:	8b 03                	mov    (%ebx),%eax
80103ede:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103ee1:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103ee3:	8b 79 1c             	mov    0x1c(%ecx),%edi
  np->parent = curproc;
80103ee6:	89 c8                	mov    %ecx,%eax
80103ee8:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
80103eeb:	b9 13 00 00 00       	mov    $0x13,%ecx
80103ef0:	8b 73 1c             	mov    0x1c(%ebx),%esi
80103ef3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for (i = 0; i < NOFILE; i++)
80103ef5:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103ef7:	8b 40 1c             	mov    0x1c(%eax),%eax
80103efa:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for (i = 0; i < NOFILE; i++)
80103f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if (curproc->ofile[i])
80103f08:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
80103f0c:	85 c0                	test   %eax,%eax
80103f0e:	74 13                	je     80103f23 <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103f10:	83 ec 0c             	sub    $0xc,%esp
80103f13:	50                   	push   %eax
80103f14:	e8 d7 d0 ff ff       	call   80100ff0 <filedup>
80103f19:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f1c:	83 c4 10             	add    $0x10,%esp
80103f1f:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
  for (i = 0; i < NOFILE; i++)
80103f23:	83 c6 01             	add    $0x1,%esi
80103f26:	83 fe 10             	cmp    $0x10,%esi
80103f29:	75 dd                	jne    80103f08 <fork+0x78>
  np->cwd = idup(curproc->cwd);
80103f2b:	83 ec 0c             	sub    $0xc,%esp
80103f2e:	ff 73 6c             	push   0x6c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f31:	83 c3 70             	add    $0x70,%ebx
  np->cwd = idup(curproc->cwd);
80103f34:	e8 67 d9 ff ff       	call   801018a0 <idup>
80103f39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f3c:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103f3f:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f42:	8d 47 70             	lea    0x70(%edi),%eax
80103f45:	6a 10                	push   $0x10
80103f47:	53                   	push   %ebx
80103f48:	50                   	push   %eax
80103f49:	e8 02 17 00 00       	call   80105650 <safestrcpy>
  pid = np->pid;
80103f4e:	8b 5f 14             	mov    0x14(%edi),%ebx
  acquire(&ptable.lock);
80103f51:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
80103f58:	e8 43 14 00 00       	call   801053a0 <acquire>
  np->state = RUNNABLE;
80103f5d:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  release(&ptable.lock);
80103f64:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
80103f6b:	e8 d0 13 00 00       	call   80105340 <release>
  return pid;
80103f70:	83 c4 10             	add    $0x10,%esp
}
80103f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f76:	89 d8                	mov    %ebx,%eax
80103f78:	5b                   	pop    %ebx
80103f79:	5e                   	pop    %esi
80103f7a:	5f                   	pop    %edi
80103f7b:	5d                   	pop    %ebp
80103f7c:	c3                   	ret
    kfree(np->kstack);
80103f7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103f80:	83 ec 0c             	sub    $0xc,%esp
80103f83:	ff 73 0c             	push   0xc(%ebx)
80103f86:	e8 45 e6 ff ff       	call   801025d0 <kfree>
    np->kstack = 0;
80103f8b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103f92:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103f95:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
80103f9c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103fa1:	eb d0                	jmp    80103f73 <fork+0xe3>
80103fa3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103faa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103fb0 <print_rss>:
{
80103fb0:	55                   	push   %ebp
80103fb1:	89 e5                	mov    %esp,%ebp
80103fb3:	53                   	push   %ebx
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fb4:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
{
80103fb9:	83 ec 10             	sub    $0x10,%esp
  cprintf("PrintingRSS\n");
80103fbc:	68 08 85 10 80       	push   $0x80108508
80103fc1:	e8 1a c8 ff ff       	call   801007e0 <cprintf>
  acquire(&ptable.lock);
80103fc6:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
80103fcd:	e8 ce 13 00 00       	call   801053a0 <acquire>
80103fd2:	83 c4 10             	add    $0x10,%esp
80103fd5:	8d 76 00             	lea    0x0(%esi),%esi
    if ((p->state == UNUSED))
80103fd8:	8b 43 10             	mov    0x10(%ebx),%eax
80103fdb:	85 c0                	test   %eax,%eax
80103fdd:	74 14                	je     80103ff3 <print_rss+0x43>
    cprintf("((P)) id: %d, state: %d, rss: %d\n", p->pid, p->state, p->rss);
80103fdf:	ff 73 04             	push   0x4(%ebx)
80103fe2:	50                   	push   %eax
80103fe3:	ff 73 14             	push   0x14(%ebx)
80103fe6:	68 08 89 10 80       	push   $0x80108908
80103feb:	e8 f0 c7 ff ff       	call   801007e0 <cprintf>
80103ff0:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ff3:	83 eb 80             	sub    $0xffffff80,%ebx
80103ff6:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
80103ffc:	75 da                	jne    80103fd8 <print_rss+0x28>
  release(&ptable.lock);
80103ffe:	83 ec 0c             	sub    $0xc,%esp
80104001:	68 00 11 1c 80       	push   $0x801c1100
80104006:	e8 35 13 00 00       	call   80105340 <release>
}
8010400b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010400e:	83 c4 10             	add    $0x10,%esp
80104011:	c9                   	leave
80104012:	c3                   	ret
80104013:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010401a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104020 <scheduler>:
{
80104020:	55                   	push   %ebp
80104021:	89 e5                	mov    %esp,%ebp
80104023:	57                   	push   %edi
80104024:	56                   	push   %esi
80104025:	53                   	push   %ebx
80104026:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80104029:	e8 42 fc ff ff       	call   80103c70 <mycpu>
  c->proc = 0;
8010402e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104035:	00 00 00 
  struct cpu *c = mycpu();
80104038:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010403a:	8d 78 04             	lea    0x4(%eax),%edi
8010403d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80104040:	fb                   	sti
    acquire(&ptable.lock);
80104041:	83 ec 0c             	sub    $0xc,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104044:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
    acquire(&ptable.lock);
80104049:	68 00 11 1c 80       	push   $0x801c1100
8010404e:	e8 4d 13 00 00       	call   801053a0 <acquire>
80104053:	83 c4 10             	add    $0x10,%esp
80104056:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010405d:	8d 76 00             	lea    0x0(%esi),%esi
      if (p->state != RUNNABLE)
80104060:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
80104064:	75 33                	jne    80104099 <scheduler+0x79>
      switchuvm(p);
80104066:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80104069:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010406f:	53                   	push   %ebx
80104070:	e8 fb 38 00 00       	call   80107970 <switchuvm>
      swtch(&(c->scheduler), p->context);
80104075:	58                   	pop    %eax
80104076:	5a                   	pop    %edx
80104077:	ff 73 20             	push   0x20(%ebx)
8010407a:	57                   	push   %edi
      p->state = RUNNING;
8010407b:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
80104082:	e8 24 16 00 00       	call   801056ab <swtch>
      switchkvm();
80104087:	e8 d4 38 00 00       	call   80107960 <switchkvm>
      c->proc = 0;
8010408c:	83 c4 10             	add    $0x10,%esp
8010408f:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80104096:	00 00 00 
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104099:	83 eb 80             	sub    $0xffffff80,%ebx
8010409c:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
801040a2:	75 bc                	jne    80104060 <scheduler+0x40>
    release(&ptable.lock);
801040a4:	83 ec 0c             	sub    $0xc,%esp
801040a7:	68 00 11 1c 80       	push   $0x801c1100
801040ac:	e8 8f 12 00 00       	call   80105340 <release>
    sti();
801040b1:	83 c4 10             	add    $0x10,%esp
801040b4:	eb 8a                	jmp    80104040 <scheduler+0x20>
801040b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040bd:	8d 76 00             	lea    0x0(%esi),%esi

801040c0 <sched>:
{
801040c0:	55                   	push   %ebp
801040c1:	89 e5                	mov    %esp,%ebp
801040c3:	56                   	push   %esi
801040c4:	53                   	push   %ebx
  pushcli();
801040c5:	e8 86 11 00 00       	call   80105250 <pushcli>
  c = mycpu();
801040ca:	e8 a1 fb ff ff       	call   80103c70 <mycpu>
  p = c->proc;
801040cf:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801040d5:	e8 c6 11 00 00       	call   801052a0 <popcli>
  if (!holding(&ptable.lock))
801040da:	83 ec 0c             	sub    $0xc,%esp
801040dd:	68 00 11 1c 80       	push   $0x801c1100
801040e2:	e8 19 12 00 00       	call   80105300 <holding>
801040e7:	83 c4 10             	add    $0x10,%esp
801040ea:	85 c0                	test   %eax,%eax
801040ec:	74 4f                	je     8010413d <sched+0x7d>
  if (mycpu()->ncli != 1)
801040ee:	e8 7d fb ff ff       	call   80103c70 <mycpu>
801040f3:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801040fa:	75 68                	jne    80104164 <sched+0xa4>
  if (p->state == RUNNING)
801040fc:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
80104100:	74 55                	je     80104157 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104102:	9c                   	pushf
80104103:	58                   	pop    %eax
  if (readeflags() & FL_IF)
80104104:	f6 c4 02             	test   $0x2,%ah
80104107:	75 41                	jne    8010414a <sched+0x8a>
  intena = mycpu()->intena;
80104109:	e8 62 fb ff ff       	call   80103c70 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
8010410e:	83 c3 20             	add    $0x20,%ebx
  intena = mycpu()->intena;
80104111:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80104117:	e8 54 fb ff ff       	call   80103c70 <mycpu>
8010411c:	83 ec 08             	sub    $0x8,%esp
8010411f:	ff 70 04             	push   0x4(%eax)
80104122:	53                   	push   %ebx
80104123:	e8 83 15 00 00       	call   801056ab <swtch>
  mycpu()->intena = intena;
80104128:	e8 43 fb ff ff       	call   80103c70 <mycpu>
}
8010412d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104130:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80104136:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104139:	5b                   	pop    %ebx
8010413a:	5e                   	pop    %esi
8010413b:	5d                   	pop    %ebp
8010413c:	c3                   	ret
    panic("sched ptable.lock");
8010413d:	83 ec 0c             	sub    $0xc,%esp
80104140:	68 15 85 10 80       	push   $0x80108515
80104145:	e8 66 c3 ff ff       	call   801004b0 <panic>
    panic("sched interruptible");
8010414a:	83 ec 0c             	sub    $0xc,%esp
8010414d:	68 41 85 10 80       	push   $0x80108541
80104152:	e8 59 c3 ff ff       	call   801004b0 <panic>
    panic("sched running");
80104157:	83 ec 0c             	sub    $0xc,%esp
8010415a:	68 33 85 10 80       	push   $0x80108533
8010415f:	e8 4c c3 ff ff       	call   801004b0 <panic>
    panic("sched locks");
80104164:	83 ec 0c             	sub    $0xc,%esp
80104167:	68 27 85 10 80       	push   $0x80108527
8010416c:	e8 3f c3 ff ff       	call   801004b0 <panic>
80104171:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104178:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010417f:	90                   	nop

80104180 <exit>:
{
80104180:	55                   	push   %ebp
80104181:	89 e5                	mov    %esp,%ebp
80104183:	57                   	push   %edi
80104184:	56                   	push   %esi
80104185:	53                   	push   %ebx
80104186:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80104189:	e8 62 fb ff ff       	call   80103cf0 <myproc>
  if (curproc == initproc)
8010418e:	39 05 34 31 1c 80    	cmp    %eax,0x801c3134
80104194:	0f 84 fd 00 00 00    	je     80104297 <exit+0x117>
8010419a:	89 c3                	mov    %eax,%ebx
8010419c:	8d 70 2c             	lea    0x2c(%eax),%esi
8010419f:	8d 78 6c             	lea    0x6c(%eax),%edi
801041a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if (curproc->ofile[fd])
801041a8:	8b 06                	mov    (%esi),%eax
801041aa:	85 c0                	test   %eax,%eax
801041ac:	74 12                	je     801041c0 <exit+0x40>
      fileclose(curproc->ofile[fd]);
801041ae:	83 ec 0c             	sub    $0xc,%esp
801041b1:	50                   	push   %eax
801041b2:	e8 89 ce ff ff       	call   80101040 <fileclose>
      curproc->ofile[fd] = 0;
801041b7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801041bd:	83 c4 10             	add    $0x10,%esp
  for (fd = 0; fd < NOFILE; fd++)
801041c0:	83 c6 04             	add    $0x4,%esi
801041c3:	39 f7                	cmp    %esi,%edi
801041c5:	75 e1                	jne    801041a8 <exit+0x28>
  begin_op();
801041c7:	e8 54 ed ff ff       	call   80102f20 <begin_op>
  iput(curproc->cwd);
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	ff 73 6c             	push   0x6c(%ebx)
801041d2:	e8 29 d8 ff ff       	call   80101a00 <iput>
  end_op();
801041d7:	e8 b4 ed ff ff       	call   80102f90 <end_op>
  curproc->cwd = 0;
801041dc:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)
  acquire(&ptable.lock);
801041e3:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
801041ea:	e8 b1 11 00 00       	call   801053a0 <acquire>
  wakeup1(curproc->parent);
801041ef:	8b 53 18             	mov    0x18(%ebx),%edx
801041f2:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041f5:	b8 34 11 1c 80       	mov    $0x801c1134,%eax
801041fa:	eb 0e                	jmp    8010420a <exit+0x8a>
801041fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104200:	83 e8 80             	sub    $0xffffff80,%eax
80104203:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
80104208:	74 1c                	je     80104226 <exit+0xa6>
    if (p->state == SLEEPING && p->chan == chan)
8010420a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010420e:	75 f0                	jne    80104200 <exit+0x80>
80104210:	3b 50 24             	cmp    0x24(%eax),%edx
80104213:	75 eb                	jne    80104200 <exit+0x80>
      p->state = RUNNABLE;
80104215:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010421c:	83 e8 80             	sub    $0xffffff80,%eax
8010421f:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
80104224:	75 e4                	jne    8010420a <exit+0x8a>
      p->parent = initproc;
80104226:	8b 0d 34 31 1c 80    	mov    0x801c3134,%ecx
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010422c:	ba 34 11 1c 80       	mov    $0x801c1134,%edx
80104231:	eb 10                	jmp    80104243 <exit+0xc3>
80104233:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104237:	90                   	nop
80104238:	83 ea 80             	sub    $0xffffff80,%edx
8010423b:	81 fa 34 31 1c 80    	cmp    $0x801c3134,%edx
80104241:	74 3b                	je     8010427e <exit+0xfe>
    if (p->parent == curproc)
80104243:	39 5a 18             	cmp    %ebx,0x18(%edx)
80104246:	75 f0                	jne    80104238 <exit+0xb8>
      if (p->state == ZOMBIE)
80104248:	83 7a 10 05          	cmpl   $0x5,0x10(%edx)
      p->parent = initproc;
8010424c:	89 4a 18             	mov    %ecx,0x18(%edx)
      if (p->state == ZOMBIE)
8010424f:	75 e7                	jne    80104238 <exit+0xb8>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104251:	b8 34 11 1c 80       	mov    $0x801c1134,%eax
80104256:	eb 12                	jmp    8010426a <exit+0xea>
80104258:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010425f:	90                   	nop
80104260:	83 e8 80             	sub    $0xffffff80,%eax
80104263:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
80104268:	74 ce                	je     80104238 <exit+0xb8>
    if (p->state == SLEEPING && p->chan == chan)
8010426a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010426e:	75 f0                	jne    80104260 <exit+0xe0>
80104270:	3b 48 24             	cmp    0x24(%eax),%ecx
80104273:	75 eb                	jne    80104260 <exit+0xe0>
      p->state = RUNNABLE;
80104275:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
8010427c:	eb e2                	jmp    80104260 <exit+0xe0>
  curproc->state = ZOMBIE;
8010427e:	c7 43 10 05 00 00 00 	movl   $0x5,0x10(%ebx)
  sched();
80104285:	e8 36 fe ff ff       	call   801040c0 <sched>
  panic("zombie exit");
8010428a:	83 ec 0c             	sub    $0xc,%esp
8010428d:	68 62 85 10 80       	push   $0x80108562
80104292:	e8 19 c2 ff ff       	call   801004b0 <panic>
    panic("init exiting");
80104297:	83 ec 0c             	sub    $0xc,%esp
8010429a:	68 55 85 10 80       	push   $0x80108555
8010429f:	e8 0c c2 ff ff       	call   801004b0 <panic>
801042a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801042ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801042af:	90                   	nop

801042b0 <yield>:
{
801042b0:	55                   	push   %ebp
801042b1:	89 e5                	mov    %esp,%ebp
801042b3:	53                   	push   %ebx
801042b4:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock); // DOC: yieldlock
801042b7:	68 00 11 1c 80       	push   $0x801c1100
801042bc:	e8 df 10 00 00       	call   801053a0 <acquire>
  pushcli();
801042c1:	e8 8a 0f 00 00       	call   80105250 <pushcli>
  c = mycpu();
801042c6:	e8 a5 f9 ff ff       	call   80103c70 <mycpu>
  p = c->proc;
801042cb:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801042d1:	e8 ca 0f 00 00       	call   801052a0 <popcli>
  myproc()->state = RUNNABLE;
801042d6:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  sched();
801042dd:	e8 de fd ff ff       	call   801040c0 <sched>
  release(&ptable.lock);
801042e2:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
801042e9:	e8 52 10 00 00       	call   80105340 <release>
}
801042ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042f1:	83 c4 10             	add    $0x10,%esp
801042f4:	c9                   	leave
801042f5:	c3                   	ret
801042f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801042fd:	8d 76 00             	lea    0x0(%esi),%esi

80104300 <sleep>:
{
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	57                   	push   %edi
80104304:	56                   	push   %esi
80104305:	53                   	push   %ebx
80104306:	83 ec 0c             	sub    $0xc,%esp
80104309:	8b 7d 08             	mov    0x8(%ebp),%edi
8010430c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
8010430f:	e8 3c 0f 00 00       	call   80105250 <pushcli>
  c = mycpu();
80104314:	e8 57 f9 ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80104319:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010431f:	e8 7c 0f 00 00       	call   801052a0 <popcli>
  if (p == 0)
80104324:	85 db                	test   %ebx,%ebx
80104326:	0f 84 87 00 00 00    	je     801043b3 <sleep+0xb3>
  if (lk == 0)
8010432c:	85 f6                	test   %esi,%esi
8010432e:	74 76                	je     801043a6 <sleep+0xa6>
  if (lk != &ptable.lock)
80104330:	81 fe 00 11 1c 80    	cmp    $0x801c1100,%esi
80104336:	74 50                	je     80104388 <sleep+0x88>
    acquire(&ptable.lock); // DOC: sleeplock1
80104338:	83 ec 0c             	sub    $0xc,%esp
8010433b:	68 00 11 1c 80       	push   $0x801c1100
80104340:	e8 5b 10 00 00       	call   801053a0 <acquire>
    release(lk);
80104345:	89 34 24             	mov    %esi,(%esp)
80104348:	e8 f3 0f 00 00       	call   80105340 <release>
  p->chan = chan;
8010434d:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
80104350:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104357:	e8 64 fd ff ff       	call   801040c0 <sched>
  p->chan = 0;
8010435c:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
    release(&ptable.lock);
80104363:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
8010436a:	e8 d1 0f 00 00       	call   80105340 <release>
    acquire(lk);
8010436f:	89 75 08             	mov    %esi,0x8(%ebp)
80104372:	83 c4 10             	add    $0x10,%esp
}
80104375:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104378:	5b                   	pop    %ebx
80104379:	5e                   	pop    %esi
8010437a:	5f                   	pop    %edi
8010437b:	5d                   	pop    %ebp
    acquire(lk);
8010437c:	e9 1f 10 00 00       	jmp    801053a0 <acquire>
80104381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104388:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
8010438b:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104392:	e8 29 fd ff ff       	call   801040c0 <sched>
  p->chan = 0;
80104397:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
8010439e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043a1:	5b                   	pop    %ebx
801043a2:	5e                   	pop    %esi
801043a3:	5f                   	pop    %edi
801043a4:	5d                   	pop    %ebp
801043a5:	c3                   	ret
    panic("sleep without lk");
801043a6:	83 ec 0c             	sub    $0xc,%esp
801043a9:	68 74 85 10 80       	push   $0x80108574
801043ae:	e8 fd c0 ff ff       	call   801004b0 <panic>
    panic("sleep");
801043b3:	83 ec 0c             	sub    $0xc,%esp
801043b6:	68 6e 85 10 80       	push   $0x8010856e
801043bb:	e8 f0 c0 ff ff       	call   801004b0 <panic>

801043c0 <wakeup>:
}

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	53                   	push   %ebx
801043c4:	83 ec 10             	sub    $0x10,%esp
801043c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
801043ca:	68 00 11 1c 80       	push   $0x801c1100
801043cf:	e8 cc 0f 00 00       	call   801053a0 <acquire>
801043d4:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043d7:	b8 34 11 1c 80       	mov    $0x801c1134,%eax
801043dc:	eb 0c                	jmp    801043ea <wakeup+0x2a>
801043de:	66 90                	xchg   %ax,%ax
801043e0:	83 e8 80             	sub    $0xffffff80,%eax
801043e3:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
801043e8:	74 1c                	je     80104406 <wakeup+0x46>
    if (p->state == SLEEPING && p->chan == chan)
801043ea:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801043ee:	75 f0                	jne    801043e0 <wakeup+0x20>
801043f0:	3b 58 24             	cmp    0x24(%eax),%ebx
801043f3:	75 eb                	jne    801043e0 <wakeup+0x20>
      p->state = RUNNABLE;
801043f5:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043fc:	83 e8 80             	sub    $0xffffff80,%eax
801043ff:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
80104404:	75 e4                	jne    801043ea <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80104406:	c7 45 08 00 11 1c 80 	movl   $0x801c1100,0x8(%ebp)
}
8010440d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104410:	c9                   	leave
  release(&ptable.lock);
80104411:	e9 2a 0f 00 00       	jmp    80105340 <release>
80104416:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010441d:	8d 76 00             	lea    0x0(%esi),%esi

80104420 <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
80104420:	55                   	push   %ebp
80104421:	89 e5                	mov    %esp,%ebp
80104423:	53                   	push   %ebx
80104424:	83 ec 10             	sub    $0x10,%esp
80104427:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010442a:	68 00 11 1c 80       	push   $0x801c1100
8010442f:	e8 6c 0f 00 00       	call   801053a0 <acquire>
80104434:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104437:	b8 34 11 1c 80       	mov    $0x801c1134,%eax
8010443c:	eb 0c                	jmp    8010444a <kill+0x2a>
8010443e:	66 90                	xchg   %ax,%ax
80104440:	83 e8 80             	sub    $0xffffff80,%eax
80104443:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
80104448:	74 36                	je     80104480 <kill+0x60>
  {
    if (p->pid == pid)
8010444a:	39 58 14             	cmp    %ebx,0x14(%eax)
8010444d:	75 f1                	jne    80104440 <kill+0x20>
    {
      p->killed = 1;
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
8010444f:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
      p->killed = 1;
80104453:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if (p->state == SLEEPING)
8010445a:	75 07                	jne    80104463 <kill+0x43>
        p->state = RUNNABLE;
8010445c:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
80104463:	83 ec 0c             	sub    $0xc,%esp
80104466:	68 00 11 1c 80       	push   $0x801c1100
8010446b:	e8 d0 0e 00 00       	call   80105340 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104473:	83 c4 10             	add    $0x10,%esp
80104476:	31 c0                	xor    %eax,%eax
}
80104478:	c9                   	leave
80104479:	c3                   	ret
8010447a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80104480:	83 ec 0c             	sub    $0xc,%esp
80104483:	68 00 11 1c 80       	push   $0x801c1100
80104488:	e8 b3 0e 00 00       	call   80105340 <release>
}
8010448d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104490:	83 c4 10             	add    $0x10,%esp
80104493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104498:	c9                   	leave
80104499:	c3                   	ret
8010449a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801044a0 <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	57                   	push   %edi
801044a4:	56                   	push   %esi
801044a5:	8d 75 e8             	lea    -0x18(%ebp),%esi
801044a8:	53                   	push   %ebx
801044a9:	bb a4 11 1c 80       	mov    $0x801c11a4,%ebx
801044ae:	83 ec 3c             	sub    $0x3c,%esp
801044b1:	eb 24                	jmp    801044d7 <procdump+0x37>
801044b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801044b7:	90                   	nop
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
      for (i = 0; i < 10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801044b8:	83 ec 0c             	sub    $0xc,%esp
801044bb:	68 82 87 10 80       	push   $0x80108782
801044c0:	e8 1b c3 ff ff       	call   801007e0 <cprintf>
801044c5:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044c8:	83 eb 80             	sub    $0xffffff80,%ebx
801044cb:	81 fb a4 31 1c 80    	cmp    $0x801c31a4,%ebx
801044d1:	0f 84 81 00 00 00    	je     80104558 <procdump+0xb8>
    if (p->state == UNUSED)
801044d7:	8b 43 a0             	mov    -0x60(%ebx),%eax
801044da:	85 c0                	test   %eax,%eax
801044dc:	74 ea                	je     801044c8 <procdump+0x28>
      state = "???";
801044de:	ba 85 85 10 80       	mov    $0x80108585,%edx
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044e3:	83 f8 05             	cmp    $0x5,%eax
801044e6:	77 11                	ja     801044f9 <procdump+0x59>
801044e8:	8b 14 85 a0 8c 10 80 	mov    -0x7fef7360(,%eax,4),%edx
      state = "???";
801044ef:	b8 85 85 10 80       	mov    $0x80108585,%eax
801044f4:	85 d2                	test   %edx,%edx
801044f6:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
801044f9:	53                   	push   %ebx
801044fa:	52                   	push   %edx
801044fb:	ff 73 a4             	push   -0x5c(%ebx)
801044fe:	68 89 85 10 80       	push   $0x80108589
80104503:	e8 d8 c2 ff ff       	call   801007e0 <cprintf>
    if (p->state == SLEEPING)
80104508:	83 c4 10             	add    $0x10,%esp
8010450b:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
8010450f:	75 a7                	jne    801044b8 <procdump+0x18>
      getcallerpcs((uint *)p->context->ebp + 2, pc);
80104511:	83 ec 08             	sub    $0x8,%esp
80104514:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104517:	8d 7d c0             	lea    -0x40(%ebp),%edi
8010451a:	50                   	push   %eax
8010451b:	8b 43 b0             	mov    -0x50(%ebx),%eax
8010451e:	8b 40 0c             	mov    0xc(%eax),%eax
80104521:	83 c0 08             	add    $0x8,%eax
80104524:	50                   	push   %eax
80104525:	e8 a6 0c 00 00       	call   801051d0 <getcallerpcs>
      for (i = 0; i < 10 && pc[i] != 0; i++)
8010452a:	83 c4 10             	add    $0x10,%esp
8010452d:	8d 76 00             	lea    0x0(%esi),%esi
80104530:	8b 17                	mov    (%edi),%edx
80104532:	85 d2                	test   %edx,%edx
80104534:	74 82                	je     801044b8 <procdump+0x18>
        cprintf(" %p", pc[i]);
80104536:	83 ec 08             	sub    $0x8,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104539:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
8010453c:	52                   	push   %edx
8010453d:	68 61 82 10 80       	push   $0x80108261
80104542:	e8 99 c2 ff ff       	call   801007e0 <cprintf>
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104547:	83 c4 10             	add    $0x10,%esp
8010454a:	39 f7                	cmp    %esi,%edi
8010454c:	75 e2                	jne    80104530 <procdump+0x90>
8010454e:	e9 65 ff ff ff       	jmp    801044b8 <procdump+0x18>
80104553:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104557:	90                   	nop
  }
}
80104558:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010455b:	5b                   	pop    %ebx
8010455c:	5e                   	pop    %esi
8010455d:	5f                   	pop    %edi
8010455e:	5d                   	pop    %ebp
8010455f:	c3                   	ret

80104560 <select_victim_process>:

struct proc *
select_victim_process(void)
{
80104560:	55                   	push   %ebp
80104561:	89 e5                	mov    %esp,%ebp
80104563:	56                   	push   %esi
80104564:	53                   	push   %ebx
  pushcli();
80104565:	e8 e6 0c 00 00       	call   80105250 <pushcli>
  c = mycpu();
8010456a:	e8 01 f7 ff ff       	call   80103c70 <mycpu>
  p = c->proc;
8010456f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104575:	e8 26 0d 00 00       	call   801052a0 <popcli>
  struct proc *victim_proc;
  victim_proc = myproc();
  maximum = victim_proc->rss;
  int id = victim_proc->pid;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010457a:	b8 34 11 1c 80       	mov    $0x801c1134,%eax
  maximum = victim_proc->rss;
8010457f:	8b 4e 04             	mov    0x4(%esi),%ecx
  int id = victim_proc->pid;
80104582:	8b 5e 14             	mov    0x14(%esi),%ebx
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104585:	eb 1a                	jmp    801045a1 <select_victim_process+0x41>
80104587:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010458e:	66 90                	xchg   %ax,%ax
  {
    if (maximum < p->rss)
    {
      maximum = p->rss;
      victim_proc = p;
      id = p->pid;
80104590:	8b 58 14             	mov    0x14(%eax),%ebx
      maximum = p->rss;
80104593:	89 d1                	mov    %edx,%ecx
      victim_proc = p;
80104595:	89 c6                	mov    %eax,%esi
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104597:	83 e8 80             	sub    $0xffffff80,%eax
8010459a:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
8010459f:	74 20                	je     801045c1 <select_victim_process+0x61>
    if (maximum < p->rss)
801045a1:	8b 50 04             	mov    0x4(%eax),%edx
801045a4:	39 d1                	cmp    %edx,%ecx
801045a6:	72 e8                	jb     80104590 <select_victim_process+0x30>
    }
    else if (maximum == p->rss)
801045a8:	39 ca                	cmp    %ecx,%edx
801045aa:	75 eb                	jne    80104597 <select_victim_process+0x37>
    {
      if (p->pid < id)
801045ac:	8b 50 14             	mov    0x14(%eax),%edx
801045af:	39 d3                	cmp    %edx,%ebx
801045b1:	7e e4                	jle    80104597 <select_victim_process+0x37>
      {
        victim_proc = p;
801045b3:	89 c6                	mov    %eax,%esi
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045b5:	83 e8 80             	sub    $0xffffff80,%eax
        id = p->pid;
801045b8:	89 d3                	mov    %edx,%ebx
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045ba:	3d 34 31 1c 80       	cmp    $0x801c3134,%eax
801045bf:	75 e0                	jne    801045a1 <select_victim_process+0x41>
      }
    }
  }
  // release(&ptable.lock);
  return victim_proc;
}
801045c1:	89 f0                	mov    %esi,%eax
801045c3:	5b                   	pop    %ebx
801045c4:	5e                   	pop    %esi
801045c5:	5d                   	pop    %ebp
801045c6:	c3                   	ret
801045c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045ce:	66 90                	xchg   %ax,%ax

801045d0 <find_pte_swap_out>:
  }
  return &pgtab[PTX(va)];
}

void find_pte_swap_out(struct proc *p, pte_t *pte_orig, int idx)
{
801045d0:	55                   	push   %ebp
801045d1:	89 e5                	mov    %esp,%ebp
801045d3:	57                   	push   %edi
801045d4:	56                   	push   %esi
801045d5:	53                   	push   %ebx
801045d6:	83 ec 1c             	sub    $0x1c,%esp
801045d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801045dc:	8b 45 10             	mov    0x10(%ebp),%eax
801045df:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint sz = p->sz;
801045e2:	8b 19                	mov    (%ecx),%ebx
  pde_t *pgdir = p->pgdir;
801045e4:	8b 71 08             	mov    0x8(%ecx),%esi
{
801045e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pte_t *pte;
  uint i;
  // uint pa = PTE_ADDR(*pte_orig);
  for (i = 0; i < sz; i += PGSIZE)
801045ea:	85 db                	test   %ebx,%ebx
801045ec:	74 55                	je     80104643 <find_pte_swap_out+0x73>
801045ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801045f1:	31 c0                	xor    %eax,%eax
801045f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801045f7:	90                   	nop
  pde = &pgdir[PDX(va)];
801045f8:	89 c2                	mov    %eax,%edx
801045fa:	c1 ea 16             	shr    $0x16,%edx
  if (*pde & PTE_P)
801045fd:	8b 14 96             	mov    (%esi,%edx,4),%edx
80104600:	f6 c2 01             	test   $0x1,%dl
80104603:	75 13                	jne    80104618 <find_pte_swap_out+0x48>
  {
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
      panic("find_pte_swap_out: pte should exist");
80104605:	83 ec 0c             	sub    $0xc,%esp
80104608:	68 2c 89 10 80       	push   $0x8010892c
8010460d:	e8 9e be ff ff       	call   801004b0 <panic>
80104612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80104618:	89 c1                	mov    %eax,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
8010461a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80104620:	c1 e9 0a             	shr    $0xa,%ecx
80104623:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
80104629:	8d 94 0a 00 00 00 80 	lea    -0x80000000(%edx,%ecx,1),%edx
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
80104630:	85 d2                	test   %edx,%edx
80104632:	74 d1                	je     80104605 <find_pte_swap_out+0x35>
    if (*pte == *pte_orig)
80104634:	8b 0f                	mov    (%edi),%ecx
80104636:	39 0a                	cmp    %ecx,(%edx)
80104638:	74 16                	je     80104650 <find_pte_swap_out+0x80>
  for (i = 0; i < sz; i += PGSIZE)
8010463a:	05 00 10 00 00       	add    $0x1000,%eax
8010463f:	39 d8                	cmp    %ebx,%eax
80104641:	72 b5                	jb     801045f8 <find_pte_swap_out+0x28>
      if(PTE_ADDR(*pte) / PGSIZE == 73) cprintf("In swap out %d %d\n",pte,*pte);
      dec_sharing(pte, PTE_ADDR(*pte) / PGSIZE);
      return;
    }
  }
}
80104643:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104646:	5b                   	pop    %ebx
80104647:	5e                   	pop    %esi
80104648:	5f                   	pop    %edi
80104649:	5d                   	pop    %ebp
8010464a:	c3                   	ret
8010464b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010464f:	90                   	nop
      swaparray[idx].proc_id[swaparray[idx].cnt] = p;
80104650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104653:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80104656:	69 d8 10 02 00 00    	imul   $0x210,%eax,%ebx
8010465c:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
80104662:	81 c3 60 2d 11 80    	add    $0x80112d60,%ebx
80104668:	8b b3 0c 02 00 00    	mov    0x20c(%ebx),%esi
8010466e:	01 f0                	add    %esi,%eax
      swaparray[idx].cnt += 1;
80104670:	83 c6 01             	add    $0x1,%esi
      swaparray[idx].proc_id[swaparray[idx].cnt] = p;
80104673:	89 0c 85 6c 2e 11 80 	mov    %ecx,-0x7feed194(,%eax,4)
      swaparray[idx].pte_id[swaparray[idx].cnt] = pte;
8010467a:	89 14 85 6c 2d 11 80 	mov    %edx,-0x7feed294(,%eax,4)
      swaparray[idx].cnt += 1;
80104681:	89 b3 0c 02 00 00    	mov    %esi,0x20c(%ebx)
      p->rss -= PGSIZE;
80104687:	81 69 04 00 10 00 00 	subl   $0x1000,0x4(%ecx)
      if(PTE_ADDR(*pte) / PGSIZE == 73) cprintf("In swap out %d %d\n",pte,*pte);
8010468e:	8b 0a                	mov    (%edx),%ecx
80104690:	89 c8                	mov    %ecx,%eax
80104692:	c1 e8 0c             	shr    $0xc,%eax
80104695:	83 f8 49             	cmp    $0x49,%eax
80104698:	74 12                	je     801046ac <find_pte_swap_out+0xdc>
      dec_sharing(pte, PTE_ADDR(*pte) / PGSIZE);
8010469a:	89 45 0c             	mov    %eax,0xc(%ebp)
8010469d:	89 55 08             	mov    %edx,0x8(%ebp)
}
801046a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046a3:	5b                   	pop    %ebx
801046a4:	5e                   	pop    %esi
801046a5:	5f                   	pop    %edi
801046a6:	5d                   	pop    %ebp
      dec_sharing(pte, PTE_ADDR(*pte) / PGSIZE);
801046a7:	e9 04 f5 ff ff       	jmp    80103bb0 <dec_sharing>
      if(PTE_ADDR(*pte) / PGSIZE == 73) cprintf("In swap out %d %d\n",pte,*pte);
801046ac:	83 ec 04             	sub    $0x4,%esp
801046af:	51                   	push   %ecx
801046b0:	52                   	push   %edx
801046b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801046b4:	68 92 85 10 80       	push   $0x80108592
801046b9:	e8 22 c1 ff ff       	call   801007e0 <cprintf>
      dec_sharing(pte, PTE_ADDR(*pte) / PGSIZE);
801046be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046c1:	83 c4 10             	add    $0x10,%esp
801046c4:	8b 02                	mov    (%edx),%eax
801046c6:	c1 e8 0c             	shr    $0xc,%eax
801046c9:	eb cf                	jmp    8010469a <find_pte_swap_out+0xca>
801046cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801046cf:	90                   	nop

801046d0 <find_pte_swap_in>:

void find_pte_swap_in(struct proc *p, pte_t *pte_orig, char *mem)
{
801046d0:	55                   	push   %ebp
801046d1:	89 e5                	mov    %esp,%ebp
801046d3:	57                   	push   %edi
801046d4:	56                   	push   %esi
801046d5:	53                   	push   %ebx
801046d6:	83 ec 1c             	sub    $0x1c,%esp
801046d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046dc:	8b 45 10             	mov    0x10(%ebp),%eax
801046df:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint sz = p->sz;
801046e2:	8b 19                	mov    (%ecx),%ebx
  pde_t *pgdir = p->pgdir;
801046e4:	8b 71 08             	mov    0x8(%ecx),%esi
{
801046e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pte_t *pte;
  // uint pa = V2P(mem);
  uint i;
  for (i = 0; i < sz; i += PGSIZE)
801046ea:	85 db                	test   %ebx,%ebx
801046ec:	74 55                	je     80104743 <find_pte_swap_in+0x73>
801046ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801046f1:	31 c0                	xor    %eax,%eax
801046f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801046f7:	90                   	nop
  pde = &pgdir[PDX(va)];
801046f8:	89 c2                	mov    %eax,%edx
801046fa:	c1 ea 16             	shr    $0x16,%edx
  if (*pde & PTE_P)
801046fd:	8b 14 96             	mov    (%esi,%edx,4),%edx
80104700:	f6 c2 01             	test   $0x1,%dl
80104703:	75 13                	jne    80104718 <find_pte_swap_in+0x48>
  {
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
      panic("find_pte_swap_in: pte should exist");
80104705:	83 ec 0c             	sub    $0xc,%esp
80104708:	68 50 89 10 80       	push   $0x80108950
8010470d:	e8 9e bd ff ff       	call   801004b0 <panic>
80104712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80104718:	89 c1                	mov    %eax,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
8010471a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80104720:	c1 e9 0a             	shr    $0xa,%ecx
80104723:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
80104729:	8d 94 0a 00 00 00 80 	lea    -0x80000000(%edx,%ecx,1),%edx
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
80104730:	85 d2                	test   %edx,%edx
80104732:	74 d1                	je     80104705 <find_pte_swap_in+0x35>
    if (*pte == *pte_orig)
80104734:	8b 0f                	mov    (%edi),%ecx
80104736:	39 0a                	cmp    %ecx,(%edx)
80104738:	74 16                	je     80104750 <find_pte_swap_in+0x80>
  for (i = 0; i < sz; i += PGSIZE)
8010473a:	05 00 10 00 00       	add    $0x1000,%eax
8010473f:	39 d8                	cmp    %ebx,%eax
80104741:	72 b5                	jb     801046f8 <find_pte_swap_in+0x28>
      p->rss += PGSIZE;
      inc_sharing(pte, V2P(mem) / PGSIZE);
      return;
    }
  }
}
80104743:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104746:	5b                   	pop    %ebx
80104747:	5e                   	pop    %esi
80104748:	5f                   	pop    %edi
80104749:	5d                   	pop    %ebp
8010474a:	c3                   	ret
8010474b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010474f:	90                   	nop
      p->rss += PGSIZE;
80104750:	8b 4d e0             	mov    -0x20(%ebp),%ecx
      inc_sharing(pte, V2P(mem) / PGSIZE);
80104753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      p->rss += PGSIZE;
80104756:	81 41 04 00 10 00 00 	addl   $0x1000,0x4(%ecx)
      inc_sharing(pte, V2P(mem) / PGSIZE);
8010475d:	05 00 00 00 80       	add    $0x80000000,%eax
80104762:	c1 e8 0c             	shr    $0xc,%eax
80104765:	89 55 08             	mov    %edx,0x8(%ebp)
80104768:	89 45 0c             	mov    %eax,0xc(%ebp)
}
8010476b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010476e:	5b                   	pop    %ebx
8010476f:	5e                   	pop    %esi
80104770:	5f                   	pop    %edi
80104771:	5d                   	pop    %ebp
      inc_sharing(pte, V2P(mem) / PGSIZE);
80104772:	e9 b9 f3 ff ff       	jmp    80103b30 <inc_sharing>
80104777:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010477e:	66 90                	xchg   %ax,%ax

80104780 <make_other_pte_swapped_out>:

void make_other_pte_swapped_out(pte_t *pte, int idx)
{
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	57                   	push   %edi
80104784:	56                   	push   %esi
80104785:	53                   	push   %ebx
  struct proc *p;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104786:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
{
8010478b:	83 ec 0c             	sub    $0xc,%esp
8010478e:	8b 7d 08             	mov    0x8(%ebp),%edi
80104791:	8b 75 0c             	mov    0xc(%ebp),%esi
80104794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  {
    if ((p->state == UNUSED)) continue;
80104798:	8b 43 10             	mov    0x10(%ebx),%eax
8010479b:	85 c0                	test   %eax,%eax
8010479d:	74 0e                	je     801047ad <make_other_pte_swapped_out+0x2d>
    find_pte_swap_out(p, pte, idx);
8010479f:	83 ec 04             	sub    $0x4,%esp
801047a2:	56                   	push   %esi
801047a3:	57                   	push   %edi
801047a4:	53                   	push   %ebx
801047a5:	e8 26 fe ff ff       	call   801045d0 <find_pte_swap_out>
801047aa:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047ad:	83 eb 80             	sub    $0xffffff80,%ebx
801047b0:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
801047b6:	75 e0                	jne    80104798 <make_other_pte_swapped_out+0x18>
    
  }
  // release(&ptable.lock);
}
801047b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047bb:	5b                   	pop    %ebx
801047bc:	5e                   	pop    %esi
801047bd:	5f                   	pop    %edi
801047be:	5d                   	pop    %ebp
801047bf:	c3                   	ret

801047c0 <make_other_pte_swapped_in>:

void make_other_pte_swapped_in(pte_t *pte, char *mem)
{
801047c0:	55                   	push   %ebp
801047c1:	89 e5                	mov    %esp,%ebp
801047c3:	57                   	push   %edi
801047c4:	56                   	push   %esi
801047c5:	53                   	push   %ebx
  // struct proc *p;
  // uint pa = PTE_ADDR(*pte);
  struct proc *p;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047c6:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
{
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	8b 7d 08             	mov    0x8(%ebp),%edi
801047d1:	8b 75 0c             	mov    0xc(%ebp),%esi
801047d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  {
    // if (!(p->state & UNUSED))
    {
      find_pte_swap_in(p, pte, mem);
801047d8:	83 ec 04             	sub    $0x4,%esp
801047db:	56                   	push   %esi
801047dc:	57                   	push   %edi
801047dd:	53                   	push   %ebx
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047de:	83 eb 80             	sub    $0xffffff80,%ebx
      find_pte_swap_in(p, pte, mem);
801047e1:	e8 ea fe ff ff       	call   801046d0 <find_pte_swap_in>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047e6:	83 c4 10             	add    $0x10,%esp
801047e9:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
801047ef:	75 e7                	jne    801047d8 <make_other_pte_swapped_in+0x18>
    }
  }
  // release(&ptable.lock);
}
801047f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047f4:	5b                   	pop    %ebx
801047f5:	5e                   	pop    %esi
801047f6:	5f                   	pop    %edi
801047f7:	5d                   	pop    %ebp
801047f8:	c3                   	ret
801047f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104800 <xint>:

uint xint(uint x)
{
80104800:	55                   	push   %ebp
80104801:	89 e5                	mov    %esp,%ebp
  a[0] = x;
  a[1] = x >> 8;
  a[2] = x >> 16;
  a[3] = x >> 24;
  return y;
}
80104803:	8b 45 08             	mov    0x8(%ebp),%eax
80104806:	5d                   	pop    %ebp
80104807:	c3                   	ret
80104808:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010480f:	90                   	nop

80104810 <initswap>:

void initswap()
{
  int j = 0;
  for (int i = 0; i < SWAPBLOCKS; i += 8)
80104810:	b8 60 2d 11 80       	mov    $0x80112d60,%eax
{
80104815:	ba 02 00 00 00       	mov    $0x2,%edx
8010481a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  {
    swaparray[j].is_free = 1;
    swaparray[j].start = xint(2) + i;
80104820:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < SWAPBLOCKS; i += 8)
80104822:	05 10 02 00 00       	add    $0x210,%eax
80104827:	83 c2 08             	add    $0x8,%edx
    swaparray[j].is_free = 1;
8010482a:	c7 80 f8 fd ff ff 01 	movl   $0x1,-0x208(%eax)
80104831:	00 00 00 
    swaparray[j].cnt = 0;
80104834:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
  for (int i = 0; i < SWAPBLOCKS; i += 8)
8010483b:	3d 00 31 13 80       	cmp    $0x80133100,%eax
80104840:	75 de                	jne    80104820 <initswap+0x10>
    j += 1;
  }
}
80104842:	c3                   	ret
80104843:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010484a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104850 <make_acces_bit_0>:

void make_acces_bit_0(pte_t* pte_orig){
80104850:	55                   	push   %ebp
80104851:	89 e5                	mov    %esp,%ebp
80104853:	57                   	push   %edi
  struct proc *p;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104854:	bf 34 11 1c 80       	mov    $0x801c1134,%edi
void make_acces_bit_0(pte_t* pte_orig){
80104859:	56                   	push   %esi
8010485a:	53                   	push   %ebx
8010485b:	83 ec 1c             	sub    $0x1c,%esp
8010485e:	8b 75 08             	mov    0x8(%ebp),%esi
80104861:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  {
    // if (p->state == UNUSED) continue
     uint sz = p->sz;
80104868:	8b 0f                	mov    (%edi),%ecx
    pde_t *pgdir = p->pgdir;
8010486a:	8b 5f 08             	mov    0x8(%edi),%ebx
    pte_t *pte;
    uint i;
    for (i = 0; i < sz; i += PGSIZE)
8010486d:	85 c9                	test   %ecx,%ecx
8010486f:	74 62                	je     801048d3 <make_acces_bit_0+0x83>
80104871:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80104874:	31 c0                	xor    %eax,%eax
80104876:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010487d:	8d 76 00             	lea    0x0(%esi),%esi
  pde = &pgdir[PDX(va)];
80104880:	89 c2                	mov    %eax,%edx
80104882:	c1 ea 16             	shr    $0x16,%edx
  if (*pde & PTE_P)
80104885:	8b 14 93             	mov    (%ebx,%edx,4),%edx
80104888:	f6 c2 01             	test   $0x1,%dl
8010488b:	75 13                	jne    801048a0 <make_acces_bit_0+0x50>
    {
      if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
        panic("find_pte_swap_in: pte should exist");
8010488d:	83 ec 0c             	sub    $0xc,%esp
80104890:	68 50 89 10 80       	push   $0x80108950
80104895:	e8 16 bc ff ff       	call   801004b0 <panic>
8010489a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
801048a0:	89 c7                	mov    %eax,%edi
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
801048a2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
801048a8:	c1 ef 0a             	shr    $0xa,%edi
801048ab:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
801048b1:	8d bc 3a 00 00 00 80 	lea    -0x80000000(%edx,%edi,1),%edi
      if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
801048b8:	85 ff                	test   %edi,%edi
801048ba:	74 d1                	je     8010488d <make_acces_bit_0+0x3d>
      if (*pte == *pte_orig){
801048bc:	8b 17                	mov    (%edi),%edx
801048be:	3b 16                	cmp    (%esi),%edx
801048c0:	75 05                	jne    801048c7 <make_acces_bit_0+0x77>
        *pte &= ~PTE_A;
801048c2:	83 e2 df             	and    $0xffffffdf,%edx
801048c5:	89 17                	mov    %edx,(%edi)
    for (i = 0; i < sz; i += PGSIZE)
801048c7:	05 00 10 00 00       	add    $0x1000,%eax
801048cc:	39 c8                	cmp    %ecx,%eax
801048ce:	72 b0                	jb     80104880 <make_acces_bit_0+0x30>
801048d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048d3:	83 ef 80             	sub    $0xffffff80,%edi
801048d6:	81 ff 34 31 1c 80    	cmp    $0x801c3134,%edi
801048dc:	75 8a                	jne    80104868 <make_acces_bit_0+0x18>
      }
    
    }
  }
}
801048de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048e1:	5b                   	pop    %ebx
801048e2:	5e                   	pop    %esi
801048e3:	5f                   	pop    %edi
801048e4:	5d                   	pop    %ebp
801048e5:	c3                   	ret
801048e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048ed:	8d 76 00             	lea    0x0(%esi),%esi

801048f0 <select_a_victim>:


pte_t *select_a_victim()
{
801048f0:	55                   	push   %ebp
801048f1:	89 e5                	mov    %esp,%ebp
801048f3:	57                   	push   %edi
801048f4:	56                   	push   %esi
801048f5:	53                   	push   %ebx
801048f6:	83 ec 1c             	sub    $0x1c,%esp
  // check for p->rss should be positive
  struct proc *p = select_victim_process();
801048f9:	e8 62 fc ff ff       	call   80104560 <select_victim_process>
  int total = 0;
  // cprintf("Proc id %d\n",p->pid);
  for (int i = 0; i < p->sz; i += PGSIZE)
801048fe:	8b 30                	mov    (%eax),%esi
80104900:	85 f6                	test   %esi,%esi
80104902:	0f 84 61 01 00 00    	je     80104a69 <select_a_victim+0x179>
  int total = 0;
80104908:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  {
    pte_t *pte = walkpgdir(p->pgdir, (void *)i, 0);
8010490f:	8b 48 08             	mov    0x8(%eax),%ecx
80104912:	89 c7                	mov    %eax,%edi
  for (int i = 0; i < p->sz; i += PGSIZE)
80104914:	31 c0                	xor    %eax,%eax
80104916:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010491d:	8d 76 00             	lea    0x0(%esi),%esi
  pde = &pgdir[PDX(va)];
80104920:	89 c2                	mov    %eax,%edx
80104922:	c1 ea 16             	shr    $0x16,%edx
  if (*pde & PTE_P)
80104925:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80104928:	f6 c2 01             	test   $0x1,%dl
8010492b:	0f 84 2e 07 00 00    	je     8010505f <select_a_victim.cold+0x7>
  return &pgtab[PTX(va)];
80104931:	89 c3                	mov    %eax,%ebx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80104933:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80104939:	c1 eb 0a             	shr    $0xa,%ebx
8010493c:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
80104942:	8d 94 1a 00 00 00 80 	lea    -0x80000000(%edx,%ebx,1),%edx
    if (*pte & PTE_P)
80104949:	8b 1a                	mov    (%edx),%ebx
8010494b:	f6 c3 01             	test   $0x1,%bl
8010494e:	74 24                	je     80104974 <select_a_victim+0x84>
    {
      if (!(*pte & PTE_A))
80104950:	83 e3 20             	and    $0x20,%ebx
80104953:	75 1b                	jne    80104970 <select_a_victim+0x80>
      {

        if (p->rss < PGSIZE)
80104955:	81 7f 04 ff 0f 00 00 	cmpl   $0xfff,0x4(%edi)
8010495c:	76 16                	jbe    80104974 <select_a_victim+0x84>
      }
    }
  }

  return 0;
}
8010495e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104961:	89 d0                	mov    %edx,%eax
80104963:	5b                   	pop    %ebx
80104964:	5e                   	pop    %esi
80104965:	5f                   	pop    %edi
80104966:	5d                   	pop    %ebp
80104967:	c3                   	ret
80104968:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010496f:	90                   	nop
        total += 1;
80104970:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  for (int i = 0; i < p->sz; i += PGSIZE)
80104974:	05 00 10 00 00       	add    $0x1000,%eax
80104979:	39 f0                	cmp    %esi,%eax
8010497b:	72 a3                	jb     80104920 <select_a_victim+0x30>
  total = (total + 9) / 10;
8010497d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80104980:	b8 67 66 66 66       	mov    $0x66666667,%eax
80104985:	83 c3 09             	add    $0x9,%ebx
80104988:	f7 eb                	imul   %ebx
8010498a:	c1 fb 1f             	sar    $0x1f,%ebx
  int cnt = 0;
8010498d:	89 f0                	mov    %esi,%eax
  total = (total + 9) / 10;
8010498f:	c1 fa 02             	sar    $0x2,%edx
80104992:	29 da                	sub    %ebx,%edx
  for (int i = 0; i < p->sz; i += PGSIZE)
80104994:	31 db                	xor    %ebx,%ebx
  total = (total + 9) / 10;
80104996:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int cnt = 0;
80104999:	31 d2                	xor    %edx,%edx
8010499b:	89 d6                	mov    %edx,%esi
8010499d:	89 c2                	mov    %eax,%edx
8010499f:	eb 1b                	jmp    801049bc <select_a_victim+0xcc>
801049a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if (cnt >= total)
801049a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801049ab:	39 c6                	cmp    %eax,%esi
801049ad:	7d 59                	jge    80104a08 <select_a_victim+0x118>
  for (int i = 0; i < p->sz; i += PGSIZE)
801049af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801049b5:	39 d3                	cmp    %edx,%ebx
801049b7:	73 4f                	jae    80104a08 <select_a_victim+0x118>
    pte_t *pte = walkpgdir(p->pgdir, (void *)i, 0);
801049b9:	8b 4f 08             	mov    0x8(%edi),%ecx
  pde = &pgdir[PDX(va)];
801049bc:	89 d8                	mov    %ebx,%eax
801049be:	c1 e8 16             	shr    $0x16,%eax
  if (*pde & PTE_P)
801049c1:	8b 04 81             	mov    (%ecx,%eax,4),%eax
801049c4:	a8 01                	test   $0x1,%al
801049c6:	0f 84 9a 06 00 00    	je     80105066 <select_a_victim.cold+0xe>
  return &pgtab[PTX(va)];
801049cc:	89 d9                	mov    %ebx,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
801049ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801049d3:	c1 e9 0a             	shr    $0xa,%ecx
801049d6:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
801049dc:	8d 8c 08 00 00 00 80 	lea    -0x80000000(%eax,%ecx,1),%ecx
      if (*pte & PTE_A)
801049e3:	8b 01                	mov    (%ecx),%eax
801049e5:	f7 d0                	not    %eax
801049e7:	a8 21                	test   $0x21,%al
801049e9:	75 bd                	jne    801049a8 <select_a_victim+0xb8>
        make_acces_bit_0(pte);
801049eb:	83 ec 0c             	sub    $0xc,%esp
        cnt += 1;
801049ee:	83 c6 01             	add    $0x1,%esi
        make_acces_bit_0(pte);
801049f1:	51                   	push   %ecx
801049f2:	e8 59 fe ff ff       	call   80104850 <make_acces_bit_0>
    if (cnt >= total)
801049f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801049fa:	8b 17                	mov    (%edi),%edx
        cnt += 1;
801049fc:	83 c4 10             	add    $0x10,%esp
    if (cnt >= total)
801049ff:	39 c6                	cmp    %eax,%esi
80104a01:	7c ac                	jl     801049af <select_a_victim+0xbf>
80104a03:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a07:	90                   	nop
  for (int i = 0; i < p->sz; i += PGSIZE)
80104a08:	89 d6                	mov    %edx,%esi
80104a0a:	85 d2                	test   %edx,%edx
80104a0c:	74 5b                	je     80104a69 <select_a_victim+0x179>
    pte_t *pte = walkpgdir(p->pgdir, (void *)i, 0);
80104a0e:	8b 4f 08             	mov    0x8(%edi),%ecx
80104a11:	31 c0                	xor    %eax,%eax
80104a13:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a17:	90                   	nop
  pde = &pgdir[PDX(va)];
80104a18:	89 c2                	mov    %eax,%edx
80104a1a:	c1 ea 16             	shr    $0x16,%edx
  if (*pde & PTE_P)
80104a1d:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80104a20:	f6 c2 01             	test   $0x1,%dl
80104a23:	0f 84 2f 06 00 00    	je     80105058 <select_a_victim.cold>
  return &pgtab[PTX(va)];
80104a29:	89 c3                	mov    %eax,%ebx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80104a2b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80104a31:	c1 eb 0a             	shr    $0xa,%ebx
80104a34:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
80104a3a:	8d 94 1a 00 00 00 80 	lea    -0x80000000(%edx,%ebx,1),%edx
    if (*pte & PTE_P)
80104a41:	8b 1a                	mov    (%edx),%ebx
80104a43:	f6 c3 01             	test   $0x1,%bl
80104a46:	74 18                	je     80104a60 <select_a_victim+0x170>
      if (!(*pte & PTE_A))
80104a48:	83 e3 20             	and    $0x20,%ebx
80104a4b:	75 13                	jne    80104a60 <select_a_victim+0x170>
        if (p->rss < PGSIZE)
80104a4d:	81 7f 04 ff 0f 00 00 	cmpl   $0xfff,0x4(%edi)
80104a54:	0f 87 04 ff ff ff    	ja     8010495e <select_a_victim+0x6e>
80104a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for (int i = 0; i < p->sz; i += PGSIZE)
80104a60:	05 00 10 00 00       	add    $0x1000,%eax
80104a65:	39 f0                	cmp    %esi,%eax
80104a67:	72 af                	jb     80104a18 <select_a_victim+0x128>
}
80104a69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80104a6c:	31 d2                	xor    %edx,%edx
}
80104a6e:	5b                   	pop    %ebx
80104a6f:	89 d0                	mov    %edx,%eax
80104a71:	5e                   	pop    %esi
80104a72:	5f                   	pop    %edi
80104a73:	5d                   	pop    %ebp
80104a74:	c3                   	ret
80104a75:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104a80 <find_new_page_after_swapping>:

void find_new_page_after_swapping()
{
80104a80:	55                   	push   %ebp
80104a81:	89 e5                	mov    %esp,%ebp
80104a83:	57                   	push   %edi
80104a84:	56                   	push   %esi
  // cprintf("In find_new_page_after_swapping\n");
  pte_t *pte = select_a_victim();
  uint idx = -1;
  for (int i = 0; i < NSLOTS; i++)
80104a85:	31 f6                	xor    %esi,%esi
{
80104a87:	53                   	push   %ebx
80104a88:	83 ec 0c             	sub    $0xc,%esp
  pte_t *pte = select_a_victim();
80104a8b:	e8 60 fe ff ff       	call   801048f0 <select_a_victim>
80104a90:	89 c7                	mov    %eax,%edi
  for (int i = 0; i < NSLOTS; i++)
80104a92:	b8 68 2d 11 80       	mov    $0x80112d68,%eax
80104a97:	eb 1b                	jmp    80104ab4 <find_new_page_after_swapping+0x34>
80104a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104aa0:	83 c6 01             	add    $0x1,%esi
80104aa3:	05 10 02 00 00       	add    $0x210,%eax
80104aa8:	81 fe fa 00 00 00    	cmp    $0xfa,%esi
80104aae:	0f 84 f6 00 00 00    	je     80104baa <find_new_page_after_swapping+0x12a>
  {
    if (swaparray[i].is_free)
80104ab4:	8b 10                	mov    (%eax),%edx
80104ab6:	85 d2                	test   %edx,%edx
80104ab8:	74 e6                	je     80104aa0 <find_new_page_after_swapping+0x20>
      break;
    }
  }
  if (idx == -1)
    panic("No available slot\n");
  if (pte == 0)
80104aba:	85 ff                	test   %edi,%edi
80104abc:	0f 84 db 00 00 00    	je     80104b9d <find_new_page_after_swapping+0x11d>
    panic("Pte is 0\n");
  uint block_no = 2 + 8 * idx;
  // int a = (PTE_ADDR(*pte)/PGSIZE);
  write_pag_to_disk(ROOTDEV, (char *)P2V(PTE_ADDR(*pte)), block_no);
80104ac2:	83 ec 04             	sub    $0x4,%esp
  uint block_no = 2 + 8 * idx;
80104ac5:	8d 04 f5 02 00 00 00 	lea    0x2(,%esi,8),%eax
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104acc:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
  write_pag_to_disk(ROOTDEV, (char *)P2V(PTE_ADDR(*pte)), block_no);
80104ad1:	50                   	push   %eax
80104ad2:	8b 07                	mov    (%edi),%eax
80104ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104ad9:	05 00 00 00 80       	add    $0x80000000,%eax
80104ade:	50                   	push   %eax
80104adf:	6a 01                	push   $0x1
80104ae1:	e8 ba b7 ff ff       	call   801002a0 <write_pag_to_disk>
80104ae6:	83 c4 10             	add    $0x10,%esp
80104ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if ((p->state == UNUSED)) continue;
80104af0:	8b 43 10             	mov    0x10(%ebx),%eax
80104af3:	85 c0                	test   %eax,%eax
80104af5:	74 0e                	je     80104b05 <find_new_page_after_swapping+0x85>
    find_pte_swap_out(p, pte, idx);
80104af7:	83 ec 04             	sub    $0x4,%esp
80104afa:	56                   	push   %esi
80104afb:	57                   	push   %edi
80104afc:	53                   	push   %ebx
80104afd:	e8 ce fa ff ff       	call   801045d0 <find_pte_swap_out>
80104b02:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b05:	83 eb 80             	sub    $0xffffff80,%ebx
80104b08:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
80104b0e:	75 e0                	jne    80104af0 <find_new_page_after_swapping+0x70>
  // cprintf("In find_new_page_after_swapping2\n");
  make_other_pte_swapped_out(pte, idx);
  // cprintf("In find_new_page_after_swapping3\n");
  swaparray[idx].page_perm = PTE_FLAGS(*pte);
80104b10:	8b 07                	mov    (%edi),%eax
80104b12:	69 d6 10 02 00 00    	imul   $0x210,%esi,%edx
  swaparray[idx].is_free = 0;
  kfree((char *)P2V(PTE_ADDR(*pte)));
80104b18:	83 ec 0c             	sub    $0xc,%esp
  swaparray[idx].page_perm = PTE_FLAGS(*pte);
80104b1b:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b20:	89 82 64 2d 11 80    	mov    %eax,-0x7feed29c(%edx)
80104b26:	8d 9a 60 2d 11 80    	lea    -0x7feed2a0(%edx),%ebx
  swaparray[idx].is_free = 0;
80104b2c:	c7 82 68 2d 11 80 00 	movl   $0x0,-0x7feed298(%edx)
80104b33:	00 00 00 
  kfree((char *)P2V(PTE_ADDR(*pte)));
80104b36:	8b 07                	mov    (%edi),%eax
80104b38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104b3d:	05 00 00 00 80       	add    $0x80000000,%eax
80104b42:	50                   	push   %eax
80104b43:	e8 88 da ff ff       	call   801025d0 <kfree>
  *pte = ((idx << 12) | PTE_S);
80104b48:	89 f0                	mov    %esi,%eax
  *pte &= ~PTE_A;
  for (int i = 0; i < swaparray[idx].cnt; i++)
80104b4a:	83 c4 10             	add    $0x10,%esp
  *pte = ((idx << 12) | PTE_S);
80104b4d:	c1 e0 0c             	shl    $0xc,%eax
80104b50:	0c 80                	or     $0x80,%al
80104b52:	89 07                	mov    %eax,(%edi)
  for (int i = 0; i < swaparray[idx].cnt; i++)
80104b54:	8b 8b 0c 02 00 00    	mov    0x20c(%ebx),%ecx
80104b5a:	85 c9                	test   %ecx,%ecx
80104b5c:	74 37                	je     80104b95 <find_new_page_after_swapping+0x115>
80104b5e:	69 c6 84 00 00 00    	imul   $0x84,%esi,%eax
80104b64:	89 da                	mov    %ebx,%edx
80104b66:	01 c8                	add    %ecx,%eax
80104b68:	8d 04 85 60 2d 11 80 	lea    -0x7feed2a0(,%eax,4),%eax
80104b6f:	89 c1                	mov    %eax,%ecx
80104b71:	29 d9                	sub    %ebx,%ecx
80104b73:	83 e1 04             	and    $0x4,%ecx
80104b76:	74 10                	je     80104b88 <find_new_page_after_swapping+0x108>
80104b78:	83 c2 04             	add    $0x4,%edx
    {
      // if(V2P(mem) / PGSIZE == 73) cprintf("In incr %d\n",swaparray[block_no].pte_id[i]);
      // inc_sharing(swaparray[block_no].pte_id[i], V2P(mem) / PGSIZE);
      // cprintf("checking both are changing or not %d %d\n",*pte,*swaparray[idx].pte_id[i]);
      swaparray[idx].pte_id[i] = pte;
80104b7b:	89 7b 0c             	mov    %edi,0xc(%ebx)
  for (int i = 0; i < swaparray[idx].cnt; i++)
80104b7e:	39 c2                	cmp    %eax,%edx
80104b80:	74 13                	je     80104b95 <find_new_page_after_swapping+0x115>
80104b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      swaparray[idx].pte_id[i] = pte;
80104b88:	89 7a 0c             	mov    %edi,0xc(%edx)
  for (int i = 0; i < swaparray[idx].cnt; i++)
80104b8b:	83 c2 08             	add    $0x8,%edx
      swaparray[idx].pte_id[i] = pte;
80104b8e:	89 7a 08             	mov    %edi,0x8(%edx)
  for (int i = 0; i < swaparray[idx].cnt; i++)
80104b91:	39 c2                	cmp    %eax,%edx
80104b93:	75 f3                	jne    80104b88 <find_new_page_after_swapping+0x108>
  // cprintf("In find new page fault %d %d %d %d refcount %d\n", pte,*pte, block_no, idx,swaparray[idx].cnt);
  //   // *pte= (idx<< 12) | PTE_S;
  // cprintf("In find_new_page_after_swapping4\n");
  // lcr3(V2P(myproc()->pgdir));
  return;
}
80104b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b98:	5b                   	pop    %ebx
80104b99:	5e                   	pop    %esi
80104b9a:	5f                   	pop    %edi
80104b9b:	5d                   	pop    %ebp
80104b9c:	c3                   	ret
    panic("Pte is 0\n");
80104b9d:	83 ec 0c             	sub    $0xc,%esp
80104ba0:	68 b8 85 10 80       	push   $0x801085b8
80104ba5:	e8 06 b9 ff ff       	call   801004b0 <panic>
    panic("No available slot\n");
80104baa:	83 ec 0c             	sub    $0xc,%esp
80104bad:	68 a5 85 10 80       	push   $0x801085a5
80104bb2:	e8 f9 b8 ff ff       	call   801004b0 <panic>
80104bb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bbe:	66 90                	xchg   %ax,%ax

80104bc0 <handle_fage_fault>:

void handle_fage_fault()
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
80104bc3:	57                   	push   %edi
80104bc4:	56                   	push   %esi
80104bc5:	53                   	push   %ebx
80104bc6:	83 ec 2c             	sub    $0x2c,%esp
  pushcli();
80104bc9:	e8 82 06 00 00       	call   80105250 <pushcli>
  c = mycpu();
80104bce:	e8 9d f0 ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80104bd3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104bd9:	e8 c2 06 00 00       	call   801052a0 <popcli>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104bde:	0f 20 d0             	mov    %cr2,%eax
  struct proc *p;
  p = myproc();
  uint va = (rcr2());
  va = PGROUNDDOWN(va);
  pde_t *pg_dir;
  pg_dir = p->pgdir;
80104be1:	8b 4b 08             	mov    0x8(%ebx),%ecx
  va = PGROUNDDOWN(va);
80104be4:	89 c2                	mov    %eax,%edx
  pde = &pgdir[PDX(va)];
80104be6:	c1 e8 16             	shr    $0x16,%eax
  va = PGROUNDDOWN(va);
80104be9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if (*pde & PTE_P)
80104bef:	8b 04 81             	mov    (%ecx,%eax,4),%eax
80104bf2:	a8 01                	test   $0x1,%al
80104bf4:	0f 84 73 04 00 00    	je     8010506d <handle_fage_fault.cold>
  return &pgtab[PTX(va)];
80104bfa:	c1 ea 0a             	shr    $0xa,%edx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80104bfd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80104c02:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80104c08:	8d 9c 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%ebx
  pte_t *pte = walkpgdir(pg_dir, (void *)va, 0);
  uint pa = PTE_ADDR(*pte);
80104c0f:	8b 33                	mov    (%ebx),%esi
  uint pgnum = pa / PGSIZE;
80104c11:	89 f0                	mov    %esi,%eax
80104c13:	c1 e8 0c             	shr    $0xc,%eax
80104c16:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (*pte & PTE_P)
80104c19:	f7 c6 01 00 00 00    	test   $0x1,%esi
80104c1f:	0f 84 8b 00 00 00    	je     80104cb0 <handle_fage_fault+0xf0>
  return (rmap[pgnum].refcount == 1);
80104c25:	69 c0 38 02 00 00    	imul   $0x238,%eax,%eax
  {
    if (check_rmap(pgnum))
80104c2b:	83 b8 34 31 13 80 01 	cmpl   $0x1,-0x7feccecc(%eax)
80104c32:	75 1c                	jne    80104c50 <handle_fage_fault+0x90>
    {
      *pte |= PTE_W;
80104c34:	83 ce 02             	or     $0x2,%esi
80104c37:	89 33                	mov    %esi,(%ebx)
      *swaparray[block_no].pte_id[i] = *pte;
    }
    swaparray[block_no].cnt = 0;
  }
  // cprintf("In handle page fault2 %d %d refcount \n", pte, *pte);
  lcr3(V2P(pg_dir));
80104c39:	8d 81 00 00 00 80    	lea    -0x80000000(%ecx),%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80104c3f:	0f 22 d8             	mov    %eax,%cr3
}
80104c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c45:	5b                   	pop    %ebx
80104c46:	5e                   	pop    %esi
80104c47:	5f                   	pop    %edi
80104c48:	5d                   	pop    %ebp
80104c49:	c3                   	ret
80104c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  uint pa = PTE_ADDR(*pte);
80104c50:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80104c56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
      char *mem = kalloc();
80104c59:	e8 42 db ff ff       	call   801027a0 <kalloc>
      memmove(mem, (char *)P2V(pa), PGSIZE);
80104c5e:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80104c64:	83 ec 04             	sub    $0x4,%esp
80104c67:	68 00 10 00 00       	push   $0x1000
      char *mem = kalloc();
80104c6c:	89 c7                	mov    %eax,%edi
      memmove(mem, (char *)P2V(pa), PGSIZE);
80104c6e:	56                   	push   %esi
      *pte = V2P(mem) | PTE_FLAGS(*pte) | PTE_W;
80104c6f:	81 c7 00 00 00 80    	add    $0x80000000,%edi
      memmove(mem, (char *)P2V(pa), PGSIZE);
80104c75:	50                   	push   %eax
80104c76:	e8 b5 08 00 00       	call   80105530 <memmove>
      *pte = V2P(mem) | PTE_FLAGS(*pte) | PTE_W;
80104c7b:	8b 03                	mov    (%ebx),%eax
80104c7d:	25 ff 0f 00 00       	and    $0xfff,%eax
80104c82:	09 f8                	or     %edi,%eax
      inc_sharing(pte, V2P(mem) / PGSIZE);
80104c84:	c1 ef 0c             	shr    $0xc,%edi
      *pte = V2P(mem) | PTE_FLAGS(*pte) | PTE_W;
80104c87:	83 c8 02             	or     $0x2,%eax
80104c8a:	89 03                	mov    %eax,(%ebx)
      dec_sharing(pte, pgnum);
80104c8c:	59                   	pop    %ecx
80104c8d:	5e                   	pop    %esi
80104c8e:	ff 75 d8             	push   -0x28(%ebp)
80104c91:	53                   	push   %ebx
80104c92:	e8 19 ef ff ff       	call   80103bb0 <dec_sharing>
      inc_sharing(pte, V2P(mem) / PGSIZE);
80104c97:	58                   	pop    %eax
80104c98:	5a                   	pop    %edx
80104c99:	57                   	push   %edi
80104c9a:	53                   	push   %ebx
80104c9b:	e8 90 ee ff ff       	call   80103b30 <inc_sharing>
80104ca0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104ca3:	83 c4 10             	add    $0x10,%esp
80104ca6:	eb 91                	jmp    80104c39 <handle_fage_fault+0x79>
80104ca8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104caf:	90                   	nop
80104cb0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    char *mem = kalloc();
80104cb3:	e8 e8 da ff ff       	call   801027a0 <kalloc>
    read_page_from_disk(8 * block_no + 2, mem);
80104cb8:	83 ec 08             	sub    $0x8,%esp
80104cbb:	50                   	push   %eax
80104cbc:	8b 7d d8             	mov    -0x28(%ebp),%edi
    char *mem = kalloc();
80104cbf:	89 c6                	mov    %eax,%esi
    read_page_from_disk(8 * block_no + 2, mem);
80104cc1:	8d 04 fd 02 00 00 00 	lea    0x2(,%edi,8),%eax
80104cc8:	50                   	push   %eax
80104cc9:	e8 62 b6 ff ff       	call   80100330 <read_page_from_disk>
    uint permissions = swaparray[block_no].page_perm;
80104cce:	69 c7 10 02 00 00    	imul   $0x210,%edi,%eax
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104cd4:	83 c4 10             	add    $0x10,%esp
    *pte = PTE_ADDR(V2P(mem)) | PTE_FLAGS(permissions);
80104cd7:	8d be 00 00 00 80    	lea    -0x80000000(%esi),%edi
80104cdd:	89 f9                	mov    %edi,%ecx
80104cdf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    uint permissions = swaparray[block_no].page_perm;
80104ce5:	05 60 2d 11 80       	add    $0x80112d60,%eax
    *pte = PTE_ADDR(V2P(mem)) | PTE_FLAGS(permissions);
80104cea:	8b 50 04             	mov    0x4(%eax),%edx
    swaparray[block_no].is_free = 1;
80104ced:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    *pte = PTE_ADDR(V2P(mem)) | PTE_FLAGS(permissions);
80104cf4:	81 e2 7d 0f 00 00    	and    $0xf7d,%edx
    *pte = *pte & ~PTE_S;
80104cfa:	09 ca                	or     %ecx,%edx
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104cfc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
    *pte = *pte & ~PTE_S;
80104cff:	83 ca 20             	or     $0x20,%edx
80104d02:	89 13                	mov    %edx,(%ebx)
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104d04:	8b 90 0c 02 00 00    	mov    0x20c(%eax),%edx
80104d0a:	85 d2                	test   %edx,%edx
80104d0c:	0f 84 91 00 00 00    	je     80104da3 <handle_fage_fault+0x1e3>
      inc_sharing(swaparray[block_no].pte_id[i], V2P(mem) / PGSIZE);
80104d12:	c1 ef 0c             	shr    $0xc,%edi
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104d15:	89 45 e0             	mov    %eax,-0x20(%ebp)
      inc_sharing(swaparray[block_no].pte_id[i], V2P(mem) / PGSIZE);
80104d18:	89 7d dc             	mov    %edi,-0x24(%ebp)
      if(V2P(mem) / PGSIZE == 73) cprintf("In incr %d\n",swaparray[block_no].pte_id[i]);
80104d1b:	8d be 00 70 fb 7f    	lea    0x7ffb7000(%esi),%edi
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104d21:	31 f6                	xor    %esi,%esi
      if(V2P(mem) / PGSIZE == 73) cprintf("In incr %d\n",swaparray[block_no].pte_id[i]);
80104d23:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80104d26:	89 c7                	mov    %eax,%edi
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104d28:	89 d8                	mov    %ebx,%eax
80104d2a:	89 f3                	mov    %esi,%ebx
80104d2c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80104d2f:	89 fe                	mov    %edi,%esi
80104d31:	89 c7                	mov    %eax,%edi
80104d33:	eb 46                	jmp    80104d7b <handle_fage_fault+0x1bb>
80104d35:	8d 76 00             	lea    0x0(%esi),%esi
      if(swaparray[block_no].proc_id[i]->state == UNUSED) continue;
80104d38:	8b 8e 0c 01 00 00    	mov    0x10c(%esi),%ecx
80104d3e:	8b 41 10             	mov    0x10(%ecx),%eax
80104d41:	85 c0                	test   %eax,%eax
80104d43:	74 25                	je     80104d6a <handle_fage_fault+0x1aa>
      inc_sharing(swaparray[block_no].pte_id[i], V2P(mem) / PGSIZE);
80104d45:	83 ec 08             	sub    $0x8,%esp
80104d48:	ff 75 dc             	push   -0x24(%ebp)
80104d4b:	ff 76 0c             	push   0xc(%esi)
80104d4e:	e8 dd ed ff ff       	call   80103b30 <inc_sharing>
      swaparray[block_no].proc_id[i]->rss += PGSIZE;
80104d53:	8b 8e 0c 01 00 00    	mov    0x10c(%esi),%ecx
      *swaparray[block_no].pte_id[i] = *pte;
80104d59:	83 c4 10             	add    $0x10,%esp
      swaparray[block_no].proc_id[i]->rss += PGSIZE;
80104d5c:	81 41 04 00 10 00 00 	addl   $0x1000,0x4(%ecx)
      *swaparray[block_no].pte_id[i] = *pte;
80104d63:	8b 4e 0c             	mov    0xc(%esi),%ecx
80104d66:	8b 07                	mov    (%edi),%eax
80104d68:	89 01                	mov    %eax,(%ecx)
    for (int i = 0; i < swaparray[block_no].cnt; i++)
80104d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d6d:	83 c3 01             	add    $0x1,%ebx
80104d70:	83 c6 04             	add    $0x4,%esi
80104d73:	3b 98 0c 02 00 00    	cmp    0x20c(%eax),%ebx
80104d79:	73 25                	jae    80104da0 <handle_fage_fault+0x1e0>
      if(V2P(mem) / PGSIZE == 73) cprintf("In incr %d\n",swaparray[block_no].pte_id[i]);
80104d7b:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
80104d82:	77 b4                	ja     80104d38 <handle_fage_fault+0x178>
80104d84:	83 ec 08             	sub    $0x8,%esp
80104d87:	ff 76 0c             	push   0xc(%esi)
80104d8a:	68 c2 85 10 80       	push   $0x801085c2
80104d8f:	e8 4c ba ff ff       	call   801007e0 <cprintf>
80104d94:	83 c4 10             	add    $0x10,%esp
80104d97:	eb 9f                	jmp    80104d38 <handle_fage_fault+0x178>
80104d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104da0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
    swaparray[block_no].cnt = 0;
80104da3:	69 45 d8 10 02 00 00 	imul   $0x210,-0x28(%ebp),%eax
80104daa:	c7 80 6c 2f 11 80 00 	movl   $0x0,-0x7feed094(%eax)
80104db1:	00 00 00 
80104db4:	e9 80 fe ff ff       	jmp    80104c39 <handle_fage_fault+0x79>
80104db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104dc0 <clean_proc_data>:

void clean_proc_data(pde_t *pde)
{
80104dc0:	55                   	push   %ebp
80104dc1:	89 e5                	mov    %esp,%ebp
80104dc3:	57                   	push   %edi
80104dc4:	56                   	push   %esi
80104dc5:	53                   	push   %ebx
80104dc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104dc9:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
80104dcf:	eb 0e                	jmp    80104ddf <clean_proc_data+0x1f>
80104dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for (int i = 0; i < NPDENTRIES; i++)
80104dd8:	83 c3 04             	add    $0x4,%ebx
80104ddb:	39 f3                	cmp    %esi,%ebx
80104ddd:	74 63                	je     80104e42 <clean_proc_data+0x82>
  {
    if (pde[i] & PTE_P)
80104ddf:	8b 0b                	mov    (%ebx),%ecx
80104de1:	f6 c1 01             	test   $0x1,%cl
80104de4:	74 f2                	je     80104dd8 <clean_proc_data+0x18>
    {
      pte_t *pte = (pte_t *)P2V(PTE_ADDR(pde[i]));
80104de6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
80104dec:	8d 91 00 00 00 80    	lea    -0x80000000(%ecx),%edx
      for (int j = 0; j < NPTENTRIES; j++)
80104df2:	81 e9 00 f0 ff 7f    	sub    $0x7ffff000,%ecx
80104df8:	eb 16                	jmp    80104e10 <clean_proc_data+0x50>
80104dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            swaparray[slot].is_free = 1;
            swaparray[slot].cnt = 0;
          }
          else{
            // cprintf("More than one cnt\n");
            swaparray[slot].cnt --;
80104e00:	83 ef 01             	sub    $0x1,%edi
80104e03:	89 b8 0c 02 00 00    	mov    %edi,0x20c(%eax)
      for (int j = 0; j < NPTENTRIES; j++)
80104e09:	83 c2 04             	add    $0x4,%edx
80104e0c:	39 d1                	cmp    %edx,%ecx
80104e0e:	74 c8                	je     80104dd8 <clean_proc_data+0x18>
        if (pte[j] & PTE_S)
80104e10:	8b 02                	mov    (%edx),%eax
80104e12:	a8 80                	test   $0x80,%al
80104e14:	74 f3                	je     80104e09 <clean_proc_data+0x49>
          uint slot = PTE_ADDR(pte[j]) >> 12;
80104e16:	c1 e8 0c             	shr    $0xc,%eax
          if(swaparray[slot].cnt == 1){
80104e19:	69 c0 10 02 00 00    	imul   $0x210,%eax,%eax
80104e1f:	05 60 2d 11 80       	add    $0x80112d60,%eax
80104e24:	8b b8 0c 02 00 00    	mov    0x20c(%eax),%edi
80104e2a:	83 ff 01             	cmp    $0x1,%edi
80104e2d:	75 d1                	jne    80104e00 <clean_proc_data+0x40>
            swaparray[slot].is_free = 1;
80104e2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
            swaparray[slot].cnt = 0;
80104e36:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%eax)
80104e3d:	00 00 00 
80104e40:	eb c7                	jmp    80104e09 <clean_proc_data+0x49>
          }
        }
      }
    }
  }
}
80104e42:	5b                   	pop    %ebx
80104e43:	5e                   	pop    %esi
80104e44:	5f                   	pop    %edi
80104e45:	5d                   	pop    %ebp
80104e46:	c3                   	ret
80104e47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e4e:	66 90                	xchg   %ax,%ax

80104e50 <wait>:
{
80104e50:	55                   	push   %ebp
80104e51:	89 e5                	mov    %esp,%ebp
80104e53:	56                   	push   %esi
80104e54:	53                   	push   %ebx
  pushcli();
80104e55:	e8 f6 03 00 00       	call   80105250 <pushcli>
  c = mycpu();
80104e5a:	e8 11 ee ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80104e5f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104e65:	e8 36 04 00 00       	call   801052a0 <popcli>
  acquire(&ptable.lock);
80104e6a:	83 ec 0c             	sub    $0xc,%esp
80104e6d:	68 00 11 1c 80       	push   $0x801c1100
80104e72:	e8 29 05 00 00       	call   801053a0 <acquire>
80104e77:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104e7a:	31 c0                	xor    %eax,%eax
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e7c:	bb 34 11 1c 80       	mov    $0x801c1134,%ebx
80104e81:	eb 10                	jmp    80104e93 <wait+0x43>
80104e83:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104e87:	90                   	nop
80104e88:	83 eb 80             	sub    $0xffffff80,%ebx
80104e8b:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
80104e91:	74 1b                	je     80104eae <wait+0x5e>
      if (p->parent != curproc)
80104e93:	39 73 18             	cmp    %esi,0x18(%ebx)
80104e96:	75 f0                	jne    80104e88 <wait+0x38>
      if (p->state == ZOMBIE)
80104e98:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
80104e9c:	74 62                	je     80104f00 <wait+0xb0>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e9e:	83 eb 80             	sub    $0xffffff80,%ebx
      havekids = 1;
80104ea1:	b8 01 00 00 00       	mov    $0x1,%eax
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ea6:	81 fb 34 31 1c 80    	cmp    $0x801c3134,%ebx
80104eac:	75 e5                	jne    80104e93 <wait+0x43>
    if (!havekids || curproc->killed)
80104eae:	85 c0                	test   %eax,%eax
80104eb0:	0f 84 ab 00 00 00    	je     80104f61 <wait+0x111>
80104eb6:	8b 46 28             	mov    0x28(%esi),%eax
80104eb9:	85 c0                	test   %eax,%eax
80104ebb:	0f 85 a0 00 00 00    	jne    80104f61 <wait+0x111>
  pushcli();
80104ec1:	e8 8a 03 00 00       	call   80105250 <pushcli>
  c = mycpu();
80104ec6:	e8 a5 ed ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80104ecb:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104ed1:	e8 ca 03 00 00       	call   801052a0 <popcli>
  if (p == 0)
80104ed6:	85 db                	test   %ebx,%ebx
80104ed8:	0f 84 9a 00 00 00    	je     80104f78 <wait+0x128>
  p->chan = chan;
80104ede:	89 73 24             	mov    %esi,0x24(%ebx)
  p->state = SLEEPING;
80104ee1:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104ee8:	e8 d3 f1 ff ff       	call   801040c0 <sched>
  p->chan = 0;
80104eed:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
80104ef4:	eb 84                	jmp    80104e7a <wait+0x2a>
80104ef6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104efd:	8d 76 00             	lea    0x0(%esi),%esi
        clean_proc_data(p->pgdir);
80104f00:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
80104f03:	8b 73 14             	mov    0x14(%ebx),%esi
        clean_proc_data(p->pgdir);
80104f06:	ff 73 08             	push   0x8(%ebx)
80104f09:	e8 b2 fe ff ff       	call   80104dc0 <clean_proc_data>
        kfree(p->kstack);
80104f0e:	5a                   	pop    %edx
80104f0f:	ff 73 0c             	push   0xc(%ebx)
80104f12:	e8 b9 d6 ff ff       	call   801025d0 <kfree>
        p->kstack = 0;
80104f17:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm2(p->pgdir,p);
80104f1e:	59                   	pop    %ecx
80104f1f:	58                   	pop    %eax
80104f20:	53                   	push   %ebx
80104f21:	ff 73 08             	push   0x8(%ebx)
80104f24:	e8 b7 2f 00 00       	call   80107ee0 <freevm2>
        p->pid = 0;
80104f29:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
80104f30:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
80104f37:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
80104f3b:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
80104f42:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
80104f49:	c7 04 24 00 11 1c 80 	movl   $0x801c1100,(%esp)
80104f50:	e8 eb 03 00 00       	call   80105340 <release>
        return pid;
80104f55:	83 c4 10             	add    $0x10,%esp
}
80104f58:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f5b:	89 f0                	mov    %esi,%eax
80104f5d:	5b                   	pop    %ebx
80104f5e:	5e                   	pop    %esi
80104f5f:	5d                   	pop    %ebp
80104f60:	c3                   	ret
      release(&ptable.lock);
80104f61:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104f64:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104f69:	68 00 11 1c 80       	push   $0x801c1100
80104f6e:	e8 cd 03 00 00       	call   80105340 <release>
      return -1;
80104f73:	83 c4 10             	add    $0x10,%esp
80104f76:	eb e0                	jmp    80104f58 <wait+0x108>
    panic("sleep");
80104f78:	83 ec 0c             	sub    $0xc,%esp
80104f7b:	68 6e 85 10 80       	push   $0x8010856e
80104f80:	e8 2b b5 ff ff       	call   801004b0 <panic>
80104f85:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104f90 <clear_swapped_page>:


void clear_swapped_page(pte_t* pte){
80104f90:	55                   	push   %ebp
80104f91:	89 e5                	mov    %esp,%ebp
80104f93:	53                   	push   %ebx
80104f94:	83 ec 10             	sub    $0x10,%esp
  uint slot = (*pte << 12);
80104f97:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9a:	8b 18                	mov    (%eax),%ebx
  cprintf("More than one cnt\n");
80104f9c:	68 ce 85 10 80       	push   $0x801085ce
  uint slot = (*pte << 12);
80104fa1:	c1 e3 0c             	shl    $0xc,%ebx
  cprintf("More than one cnt\n");
80104fa4:	e8 37 b8 ff ff       	call   801007e0 <cprintf>
  if(swaparray[slot].cnt == 1){
80104fa9:	69 c3 10 02 00 00    	imul   $0x210,%ebx,%eax
80104faf:	83 c4 10             	add    $0x10,%esp
80104fb2:	8b 90 6c 2f 11 80    	mov    -0x7feed094(%eax),%edx
80104fb8:	05 60 2d 11 80       	add    $0x80112d60,%eax
80104fbd:	8d 4a ff             	lea    -0x1(%edx),%ecx
80104fc0:	83 fa 01             	cmp    $0x1,%edx
80104fc3:	75 09                	jne    80104fce <clear_swapped_page+0x3e>

    swaparray[slot].is_free = 1;
80104fc5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    swaparray[slot].cnt = 0;
80104fcc:	31 c9                	xor    %ecx,%ecx
80104fce:	69 db 10 02 00 00    	imul   $0x210,%ebx,%ebx
80104fd4:	89 8b 6c 2f 11 80    	mov    %ecx,-0x7feed094(%ebx)
  }
  else{

    swaparray[slot].cnt --;
  }
}
80104fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fdd:	c9                   	leave
80104fde:	c3                   	ret
80104fdf:	90                   	nop

80104fe0 <illop>:


void illop(){
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	56                   	push   %esi
80104fe4:	53                   	push   %ebx
  pushcli();
80104fe5:	e8 66 02 00 00       	call   80105250 <pushcli>
  c = mycpu();
80104fea:	e8 81 ec ff ff       	call   80103c70 <mycpu>
  p = c->proc;
80104fef:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104ff5:	e8 a6 02 00 00       	call   801052a0 <popcli>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104ffa:	0f 20 d0             	mov    %cr2,%eax
  if (*pde & PTE_P)
80104ffd:	8b 4b 08             	mov    0x8(%ebx),%ecx
  struct proc *p;
  p = myproc();

  uint va = (rcr2());
  va = PGROUNDDOWN(va);
80105000:	89 c2                	mov    %eax,%edx
  pde = &pgdir[PDX(va)];
80105002:	c1 e8 16             	shr    $0x16,%eax
  va = PGROUNDDOWN(va);
80105005:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if (*pde & PTE_P)
8010500b:	8b 04 81             	mov    (%ecx,%eax,4),%eax
8010500e:	a8 01                	test   $0x1,%al
80105010:	0f 84 5e 00 00 00    	je     80105074 <illop.cold>
  return &pgtab[PTX(va)];
80105016:	89 d1                	mov    %edx,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80105018:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  pde_t *pg_dir;
  pg_dir = p->pgdir;
  pte_t *pte = walkpgdir(pg_dir, (void *)va, 0);
  uint pa = PTE_ADDR(*pte);
  uint pgnum = pa / PGSIZE;
  cprintf("In illop p->pid %d va %d *pte %d pte %d pa %d pgnum %d \n",p->pid,va,*pte,pte,pa,pgnum);
8010501d:	83 ec 04             	sub    $0x4,%esp
  return &pgtab[PTX(va)];
80105020:	c1 e9 0a             	shr    $0xa,%ecx
80105023:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
80105029:	8d 8c 08 00 00 00 80 	lea    -0x80000000(%eax,%ecx,1),%ecx
  uint pa = PTE_ADDR(*pte);
80105030:	8b 01                	mov    (%ecx),%eax
  uint pgnum = pa / PGSIZE;
80105032:	89 c6                	mov    %eax,%esi
80105034:	c1 ee 0c             	shr    $0xc,%esi
  cprintf("In illop p->pid %d va %d *pte %d pte %d pa %d pgnum %d \n",p->pid,va,*pte,pte,pa,pgnum);
80105037:	56                   	push   %esi
  uint pa = PTE_ADDR(*pte);
80105038:	89 c6                	mov    %eax,%esi
8010503a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  cprintf("In illop p->pid %d va %d *pte %d pte %d pa %d pgnum %d \n",p->pid,va,*pte,pte,pa,pgnum);
80105040:	56                   	push   %esi
80105041:	51                   	push   %ecx
80105042:	50                   	push   %eax
80105043:	52                   	push   %edx
80105044:	ff 73 14             	push   0x14(%ebx)
80105047:	68 74 89 10 80       	push   $0x80108974
8010504c:	e8 8f b7 ff ff       	call   801007e0 <cprintf>
  // panic("ILLP");
}
80105051:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105054:	5b                   	pop    %ebx
80105055:	5e                   	pop    %esi
80105056:	5d                   	pop    %ebp
80105057:	c3                   	ret

80105058 <select_a_victim.cold>:
    if (*pte & PTE_P)
80105058:	a1 00 00 00 00       	mov    0x0,%eax
8010505d:	0f 0b                	ud2
    if (*pte & PTE_P)
8010505f:	a1 00 00 00 00       	mov    0x0,%eax
80105064:	0f 0b                	ud2
    if (*pte & PTE_P)
80105066:	a1 00 00 00 00       	mov    0x0,%eax
8010506b:	0f 0b                	ud2

8010506d <handle_fage_fault.cold>:
  uint pa = PTE_ADDR(*pte);
8010506d:	a1 00 00 00 00       	mov    0x0,%eax
80105072:	0f 0b                	ud2

80105074 <illop.cold>:
  uint pa = PTE_ADDR(*pte);
80105074:	a1 00 00 00 00       	mov    0x0,%eax
80105079:	0f 0b                	ud2
8010507b:	66 90                	xchg   %ax,%ax
8010507d:	66 90                	xchg   %ax,%ax
8010507f:	90                   	nop

80105080 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105080:	55                   	push   %ebp
80105081:	89 e5                	mov    %esp,%ebp
80105083:	53                   	push   %ebx
80105084:	83 ec 0c             	sub    $0xc,%esp
80105087:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010508a:	68 0b 86 10 80       	push   $0x8010860b
8010508f:	8d 43 04             	lea    0x4(%ebx),%eax
80105092:	50                   	push   %eax
80105093:	e8 18 01 00 00       	call   801051b0 <initlock>
  lk->name = name;
80105098:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010509b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
801050a1:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
801050a4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
801050ab:	89 43 38             	mov    %eax,0x38(%ebx)
}
801050ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050b1:	c9                   	leave
801050b2:	c3                   	ret
801050b3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801050ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801050c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801050c0:	55                   	push   %ebp
801050c1:	89 e5                	mov    %esp,%ebp
801050c3:	56                   	push   %esi
801050c4:	53                   	push   %ebx
801050c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801050c8:	8d 73 04             	lea    0x4(%ebx),%esi
801050cb:	83 ec 0c             	sub    $0xc,%esp
801050ce:	56                   	push   %esi
801050cf:	e8 cc 02 00 00       	call   801053a0 <acquire>
  while (lk->locked) {
801050d4:	8b 13                	mov    (%ebx),%edx
801050d6:	83 c4 10             	add    $0x10,%esp
801050d9:	85 d2                	test   %edx,%edx
801050db:	74 16                	je     801050f3 <acquiresleep+0x33>
801050dd:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
801050e0:	83 ec 08             	sub    $0x8,%esp
801050e3:	56                   	push   %esi
801050e4:	53                   	push   %ebx
801050e5:	e8 16 f2 ff ff       	call   80104300 <sleep>
  while (lk->locked) {
801050ea:	8b 03                	mov    (%ebx),%eax
801050ec:	83 c4 10             	add    $0x10,%esp
801050ef:	85 c0                	test   %eax,%eax
801050f1:	75 ed                	jne    801050e0 <acquiresleep+0x20>
  }
  lk->locked = 1;
801050f3:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801050f9:	e8 f2 eb ff ff       	call   80103cf0 <myproc>
801050fe:	8b 40 14             	mov    0x14(%eax),%eax
80105101:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80105104:	89 75 08             	mov    %esi,0x8(%ebp)
}
80105107:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010510a:	5b                   	pop    %ebx
8010510b:	5e                   	pop    %esi
8010510c:	5d                   	pop    %ebp
  release(&lk->lk);
8010510d:	e9 2e 02 00 00       	jmp    80105340 <release>
80105112:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105120 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105120:	55                   	push   %ebp
80105121:	89 e5                	mov    %esp,%ebp
80105123:	56                   	push   %esi
80105124:	53                   	push   %ebx
80105125:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80105128:	8d 73 04             	lea    0x4(%ebx),%esi
8010512b:	83 ec 0c             	sub    $0xc,%esp
8010512e:	56                   	push   %esi
8010512f:	e8 6c 02 00 00       	call   801053a0 <acquire>
  lk->locked = 0;
80105134:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010513a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80105141:	89 1c 24             	mov    %ebx,(%esp)
80105144:	e8 77 f2 ff ff       	call   801043c0 <wakeup>
  release(&lk->lk);
80105149:	89 75 08             	mov    %esi,0x8(%ebp)
8010514c:	83 c4 10             	add    $0x10,%esp
}
8010514f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105152:	5b                   	pop    %ebx
80105153:	5e                   	pop    %esi
80105154:	5d                   	pop    %ebp
  release(&lk->lk);
80105155:	e9 e6 01 00 00       	jmp    80105340 <release>
8010515a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105160 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105160:	55                   	push   %ebp
80105161:	89 e5                	mov    %esp,%ebp
80105163:	57                   	push   %edi
80105164:	31 ff                	xor    %edi,%edi
80105166:	56                   	push   %esi
80105167:	53                   	push   %ebx
80105168:	83 ec 18             	sub    $0x18,%esp
8010516b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010516e:	8d 73 04             	lea    0x4(%ebx),%esi
80105171:	56                   	push   %esi
80105172:	e8 29 02 00 00       	call   801053a0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80105177:	8b 03                	mov    (%ebx),%eax
80105179:	83 c4 10             	add    $0x10,%esp
8010517c:	85 c0                	test   %eax,%eax
8010517e:	75 18                	jne    80105198 <holdingsleep+0x38>
  release(&lk->lk);
80105180:	83 ec 0c             	sub    $0xc,%esp
80105183:	56                   	push   %esi
80105184:	e8 b7 01 00 00       	call   80105340 <release>
  return r;
}
80105189:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010518c:	89 f8                	mov    %edi,%eax
8010518e:	5b                   	pop    %ebx
8010518f:	5e                   	pop    %esi
80105190:	5f                   	pop    %edi
80105191:	5d                   	pop    %ebp
80105192:	c3                   	ret
80105193:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105197:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80105198:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010519b:	e8 50 eb ff ff       	call   80103cf0 <myproc>
801051a0:	39 58 14             	cmp    %ebx,0x14(%eax)
801051a3:	0f 94 c0             	sete   %al
801051a6:	0f b6 c0             	movzbl %al,%eax
801051a9:	89 c7                	mov    %eax,%edi
801051ab:	eb d3                	jmp    80105180 <holdingsleep+0x20>
801051ad:	66 90                	xchg   %ax,%ax
801051af:	90                   	nop

801051b0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801051b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801051b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801051bf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801051c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051c9:	5d                   	pop    %ebp
801051ca:	c3                   	ret
801051cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801051cf:	90                   	nop

801051d0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801051d0:	55                   	push   %ebp
801051d1:	89 e5                	mov    %esp,%ebp
801051d3:	53                   	push   %ebx
801051d4:	8b 45 08             	mov    0x8(%ebp),%eax
801051d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801051da:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051dd:	05 f8 ff ff 7f       	add    $0x7ffffff8,%eax
801051e2:	3d fe ff ff 7f       	cmp    $0x7ffffffe,%eax
  for(i = 0; i < 10; i++){
801051e7:	b8 00 00 00 00       	mov    $0x0,%eax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051ec:	76 10                	jbe    801051fe <getcallerpcs+0x2e>
801051ee:	eb 28                	jmp    80105218 <getcallerpcs+0x48>
801051f0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801051f6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801051fc:	77 1a                	ja     80105218 <getcallerpcs+0x48>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051fe:	8b 5a 04             	mov    0x4(%edx),%ebx
80105201:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80105204:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80105207:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80105209:	83 f8 0a             	cmp    $0xa,%eax
8010520c:	75 e2                	jne    801051f0 <getcallerpcs+0x20>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010520e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105211:	c9                   	leave
80105212:	c3                   	ret
80105213:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105217:	90                   	nop
80105218:	8d 04 81             	lea    (%ecx,%eax,4),%eax
8010521b:	83 c1 28             	add    $0x28,%ecx
8010521e:	89 ca                	mov    %ecx,%edx
80105220:	29 c2                	sub    %eax,%edx
80105222:	83 e2 04             	and    $0x4,%edx
80105225:	74 11                	je     80105238 <getcallerpcs+0x68>
    pcs[i] = 0;
80105227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010522d:	83 c0 04             	add    $0x4,%eax
80105230:	39 c1                	cmp    %eax,%ecx
80105232:	74 da                	je     8010520e <getcallerpcs+0x3e>
80105234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pcs[i] = 0;
80105238:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010523e:	83 c0 08             	add    $0x8,%eax
    pcs[i] = 0;
80105241:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
  for(; i < 10; i++)
80105248:	39 c1                	cmp    %eax,%ecx
8010524a:	75 ec                	jne    80105238 <getcallerpcs+0x68>
8010524c:	eb c0                	jmp    8010520e <getcallerpcs+0x3e>
8010524e:	66 90                	xchg   %ax,%ax

80105250 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105250:	55                   	push   %ebp
80105251:	89 e5                	mov    %esp,%ebp
80105253:	53                   	push   %ebx
80105254:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105257:	9c                   	pushf
80105258:	5b                   	pop    %ebx
  asm volatile("cli");
80105259:	fa                   	cli
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
8010525a:	e8 11 ea ff ff       	call   80103c70 <mycpu>
8010525f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105265:	85 c0                	test   %eax,%eax
80105267:	74 17                	je     80105280 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80105269:	e8 02 ea ff ff       	call   80103c70 <mycpu>
8010526e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80105275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105278:	c9                   	leave
80105279:	c3                   	ret
8010527a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80105280:	e8 eb e9 ff ff       	call   80103c70 <mycpu>
80105285:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010528b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80105291:	eb d6                	jmp    80105269 <pushcli+0x19>
80105293:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010529a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801052a0 <popcli>:

void
popcli(void)
{
801052a0:	55                   	push   %ebp
801052a1:	89 e5                	mov    %esp,%ebp
801052a3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052a6:	9c                   	pushf
801052a7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801052a8:	f6 c4 02             	test   $0x2,%ah
801052ab:	75 35                	jne    801052e2 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
801052ad:	e8 be e9 ff ff       	call   80103c70 <mycpu>
801052b2:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
801052b9:	78 34                	js     801052ef <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801052bb:	e8 b0 e9 ff ff       	call   80103c70 <mycpu>
801052c0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801052c6:	85 d2                	test   %edx,%edx
801052c8:	74 06                	je     801052d0 <popcli+0x30>
    sti();
}
801052ca:	c9                   	leave
801052cb:	c3                   	ret
801052cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
801052d0:	e8 9b e9 ff ff       	call   80103c70 <mycpu>
801052d5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801052db:	85 c0                	test   %eax,%eax
801052dd:	74 eb                	je     801052ca <popcli+0x2a>
  asm volatile("sti");
801052df:	fb                   	sti
}
801052e0:	c9                   	leave
801052e1:	c3                   	ret
    panic("popcli - interruptible");
801052e2:	83 ec 0c             	sub    $0xc,%esp
801052e5:	68 16 86 10 80       	push   $0x80108616
801052ea:	e8 c1 b1 ff ff       	call   801004b0 <panic>
    panic("popcli");
801052ef:	83 ec 0c             	sub    $0xc,%esp
801052f2:	68 2d 86 10 80       	push   $0x8010862d
801052f7:	e8 b4 b1 ff ff       	call   801004b0 <panic>
801052fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105300 <holding>:
{
80105300:	55                   	push   %ebp
80105301:	89 e5                	mov    %esp,%ebp
80105303:	56                   	push   %esi
80105304:	53                   	push   %ebx
80105305:	8b 75 08             	mov    0x8(%ebp),%esi
80105308:	31 db                	xor    %ebx,%ebx
  pushcli();
8010530a:	e8 41 ff ff ff       	call   80105250 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010530f:	8b 06                	mov    (%esi),%eax
80105311:	85 c0                	test   %eax,%eax
80105313:	75 0b                	jne    80105320 <holding+0x20>
  popcli();
80105315:	e8 86 ff ff ff       	call   801052a0 <popcli>
}
8010531a:	89 d8                	mov    %ebx,%eax
8010531c:	5b                   	pop    %ebx
8010531d:	5e                   	pop    %esi
8010531e:	5d                   	pop    %ebp
8010531f:	c3                   	ret
  r = lock->locked && lock->cpu == mycpu();
80105320:	8b 5e 08             	mov    0x8(%esi),%ebx
80105323:	e8 48 e9 ff ff       	call   80103c70 <mycpu>
80105328:	39 c3                	cmp    %eax,%ebx
8010532a:	0f 94 c3             	sete   %bl
  popcli();
8010532d:	e8 6e ff ff ff       	call   801052a0 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80105332:	0f b6 db             	movzbl %bl,%ebx
}
80105335:	89 d8                	mov    %ebx,%eax
80105337:	5b                   	pop    %ebx
80105338:	5e                   	pop    %esi
80105339:	5d                   	pop    %ebp
8010533a:	c3                   	ret
8010533b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010533f:	90                   	nop

80105340 <release>:
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	56                   	push   %esi
80105344:	53                   	push   %ebx
80105345:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80105348:	e8 03 ff ff ff       	call   80105250 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010534d:	8b 03                	mov    (%ebx),%eax
8010534f:	85 c0                	test   %eax,%eax
80105351:	75 15                	jne    80105368 <release+0x28>
  popcli();
80105353:	e8 48 ff ff ff       	call   801052a0 <popcli>
    panic("release");
80105358:	83 ec 0c             	sub    $0xc,%esp
8010535b:	68 34 86 10 80       	push   $0x80108634
80105360:	e8 4b b1 ff ff       	call   801004b0 <panic>
80105365:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80105368:	8b 73 08             	mov    0x8(%ebx),%esi
8010536b:	e8 00 e9 ff ff       	call   80103c70 <mycpu>
80105370:	39 c6                	cmp    %eax,%esi
80105372:	75 df                	jne    80105353 <release+0x13>
  popcli();
80105374:	e8 27 ff ff ff       	call   801052a0 <popcli>
  lk->pcs[0] = 0;
80105379:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80105380:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80105387:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010538c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80105392:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105395:	5b                   	pop    %ebx
80105396:	5e                   	pop    %esi
80105397:	5d                   	pop    %ebp
  popcli();
80105398:	e9 03 ff ff ff       	jmp    801052a0 <popcli>
8010539d:	8d 76 00             	lea    0x0(%esi),%esi

801053a0 <acquire>:
{
801053a0:	55                   	push   %ebp
801053a1:	89 e5                	mov    %esp,%ebp
801053a3:	53                   	push   %ebx
801053a4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801053a7:	e8 a4 fe ff ff       	call   80105250 <pushcli>
  if(holding(lk))
801053ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801053af:	e8 9c fe ff ff       	call   80105250 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801053b4:	8b 03                	mov    (%ebx),%eax
801053b6:	85 c0                	test   %eax,%eax
801053b8:	0f 85 b2 00 00 00    	jne    80105470 <acquire+0xd0>
  popcli();
801053be:	e8 dd fe ff ff       	call   801052a0 <popcli>
  asm volatile("lock; xchgl %0, %1" :
801053c3:	b9 01 00 00 00       	mov    $0x1,%ecx
801053c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801053cf:	90                   	nop
  while(xchg(&lk->locked, 1) != 0)
801053d0:	8b 55 08             	mov    0x8(%ebp),%edx
801053d3:	89 c8                	mov    %ecx,%eax
801053d5:	f0 87 02             	lock xchg %eax,(%edx)
801053d8:	85 c0                	test   %eax,%eax
801053da:	75 f4                	jne    801053d0 <acquire+0x30>
  __sync_synchronize();
801053dc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
801053e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
801053e4:	e8 87 e8 ff ff       	call   80103c70 <mycpu>
  getcallerpcs(&lk, lk->pcs);
801053e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  for(i = 0; i < 10; i++){
801053ec:	31 d2                	xor    %edx,%edx
  lk->cpu = mycpu();
801053ee:	89 43 08             	mov    %eax,0x8(%ebx)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053f1:	8d 85 00 00 00 80    	lea    -0x80000000(%ebp),%eax
801053f7:	3d fe ff ff 7f       	cmp    $0x7ffffffe,%eax
801053fc:	77 32                	ja     80105430 <acquire+0x90>
  ebp = (uint*)v - 2;
801053fe:	89 e8                	mov    %ebp,%eax
80105400:	eb 14                	jmp    80105416 <acquire+0x76>
80105402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105408:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
8010540e:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80105414:	77 1a                	ja     80105430 <acquire+0x90>
    pcs[i] = ebp[1];     // saved %eip
80105416:	8b 58 04             	mov    0x4(%eax),%ebx
80105419:	89 5c 91 0c          	mov    %ebx,0xc(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
8010541d:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80105420:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80105422:	83 fa 0a             	cmp    $0xa,%edx
80105425:	75 e1                	jne    80105408 <acquire+0x68>
}
80105427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010542a:	c9                   	leave
8010542b:	c3                   	ret
8010542c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105430:	8d 44 91 0c          	lea    0xc(%ecx,%edx,4),%eax
80105434:	83 c1 34             	add    $0x34,%ecx
80105437:	89 ca                	mov    %ecx,%edx
80105439:	29 c2                	sub    %eax,%edx
8010543b:	83 e2 04             	and    $0x4,%edx
8010543e:	74 10                	je     80105450 <acquire+0xb0>
    pcs[i] = 0;
80105440:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105446:	83 c0 04             	add    $0x4,%eax
80105449:	39 c1                	cmp    %eax,%ecx
8010544b:	74 da                	je     80105427 <acquire+0x87>
8010544d:	8d 76 00             	lea    0x0(%esi),%esi
    pcs[i] = 0;
80105450:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105456:	83 c0 08             	add    $0x8,%eax
    pcs[i] = 0;
80105459:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
  for(; i < 10; i++)
80105460:	39 c1                	cmp    %eax,%ecx
80105462:	75 ec                	jne    80105450 <acquire+0xb0>
80105464:	eb c1                	jmp    80105427 <acquire+0x87>
80105466:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010546d:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80105470:	8b 5b 08             	mov    0x8(%ebx),%ebx
80105473:	e8 f8 e7 ff ff       	call   80103c70 <mycpu>
80105478:	39 c3                	cmp    %eax,%ebx
8010547a:	0f 85 3e ff ff ff    	jne    801053be <acquire+0x1e>
  popcli();
80105480:	e8 1b fe ff ff       	call   801052a0 <popcli>
    panic("acquire");
80105485:	83 ec 0c             	sub    $0xc,%esp
80105488:	68 3c 86 10 80       	push   $0x8010863c
8010548d:	e8 1e b0 ff ff       	call   801004b0 <panic>
80105492:	66 90                	xchg   %ax,%ax
80105494:	66 90                	xchg   %ax,%ax
80105496:	66 90                	xchg   %ax,%ax
80105498:	66 90                	xchg   %ax,%ax
8010549a:	66 90                	xchg   %ax,%ax
8010549c:	66 90                	xchg   %ax,%ax
8010549e:	66 90                	xchg   %ax,%ax

801054a0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801054a0:	55                   	push   %ebp
801054a1:	89 e5                	mov    %esp,%ebp
801054a3:	57                   	push   %edi
801054a4:	8b 55 08             	mov    0x8(%ebp),%edx
801054a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
801054aa:	89 d0                	mov    %edx,%eax
801054ac:	09 c8                	or     %ecx,%eax
801054ae:	a8 03                	test   $0x3,%al
801054b0:	75 1e                	jne    801054d0 <memset+0x30>
    c &= 0xFF;
801054b2:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801054b6:	c1 e9 02             	shr    $0x2,%ecx
  asm volatile("cld; rep stosl" :
801054b9:	89 d7                	mov    %edx,%edi
801054bb:	69 c0 01 01 01 01    	imul   $0x1010101,%eax,%eax
801054c1:	fc                   	cld
801054c2:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
801054c4:	8b 7d fc             	mov    -0x4(%ebp),%edi
801054c7:	89 d0                	mov    %edx,%eax
801054c9:	c9                   	leave
801054ca:	c3                   	ret
801054cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801054cf:	90                   	nop
  asm volatile("cld; rep stosb" :
801054d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d3:	89 d7                	mov    %edx,%edi
801054d5:	fc                   	cld
801054d6:	f3 aa                	rep stos %al,%es:(%edi)
801054d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
801054db:	89 d0                	mov    %edx,%eax
801054dd:	c9                   	leave
801054de:	c3                   	ret
801054df:	90                   	nop

801054e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054e0:	55                   	push   %ebp
801054e1:	89 e5                	mov    %esp,%ebp
801054e3:	56                   	push   %esi
801054e4:	8b 75 10             	mov    0x10(%ebp),%esi
801054e7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ea:	53                   	push   %ebx
801054eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054ee:	85 f6                	test   %esi,%esi
801054f0:	74 2e                	je     80105520 <memcmp+0x40>
801054f2:	01 c6                	add    %eax,%esi
801054f4:	eb 14                	jmp    8010550a <memcmp+0x2a>
801054f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801054fd:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80105500:	83 c0 01             	add    $0x1,%eax
80105503:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80105506:	39 f0                	cmp    %esi,%eax
80105508:	74 16                	je     80105520 <memcmp+0x40>
    if(*s1 != *s2)
8010550a:	0f b6 08             	movzbl (%eax),%ecx
8010550d:	0f b6 1a             	movzbl (%edx),%ebx
80105510:	38 d9                	cmp    %bl,%cl
80105512:	74 ec                	je     80105500 <memcmp+0x20>
      return *s1 - *s2;
80105514:	0f b6 c1             	movzbl %cl,%eax
80105517:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80105519:	5b                   	pop    %ebx
8010551a:	5e                   	pop    %esi
8010551b:	5d                   	pop    %ebp
8010551c:	c3                   	ret
8010551d:	8d 76 00             	lea    0x0(%esi),%esi
80105520:	5b                   	pop    %ebx
  return 0;
80105521:	31 c0                	xor    %eax,%eax
}
80105523:	5e                   	pop    %esi
80105524:	5d                   	pop    %ebp
80105525:	c3                   	ret
80105526:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010552d:	8d 76 00             	lea    0x0(%esi),%esi

80105530 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105530:	55                   	push   %ebp
80105531:	89 e5                	mov    %esp,%ebp
80105533:	57                   	push   %edi
80105534:	8b 55 08             	mov    0x8(%ebp),%edx
80105537:	8b 45 10             	mov    0x10(%ebp),%eax
8010553a:	56                   	push   %esi
8010553b:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010553e:	39 d6                	cmp    %edx,%esi
80105540:	73 26                	jae    80105568 <memmove+0x38>
80105542:	8d 0c 06             	lea    (%esi,%eax,1),%ecx
80105545:	39 ca                	cmp    %ecx,%edx
80105547:	73 1f                	jae    80105568 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
80105549:	85 c0                	test   %eax,%eax
8010554b:	74 0f                	je     8010555c <memmove+0x2c>
8010554d:	83 e8 01             	sub    $0x1,%eax
      *--d = *--s;
80105550:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80105554:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80105557:	83 e8 01             	sub    $0x1,%eax
8010555a:	73 f4                	jae    80105550 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
8010555c:	5e                   	pop    %esi
8010555d:	89 d0                	mov    %edx,%eax
8010555f:	5f                   	pop    %edi
80105560:	5d                   	pop    %ebp
80105561:	c3                   	ret
80105562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80105568:	8d 0c 06             	lea    (%esi,%eax,1),%ecx
8010556b:	89 d7                	mov    %edx,%edi
8010556d:	85 c0                	test   %eax,%eax
8010556f:	74 eb                	je     8010555c <memmove+0x2c>
80105571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80105578:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80105579:	39 ce                	cmp    %ecx,%esi
8010557b:	75 fb                	jne    80105578 <memmove+0x48>
}
8010557d:	5e                   	pop    %esi
8010557e:	89 d0                	mov    %edx,%eax
80105580:	5f                   	pop    %edi
80105581:	5d                   	pop    %ebp
80105582:	c3                   	ret
80105583:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010558a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105590 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80105590:	eb 9e                	jmp    80105530 <memmove>
80105592:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801055a0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
801055a0:	55                   	push   %ebp
801055a1:	89 e5                	mov    %esp,%ebp
801055a3:	53                   	push   %ebx
801055a4:	8b 55 10             	mov    0x10(%ebp),%edx
801055a7:	8b 45 08             	mov    0x8(%ebp),%eax
801055aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(n > 0 && *p && *p == *q)
801055ad:	85 d2                	test   %edx,%edx
801055af:	75 16                	jne    801055c7 <strncmp+0x27>
801055b1:	eb 2d                	jmp    801055e0 <strncmp+0x40>
801055b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801055b7:	90                   	nop
801055b8:	3a 19                	cmp    (%ecx),%bl
801055ba:	75 12                	jne    801055ce <strncmp+0x2e>
    n--, p++, q++;
801055bc:	83 c0 01             	add    $0x1,%eax
801055bf:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801055c2:	83 ea 01             	sub    $0x1,%edx
801055c5:	74 19                	je     801055e0 <strncmp+0x40>
801055c7:	0f b6 18             	movzbl (%eax),%ebx
801055ca:	84 db                	test   %bl,%bl
801055cc:	75 ea                	jne    801055b8 <strncmp+0x18>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
801055ce:	0f b6 00             	movzbl (%eax),%eax
801055d1:	0f b6 11             	movzbl (%ecx),%edx
}
801055d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801055d7:	c9                   	leave
  return (uchar)*p - (uchar)*q;
801055d8:	29 d0                	sub    %edx,%eax
}
801055da:	c3                   	ret
801055db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801055df:	90                   	nop
801055e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
801055e3:	31 c0                	xor    %eax,%eax
}
801055e5:	c9                   	leave
801055e6:	c3                   	ret
801055e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801055ee:	66 90                	xchg   %ax,%ax

801055f0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055f0:	55                   	push   %ebp
801055f1:	89 e5                	mov    %esp,%ebp
801055f3:	57                   	push   %edi
801055f4:	56                   	push   %esi
801055f5:	8b 75 08             	mov    0x8(%ebp),%esi
801055f8:	53                   	push   %ebx
801055f9:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
801055fc:	89 f0                	mov    %esi,%eax
801055fe:	eb 15                	jmp    80105615 <strncpy+0x25>
80105600:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105604:	8b 7d 0c             	mov    0xc(%ebp),%edi
80105607:	83 c0 01             	add    $0x1,%eax
8010560a:	0f b6 4f ff          	movzbl -0x1(%edi),%ecx
8010560e:	88 48 ff             	mov    %cl,-0x1(%eax)
80105611:	84 c9                	test   %cl,%cl
80105613:	74 13                	je     80105628 <strncpy+0x38>
80105615:	89 d3                	mov    %edx,%ebx
80105617:	83 ea 01             	sub    $0x1,%edx
8010561a:	85 db                	test   %ebx,%ebx
8010561c:	7f e2                	jg     80105600 <strncpy+0x10>
    ;
  while(n-- > 0)
    *s++ = 0;
  return os;
}
8010561e:	5b                   	pop    %ebx
8010561f:	89 f0                	mov    %esi,%eax
80105621:	5e                   	pop    %esi
80105622:	5f                   	pop    %edi
80105623:	5d                   	pop    %ebp
80105624:	c3                   	ret
80105625:	8d 76 00             	lea    0x0(%esi),%esi
  while(n-- > 0)
80105628:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
8010562b:	83 e9 01             	sub    $0x1,%ecx
8010562e:	85 d2                	test   %edx,%edx
80105630:	74 ec                	je     8010561e <strncpy+0x2e>
80105632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    *s++ = 0;
80105638:	83 c0 01             	add    $0x1,%eax
8010563b:	89 ca                	mov    %ecx,%edx
8010563d:	c6 40 ff 00          	movb   $0x0,-0x1(%eax)
  while(n-- > 0)
80105641:	29 c2                	sub    %eax,%edx
80105643:	85 d2                	test   %edx,%edx
80105645:	7f f1                	jg     80105638 <strncpy+0x48>
}
80105647:	5b                   	pop    %ebx
80105648:	89 f0                	mov    %esi,%eax
8010564a:	5e                   	pop    %esi
8010564b:	5f                   	pop    %edi
8010564c:	5d                   	pop    %ebp
8010564d:	c3                   	ret
8010564e:	66 90                	xchg   %ax,%ax

80105650 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105650:	55                   	push   %ebp
80105651:	89 e5                	mov    %esp,%ebp
80105653:	56                   	push   %esi
80105654:	8b 55 10             	mov    0x10(%ebp),%edx
80105657:	8b 75 08             	mov    0x8(%ebp),%esi
8010565a:	53                   	push   %ebx
8010565b:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
8010565e:	85 d2                	test   %edx,%edx
80105660:	7e 25                	jle    80105687 <safestrcpy+0x37>
80105662:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80105666:	89 f2                	mov    %esi,%edx
80105668:	eb 16                	jmp    80105680 <safestrcpy+0x30>
8010566a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80105670:	0f b6 08             	movzbl (%eax),%ecx
80105673:	83 c0 01             	add    $0x1,%eax
80105676:	83 c2 01             	add    $0x1,%edx
80105679:	88 4a ff             	mov    %cl,-0x1(%edx)
8010567c:	84 c9                	test   %cl,%cl
8010567e:	74 04                	je     80105684 <safestrcpy+0x34>
80105680:	39 d8                	cmp    %ebx,%eax
80105682:	75 ec                	jne    80105670 <safestrcpy+0x20>
    ;
  *s = 0;
80105684:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80105687:	89 f0                	mov    %esi,%eax
80105689:	5b                   	pop    %ebx
8010568a:	5e                   	pop    %esi
8010568b:	5d                   	pop    %ebp
8010568c:	c3                   	ret
8010568d:	8d 76 00             	lea    0x0(%esi),%esi

80105690 <strlen>:

int
strlen(const char *s)
{
80105690:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80105691:	31 c0                	xor    %eax,%eax
{
80105693:	89 e5                	mov    %esp,%ebp
80105695:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80105698:	80 3a 00             	cmpb   $0x0,(%edx)
8010569b:	74 0c                	je     801056a9 <strlen+0x19>
8010569d:	8d 76 00             	lea    0x0(%esi),%esi
801056a0:	83 c0 01             	add    $0x1,%eax
801056a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801056a7:	75 f7                	jne    801056a0 <strlen+0x10>
    ;
  return n;
}
801056a9:	5d                   	pop    %ebp
801056aa:	c3                   	ret

801056ab <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056ab:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056af:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801056b3:	55                   	push   %ebp
  pushl %ebx
801056b4:	53                   	push   %ebx
  pushl %esi
801056b5:	56                   	push   %esi
  pushl %edi
801056b6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056b7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056b9:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801056bb:	5f                   	pop    %edi
  popl %esi
801056bc:	5e                   	pop    %esi
  popl %ebx
801056bd:	5b                   	pop    %ebx
  popl %ebp
801056be:	5d                   	pop    %ebp
  ret
801056bf:	c3                   	ret

801056c0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801056c0:	55                   	push   %ebp
801056c1:	89 e5                	mov    %esp,%ebp
801056c3:	53                   	push   %ebx
801056c4:	83 ec 04             	sub    $0x4,%esp
801056c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801056ca:	e8 21 e6 ff ff       	call   80103cf0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801056cf:	8b 00                	mov    (%eax),%eax
801056d1:	39 c3                	cmp    %eax,%ebx
801056d3:	73 1b                	jae    801056f0 <fetchint+0x30>
801056d5:	8d 53 04             	lea    0x4(%ebx),%edx
801056d8:	39 d0                	cmp    %edx,%eax
801056da:	72 14                	jb     801056f0 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
801056dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801056df:	8b 13                	mov    (%ebx),%edx
801056e1:	89 10                	mov    %edx,(%eax)
  return 0;
801056e3:	31 c0                	xor    %eax,%eax
}
801056e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056e8:	c9                   	leave
801056e9:	c3                   	ret
801056ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801056f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f5:	eb ee                	jmp    801056e5 <fetchint+0x25>
801056f7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801056fe:	66 90                	xchg   %ax,%ax

80105700 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105700:	55                   	push   %ebp
80105701:	89 e5                	mov    %esp,%ebp
80105703:	53                   	push   %ebx
80105704:	83 ec 04             	sub    $0x4,%esp
80105707:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010570a:	e8 e1 e5 ff ff       	call   80103cf0 <myproc>

  if(addr >= curproc->sz)
8010570f:	3b 18                	cmp    (%eax),%ebx
80105711:	73 2d                	jae    80105740 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80105713:	8b 55 0c             	mov    0xc(%ebp),%edx
80105716:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80105718:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010571a:	39 d3                	cmp    %edx,%ebx
8010571c:	73 22                	jae    80105740 <fetchstr+0x40>
8010571e:	89 d8                	mov    %ebx,%eax
80105720:	eb 0d                	jmp    8010572f <fetchstr+0x2f>
80105722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105728:	83 c0 01             	add    $0x1,%eax
8010572b:	39 d0                	cmp    %edx,%eax
8010572d:	73 11                	jae    80105740 <fetchstr+0x40>
    if(*s == 0)
8010572f:	80 38 00             	cmpb   $0x0,(%eax)
80105732:	75 f4                	jne    80105728 <fetchstr+0x28>
      return s - *pp;
80105734:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80105736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105739:	c9                   	leave
8010573a:	c3                   	ret
8010573b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010573f:	90                   	nop
80105740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80105743:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105748:	c9                   	leave
80105749:	c3                   	ret
8010574a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105750 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105750:	55                   	push   %ebp
80105751:	89 e5                	mov    %esp,%ebp
80105753:	56                   	push   %esi
80105754:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105755:	e8 96 e5 ff ff       	call   80103cf0 <myproc>
8010575a:	8b 55 08             	mov    0x8(%ebp),%edx
8010575d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105760:	8b 40 44             	mov    0x44(%eax),%eax
80105763:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80105766:	e8 85 e5 ff ff       	call   80103cf0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010576b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010576e:	8b 00                	mov    (%eax),%eax
80105770:	39 c6                	cmp    %eax,%esi
80105772:	73 1c                	jae    80105790 <argint+0x40>
80105774:	8d 53 08             	lea    0x8(%ebx),%edx
80105777:	39 d0                	cmp    %edx,%eax
80105779:	72 15                	jb     80105790 <argint+0x40>
  *ip = *(int*)(addr);
8010577b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577e:	8b 53 04             	mov    0x4(%ebx),%edx
80105781:	89 10                	mov    %edx,(%eax)
  return 0;
80105783:	31 c0                	xor    %eax,%eax
}
80105785:	5b                   	pop    %ebx
80105786:	5e                   	pop    %esi
80105787:	5d                   	pop    %ebp
80105788:	c3                   	ret
80105789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105795:	eb ee                	jmp    80105785 <argint+0x35>
80105797:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010579e:	66 90                	xchg   %ax,%ax

801057a0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801057a0:	55                   	push   %ebp
801057a1:	89 e5                	mov    %esp,%ebp
801057a3:	57                   	push   %edi
801057a4:	56                   	push   %esi
801057a5:	53                   	push   %ebx
801057a6:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
801057a9:	e8 42 e5 ff ff       	call   80103cf0 <myproc>
801057ae:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801057b0:	e8 3b e5 ff ff       	call   80103cf0 <myproc>
801057b5:	8b 55 08             	mov    0x8(%ebp),%edx
801057b8:	8b 40 1c             	mov    0x1c(%eax),%eax
801057bb:	8b 40 44             	mov    0x44(%eax),%eax
801057be:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
801057c1:	e8 2a e5 ff ff       	call   80103cf0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801057c6:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
801057c9:	8b 00                	mov    (%eax),%eax
801057cb:	39 c7                	cmp    %eax,%edi
801057cd:	73 31                	jae    80105800 <argptr+0x60>
801057cf:	8d 4b 08             	lea    0x8(%ebx),%ecx
801057d2:	39 c8                	cmp    %ecx,%eax
801057d4:	72 2a                	jb     80105800 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801057d6:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
801057d9:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801057dc:	85 d2                	test   %edx,%edx
801057de:	78 20                	js     80105800 <argptr+0x60>
801057e0:	8b 16                	mov    (%esi),%edx
801057e2:	39 d0                	cmp    %edx,%eax
801057e4:	73 1a                	jae    80105800 <argptr+0x60>
801057e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
801057e9:	01 c3                	add    %eax,%ebx
801057eb:	39 da                	cmp    %ebx,%edx
801057ed:	72 11                	jb     80105800 <argptr+0x60>
    return -1;
  *pp = (char*)i;
801057ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801057f2:	89 02                	mov    %eax,(%edx)
  return 0;
801057f4:	31 c0                	xor    %eax,%eax
}
801057f6:	83 c4 0c             	add    $0xc,%esp
801057f9:	5b                   	pop    %ebx
801057fa:	5e                   	pop    %esi
801057fb:	5f                   	pop    %edi
801057fc:	5d                   	pop    %ebp
801057fd:	c3                   	ret
801057fe:	66 90                	xchg   %ax,%ax
    return -1;
80105800:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105805:	eb ef                	jmp    801057f6 <argptr+0x56>
80105807:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010580e:	66 90                	xchg   %ax,%ax

80105810 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105810:	55                   	push   %ebp
80105811:	89 e5                	mov    %esp,%ebp
80105813:	56                   	push   %esi
80105814:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105815:	e8 d6 e4 ff ff       	call   80103cf0 <myproc>
8010581a:	8b 55 08             	mov    0x8(%ebp),%edx
8010581d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105820:	8b 40 44             	mov    0x44(%eax),%eax
80105823:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80105826:	e8 c5 e4 ff ff       	call   80103cf0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010582b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010582e:	8b 00                	mov    (%eax),%eax
80105830:	39 c6                	cmp    %eax,%esi
80105832:	73 44                	jae    80105878 <argstr+0x68>
80105834:	8d 53 08             	lea    0x8(%ebx),%edx
80105837:	39 d0                	cmp    %edx,%eax
80105839:	72 3d                	jb     80105878 <argstr+0x68>
  *ip = *(int*)(addr);
8010583b:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
8010583e:	e8 ad e4 ff ff       	call   80103cf0 <myproc>
  if(addr >= curproc->sz)
80105843:	3b 18                	cmp    (%eax),%ebx
80105845:	73 31                	jae    80105878 <argstr+0x68>
  *pp = (char*)addr;
80105847:	8b 55 0c             	mov    0xc(%ebp),%edx
8010584a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010584c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010584e:	39 d3                	cmp    %edx,%ebx
80105850:	73 26                	jae    80105878 <argstr+0x68>
80105852:	89 d8                	mov    %ebx,%eax
80105854:	eb 11                	jmp    80105867 <argstr+0x57>
80105856:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010585d:	8d 76 00             	lea    0x0(%esi),%esi
80105860:	83 c0 01             	add    $0x1,%eax
80105863:	39 d0                	cmp    %edx,%eax
80105865:	73 11                	jae    80105878 <argstr+0x68>
    if(*s == 0)
80105867:	80 38 00             	cmpb   $0x0,(%eax)
8010586a:	75 f4                	jne    80105860 <argstr+0x50>
      return s - *pp;
8010586c:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
8010586e:	5b                   	pop    %ebx
8010586f:	5e                   	pop    %esi
80105870:	5d                   	pop    %ebp
80105871:	c3                   	ret
80105872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105878:	5b                   	pop    %ebx
    return -1;
80105879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010587e:	5e                   	pop    %esi
8010587f:	5d                   	pop    %ebp
80105880:	c3                   	ret
80105881:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105888:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010588f:	90                   	nop

80105890 <syscall>:
[SYS_getNumFreePages]   sys_getNumFreePages,
};

void
syscall(void)
{
80105890:	55                   	push   %ebp
80105891:	89 e5                	mov    %esp,%ebp
80105893:	53                   	push   %ebx
80105894:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80105897:	e8 54 e4 ff ff       	call   80103cf0 <myproc>
8010589c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010589e:	8b 40 1c             	mov    0x1c(%eax),%eax
801058a1:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801058a4:	8d 50 ff             	lea    -0x1(%eax),%edx
801058a7:	83 fa 16             	cmp    $0x16,%edx
801058aa:	77 24                	ja     801058d0 <syscall+0x40>
801058ac:	8b 14 85 c0 8c 10 80 	mov    -0x7fef7340(,%eax,4),%edx
801058b3:	85 d2                	test   %edx,%edx
801058b5:	74 19                	je     801058d0 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
801058b7:	ff d2                	call   *%edx
801058b9:	89 c2                	mov    %eax,%edx
801058bb:	8b 43 1c             	mov    0x1c(%ebx),%eax
801058be:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
801058c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801058c4:	c9                   	leave
801058c5:	c3                   	ret
801058c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801058cd:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
801058d0:	50                   	push   %eax
            curproc->pid, curproc->name, num);
801058d1:	8d 43 70             	lea    0x70(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
801058d4:	50                   	push   %eax
801058d5:	ff 73 14             	push   0x14(%ebx)
801058d8:	68 44 86 10 80       	push   $0x80108644
801058dd:	e8 fe ae ff ff       	call   801007e0 <cprintf>
    curproc->tf->eax = -1;
801058e2:	8b 43 1c             	mov    0x1c(%ebx),%eax
801058e5:	83 c4 10             	add    $0x10,%esp
801058e8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
801058ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801058f2:	c9                   	leave
801058f3:	c3                   	ret
801058f4:	66 90                	xchg   %ax,%ax
801058f6:	66 90                	xchg   %ax,%ax
801058f8:	66 90                	xchg   %ax,%ax
801058fa:	66 90                	xchg   %ax,%ax
801058fc:	66 90                	xchg   %ax,%ax
801058fe:	66 90                	xchg   %ax,%ax

80105900 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	57                   	push   %edi
80105904:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105905:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80105908:	53                   	push   %ebx
80105909:	83 ec 34             	sub    $0x34,%esp
8010590c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010590f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105912:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80105915:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80105918:	57                   	push   %edi
80105919:	50                   	push   %eax
8010591a:	e8 b1 c8 ff ff       	call   801021d0 <nameiparent>
8010591f:	83 c4 10             	add    $0x10,%esp
80105922:	85 c0                	test   %eax,%eax
80105924:	74 5e                	je     80105984 <create+0x84>
    return 0;
  ilock(dp);
80105926:	83 ec 0c             	sub    $0xc,%esp
80105929:	89 c3                	mov    %eax,%ebx
8010592b:	50                   	push   %eax
8010592c:	e8 9f bf ff ff       	call   801018d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80105931:	83 c4 0c             	add    $0xc,%esp
80105934:	6a 00                	push   $0x0
80105936:	57                   	push   %edi
80105937:	53                   	push   %ebx
80105938:	e8 e3 c4 ff ff       	call   80101e20 <dirlookup>
8010593d:	83 c4 10             	add    $0x10,%esp
80105940:	89 c6                	mov    %eax,%esi
80105942:	85 c0                	test   %eax,%eax
80105944:	74 4a                	je     80105990 <create+0x90>
    iunlockput(dp);
80105946:	83 ec 0c             	sub    $0xc,%esp
80105949:	53                   	push   %ebx
8010594a:	e8 11 c2 ff ff       	call   80101b60 <iunlockput>
    ilock(ip);
8010594f:	89 34 24             	mov    %esi,(%esp)
80105952:	e8 79 bf ff ff       	call   801018d0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105957:	83 c4 10             	add    $0x10,%esp
8010595a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010595f:	75 17                	jne    80105978 <create+0x78>
80105961:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80105966:	75 10                	jne    80105978 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80105968:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010596b:	89 f0                	mov    %esi,%eax
8010596d:	5b                   	pop    %ebx
8010596e:	5e                   	pop    %esi
8010596f:	5f                   	pop    %edi
80105970:	5d                   	pop    %ebp
80105971:	c3                   	ret
80105972:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(ip);
80105978:	83 ec 0c             	sub    $0xc,%esp
8010597b:	56                   	push   %esi
8010597c:	e8 df c1 ff ff       	call   80101b60 <iunlockput>
    return 0;
80105981:	83 c4 10             	add    $0x10,%esp
}
80105984:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80105987:	31 f6                	xor    %esi,%esi
}
80105989:	5b                   	pop    %ebx
8010598a:	89 f0                	mov    %esi,%eax
8010598c:	5e                   	pop    %esi
8010598d:	5f                   	pop    %edi
8010598e:	5d                   	pop    %ebp
8010598f:	c3                   	ret
  if((ip = ialloc(dp->dev, type)) == 0)
80105990:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80105994:	83 ec 08             	sub    $0x8,%esp
80105997:	50                   	push   %eax
80105998:	ff 33                	push   (%ebx)
8010599a:	e8 c1 bd ff ff       	call   80101760 <ialloc>
8010599f:	83 c4 10             	add    $0x10,%esp
801059a2:	89 c6                	mov    %eax,%esi
801059a4:	85 c0                	test   %eax,%eax
801059a6:	0f 84 bc 00 00 00    	je     80105a68 <create+0x168>
  ilock(ip);
801059ac:	83 ec 0c             	sub    $0xc,%esp
801059af:	50                   	push   %eax
801059b0:	e8 1b bf ff ff       	call   801018d0 <ilock>
  ip->major = major;
801059b5:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
801059b9:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
801059bd:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
801059c1:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
801059c5:	b8 01 00 00 00       	mov    $0x1,%eax
801059ca:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
801059ce:	89 34 24             	mov    %esi,(%esp)
801059d1:	e8 4a be ff ff       	call   80101820 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801059d6:	83 c4 10             	add    $0x10,%esp
801059d9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059de:	74 30                	je     80105a10 <create+0x110>
  if(dirlink(dp, name, ip->inum) < 0)
801059e0:	83 ec 04             	sub    $0x4,%esp
801059e3:	ff 76 04             	push   0x4(%esi)
801059e6:	57                   	push   %edi
801059e7:	53                   	push   %ebx
801059e8:	e8 03 c7 ff ff       	call   801020f0 <dirlink>
801059ed:	83 c4 10             	add    $0x10,%esp
801059f0:	85 c0                	test   %eax,%eax
801059f2:	78 67                	js     80105a5b <create+0x15b>
  iunlockput(dp);
801059f4:	83 ec 0c             	sub    $0xc,%esp
801059f7:	53                   	push   %ebx
801059f8:	e8 63 c1 ff ff       	call   80101b60 <iunlockput>
  return ip;
801059fd:	83 c4 10             	add    $0x10,%esp
}
80105a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a03:	89 f0                	mov    %esi,%eax
80105a05:	5b                   	pop    %ebx
80105a06:	5e                   	pop    %esi
80105a07:	5f                   	pop    %edi
80105a08:	5d                   	pop    %ebp
80105a09:	c3                   	ret
80105a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80105a10:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80105a13:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80105a18:	53                   	push   %ebx
80105a19:	e8 02 be ff ff       	call   80101820 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a1e:	83 c4 0c             	add    $0xc,%esp
80105a21:	ff 76 04             	push   0x4(%esi)
80105a24:	68 7c 86 10 80       	push   $0x8010867c
80105a29:	56                   	push   %esi
80105a2a:	e8 c1 c6 ff ff       	call   801020f0 <dirlink>
80105a2f:	83 c4 10             	add    $0x10,%esp
80105a32:	85 c0                	test   %eax,%eax
80105a34:	78 18                	js     80105a4e <create+0x14e>
80105a36:	83 ec 04             	sub    $0x4,%esp
80105a39:	ff 73 04             	push   0x4(%ebx)
80105a3c:	68 7b 86 10 80       	push   $0x8010867b
80105a41:	56                   	push   %esi
80105a42:	e8 a9 c6 ff ff       	call   801020f0 <dirlink>
80105a47:	83 c4 10             	add    $0x10,%esp
80105a4a:	85 c0                	test   %eax,%eax
80105a4c:	79 92                	jns    801059e0 <create+0xe0>
      panic("create dots");
80105a4e:	83 ec 0c             	sub    $0xc,%esp
80105a51:	68 6f 86 10 80       	push   $0x8010866f
80105a56:	e8 55 aa ff ff       	call   801004b0 <panic>
    panic("create: dirlink");
80105a5b:	83 ec 0c             	sub    $0xc,%esp
80105a5e:	68 7e 86 10 80       	push   $0x8010867e
80105a63:	e8 48 aa ff ff       	call   801004b0 <panic>
    panic("create: ialloc");
80105a68:	83 ec 0c             	sub    $0xc,%esp
80105a6b:	68 60 86 10 80       	push   $0x80108660
80105a70:	e8 3b aa ff ff       	call   801004b0 <panic>
80105a75:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a80 <sys_dup>:
{
80105a80:	55                   	push   %ebp
80105a81:	89 e5                	mov    %esp,%ebp
80105a83:	56                   	push   %esi
80105a84:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105a88:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80105a8b:	50                   	push   %eax
80105a8c:	6a 00                	push   $0x0
80105a8e:	e8 bd fc ff ff       	call   80105750 <argint>
80105a93:	83 c4 10             	add    $0x10,%esp
80105a96:	85 c0                	test   %eax,%eax
80105a98:	78 36                	js     80105ad0 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a9a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a9e:	77 30                	ja     80105ad0 <sys_dup+0x50>
80105aa0:	e8 4b e2 ff ff       	call   80103cf0 <myproc>
80105aa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aa8:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
80105aac:	85 f6                	test   %esi,%esi
80105aae:	74 20                	je     80105ad0 <sys_dup+0x50>
  struct proc *curproc = myproc();
80105ab0:	e8 3b e2 ff ff       	call   80103cf0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105ab5:	31 db                	xor    %ebx,%ebx
80105ab7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105abe:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105ac0:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80105ac4:	85 d2                	test   %edx,%edx
80105ac6:	74 18                	je     80105ae0 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80105ac8:	83 c3 01             	add    $0x1,%ebx
80105acb:	83 fb 10             	cmp    $0x10,%ebx
80105ace:	75 f0                	jne    80105ac0 <sys_dup+0x40>
}
80105ad0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80105ad3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105ad8:	89 d8                	mov    %ebx,%eax
80105ada:	5b                   	pop    %ebx
80105adb:	5e                   	pop    %esi
80105adc:	5d                   	pop    %ebp
80105add:	c3                   	ret
80105ade:	66 90                	xchg   %ax,%ax
  filedup(f);
80105ae0:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80105ae3:	89 74 98 2c          	mov    %esi,0x2c(%eax,%ebx,4)
  filedup(f);
80105ae7:	56                   	push   %esi
80105ae8:	e8 03 b5 ff ff       	call   80100ff0 <filedup>
  return fd;
80105aed:	83 c4 10             	add    $0x10,%esp
}
80105af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105af3:	89 d8                	mov    %ebx,%eax
80105af5:	5b                   	pop    %ebx
80105af6:	5e                   	pop    %esi
80105af7:	5d                   	pop    %ebp
80105af8:	c3                   	ret
80105af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105b00 <sys_read>:
{
80105b00:	55                   	push   %ebp
80105b01:	89 e5                	mov    %esp,%ebp
80105b03:	56                   	push   %esi
80105b04:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105b05:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105b08:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80105b0b:	53                   	push   %ebx
80105b0c:	6a 00                	push   $0x0
80105b0e:	e8 3d fc ff ff       	call   80105750 <argint>
80105b13:	83 c4 10             	add    $0x10,%esp
80105b16:	85 c0                	test   %eax,%eax
80105b18:	78 5e                	js     80105b78 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105b1a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b1e:	77 58                	ja     80105b78 <sys_read+0x78>
80105b20:	e8 cb e1 ff ff       	call   80103cf0 <myproc>
80105b25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b28:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
80105b2c:	85 f6                	test   %esi,%esi
80105b2e:	74 48                	je     80105b78 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b30:	83 ec 08             	sub    $0x8,%esp
80105b33:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b36:	50                   	push   %eax
80105b37:	6a 02                	push   $0x2
80105b39:	e8 12 fc ff ff       	call   80105750 <argint>
80105b3e:	83 c4 10             	add    $0x10,%esp
80105b41:	85 c0                	test   %eax,%eax
80105b43:	78 33                	js     80105b78 <sys_read+0x78>
80105b45:	83 ec 04             	sub    $0x4,%esp
80105b48:	ff 75 f0             	push   -0x10(%ebp)
80105b4b:	53                   	push   %ebx
80105b4c:	6a 01                	push   $0x1
80105b4e:	e8 4d fc ff ff       	call   801057a0 <argptr>
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	85 c0                	test   %eax,%eax
80105b58:	78 1e                	js     80105b78 <sys_read+0x78>
  return fileread(f, p, n);
80105b5a:	83 ec 04             	sub    $0x4,%esp
80105b5d:	ff 75 f0             	push   -0x10(%ebp)
80105b60:	ff 75 f4             	push   -0xc(%ebp)
80105b63:	56                   	push   %esi
80105b64:	e8 07 b6 ff ff       	call   80101170 <fileread>
80105b69:	83 c4 10             	add    $0x10,%esp
}
80105b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105b6f:	5b                   	pop    %ebx
80105b70:	5e                   	pop    %esi
80105b71:	5d                   	pop    %ebp
80105b72:	c3                   	ret
80105b73:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105b77:	90                   	nop
    return -1;
80105b78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7d:	eb ed                	jmp    80105b6c <sys_read+0x6c>
80105b7f:	90                   	nop

80105b80 <sys_write>:
{
80105b80:	55                   	push   %ebp
80105b81:	89 e5                	mov    %esp,%ebp
80105b83:	56                   	push   %esi
80105b84:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105b85:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105b88:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80105b8b:	53                   	push   %ebx
80105b8c:	6a 00                	push   $0x0
80105b8e:	e8 bd fb ff ff       	call   80105750 <argint>
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	78 5e                	js     80105bf8 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105b9a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b9e:	77 58                	ja     80105bf8 <sys_write+0x78>
80105ba0:	e8 4b e1 ff ff       	call   80103cf0 <myproc>
80105ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ba8:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
80105bac:	85 f6                	test   %esi,%esi
80105bae:	74 48                	je     80105bf8 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bb0:	83 ec 08             	sub    $0x8,%esp
80105bb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb6:	50                   	push   %eax
80105bb7:	6a 02                	push   $0x2
80105bb9:	e8 92 fb ff ff       	call   80105750 <argint>
80105bbe:	83 c4 10             	add    $0x10,%esp
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	78 33                	js     80105bf8 <sys_write+0x78>
80105bc5:	83 ec 04             	sub    $0x4,%esp
80105bc8:	ff 75 f0             	push   -0x10(%ebp)
80105bcb:	53                   	push   %ebx
80105bcc:	6a 01                	push   $0x1
80105bce:	e8 cd fb ff ff       	call   801057a0 <argptr>
80105bd3:	83 c4 10             	add    $0x10,%esp
80105bd6:	85 c0                	test   %eax,%eax
80105bd8:	78 1e                	js     80105bf8 <sys_write+0x78>
  return filewrite(f, p, n);
80105bda:	83 ec 04             	sub    $0x4,%esp
80105bdd:	ff 75 f0             	push   -0x10(%ebp)
80105be0:	ff 75 f4             	push   -0xc(%ebp)
80105be3:	56                   	push   %esi
80105be4:	e8 17 b6 ff ff       	call   80101200 <filewrite>
80105be9:	83 c4 10             	add    $0x10,%esp
}
80105bec:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105bef:	5b                   	pop    %ebx
80105bf0:	5e                   	pop    %esi
80105bf1:	5d                   	pop    %ebp
80105bf2:	c3                   	ret
80105bf3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105bf7:	90                   	nop
    return -1;
80105bf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfd:	eb ed                	jmp    80105bec <sys_write+0x6c>
80105bff:	90                   	nop

80105c00 <sys_close>:
{
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	56                   	push   %esi
80105c04:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105c05:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105c08:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80105c0b:	50                   	push   %eax
80105c0c:	6a 00                	push   $0x0
80105c0e:	e8 3d fb ff ff       	call   80105750 <argint>
80105c13:	83 c4 10             	add    $0x10,%esp
80105c16:	85 c0                	test   %eax,%eax
80105c18:	78 3e                	js     80105c58 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105c1a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105c1e:	77 38                	ja     80105c58 <sys_close+0x58>
80105c20:	e8 cb e0 ff ff       	call   80103cf0 <myproc>
80105c25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c28:	8d 5a 08             	lea    0x8(%edx),%ebx
80105c2b:	8b 74 98 0c          	mov    0xc(%eax,%ebx,4),%esi
80105c2f:	85 f6                	test   %esi,%esi
80105c31:	74 25                	je     80105c58 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
80105c33:	e8 b8 e0 ff ff       	call   80103cf0 <myproc>
  fileclose(f);
80105c38:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
80105c3b:	c7 44 98 0c 00 00 00 	movl   $0x0,0xc(%eax,%ebx,4)
80105c42:	00 
  fileclose(f);
80105c43:	56                   	push   %esi
80105c44:	e8 f7 b3 ff ff       	call   80101040 <fileclose>
  return 0;
80105c49:	83 c4 10             	add    $0x10,%esp
80105c4c:	31 c0                	xor    %eax,%eax
}
80105c4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105c51:	5b                   	pop    %ebx
80105c52:	5e                   	pop    %esi
80105c53:	5d                   	pop    %ebp
80105c54:	c3                   	ret
80105c55:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5d:	eb ef                	jmp    80105c4e <sys_close+0x4e>
80105c5f:	90                   	nop

80105c60 <sys_fstat>:
{
80105c60:	55                   	push   %ebp
80105c61:	89 e5                	mov    %esp,%ebp
80105c63:	56                   	push   %esi
80105c64:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105c65:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105c68:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80105c6b:	53                   	push   %ebx
80105c6c:	6a 00                	push   $0x0
80105c6e:	e8 dd fa ff ff       	call   80105750 <argint>
80105c73:	83 c4 10             	add    $0x10,%esp
80105c76:	85 c0                	test   %eax,%eax
80105c78:	78 46                	js     80105cc0 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105c7a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105c7e:	77 40                	ja     80105cc0 <sys_fstat+0x60>
80105c80:	e8 6b e0 ff ff       	call   80103cf0 <myproc>
80105c85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c88:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
80105c8c:	85 f6                	test   %esi,%esi
80105c8e:	74 30                	je     80105cc0 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c90:	83 ec 04             	sub    $0x4,%esp
80105c93:	6a 14                	push   $0x14
80105c95:	53                   	push   %ebx
80105c96:	6a 01                	push   $0x1
80105c98:	e8 03 fb ff ff       	call   801057a0 <argptr>
80105c9d:	83 c4 10             	add    $0x10,%esp
80105ca0:	85 c0                	test   %eax,%eax
80105ca2:	78 1c                	js     80105cc0 <sys_fstat+0x60>
  return filestat(f, st);
80105ca4:	83 ec 08             	sub    $0x8,%esp
80105ca7:	ff 75 f4             	push   -0xc(%ebp)
80105caa:	56                   	push   %esi
80105cab:	e8 70 b4 ff ff       	call   80101120 <filestat>
80105cb0:	83 c4 10             	add    $0x10,%esp
}
80105cb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105cb6:	5b                   	pop    %ebx
80105cb7:	5e                   	pop    %esi
80105cb8:	5d                   	pop    %ebp
80105cb9:	c3                   	ret
80105cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105cc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc5:	eb ec                	jmp    80105cb3 <sys_fstat+0x53>
80105cc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cce:	66 90                	xchg   %ax,%ax

80105cd0 <sys_link>:
{
80105cd0:	55                   	push   %ebp
80105cd1:	89 e5                	mov    %esp,%ebp
80105cd3:	57                   	push   %edi
80105cd4:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cd5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105cd8:	53                   	push   %ebx
80105cd9:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cdc:	50                   	push   %eax
80105cdd:	6a 00                	push   $0x0
80105cdf:	e8 2c fb ff ff       	call   80105810 <argstr>
80105ce4:	83 c4 10             	add    $0x10,%esp
80105ce7:	85 c0                	test   %eax,%eax
80105ce9:	0f 88 fb 00 00 00    	js     80105dea <sys_link+0x11a>
80105cef:	83 ec 08             	sub    $0x8,%esp
80105cf2:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105cf5:	50                   	push   %eax
80105cf6:	6a 01                	push   $0x1
80105cf8:	e8 13 fb ff ff       	call   80105810 <argstr>
80105cfd:	83 c4 10             	add    $0x10,%esp
80105d00:	85 c0                	test   %eax,%eax
80105d02:	0f 88 e2 00 00 00    	js     80105dea <sys_link+0x11a>
  begin_op();
80105d08:	e8 13 d2 ff ff       	call   80102f20 <begin_op>
  if((ip = namei(old)) == 0){
80105d0d:	83 ec 0c             	sub    $0xc,%esp
80105d10:	ff 75 d4             	push   -0x2c(%ebp)
80105d13:	e8 98 c4 ff ff       	call   801021b0 <namei>
80105d18:	83 c4 10             	add    $0x10,%esp
80105d1b:	89 c3                	mov    %eax,%ebx
80105d1d:	85 c0                	test   %eax,%eax
80105d1f:	0f 84 df 00 00 00    	je     80105e04 <sys_link+0x134>
  ilock(ip);
80105d25:	83 ec 0c             	sub    $0xc,%esp
80105d28:	50                   	push   %eax
80105d29:	e8 a2 bb ff ff       	call   801018d0 <ilock>
  if(ip->type == T_DIR){
80105d2e:	83 c4 10             	add    $0x10,%esp
80105d31:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105d36:	0f 84 b5 00 00 00    	je     80105df1 <sys_link+0x121>
  iupdate(ip);
80105d3c:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
80105d3f:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80105d44:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105d47:	53                   	push   %ebx
80105d48:	e8 d3 ba ff ff       	call   80101820 <iupdate>
  iunlock(ip);
80105d4d:	89 1c 24             	mov    %ebx,(%esp)
80105d50:	e8 5b bc ff ff       	call   801019b0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105d55:	58                   	pop    %eax
80105d56:	5a                   	pop    %edx
80105d57:	57                   	push   %edi
80105d58:	ff 75 d0             	push   -0x30(%ebp)
80105d5b:	e8 70 c4 ff ff       	call   801021d0 <nameiparent>
80105d60:	83 c4 10             	add    $0x10,%esp
80105d63:	89 c6                	mov    %eax,%esi
80105d65:	85 c0                	test   %eax,%eax
80105d67:	74 5b                	je     80105dc4 <sys_link+0xf4>
  ilock(dp);
80105d69:	83 ec 0c             	sub    $0xc,%esp
80105d6c:	50                   	push   %eax
80105d6d:	e8 5e bb ff ff       	call   801018d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d72:	8b 03                	mov    (%ebx),%eax
80105d74:	83 c4 10             	add    $0x10,%esp
80105d77:	39 06                	cmp    %eax,(%esi)
80105d79:	75 3d                	jne    80105db8 <sys_link+0xe8>
80105d7b:	83 ec 04             	sub    $0x4,%esp
80105d7e:	ff 73 04             	push   0x4(%ebx)
80105d81:	57                   	push   %edi
80105d82:	56                   	push   %esi
80105d83:	e8 68 c3 ff ff       	call   801020f0 <dirlink>
80105d88:	83 c4 10             	add    $0x10,%esp
80105d8b:	85 c0                	test   %eax,%eax
80105d8d:	78 29                	js     80105db8 <sys_link+0xe8>
  iunlockput(dp);
80105d8f:	83 ec 0c             	sub    $0xc,%esp
80105d92:	56                   	push   %esi
80105d93:	e8 c8 bd ff ff       	call   80101b60 <iunlockput>
  iput(ip);
80105d98:	89 1c 24             	mov    %ebx,(%esp)
80105d9b:	e8 60 bc ff ff       	call   80101a00 <iput>
  end_op();
80105da0:	e8 eb d1 ff ff       	call   80102f90 <end_op>
  return 0;
80105da5:	83 c4 10             	add    $0x10,%esp
80105da8:	31 c0                	xor    %eax,%eax
}
80105daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dad:	5b                   	pop    %ebx
80105dae:	5e                   	pop    %esi
80105daf:	5f                   	pop    %edi
80105db0:	5d                   	pop    %ebp
80105db1:	c3                   	ret
80105db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105db8:	83 ec 0c             	sub    $0xc,%esp
80105dbb:	56                   	push   %esi
80105dbc:	e8 9f bd ff ff       	call   80101b60 <iunlockput>
    goto bad;
80105dc1:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105dc4:	83 ec 0c             	sub    $0xc,%esp
80105dc7:	53                   	push   %ebx
80105dc8:	e8 03 bb ff ff       	call   801018d0 <ilock>
  ip->nlink--;
80105dcd:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105dd2:	89 1c 24             	mov    %ebx,(%esp)
80105dd5:	e8 46 ba ff ff       	call   80101820 <iupdate>
  iunlockput(ip);
80105dda:	89 1c 24             	mov    %ebx,(%esp)
80105ddd:	e8 7e bd ff ff       	call   80101b60 <iunlockput>
  end_op();
80105de2:	e8 a9 d1 ff ff       	call   80102f90 <end_op>
  return -1;
80105de7:	83 c4 10             	add    $0x10,%esp
    return -1;
80105dea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105def:	eb b9                	jmp    80105daa <sys_link+0xda>
    iunlockput(ip);
80105df1:	83 ec 0c             	sub    $0xc,%esp
80105df4:	53                   	push   %ebx
80105df5:	e8 66 bd ff ff       	call   80101b60 <iunlockput>
    end_op();
80105dfa:	e8 91 d1 ff ff       	call   80102f90 <end_op>
    return -1;
80105dff:	83 c4 10             	add    $0x10,%esp
80105e02:	eb e6                	jmp    80105dea <sys_link+0x11a>
    end_op();
80105e04:	e8 87 d1 ff ff       	call   80102f90 <end_op>
    return -1;
80105e09:	eb df                	jmp    80105dea <sys_link+0x11a>
80105e0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105e0f:	90                   	nop

80105e10 <sys_unlink>:
{
80105e10:	55                   	push   %ebp
80105e11:	89 e5                	mov    %esp,%ebp
80105e13:	57                   	push   %edi
80105e14:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80105e15:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105e18:	53                   	push   %ebx
80105e19:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
80105e1c:	50                   	push   %eax
80105e1d:	6a 00                	push   $0x0
80105e1f:	e8 ec f9 ff ff       	call   80105810 <argstr>
80105e24:	83 c4 10             	add    $0x10,%esp
80105e27:	85 c0                	test   %eax,%eax
80105e29:	0f 88 54 01 00 00    	js     80105f83 <sys_unlink+0x173>
  begin_op();
80105e2f:	e8 ec d0 ff ff       	call   80102f20 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e34:	8d 5d ca             	lea    -0x36(%ebp),%ebx
80105e37:	83 ec 08             	sub    $0x8,%esp
80105e3a:	53                   	push   %ebx
80105e3b:	ff 75 c0             	push   -0x40(%ebp)
80105e3e:	e8 8d c3 ff ff       	call   801021d0 <nameiparent>
80105e43:	83 c4 10             	add    $0x10,%esp
80105e46:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80105e49:	85 c0                	test   %eax,%eax
80105e4b:	0f 84 58 01 00 00    	je     80105fa9 <sys_unlink+0x199>
  ilock(dp);
80105e51:	8b 7d b4             	mov    -0x4c(%ebp),%edi
80105e54:	83 ec 0c             	sub    $0xc,%esp
80105e57:	57                   	push   %edi
80105e58:	e8 73 ba ff ff       	call   801018d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e5d:	58                   	pop    %eax
80105e5e:	5a                   	pop    %edx
80105e5f:	68 7c 86 10 80       	push   $0x8010867c
80105e64:	53                   	push   %ebx
80105e65:	e8 96 bf ff ff       	call   80101e00 <namecmp>
80105e6a:	83 c4 10             	add    $0x10,%esp
80105e6d:	85 c0                	test   %eax,%eax
80105e6f:	0f 84 fb 00 00 00    	je     80105f70 <sys_unlink+0x160>
80105e75:	83 ec 08             	sub    $0x8,%esp
80105e78:	68 7b 86 10 80       	push   $0x8010867b
80105e7d:	53                   	push   %ebx
80105e7e:	e8 7d bf ff ff       	call   80101e00 <namecmp>
80105e83:	83 c4 10             	add    $0x10,%esp
80105e86:	85 c0                	test   %eax,%eax
80105e88:	0f 84 e2 00 00 00    	je     80105f70 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
80105e8e:	83 ec 04             	sub    $0x4,%esp
80105e91:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105e94:	50                   	push   %eax
80105e95:	53                   	push   %ebx
80105e96:	57                   	push   %edi
80105e97:	e8 84 bf ff ff       	call   80101e20 <dirlookup>
80105e9c:	83 c4 10             	add    $0x10,%esp
80105e9f:	89 c3                	mov    %eax,%ebx
80105ea1:	85 c0                	test   %eax,%eax
80105ea3:	0f 84 c7 00 00 00    	je     80105f70 <sys_unlink+0x160>
  ilock(ip);
80105ea9:	83 ec 0c             	sub    $0xc,%esp
80105eac:	50                   	push   %eax
80105ead:	e8 1e ba ff ff       	call   801018d0 <ilock>
  if(ip->nlink < 1)
80105eb2:	83 c4 10             	add    $0x10,%esp
80105eb5:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80105eba:	0f 8e 0a 01 00 00    	jle    80105fca <sys_unlink+0x1ba>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ec0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105ec5:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105ec8:	74 66                	je     80105f30 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105eca:	83 ec 04             	sub    $0x4,%esp
80105ecd:	6a 10                	push   $0x10
80105ecf:	6a 00                	push   $0x0
80105ed1:	57                   	push   %edi
80105ed2:	e8 c9 f5 ff ff       	call   801054a0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ed7:	6a 10                	push   $0x10
80105ed9:	ff 75 c4             	push   -0x3c(%ebp)
80105edc:	57                   	push   %edi
80105edd:	ff 75 b4             	push   -0x4c(%ebp)
80105ee0:	e8 fb bd ff ff       	call   80101ce0 <writei>
80105ee5:	83 c4 20             	add    $0x20,%esp
80105ee8:	83 f8 10             	cmp    $0x10,%eax
80105eeb:	0f 85 cc 00 00 00    	jne    80105fbd <sys_unlink+0x1ad>
  if(ip->type == T_DIR){
80105ef1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105ef6:	0f 84 94 00 00 00    	je     80105f90 <sys_unlink+0x180>
  iunlockput(dp);
80105efc:	83 ec 0c             	sub    $0xc,%esp
80105eff:	ff 75 b4             	push   -0x4c(%ebp)
80105f02:	e8 59 bc ff ff       	call   80101b60 <iunlockput>
  ip->nlink--;
80105f07:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105f0c:	89 1c 24             	mov    %ebx,(%esp)
80105f0f:	e8 0c b9 ff ff       	call   80101820 <iupdate>
  iunlockput(ip);
80105f14:	89 1c 24             	mov    %ebx,(%esp)
80105f17:	e8 44 bc ff ff       	call   80101b60 <iunlockput>
  end_op();
80105f1c:	e8 6f d0 ff ff       	call   80102f90 <end_op>
  return 0;
80105f21:	83 c4 10             	add    $0x10,%esp
80105f24:	31 c0                	xor    %eax,%eax
}
80105f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f29:	5b                   	pop    %ebx
80105f2a:	5e                   	pop    %esi
80105f2b:	5f                   	pop    %edi
80105f2c:	5d                   	pop    %ebp
80105f2d:	c3                   	ret
80105f2e:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f30:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105f34:	76 94                	jbe    80105eca <sys_unlink+0xba>
80105f36:	be 20 00 00 00       	mov    $0x20,%esi
80105f3b:	eb 0b                	jmp    80105f48 <sys_unlink+0x138>
80105f3d:	8d 76 00             	lea    0x0(%esi),%esi
80105f40:	83 c6 10             	add    $0x10,%esi
80105f43:	3b 73 58             	cmp    0x58(%ebx),%esi
80105f46:	73 82                	jae    80105eca <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f48:	6a 10                	push   $0x10
80105f4a:	56                   	push   %esi
80105f4b:	57                   	push   %edi
80105f4c:	53                   	push   %ebx
80105f4d:	e8 8e bc ff ff       	call   80101be0 <readi>
80105f52:	83 c4 10             	add    $0x10,%esp
80105f55:	83 f8 10             	cmp    $0x10,%eax
80105f58:	75 56                	jne    80105fb0 <sys_unlink+0x1a0>
    if(de.inum != 0)
80105f5a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80105f5f:	74 df                	je     80105f40 <sys_unlink+0x130>
    iunlockput(ip);
80105f61:	83 ec 0c             	sub    $0xc,%esp
80105f64:	53                   	push   %ebx
80105f65:	e8 f6 bb ff ff       	call   80101b60 <iunlockput>
    goto bad;
80105f6a:	83 c4 10             	add    $0x10,%esp
80105f6d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105f70:	83 ec 0c             	sub    $0xc,%esp
80105f73:	ff 75 b4             	push   -0x4c(%ebp)
80105f76:	e8 e5 bb ff ff       	call   80101b60 <iunlockput>
  end_op();
80105f7b:	e8 10 d0 ff ff       	call   80102f90 <end_op>
  return -1;
80105f80:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f88:	eb 9c                	jmp    80105f26 <sys_unlink+0x116>
80105f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105f90:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105f93:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105f96:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
80105f9b:	50                   	push   %eax
80105f9c:	e8 7f b8 ff ff       	call   80101820 <iupdate>
80105fa1:	83 c4 10             	add    $0x10,%esp
80105fa4:	e9 53 ff ff ff       	jmp    80105efc <sys_unlink+0xec>
    end_op();
80105fa9:	e8 e2 cf ff ff       	call   80102f90 <end_op>
    return -1;
80105fae:	eb d3                	jmp    80105f83 <sys_unlink+0x173>
      panic("isdirempty: readi");
80105fb0:	83 ec 0c             	sub    $0xc,%esp
80105fb3:	68 a0 86 10 80       	push   $0x801086a0
80105fb8:	e8 f3 a4 ff ff       	call   801004b0 <panic>
    panic("unlink: writei");
80105fbd:	83 ec 0c             	sub    $0xc,%esp
80105fc0:	68 b2 86 10 80       	push   $0x801086b2
80105fc5:	e8 e6 a4 ff ff       	call   801004b0 <panic>
    panic("unlink: nlink < 1");
80105fca:	83 ec 0c             	sub    $0xc,%esp
80105fcd:	68 8e 86 10 80       	push   $0x8010868e
80105fd2:	e8 d9 a4 ff ff       	call   801004b0 <panic>
80105fd7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105fde:	66 90                	xchg   %ax,%ax

80105fe0 <sys_open>:

int
sys_open(void)
{
80105fe0:	55                   	push   %ebp
80105fe1:	89 e5                	mov    %esp,%ebp
80105fe3:	57                   	push   %edi
80105fe4:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105fe5:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105fe8:	53                   	push   %ebx
80105fe9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105fec:	50                   	push   %eax
80105fed:	6a 00                	push   $0x0
80105fef:	e8 1c f8 ff ff       	call   80105810 <argstr>
80105ff4:	83 c4 10             	add    $0x10,%esp
80105ff7:	85 c0                	test   %eax,%eax
80105ff9:	0f 88 8e 00 00 00    	js     8010608d <sys_open+0xad>
80105fff:	83 ec 08             	sub    $0x8,%esp
80106002:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106005:	50                   	push   %eax
80106006:	6a 01                	push   $0x1
80106008:	e8 43 f7 ff ff       	call   80105750 <argint>
8010600d:	83 c4 10             	add    $0x10,%esp
80106010:	85 c0                	test   %eax,%eax
80106012:	78 79                	js     8010608d <sys_open+0xad>
    return -1;

  begin_op();
80106014:	e8 07 cf ff ff       	call   80102f20 <begin_op>

  if(omode & O_CREATE){
80106019:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
8010601d:	75 79                	jne    80106098 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
8010601f:	83 ec 0c             	sub    $0xc,%esp
80106022:	ff 75 e0             	push   -0x20(%ebp)
80106025:	e8 86 c1 ff ff       	call   801021b0 <namei>
8010602a:	83 c4 10             	add    $0x10,%esp
8010602d:	89 c6                	mov    %eax,%esi
8010602f:	85 c0                	test   %eax,%eax
80106031:	0f 84 7e 00 00 00    	je     801060b5 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80106037:	83 ec 0c             	sub    $0xc,%esp
8010603a:	50                   	push   %eax
8010603b:	e8 90 b8 ff ff       	call   801018d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106040:	83 c4 10             	add    $0x10,%esp
80106043:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80106048:	0f 84 ba 00 00 00    	je     80106108 <sys_open+0x128>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010604e:	e8 2d af ff ff       	call   80100f80 <filealloc>
80106053:	89 c7                	mov    %eax,%edi
80106055:	85 c0                	test   %eax,%eax
80106057:	74 23                	je     8010607c <sys_open+0x9c>
  struct proc *curproc = myproc();
80106059:	e8 92 dc ff ff       	call   80103cf0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010605e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80106060:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80106064:	85 d2                	test   %edx,%edx
80106066:	74 58                	je     801060c0 <sys_open+0xe0>
  for(fd = 0; fd < NOFILE; fd++){
80106068:	83 c3 01             	add    $0x1,%ebx
8010606b:	83 fb 10             	cmp    $0x10,%ebx
8010606e:	75 f0                	jne    80106060 <sys_open+0x80>
    if(f)
      fileclose(f);
80106070:	83 ec 0c             	sub    $0xc,%esp
80106073:	57                   	push   %edi
80106074:	e8 c7 af ff ff       	call   80101040 <fileclose>
80106079:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010607c:	83 ec 0c             	sub    $0xc,%esp
8010607f:	56                   	push   %esi
80106080:	e8 db ba ff ff       	call   80101b60 <iunlockput>
    end_op();
80106085:	e8 06 cf ff ff       	call   80102f90 <end_op>
    return -1;
8010608a:	83 c4 10             	add    $0x10,%esp
    return -1;
8010608d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80106092:	eb 65                	jmp    801060f9 <sys_open+0x119>
80106094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80106098:	83 ec 0c             	sub    $0xc,%esp
8010609b:	31 c9                	xor    %ecx,%ecx
8010609d:	ba 02 00 00 00       	mov    $0x2,%edx
801060a2:	6a 00                	push   $0x0
801060a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060a7:	e8 54 f8 ff ff       	call   80105900 <create>
    if(ip == 0){
801060ac:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
801060af:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801060b1:	85 c0                	test   %eax,%eax
801060b3:	75 99                	jne    8010604e <sys_open+0x6e>
      end_op();
801060b5:	e8 d6 ce ff ff       	call   80102f90 <end_op>
      return -1;
801060ba:	eb d1                	jmp    8010608d <sys_open+0xad>
801060bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
801060c0:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801060c3:	89 7c 98 2c          	mov    %edi,0x2c(%eax,%ebx,4)
  iunlock(ip);
801060c7:	56                   	push   %esi
801060c8:	e8 e3 b8 ff ff       	call   801019b0 <iunlock>
  end_op();
801060cd:	e8 be ce ff ff       	call   80102f90 <end_op>

  f->type = FD_INODE;
801060d2:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801060d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060db:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
801060de:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
801060e1:	89 d0                	mov    %edx,%eax
  f->off = 0;
801060e3:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
801060ea:	f7 d0                	not    %eax
801060ec:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060ef:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
801060f2:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060f5:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
801060f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060fc:	89 d8                	mov    %ebx,%eax
801060fe:	5b                   	pop    %ebx
801060ff:	5e                   	pop    %esi
80106100:	5f                   	pop    %edi
80106101:	5d                   	pop    %ebp
80106102:	c3                   	ret
80106103:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106107:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
80106108:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010610b:	85 c9                	test   %ecx,%ecx
8010610d:	0f 84 3b ff ff ff    	je     8010604e <sys_open+0x6e>
80106113:	e9 64 ff ff ff       	jmp    8010607c <sys_open+0x9c>
80106118:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010611f:	90                   	nop

80106120 <sys_mkdir>:

int
sys_mkdir(void)
{
80106120:	55                   	push   %ebp
80106121:	89 e5                	mov    %esp,%ebp
80106123:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106126:	e8 f5 cd ff ff       	call   80102f20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010612b:	83 ec 08             	sub    $0x8,%esp
8010612e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106131:	50                   	push   %eax
80106132:	6a 00                	push   $0x0
80106134:	e8 d7 f6 ff ff       	call   80105810 <argstr>
80106139:	83 c4 10             	add    $0x10,%esp
8010613c:	85 c0                	test   %eax,%eax
8010613e:	78 30                	js     80106170 <sys_mkdir+0x50>
80106140:	83 ec 0c             	sub    $0xc,%esp
80106143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106146:	31 c9                	xor    %ecx,%ecx
80106148:	ba 01 00 00 00       	mov    $0x1,%edx
8010614d:	6a 00                	push   $0x0
8010614f:	e8 ac f7 ff ff       	call   80105900 <create>
80106154:	83 c4 10             	add    $0x10,%esp
80106157:	85 c0                	test   %eax,%eax
80106159:	74 15                	je     80106170 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010615b:	83 ec 0c             	sub    $0xc,%esp
8010615e:	50                   	push   %eax
8010615f:	e8 fc b9 ff ff       	call   80101b60 <iunlockput>
  end_op();
80106164:	e8 27 ce ff ff       	call   80102f90 <end_op>
  return 0;
80106169:	83 c4 10             	add    $0x10,%esp
8010616c:	31 c0                	xor    %eax,%eax
}
8010616e:	c9                   	leave
8010616f:	c3                   	ret
    end_op();
80106170:	e8 1b ce ff ff       	call   80102f90 <end_op>
    return -1;
80106175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010617a:	c9                   	leave
8010617b:	c3                   	ret
8010617c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106180 <sys_mknod>:

int
sys_mknod(void)
{
80106180:	55                   	push   %ebp
80106181:	89 e5                	mov    %esp,%ebp
80106183:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106186:	e8 95 cd ff ff       	call   80102f20 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010618b:	83 ec 08             	sub    $0x8,%esp
8010618e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106191:	50                   	push   %eax
80106192:	6a 00                	push   $0x0
80106194:	e8 77 f6 ff ff       	call   80105810 <argstr>
80106199:	83 c4 10             	add    $0x10,%esp
8010619c:	85 c0                	test   %eax,%eax
8010619e:	78 60                	js     80106200 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801061a0:	83 ec 08             	sub    $0x8,%esp
801061a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061a6:	50                   	push   %eax
801061a7:	6a 01                	push   $0x1
801061a9:	e8 a2 f5 ff ff       	call   80105750 <argint>
  if((argstr(0, &path)) < 0 ||
801061ae:	83 c4 10             	add    $0x10,%esp
801061b1:	85 c0                	test   %eax,%eax
801061b3:	78 4b                	js     80106200 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
801061b5:	83 ec 08             	sub    $0x8,%esp
801061b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061bb:	50                   	push   %eax
801061bc:	6a 02                	push   $0x2
801061be:	e8 8d f5 ff ff       	call   80105750 <argint>
     argint(1, &major) < 0 ||
801061c3:	83 c4 10             	add    $0x10,%esp
801061c6:	85 c0                	test   %eax,%eax
801061c8:	78 36                	js     80106200 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061ca:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801061ce:	83 ec 0c             	sub    $0xc,%esp
801061d1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801061d5:	ba 03 00 00 00       	mov    $0x3,%edx
801061da:	50                   	push   %eax
801061db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061de:	e8 1d f7 ff ff       	call   80105900 <create>
     argint(2, &minor) < 0 ||
801061e3:	83 c4 10             	add    $0x10,%esp
801061e6:	85 c0                	test   %eax,%eax
801061e8:	74 16                	je     80106200 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801061ea:	83 ec 0c             	sub    $0xc,%esp
801061ed:	50                   	push   %eax
801061ee:	e8 6d b9 ff ff       	call   80101b60 <iunlockput>
  end_op();
801061f3:	e8 98 cd ff ff       	call   80102f90 <end_op>
  return 0;
801061f8:	83 c4 10             	add    $0x10,%esp
801061fb:	31 c0                	xor    %eax,%eax
}
801061fd:	c9                   	leave
801061fe:	c3                   	ret
801061ff:	90                   	nop
    end_op();
80106200:	e8 8b cd ff ff       	call   80102f90 <end_op>
    return -1;
80106205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010620a:	c9                   	leave
8010620b:	c3                   	ret
8010620c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106210 <sys_chdir>:

int
sys_chdir(void)
{
80106210:	55                   	push   %ebp
80106211:	89 e5                	mov    %esp,%ebp
80106213:	56                   	push   %esi
80106214:	53                   	push   %ebx
80106215:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106218:	e8 d3 da ff ff       	call   80103cf0 <myproc>
8010621d:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010621f:	e8 fc cc ff ff       	call   80102f20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106224:	83 ec 08             	sub    $0x8,%esp
80106227:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010622a:	50                   	push   %eax
8010622b:	6a 00                	push   $0x0
8010622d:	e8 de f5 ff ff       	call   80105810 <argstr>
80106232:	83 c4 10             	add    $0x10,%esp
80106235:	85 c0                	test   %eax,%eax
80106237:	78 77                	js     801062b0 <sys_chdir+0xa0>
80106239:	83 ec 0c             	sub    $0xc,%esp
8010623c:	ff 75 f4             	push   -0xc(%ebp)
8010623f:	e8 6c bf ff ff       	call   801021b0 <namei>
80106244:	83 c4 10             	add    $0x10,%esp
80106247:	89 c3                	mov    %eax,%ebx
80106249:	85 c0                	test   %eax,%eax
8010624b:	74 63                	je     801062b0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
8010624d:	83 ec 0c             	sub    $0xc,%esp
80106250:	50                   	push   %eax
80106251:	e8 7a b6 ff ff       	call   801018d0 <ilock>
  if(ip->type != T_DIR){
80106256:	83 c4 10             	add    $0x10,%esp
80106259:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010625e:	75 30                	jne    80106290 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80106260:	83 ec 0c             	sub    $0xc,%esp
80106263:	53                   	push   %ebx
80106264:	e8 47 b7 ff ff       	call   801019b0 <iunlock>
  iput(curproc->cwd);
80106269:	58                   	pop    %eax
8010626a:	ff 76 6c             	push   0x6c(%esi)
8010626d:	e8 8e b7 ff ff       	call   80101a00 <iput>
  end_op();
80106272:	e8 19 cd ff ff       	call   80102f90 <end_op>
  curproc->cwd = ip;
80106277:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
8010627a:	83 c4 10             	add    $0x10,%esp
8010627d:	31 c0                	xor    %eax,%eax
}
8010627f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106282:	5b                   	pop    %ebx
80106283:	5e                   	pop    %esi
80106284:	5d                   	pop    %ebp
80106285:	c3                   	ret
80106286:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010628d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80106290:	83 ec 0c             	sub    $0xc,%esp
80106293:	53                   	push   %ebx
80106294:	e8 c7 b8 ff ff       	call   80101b60 <iunlockput>
    end_op();
80106299:	e8 f2 cc ff ff       	call   80102f90 <end_op>
    return -1;
8010629e:	83 c4 10             	add    $0x10,%esp
    return -1;
801062a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a6:	eb d7                	jmp    8010627f <sys_chdir+0x6f>
801062a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801062af:	90                   	nop
    end_op();
801062b0:	e8 db cc ff ff       	call   80102f90 <end_op>
    return -1;
801062b5:	eb ea                	jmp    801062a1 <sys_chdir+0x91>
801062b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801062be:	66 90                	xchg   %ax,%ax

801062c0 <sys_exec>:

int
sys_exec(void)
{
801062c0:	55                   	push   %ebp
801062c1:	89 e5                	mov    %esp,%ebp
801062c3:	57                   	push   %edi
801062c4:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062c5:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
801062cb:	53                   	push   %ebx
801062cc:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062d2:	50                   	push   %eax
801062d3:	6a 00                	push   $0x0
801062d5:	e8 36 f5 ff ff       	call   80105810 <argstr>
801062da:	83 c4 10             	add    $0x10,%esp
801062dd:	85 c0                	test   %eax,%eax
801062df:	0f 88 87 00 00 00    	js     8010636c <sys_exec+0xac>
801062e5:	83 ec 08             	sub    $0x8,%esp
801062e8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801062ee:	50                   	push   %eax
801062ef:	6a 01                	push   $0x1
801062f1:	e8 5a f4 ff ff       	call   80105750 <argint>
801062f6:	83 c4 10             	add    $0x10,%esp
801062f9:	85 c0                	test   %eax,%eax
801062fb:	78 6f                	js     8010636c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801062fd:	83 ec 04             	sub    $0x4,%esp
80106300:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80106306:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80106308:	68 80 00 00 00       	push   $0x80
8010630d:	6a 00                	push   $0x0
8010630f:	56                   	push   %esi
80106310:	e8 8b f1 ff ff       	call   801054a0 <memset>
80106315:	83 c4 10             	add    $0x10,%esp
80106318:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010631f:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106320:	83 ec 08             	sub    $0x8,%esp
80106323:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106329:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
80106330:	50                   	push   %eax
80106331:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106337:	01 f8                	add    %edi,%eax
80106339:	50                   	push   %eax
8010633a:	e8 81 f3 ff ff       	call   801056c0 <fetchint>
8010633f:	83 c4 10             	add    $0x10,%esp
80106342:	85 c0                	test   %eax,%eax
80106344:	78 26                	js     8010636c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80106346:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
8010634c:	85 c0                	test   %eax,%eax
8010634e:	74 30                	je     80106380 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106350:	83 ec 08             	sub    $0x8,%esp
80106353:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80106356:	52                   	push   %edx
80106357:	50                   	push   %eax
80106358:	e8 a3 f3 ff ff       	call   80105700 <fetchstr>
8010635d:	83 c4 10             	add    $0x10,%esp
80106360:	85 c0                	test   %eax,%eax
80106362:	78 08                	js     8010636c <sys_exec+0xac>
  for(i=0;; i++){
80106364:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80106367:	83 fb 20             	cmp    $0x20,%ebx
8010636a:	75 b4                	jne    80106320 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
8010636c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010636f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106374:	5b                   	pop    %ebx
80106375:	5e                   	pop    %esi
80106376:	5f                   	pop    %edi
80106377:	5d                   	pop    %ebp
80106378:	c3                   	ret
80106379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80106380:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80106387:	00 00 00 00 
  return exec(path, argv);
8010638b:	83 ec 08             	sub    $0x8,%esp
8010638e:	56                   	push   %esi
8010638f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80106395:	e8 46 a8 ff ff       	call   80100be0 <exec>
8010639a:	83 c4 10             	add    $0x10,%esp
}
8010639d:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063a0:	5b                   	pop    %ebx
801063a1:	5e                   	pop    %esi
801063a2:	5f                   	pop    %edi
801063a3:	5d                   	pop    %ebp
801063a4:	c3                   	ret
801063a5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801063ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801063b0 <sys_pipe>:

int
sys_pipe(void)
{
801063b0:	55                   	push   %ebp
801063b1:	89 e5                	mov    %esp,%ebp
801063b3:	57                   	push   %edi
801063b4:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
801063b8:	53                   	push   %ebx
801063b9:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063bc:	6a 08                	push   $0x8
801063be:	50                   	push   %eax
801063bf:	6a 00                	push   $0x0
801063c1:	e8 da f3 ff ff       	call   801057a0 <argptr>
801063c6:	83 c4 10             	add    $0x10,%esp
801063c9:	85 c0                	test   %eax,%eax
801063cb:	0f 88 8b 00 00 00    	js     8010645c <sys_pipe+0xac>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
801063d1:	83 ec 08             	sub    $0x8,%esp
801063d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063d7:	50                   	push   %eax
801063d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801063db:	50                   	push   %eax
801063dc:	e8 1f d2 ff ff       	call   80103600 <pipealloc>
801063e1:	83 c4 10             	add    $0x10,%esp
801063e4:	85 c0                	test   %eax,%eax
801063e6:	78 74                	js     8010645c <sys_pipe+0xac>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801063e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
801063eb:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
801063ed:	e8 fe d8 ff ff       	call   80103cf0 <myproc>
    if(curproc->ofile[fd] == 0){
801063f2:	8b 74 98 2c          	mov    0x2c(%eax,%ebx,4),%esi
801063f6:	85 f6                	test   %esi,%esi
801063f8:	74 16                	je     80106410 <sys_pipe+0x60>
801063fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(fd = 0; fd < NOFILE; fd++){
80106400:	83 c3 01             	add    $0x1,%ebx
80106403:	83 fb 10             	cmp    $0x10,%ebx
80106406:	74 3d                	je     80106445 <sys_pipe+0x95>
    if(curproc->ofile[fd] == 0){
80106408:	8b 74 98 2c          	mov    0x2c(%eax,%ebx,4),%esi
8010640c:	85 f6                	test   %esi,%esi
8010640e:	75 f0                	jne    80106400 <sys_pipe+0x50>
      curproc->ofile[fd] = f;
80106410:	8d 73 08             	lea    0x8(%ebx),%esi
80106413:	89 7c b0 0c          	mov    %edi,0xc(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
8010641a:	e8 d1 d8 ff ff       	call   80103cf0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010641f:	31 d2                	xor    %edx,%edx
80106421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80106428:	8b 4c 90 2c          	mov    0x2c(%eax,%edx,4),%ecx
8010642c:	85 c9                	test   %ecx,%ecx
8010642e:	74 38                	je     80106468 <sys_pipe+0xb8>
  for(fd = 0; fd < NOFILE; fd++){
80106430:	83 c2 01             	add    $0x1,%edx
80106433:	83 fa 10             	cmp    $0x10,%edx
80106436:	75 f0                	jne    80106428 <sys_pipe+0x78>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
80106438:	e8 b3 d8 ff ff       	call   80103cf0 <myproc>
8010643d:	c7 44 b0 0c 00 00 00 	movl   $0x0,0xc(%eax,%esi,4)
80106444:	00 
    fileclose(rf);
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	ff 75 e0             	push   -0x20(%ebp)
8010644b:	e8 f0 ab ff ff       	call   80101040 <fileclose>
    fileclose(wf);
80106450:	58                   	pop    %eax
80106451:	ff 75 e4             	push   -0x1c(%ebp)
80106454:	e8 e7 ab ff ff       	call   80101040 <fileclose>
    return -1;
80106459:	83 c4 10             	add    $0x10,%esp
    return -1;
8010645c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106461:	eb 16                	jmp    80106479 <sys_pipe+0xc9>
80106463:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106467:	90                   	nop
      curproc->ofile[fd] = f;
80106468:	89 7c 90 2c          	mov    %edi,0x2c(%eax,%edx,4)
  }
  fd[0] = fd0;
8010646c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010646f:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80106471:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106474:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80106477:	31 c0                	xor    %eax,%eax
}
80106479:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010647c:	5b                   	pop    %ebx
8010647d:	5e                   	pop    %esi
8010647e:	5f                   	pop    %edi
8010647f:	5d                   	pop    %ebp
80106480:	c3                   	ret
80106481:	66 90                	xchg   %ax,%ax
80106483:	66 90                	xchg   %ax,%ax
80106485:	66 90                	xchg   %ax,%ax
80106487:	66 90                	xchg   %ax,%ax
80106489:	66 90                	xchg   %ax,%ax
8010648b:	66 90                	xchg   %ax,%ax
8010648d:	66 90                	xchg   %ax,%ax
8010648f:	90                   	nop

80106490 <sys_getNumFreePages>:


int
sys_getNumFreePages(void)
{
  return num_of_FreePages();  
80106490:	e9 fb c3 ff ff       	jmp    80102890 <num_of_FreePages>
80106495:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010649c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801064a0 <sys_getrss>:
}

int 
sys_getrss()
{
801064a0:	55                   	push   %ebp
801064a1:	89 e5                	mov    %esp,%ebp
801064a3:	83 ec 08             	sub    $0x8,%esp
  print_rss();
801064a6:	e8 05 db ff ff       	call   80103fb0 <print_rss>
  return 0;
}
801064ab:	31 c0                	xor    %eax,%eax
801064ad:	c9                   	leave
801064ae:	c3                   	ret
801064af:	90                   	nop

801064b0 <sys_fork>:

int
sys_fork(void)
{
  return fork();
801064b0:	e9 db d9 ff ff       	jmp    80103e90 <fork>
801064b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801064bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801064c0 <sys_exit>:
}

int
sys_exit(void)
{
801064c0:	55                   	push   %ebp
801064c1:	89 e5                	mov    %esp,%ebp
801064c3:	83 ec 08             	sub    $0x8,%esp
  exit();
801064c6:	e8 b5 dc ff ff       	call   80104180 <exit>
  return 0;  // not reached
}
801064cb:	31 c0                	xor    %eax,%eax
801064cd:	c9                   	leave
801064ce:	c3                   	ret
801064cf:	90                   	nop

801064d0 <sys_wait>:

int
sys_wait(void)
{
  return wait();
801064d0:	e9 7b e9 ff ff       	jmp    80104e50 <wait>
801064d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801064dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801064e0 <sys_kill>:
}

int
sys_kill(void)
{
801064e0:	55                   	push   %ebp
801064e1:	89 e5                	mov    %esp,%ebp
801064e3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064e9:	50                   	push   %eax
801064ea:	6a 00                	push   $0x0
801064ec:	e8 5f f2 ff ff       	call   80105750 <argint>
801064f1:	83 c4 10             	add    $0x10,%esp
801064f4:	85 c0                	test   %eax,%eax
801064f6:	78 18                	js     80106510 <sys_kill+0x30>
    return -1;
  return kill(pid);
801064f8:	83 ec 0c             	sub    $0xc,%esp
801064fb:	ff 75 f4             	push   -0xc(%ebp)
801064fe:	e8 1d df ff ff       	call   80104420 <kill>
80106503:	83 c4 10             	add    $0x10,%esp
}
80106506:	c9                   	leave
80106507:	c3                   	ret
80106508:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010650f:	90                   	nop
80106510:	c9                   	leave
    return -1;
80106511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106516:	c3                   	ret
80106517:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010651e:	66 90                	xchg   %ax,%ax

80106520 <sys_getpid>:

int
sys_getpid(void)
{
80106520:	55                   	push   %ebp
80106521:	89 e5                	mov    %esp,%ebp
80106523:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106526:	e8 c5 d7 ff ff       	call   80103cf0 <myproc>
8010652b:	8b 40 14             	mov    0x14(%eax),%eax
}
8010652e:	c9                   	leave
8010652f:	c3                   	ret

80106530 <sys_sbrk>:

int
sys_sbrk(void)
{
80106530:	55                   	push   %ebp
80106531:	89 e5                	mov    %esp,%ebp
80106533:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106534:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80106537:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010653a:	50                   	push   %eax
8010653b:	6a 00                	push   $0x0
8010653d:	e8 0e f2 ff ff       	call   80105750 <argint>
80106542:	83 c4 10             	add    $0x10,%esp
80106545:	85 c0                	test   %eax,%eax
80106547:	78 27                	js     80106570 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80106549:	e8 a2 d7 ff ff       	call   80103cf0 <myproc>
  if(growproc(n) < 0)
8010654e:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80106551:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80106553:	ff 75 f4             	push   -0xc(%ebp)
80106556:	e8 b5 d8 ff ff       	call   80103e10 <growproc>
8010655b:	83 c4 10             	add    $0x10,%esp
8010655e:	85 c0                	test   %eax,%eax
80106560:	78 0e                	js     80106570 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80106562:	89 d8                	mov    %ebx,%eax
80106564:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106567:	c9                   	leave
80106568:	c3                   	ret
80106569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106570:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80106575:	eb eb                	jmp    80106562 <sys_sbrk+0x32>
80106577:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010657e:	66 90                	xchg   %ax,%ax

80106580 <sys_sleep>:

int
sys_sleep(void)
{
80106580:	55                   	push   %ebp
80106581:	89 e5                	mov    %esp,%ebp
80106583:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106584:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80106587:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010658a:	50                   	push   %eax
8010658b:	6a 00                	push   $0x0
8010658d:	e8 be f1 ff ff       	call   80105750 <argint>
80106592:	83 c4 10             	add    $0x10,%esp
80106595:	85 c0                	test   %eax,%eax
80106597:	78 64                	js     801065fd <sys_sleep+0x7d>
    return -1;
  acquire(&tickslock);
80106599:	83 ec 0c             	sub    $0xc,%esp
8010659c:	68 60 31 1c 80       	push   $0x801c3160
801065a1:	e8 fa ed ff ff       	call   801053a0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801065a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
801065a9:	8b 1d 40 31 1c 80    	mov    0x801c3140,%ebx
  while(ticks - ticks0 < n){
801065af:	83 c4 10             	add    $0x10,%esp
801065b2:	85 d2                	test   %edx,%edx
801065b4:	75 2b                	jne    801065e1 <sys_sleep+0x61>
801065b6:	eb 58                	jmp    80106610 <sys_sleep+0x90>
801065b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801065bf:	90                   	nop
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
801065c0:	83 ec 08             	sub    $0x8,%esp
801065c3:	68 60 31 1c 80       	push   $0x801c3160
801065c8:	68 40 31 1c 80       	push   $0x801c3140
801065cd:	e8 2e dd ff ff       	call   80104300 <sleep>
  while(ticks - ticks0 < n){
801065d2:	a1 40 31 1c 80       	mov    0x801c3140,%eax
801065d7:	83 c4 10             	add    $0x10,%esp
801065da:	29 d8                	sub    %ebx,%eax
801065dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801065df:	73 2f                	jae    80106610 <sys_sleep+0x90>
    if(myproc()->killed){
801065e1:	e8 0a d7 ff ff       	call   80103cf0 <myproc>
801065e6:	8b 40 28             	mov    0x28(%eax),%eax
801065e9:	85 c0                	test   %eax,%eax
801065eb:	74 d3                	je     801065c0 <sys_sleep+0x40>
      release(&tickslock);
801065ed:	83 ec 0c             	sub    $0xc,%esp
801065f0:	68 60 31 1c 80       	push   $0x801c3160
801065f5:	e8 46 ed ff ff       	call   80105340 <release>
      return -1;
801065fa:	83 c4 10             	add    $0x10,%esp
  }
  release(&tickslock);
  return 0;
}
801065fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80106600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106605:	c9                   	leave
80106606:	c3                   	ret
80106607:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010660e:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80106610:	83 ec 0c             	sub    $0xc,%esp
80106613:	68 60 31 1c 80       	push   $0x801c3160
80106618:	e8 23 ed ff ff       	call   80105340 <release>
}
8010661d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return 0;
80106620:	83 c4 10             	add    $0x10,%esp
80106623:	31 c0                	xor    %eax,%eax
}
80106625:	c9                   	leave
80106626:	c3                   	ret
80106627:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010662e:	66 90                	xchg   %ax,%ax

80106630 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106630:	55                   	push   %ebp
80106631:	89 e5                	mov    %esp,%ebp
80106633:	53                   	push   %ebx
80106634:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80106637:	68 60 31 1c 80       	push   $0x801c3160
8010663c:	e8 5f ed ff ff       	call   801053a0 <acquire>
  xticks = ticks;
80106641:	8b 1d 40 31 1c 80    	mov    0x801c3140,%ebx
  release(&tickslock);
80106647:	c7 04 24 60 31 1c 80 	movl   $0x801c3160,(%esp)
8010664e:	e8 ed ec ff ff       	call   80105340 <release>
  return xticks;
}
80106653:	89 d8                	mov    %ebx,%eax
80106655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106658:	c9                   	leave
80106659:	c3                   	ret

8010665a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010665a:	1e                   	push   %ds
  pushl %es
8010665b:	06                   	push   %es
  pushl %fs
8010665c:	0f a0                	push   %fs
  pushl %gs
8010665e:	0f a8                	push   %gs
  pushal
80106660:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106661:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106665:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106667:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106669:	54                   	push   %esp
  call trap
8010666a:	e8 c1 00 00 00       	call   80106730 <trap>
  addl $4, %esp
8010666f:	83 c4 04             	add    $0x4,%esp

80106672 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106672:	61                   	popa
  popl %gs
80106673:	0f a9                	pop    %gs
  popl %fs
80106675:	0f a1                	pop    %fs
  popl %es
80106677:	07                   	pop    %es
  popl %ds
80106678:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106679:	83 c4 08             	add    $0x8,%esp
  iret
8010667c:	cf                   	iret
8010667d:	66 90                	xchg   %ax,%ax
8010667f:	90                   	nop

80106680 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106680:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80106681:	31 c0                	xor    %eax,%eax
{
80106683:	89 e5                	mov    %esp,%ebp
80106685:	83 ec 08             	sub    $0x8,%esp
80106688:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010668f:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106690:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80106697:	c7 04 c5 a2 31 1c 80 	movl   $0x8e000008,-0x7fe3ce5e(,%eax,8)
8010669e:	08 00 00 8e 
801066a2:	66 89 14 c5 a0 31 1c 	mov    %dx,-0x7fe3ce60(,%eax,8)
801066a9:	80 
801066aa:	c1 ea 10             	shr    $0x10,%edx
801066ad:	66 89 14 c5 a6 31 1c 	mov    %dx,-0x7fe3ce5a(,%eax,8)
801066b4:	80 
  for(i = 0; i < 256; i++)
801066b5:	83 c0 01             	add    $0x1,%eax
801066b8:	3d 00 01 00 00       	cmp    $0x100,%eax
801066bd:	75 d1                	jne    80106690 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
801066bf:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801066c2:	a1 08 b1 10 80       	mov    0x8010b108,%eax
801066c7:	c7 05 a2 33 1c 80 08 	movl   $0xef000008,0x801c33a2
801066ce:	00 00 ef 
  initlock(&tickslock, "time");
801066d1:	68 c1 86 10 80       	push   $0x801086c1
801066d6:	68 60 31 1c 80       	push   $0x801c3160
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801066db:	66 a3 a0 33 1c 80    	mov    %ax,0x801c33a0
801066e1:	c1 e8 10             	shr    $0x10,%eax
801066e4:	66 a3 a6 33 1c 80    	mov    %ax,0x801c33a6
  initlock(&tickslock, "time");
801066ea:	e8 c1 ea ff ff       	call   801051b0 <initlock>
}
801066ef:	83 c4 10             	add    $0x10,%esp
801066f2:	c9                   	leave
801066f3:	c3                   	ret
801066f4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801066fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801066ff:	90                   	nop

80106700 <idtinit>:

void
idtinit(void)
{
80106700:	55                   	push   %ebp
  pd[0] = size-1;
80106701:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80106706:	89 e5                	mov    %esp,%ebp
80106708:	83 ec 10             	sub    $0x10,%esp
8010670b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010670f:	b8 a0 31 1c 80       	mov    $0x801c31a0,%eax
80106714:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106718:	c1 e8 10             	shr    $0x10,%eax
8010671b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010671f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106722:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80106725:	c9                   	leave
80106726:	c3                   	ret
80106727:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010672e:	66 90                	xchg   %ax,%ax

80106730 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106730:	55                   	push   %ebp
80106731:	89 e5                	mov    %esp,%ebp
80106733:	57                   	push   %edi
80106734:	56                   	push   %esi
80106735:	53                   	push   %ebx
80106736:	83 ec 1c             	sub    $0x1c,%esp
80106739:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010673c:	8b 43 30             	mov    0x30(%ebx),%eax
8010673f:	83 f8 40             	cmp    $0x40,%eax
80106742:	0f 84 30 01 00 00    	je     80106878 <trap+0x148>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80106748:	83 e8 0e             	sub    $0xe,%eax
8010674b:	83 f8 31             	cmp    $0x31,%eax
8010674e:	0f 87 8c 00 00 00    	ja     801067e0 <trap+0xb0>
80106754:	ff 24 85 20 8d 10 80 	jmp    *-0x7fef72e0(,%eax,4)
8010675b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010675f:	90                   	nop
  case T_PGFLT:
    handle_fage_fault();
    break;
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106760:	e8 6b d5 ff ff       	call   80103cd0 <cpuid>
80106765:	85 c0                	test   %eax,%eax
80106767:	0f 84 13 02 00 00    	je     80106980 <trap+0x250>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
8010676d:	e8 5e c3 ff ff       	call   80102ad0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106772:	e8 79 d5 ff ff       	call   80103cf0 <myproc>
80106777:	85 c0                	test   %eax,%eax
80106779:	74 1a                	je     80106795 <trap+0x65>
8010677b:	e8 70 d5 ff ff       	call   80103cf0 <myproc>
80106780:	8b 50 28             	mov    0x28(%eax),%edx
80106783:	85 d2                	test   %edx,%edx
80106785:	74 0e                	je     80106795 <trap+0x65>
80106787:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010678b:	f7 d0                	not    %eax
8010678d:	a8 03                	test   $0x3,%al
8010678f:	0f 84 cb 01 00 00    	je     80106960 <trap+0x230>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106795:	e8 56 d5 ff ff       	call   80103cf0 <myproc>
8010679a:	85 c0                	test   %eax,%eax
8010679c:	74 0f                	je     801067ad <trap+0x7d>
8010679e:	e8 4d d5 ff ff       	call   80103cf0 <myproc>
801067a3:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
801067a7:	0f 84 b3 00 00 00    	je     80106860 <trap+0x130>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067ad:	e8 3e d5 ff ff       	call   80103cf0 <myproc>
801067b2:	85 c0                	test   %eax,%eax
801067b4:	74 1a                	je     801067d0 <trap+0xa0>
801067b6:	e8 35 d5 ff ff       	call   80103cf0 <myproc>
801067bb:	8b 40 28             	mov    0x28(%eax),%eax
801067be:	85 c0                	test   %eax,%eax
801067c0:	74 0e                	je     801067d0 <trap+0xa0>
801067c2:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801067c6:	f7 d0                	not    %eax
801067c8:	a8 03                	test   $0x3,%al
801067ca:	0f 84 d5 00 00 00    	je     801068a5 <trap+0x175>
    exit();
}
801067d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067d3:	5b                   	pop    %ebx
801067d4:	5e                   	pop    %esi
801067d5:	5f                   	pop    %edi
801067d6:	5d                   	pop    %ebp
801067d7:	c3                   	ret
801067d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801067df:	90                   	nop
    if(myproc() == 0 || (tf->cs&3) == 0){
801067e0:	e8 0b d5 ff ff       	call   80103cf0 <myproc>
801067e5:	8b 7b 38             	mov    0x38(%ebx),%edi
801067e8:	85 c0                	test   %eax,%eax
801067ea:	0f 84 c4 01 00 00    	je     801069b4 <trap+0x284>
801067f0:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801067f4:	0f 84 ba 01 00 00    	je     801069b4 <trap+0x284>
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067fa:	0f 20 d1             	mov    %cr2,%ecx
801067fd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106800:	e8 cb d4 ff ff       	call   80103cd0 <cpuid>
80106805:	8b 73 30             	mov    0x30(%ebx),%esi
80106808:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010680b:	8b 43 34             	mov    0x34(%ebx),%eax
8010680e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80106811:	e8 da d4 ff ff       	call   80103cf0 <myproc>
80106816:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106819:	e8 d2 d4 ff ff       	call   80103cf0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010681e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80106821:	51                   	push   %ecx
80106822:	57                   	push   %edi
80106823:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106826:	52                   	push   %edx
80106827:	ff 75 e4             	push   -0x1c(%ebp)
8010682a:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
8010682b:	8b 75 e0             	mov    -0x20(%ebp),%esi
8010682e:	83 c6 70             	add    $0x70,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106831:	56                   	push   %esi
80106832:	ff 70 14             	push   0x14(%eax)
80106835:	68 08 8a 10 80       	push   $0x80108a08
8010683a:	e8 a1 9f ff ff       	call   801007e0 <cprintf>
    myproc()->killed = 1;
8010683f:	83 c4 20             	add    $0x20,%esp
80106842:	e8 a9 d4 ff ff       	call   80103cf0 <myproc>
80106847:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010684e:	e8 9d d4 ff ff       	call   80103cf0 <myproc>
80106853:	85 c0                	test   %eax,%eax
80106855:	0f 85 20 ff ff ff    	jne    8010677b <trap+0x4b>
8010685b:	e9 35 ff ff ff       	jmp    80106795 <trap+0x65>
  if(myproc() && myproc()->state == RUNNING &&
80106860:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80106864:	0f 85 43 ff ff ff    	jne    801067ad <trap+0x7d>
    yield();
8010686a:	e8 41 da ff ff       	call   801042b0 <yield>
8010686f:	e9 39 ff ff ff       	jmp    801067ad <trap+0x7d>
80106874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80106878:	e8 73 d4 ff ff       	call   80103cf0 <myproc>
8010687d:	8b 70 28             	mov    0x28(%eax),%esi
80106880:	85 f6                	test   %esi,%esi
80106882:	0f 85 e8 00 00 00    	jne    80106970 <trap+0x240>
    myproc()->tf = tf;
80106888:	e8 63 d4 ff ff       	call   80103cf0 <myproc>
8010688d:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
80106890:	e8 fb ef ff ff       	call   80105890 <syscall>
    if(myproc()->killed)
80106895:	e8 56 d4 ff ff       	call   80103cf0 <myproc>
8010689a:	8b 48 28             	mov    0x28(%eax),%ecx
8010689d:	85 c9                	test   %ecx,%ecx
8010689f:	0f 84 2b ff ff ff    	je     801067d0 <trap+0xa0>
}
801068a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068a8:	5b                   	pop    %ebx
801068a9:	5e                   	pop    %esi
801068aa:	5f                   	pop    %edi
801068ab:	5d                   	pop    %ebp
      exit();
801068ac:	e9 cf d8 ff ff       	jmp    80104180 <exit>
801068b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068b8:	8b 7b 38             	mov    0x38(%ebx),%edi
801068bb:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
801068bf:	e8 0c d4 ff ff       	call   80103cd0 <cpuid>
801068c4:	57                   	push   %edi
801068c5:	56                   	push   %esi
801068c6:	50                   	push   %eax
801068c7:	68 b0 89 10 80       	push   $0x801089b0
801068cc:	e8 0f 9f ff ff       	call   801007e0 <cprintf>
    lapiceoi();
801068d1:	e8 fa c1 ff ff       	call   80102ad0 <lapiceoi>
    break;
801068d6:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068d9:	e8 12 d4 ff ff       	call   80103cf0 <myproc>
801068de:	85 c0                	test   %eax,%eax
801068e0:	0f 85 95 fe ff ff    	jne    8010677b <trap+0x4b>
801068e6:	e9 aa fe ff ff       	jmp    80106795 <trap+0x65>
801068eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801068ef:	90                   	nop
    kbdintr();
801068f0:	e8 ab c0 ff ff       	call   801029a0 <kbdintr>
    lapiceoi();
801068f5:	e8 d6 c1 ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068fa:	e8 f1 d3 ff ff       	call   80103cf0 <myproc>
801068ff:	85 c0                	test   %eax,%eax
80106901:	0f 85 74 fe ff ff    	jne    8010677b <trap+0x4b>
80106907:	e9 89 fe ff ff       	jmp    80106795 <trap+0x65>
8010690c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80106910:	e8 4b 02 00 00       	call   80106b60 <uartintr>
    lapiceoi();
80106915:	e8 b6 c1 ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010691a:	e8 d1 d3 ff ff       	call   80103cf0 <myproc>
8010691f:	85 c0                	test   %eax,%eax
80106921:	0f 85 54 fe ff ff    	jne    8010677b <trap+0x4b>
80106927:	e9 69 fe ff ff       	jmp    80106795 <trap+0x65>
8010692c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ideintr();
80106930:	e8 2b ba ff ff       	call   80102360 <ideintr>
80106935:	e9 33 fe ff ff       	jmp    8010676d <trap+0x3d>
8010693a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    handle_fage_fault();
80106940:	e8 7b e2 ff ff       	call   80104bc0 <handle_fage_fault>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106945:	e8 a6 d3 ff ff       	call   80103cf0 <myproc>
8010694a:	85 c0                	test   %eax,%eax
8010694c:	0f 85 29 fe ff ff    	jne    8010677b <trap+0x4b>
80106952:	e9 3e fe ff ff       	jmp    80106795 <trap+0x65>
80106957:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010695e:	66 90                	xchg   %ax,%ax
    exit();
80106960:	e8 1b d8 ff ff       	call   80104180 <exit>
80106965:	e9 2b fe ff ff       	jmp    80106795 <trap+0x65>
8010696a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80106970:	e8 0b d8 ff ff       	call   80104180 <exit>
80106975:	e9 0e ff ff ff       	jmp    80106888 <trap+0x158>
8010697a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80106980:	83 ec 0c             	sub    $0xc,%esp
80106983:	68 60 31 1c 80       	push   $0x801c3160
80106988:	e8 13 ea ff ff       	call   801053a0 <acquire>
      ticks++;
8010698d:	83 05 40 31 1c 80 01 	addl   $0x1,0x801c3140
      wakeup(&ticks);
80106994:	c7 04 24 40 31 1c 80 	movl   $0x801c3140,(%esp)
8010699b:	e8 20 da ff ff       	call   801043c0 <wakeup>
      release(&tickslock);
801069a0:	c7 04 24 60 31 1c 80 	movl   $0x801c3160,(%esp)
801069a7:	e8 94 e9 ff ff       	call   80105340 <release>
801069ac:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801069af:	e9 b9 fd ff ff       	jmp    8010676d <trap+0x3d>
801069b4:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069b7:	e8 14 d3 ff ff       	call   80103cd0 <cpuid>
801069bc:	83 ec 0c             	sub    $0xc,%esp
801069bf:	56                   	push   %esi
801069c0:	57                   	push   %edi
801069c1:	50                   	push   %eax
801069c2:	ff 73 30             	push   0x30(%ebx)
801069c5:	68 d4 89 10 80       	push   $0x801089d4
801069ca:	e8 11 9e ff ff       	call   801007e0 <cprintf>
      panic("trap");
801069cf:	83 c4 14             	add    $0x14,%esp
801069d2:	68 c6 86 10 80       	push   $0x801086c6
801069d7:	e8 d4 9a ff ff       	call   801004b0 <panic>
801069dc:	66 90                	xchg   %ax,%ax
801069de:	66 90                	xchg   %ax,%ax

801069e0 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
801069e0:	a1 a0 39 1c 80       	mov    0x801c39a0,%eax
801069e5:	85 c0                	test   %eax,%eax
801069e7:	74 17                	je     80106a00 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801069e9:	ba fd 03 00 00       	mov    $0x3fd,%edx
801069ee:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801069ef:	a8 01                	test   $0x1,%al
801069f1:	74 0d                	je     80106a00 <uartgetc+0x20>
801069f3:	ba f8 03 00 00       	mov    $0x3f8,%edx
801069f8:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801069f9:	0f b6 c0             	movzbl %al,%eax
801069fc:	c3                   	ret
801069fd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80106a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106a05:	c3                   	ret
80106a06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106a0d:	8d 76 00             	lea    0x0(%esi),%esi

80106a10 <uartinit>:
{
80106a10:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a11:	31 c9                	xor    %ecx,%ecx
80106a13:	89 c8                	mov    %ecx,%eax
80106a15:	89 e5                	mov    %esp,%ebp
80106a17:	57                   	push   %edi
80106a18:	bf fa 03 00 00       	mov    $0x3fa,%edi
80106a1d:	56                   	push   %esi
80106a1e:	89 fa                	mov    %edi,%edx
80106a20:	53                   	push   %ebx
80106a21:	83 ec 1c             	sub    $0x1c,%esp
80106a24:	ee                   	out    %al,(%dx)
80106a25:	be fb 03 00 00       	mov    $0x3fb,%esi
80106a2a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80106a2f:	89 f2                	mov    %esi,%edx
80106a31:	ee                   	out    %al,(%dx)
80106a32:	b8 0c 00 00 00       	mov    $0xc,%eax
80106a37:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106a3c:	ee                   	out    %al,(%dx)
80106a3d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80106a42:	89 c8                	mov    %ecx,%eax
80106a44:	89 da                	mov    %ebx,%edx
80106a46:	ee                   	out    %al,(%dx)
80106a47:	b8 03 00 00 00       	mov    $0x3,%eax
80106a4c:	89 f2                	mov    %esi,%edx
80106a4e:	ee                   	out    %al,(%dx)
80106a4f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106a54:	89 c8                	mov    %ecx,%eax
80106a56:	ee                   	out    %al,(%dx)
80106a57:	b8 01 00 00 00       	mov    $0x1,%eax
80106a5c:	89 da                	mov    %ebx,%edx
80106a5e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a5f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106a64:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106a65:	3c ff                	cmp    $0xff,%al
80106a67:	0f 84 7c 00 00 00    	je     80106ae9 <uartinit+0xd9>
  uart = 1;
80106a6d:	c7 05 a0 39 1c 80 01 	movl   $0x1,0x801c39a0
80106a74:	00 00 00 
80106a77:	89 fa                	mov    %edi,%edx
80106a79:	ec                   	in     (%dx),%al
80106a7a:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106a7f:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80106a80:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80106a83:	bf cb 86 10 80       	mov    $0x801086cb,%edi
80106a88:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80106a8d:	6a 00                	push   $0x0
80106a8f:	6a 04                	push   $0x4
80106a91:	e8 fa ba ff ff       	call   80102590 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80106a96:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80106a9a:	83 c4 10             	add    $0x10,%esp
80106a9d:	8d 76 00             	lea    0x0(%esi),%esi
  if(!uart)
80106aa0:	a1 a0 39 1c 80       	mov    0x801c39a0,%eax
80106aa5:	85 c0                	test   %eax,%eax
80106aa7:	74 32                	je     80106adb <uartinit+0xcb>
80106aa9:	89 f2                	mov    %esi,%edx
80106aab:	ec                   	in     (%dx),%al
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106aac:	a8 20                	test   $0x20,%al
80106aae:	75 21                	jne    80106ad1 <uartinit+0xc1>
80106ab0:	bb 80 00 00 00       	mov    $0x80,%ebx
80106ab5:	8d 76 00             	lea    0x0(%esi),%esi
    microdelay(10);
80106ab8:	83 ec 0c             	sub    $0xc,%esp
80106abb:	6a 0a                	push   $0xa
80106abd:	e8 2e c0 ff ff       	call   80102af0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ac2:	83 c4 10             	add    $0x10,%esp
80106ac5:	83 eb 01             	sub    $0x1,%ebx
80106ac8:	74 07                	je     80106ad1 <uartinit+0xc1>
80106aca:	89 f2                	mov    %esi,%edx
80106acc:	ec                   	in     (%dx),%al
80106acd:	a8 20                	test   $0x20,%al
80106acf:	74 e7                	je     80106ab8 <uartinit+0xa8>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ad1:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106ad6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
80106ada:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80106adb:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80106adf:	83 c7 01             	add    $0x1,%edi
80106ae2:	88 45 e7             	mov    %al,-0x19(%ebp)
80106ae5:	84 c0                	test   %al,%al
80106ae7:	75 b7                	jne    80106aa0 <uartinit+0x90>
}
80106ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106aec:	5b                   	pop    %ebx
80106aed:	5e                   	pop    %esi
80106aee:	5f                   	pop    %edi
80106aef:	5d                   	pop    %ebp
80106af0:	c3                   	ret
80106af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106af8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106aff:	90                   	nop

80106b00 <uartputc>:
  if(!uart)
80106b00:	a1 a0 39 1c 80       	mov    0x801c39a0,%eax
80106b05:	85 c0                	test   %eax,%eax
80106b07:	74 4f                	je     80106b58 <uartputc+0x58>
{
80106b09:	55                   	push   %ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b0a:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106b0f:	89 e5                	mov    %esp,%ebp
80106b11:	56                   	push   %esi
80106b12:	53                   	push   %ebx
80106b13:	ec                   	in     (%dx),%al
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b14:	a8 20                	test   $0x20,%al
80106b16:	75 29                	jne    80106b41 <uartputc+0x41>
80106b18:	bb 80 00 00 00       	mov    $0x80,%ebx
80106b1d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106b22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80106b28:	83 ec 0c             	sub    $0xc,%esp
80106b2b:	6a 0a                	push   $0xa
80106b2d:	e8 be bf ff ff       	call   80102af0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b32:	83 c4 10             	add    $0x10,%esp
80106b35:	83 eb 01             	sub    $0x1,%ebx
80106b38:	74 07                	je     80106b41 <uartputc+0x41>
80106b3a:	89 f2                	mov    %esi,%edx
80106b3c:	ec                   	in     (%dx),%al
80106b3d:	a8 20                	test   $0x20,%al
80106b3f:	74 e7                	je     80106b28 <uartputc+0x28>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b41:	8b 45 08             	mov    0x8(%ebp),%eax
80106b44:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106b49:	ee                   	out    %al,(%dx)
}
80106b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106b4d:	5b                   	pop    %ebx
80106b4e:	5e                   	pop    %esi
80106b4f:	5d                   	pop    %ebp
80106b50:	c3                   	ret
80106b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b58:	c3                   	ret
80106b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106b60 <uartintr>:

void
uartintr(void)
{
80106b60:	55                   	push   %ebp
80106b61:	89 e5                	mov    %esp,%ebp
80106b63:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106b66:	68 e0 69 10 80       	push   $0x801069e0
80106b6b:	e8 60 9e ff ff       	call   801009d0 <consoleintr>
}
80106b70:	83 c4 10             	add    $0x10,%esp
80106b73:	c9                   	leave
80106b74:	c3                   	ret

80106b75 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $0
80106b77:	6a 00                	push   $0x0
  jmp alltraps
80106b79:	e9 dc fa ff ff       	jmp    8010665a <alltraps>

80106b7e <vector1>:
.globl vector1
vector1:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $1
80106b80:	6a 01                	push   $0x1
  jmp alltraps
80106b82:	e9 d3 fa ff ff       	jmp    8010665a <alltraps>

80106b87 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $2
80106b89:	6a 02                	push   $0x2
  jmp alltraps
80106b8b:	e9 ca fa ff ff       	jmp    8010665a <alltraps>

80106b90 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $3
80106b92:	6a 03                	push   $0x3
  jmp alltraps
80106b94:	e9 c1 fa ff ff       	jmp    8010665a <alltraps>

80106b99 <vector4>:
.globl vector4
vector4:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $4
80106b9b:	6a 04                	push   $0x4
  jmp alltraps
80106b9d:	e9 b8 fa ff ff       	jmp    8010665a <alltraps>

80106ba2 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $5
80106ba4:	6a 05                	push   $0x5
  jmp alltraps
80106ba6:	e9 af fa ff ff       	jmp    8010665a <alltraps>

80106bab <vector6>:
.globl vector6
vector6:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $6
80106bad:	6a 06                	push   $0x6
  jmp alltraps
80106baf:	e9 a6 fa ff ff       	jmp    8010665a <alltraps>

80106bb4 <vector7>:
.globl vector7
vector7:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $7
80106bb6:	6a 07                	push   $0x7
  jmp alltraps
80106bb8:	e9 9d fa ff ff       	jmp    8010665a <alltraps>

80106bbd <vector8>:
.globl vector8
vector8:
  pushl $8
80106bbd:	6a 08                	push   $0x8
  jmp alltraps
80106bbf:	e9 96 fa ff ff       	jmp    8010665a <alltraps>

80106bc4 <vector9>:
.globl vector9
vector9:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $9
80106bc6:	6a 09                	push   $0x9
  jmp alltraps
80106bc8:	e9 8d fa ff ff       	jmp    8010665a <alltraps>

80106bcd <vector10>:
.globl vector10
vector10:
  pushl $10
80106bcd:	6a 0a                	push   $0xa
  jmp alltraps
80106bcf:	e9 86 fa ff ff       	jmp    8010665a <alltraps>

80106bd4 <vector11>:
.globl vector11
vector11:
  pushl $11
80106bd4:	6a 0b                	push   $0xb
  jmp alltraps
80106bd6:	e9 7f fa ff ff       	jmp    8010665a <alltraps>

80106bdb <vector12>:
.globl vector12
vector12:
  pushl $12
80106bdb:	6a 0c                	push   $0xc
  jmp alltraps
80106bdd:	e9 78 fa ff ff       	jmp    8010665a <alltraps>

80106be2 <vector13>:
.globl vector13
vector13:
  pushl $13
80106be2:	6a 0d                	push   $0xd
  jmp alltraps
80106be4:	e9 71 fa ff ff       	jmp    8010665a <alltraps>

80106be9 <vector14>:
.globl vector14
vector14:
  pushl $14
80106be9:	6a 0e                	push   $0xe
  jmp alltraps
80106beb:	e9 6a fa ff ff       	jmp    8010665a <alltraps>

80106bf0 <vector15>:
.globl vector15
vector15:
  pushl $0
80106bf0:	6a 00                	push   $0x0
  pushl $15
80106bf2:	6a 0f                	push   $0xf
  jmp alltraps
80106bf4:	e9 61 fa ff ff       	jmp    8010665a <alltraps>

80106bf9 <vector16>:
.globl vector16
vector16:
  pushl $0
80106bf9:	6a 00                	push   $0x0
  pushl $16
80106bfb:	6a 10                	push   $0x10
  jmp alltraps
80106bfd:	e9 58 fa ff ff       	jmp    8010665a <alltraps>

80106c02 <vector17>:
.globl vector17
vector17:
  pushl $17
80106c02:	6a 11                	push   $0x11
  jmp alltraps
80106c04:	e9 51 fa ff ff       	jmp    8010665a <alltraps>

80106c09 <vector18>:
.globl vector18
vector18:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $18
80106c0b:	6a 12                	push   $0x12
  jmp alltraps
80106c0d:	e9 48 fa ff ff       	jmp    8010665a <alltraps>

80106c12 <vector19>:
.globl vector19
vector19:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $19
80106c14:	6a 13                	push   $0x13
  jmp alltraps
80106c16:	e9 3f fa ff ff       	jmp    8010665a <alltraps>

80106c1b <vector20>:
.globl vector20
vector20:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $20
80106c1d:	6a 14                	push   $0x14
  jmp alltraps
80106c1f:	e9 36 fa ff ff       	jmp    8010665a <alltraps>

80106c24 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $21
80106c26:	6a 15                	push   $0x15
  jmp alltraps
80106c28:	e9 2d fa ff ff       	jmp    8010665a <alltraps>

80106c2d <vector22>:
.globl vector22
vector22:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $22
80106c2f:	6a 16                	push   $0x16
  jmp alltraps
80106c31:	e9 24 fa ff ff       	jmp    8010665a <alltraps>

80106c36 <vector23>:
.globl vector23
vector23:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $23
80106c38:	6a 17                	push   $0x17
  jmp alltraps
80106c3a:	e9 1b fa ff ff       	jmp    8010665a <alltraps>

80106c3f <vector24>:
.globl vector24
vector24:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $24
80106c41:	6a 18                	push   $0x18
  jmp alltraps
80106c43:	e9 12 fa ff ff       	jmp    8010665a <alltraps>

80106c48 <vector25>:
.globl vector25
vector25:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $25
80106c4a:	6a 19                	push   $0x19
  jmp alltraps
80106c4c:	e9 09 fa ff ff       	jmp    8010665a <alltraps>

80106c51 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $26
80106c53:	6a 1a                	push   $0x1a
  jmp alltraps
80106c55:	e9 00 fa ff ff       	jmp    8010665a <alltraps>

80106c5a <vector27>:
.globl vector27
vector27:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $27
80106c5c:	6a 1b                	push   $0x1b
  jmp alltraps
80106c5e:	e9 f7 f9 ff ff       	jmp    8010665a <alltraps>

80106c63 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $28
80106c65:	6a 1c                	push   $0x1c
  jmp alltraps
80106c67:	e9 ee f9 ff ff       	jmp    8010665a <alltraps>

80106c6c <vector29>:
.globl vector29
vector29:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $29
80106c6e:	6a 1d                	push   $0x1d
  jmp alltraps
80106c70:	e9 e5 f9 ff ff       	jmp    8010665a <alltraps>

80106c75 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $30
80106c77:	6a 1e                	push   $0x1e
  jmp alltraps
80106c79:	e9 dc f9 ff ff       	jmp    8010665a <alltraps>

80106c7e <vector31>:
.globl vector31
vector31:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $31
80106c80:	6a 1f                	push   $0x1f
  jmp alltraps
80106c82:	e9 d3 f9 ff ff       	jmp    8010665a <alltraps>

80106c87 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $32
80106c89:	6a 20                	push   $0x20
  jmp alltraps
80106c8b:	e9 ca f9 ff ff       	jmp    8010665a <alltraps>

80106c90 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $33
80106c92:	6a 21                	push   $0x21
  jmp alltraps
80106c94:	e9 c1 f9 ff ff       	jmp    8010665a <alltraps>

80106c99 <vector34>:
.globl vector34
vector34:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $34
80106c9b:	6a 22                	push   $0x22
  jmp alltraps
80106c9d:	e9 b8 f9 ff ff       	jmp    8010665a <alltraps>

80106ca2 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $35
80106ca4:	6a 23                	push   $0x23
  jmp alltraps
80106ca6:	e9 af f9 ff ff       	jmp    8010665a <alltraps>

80106cab <vector36>:
.globl vector36
vector36:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $36
80106cad:	6a 24                	push   $0x24
  jmp alltraps
80106caf:	e9 a6 f9 ff ff       	jmp    8010665a <alltraps>

80106cb4 <vector37>:
.globl vector37
vector37:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $37
80106cb6:	6a 25                	push   $0x25
  jmp alltraps
80106cb8:	e9 9d f9 ff ff       	jmp    8010665a <alltraps>

80106cbd <vector38>:
.globl vector38
vector38:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $38
80106cbf:	6a 26                	push   $0x26
  jmp alltraps
80106cc1:	e9 94 f9 ff ff       	jmp    8010665a <alltraps>

80106cc6 <vector39>:
.globl vector39
vector39:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $39
80106cc8:	6a 27                	push   $0x27
  jmp alltraps
80106cca:	e9 8b f9 ff ff       	jmp    8010665a <alltraps>

80106ccf <vector40>:
.globl vector40
vector40:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $40
80106cd1:	6a 28                	push   $0x28
  jmp alltraps
80106cd3:	e9 82 f9 ff ff       	jmp    8010665a <alltraps>

80106cd8 <vector41>:
.globl vector41
vector41:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $41
80106cda:	6a 29                	push   $0x29
  jmp alltraps
80106cdc:	e9 79 f9 ff ff       	jmp    8010665a <alltraps>

80106ce1 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $42
80106ce3:	6a 2a                	push   $0x2a
  jmp alltraps
80106ce5:	e9 70 f9 ff ff       	jmp    8010665a <alltraps>

80106cea <vector43>:
.globl vector43
vector43:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $43
80106cec:	6a 2b                	push   $0x2b
  jmp alltraps
80106cee:	e9 67 f9 ff ff       	jmp    8010665a <alltraps>

80106cf3 <vector44>:
.globl vector44
vector44:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $44
80106cf5:	6a 2c                	push   $0x2c
  jmp alltraps
80106cf7:	e9 5e f9 ff ff       	jmp    8010665a <alltraps>

80106cfc <vector45>:
.globl vector45
vector45:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $45
80106cfe:	6a 2d                	push   $0x2d
  jmp alltraps
80106d00:	e9 55 f9 ff ff       	jmp    8010665a <alltraps>

80106d05 <vector46>:
.globl vector46
vector46:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $46
80106d07:	6a 2e                	push   $0x2e
  jmp alltraps
80106d09:	e9 4c f9 ff ff       	jmp    8010665a <alltraps>

80106d0e <vector47>:
.globl vector47
vector47:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $47
80106d10:	6a 2f                	push   $0x2f
  jmp alltraps
80106d12:	e9 43 f9 ff ff       	jmp    8010665a <alltraps>

80106d17 <vector48>:
.globl vector48
vector48:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $48
80106d19:	6a 30                	push   $0x30
  jmp alltraps
80106d1b:	e9 3a f9 ff ff       	jmp    8010665a <alltraps>

80106d20 <vector49>:
.globl vector49
vector49:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $49
80106d22:	6a 31                	push   $0x31
  jmp alltraps
80106d24:	e9 31 f9 ff ff       	jmp    8010665a <alltraps>

80106d29 <vector50>:
.globl vector50
vector50:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $50
80106d2b:	6a 32                	push   $0x32
  jmp alltraps
80106d2d:	e9 28 f9 ff ff       	jmp    8010665a <alltraps>

80106d32 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $51
80106d34:	6a 33                	push   $0x33
  jmp alltraps
80106d36:	e9 1f f9 ff ff       	jmp    8010665a <alltraps>

80106d3b <vector52>:
.globl vector52
vector52:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $52
80106d3d:	6a 34                	push   $0x34
  jmp alltraps
80106d3f:	e9 16 f9 ff ff       	jmp    8010665a <alltraps>

80106d44 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $53
80106d46:	6a 35                	push   $0x35
  jmp alltraps
80106d48:	e9 0d f9 ff ff       	jmp    8010665a <alltraps>

80106d4d <vector54>:
.globl vector54
vector54:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $54
80106d4f:	6a 36                	push   $0x36
  jmp alltraps
80106d51:	e9 04 f9 ff ff       	jmp    8010665a <alltraps>

80106d56 <vector55>:
.globl vector55
vector55:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $55
80106d58:	6a 37                	push   $0x37
  jmp alltraps
80106d5a:	e9 fb f8 ff ff       	jmp    8010665a <alltraps>

80106d5f <vector56>:
.globl vector56
vector56:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $56
80106d61:	6a 38                	push   $0x38
  jmp alltraps
80106d63:	e9 f2 f8 ff ff       	jmp    8010665a <alltraps>

80106d68 <vector57>:
.globl vector57
vector57:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $57
80106d6a:	6a 39                	push   $0x39
  jmp alltraps
80106d6c:	e9 e9 f8 ff ff       	jmp    8010665a <alltraps>

80106d71 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $58
80106d73:	6a 3a                	push   $0x3a
  jmp alltraps
80106d75:	e9 e0 f8 ff ff       	jmp    8010665a <alltraps>

80106d7a <vector59>:
.globl vector59
vector59:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $59
80106d7c:	6a 3b                	push   $0x3b
  jmp alltraps
80106d7e:	e9 d7 f8 ff ff       	jmp    8010665a <alltraps>

80106d83 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $60
80106d85:	6a 3c                	push   $0x3c
  jmp alltraps
80106d87:	e9 ce f8 ff ff       	jmp    8010665a <alltraps>

80106d8c <vector61>:
.globl vector61
vector61:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $61
80106d8e:	6a 3d                	push   $0x3d
  jmp alltraps
80106d90:	e9 c5 f8 ff ff       	jmp    8010665a <alltraps>

80106d95 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $62
80106d97:	6a 3e                	push   $0x3e
  jmp alltraps
80106d99:	e9 bc f8 ff ff       	jmp    8010665a <alltraps>

80106d9e <vector63>:
.globl vector63
vector63:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $63
80106da0:	6a 3f                	push   $0x3f
  jmp alltraps
80106da2:	e9 b3 f8 ff ff       	jmp    8010665a <alltraps>

80106da7 <vector64>:
.globl vector64
vector64:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $64
80106da9:	6a 40                	push   $0x40
  jmp alltraps
80106dab:	e9 aa f8 ff ff       	jmp    8010665a <alltraps>

80106db0 <vector65>:
.globl vector65
vector65:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $65
80106db2:	6a 41                	push   $0x41
  jmp alltraps
80106db4:	e9 a1 f8 ff ff       	jmp    8010665a <alltraps>

80106db9 <vector66>:
.globl vector66
vector66:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $66
80106dbb:	6a 42                	push   $0x42
  jmp alltraps
80106dbd:	e9 98 f8 ff ff       	jmp    8010665a <alltraps>

80106dc2 <vector67>:
.globl vector67
vector67:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $67
80106dc4:	6a 43                	push   $0x43
  jmp alltraps
80106dc6:	e9 8f f8 ff ff       	jmp    8010665a <alltraps>

80106dcb <vector68>:
.globl vector68
vector68:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $68
80106dcd:	6a 44                	push   $0x44
  jmp alltraps
80106dcf:	e9 86 f8 ff ff       	jmp    8010665a <alltraps>

80106dd4 <vector69>:
.globl vector69
vector69:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $69
80106dd6:	6a 45                	push   $0x45
  jmp alltraps
80106dd8:	e9 7d f8 ff ff       	jmp    8010665a <alltraps>

80106ddd <vector70>:
.globl vector70
vector70:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $70
80106ddf:	6a 46                	push   $0x46
  jmp alltraps
80106de1:	e9 74 f8 ff ff       	jmp    8010665a <alltraps>

80106de6 <vector71>:
.globl vector71
vector71:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $71
80106de8:	6a 47                	push   $0x47
  jmp alltraps
80106dea:	e9 6b f8 ff ff       	jmp    8010665a <alltraps>

80106def <vector72>:
.globl vector72
vector72:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $72
80106df1:	6a 48                	push   $0x48
  jmp alltraps
80106df3:	e9 62 f8 ff ff       	jmp    8010665a <alltraps>

80106df8 <vector73>:
.globl vector73
vector73:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $73
80106dfa:	6a 49                	push   $0x49
  jmp alltraps
80106dfc:	e9 59 f8 ff ff       	jmp    8010665a <alltraps>

80106e01 <vector74>:
.globl vector74
vector74:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $74
80106e03:	6a 4a                	push   $0x4a
  jmp alltraps
80106e05:	e9 50 f8 ff ff       	jmp    8010665a <alltraps>

80106e0a <vector75>:
.globl vector75
vector75:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $75
80106e0c:	6a 4b                	push   $0x4b
  jmp alltraps
80106e0e:	e9 47 f8 ff ff       	jmp    8010665a <alltraps>

80106e13 <vector76>:
.globl vector76
vector76:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $76
80106e15:	6a 4c                	push   $0x4c
  jmp alltraps
80106e17:	e9 3e f8 ff ff       	jmp    8010665a <alltraps>

80106e1c <vector77>:
.globl vector77
vector77:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $77
80106e1e:	6a 4d                	push   $0x4d
  jmp alltraps
80106e20:	e9 35 f8 ff ff       	jmp    8010665a <alltraps>

80106e25 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $78
80106e27:	6a 4e                	push   $0x4e
  jmp alltraps
80106e29:	e9 2c f8 ff ff       	jmp    8010665a <alltraps>

80106e2e <vector79>:
.globl vector79
vector79:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $79
80106e30:	6a 4f                	push   $0x4f
  jmp alltraps
80106e32:	e9 23 f8 ff ff       	jmp    8010665a <alltraps>

80106e37 <vector80>:
.globl vector80
vector80:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $80
80106e39:	6a 50                	push   $0x50
  jmp alltraps
80106e3b:	e9 1a f8 ff ff       	jmp    8010665a <alltraps>

80106e40 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $81
80106e42:	6a 51                	push   $0x51
  jmp alltraps
80106e44:	e9 11 f8 ff ff       	jmp    8010665a <alltraps>

80106e49 <vector82>:
.globl vector82
vector82:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $82
80106e4b:	6a 52                	push   $0x52
  jmp alltraps
80106e4d:	e9 08 f8 ff ff       	jmp    8010665a <alltraps>

80106e52 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $83
80106e54:	6a 53                	push   $0x53
  jmp alltraps
80106e56:	e9 ff f7 ff ff       	jmp    8010665a <alltraps>

80106e5b <vector84>:
.globl vector84
vector84:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $84
80106e5d:	6a 54                	push   $0x54
  jmp alltraps
80106e5f:	e9 f6 f7 ff ff       	jmp    8010665a <alltraps>

80106e64 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $85
80106e66:	6a 55                	push   $0x55
  jmp alltraps
80106e68:	e9 ed f7 ff ff       	jmp    8010665a <alltraps>

80106e6d <vector86>:
.globl vector86
vector86:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $86
80106e6f:	6a 56                	push   $0x56
  jmp alltraps
80106e71:	e9 e4 f7 ff ff       	jmp    8010665a <alltraps>

80106e76 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $87
80106e78:	6a 57                	push   $0x57
  jmp alltraps
80106e7a:	e9 db f7 ff ff       	jmp    8010665a <alltraps>

80106e7f <vector88>:
.globl vector88
vector88:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $88
80106e81:	6a 58                	push   $0x58
  jmp alltraps
80106e83:	e9 d2 f7 ff ff       	jmp    8010665a <alltraps>

80106e88 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $89
80106e8a:	6a 59                	push   $0x59
  jmp alltraps
80106e8c:	e9 c9 f7 ff ff       	jmp    8010665a <alltraps>

80106e91 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $90
80106e93:	6a 5a                	push   $0x5a
  jmp alltraps
80106e95:	e9 c0 f7 ff ff       	jmp    8010665a <alltraps>

80106e9a <vector91>:
.globl vector91
vector91:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $91
80106e9c:	6a 5b                	push   $0x5b
  jmp alltraps
80106e9e:	e9 b7 f7 ff ff       	jmp    8010665a <alltraps>

80106ea3 <vector92>:
.globl vector92
vector92:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $92
80106ea5:	6a 5c                	push   $0x5c
  jmp alltraps
80106ea7:	e9 ae f7 ff ff       	jmp    8010665a <alltraps>

80106eac <vector93>:
.globl vector93
vector93:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $93
80106eae:	6a 5d                	push   $0x5d
  jmp alltraps
80106eb0:	e9 a5 f7 ff ff       	jmp    8010665a <alltraps>

80106eb5 <vector94>:
.globl vector94
vector94:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $94
80106eb7:	6a 5e                	push   $0x5e
  jmp alltraps
80106eb9:	e9 9c f7 ff ff       	jmp    8010665a <alltraps>

80106ebe <vector95>:
.globl vector95
vector95:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $95
80106ec0:	6a 5f                	push   $0x5f
  jmp alltraps
80106ec2:	e9 93 f7 ff ff       	jmp    8010665a <alltraps>

80106ec7 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $96
80106ec9:	6a 60                	push   $0x60
  jmp alltraps
80106ecb:	e9 8a f7 ff ff       	jmp    8010665a <alltraps>

80106ed0 <vector97>:
.globl vector97
vector97:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $97
80106ed2:	6a 61                	push   $0x61
  jmp alltraps
80106ed4:	e9 81 f7 ff ff       	jmp    8010665a <alltraps>

80106ed9 <vector98>:
.globl vector98
vector98:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $98
80106edb:	6a 62                	push   $0x62
  jmp alltraps
80106edd:	e9 78 f7 ff ff       	jmp    8010665a <alltraps>

80106ee2 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $99
80106ee4:	6a 63                	push   $0x63
  jmp alltraps
80106ee6:	e9 6f f7 ff ff       	jmp    8010665a <alltraps>

80106eeb <vector100>:
.globl vector100
vector100:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $100
80106eed:	6a 64                	push   $0x64
  jmp alltraps
80106eef:	e9 66 f7 ff ff       	jmp    8010665a <alltraps>

80106ef4 <vector101>:
.globl vector101
vector101:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $101
80106ef6:	6a 65                	push   $0x65
  jmp alltraps
80106ef8:	e9 5d f7 ff ff       	jmp    8010665a <alltraps>

80106efd <vector102>:
.globl vector102
vector102:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $102
80106eff:	6a 66                	push   $0x66
  jmp alltraps
80106f01:	e9 54 f7 ff ff       	jmp    8010665a <alltraps>

80106f06 <vector103>:
.globl vector103
vector103:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $103
80106f08:	6a 67                	push   $0x67
  jmp alltraps
80106f0a:	e9 4b f7 ff ff       	jmp    8010665a <alltraps>

80106f0f <vector104>:
.globl vector104
vector104:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $104
80106f11:	6a 68                	push   $0x68
  jmp alltraps
80106f13:	e9 42 f7 ff ff       	jmp    8010665a <alltraps>

80106f18 <vector105>:
.globl vector105
vector105:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $105
80106f1a:	6a 69                	push   $0x69
  jmp alltraps
80106f1c:	e9 39 f7 ff ff       	jmp    8010665a <alltraps>

80106f21 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $106
80106f23:	6a 6a                	push   $0x6a
  jmp alltraps
80106f25:	e9 30 f7 ff ff       	jmp    8010665a <alltraps>

80106f2a <vector107>:
.globl vector107
vector107:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $107
80106f2c:	6a 6b                	push   $0x6b
  jmp alltraps
80106f2e:	e9 27 f7 ff ff       	jmp    8010665a <alltraps>

80106f33 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $108
80106f35:	6a 6c                	push   $0x6c
  jmp alltraps
80106f37:	e9 1e f7 ff ff       	jmp    8010665a <alltraps>

80106f3c <vector109>:
.globl vector109
vector109:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $109
80106f3e:	6a 6d                	push   $0x6d
  jmp alltraps
80106f40:	e9 15 f7 ff ff       	jmp    8010665a <alltraps>

80106f45 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $110
80106f47:	6a 6e                	push   $0x6e
  jmp alltraps
80106f49:	e9 0c f7 ff ff       	jmp    8010665a <alltraps>

80106f4e <vector111>:
.globl vector111
vector111:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $111
80106f50:	6a 6f                	push   $0x6f
  jmp alltraps
80106f52:	e9 03 f7 ff ff       	jmp    8010665a <alltraps>

80106f57 <vector112>:
.globl vector112
vector112:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $112
80106f59:	6a 70                	push   $0x70
  jmp alltraps
80106f5b:	e9 fa f6 ff ff       	jmp    8010665a <alltraps>

80106f60 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $113
80106f62:	6a 71                	push   $0x71
  jmp alltraps
80106f64:	e9 f1 f6 ff ff       	jmp    8010665a <alltraps>

80106f69 <vector114>:
.globl vector114
vector114:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $114
80106f6b:	6a 72                	push   $0x72
  jmp alltraps
80106f6d:	e9 e8 f6 ff ff       	jmp    8010665a <alltraps>

80106f72 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $115
80106f74:	6a 73                	push   $0x73
  jmp alltraps
80106f76:	e9 df f6 ff ff       	jmp    8010665a <alltraps>

80106f7b <vector116>:
.globl vector116
vector116:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $116
80106f7d:	6a 74                	push   $0x74
  jmp alltraps
80106f7f:	e9 d6 f6 ff ff       	jmp    8010665a <alltraps>

80106f84 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $117
80106f86:	6a 75                	push   $0x75
  jmp alltraps
80106f88:	e9 cd f6 ff ff       	jmp    8010665a <alltraps>

80106f8d <vector118>:
.globl vector118
vector118:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $118
80106f8f:	6a 76                	push   $0x76
  jmp alltraps
80106f91:	e9 c4 f6 ff ff       	jmp    8010665a <alltraps>

80106f96 <vector119>:
.globl vector119
vector119:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $119
80106f98:	6a 77                	push   $0x77
  jmp alltraps
80106f9a:	e9 bb f6 ff ff       	jmp    8010665a <alltraps>

80106f9f <vector120>:
.globl vector120
vector120:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $120
80106fa1:	6a 78                	push   $0x78
  jmp alltraps
80106fa3:	e9 b2 f6 ff ff       	jmp    8010665a <alltraps>

80106fa8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $121
80106faa:	6a 79                	push   $0x79
  jmp alltraps
80106fac:	e9 a9 f6 ff ff       	jmp    8010665a <alltraps>

80106fb1 <vector122>:
.globl vector122
vector122:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $122
80106fb3:	6a 7a                	push   $0x7a
  jmp alltraps
80106fb5:	e9 a0 f6 ff ff       	jmp    8010665a <alltraps>

80106fba <vector123>:
.globl vector123
vector123:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $123
80106fbc:	6a 7b                	push   $0x7b
  jmp alltraps
80106fbe:	e9 97 f6 ff ff       	jmp    8010665a <alltraps>

80106fc3 <vector124>:
.globl vector124
vector124:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $124
80106fc5:	6a 7c                	push   $0x7c
  jmp alltraps
80106fc7:	e9 8e f6 ff ff       	jmp    8010665a <alltraps>

80106fcc <vector125>:
.globl vector125
vector125:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $125
80106fce:	6a 7d                	push   $0x7d
  jmp alltraps
80106fd0:	e9 85 f6 ff ff       	jmp    8010665a <alltraps>

80106fd5 <vector126>:
.globl vector126
vector126:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $126
80106fd7:	6a 7e                	push   $0x7e
  jmp alltraps
80106fd9:	e9 7c f6 ff ff       	jmp    8010665a <alltraps>

80106fde <vector127>:
.globl vector127
vector127:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $127
80106fe0:	6a 7f                	push   $0x7f
  jmp alltraps
80106fe2:	e9 73 f6 ff ff       	jmp    8010665a <alltraps>

80106fe7 <vector128>:
.globl vector128
vector128:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $128
80106fe9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106fee:	e9 67 f6 ff ff       	jmp    8010665a <alltraps>

80106ff3 <vector129>:
.globl vector129
vector129:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $129
80106ff5:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106ffa:	e9 5b f6 ff ff       	jmp    8010665a <alltraps>

80106fff <vector130>:
.globl vector130
vector130:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $130
80107001:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107006:	e9 4f f6 ff ff       	jmp    8010665a <alltraps>

8010700b <vector131>:
.globl vector131
vector131:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $131
8010700d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107012:	e9 43 f6 ff ff       	jmp    8010665a <alltraps>

80107017 <vector132>:
.globl vector132
vector132:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $132
80107019:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010701e:	e9 37 f6 ff ff       	jmp    8010665a <alltraps>

80107023 <vector133>:
.globl vector133
vector133:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $133
80107025:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010702a:	e9 2b f6 ff ff       	jmp    8010665a <alltraps>

8010702f <vector134>:
.globl vector134
vector134:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $134
80107031:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107036:	e9 1f f6 ff ff       	jmp    8010665a <alltraps>

8010703b <vector135>:
.globl vector135
vector135:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $135
8010703d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107042:	e9 13 f6 ff ff       	jmp    8010665a <alltraps>

80107047 <vector136>:
.globl vector136
vector136:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $136
80107049:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010704e:	e9 07 f6 ff ff       	jmp    8010665a <alltraps>

80107053 <vector137>:
.globl vector137
vector137:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $137
80107055:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010705a:	e9 fb f5 ff ff       	jmp    8010665a <alltraps>

8010705f <vector138>:
.globl vector138
vector138:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $138
80107061:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107066:	e9 ef f5 ff ff       	jmp    8010665a <alltraps>

8010706b <vector139>:
.globl vector139
vector139:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $139
8010706d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107072:	e9 e3 f5 ff ff       	jmp    8010665a <alltraps>

80107077 <vector140>:
.globl vector140
vector140:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $140
80107079:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010707e:	e9 d7 f5 ff ff       	jmp    8010665a <alltraps>

80107083 <vector141>:
.globl vector141
vector141:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $141
80107085:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010708a:	e9 cb f5 ff ff       	jmp    8010665a <alltraps>

8010708f <vector142>:
.globl vector142
vector142:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $142
80107091:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107096:	e9 bf f5 ff ff       	jmp    8010665a <alltraps>

8010709b <vector143>:
.globl vector143
vector143:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $143
8010709d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801070a2:	e9 b3 f5 ff ff       	jmp    8010665a <alltraps>

801070a7 <vector144>:
.globl vector144
vector144:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $144
801070a9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801070ae:	e9 a7 f5 ff ff       	jmp    8010665a <alltraps>

801070b3 <vector145>:
.globl vector145
vector145:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $145
801070b5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801070ba:	e9 9b f5 ff ff       	jmp    8010665a <alltraps>

801070bf <vector146>:
.globl vector146
vector146:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $146
801070c1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801070c6:	e9 8f f5 ff ff       	jmp    8010665a <alltraps>

801070cb <vector147>:
.globl vector147
vector147:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $147
801070cd:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801070d2:	e9 83 f5 ff ff       	jmp    8010665a <alltraps>

801070d7 <vector148>:
.globl vector148
vector148:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $148
801070d9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801070de:	e9 77 f5 ff ff       	jmp    8010665a <alltraps>

801070e3 <vector149>:
.globl vector149
vector149:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $149
801070e5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070ea:	e9 6b f5 ff ff       	jmp    8010665a <alltraps>

801070ef <vector150>:
.globl vector150
vector150:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $150
801070f1:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801070f6:	e9 5f f5 ff ff       	jmp    8010665a <alltraps>

801070fb <vector151>:
.globl vector151
vector151:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $151
801070fd:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107102:	e9 53 f5 ff ff       	jmp    8010665a <alltraps>

80107107 <vector152>:
.globl vector152
vector152:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $152
80107109:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010710e:	e9 47 f5 ff ff       	jmp    8010665a <alltraps>

80107113 <vector153>:
.globl vector153
vector153:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $153
80107115:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010711a:	e9 3b f5 ff ff       	jmp    8010665a <alltraps>

8010711f <vector154>:
.globl vector154
vector154:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $154
80107121:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107126:	e9 2f f5 ff ff       	jmp    8010665a <alltraps>

8010712b <vector155>:
.globl vector155
vector155:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $155
8010712d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107132:	e9 23 f5 ff ff       	jmp    8010665a <alltraps>

80107137 <vector156>:
.globl vector156
vector156:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $156
80107139:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010713e:	e9 17 f5 ff ff       	jmp    8010665a <alltraps>

80107143 <vector157>:
.globl vector157
vector157:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $157
80107145:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010714a:	e9 0b f5 ff ff       	jmp    8010665a <alltraps>

8010714f <vector158>:
.globl vector158
vector158:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $158
80107151:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107156:	e9 ff f4 ff ff       	jmp    8010665a <alltraps>

8010715b <vector159>:
.globl vector159
vector159:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $159
8010715d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107162:	e9 f3 f4 ff ff       	jmp    8010665a <alltraps>

80107167 <vector160>:
.globl vector160
vector160:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $160
80107169:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010716e:	e9 e7 f4 ff ff       	jmp    8010665a <alltraps>

80107173 <vector161>:
.globl vector161
vector161:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $161
80107175:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010717a:	e9 db f4 ff ff       	jmp    8010665a <alltraps>

8010717f <vector162>:
.globl vector162
vector162:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $162
80107181:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107186:	e9 cf f4 ff ff       	jmp    8010665a <alltraps>

8010718b <vector163>:
.globl vector163
vector163:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $163
8010718d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107192:	e9 c3 f4 ff ff       	jmp    8010665a <alltraps>

80107197 <vector164>:
.globl vector164
vector164:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $164
80107199:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010719e:	e9 b7 f4 ff ff       	jmp    8010665a <alltraps>

801071a3 <vector165>:
.globl vector165
vector165:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $165
801071a5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801071aa:	e9 ab f4 ff ff       	jmp    8010665a <alltraps>

801071af <vector166>:
.globl vector166
vector166:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $166
801071b1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801071b6:	e9 9f f4 ff ff       	jmp    8010665a <alltraps>

801071bb <vector167>:
.globl vector167
vector167:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $167
801071bd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801071c2:	e9 93 f4 ff ff       	jmp    8010665a <alltraps>

801071c7 <vector168>:
.globl vector168
vector168:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $168
801071c9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801071ce:	e9 87 f4 ff ff       	jmp    8010665a <alltraps>

801071d3 <vector169>:
.globl vector169
vector169:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $169
801071d5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801071da:	e9 7b f4 ff ff       	jmp    8010665a <alltraps>

801071df <vector170>:
.globl vector170
vector170:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $170
801071e1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071e6:	e9 6f f4 ff ff       	jmp    8010665a <alltraps>

801071eb <vector171>:
.globl vector171
vector171:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $171
801071ed:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801071f2:	e9 63 f4 ff ff       	jmp    8010665a <alltraps>

801071f7 <vector172>:
.globl vector172
vector172:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $172
801071f9:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801071fe:	e9 57 f4 ff ff       	jmp    8010665a <alltraps>

80107203 <vector173>:
.globl vector173
vector173:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $173
80107205:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010720a:	e9 4b f4 ff ff       	jmp    8010665a <alltraps>

8010720f <vector174>:
.globl vector174
vector174:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $174
80107211:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107216:	e9 3f f4 ff ff       	jmp    8010665a <alltraps>

8010721b <vector175>:
.globl vector175
vector175:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $175
8010721d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107222:	e9 33 f4 ff ff       	jmp    8010665a <alltraps>

80107227 <vector176>:
.globl vector176
vector176:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $176
80107229:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010722e:	e9 27 f4 ff ff       	jmp    8010665a <alltraps>

80107233 <vector177>:
.globl vector177
vector177:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $177
80107235:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010723a:	e9 1b f4 ff ff       	jmp    8010665a <alltraps>

8010723f <vector178>:
.globl vector178
vector178:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $178
80107241:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107246:	e9 0f f4 ff ff       	jmp    8010665a <alltraps>

8010724b <vector179>:
.globl vector179
vector179:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $179
8010724d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107252:	e9 03 f4 ff ff       	jmp    8010665a <alltraps>

80107257 <vector180>:
.globl vector180
vector180:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $180
80107259:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010725e:	e9 f7 f3 ff ff       	jmp    8010665a <alltraps>

80107263 <vector181>:
.globl vector181
vector181:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $181
80107265:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010726a:	e9 eb f3 ff ff       	jmp    8010665a <alltraps>

8010726f <vector182>:
.globl vector182
vector182:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $182
80107271:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107276:	e9 df f3 ff ff       	jmp    8010665a <alltraps>

8010727b <vector183>:
.globl vector183
vector183:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $183
8010727d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107282:	e9 d3 f3 ff ff       	jmp    8010665a <alltraps>

80107287 <vector184>:
.globl vector184
vector184:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $184
80107289:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010728e:	e9 c7 f3 ff ff       	jmp    8010665a <alltraps>

80107293 <vector185>:
.globl vector185
vector185:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $185
80107295:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010729a:	e9 bb f3 ff ff       	jmp    8010665a <alltraps>

8010729f <vector186>:
.globl vector186
vector186:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $186
801072a1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801072a6:	e9 af f3 ff ff       	jmp    8010665a <alltraps>

801072ab <vector187>:
.globl vector187
vector187:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $187
801072ad:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801072b2:	e9 a3 f3 ff ff       	jmp    8010665a <alltraps>

801072b7 <vector188>:
.globl vector188
vector188:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $188
801072b9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801072be:	e9 97 f3 ff ff       	jmp    8010665a <alltraps>

801072c3 <vector189>:
.globl vector189
vector189:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $189
801072c5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801072ca:	e9 8b f3 ff ff       	jmp    8010665a <alltraps>

801072cf <vector190>:
.globl vector190
vector190:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $190
801072d1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801072d6:	e9 7f f3 ff ff       	jmp    8010665a <alltraps>

801072db <vector191>:
.globl vector191
vector191:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $191
801072dd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072e2:	e9 73 f3 ff ff       	jmp    8010665a <alltraps>

801072e7 <vector192>:
.globl vector192
vector192:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $192
801072e9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072ee:	e9 67 f3 ff ff       	jmp    8010665a <alltraps>

801072f3 <vector193>:
.globl vector193
vector193:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $193
801072f5:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801072fa:	e9 5b f3 ff ff       	jmp    8010665a <alltraps>

801072ff <vector194>:
.globl vector194
vector194:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $194
80107301:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107306:	e9 4f f3 ff ff       	jmp    8010665a <alltraps>

8010730b <vector195>:
.globl vector195
vector195:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $195
8010730d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107312:	e9 43 f3 ff ff       	jmp    8010665a <alltraps>

80107317 <vector196>:
.globl vector196
vector196:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $196
80107319:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010731e:	e9 37 f3 ff ff       	jmp    8010665a <alltraps>

80107323 <vector197>:
.globl vector197
vector197:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $197
80107325:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010732a:	e9 2b f3 ff ff       	jmp    8010665a <alltraps>

8010732f <vector198>:
.globl vector198
vector198:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $198
80107331:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107336:	e9 1f f3 ff ff       	jmp    8010665a <alltraps>

8010733b <vector199>:
.globl vector199
vector199:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $199
8010733d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107342:	e9 13 f3 ff ff       	jmp    8010665a <alltraps>

80107347 <vector200>:
.globl vector200
vector200:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $200
80107349:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010734e:	e9 07 f3 ff ff       	jmp    8010665a <alltraps>

80107353 <vector201>:
.globl vector201
vector201:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $201
80107355:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010735a:	e9 fb f2 ff ff       	jmp    8010665a <alltraps>

8010735f <vector202>:
.globl vector202
vector202:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $202
80107361:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107366:	e9 ef f2 ff ff       	jmp    8010665a <alltraps>

8010736b <vector203>:
.globl vector203
vector203:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $203
8010736d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107372:	e9 e3 f2 ff ff       	jmp    8010665a <alltraps>

80107377 <vector204>:
.globl vector204
vector204:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $204
80107379:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010737e:	e9 d7 f2 ff ff       	jmp    8010665a <alltraps>

80107383 <vector205>:
.globl vector205
vector205:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $205
80107385:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010738a:	e9 cb f2 ff ff       	jmp    8010665a <alltraps>

8010738f <vector206>:
.globl vector206
vector206:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $206
80107391:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107396:	e9 bf f2 ff ff       	jmp    8010665a <alltraps>

8010739b <vector207>:
.globl vector207
vector207:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $207
8010739d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801073a2:	e9 b3 f2 ff ff       	jmp    8010665a <alltraps>

801073a7 <vector208>:
.globl vector208
vector208:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $208
801073a9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801073ae:	e9 a7 f2 ff ff       	jmp    8010665a <alltraps>

801073b3 <vector209>:
.globl vector209
vector209:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $209
801073b5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801073ba:	e9 9b f2 ff ff       	jmp    8010665a <alltraps>

801073bf <vector210>:
.globl vector210
vector210:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $210
801073c1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801073c6:	e9 8f f2 ff ff       	jmp    8010665a <alltraps>

801073cb <vector211>:
.globl vector211
vector211:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $211
801073cd:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801073d2:	e9 83 f2 ff ff       	jmp    8010665a <alltraps>

801073d7 <vector212>:
.globl vector212
vector212:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $212
801073d9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801073de:	e9 77 f2 ff ff       	jmp    8010665a <alltraps>

801073e3 <vector213>:
.globl vector213
vector213:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $213
801073e5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073ea:	e9 6b f2 ff ff       	jmp    8010665a <alltraps>

801073ef <vector214>:
.globl vector214
vector214:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $214
801073f1:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801073f6:	e9 5f f2 ff ff       	jmp    8010665a <alltraps>

801073fb <vector215>:
.globl vector215
vector215:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $215
801073fd:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107402:	e9 53 f2 ff ff       	jmp    8010665a <alltraps>

80107407 <vector216>:
.globl vector216
vector216:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $216
80107409:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010740e:	e9 47 f2 ff ff       	jmp    8010665a <alltraps>

80107413 <vector217>:
.globl vector217
vector217:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $217
80107415:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010741a:	e9 3b f2 ff ff       	jmp    8010665a <alltraps>

8010741f <vector218>:
.globl vector218
vector218:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $218
80107421:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107426:	e9 2f f2 ff ff       	jmp    8010665a <alltraps>

8010742b <vector219>:
.globl vector219
vector219:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $219
8010742d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107432:	e9 23 f2 ff ff       	jmp    8010665a <alltraps>

80107437 <vector220>:
.globl vector220
vector220:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $220
80107439:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010743e:	e9 17 f2 ff ff       	jmp    8010665a <alltraps>

80107443 <vector221>:
.globl vector221
vector221:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $221
80107445:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010744a:	e9 0b f2 ff ff       	jmp    8010665a <alltraps>

8010744f <vector222>:
.globl vector222
vector222:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $222
80107451:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107456:	e9 ff f1 ff ff       	jmp    8010665a <alltraps>

8010745b <vector223>:
.globl vector223
vector223:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $223
8010745d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107462:	e9 f3 f1 ff ff       	jmp    8010665a <alltraps>

80107467 <vector224>:
.globl vector224
vector224:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $224
80107469:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010746e:	e9 e7 f1 ff ff       	jmp    8010665a <alltraps>

80107473 <vector225>:
.globl vector225
vector225:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $225
80107475:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010747a:	e9 db f1 ff ff       	jmp    8010665a <alltraps>

8010747f <vector226>:
.globl vector226
vector226:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $226
80107481:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107486:	e9 cf f1 ff ff       	jmp    8010665a <alltraps>

8010748b <vector227>:
.globl vector227
vector227:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $227
8010748d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107492:	e9 c3 f1 ff ff       	jmp    8010665a <alltraps>

80107497 <vector228>:
.globl vector228
vector228:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $228
80107499:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010749e:	e9 b7 f1 ff ff       	jmp    8010665a <alltraps>

801074a3 <vector229>:
.globl vector229
vector229:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $229
801074a5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801074aa:	e9 ab f1 ff ff       	jmp    8010665a <alltraps>

801074af <vector230>:
.globl vector230
vector230:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $230
801074b1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801074b6:	e9 9f f1 ff ff       	jmp    8010665a <alltraps>

801074bb <vector231>:
.globl vector231
vector231:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $231
801074bd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801074c2:	e9 93 f1 ff ff       	jmp    8010665a <alltraps>

801074c7 <vector232>:
.globl vector232
vector232:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $232
801074c9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801074ce:	e9 87 f1 ff ff       	jmp    8010665a <alltraps>

801074d3 <vector233>:
.globl vector233
vector233:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $233
801074d5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801074da:	e9 7b f1 ff ff       	jmp    8010665a <alltraps>

801074df <vector234>:
.globl vector234
vector234:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $234
801074e1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074e6:	e9 6f f1 ff ff       	jmp    8010665a <alltraps>

801074eb <vector235>:
.globl vector235
vector235:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $235
801074ed:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801074f2:	e9 63 f1 ff ff       	jmp    8010665a <alltraps>

801074f7 <vector236>:
.globl vector236
vector236:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $236
801074f9:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801074fe:	e9 57 f1 ff ff       	jmp    8010665a <alltraps>

80107503 <vector237>:
.globl vector237
vector237:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $237
80107505:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010750a:	e9 4b f1 ff ff       	jmp    8010665a <alltraps>

8010750f <vector238>:
.globl vector238
vector238:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $238
80107511:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107516:	e9 3f f1 ff ff       	jmp    8010665a <alltraps>

8010751b <vector239>:
.globl vector239
vector239:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $239
8010751d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107522:	e9 33 f1 ff ff       	jmp    8010665a <alltraps>

80107527 <vector240>:
.globl vector240
vector240:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $240
80107529:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010752e:	e9 27 f1 ff ff       	jmp    8010665a <alltraps>

80107533 <vector241>:
.globl vector241
vector241:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $241
80107535:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010753a:	e9 1b f1 ff ff       	jmp    8010665a <alltraps>

8010753f <vector242>:
.globl vector242
vector242:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $242
80107541:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107546:	e9 0f f1 ff ff       	jmp    8010665a <alltraps>

8010754b <vector243>:
.globl vector243
vector243:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $243
8010754d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107552:	e9 03 f1 ff ff       	jmp    8010665a <alltraps>

80107557 <vector244>:
.globl vector244
vector244:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $244
80107559:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010755e:	e9 f7 f0 ff ff       	jmp    8010665a <alltraps>

80107563 <vector245>:
.globl vector245
vector245:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $245
80107565:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010756a:	e9 eb f0 ff ff       	jmp    8010665a <alltraps>

8010756f <vector246>:
.globl vector246
vector246:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $246
80107571:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107576:	e9 df f0 ff ff       	jmp    8010665a <alltraps>

8010757b <vector247>:
.globl vector247
vector247:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $247
8010757d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107582:	e9 d3 f0 ff ff       	jmp    8010665a <alltraps>

80107587 <vector248>:
.globl vector248
vector248:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $248
80107589:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010758e:	e9 c7 f0 ff ff       	jmp    8010665a <alltraps>

80107593 <vector249>:
.globl vector249
vector249:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $249
80107595:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010759a:	e9 bb f0 ff ff       	jmp    8010665a <alltraps>

8010759f <vector250>:
.globl vector250
vector250:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $250
801075a1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801075a6:	e9 af f0 ff ff       	jmp    8010665a <alltraps>

801075ab <vector251>:
.globl vector251
vector251:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $251
801075ad:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801075b2:	e9 a3 f0 ff ff       	jmp    8010665a <alltraps>

801075b7 <vector252>:
.globl vector252
vector252:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $252
801075b9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801075be:	e9 97 f0 ff ff       	jmp    8010665a <alltraps>

801075c3 <vector253>:
.globl vector253
vector253:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $253
801075c5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801075ca:	e9 8b f0 ff ff       	jmp    8010665a <alltraps>

801075cf <vector254>:
.globl vector254
vector254:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $254
801075d1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801075d6:	e9 7f f0 ff ff       	jmp    8010665a <alltraps>

801075db <vector255>:
.globl vector255
vector255:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $255
801075dd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075e2:	e9 73 f0 ff ff       	jmp    8010665a <alltraps>
801075e7:	66 90                	xchg   %ax,%ax
801075e9:	66 90                	xchg   %ax,%ax
801075eb:	66 90                	xchg   %ax,%ax
801075ed:	66 90                	xchg   %ax,%ax
801075ef:	90                   	nop

801075f0 <deallocuvm2.part.0>:
  }
  return newsz;
}


int deallocuvm2(pde_t *pgdir, uint oldsz, uint newsz,struct proc * p)
801075f0:	55                   	push   %ebp
801075f1:	89 e5                	mov    %esp,%ebp
801075f3:	57                   	push   %edi
801075f4:	56                   	push   %esi
801075f5:	89 c6                	mov    %eax,%esi
801075f7:	89 c8                	mov    %ecx,%eax
801075f9:	53                   	push   %ebx
  uint a, pa;
  // cprintf("Initially Old size %d %d new size %d\n", *pgdir,oldsz,newsz);
  if (newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
801075fa:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
80107600:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
int deallocuvm2(pde_t *pgdir, uint oldsz, uint newsz,struct proc * p)
80107606:	83 ec 1c             	sub    $0x1c,%esp
  for (; a < oldsz; a += PGSIZE)
80107609:	39 d3                	cmp    %edx,%ebx
8010760b:	0f 83 9a 00 00 00    	jae    801076ab <deallocuvm2.part.0+0xbb>
80107611:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80107614:	eb 16                	jmp    8010762c <deallocuvm2.part.0+0x3c>
80107616:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010761d:	8d 76 00             	lea    0x0(%esi),%esi
  {
    pte = walkpgdir(pgdir, (char *)a, 0);
    if (!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107620:	83 c7 01             	add    $0x1,%edi
80107623:	89 fb                	mov    %edi,%ebx
80107625:	c1 e3 16             	shl    $0x16,%ebx
  for (; a < oldsz; a += PGSIZE)
80107628:	39 d3                	cmp    %edx,%ebx
8010762a:	73 7c                	jae    801076a8 <deallocuvm2.part.0+0xb8>
  pde = &pgdir[PDX(va)];
8010762c:	89 df                	mov    %ebx,%edi
8010762e:	c1 ef 16             	shr    $0x16,%edi
  if (*pde & PTE_P)
80107631:	8b 04 be             	mov    (%esi,%edi,4),%eax
80107634:	a8 01                	test   $0x1,%al
80107636:	74 e8                	je     80107620 <deallocuvm2.part.0+0x30>
  return &pgtab[PTX(va)];
80107638:	89 d9                	mov    %ebx,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
8010763a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
8010763f:	c1 e9 0a             	shr    $0xa,%ecx
80107642:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
80107648:	8d 8c 08 00 00 00 80 	lea    -0x80000000(%eax,%ecx,1),%ecx
    if (!pte)
8010764f:	85 c9                	test   %ecx,%ecx
80107651:	74 cd                	je     80107620 <deallocuvm2.part.0+0x30>
    else if ((*pte & PTE_P) != 0)
80107653:	8b 01                	mov    (%ecx),%eax
80107655:	a8 01                	test   $0x1,%al
80107657:	74 45                	je     8010769e <deallocuvm2.part.0+0xae>
    {
      pa = PTE_ADDR(*pte);
      if (pa == 0)
80107659:	89 c7                	mov    %eax,%edi
8010765b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80107661:	74 6f                	je     801076d2 <deallocuvm2.part.0+0xe2>
      // cprintf("In dealloc Old size %d new size %d %d %d %d\n",a,oldsz,newsz,pte,*pgdir);
      if(0) {
        clear_swapped_page(pte);
        *pte = 0;
      }
      else{int do_free = dec_sharing(pte, pa / PGSIZE);
80107663:	83 ec 08             	sub    $0x8,%esp
80107666:	c1 e8 0c             	shr    $0xc,%eax
80107669:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010766c:	50                   	push   %eax
8010766d:	51                   	push   %ecx
8010766e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80107671:	e8 3a c5 ff ff       	call   80103bb0 <dec_sharing>
      if (do_free)
80107676:	83 c4 10             	add    $0x10,%esp
80107679:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010767c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010767f:	85 c0                	test   %eax,%eax
80107681:	75 35                	jne    801076b8 <deallocuvm2.part.0+0xc8>
        kfree(v);
      if(p->rss > 0) p->rss -= PGSIZE;}
80107683:	8b 45 08             	mov    0x8(%ebp),%eax
80107686:	8b 40 04             	mov    0x4(%eax),%eax
80107689:	85 c0                	test   %eax,%eax
8010768b:	74 0b                	je     80107698 <deallocuvm2.part.0+0xa8>
8010768d:	8b 7d 08             	mov    0x8(%ebp),%edi
80107690:	2d 00 10 00 00       	sub    $0x1000,%eax
80107695:	89 47 04             	mov    %eax,0x4(%edi)
      *pte = 0;
80107698:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  for (; a < oldsz; a += PGSIZE)
8010769e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801076a4:	39 d3                	cmp    %edx,%ebx
801076a6:	72 84                	jb     8010762c <deallocuvm2.part.0+0x3c>
801076a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
    }
  }
  return newsz;
}
801076ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076ae:	5b                   	pop    %ebx
801076af:	5e                   	pop    %esi
801076b0:	5f                   	pop    %edi
801076b1:	5d                   	pop    %ebp
801076b2:	c3                   	ret
801076b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801076b7:	90                   	nop
        kfree(v);
801076b8:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
801076bb:	81 c7 00 00 00 80    	add    $0x80000000,%edi
        kfree(v);
801076c1:	57                   	push   %edi
801076c2:	e8 09 af ff ff       	call   801025d0 <kfree>
801076c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801076ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801076cd:	83 c4 10             	add    $0x10,%esp
801076d0:	eb b1                	jmp    80107683 <deallocuvm2.part.0+0x93>
        panic("kfree");
801076d2:	83 ec 0c             	sub    $0xc,%esp
801076d5:	68 fb 83 10 80       	push   $0x801083fb
801076da:	e8 d1 8d ff ff       	call   801004b0 <panic>
801076df:	90                   	nop

801076e0 <deallocuvm.part.0>:
int deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
801076e0:	55                   	push   %ebp
801076e1:	89 e5                	mov    %esp,%ebp
801076e3:	57                   	push   %edi
801076e4:	56                   	push   %esi
801076e5:	89 ce                	mov    %ecx,%esi
801076e7:	53                   	push   %ebx
  a = PGROUNDUP(newsz);
801076e8:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
801076ee:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
int deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
801076f4:	83 ec 1c             	sub    $0x1c,%esp
801076f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for (; a < oldsz; a += PGSIZE)
801076fa:	39 d3                	cmp    %edx,%ebx
801076fc:	0f 83 8d 00 00 00    	jae    8010778f <deallocuvm.part.0+0xaf>
80107702:	89 55 e0             	mov    %edx,-0x20(%ebp)
80107705:	89 de                	mov    %ebx,%esi
80107707:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010770a:	eb 13                	jmp    8010771f <deallocuvm.part.0+0x3f>
8010770c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107710:	83 c3 01             	add    $0x1,%ebx
  for (; a < oldsz; a += PGSIZE)
80107713:	8b 45 e0             	mov    -0x20(%ebp),%eax
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107716:	89 de                	mov    %ebx,%esi
80107718:	c1 e6 16             	shl    $0x16,%esi
  for (; a < oldsz; a += PGSIZE)
8010771b:	39 c6                	cmp    %eax,%esi
8010771d:	73 6d                	jae    8010778c <deallocuvm.part.0+0xac>
  if (*pde & PTE_P)
8010771f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  pde = &pgdir[PDX(va)];
80107722:	89 f3                	mov    %esi,%ebx
80107724:	c1 eb 16             	shr    $0x16,%ebx
  if (*pde & PTE_P)
80107727:	8b 04 98             	mov    (%eax,%ebx,4),%eax
8010772a:	a8 01                	test   $0x1,%al
8010772c:	74 e2                	je     80107710 <deallocuvm.part.0+0x30>
  return &pgtab[PTX(va)];
8010772e:	89 f1                	mov    %esi,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80107730:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107735:	c1 e9 0a             	shr    $0xa,%ecx
80107738:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
8010773e:	8d bc 08 00 00 00 80 	lea    -0x80000000(%eax,%ecx,1),%edi
    if (!pte)
80107745:	85 ff                	test   %edi,%edi
80107747:	74 c7                	je     80107710 <deallocuvm.part.0+0x30>
    else if ((*pte & PTE_P) != 0)
80107749:	8b 07                	mov    (%edi),%eax
8010774b:	a8 01                	test   $0x1,%al
8010774d:	74 30                	je     8010777f <deallocuvm.part.0+0x9f>
      if (pa == 0)
8010774f:	89 c3                	mov    %eax,%ebx
80107751:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107757:	74 6b                	je     801077c4 <deallocuvm.part.0+0xe4>
      else{int do_free = dec_sharing(pte, pa / PGSIZE);
80107759:	83 ec 08             	sub    $0x8,%esp
8010775c:	c1 e8 0c             	shr    $0xc,%eax
8010775f:	50                   	push   %eax
80107760:	57                   	push   %edi
80107761:	e8 4a c4 ff ff       	call   80103bb0 <dec_sharing>
      if (do_free)
80107766:	83 c4 10             	add    $0x10,%esp
80107769:	85 c0                	test   %eax,%eax
8010776b:	75 43                	jne    801077b0 <deallocuvm.part.0+0xd0>
      if(myproc()->rss > 0) myproc()->rss -= PGSIZE;}
8010776d:	e8 7e c5 ff ff       	call   80103cf0 <myproc>
80107772:	8b 40 04             	mov    0x4(%eax),%eax
80107775:	85 c0                	test   %eax,%eax
80107777:	75 27                	jne    801077a0 <deallocuvm.part.0+0xc0>
      *pte = 0;
80107779:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  for (; a < oldsz; a += PGSIZE)
8010777f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107782:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107788:	39 c6                	cmp    %eax,%esi
8010778a:	72 93                	jb     8010771f <deallocuvm.part.0+0x3f>
8010778c:	8b 75 dc             	mov    -0x24(%ebp),%esi
}
8010778f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107792:	89 f0                	mov    %esi,%eax
80107794:	5b                   	pop    %ebx
80107795:	5e                   	pop    %esi
80107796:	5f                   	pop    %edi
80107797:	5d                   	pop    %ebp
80107798:	c3                   	ret
80107799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(myproc()->rss > 0) myproc()->rss -= PGSIZE;}
801077a0:	e8 4b c5 ff ff       	call   80103cf0 <myproc>
801077a5:	81 68 04 00 10 00 00 	subl   $0x1000,0x4(%eax)
801077ac:	eb cb                	jmp    80107779 <deallocuvm.part.0+0x99>
801077ae:	66 90                	xchg   %ax,%ax
        kfree(v);
801077b0:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
801077b3:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
        kfree(v);
801077b9:	53                   	push   %ebx
801077ba:	e8 11 ae ff ff       	call   801025d0 <kfree>
801077bf:	83 c4 10             	add    $0x10,%esp
801077c2:	eb a9                	jmp    8010776d <deallocuvm.part.0+0x8d>
        panic("kfree");
801077c4:	83 ec 0c             	sub    $0xc,%esp
801077c7:	68 fb 83 10 80       	push   $0x801083fb
801077cc:	e8 df 8c ff ff       	call   801004b0 <panic>
801077d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077df:	90                   	nop

801077e0 <mappages>:
{
801077e0:	55                   	push   %ebp
801077e1:	89 e5                	mov    %esp,%ebp
801077e3:	57                   	push   %edi
801077e4:	56                   	push   %esi
801077e5:	53                   	push   %ebx
  a = (char *)PGROUNDDOWN((uint)va);
801077e6:	89 d3                	mov    %edx,%ebx
801077e8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
801077ee:	83 ec 1c             	sub    $0x1c,%esp
801077f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  last = (char *)PGROUNDDOWN(((uint)va) + size - 1);
801077f4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
801077f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
80107800:	8b 45 08             	mov    0x8(%ebp),%eax
80107803:	29 d8                	sub    %ebx,%eax
80107805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107808:	eb 3f                	jmp    80107849 <mappages+0x69>
8010780a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107810:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80107812:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107817:	c1 ea 0a             	shr    $0xa,%edx
8010781a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107820:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107827:	85 c0                	test   %eax,%eax
80107829:	74 75                	je     801078a0 <mappages+0xc0>
    if (*pte & PTE_P)
8010782b:	f6 00 01             	testb  $0x1,(%eax)
8010782e:	0f 85 86 00 00 00    	jne    801078ba <mappages+0xda>
    *pte = pa | perm | PTE_P;
80107834:	0b 75 0c             	or     0xc(%ebp),%esi
80107837:	83 ce 01             	or     $0x1,%esi
8010783a:	89 30                	mov    %esi,(%eax)
    if (a == last)
8010783c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010783f:	39 c3                	cmp    %eax,%ebx
80107841:	74 6d                	je     801078b0 <mappages+0xd0>
    a += PGSIZE;
80107843:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for (;;)
80107849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  pde = &pgdir[PDX(va)];
8010784c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010784f:	8d 34 03             	lea    (%ebx,%eax,1),%esi
80107852:	89 d8                	mov    %ebx,%eax
80107854:	c1 e8 16             	shr    $0x16,%eax
80107857:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if (*pde & PTE_P)
8010785a:	8b 07                	mov    (%edi),%eax
8010785c:	a8 01                	test   $0x1,%al
8010785e:	75 b0                	jne    80107810 <mappages+0x30>
    if (!alloc || (pgtab = (pte_t *)kalloc()) == 0)
80107860:	e8 3b af ff ff       	call   801027a0 <kalloc>
80107865:	85 c0                	test   %eax,%eax
80107867:	74 37                	je     801078a0 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80107869:	83 ec 04             	sub    $0x4,%esp
8010786c:	68 00 10 00 00       	push   $0x1000
80107871:	6a 00                	push   $0x0
80107873:	50                   	push   %eax
80107874:	89 45 d8             	mov    %eax,-0x28(%ebp)
80107877:	e8 24 dc ff ff       	call   801054a0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010787c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
8010787f:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107882:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80107888:	83 c8 07             	or     $0x7,%eax
8010788b:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
8010788d:	89 d8                	mov    %ebx,%eax
8010788f:	c1 e8 0a             	shr    $0xa,%eax
80107892:	25 fc 0f 00 00       	and    $0xffc,%eax
80107897:	01 d0                	add    %edx,%eax
80107899:	eb 90                	jmp    8010782b <mappages+0x4b>
8010789b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010789f:	90                   	nop
}
801078a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801078a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801078a8:	5b                   	pop    %ebx
801078a9:	5e                   	pop    %esi
801078aa:	5f                   	pop    %edi
801078ab:	5d                   	pop    %ebp
801078ac:	c3                   	ret
801078ad:	8d 76 00             	lea    0x0(%esi),%esi
801078b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801078b3:	31 c0                	xor    %eax,%eax
}
801078b5:	5b                   	pop    %ebx
801078b6:	5e                   	pop    %esi
801078b7:	5f                   	pop    %edi
801078b8:	5d                   	pop    %ebp
801078b9:	c3                   	ret
      panic("remap");
801078ba:	83 ec 0c             	sub    $0xc,%esp
801078bd:	68 d3 86 10 80       	push   $0x801086d3
801078c2:	e8 e9 8b ff ff       	call   801004b0 <panic>
801078c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078ce:	66 90                	xchg   %ax,%ax

801078d0 <seginit>:
{
801078d0:	55                   	push   %ebp
801078d1:	89 e5                	mov    %esp,%ebp
801078d3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
801078d6:	e8 f5 c3 ff ff       	call   80103cd0 <cpuid>
  pd[0] = size-1;
801078db:	ba 2f 00 00 00       	mov    $0x2f,%edx
  c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
801078e0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801078e6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
801078ea:	c7 80 58 28 11 80 ff 	movl   $0xffff,-0x7feed7a8(%eax)
801078f1:	ff 00 00 
801078f4:	c7 80 5c 28 11 80 00 	movl   $0xcf9a00,-0x7feed7a4(%eax)
801078fb:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078fe:	c7 80 60 28 11 80 ff 	movl   $0xffff,-0x7feed7a0(%eax)
80107905:	ff 00 00 
80107908:	c7 80 64 28 11 80 00 	movl   $0xcf9200,-0x7feed79c(%eax)
8010790f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
80107912:	c7 80 68 28 11 80 ff 	movl   $0xffff,-0x7feed798(%eax)
80107919:	ff 00 00 
8010791c:	c7 80 6c 28 11 80 00 	movl   $0xcffa00,-0x7feed794(%eax)
80107923:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107926:	c7 80 70 28 11 80 ff 	movl   $0xffff,-0x7feed790(%eax)
8010792d:	ff 00 00 
80107930:	c7 80 74 28 11 80 00 	movl   $0xcff200,-0x7feed78c(%eax)
80107937:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010793a:	05 50 28 11 80       	add    $0x80112850,%eax
  pd[1] = (uint)p;
8010793f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107943:	c1 e8 10             	shr    $0x10,%eax
80107946:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010794a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010794d:	0f 01 10             	lgdtl  (%eax)
}
80107950:	c9                   	leave
80107951:	c3                   	ret
80107952:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107960 <switchkvm>:
  lcr3(V2P(kpgdir)); // switch to the kernel page table
80107960:	a1 a4 39 1c 80       	mov    0x801c39a4,%eax
80107965:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010796a:	0f 22 d8             	mov    %eax,%cr3
}
8010796d:	c3                   	ret
8010796e:	66 90                	xchg   %ax,%ax

80107970 <switchuvm>:
{
80107970:	55                   	push   %ebp
80107971:	89 e5                	mov    %esp,%ebp
80107973:	57                   	push   %edi
80107974:	56                   	push   %esi
80107975:	53                   	push   %ebx
80107976:	83 ec 1c             	sub    $0x1c,%esp
80107979:	8b 75 08             	mov    0x8(%ebp),%esi
  if (p == 0)
8010797c:	85 f6                	test   %esi,%esi
8010797e:	0f 84 cb 00 00 00    	je     80107a4f <switchuvm+0xdf>
  if (p->kstack == 0)
80107984:	8b 46 0c             	mov    0xc(%esi),%eax
80107987:	85 c0                	test   %eax,%eax
80107989:	0f 84 da 00 00 00    	je     80107a69 <switchuvm+0xf9>
  if (p->pgdir == 0)
8010798f:	8b 46 08             	mov    0x8(%esi),%eax
80107992:	85 c0                	test   %eax,%eax
80107994:	0f 84 c2 00 00 00    	je     80107a5c <switchuvm+0xec>
  pushcli();
8010799a:	e8 b1 d8 ff ff       	call   80105250 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010799f:	e8 cc c2 ff ff       	call   80103c70 <mycpu>
801079a4:	89 c3                	mov    %eax,%ebx
801079a6:	e8 c5 c2 ff ff       	call   80103c70 <mycpu>
801079ab:	89 c7                	mov    %eax,%edi
801079ad:	e8 be c2 ff ff       	call   80103c70 <mycpu>
801079b2:	83 c7 08             	add    $0x8,%edi
801079b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801079b8:	e8 b3 c2 ff ff       	call   80103c70 <mycpu>
801079bd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801079c0:	ba 67 00 00 00       	mov    $0x67,%edx
801079c5:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801079cc:	83 c0 08             	add    $0x8,%eax
801079cf:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort)0xFFFF;
801079d6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801079db:	83 c1 08             	add    $0x8,%ecx
801079de:	c1 e8 18             	shr    $0x18,%eax
801079e1:	c1 e9 10             	shr    $0x10,%ecx
801079e4:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
801079ea:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801079f0:	b9 99 40 00 00       	mov    $0x4099,%ecx
801079f5:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801079fc:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80107a01:	e8 6a c2 ff ff       	call   80103c70 <mycpu>
80107a06:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a0d:	e8 5e c2 ff ff       	call   80103c70 <mycpu>
80107a12:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a16:	8b 5e 0c             	mov    0xc(%esi),%ebx
80107a19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107a1f:	e8 4c c2 ff ff       	call   80103c70 <mycpu>
80107a24:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort)0xFFFF;
80107a27:	e8 44 c2 ff ff       	call   80103c70 <mycpu>
80107a2c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107a30:	b8 28 00 00 00       	mov    $0x28,%eax
80107a35:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir)); // switch to process's address space
80107a38:	8b 46 08             	mov    0x8(%esi),%eax
80107a3b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a40:	0f 22 d8             	mov    %eax,%cr3
}
80107a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a46:	5b                   	pop    %ebx
80107a47:	5e                   	pop    %esi
80107a48:	5f                   	pop    %edi
80107a49:	5d                   	pop    %ebp
  popcli();
80107a4a:	e9 51 d8 ff ff       	jmp    801052a0 <popcli>
    panic("switchuvm: no process");
80107a4f:	83 ec 0c             	sub    $0xc,%esp
80107a52:	68 d9 86 10 80       	push   $0x801086d9
80107a57:	e8 54 8a ff ff       	call   801004b0 <panic>
    panic("switchuvm: no pgdir");
80107a5c:	83 ec 0c             	sub    $0xc,%esp
80107a5f:	68 04 87 10 80       	push   $0x80108704
80107a64:	e8 47 8a ff ff       	call   801004b0 <panic>
    panic("switchuvm: no kstack");
80107a69:	83 ec 0c             	sub    $0xc,%esp
80107a6c:	68 ef 86 10 80       	push   $0x801086ef
80107a71:	e8 3a 8a ff ff       	call   801004b0 <panic>
80107a76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107a7d:	8d 76 00             	lea    0x0(%esi),%esi

80107a80 <inituvm>:
{
80107a80:	55                   	push   %ebp
80107a81:	89 e5                	mov    %esp,%ebp
80107a83:	57                   	push   %edi
80107a84:	56                   	push   %esi
80107a85:	53                   	push   %ebx
80107a86:	83 ec 1c             	sub    $0x1c,%esp
80107a89:	8b 45 08             	mov    0x8(%ebp),%eax
80107a8c:	8b 7d 10             	mov    0x10(%ebp),%edi
80107a8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (sz >= PGSIZE)
80107a98:	81 ff ff 0f 00 00    	cmp    $0xfff,%edi
80107a9e:	77 72                	ja     80107b12 <inituvm+0x92>
  mem = kalloc();
80107aa0:	e8 fb ac ff ff       	call   801027a0 <kalloc>
  memset(mem, 0, PGSIZE);
80107aa5:	83 ec 04             	sub    $0x4,%esp
80107aa8:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80107aad:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80107aaf:	6a 00                	push   $0x0
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W | PTE_U);
80107ab1:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  memset(mem, 0, PGSIZE);
80107ab7:	50                   	push   %eax
80107ab8:	e8 e3 d9 ff ff       	call   801054a0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W | PTE_U);
80107abd:	58                   	pop    %eax
80107abe:	5a                   	pop    %edx
80107abf:	6a 06                	push   $0x6
80107ac1:	56                   	push   %esi
80107ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ac5:	31 d2                	xor    %edx,%edx
80107ac7:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107acc:	e8 0f fd ff ff       	call   801077e0 <mappages>
  memmove(mem, init, sz);
80107ad1:	83 c4 0c             	add    $0xc,%esp
80107ad4:	57                   	push   %edi
80107ad5:	ff 75 e0             	push   -0x20(%ebp)
80107ad8:	53                   	push   %ebx
80107ad9:	e8 52 da ff ff       	call   80105530 <memmove>
  if (*pde & PTE_P)
80107ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ae1:	83 c4 10             	add    $0x10,%esp
80107ae4:	8b 10                	mov    (%eax),%edx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80107ae6:	89 d0                	mov    %edx,%eax
80107ae8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aed:	05 00 00 00 80       	add    $0x80000000,%eax
80107af2:	83 e2 01             	and    $0x1,%edx
80107af5:	ba 00 00 00 00       	mov    $0x0,%edx
80107afa:	0f 44 c2             	cmove  %edx,%eax
  inc_sharing(pte, V2P(mem) / PGSIZE);
80107afd:	c1 ee 0c             	shr    $0xc,%esi
80107b00:	89 75 0c             	mov    %esi,0xc(%ebp)
80107b03:	89 45 08             	mov    %eax,0x8(%ebp)
}
80107b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107b09:	5b                   	pop    %ebx
80107b0a:	5e                   	pop    %esi
80107b0b:	5f                   	pop    %edi
80107b0c:	5d                   	pop    %ebp
  inc_sharing(pte, V2P(mem) / PGSIZE);
80107b0d:	e9 1e c0 ff ff       	jmp    80103b30 <inc_sharing>
    panic("inituvm: more than a page");
80107b12:	83 ec 0c             	sub    $0xc,%esp
80107b15:	68 18 87 10 80       	push   $0x80108718
80107b1a:	e8 91 89 ff ff       	call   801004b0 <panic>
80107b1f:	90                   	nop

80107b20 <loaduvm>:
{
80107b20:	55                   	push   %ebp
80107b21:	89 e5                	mov    %esp,%ebp
80107b23:	57                   	push   %edi
80107b24:	56                   	push   %esi
80107b25:	53                   	push   %ebx
80107b26:	83 ec 0c             	sub    $0xc,%esp
  if ((uint)addr % PGSIZE != 0)
80107b29:	8b 75 0c             	mov    0xc(%ebp),%esi
{
80107b2c:	8b 7d 18             	mov    0x18(%ebp),%edi
  if ((uint)addr % PGSIZE != 0)
80107b2f:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
80107b35:	0f 85 a2 00 00 00    	jne    80107bdd <loaduvm+0xbd>
  for (i = 0; i < sz; i += PGSIZE)
80107b3b:	85 ff                	test   %edi,%edi
80107b3d:	74 7d                	je     80107bbc <loaduvm+0x9c>
80107b3f:	90                   	nop
  pde = &pgdir[PDX(va)];
80107b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  if (*pde & PTE_P)
80107b43:	8b 55 08             	mov    0x8(%ebp),%edx
80107b46:	01 f0                	add    %esi,%eax
  pde = &pgdir[PDX(va)];
80107b48:	89 c1                	mov    %eax,%ecx
80107b4a:	c1 e9 16             	shr    $0x16,%ecx
  if (*pde & PTE_P)
80107b4d:	8b 0c 8a             	mov    (%edx,%ecx,4),%ecx
80107b50:	f6 c1 01             	test   $0x1,%cl
80107b53:	75 13                	jne    80107b68 <loaduvm+0x48>
      panic("loaduvm: address should exist");
80107b55:	83 ec 0c             	sub    $0xc,%esp
80107b58:	68 32 87 10 80       	push   $0x80108732
80107b5d:	e8 4e 89 ff ff       	call   801004b0 <panic>
80107b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107b68:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80107b6b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80107b71:	25 fc 0f 00 00       	and    $0xffc,%eax
80107b76:	8d 8c 01 00 00 00 80 	lea    -0x80000000(%ecx,%eax,1),%ecx
    if ((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
80107b7d:	85 c9                	test   %ecx,%ecx
80107b7f:	74 d4                	je     80107b55 <loaduvm+0x35>
    if (sz - i < PGSIZE)
80107b81:	89 fb                	mov    %edi,%ebx
80107b83:	b8 00 10 00 00       	mov    $0x1000,%eax
80107b88:	29 f3                	sub    %esi,%ebx
80107b8a:	39 c3                	cmp    %eax,%ebx
80107b8c:	0f 47 d8             	cmova  %eax,%ebx
    if (readi(ip, P2V(pa), offset + i, n) != n)
80107b8f:	53                   	push   %ebx
80107b90:	8b 45 14             	mov    0x14(%ebp),%eax
80107b93:	01 f0                	add    %esi,%eax
80107b95:	50                   	push   %eax
    pa = PTE_ADDR(*pte);
80107b96:	8b 01                	mov    (%ecx),%eax
80107b98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (readi(ip, P2V(pa), offset + i, n) != n)
80107b9d:	05 00 00 00 80       	add    $0x80000000,%eax
80107ba2:	50                   	push   %eax
80107ba3:	ff 75 10             	push   0x10(%ebp)
80107ba6:	e8 35 a0 ff ff       	call   80101be0 <readi>
80107bab:	83 c4 10             	add    $0x10,%esp
80107bae:	39 d8                	cmp    %ebx,%eax
80107bb0:	75 1e                	jne    80107bd0 <loaduvm+0xb0>
  for (i = 0; i < sz; i += PGSIZE)
80107bb2:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107bb8:	39 fe                	cmp    %edi,%esi
80107bba:	72 84                	jb     80107b40 <loaduvm+0x20>
}
80107bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107bbf:	31 c0                	xor    %eax,%eax
}
80107bc1:	5b                   	pop    %ebx
80107bc2:	5e                   	pop    %esi
80107bc3:	5f                   	pop    %edi
80107bc4:	5d                   	pop    %ebp
80107bc5:	c3                   	ret
80107bc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107bcd:	8d 76 00             	lea    0x0(%esi),%esi
80107bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107bd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107bd8:	5b                   	pop    %ebx
80107bd9:	5e                   	pop    %esi
80107bda:	5f                   	pop    %edi
80107bdb:	5d                   	pop    %ebp
80107bdc:	c3                   	ret
    panic("loaduvm: addr must be page aligned");
80107bdd:	83 ec 0c             	sub    $0xc,%esp
80107be0:	68 4c 8a 10 80       	push   $0x80108a4c
80107be5:	e8 c6 88 ff ff       	call   801004b0 <panic>
80107bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107bf0 <allocuvm>:
{
80107bf0:	55                   	push   %ebp
80107bf1:	89 e5                	mov    %esp,%ebp
80107bf3:	57                   	push   %edi
80107bf4:	56                   	push   %esi
80107bf5:	53                   	push   %ebx
80107bf6:	83 ec 1c             	sub    $0x1c,%esp
  if (newsz >= KERNBASE)
80107bf9:	8b 4d 10             	mov    0x10(%ebp),%ecx
{
80107bfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  if (newsz >= KERNBASE)
80107bff:	85 c9                	test   %ecx,%ecx
80107c01:	0f 88 e5 00 00 00    	js     80107cec <allocuvm+0xfc>
  if (newsz < oldsz)
80107c07:	39 f1                	cmp    %esi,%ecx
80107c09:	0f 82 f1 00 00 00    	jb     80107d00 <allocuvm+0x110>
  a = PGROUNDUP(oldsz);
80107c0f:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80107c15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c1a:	89 c7                	mov    %eax,%edi
  for (; a < newsz; a += PGSIZE)
80107c1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80107c1f:	0f 83 dd 00 00 00    	jae    80107d02 <allocuvm+0x112>
80107c25:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80107c28:	89 75 0c             	mov    %esi,0xc(%ebp)
80107c2b:	e9 88 00 00 00       	jmp    80107cb8 <allocuvm+0xc8>
    memset(mem, 0, PGSIZE);
80107c30:	83 ec 04             	sub    $0x4,%esp
    if (mappages(pgdir, (char *)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0)
80107c33:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
    memset(mem, 0, PGSIZE);
80107c39:	68 00 10 00 00       	push   $0x1000
80107c3e:	6a 00                	push   $0x0
80107c40:	50                   	push   %eax
80107c41:	e8 5a d8 ff ff       	call   801054a0 <memset>
    if (mappages(pgdir, (char *)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0)
80107c46:	58                   	pop    %eax
80107c47:	5a                   	pop    %edx
80107c48:	6a 06                	push   $0x6
80107c4a:	56                   	push   %esi
80107c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c4e:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107c53:	89 fa                	mov    %edi,%edx
80107c55:	e8 86 fb ff ff       	call   801077e0 <mappages>
80107c5a:	83 c4 10             	add    $0x10,%esp
80107c5d:	85 c0                	test   %eax,%eax
80107c5f:	0f 88 ab 00 00 00    	js     80107d10 <allocuvm+0x120>
  if (*pde & PTE_P)
80107c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  pde = &pgdir[PDX(va)];
80107c68:	89 f8                	mov    %edi,%eax
      return 0;
80107c6a:	31 d2                	xor    %edx,%edx
  pde = &pgdir[PDX(va)];
80107c6c:	c1 e8 16             	shr    $0x16,%eax
  if (*pde & PTE_P)
80107c6f:	8b 04 81             	mov    (%ecx,%eax,4),%eax
80107c72:	a8 01                	test   $0x1,%al
80107c74:	74 17                	je     80107c8d <allocuvm+0x9d>
  return &pgtab[PTX(va)];
80107c76:	89 fa                	mov    %edi,%edx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80107c78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107c7d:	c1 ea 0a             	shr    $0xa,%edx
80107c80:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107c86:	8d 94 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%edx
    inc_sharing(pte, V2P(mem) / PGSIZE);
80107c8d:	83 ec 08             	sub    $0x8,%esp
80107c90:	c1 ee 0c             	shr    $0xc,%esi
  for (; a < newsz; a += PGSIZE)
80107c93:	81 c7 00 10 00 00    	add    $0x1000,%edi
    inc_sharing(pte, V2P(mem) / PGSIZE);
80107c99:	56                   	push   %esi
80107c9a:	52                   	push   %edx
80107c9b:	e8 90 be ff ff       	call   80103b30 <inc_sharing>
    myproc()->rss += PGSIZE;
80107ca0:	e8 4b c0 ff ff       	call   80103cf0 <myproc>
  for (; a < newsz; a += PGSIZE)
80107ca5:	83 c4 10             	add    $0x10,%esp
    myproc()->rss += PGSIZE;
80107ca8:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
  for (; a < newsz; a += PGSIZE)
80107caf:	3b 7d 10             	cmp    0x10(%ebp),%edi
80107cb2:	0f 83 90 00 00 00    	jae    80107d48 <allocuvm+0x158>
    mem = kalloc();
80107cb8:	e8 e3 aa ff ff       	call   801027a0 <kalloc>
80107cbd:	89 c3                	mov    %eax,%ebx
    if (mem == 0)
80107cbf:	85 c0                	test   %eax,%eax
80107cc1:	0f 85 69 ff ff ff    	jne    80107c30 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80107cc7:	83 ec 0c             	sub    $0xc,%esp
80107cca:	8b 75 0c             	mov    0xc(%ebp),%esi
80107ccd:	68 50 87 10 80       	push   $0x80108750
80107cd2:	e8 09 8b ff ff       	call   801007e0 <cprintf>
  if (newsz >= oldsz)
80107cd7:	83 c4 10             	add    $0x10,%esp
80107cda:	39 75 10             	cmp    %esi,0x10(%ebp)
80107cdd:	74 0d                	je     80107cec <allocuvm+0xfc>
80107cdf:	8b 55 10             	mov    0x10(%ebp),%edx
80107ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ce5:	89 f1                	mov    %esi,%ecx
80107ce7:	e8 f4 f9 ff ff       	call   801076e0 <deallocuvm.part.0>
    return 0;
80107cec:	31 c9                	xor    %ecx,%ecx
}
80107cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107cf1:	89 c8                	mov    %ecx,%eax
80107cf3:	5b                   	pop    %ebx
80107cf4:	5e                   	pop    %esi
80107cf5:	5f                   	pop    %edi
80107cf6:	5d                   	pop    %ebp
80107cf7:	c3                   	ret
80107cf8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107cff:	90                   	nop
    return oldsz;
80107d00:	89 f1                	mov    %esi,%ecx
}
80107d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107d05:	89 c8                	mov    %ecx,%eax
80107d07:	5b                   	pop    %ebx
80107d08:	5e                   	pop    %esi
80107d09:	5f                   	pop    %edi
80107d0a:	5d                   	pop    %ebp
80107d0b:	c3                   	ret
80107d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("allocuvm out of memory (2)\n");
80107d10:	83 ec 0c             	sub    $0xc,%esp
80107d13:	8b 75 0c             	mov    0xc(%ebp),%esi
80107d16:	68 68 87 10 80       	push   $0x80108768
80107d1b:	e8 c0 8a ff ff       	call   801007e0 <cprintf>
  if (newsz >= oldsz)
80107d20:	83 c4 10             	add    $0x10,%esp
80107d23:	39 75 10             	cmp    %esi,0x10(%ebp)
80107d26:	74 0d                	je     80107d35 <allocuvm+0x145>
80107d28:	8b 55 10             	mov    0x10(%ebp),%edx
80107d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d2e:	89 f1                	mov    %esi,%ecx
80107d30:	e8 ab f9 ff ff       	call   801076e0 <deallocuvm.part.0>
      kfree(mem);
80107d35:	83 ec 0c             	sub    $0xc,%esp
80107d38:	53                   	push   %ebx
80107d39:	e8 92 a8 ff ff       	call   801025d0 <kfree>
      return 0;
80107d3e:	83 c4 10             	add    $0x10,%esp
    return 0;
80107d41:	31 c9                	xor    %ecx,%ecx
80107d43:	eb a9                	jmp    80107cee <allocuvm+0xfe>
80107d45:	8d 76 00             	lea    0x0(%esi),%esi
80107d48:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
}
80107d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107d4e:	5b                   	pop    %ebx
80107d4f:	5e                   	pop    %esi
80107d50:	89 c8                	mov    %ecx,%eax
80107d52:	5f                   	pop    %edi
80107d53:	5d                   	pop    %ebp
80107d54:	c3                   	ret
80107d55:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107d60 <deallocuvm>:
{
80107d60:	55                   	push   %ebp
80107d61:	89 e5                	mov    %esp,%ebp
80107d63:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d66:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107d69:	8b 45 08             	mov    0x8(%ebp),%eax
  if (newsz >= oldsz)
80107d6c:	39 d1                	cmp    %edx,%ecx
80107d6e:	73 10                	jae    80107d80 <deallocuvm+0x20>
}
80107d70:	5d                   	pop    %ebp
80107d71:	e9 6a f9 ff ff       	jmp    801076e0 <deallocuvm.part.0>
80107d76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107d7d:	8d 76 00             	lea    0x0(%esi),%esi
80107d80:	89 d0                	mov    %edx,%eax
80107d82:	5d                   	pop    %ebp
80107d83:	c3                   	ret
80107d84:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107d8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107d8f:	90                   	nop

80107d90 <deallocuvm2>:
{
80107d90:	55                   	push   %ebp
80107d91:	89 e5                	mov    %esp,%ebp
80107d93:	53                   	push   %ebx
80107d94:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d97:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107d9d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  if (newsz >= oldsz)
80107da0:	39 d1                	cmp    %edx,%ecx
80107da2:	73 0c                	jae    80107db0 <deallocuvm2+0x20>
80107da4:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80107da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107daa:	c9                   	leave
80107dab:	e9 40 f8 ff ff       	jmp    801075f0 <deallocuvm2.part.0>
80107db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107db3:	89 d0                	mov    %edx,%eax
80107db5:	c9                   	leave
80107db6:	c3                   	ret
80107db7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107dbe:	66 90                	xchg   %ax,%ax

80107dc0 <freevm>:
// Free a page table and all the physical memory pages
// in the user part.
void freevm(pde_t *pgdir)
{
80107dc0:	55                   	push   %ebp
80107dc1:	89 e5                	mov    %esp,%ebp
80107dc3:	57                   	push   %edi
80107dc4:	56                   	push   %esi
80107dc5:	53                   	push   %ebx
80107dc6:	83 ec 0c             	sub    $0xc,%esp
80107dc9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if (pgdir == 0)
80107dcc:	85 f6                	test   %esi,%esi
80107dce:	74 59                	je     80107e29 <freevm+0x69>
  if (newsz >= oldsz)
80107dd0:	31 c9                	xor    %ecx,%ecx
80107dd2:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107dd7:	89 f0                	mov    %esi,%eax
80107dd9:	89 f3                	mov    %esi,%ebx
80107ddb:	e8 00 f9 ff ff       	call   801076e0 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  // cprintf("In freevm\n");
  deallocuvm(pgdir, KERNBASE, 0);
  for (i = 0; i < NPDENTRIES; i++)
80107de0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107de6:	eb 0f                	jmp    80107df7 <freevm+0x37>
80107de8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107def:	90                   	nop
80107df0:	83 c3 04             	add    $0x4,%ebx
80107df3:	39 fb                	cmp    %edi,%ebx
80107df5:	74 23                	je     80107e1a <freevm+0x5a>
  {
    if (pgdir[i] & PTE_P)
80107df7:	8b 03                	mov    (%ebx),%eax
80107df9:	a8 01                	test   $0x1,%al
80107dfb:	74 f3                	je     80107df0 <freevm+0x30>
    {
      char *v = P2V(PTE_ADDR(pgdir[i]));
80107dfd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107e02:	83 ec 0c             	sub    $0xc,%esp
  for (i = 0; i < NPDENTRIES; i++)
80107e05:	83 c3 04             	add    $0x4,%ebx
      char *v = P2V(PTE_ADDR(pgdir[i]));
80107e08:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80107e0d:	50                   	push   %eax
80107e0e:	e8 bd a7 ff ff       	call   801025d0 <kfree>
80107e13:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NPDENTRIES; i++)
80107e16:	39 fb                	cmp    %edi,%ebx
80107e18:	75 dd                	jne    80107df7 <freevm+0x37>
    }
  }
  kfree((char *)pgdir);
80107e1a:	89 75 08             	mov    %esi,0x8(%ebp)
}
80107e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107e20:	5b                   	pop    %ebx
80107e21:	5e                   	pop    %esi
80107e22:	5f                   	pop    %edi
80107e23:	5d                   	pop    %ebp
  kfree((char *)pgdir);
80107e24:	e9 a7 a7 ff ff       	jmp    801025d0 <kfree>
    panic("freevm: no pgdir");
80107e29:	83 ec 0c             	sub    $0xc,%esp
80107e2c:	68 84 87 10 80       	push   $0x80108784
80107e31:	e8 7a 86 ff ff       	call   801004b0 <panic>
80107e36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107e3d:	8d 76 00             	lea    0x0(%esi),%esi

80107e40 <setupkvm>:
{
80107e40:	55                   	push   %ebp
80107e41:	89 e5                	mov    %esp,%ebp
80107e43:	56                   	push   %esi
80107e44:	53                   	push   %ebx
  if ((pgdir = (pde_t *)kalloc()) == 0)
80107e45:	e8 56 a9 ff ff       	call   801027a0 <kalloc>
80107e4a:	85 c0                	test   %eax,%eax
80107e4c:	74 5e                	je     80107eac <setupkvm+0x6c>
  memset(pgdir, 0, PGSIZE);
80107e4e:	83 ec 04             	sub    $0x4,%esp
80107e51:	89 c6                	mov    %eax,%esi
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e53:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107e58:	68 00 10 00 00       	push   $0x1000
80107e5d:	6a 00                	push   $0x0
80107e5f:	50                   	push   %eax
80107e60:	e8 3b d6 ff ff       	call   801054a0 <memset>
80107e65:	83 c4 10             	add    $0x10,%esp
                 (uint)k->phys_start, k->perm) < 0)
80107e68:	8b 43 04             	mov    0x4(%ebx),%eax
    if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107e6b:	83 ec 08             	sub    $0x8,%esp
80107e6e:	8b 4b 08             	mov    0x8(%ebx),%ecx
80107e71:	8b 13                	mov    (%ebx),%edx
80107e73:	ff 73 0c             	push   0xc(%ebx)
80107e76:	50                   	push   %eax
80107e77:	29 c1                	sub    %eax,%ecx
80107e79:	89 f0                	mov    %esi,%eax
80107e7b:	e8 60 f9 ff ff       	call   801077e0 <mappages>
80107e80:	83 c4 10             	add    $0x10,%esp
80107e83:	85 c0                	test   %eax,%eax
80107e85:	78 19                	js     80107ea0 <setupkvm+0x60>
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e87:	83 c3 10             	add    $0x10,%ebx
80107e8a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107e90:	75 d6                	jne    80107e68 <setupkvm+0x28>
}
80107e92:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107e95:	89 f0                	mov    %esi,%eax
80107e97:	5b                   	pop    %ebx
80107e98:	5e                   	pop    %esi
80107e99:	5d                   	pop    %ebp
80107e9a:	c3                   	ret
80107e9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107e9f:	90                   	nop
      freevm(pgdir);
80107ea0:	83 ec 0c             	sub    $0xc,%esp
80107ea3:	56                   	push   %esi
80107ea4:	e8 17 ff ff ff       	call   80107dc0 <freevm>
      return 0;
80107ea9:	83 c4 10             	add    $0x10,%esp
}
80107eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80107eaf:	31 f6                	xor    %esi,%esi
}
80107eb1:	89 f0                	mov    %esi,%eax
80107eb3:	5b                   	pop    %ebx
80107eb4:	5e                   	pop    %esi
80107eb5:	5d                   	pop    %ebp
80107eb6:	c3                   	ret
80107eb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107ebe:	66 90                	xchg   %ax,%ax

80107ec0 <kvmalloc>:
{
80107ec0:	55                   	push   %ebp
80107ec1:	89 e5                	mov    %esp,%ebp
80107ec3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ec6:	e8 75 ff ff ff       	call   80107e40 <setupkvm>
80107ecb:	a3 a4 39 1c 80       	mov    %eax,0x801c39a4
  lcr3(V2P(kpgdir)); // switch to the kernel page table
80107ed0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ed5:	0f 22 d8             	mov    %eax,%cr3
}
80107ed8:	c9                   	leave
80107ed9:	c3                   	ret
80107eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107ee0 <freevm2>:


void
freevm2(pde_t *pgdir,struct proc * p)
{
80107ee0:	55                   	push   %ebp
80107ee1:	89 e5                	mov    %esp,%ebp
80107ee3:	57                   	push   %edi
80107ee4:	56                   	push   %esi
80107ee5:	53                   	push   %ebx
80107ee6:	83 ec 0c             	sub    $0xc,%esp
80107ee9:	8b 75 08             	mov    0x8(%ebp),%esi
80107eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  uint i;

  if(pgdir == 0)
80107eef:	85 f6                	test   %esi,%esi
80107ef1:	74 5e                	je     80107f51 <freevm2+0x71>
  if (newsz >= oldsz)
80107ef3:	83 ec 0c             	sub    $0xc,%esp
80107ef6:	31 c9                	xor    %ecx,%ecx
80107ef8:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107efd:	89 f3                	mov    %esi,%ebx
80107eff:	50                   	push   %eax
80107f00:	89 f0                	mov    %esi,%eax
80107f02:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107f08:	e8 e3 f6 ff ff       	call   801075f0 <deallocuvm2.part.0>
    panic("freevm2: no pgdir");

  deallocuvm2(pgdir, KERNBASE, 0, p);
  for(i = 0; i < NPDENTRIES; i++){
80107f0d:	83 c4 10             	add    $0x10,%esp
80107f10:	eb 0d                	jmp    80107f1f <freevm2+0x3f>
80107f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107f18:	83 c3 04             	add    $0x4,%ebx
80107f1b:	39 fb                	cmp    %edi,%ebx
80107f1d:	74 23                	je     80107f42 <freevm2+0x62>
    if(pgdir[i] & PTE_P){
80107f1f:	8b 03                	mov    (%ebx),%eax
80107f21:	a8 01                	test   $0x1,%al
80107f23:	74 f3                	je     80107f18 <freevm2+0x38>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107f2a:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f2d:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f30:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80107f35:	50                   	push   %eax
80107f36:	e8 95 a6 ff ff       	call   801025d0 <kfree>
80107f3b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f3e:	39 fb                	cmp    %edi,%ebx
80107f40:	75 dd                	jne    80107f1f <freevm2+0x3f>
    }
  }
  kfree((char*)pgdir);
80107f42:	89 75 08             	mov    %esi,0x8(%ebp)
}
80107f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107f48:	5b                   	pop    %ebx
80107f49:	5e                   	pop    %esi
80107f4a:	5f                   	pop    %edi
80107f4b:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107f4c:	e9 7f a6 ff ff       	jmp    801025d0 <kfree>
    panic("freevm2: no pgdir");
80107f51:	83 ec 0c             	sub    $0xc,%esp
80107f54:	68 95 87 10 80       	push   $0x80108795
80107f59:	e8 52 85 ff ff       	call   801004b0 <panic>
80107f5e:	66 90                	xchg   %ax,%ax

80107f60 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void clearpteu(pde_t *pgdir, char *uva)
{
80107f60:	55                   	push   %ebp
80107f61:	89 e5                	mov    %esp,%ebp
80107f63:	83 ec 08             	sub    $0x8,%esp
80107f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  if (*pde & PTE_P)
80107f69:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107f6c:	89 c1                	mov    %eax,%ecx
80107f6e:	c1 e9 16             	shr    $0x16,%ecx
  if (*pde & PTE_P)
80107f71:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107f74:	f6 c2 01             	test   $0x1,%dl
80107f77:	75 17                	jne    80107f90 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if (pte == 0)
    panic("clearpteu");
80107f79:	83 ec 0c             	sub    $0xc,%esp
80107f7c:	68 a7 87 10 80       	push   $0x801087a7
80107f81:	e8 2a 85 ff ff       	call   801004b0 <panic>
80107f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107f8d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107f90:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80107f93:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107f99:	25 fc 0f 00 00       	and    $0xffc,%eax
80107f9e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if (pte == 0)
80107fa5:	85 c0                	test   %eax,%eax
80107fa7:	74 d0                	je     80107f79 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107fa9:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80107fac:	c9                   	leave
80107fad:	c3                   	ret
80107fae:	66 90                	xchg   %ax,%ax

80107fb0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t *
copyuvm(pde_t *pgdir, uint sz,struct proc* child)
{
80107fb0:	55                   	push   %ebp
80107fb1:	89 e5                	mov    %esp,%ebp
80107fb3:	57                   	push   %edi
80107fb4:	56                   	push   %esi
80107fb5:	53                   	push   %ebx
80107fb6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i,flags;

  if ((d = setupkvm()) == 0)
80107fb9:	e8 82 fe ff ff       	call   80107e40 <setupkvm>
80107fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107fc1:	85 c0                	test   %eax,%eax
80107fc3:	0f 84 a6 00 00 00    	je     8010806f <copyuvm+0xbf>
    return 0;
  for (i = 0; i < sz; i += PGSIZE)
80107fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fcc:	85 c0                	test   %eax,%eax
80107fce:	0f 84 f9 00 00 00    	je     801080cd <copyuvm+0x11d>
80107fd4:	31 ff                	xor    %edi,%edi
80107fd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107fdd:	8d 76 00             	lea    0x0(%esi),%esi
  if (*pde & PTE_P)
80107fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107fe3:	89 f8                	mov    %edi,%eax
80107fe5:	c1 e8 16             	shr    $0x16,%eax
80107fe8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (*pde & PTE_P)
80107feb:	8b 04 82             	mov    (%edx,%eax,4),%eax
80107fee:	a8 01                	test   $0x1,%al
80107ff0:	75 0e                	jne    80108000 <copyuvm+0x50>
  {
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
      panic("copyuvm: pte should exist");
80107ff2:	83 ec 0c             	sub    $0xc,%esp
80107ff5:	68 b1 87 10 80       	push   $0x801087b1
80107ffa:	e8 b1 84 ff ff       	call   801004b0 <panic>
80107fff:	90                   	nop
  return &pgtab[PTX(va)];
80108000:	89 f9                	mov    %edi,%ecx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
80108002:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80108007:	c1 e9 0a             	shr    $0xa,%ecx
8010800a:	89 ca                	mov    %ecx,%edx
8010800c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80108012:	8d b4 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%esi
80108019:	89 55 dc             	mov    %edx,-0x24(%ebp)
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
8010801c:	85 f6                	test   %esi,%esi
8010801e:	74 d2                	je     80107ff2 <copyuvm+0x42>
    if (!(*pte & PTE_P))
80108020:	8b 1e                	mov    (%esi),%ebx
80108022:	f6 c3 01             	test   $0x1,%bl
80108025:	0f 84 b8 00 00 00    	je     801080e3 <copyuvm+0x133>
      panic("copyuvm: page not present");
  
    pa = PTE_ADDR(*pte);
    // cprintf("in copyuvm %d %d %d %d %d %d %d\n",*pgdir, d,i,pte,new_pte,sz,pa/PGSIZE);
    flags = PTE_FLAGS(*pte);
8010802b:	89 d8                	mov    %ebx,%eax
    if(mappages(d, (void*)i, PGSIZE, pa, flags) != 0) {
8010802d:	83 ec 08             	sub    $0x8,%esp
80108030:	b9 00 10 00 00       	mov    $0x1000,%ecx
80108035:	89 fa                	mov    %edi,%edx
    flags = PTE_FLAGS(*pte);
80108037:	25 ff 0f 00 00       	and    $0xfff,%eax
    if(mappages(d, (void*)i, PGSIZE, pa, flags) != 0) {
8010803c:	50                   	push   %eax
    pa = PTE_ADDR(*pte);
8010803d:	89 d8                	mov    %ebx,%eax
8010803f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(mappages(d, (void*)i, PGSIZE, pa, flags) != 0) {
80108044:	50                   	push   %eax
80108045:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108048:	e8 93 f7 ff ff       	call   801077e0 <mappages>
8010804d:	83 c4 10             	add    $0x10,%esp
80108050:	85 c0                	test   %eax,%eax
80108052:	75 0d                	jne    80108061 <copyuvm+0xb1>
  if (*pde & PTE_P)
80108054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108057:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010805a:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010805d:	a8 01                	test   $0x1,%al
8010805f:	75 27                	jne    80108088 <copyuvm+0xd8>
  }
  lcr3(V2P(pgdir));
  return d;

bad:
  freevm(d);
80108061:	83 ec 0c             	sub    $0xc,%esp
80108064:	ff 75 e4             	push   -0x1c(%ebp)
80108067:	e8 54 fd ff ff       	call   80107dc0 <freevm>
  return 0;
8010806c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010806f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80108076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108079:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010807c:	5b                   	pop    %ebx
8010807d:	5e                   	pop    %esi
8010807e:	5f                   	pop    %edi
8010807f:	5d                   	pop    %ebp
80108080:	c3                   	ret
80108081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
80108088:	8b 55 dc             	mov    -0x24(%ebp),%edx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
8010808b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80108090:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if (new_pte == 0)
80108097:	85 c0                	test   %eax,%eax
80108099:	74 c6                	je     80108061 <copyuvm+0xb1>
    *pte &= ~PTE_W;
8010809b:	8b 0e                	mov    (%esi),%ecx
    inc_sharing(new_pte, pa / PGSIZE);
8010809d:	83 ec 08             	sub    $0x8,%esp
801080a0:	c1 eb 0c             	shr    $0xc,%ebx
  for (i = 0; i < sz; i += PGSIZE)
801080a3:	81 c7 00 10 00 00    	add    $0x1000,%edi
    *pte &= ~PTE_W;
801080a9:	83 e1 fd             	and    $0xfffffffd,%ecx
801080ac:	89 0e                	mov    %ecx,(%esi)
    *new_pte = *pte;
801080ae:	89 08                	mov    %ecx,(%eax)
    inc_sharing(new_pte, pa / PGSIZE);
801080b0:	53                   	push   %ebx
801080b1:	50                   	push   %eax
801080b2:	e8 79 ba ff ff       	call   80103b30 <inc_sharing>
    child->rss += PGSIZE;
801080b7:	8b 45 10             	mov    0x10(%ebp),%eax
  for (i = 0; i < sz; i += PGSIZE)
801080ba:	83 c4 10             	add    $0x10,%esp
    child->rss += PGSIZE;
801080bd:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
  for (i = 0; i < sz; i += PGSIZE)
801080c4:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801080c7:	0f 82 13 ff ff ff    	jb     80107fe0 <copyuvm+0x30>
  lcr3(V2P(pgdir));
801080cd:	8b 45 08             	mov    0x8(%ebp),%eax
801080d0:	05 00 00 00 80       	add    $0x80000000,%eax
801080d5:	0f 22 d8             	mov    %eax,%cr3
}
801080d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801080de:	5b                   	pop    %ebx
801080df:	5e                   	pop    %esi
801080e0:	5f                   	pop    %edi
801080e1:	5d                   	pop    %ebp
801080e2:	c3                   	ret
      panic("copyuvm: page not present");
801080e3:	83 ec 0c             	sub    $0xc,%esp
801080e6:	68 cb 87 10 80       	push   $0x801087cb
801080eb:	e8 c0 83 ff ff       	call   801004b0 <panic>

801080f0 <uva2ka>:

// PAGEBREAK!
//  Map user virtual address to kernel address.
char *
uva2ka(pde_t *pgdir, char *uva)
{
801080f0:	55                   	push   %ebp
801080f1:	89 e5                	mov    %esp,%ebp
801080f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  if (*pde & PTE_P)
801080f6:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
801080f9:	89 c1                	mov    %eax,%ecx
801080fb:	c1 e9 16             	shr    $0x16,%ecx
  if (*pde & PTE_P)
801080fe:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80108101:	f6 c2 01             	test   $0x1,%dl
80108104:	0f 84 f8 00 00 00    	je     80108202 <uva2ka.cold>
  return &pgtab[PTX(va)];
8010810a:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
8010810d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if ((*pte & PTE_P) == 0)
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  return (char *)P2V(PTE_ADDR(*pte));
}
80108113:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
80108114:	25 ff 03 00 00       	and    $0x3ff,%eax
  if ((*pte & PTE_P) == 0)
80108119:	8b 94 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%edx
  return (char *)P2V(PTE_ADDR(*pte));
80108120:	89 d0                	mov    %edx,%eax
80108122:	f7 d2                	not    %edx
80108124:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108129:	05 00 00 00 80       	add    $0x80000000,%eax
8010812e:	83 e2 05             	and    $0x5,%edx
80108131:	ba 00 00 00 00       	mov    $0x0,%edx
80108136:	0f 45 c2             	cmovne %edx,%eax
}
80108139:	c3                   	ret
8010813a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80108140 <copyout>:

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108140:	55                   	push   %ebp
80108141:	89 e5                	mov    %esp,%ebp
80108143:	57                   	push   %edi
80108144:	56                   	push   %esi
80108145:	53                   	push   %ebx
80108146:	83 ec 0c             	sub    $0xc,%esp
80108149:	8b 75 14             	mov    0x14(%ebp),%esi
8010814c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010814f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char *)p;
  while (len > 0)
80108152:	85 f6                	test   %esi,%esi
80108154:	75 51                	jne    801081a7 <copyout+0x67>
80108156:	e9 9d 00 00 00       	jmp    801081f8 <copyout+0xb8>
8010815b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010815f:	90                   	nop
  return (char *)P2V(PTE_ADDR(*pte));
80108160:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80108166:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
  {
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char *)va0);
    if (pa0 == 0)
8010816c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80108172:	74 74                	je     801081e8 <copyout+0xa8>
      return -1;
    n = PGSIZE - (va - va0);
80108174:	89 fb                	mov    %edi,%ebx
80108176:	29 c3                	sub    %eax,%ebx
80108178:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if (n > len)
8010817e:	39 f3                	cmp    %esi,%ebx
80108180:	0f 47 de             	cmova  %esi,%ebx
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80108183:	29 f8                	sub    %edi,%eax
80108185:	83 ec 04             	sub    $0x4,%esp
80108188:	01 c1                	add    %eax,%ecx
8010818a:	53                   	push   %ebx
8010818b:	52                   	push   %edx
8010818c:	89 55 10             	mov    %edx,0x10(%ebp)
8010818f:	51                   	push   %ecx
80108190:	e8 9b d3 ff ff       	call   80105530 <memmove>
    len -= n;
    buf += n;
80108195:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
80108198:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while (len > 0)
8010819e:	83 c4 10             	add    $0x10,%esp
    buf += n;
801081a1:	01 da                	add    %ebx,%edx
  while (len > 0)
801081a3:	29 de                	sub    %ebx,%esi
801081a5:	74 51                	je     801081f8 <copyout+0xb8>
  if (*pde & PTE_P)
801081a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
801081aa:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
801081ac:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
801081ae:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
801081b1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if (*pde & PTE_P)
801081b7:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
801081ba:	f6 c1 01             	test   $0x1,%cl
801081bd:	0f 84 46 00 00 00    	je     80108209 <copyout.cold>
  return &pgtab[PTX(va)];
801081c3:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
801081c5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
801081cb:	c1 eb 0c             	shr    $0xc,%ebx
801081ce:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if ((*pte & PTE_P) == 0)
801081d4:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if ((*pte & PTE_U) == 0)
801081db:	89 d9                	mov    %ebx,%ecx
801081dd:	f7 d1                	not    %ecx
801081df:	83 e1 05             	and    $0x5,%ecx
801081e2:	0f 84 78 ff ff ff    	je     80108160 <copyout+0x20>
  }
  return 0;
}
801081e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801081eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801081f0:	5b                   	pop    %ebx
801081f1:	5e                   	pop    %esi
801081f2:	5f                   	pop    %edi
801081f3:	5d                   	pop    %ebp
801081f4:	c3                   	ret
801081f5:	8d 76 00             	lea    0x0(%esi),%esi
801081f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801081fb:	31 c0                	xor    %eax,%eax
}
801081fd:	5b                   	pop    %ebx
801081fe:	5e                   	pop    %esi
801081ff:	5f                   	pop    %edi
80108200:	5d                   	pop    %ebp
80108201:	c3                   	ret

80108202 <uva2ka.cold>:
  if ((*pte & PTE_P) == 0)
80108202:	a1 00 00 00 00       	mov    0x0,%eax
80108207:	0f 0b                	ud2

80108209 <copyout.cold>:
80108209:	a1 00 00 00 00       	mov    0x0,%eax
8010820e:	0f 0b                	ud2
