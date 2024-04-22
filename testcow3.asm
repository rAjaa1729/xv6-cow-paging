
_testcow3:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
	exit();
}

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 0c             	sub    $0xc,%esp
	printf(1, "Test starting...\n");
  11:	68 44 0a 00 00       	push   $0xa44
  16:	6a 01                	push   $0x1
  18:	e8 93 06 00 00       	call   6b0 <printf>
	test();
  1d:	e8 3e 00 00 00       	call   60 <test>
  22:	66 90                	xchg   %ax,%ax
  24:	66 90                	xchg   %ax,%ax
  26:	66 90                	xchg   %ax,%ax
  28:	66 90                	xchg   %ax,%ax
  2a:	66 90                	xchg   %ax,%ax
  2c:	66 90                	xchg   %ax,%ax
  2e:	66 90                	xchg   %ax,%ax

00000030 <processing>:
processing(int *x) {
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	83 ec 0c             	sub    $0xc,%esp
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	c7 00 ae ad 01 00    	movl   $0x1adae,(%eax)
    printf(1, "done processing %d\n", x);
  3f:	50                   	push   %eax
  40:	68 b8 09 00 00       	push   $0x9b8
  45:	6a 01                	push   $0x1
  47:	e8 64 06 00 00       	call   6b0 <printf>
}
  4c:	83 c4 10             	add    $0x10,%esp
  4f:	c9                   	leave
  50:	c3                   	ret
  51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  5f:	90                   	nop

00000060 <test>:
{
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  63:	57                   	push   %edi
  64:	56                   	push   %esi
  65:	53                   	push   %ebx
  66:	83 ec 2c             	sub    $0x2c,%esp
    uint prev_free_pages = getNumFreePages();
  69:	e8 8d 05 00 00       	call   5fb <getNumFreePages>
    char *m1 = (char*)malloc(size);
  6e:	83 ec 0c             	sub    $0xc,%esp
    long long size = ((prev_free_pages - 20) * 4 * 1024) / 2; // 20 pages will be used by kernel to create kstack, and process related datastructures.
  71:	8d 70 ec             	lea    -0x14(%eax),%esi
  74:	c1 e6 0c             	shl    $0xc,%esi
  77:	d1 ee                	shr    %esi
    char *m1 = (char*)malloc(size);
  79:	56                   	push   %esi
  7a:	e8 51 08 00 00       	call   8d0 <malloc>
    if (m1 == 0) goto out_of_memory;
  7f:	83 c4 10             	add    $0x10,%esp
    char *m1 = (char*)malloc(size);
  82:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if (m1 == 0) goto out_of_memory;
  85:	85 c0                	test   %eax,%eax
  87:	0f 84 00 02 00 00    	je     28d <test+0x22d>
    printf(1, "\n*** Forking ***\n");
  8d:	83 ec 08             	sub    $0x8,%esp
  90:	68 f6 09 00 00       	push   $0x9f6
  95:	6a 01                	push   $0x1
  97:	e8 14 06 00 00       	call   6b0 <printf>
    pid = fork();
  9c:	e8 aa 04 00 00       	call   54b <fork>
    if (pid < 0) goto fork_failed; // Fork failed
  a1:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  a4:	89 c3                	mov    %eax,%ebx
    if (pid < 0) goto fork_failed; // Fork failed
  a6:	85 c0                	test   %eax,%eax
  a8:	0f 88 eb 01 00 00    	js     299 <test+0x239>
    long long size = ((prev_free_pages - 20) * 4 * 1024) / 2; // 20 pages will be used by kernel to create kstack, and process related datastructures.
  ae:	89 75 d0             	mov    %esi,-0x30(%ebp)
  b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    if (pid == 0) { // Child process
  b8:	75 53                	jne    10d <test+0xad>
        printf(1, "\n*** Child ***\n");
  ba:	52                   	push   %edx
  bb:	52                   	push   %edx
  bc:	68 23 0a 00 00       	push   $0xa23
  c1:	6a 01                	push   $0x1
  c3:	e8 e8 05 00 00       	call   6b0 <printf>
        prev_free_pages = getNumFreePages();
  c8:	e8 2e 05 00 00       	call   5fb <getNumFreePages>
        for (int i=0; i<size; i++) {
  cd:	83 c4 10             	add    $0x10,%esp
        prev_free_pages = getNumFreePages();
  d0:	89 c7                	mov    %eax,%edi
        for (int i=0; i<size; i++) {
  d2:	85 f6                	test   %esi,%esi
  d4:	75 7d                	jne    153 <test+0xf3>
        curr_free_pages = getNumFreePages();
  d6:	e8 20 05 00 00       	call   5fb <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
  db:	39 f8                	cmp    %edi,%eax
  dd:	0f 83 d8 01 00 00    	jae    2bb <test+0x25b>
        processing(&x);
  e3:	83 ec 0c             	sub    $0xc,%esp
  e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
        int x = 0;
  e9:	31 d2                	xor    %edx,%edx
        processing(&x);
  eb:	50                   	push   %eax
        int x = 0;
  ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        processing(&x);
  ef:	e8 3c ff ff ff       	call   30 <processing>
  f4:	83 c4 10             	add    $0x10,%esp
        printf(1, "[COW3] Lab5 Child test passed!\n");
  f7:	50                   	push   %eax
  f8:	50                   	push   %eax
  f9:	68 94 0a 00 00       	push   $0xa94
  fe:	6a 01                	push   $0x1
 100:	e8 ab 05 00 00       	call   6b0 <printf>
 105:	83 c4 10             	add    $0x10,%esp
    exit();
 108:	e8 46 04 00 00       	call   553 <exit>
        printf(1, "\n*** Parent ***\n");
 10d:	50                   	push   %eax
 10e:	50                   	push   %eax
 10f:	68 33 0a 00 00       	push   $0xa33
 114:	6a 01                	push   $0x1
 116:	e8 95 05 00 00       	call   6b0 <printf>
        prev_free_pages = getNumFreePages();
 11b:	e8 db 04 00 00       	call   5fb <getNumFreePages>
        for (int i=0; i<size; i++) {
 120:	83 c4 10             	add    $0x10,%esp
        prev_free_pages = getNumFreePages();
 123:	89 c7                	mov    %eax,%edi
        for (int i=0; i<size; i++) {
 125:	85 f6                	test   %esi,%esi
 127:	0f 85 d2 00 00 00    	jne    1ff <test+0x19f>
        curr_free_pages = getNumFreePages();
 12d:	e8 c9 04 00 00       	call   5fb <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
 132:	39 f8                	cmp    %edi,%eax
 134:	0f 83 6b 01 00 00    	jae    2a5 <test+0x245>
        processing(&x);
 13a:	83 ec 0c             	sub    $0xc,%esp
 13d:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
        int x = 0;
 140:	31 c0                	xor    %eax,%eax
        processing(&x);
 142:	53                   	push   %ebx
        int x = 0;
 143:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        processing(&x);
 146:	e8 e5 fe ff ff       	call   30 <processing>
 14b:	83 c4 10             	add    $0x10,%esp
 14e:	e9 81 01 00 00       	jmp    2d4 <test+0x274>
            m1[i] = (char)(65+(i%26));
 153:	89 45 c8             	mov    %eax,-0x38(%ebp)
 156:	8b 7d cc             	mov    -0x34(%ebp),%edi
 159:	b9 4f ec c4 4e       	mov    $0x4ec4ec4f,%ecx
 15e:	66 90                	xchg   %ax,%ax
 160:	89 d8                	mov    %ebx,%eax
 162:	f7 e1                	mul    %ecx
 164:	89 d8                	mov    %ebx,%eax
 166:	c1 ea 03             	shr    $0x3,%edx
 169:	6b d2 1a             	imul   $0x1a,%edx,%edx
 16c:	29 d0                	sub    %edx,%eax
 16e:	83 c0 41             	add    $0x41,%eax
 171:	88 04 1f             	mov    %al,(%edi,%ebx,1)
        for (int i=0; i<size; i++) {
 174:	83 c3 01             	add    $0x1,%ebx
 177:	39 f3                	cmp    %esi,%ebx
 179:	75 e5                	jne    160 <test+0x100>
        curr_free_pages = getNumFreePages();
 17b:	8b 7d c8             	mov    -0x38(%ebp),%edi
 17e:	e8 78 04 00 00       	call   5fb <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
 183:	39 f8                	cmp    %edi,%eax
 185:	0f 83 30 01 00 00    	jae    2bb <test+0x25b>
        int x = 0;
 18b:	31 c0                	xor    %eax,%eax
        processing(&x);
 18d:	83 ec 0c             	sub    $0xc,%esp
 190:	31 db                	xor    %ebx,%ebx
        int x = 0;
 192:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        processing(&x);
 195:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 198:	50                   	push   %eax
 199:	e8 92 fe ff ff       	call   30 <processing>
        for(int k=0;k<size;++k){
 19e:	83 c4 10             	add    $0x10,%esp
        processing(&x);
 1a1:	31 c9                	xor    %ecx,%ecx
 1a3:	eb 1d                	jmp    1c2 <test+0x162>
 1a5:	8d 76 00             	lea    0x0(%esi),%esi
        for(int k=0;k<size;++k){
 1a8:	83 c1 01             	add    $0x1,%ecx
 1ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
 1ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 1b1:	83 d3 00             	adc    $0x0,%ebx
 1b4:	89 da                	mov    %ebx,%edx
 1b6:	31 c8                	xor    %ecx,%eax
 1b8:	31 fa                	xor    %edi,%edx
 1ba:	09 d0                	or     %edx,%eax
 1bc:	0f 84 35 ff ff ff    	je     f7 <test+0x97>
			if(m1[k] != (char)(65+(k%26))) goto failed;
 1c2:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
 1c7:	8b 75 cc             	mov    -0x34(%ebp),%esi
 1ca:	f7 e1                	mul    %ecx
 1cc:	89 c8                	mov    %ecx,%eax
 1ce:	c1 ea 03             	shr    $0x3,%edx
 1d1:	6b d2 1a             	imul   $0x1a,%edx,%edx
 1d4:	29 d0                	sub    %edx,%eax
 1d6:	83 c0 41             	add    $0x41,%eax
 1d9:	38 04 0e             	cmp    %al,(%esi,%ecx,1)
 1dc:	74 ca                	je     1a8 <test+0x148>
    printf(1, "Copy failed: The memory contents of the processes is inconsistent!\n");
 1de:	51                   	push   %ecx
 1df:	51                   	push   %ecx
 1e0:	68 10 0b 00 00       	push   $0xb10
	printf(1, "Failed to fork a process!\n");
 1e5:	6a 01                	push   $0x1
 1e7:	e8 c4 04 00 00       	call   6b0 <printf>
    printf(1, "Lab5 test failed!\n");
 1ec:	59                   	pop    %ecx
 1ed:	5b                   	pop    %ebx
 1ee:	68 e3 09 00 00       	push   $0x9e3
 1f3:	6a 01                	push   $0x1
 1f5:	e8 b6 04 00 00       	call   6b0 <printf>
	exit();
 1fa:	e8 54 03 00 00       	call   553 <exit>
            m1[i] = (char)(97+(i%26));
 1ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
 202:	8b 7d cc             	mov    -0x34(%ebp),%edi
        for (int i=0; i<size; i++) {
 205:	31 c9                	xor    %ecx,%ecx
            m1[i] = (char)(97+(i%26));
 207:	bb 4f ec c4 4e       	mov    $0x4ec4ec4f,%ebx
 20c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 210:	89 c8                	mov    %ecx,%eax
 212:	f7 e3                	mul    %ebx
 214:	89 c8                	mov    %ecx,%eax
 216:	c1 ea 03             	shr    $0x3,%edx
 219:	6b d2 1a             	imul   $0x1a,%edx,%edx
 21c:	29 d0                	sub    %edx,%eax
 21e:	83 c0 61             	add    $0x61,%eax
 221:	88 04 0f             	mov    %al,(%edi,%ecx,1)
        for (int i=0; i<size; i++) {
 224:	83 c1 01             	add    $0x1,%ecx
 227:	39 f1                	cmp    %esi,%ecx
 229:	75 e5                	jne    210 <test+0x1b0>
        curr_free_pages = getNumFreePages();
 22b:	8b 7d c8             	mov    -0x38(%ebp),%edi
 22e:	e8 c8 03 00 00       	call   5fb <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
 233:	39 f8                	cmp    %edi,%eax
 235:	73 6e                	jae    2a5 <test+0x245>
        processing(&x);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
        int x = 0;
 23d:	31 ff                	xor    %edi,%edi
        processing(&x);
 23f:	31 f6                	xor    %esi,%esi
 241:	53                   	push   %ebx
        int x = 0;
 242:	89 7d e4             	mov    %edi,-0x1c(%ebp)
        processing(&x);
 245:	31 ff                	xor    %edi,%edi
 247:	e8 e4 fd ff ff       	call   30 <processing>
			if(m1[k] != (char)(97+(k%26))) goto failed;
 24c:	89 5d c8             	mov    %ebx,-0x38(%ebp)
 24f:	83 c4 10             	add    $0x10,%esp
 252:	eb 18                	jmp    26c <test+0x20c>
 254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        for(int k=0;k<size;++k){
 258:	83 c6 01             	add    $0x1,%esi
 25b:	8b 45 d0             	mov    -0x30(%ebp),%eax
 25e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 261:	83 d7 00             	adc    $0x0,%edi
 264:	31 fa                	xor    %edi,%edx
 266:	31 f0                	xor    %esi,%eax
 268:	09 d0                	or     %edx,%eax
 26a:	74 65                	je     2d1 <test+0x271>
			if(m1[k] != (char)(97+(k%26))) goto failed;
 26c:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
 271:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 274:	f7 e6                	mul    %esi
 276:	89 f0                	mov    %esi,%eax
 278:	c1 ea 03             	shr    $0x3,%edx
 27b:	6b d2 1a             	imul   $0x1a,%edx,%edx
 27e:	29 d0                	sub    %edx,%eax
 280:	83 c0 61             	add    $0x61,%eax
 283:	38 04 31             	cmp    %al,(%ecx,%esi,1)
 286:	74 d0                	je     258 <test+0x1f8>
 288:	e9 51 ff ff ff       	jmp    1de <test+0x17e>
	printf(1, "Exceeded the PHYSTOP!\n");
 28d:	57                   	push   %edi
 28e:	57                   	push   %edi
 28f:	68 cc 09 00 00       	push   $0x9cc
 294:	e9 4c ff ff ff       	jmp    1e5 <test+0x185>
	printf(1, "Failed to fork a process!\n");
 299:	56                   	push   %esi
 29a:	56                   	push   %esi
 29b:	68 08 0a 00 00       	push   $0xa08
 2a0:	e9 40 ff ff ff       	jmp    1e5 <test+0x185>
            printf(1, "Lab5 Parent: Free pages should decrease after write\n");
 2a5:	50                   	push   %eax
 2a6:	50                   	push   %eax
 2a7:	68 b4 0a 00 00       	push   $0xab4
 2ac:	6a 01                	push   $0x1
 2ae:	e8 fd 03 00 00       	call   6b0 <printf>
            goto failed;
 2b3:	83 c4 10             	add    $0x10,%esp
 2b6:	e9 23 ff ff ff       	jmp    1de <test+0x17e>
            printf(1, "Lab5 Child: Free pages should decrease after write\n");
 2bb:	50                   	push   %eax
 2bc:	50                   	push   %eax
 2bd:	68 60 0a 00 00       	push   $0xa60
 2c2:	6a 01                	push   $0x1
 2c4:	e8 e7 03 00 00       	call   6b0 <printf>
            goto failed;
 2c9:	83 c4 10             	add    $0x10,%esp
 2cc:	e9 0d ff ff ff       	jmp    1de <test+0x17e>
 2d1:	8b 5d c8             	mov    -0x38(%ebp),%ebx
        wait();
 2d4:	e8 82 02 00 00       	call   55b <wait>
        processing(&x);
 2d9:	83 ec 0c             	sub    $0xc,%esp
 2dc:	53                   	push   %ebx
 2dd:	e8 4e fd ff ff       	call   30 <processing>
        printf(1, "done processing %d\n", x);
 2e2:	83 c4 0c             	add    $0xc,%esp
 2e5:	ff 75 e4             	push   -0x1c(%ebp)
 2e8:	68 b8 09 00 00       	push   $0x9b8
 2ed:	6a 01                	push   $0x1
 2ef:	e8 bc 03 00 00       	call   6b0 <printf>
        printf(1, "[COW3] Lab5 Parent test passed!\n");
 2f4:	5b                   	pop    %ebx
 2f5:	5e                   	pop    %esi
 2f6:	68 ec 0a 00 00       	push   $0xaec
 2fb:	6a 01                	push   $0x1
 2fd:	e8 ae 03 00 00       	call   6b0 <printf>
 302:	83 c4 10             	add    $0x10,%esp
 305:	e9 fe fd ff ff       	jmp    108 <test+0xa8>
 30a:	66 90                	xchg   %ax,%ax
 30c:	66 90                	xchg   %ax,%ax
 30e:	66 90                	xchg   %ax,%ax

00000310 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 310:	55                   	push   %ebp
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 311:	31 c0                	xor    %eax,%eax
{
 313:	89 e5                	mov    %esp,%ebp
 315:	53                   	push   %ebx
 316:	8b 4d 08             	mov    0x8(%ebp),%ecx
 319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 31c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while((*s++ = *t++) != 0)
 320:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
 324:	88 14 01             	mov    %dl,(%ecx,%eax,1)
 327:	83 c0 01             	add    $0x1,%eax
 32a:	84 d2                	test   %dl,%dl
 32c:	75 f2                	jne    320 <strcpy+0x10>
    ;
  return os;
}
 32e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 331:	89 c8                	mov    %ecx,%eax
 333:	c9                   	leave
 334:	c3                   	ret
 335:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 33c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000340 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	53                   	push   %ebx
 344:	8b 55 08             	mov    0x8(%ebp),%edx
 347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 34a:	0f b6 02             	movzbl (%edx),%eax
 34d:	84 c0                	test   %al,%al
 34f:	75 17                	jne    368 <strcmp+0x28>
 351:	eb 3a                	jmp    38d <strcmp+0x4d>
 353:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 357:	90                   	nop
 358:	0f b6 42 01          	movzbl 0x1(%edx),%eax
    p++, q++;
 35c:	83 c2 01             	add    $0x1,%edx
 35f:	8d 59 01             	lea    0x1(%ecx),%ebx
  while(*p && *p == *q)
 362:	84 c0                	test   %al,%al
 364:	74 1a                	je     380 <strcmp+0x40>
 366:	89 d9                	mov    %ebx,%ecx
 368:	0f b6 19             	movzbl (%ecx),%ebx
 36b:	38 c3                	cmp    %al,%bl
 36d:	74 e9                	je     358 <strcmp+0x18>
  return (uchar)*p - (uchar)*q;
 36f:	29 d8                	sub    %ebx,%eax
}
 371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 374:	c9                   	leave
 375:	c3                   	ret
 376:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 37d:	8d 76 00             	lea    0x0(%esi),%esi
  return (uchar)*p - (uchar)*q;
 380:	0f b6 59 01          	movzbl 0x1(%ecx),%ebx
 384:	31 c0                	xor    %eax,%eax
 386:	29 d8                	sub    %ebx,%eax
}
 388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 38b:	c9                   	leave
 38c:	c3                   	ret
  return (uchar)*p - (uchar)*q;
 38d:	0f b6 19             	movzbl (%ecx),%ebx
 390:	31 c0                	xor    %eax,%eax
 392:	eb db                	jmp    36f <strcmp+0x2f>
 394:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 39b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 39f:	90                   	nop

000003a0 <strlen>:

uint
strlen(const char *s)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
 3a6:	80 3a 00             	cmpb   $0x0,(%edx)
 3a9:	74 15                	je     3c0 <strlen+0x20>
 3ab:	31 c0                	xor    %eax,%eax
 3ad:	8d 76 00             	lea    0x0(%esi),%esi
 3b0:	83 c0 01             	add    $0x1,%eax
 3b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
 3b7:	89 c1                	mov    %eax,%ecx
 3b9:	75 f5                	jne    3b0 <strlen+0x10>
    ;
  return n;
}
 3bb:	89 c8                	mov    %ecx,%eax
 3bd:	5d                   	pop    %ebp
 3be:	c3                   	ret
 3bf:	90                   	nop
  for(n = 0; s[n]; n++)
 3c0:	31 c9                	xor    %ecx,%ecx
}
 3c2:	5d                   	pop    %ebp
 3c3:	89 c8                	mov    %ecx,%eax
 3c5:	c3                   	ret
 3c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 3cd:	8d 76 00             	lea    0x0(%esi),%esi

000003d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	57                   	push   %edi
 3d4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 3d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	89 d7                	mov    %edx,%edi
 3df:	fc                   	cld
 3e0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3e2:	8b 7d fc             	mov    -0x4(%ebp),%edi
 3e5:	89 d0                	mov    %edx,%eax
 3e7:	c9                   	leave
 3e8:	c3                   	ret
 3e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000003f0 <strchr>:

char*
strchr(const char *s, char c)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 3fa:	0f b6 10             	movzbl (%eax),%edx
 3fd:	84 d2                	test   %dl,%dl
 3ff:	75 12                	jne    413 <strchr+0x23>
 401:	eb 1d                	jmp    420 <strchr+0x30>
 403:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 407:	90                   	nop
 408:	0f b6 50 01          	movzbl 0x1(%eax),%edx
 40c:	83 c0 01             	add    $0x1,%eax
 40f:	84 d2                	test   %dl,%dl
 411:	74 0d                	je     420 <strchr+0x30>
    if(*s == c)
 413:	38 d1                	cmp    %dl,%cl
 415:	75 f1                	jne    408 <strchr+0x18>
      return (char*)s;
  return 0;
}
 417:	5d                   	pop    %ebp
 418:	c3                   	ret
 419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return 0;
 420:	31 c0                	xor    %eax,%eax
}
 422:	5d                   	pop    %ebp
 423:	c3                   	ret
 424:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 42b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 42f:	90                   	nop

00000430 <gets>:

char*
gets(char *buf, int max)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	57                   	push   %edi
 434:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
 435:	8d 75 e7             	lea    -0x19(%ebp),%esi
{
 438:	53                   	push   %ebx
  for(i=0; i+1 < max; ){
 439:	31 db                	xor    %ebx,%ebx
{
 43b:	83 ec 1c             	sub    $0x1c,%esp
  for(i=0; i+1 < max; ){
 43e:	eb 27                	jmp    467 <gets+0x37>
    cc = read(0, &c, 1);
 440:	83 ec 04             	sub    $0x4,%esp
 443:	6a 01                	push   $0x1
 445:	56                   	push   %esi
 446:	6a 00                	push   $0x0
 448:	e8 1e 01 00 00       	call   56b <read>
    if(cc < 1)
 44d:	83 c4 10             	add    $0x10,%esp
 450:	85 c0                	test   %eax,%eax
 452:	7e 1d                	jle    471 <gets+0x41>
      break;
    buf[i++] = c;
 454:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 458:	8b 55 08             	mov    0x8(%ebp),%edx
 45b:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
    if(c == '\n' || c == '\r')
 45f:	3c 0a                	cmp    $0xa,%al
 461:	74 10                	je     473 <gets+0x43>
 463:	3c 0d                	cmp    $0xd,%al
 465:	74 0c                	je     473 <gets+0x43>
  for(i=0; i+1 < max; ){
 467:	89 df                	mov    %ebx,%edi
 469:	83 c3 01             	add    $0x1,%ebx
 46c:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 46f:	7c cf                	jl     440 <gets+0x10>
 471:	89 fb                	mov    %edi,%ebx
      break;
  }
  buf[i] = '\0';
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 47a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 47d:	5b                   	pop    %ebx
 47e:	5e                   	pop    %esi
 47f:	5f                   	pop    %edi
 480:	5d                   	pop    %ebp
 481:	c3                   	ret
 482:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000490 <stat>:

int
stat(const char *n, struct stat *st)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	56                   	push   %esi
 494:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 495:	83 ec 08             	sub    $0x8,%esp
 498:	6a 00                	push   $0x0
 49a:	ff 75 08             	push   0x8(%ebp)
 49d:	e8 f1 00 00 00       	call   593 <open>
  if(fd < 0)
 4a2:	83 c4 10             	add    $0x10,%esp
 4a5:	85 c0                	test   %eax,%eax
 4a7:	78 27                	js     4d0 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 4a9:	83 ec 08             	sub    $0x8,%esp
 4ac:	ff 75 0c             	push   0xc(%ebp)
 4af:	89 c3                	mov    %eax,%ebx
 4b1:	50                   	push   %eax
 4b2:	e8 f4 00 00 00       	call   5ab <fstat>
  close(fd);
 4b7:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 4ba:	89 c6                	mov    %eax,%esi
  close(fd);
 4bc:	e8 ba 00 00 00       	call   57b <close>
  return r;
 4c1:	83 c4 10             	add    $0x10,%esp
}
 4c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
 4c7:	89 f0                	mov    %esi,%eax
 4c9:	5b                   	pop    %ebx
 4ca:	5e                   	pop    %esi
 4cb:	5d                   	pop    %ebp
 4cc:	c3                   	ret
 4cd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 4d0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 4d5:	eb ed                	jmp    4c4 <stat+0x34>
 4d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 4de:	66 90                	xchg   %ax,%ax

000004e0 <atoi>:

int
atoi(const char *s)
{
 4e0:	55                   	push   %ebp
 4e1:	89 e5                	mov    %esp,%ebp
 4e3:	53                   	push   %ebx
 4e4:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4e7:	0f be 02             	movsbl (%edx),%eax
 4ea:	8d 48 d0             	lea    -0x30(%eax),%ecx
 4ed:	80 f9 09             	cmp    $0x9,%cl
  n = 0;
 4f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  while('0' <= *s && *s <= '9')
 4f5:	77 1e                	ja     515 <atoi+0x35>
 4f7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 4fe:	66 90                	xchg   %ax,%ax
    n = n*10 + *s++ - '0';
 500:	83 c2 01             	add    $0x1,%edx
 503:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
 506:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
  while('0' <= *s && *s <= '9')
 50a:	0f be 02             	movsbl (%edx),%eax
 50d:	8d 58 d0             	lea    -0x30(%eax),%ebx
 510:	80 fb 09             	cmp    $0x9,%bl
 513:	76 eb                	jbe    500 <atoi+0x20>
  return n;
}
 515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 518:	89 c8                	mov    %ecx,%eax
 51a:	c9                   	leave
 51b:	c3                   	ret
 51c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000520 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	57                   	push   %edi
 524:	8b 45 10             	mov    0x10(%ebp),%eax
 527:	8b 55 08             	mov    0x8(%ebp),%edx
 52a:	56                   	push   %esi
 52b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 52e:	85 c0                	test   %eax,%eax
 530:	7e 13                	jle    545 <memmove+0x25>
 532:	01 d0                	add    %edx,%eax
  dst = vdst;
 534:	89 d7                	mov    %edx,%edi
 536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 53d:	8d 76 00             	lea    0x0(%esi),%esi
    *dst++ = *src++;
 540:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 541:	39 f8                	cmp    %edi,%eax
 543:	75 fb                	jne    540 <memmove+0x20>
  return vdst;
}
 545:	5e                   	pop    %esi
 546:	89 d0                	mov    %edx,%eax
 548:	5f                   	pop    %edi
 549:	5d                   	pop    %ebp
 54a:	c3                   	ret

0000054b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 54b:	b8 01 00 00 00       	mov    $0x1,%eax
 550:	cd 40                	int    $0x40
 552:	c3                   	ret

00000553 <exit>:
SYSCALL(exit)
 553:	b8 02 00 00 00       	mov    $0x2,%eax
 558:	cd 40                	int    $0x40
 55a:	c3                   	ret

0000055b <wait>:
SYSCALL(wait)
 55b:	b8 03 00 00 00       	mov    $0x3,%eax
 560:	cd 40                	int    $0x40
 562:	c3                   	ret

00000563 <pipe>:
SYSCALL(pipe)
 563:	b8 04 00 00 00       	mov    $0x4,%eax
 568:	cd 40                	int    $0x40
 56a:	c3                   	ret

0000056b <read>:
SYSCALL(read)
 56b:	b8 05 00 00 00       	mov    $0x5,%eax
 570:	cd 40                	int    $0x40
 572:	c3                   	ret

00000573 <write>:
SYSCALL(write)
 573:	b8 10 00 00 00       	mov    $0x10,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret

0000057b <close>:
SYSCALL(close)
 57b:	b8 15 00 00 00       	mov    $0x15,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret

00000583 <kill>:
SYSCALL(kill)
 583:	b8 06 00 00 00       	mov    $0x6,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret

0000058b <exec>:
SYSCALL(exec)
 58b:	b8 07 00 00 00       	mov    $0x7,%eax
 590:	cd 40                	int    $0x40
 592:	c3                   	ret

00000593 <open>:
SYSCALL(open)
 593:	b8 0f 00 00 00       	mov    $0xf,%eax
 598:	cd 40                	int    $0x40
 59a:	c3                   	ret

0000059b <mknod>:
SYSCALL(mknod)
 59b:	b8 11 00 00 00       	mov    $0x11,%eax
 5a0:	cd 40                	int    $0x40
 5a2:	c3                   	ret

000005a3 <unlink>:
SYSCALL(unlink)
 5a3:	b8 12 00 00 00       	mov    $0x12,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret

000005ab <fstat>:
SYSCALL(fstat)
 5ab:	b8 08 00 00 00       	mov    $0x8,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret

000005b3 <link>:
SYSCALL(link)
 5b3:	b8 13 00 00 00       	mov    $0x13,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret

000005bb <mkdir>:
SYSCALL(mkdir)
 5bb:	b8 14 00 00 00       	mov    $0x14,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret

000005c3 <chdir>:
SYSCALL(chdir)
 5c3:	b8 09 00 00 00       	mov    $0x9,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret

000005cb <dup>:
SYSCALL(dup)
 5cb:	b8 0a 00 00 00       	mov    $0xa,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret

000005d3 <getpid>:
SYSCALL(getpid)
 5d3:	b8 0b 00 00 00       	mov    $0xb,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret

000005db <sbrk>:
SYSCALL(sbrk)
 5db:	b8 0c 00 00 00       	mov    $0xc,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret

000005e3 <sleep>:
SYSCALL(sleep)
 5e3:	b8 0d 00 00 00       	mov    $0xd,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret

000005eb <uptime>:
SYSCALL(uptime)
 5eb:	b8 0e 00 00 00       	mov    $0xe,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret

000005f3 <getrss>:
SYSCALL(getrss)
 5f3:	b8 16 00 00 00       	mov    $0x16,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret

000005fb <getNumFreePages>:
 5fb:	b8 17 00 00 00       	mov    $0x17,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret
 603:	66 90                	xchg   %ax,%ax
 605:	66 90                	xchg   %ax,%ax
 607:	66 90                	xchg   %ax,%ax
 609:	66 90                	xchg   %ax,%ax
 60b:	66 90                	xchg   %ax,%ax
 60d:	66 90                	xchg   %ax,%ax
 60f:	90                   	nop

00000610 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	57                   	push   %edi
 614:	56                   	push   %esi
 615:	53                   	push   %ebx
 616:	89 cb                	mov    %ecx,%ebx
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 618:	89 d1                	mov    %edx,%ecx
{
 61a:	83 ec 3c             	sub    $0x3c,%esp
 61d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  if(sgn && xx < 0){
 620:	85 d2                	test   %edx,%edx
 622:	0f 89 80 00 00 00    	jns    6a8 <printint+0x98>
 628:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 62c:	74 7a                	je     6a8 <printint+0x98>
    x = -xx;
 62e:	f7 d9                	neg    %ecx
    neg = 1;
 630:	b8 01 00 00 00       	mov    $0x1,%eax
  } else {
    x = xx;
  }

  i = 0;
 635:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 638:	31 f6                	xor    %esi,%esi
 63a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
 640:	89 c8                	mov    %ecx,%eax
 642:	31 d2                	xor    %edx,%edx
 644:	89 f7                	mov    %esi,%edi
 646:	f7 f3                	div    %ebx
 648:	8d 76 01             	lea    0x1(%esi),%esi
 64b:	0f b6 92 ac 0b 00 00 	movzbl 0xbac(%edx),%edx
 652:	88 54 35 d7          	mov    %dl,-0x29(%ebp,%esi,1)
  }while((x /= base) != 0);
 656:	89 ca                	mov    %ecx,%edx
 658:	89 c1                	mov    %eax,%ecx
 65a:	39 da                	cmp    %ebx,%edx
 65c:	73 e2                	jae    640 <printint+0x30>
  if(neg)
 65e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 661:	85 c0                	test   %eax,%eax
 663:	74 07                	je     66c <printint+0x5c>
    buf[i++] = '-';
 665:	c6 44 35 d8 2d       	movb   $0x2d,-0x28(%ebp,%esi,1)

  while(--i >= 0)
 66a:	89 f7                	mov    %esi,%edi
 66c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
 66f:	8b 75 c0             	mov    -0x40(%ebp),%esi
 672:	01 df                	add    %ebx,%edi
 674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    putc(fd, buf[i]);
 678:	0f b6 07             	movzbl (%edi),%eax
  write(fd, &c, 1);
 67b:	83 ec 04             	sub    $0x4,%esp
 67e:	88 45 d7             	mov    %al,-0x29(%ebp)
 681:	8d 45 d7             	lea    -0x29(%ebp),%eax
 684:	6a 01                	push   $0x1
 686:	50                   	push   %eax
 687:	56                   	push   %esi
 688:	e8 e6 fe ff ff       	call   573 <write>
  while(--i >= 0)
 68d:	89 f8                	mov    %edi,%eax
 68f:	83 c4 10             	add    $0x10,%esp
 692:	83 ef 01             	sub    $0x1,%edi
 695:	39 c3                	cmp    %eax,%ebx
 697:	75 df                	jne    678 <printint+0x68>
}
 699:	8d 65 f4             	lea    -0xc(%ebp),%esp
 69c:	5b                   	pop    %ebx
 69d:	5e                   	pop    %esi
 69e:	5f                   	pop    %edi
 69f:	5d                   	pop    %ebp
 6a0:	c3                   	ret
 6a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 6a8:	31 c0                	xor    %eax,%eax
 6aa:	eb 89                	jmp    635 <printint+0x25>
 6ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000006b0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	57                   	push   %edi
 6b4:	56                   	push   %esi
 6b5:	53                   	push   %ebx
 6b6:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6b9:	8b 75 0c             	mov    0xc(%ebp),%esi
{
 6bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i = 0; fmt[i]; i++){
 6bf:	0f b6 1e             	movzbl (%esi),%ebx
 6c2:	83 c6 01             	add    $0x1,%esi
 6c5:	84 db                	test   %bl,%bl
 6c7:	74 67                	je     730 <printf+0x80>
 6c9:	8d 4d 10             	lea    0x10(%ebp),%ecx
 6cc:	31 d2                	xor    %edx,%edx
 6ce:	89 4d d0             	mov    %ecx,-0x30(%ebp)
 6d1:	eb 34                	jmp    707 <printf+0x57>
 6d3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6d7:	90                   	nop
 6d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 6db:	ba 25 00 00 00       	mov    $0x25,%edx
      if(c == '%'){
 6e0:	83 f8 25             	cmp    $0x25,%eax
 6e3:	74 18                	je     6fd <printf+0x4d>
  write(fd, &c, 1);
 6e5:	83 ec 04             	sub    $0x4,%esp
 6e8:	8d 45 e7             	lea    -0x19(%ebp),%eax
 6eb:	88 5d e7             	mov    %bl,-0x19(%ebp)
 6ee:	6a 01                	push   $0x1
 6f0:	50                   	push   %eax
 6f1:	57                   	push   %edi
 6f2:	e8 7c fe ff ff       	call   573 <write>
 6f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      } else {
        putc(fd, c);
 6fa:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 6fd:	0f b6 1e             	movzbl (%esi),%ebx
 700:	83 c6 01             	add    $0x1,%esi
 703:	84 db                	test   %bl,%bl
 705:	74 29                	je     730 <printf+0x80>
    c = fmt[i] & 0xff;
 707:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 70a:	85 d2                	test   %edx,%edx
 70c:	74 ca                	je     6d8 <printf+0x28>
      }
    } else if(state == '%'){
 70e:	83 fa 25             	cmp    $0x25,%edx
 711:	75 ea                	jne    6fd <printf+0x4d>
      if(c == 'd'){
 713:	83 f8 25             	cmp    $0x25,%eax
 716:	0f 84 04 01 00 00    	je     820 <printf+0x170>
 71c:	83 e8 63             	sub    $0x63,%eax
 71f:	83 f8 15             	cmp    $0x15,%eax
 722:	77 1c                	ja     740 <printf+0x90>
 724:	ff 24 85 54 0b 00 00 	jmp    *0xb54(,%eax,4)
 72b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 72f:	90                   	nop
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 730:	8d 65 f4             	lea    -0xc(%ebp),%esp
 733:	5b                   	pop    %ebx
 734:	5e                   	pop    %esi
 735:	5f                   	pop    %edi
 736:	5d                   	pop    %ebp
 737:	c3                   	ret
 738:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 73f:	90                   	nop
  write(fd, &c, 1);
 740:	83 ec 04             	sub    $0x4,%esp
 743:	8d 55 e7             	lea    -0x19(%ebp),%edx
 746:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 74a:	6a 01                	push   $0x1
 74c:	52                   	push   %edx
 74d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 750:	57                   	push   %edi
 751:	e8 1d fe ff ff       	call   573 <write>
 756:	83 c4 0c             	add    $0xc,%esp
 759:	88 5d e7             	mov    %bl,-0x19(%ebp)
 75c:	6a 01                	push   $0x1
 75e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 761:	52                   	push   %edx
 762:	57                   	push   %edi
 763:	e8 0b fe ff ff       	call   573 <write>
        putc(fd, c);
 768:	83 c4 10             	add    $0x10,%esp
      state = 0;
 76b:	31 d2                	xor    %edx,%edx
 76d:	eb 8e                	jmp    6fd <printf+0x4d>
 76f:	90                   	nop
        printint(fd, *ap, 16, 0);
 770:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 773:	83 ec 0c             	sub    $0xc,%esp
 776:	b9 10 00 00 00       	mov    $0x10,%ecx
 77b:	8b 13                	mov    (%ebx),%edx
 77d:	6a 00                	push   $0x0
 77f:	89 f8                	mov    %edi,%eax
        ap++;
 781:	83 c3 04             	add    $0x4,%ebx
        printint(fd, *ap, 16, 0);
 784:	e8 87 fe ff ff       	call   610 <printint>
        ap++;
 789:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 78c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 78f:	31 d2                	xor    %edx,%edx
 791:	e9 67 ff ff ff       	jmp    6fd <printf+0x4d>
        s = (char*)*ap;
 796:	8b 45 d0             	mov    -0x30(%ebp),%eax
 799:	8b 18                	mov    (%eax),%ebx
        ap++;
 79b:	83 c0 04             	add    $0x4,%eax
 79e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 7a1:	85 db                	test   %ebx,%ebx
 7a3:	0f 84 87 00 00 00    	je     830 <printf+0x180>
        while(*s != 0){
 7a9:	0f b6 03             	movzbl (%ebx),%eax
      state = 0;
 7ac:	31 d2                	xor    %edx,%edx
        while(*s != 0){
 7ae:	84 c0                	test   %al,%al
 7b0:	0f 84 47 ff ff ff    	je     6fd <printf+0x4d>
 7b6:	8d 55 e7             	lea    -0x19(%ebp),%edx
 7b9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 7bc:	89 de                	mov    %ebx,%esi
 7be:	89 d3                	mov    %edx,%ebx
  write(fd, &c, 1);
 7c0:	83 ec 04             	sub    $0x4,%esp
 7c3:	88 45 e7             	mov    %al,-0x19(%ebp)
          s++;
 7c6:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 7c9:	6a 01                	push   $0x1
 7cb:	53                   	push   %ebx
 7cc:	57                   	push   %edi
 7cd:	e8 a1 fd ff ff       	call   573 <write>
        while(*s != 0){
 7d2:	0f b6 06             	movzbl (%esi),%eax
 7d5:	83 c4 10             	add    $0x10,%esp
 7d8:	84 c0                	test   %al,%al
 7da:	75 e4                	jne    7c0 <printf+0x110>
      state = 0;
 7dc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
 7df:	31 d2                	xor    %edx,%edx
 7e1:	e9 17 ff ff ff       	jmp    6fd <printf+0x4d>
        printint(fd, *ap, 10, 1);
 7e6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 7e9:	83 ec 0c             	sub    $0xc,%esp
 7ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
 7f1:	8b 13                	mov    (%ebx),%edx
 7f3:	6a 01                	push   $0x1
 7f5:	eb 88                	jmp    77f <printf+0xcf>
        putc(fd, *ap);
 7f7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  write(fd, &c, 1);
 7fa:	83 ec 04             	sub    $0x4,%esp
 7fd:	8d 55 e7             	lea    -0x19(%ebp),%edx
        putc(fd, *ap);
 800:	8b 03                	mov    (%ebx),%eax
        ap++;
 802:	83 c3 04             	add    $0x4,%ebx
        putc(fd, *ap);
 805:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 808:	6a 01                	push   $0x1
 80a:	52                   	push   %edx
 80b:	57                   	push   %edi
 80c:	e8 62 fd ff ff       	call   573 <write>
        ap++;
 811:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 814:	83 c4 10             	add    $0x10,%esp
      state = 0;
 817:	31 d2                	xor    %edx,%edx
 819:	e9 df fe ff ff       	jmp    6fd <printf+0x4d>
 81e:	66 90                	xchg   %ax,%ax
  write(fd, &c, 1);
 820:	83 ec 04             	sub    $0x4,%esp
 823:	88 5d e7             	mov    %bl,-0x19(%ebp)
 826:	8d 55 e7             	lea    -0x19(%ebp),%edx
 829:	6a 01                	push   $0x1
 82b:	e9 31 ff ff ff       	jmp    761 <printf+0xb1>
 830:	b8 28 00 00 00       	mov    $0x28,%eax
          s = "(null)";
 835:	bb 56 0a 00 00       	mov    $0xa56,%ebx
 83a:	e9 77 ff ff ff       	jmp    7b6 <printf+0x106>
 83f:	90                   	nop

00000840 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 840:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 841:	a1 c0 0b 00 00       	mov    0xbc0,%eax
{
 846:	89 e5                	mov    %esp,%ebp
 848:	57                   	push   %edi
 849:	56                   	push   %esi
 84a:	53                   	push   %ebx
 84b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 84e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 851:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 858:	8b 10                	mov    (%eax),%edx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	39 c8                	cmp    %ecx,%eax
 85c:	73 32                	jae    890 <free+0x50>
 85e:	39 d1                	cmp    %edx,%ecx
 860:	72 04                	jb     866 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	39 d0                	cmp    %edx,%eax
 864:	72 32                	jb     898 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 866:	8b 73 fc             	mov    -0x4(%ebx),%esi
 869:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 86c:	39 fa                	cmp    %edi,%edx
 86e:	74 30                	je     8a0 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 870:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 873:	8b 50 04             	mov    0x4(%eax),%edx
 876:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 879:	39 f1                	cmp    %esi,%ecx
 87b:	74 3a                	je     8b7 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 87d:	89 08                	mov    %ecx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
}
 87f:	5b                   	pop    %ebx
  freep = p;
 880:	a3 c0 0b 00 00       	mov    %eax,0xbc0
}
 885:	5e                   	pop    %esi
 886:	5f                   	pop    %edi
 887:	5d                   	pop    %ebp
 888:	c3                   	ret
 889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 890:	39 d0                	cmp    %edx,%eax
 892:	72 04                	jb     898 <free+0x58>
 894:	39 d1                	cmp    %edx,%ecx
 896:	72 ce                	jb     866 <free+0x26>
{
 898:	89 d0                	mov    %edx,%eax
 89a:	eb bc                	jmp    858 <free+0x18>
 89c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 8a0:	03 72 04             	add    0x4(%edx),%esi
 8a3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a6:	8b 10                	mov    (%eax),%edx
 8a8:	8b 12                	mov    (%edx),%edx
 8aa:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 8ad:	8b 50 04             	mov    0x4(%eax),%edx
 8b0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8b3:	39 f1                	cmp    %esi,%ecx
 8b5:	75 c6                	jne    87d <free+0x3d>
    p->s.size += bp->s.size;
 8b7:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 8ba:	a3 c0 0b 00 00       	mov    %eax,0xbc0
    p->s.size += bp->s.size;
 8bf:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8c2:	8b 4b f8             	mov    -0x8(%ebx),%ecx
 8c5:	89 08                	mov    %ecx,(%eax)
}
 8c7:	5b                   	pop    %ebx
 8c8:	5e                   	pop    %esi
 8c9:	5f                   	pop    %edi
 8ca:	5d                   	pop    %ebp
 8cb:	c3                   	ret
 8cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000008d0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d0:	55                   	push   %ebp
 8d1:	89 e5                	mov    %esp,%ebp
 8d3:	57                   	push   %edi
 8d4:	56                   	push   %esi
 8d5:	53                   	push   %ebx
 8d6:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d9:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 8dc:	8b 15 c0 0b 00 00    	mov    0xbc0,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e2:	8d 78 07             	lea    0x7(%eax),%edi
 8e5:	c1 ef 03             	shr    $0x3,%edi
 8e8:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 8eb:	85 d2                	test   %edx,%edx
 8ed:	0f 84 8d 00 00 00    	je     980 <malloc+0xb0>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f3:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 8f5:	8b 48 04             	mov    0x4(%eax),%ecx
 8f8:	39 f9                	cmp    %edi,%ecx
 8fa:	73 64                	jae    960 <malloc+0x90>
  if(nu < 4096)
 8fc:	bb 00 10 00 00       	mov    $0x1000,%ebx
 901:	39 df                	cmp    %ebx,%edi
 903:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 906:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 90d:	eb 0a                	jmp    919 <malloc+0x49>
 90f:	90                   	nop
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 910:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 912:	8b 48 04             	mov    0x4(%eax),%ecx
 915:	39 f9                	cmp    %edi,%ecx
 917:	73 47                	jae    960 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 919:	89 c2                	mov    %eax,%edx
 91b:	3b 05 c0 0b 00 00    	cmp    0xbc0,%eax
 921:	75 ed                	jne    910 <malloc+0x40>
  p = sbrk(nu * sizeof(Header));
 923:	83 ec 0c             	sub    $0xc,%esp
 926:	56                   	push   %esi
 927:	e8 af fc ff ff       	call   5db <sbrk>
  if(p == (char*)-1)
 92c:	83 c4 10             	add    $0x10,%esp
 92f:	83 f8 ff             	cmp    $0xffffffff,%eax
 932:	74 1c                	je     950 <malloc+0x80>
  hp->s.size = nu;
 934:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 937:	83 ec 0c             	sub    $0xc,%esp
 93a:	83 c0 08             	add    $0x8,%eax
 93d:	50                   	push   %eax
 93e:	e8 fd fe ff ff       	call   840 <free>
  return freep;
 943:	8b 15 c0 0b 00 00    	mov    0xbc0,%edx
      if((p = morecore(nunits)) == 0)
 949:	83 c4 10             	add    $0x10,%esp
 94c:	85 d2                	test   %edx,%edx
 94e:	75 c0                	jne    910 <malloc+0x40>
        return 0;
  }
}
 950:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 953:	31 c0                	xor    %eax,%eax
}
 955:	5b                   	pop    %ebx
 956:	5e                   	pop    %esi
 957:	5f                   	pop    %edi
 958:	5d                   	pop    %ebp
 959:	c3                   	ret
 95a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 960:	39 cf                	cmp    %ecx,%edi
 962:	74 4c                	je     9b0 <malloc+0xe0>
        p->s.size -= nunits;
 964:	29 f9                	sub    %edi,%ecx
 966:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 969:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 96c:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 96f:	89 15 c0 0b 00 00    	mov    %edx,0xbc0
}
 975:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 978:	83 c0 08             	add    $0x8,%eax
}
 97b:	5b                   	pop    %ebx
 97c:	5e                   	pop    %esi
 97d:	5f                   	pop    %edi
 97e:	5d                   	pop    %ebp
 97f:	c3                   	ret
    base.s.ptr = freep = prevp = &base;
 980:	c7 05 c0 0b 00 00 c4 	movl   $0xbc4,0xbc0
 987:	0b 00 00 
    base.s.size = 0;
 98a:	b8 c4 0b 00 00       	mov    $0xbc4,%eax
    base.s.ptr = freep = prevp = &base;
 98f:	c7 05 c4 0b 00 00 c4 	movl   $0xbc4,0xbc4
 996:	0b 00 00 
    base.s.size = 0;
 999:	c7 05 c8 0b 00 00 00 	movl   $0x0,0xbc8
 9a0:	00 00 00 
    if(p->s.size >= nunits){
 9a3:	e9 54 ff ff ff       	jmp    8fc <malloc+0x2c>
 9a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 9af:	90                   	nop
        prevp->s.ptr = p->s.ptr;
 9b0:	8b 08                	mov    (%eax),%ecx
 9b2:	89 0a                	mov    %ecx,(%edx)
 9b4:	eb b9                	jmp    96f <malloc+0x9f>
