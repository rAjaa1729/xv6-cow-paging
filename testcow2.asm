
_testcow2:     file format elf32-i386


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
  11:	68 c4 09 00 00       	push   $0x9c4
  16:	6a 01                	push   $0x1
  18:	e8 13 06 00 00       	call   630 <printf>
	test();
  1d:	e8 1e 00 00 00       	call   40 <test>
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
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	c7 00 ae ad 01 00    	movl   $0x1adae,(%eax)
}
  3c:	5d                   	pop    %ebp
  3d:	c3                   	ret
  3e:	66 90                	xchg   %ax,%ax

00000040 <test>:
{
  40:	55                   	push   %ebp
  41:	89 e5                	mov    %esp,%ebp
  43:	57                   	push   %edi
  44:	56                   	push   %esi
  45:	53                   	push   %ebx
  46:	83 ec 1c             	sub    $0x1c,%esp
    uint prev_free_pages = getNumFreePages();
  49:	e8 2d 05 00 00       	call   57b <getNumFreePages>
    char *m1 = (char*)malloc(size);
  4e:	83 ec 0c             	sub    $0xc,%esp
    long long size = ((prev_free_pages - 20) * 4 * 1024) / 3; // 20 pages will be used by kernel to create kstack, and process related datastructures.
  51:	8d 50 ec             	lea    -0x14(%eax),%edx
  54:	b8 ab aa aa aa       	mov    $0xaaaaaaab,%eax
  59:	c1 e2 0c             	shl    $0xc,%edx
  5c:	f7 e2                	mul    %edx
  5e:	89 d3                	mov    %edx,%ebx
  60:	d1 eb                	shr    %ebx
    char *m1 = (char*)malloc(size);
  62:	53                   	push   %ebx
  63:	e8 e8 07 00 00       	call   850 <malloc>
    if (m1 == 0) goto out_of_memory;
  68:	83 c4 10             	add    $0x10,%esp
    char *m1 = (char*)malloc(size);
  6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (m1 == 0) goto out_of_memory;
  6e:	85 c0                	test   %eax,%eax
  70:	0f 84 b3 01 00 00    	je     229 <test+0x1e9>
    printf(1, "\n*** Forking ***\n");
  76:	83 ec 08             	sub    $0x8,%esp
  79:	68 62 09 00 00       	push   $0x962
  7e:	6a 01                	push   $0x1
  80:	e8 ab 05 00 00       	call   630 <printf>
    pid = fork();
  85:	e8 41 04 00 00       	call   4cb <fork>
    if (pid < 0) goto fork_failed; // Fork failed
  8a:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  8d:	89 c7                	mov    %eax,%edi
    if (pid < 0) goto fork_failed; // Fork failed
  8f:	85 c0                	test   %eax,%eax
  91:	0f 88 ba 01 00 00    	js     251 <test+0x211>
    long long size = ((prev_free_pages - 20) * 4 * 1024) / 3; // 20 pages will be used by kernel to create kstack, and process related datastructures.
  97:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  9a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    if (pid == 0) { // Child process
  a1:	0f 84 b5 00 00 00    	je     15c <test+0x11c>
        printf(1, "\n*** Parent ***\n");
  a7:	57                   	push   %edi
  a8:	57                   	push   %edi
            m1[i] = (char)(97+(i%26));
  a9:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
        printf(1, "\n*** Parent ***\n");
  ae:	68 9f 09 00 00       	push   $0x99f
  b3:	6a 01                	push   $0x1
  b5:	e8 76 05 00 00       	call   630 <printf>
        prev_free_pages = getNumFreePages();
  ba:	e8 bc 04 00 00       	call   57b <getNumFreePages>
        for (int i=0; i<size; i++) {
  bf:	83 c4 10             	add    $0x10,%esp
  c2:	31 c9                	xor    %ecx,%ecx
        prev_free_pages = getNumFreePages();
  c4:	89 c6                	mov    %eax,%esi
        for (int i=0; i<size; i++) {
  c6:	85 db                	test   %ebx,%ebx
  c8:	0f 84 25 01 00 00    	je     1f3 <test+0x1b3>
            m1[i] = (char)(97+(i%26));
  ce:	89 c8                	mov    %ecx,%eax
  d0:	f7 e7                	mul    %edi
  d2:	89 d0                	mov    %edx,%eax
  d4:	89 ca                	mov    %ecx,%edx
  d6:	c1 e8 03             	shr    $0x3,%eax
  d9:	6b c0 1a             	imul   $0x1a,%eax,%eax
  dc:	29 c2                	sub    %eax,%edx
  de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  e1:	83 c2 61             	add    $0x61,%edx
  e4:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        for (int i=0; i<size; i++) {
  e7:	83 c1 01             	add    $0x1,%ecx
  ea:	39 d9                	cmp    %ebx,%ecx
  ec:	75 e0                	jne    ce <test+0x8e>
        curr_free_pages = getNumFreePages();
  ee:	e8 88 04 00 00       	call   57b <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
  f3:	39 f0                	cmp    %esi,%eax
  f5:	0f 83 78 01 00 00    	jae    273 <test+0x233>
  fb:	31 c9                	xor    %ecx,%ecx
  fd:	31 db                	xor    %ebx,%ebx
  ff:	eb 1c                	jmp    11d <test+0xdd>
        for(int k=0;k<size;++k){
 101:	83 c1 01             	add    $0x1,%ecx
 104:	8b 7d d8             	mov    -0x28(%ebp),%edi
 107:	8b 75 dc             	mov    -0x24(%ebp),%esi
 10a:	83 d3 00             	adc    $0x0,%ebx
 10d:	89 c8                	mov    %ecx,%eax
 10f:	89 da                	mov    %ebx,%edx
 111:	31 f8                	xor    %edi,%eax
 113:	31 f2                	xor    %esi,%edx
 115:	09 d0                	or     %edx,%eax
 117:	0f 84 df 00 00 00    	je     1fc <test+0x1bc>
			if(m1[k] != (char)(97+(k%26))) goto failed;
 11d:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
 122:	f7 e1                	mul    %ecx
 124:	89 d0                	mov    %edx,%eax
 126:	89 ca                	mov    %ecx,%edx
 128:	c1 e8 03             	shr    $0x3,%eax
 12b:	6b c0 1a             	imul   $0x1a,%eax,%eax
 12e:	29 c2                	sub    %eax,%edx
 130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 133:	83 c2 61             	add    $0x61,%edx
 136:	38 14 08             	cmp    %dl,(%eax,%ecx,1)
 139:	74 c6                	je     101 <test+0xc1>
    printf(1, "Copy failed: The memory contents of the processes is inconsistent!\n");
 13b:	50                   	push   %eax
 13c:	50                   	push   %eax
 13d:	68 90 0a 00 00       	push   $0xa90
	printf(1, "Failed to fork a process!\n");
 142:	6a 01                	push   $0x1
 144:	e8 e7 04 00 00       	call   630 <printf>
    printf(1, "Lab5 test failed!\n");
 149:	58                   	pop    %eax
 14a:	5a                   	pop    %edx
 14b:	68 4f 09 00 00       	push   $0x94f
 150:	6a 01                	push   $0x1
 152:	e8 d9 04 00 00       	call   630 <printf>
	exit();
 157:	e8 77 03 00 00       	call   4d3 <exit>
        printf(1, "\n*** Child ***\n");
 15c:	50                   	push   %eax
 15d:	50                   	push   %eax
 15e:	68 8f 09 00 00       	push   $0x98f
 163:	6a 01                	push   $0x1
 165:	e8 c6 04 00 00       	call   630 <printf>
        prev_free_pages = getNumFreePages();
 16a:	e8 0c 04 00 00       	call   57b <getNumFreePages>
        for (int i=0; i<size; i++) {
 16f:	83 c4 10             	add    $0x10,%esp
        prev_free_pages = getNumFreePages();
 172:	89 c6                	mov    %eax,%esi
        for (int i=0; i<size; i++) {
 174:	85 db                	test   %ebx,%ebx
 176:	0f 84 b9 00 00 00    	je     235 <test+0x1f5>
            m1[i] = (char)(65+(i%26));
 17c:	b9 4f ec c4 4e       	mov    $0x4ec4ec4f,%ecx
 181:	89 f8                	mov    %edi,%eax
 183:	f7 e1                	mul    %ecx
 185:	89 d0                	mov    %edx,%eax
 187:	89 fa                	mov    %edi,%edx
 189:	c1 e8 03             	shr    $0x3,%eax
 18c:	6b c0 1a             	imul   $0x1a,%eax,%eax
 18f:	29 c2                	sub    %eax,%edx
 191:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 194:	83 c2 41             	add    $0x41,%edx
 197:	88 14 38             	mov    %dl,(%eax,%edi,1)
        for (int i=0; i<size; i++) {
 19a:	83 c7 01             	add    $0x1,%edi
 19d:	39 df                	cmp    %ebx,%edi
 19f:	75 e0                	jne    181 <test+0x141>
        curr_free_pages = getNumFreePages();
 1a1:	e8 d5 03 00 00       	call   57b <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
 1a6:	31 db                	xor    %ebx,%ebx
 1a8:	31 c9                	xor    %ecx,%ecx
 1aa:	39 f0                	cmp    %esi,%eax
 1ac:	72 22                	jb     1d0 <test+0x190>
 1ae:	e9 aa 00 00 00       	jmp    25d <test+0x21d>
 1b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1b7:	90                   	nop
        for(int k=0;k<size;++k){
 1b8:	83 c1 01             	add    $0x1,%ecx
 1bb:	8b 7d d8             	mov    -0x28(%ebp),%edi
 1be:	8b 75 dc             	mov    -0x24(%ebp),%esi
 1c1:	83 d3 00             	adc    $0x0,%ebx
 1c4:	89 c8                	mov    %ecx,%eax
 1c6:	89 da                	mov    %ebx,%edx
 1c8:	31 f8                	xor    %edi,%eax
 1ca:	31 f2                	xor    %esi,%edx
 1cc:	09 d0                	or     %edx,%eax
 1ce:	74 6e                	je     23e <test+0x1fe>
			if(m1[k] != (char)(65+(k%26))) goto failed;
 1d0:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
 1d5:	f7 e1                	mul    %ecx
 1d7:	89 d0                	mov    %edx,%eax
 1d9:	89 ca                	mov    %ecx,%edx
 1db:	c1 e8 03             	shr    $0x3,%eax
 1de:	6b c0 1a             	imul   $0x1a,%eax,%eax
 1e1:	29 c2                	sub    %eax,%edx
 1e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1e6:	83 c2 41             	add    $0x41,%edx
 1e9:	38 14 08             	cmp    %dl,(%eax,%ecx,1)
 1ec:	74 ca                	je     1b8 <test+0x178>
 1ee:	e9 48 ff ff ff       	jmp    13b <test+0xfb>
        curr_free_pages = getNumFreePages();
 1f3:	e8 83 03 00 00       	call   57b <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
 1f8:	39 f0                	cmp    %esi,%eax
 1fa:	73 77                	jae    273 <test+0x233>
        wait();
 1fc:	e8 da 02 00 00       	call   4db <wait>
        printf(1, "done processing %d\n", x);
 201:	52                   	push   %edx
 202:	68 ae ad 01 00       	push   $0x1adae
 207:	68 b0 09 00 00       	push   $0x9b0
 20c:	6a 01                	push   $0x1
 20e:	e8 1d 04 00 00       	call   630 <printf>
        printf(1, "[COW2] Lab5 Parent test passed!\n");
 213:	59                   	pop    %ecx
 214:	5b                   	pop    %ebx
 215:	68 6c 0a 00 00       	push   $0xa6c
 21a:	6a 01                	push   $0x1
 21c:	e8 0f 04 00 00       	call   630 <printf>
 221:	83 c4 10             	add    $0x10,%esp
    exit();
 224:	e8 aa 02 00 00       	call   4d3 <exit>
	printf(1, "Exceeded the PHYSTOP!\n");
 229:	53                   	push   %ebx
 22a:	53                   	push   %ebx
 22b:	68 38 09 00 00       	push   $0x938
 230:	e9 0d ff ff ff       	jmp    142 <test+0x102>
        curr_free_pages = getNumFreePages();
 235:	e8 41 03 00 00       	call   57b <getNumFreePages>
        if (curr_free_pages >= prev_free_pages) {
 23a:	39 f0                	cmp    %esi,%eax
 23c:	73 1f                	jae    25d <test+0x21d>
        printf(1, "[COW2] Lab5 Child test passed!\n");
 23e:	50                   	push   %eax
 23f:	50                   	push   %eax
 240:	68 14 0a 00 00       	push   $0xa14
 245:	6a 01                	push   $0x1
 247:	e8 e4 03 00 00       	call   630 <printf>
 24c:	83 c4 10             	add    $0x10,%esp
 24f:	eb d3                	jmp    224 <test+0x1e4>
	printf(1, "Failed to fork a process!\n");
 251:	51                   	push   %ecx
 252:	51                   	push   %ecx
 253:	68 74 09 00 00       	push   $0x974
 258:	e9 e5 fe ff ff       	jmp    142 <test+0x102>
            printf(1, "Lab5 Child: Free pages should decrease after write\n");
 25d:	50                   	push   %eax
 25e:	50                   	push   %eax
 25f:	68 e0 09 00 00       	push   $0x9e0
 264:	6a 01                	push   $0x1
 266:	e8 c5 03 00 00       	call   630 <printf>
            goto failed;
 26b:	83 c4 10             	add    $0x10,%esp
 26e:	e9 c8 fe ff ff       	jmp    13b <test+0xfb>
            printf(1, "Lab5 Parent: Free pages should decrease after write\n");
 273:	56                   	push   %esi
 274:	56                   	push   %esi
 275:	68 34 0a 00 00       	push   $0xa34
 27a:	6a 01                	push   $0x1
 27c:	e8 af 03 00 00       	call   630 <printf>
            goto failed;
 281:	83 c4 10             	add    $0x10,%esp
 284:	e9 b2 fe ff ff       	jmp    13b <test+0xfb>
 289:	66 90                	xchg   %ax,%ax
 28b:	66 90                	xchg   %ax,%ax
 28d:	66 90                	xchg   %ax,%ax
 28f:	90                   	nop

00000290 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 290:	55                   	push   %ebp
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 291:	31 c0                	xor    %eax,%eax
{
 293:	89 e5                	mov    %esp,%ebp
 295:	53                   	push   %ebx
 296:	8b 4d 08             	mov    0x8(%ebp),%ecx
 299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 29c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while((*s++ = *t++) != 0)
 2a0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
 2a4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
 2a7:	83 c0 01             	add    $0x1,%eax
 2aa:	84 d2                	test   %dl,%dl
 2ac:	75 f2                	jne    2a0 <strcpy+0x10>
    ;
  return os;
}
 2ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2b1:	89 c8                	mov    %ecx,%eax
 2b3:	c9                   	leave
 2b4:	c3                   	ret
 2b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000002c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	53                   	push   %ebx
 2c4:	8b 55 08             	mov    0x8(%ebp),%edx
 2c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 2ca:	0f b6 02             	movzbl (%edx),%eax
 2cd:	84 c0                	test   %al,%al
 2cf:	75 17                	jne    2e8 <strcmp+0x28>
 2d1:	eb 3a                	jmp    30d <strcmp+0x4d>
 2d3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2d7:	90                   	nop
 2d8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
    p++, q++;
 2dc:	83 c2 01             	add    $0x1,%edx
 2df:	8d 59 01             	lea    0x1(%ecx),%ebx
  while(*p && *p == *q)
 2e2:	84 c0                	test   %al,%al
 2e4:	74 1a                	je     300 <strcmp+0x40>
 2e6:	89 d9                	mov    %ebx,%ecx
 2e8:	0f b6 19             	movzbl (%ecx),%ebx
 2eb:	38 c3                	cmp    %al,%bl
 2ed:	74 e9                	je     2d8 <strcmp+0x18>
  return (uchar)*p - (uchar)*q;
 2ef:	29 d8                	sub    %ebx,%eax
}
 2f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2f4:	c9                   	leave
 2f5:	c3                   	ret
 2f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2fd:	8d 76 00             	lea    0x0(%esi),%esi
  return (uchar)*p - (uchar)*q;
 300:	0f b6 59 01          	movzbl 0x1(%ecx),%ebx
 304:	31 c0                	xor    %eax,%eax
 306:	29 d8                	sub    %ebx,%eax
}
 308:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 30b:	c9                   	leave
 30c:	c3                   	ret
  return (uchar)*p - (uchar)*q;
 30d:	0f b6 19             	movzbl (%ecx),%ebx
 310:	31 c0                	xor    %eax,%eax
 312:	eb db                	jmp    2ef <strcmp+0x2f>
 314:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 31b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 31f:	90                   	nop

00000320 <strlen>:

uint
strlen(const char *s)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
 326:	80 3a 00             	cmpb   $0x0,(%edx)
 329:	74 15                	je     340 <strlen+0x20>
 32b:	31 c0                	xor    %eax,%eax
 32d:	8d 76 00             	lea    0x0(%esi),%esi
 330:	83 c0 01             	add    $0x1,%eax
 333:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
 337:	89 c1                	mov    %eax,%ecx
 339:	75 f5                	jne    330 <strlen+0x10>
    ;
  return n;
}
 33b:	89 c8                	mov    %ecx,%eax
 33d:	5d                   	pop    %ebp
 33e:	c3                   	ret
 33f:	90                   	nop
  for(n = 0; s[n]; n++)
 340:	31 c9                	xor    %ecx,%ecx
}
 342:	5d                   	pop    %ebp
 343:	89 c8                	mov    %ecx,%eax
 345:	c3                   	ret
 346:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 34d:	8d 76 00             	lea    0x0(%esi),%esi

00000350 <memset>:

void*
memset(void *dst, int c, uint n)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	57                   	push   %edi
 354:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 357:	8b 4d 10             	mov    0x10(%ebp),%ecx
 35a:	8b 45 0c             	mov    0xc(%ebp),%eax
 35d:	89 d7                	mov    %edx,%edi
 35f:	fc                   	cld
 360:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 362:	8b 7d fc             	mov    -0x4(%ebp),%edi
 365:	89 d0                	mov    %edx,%eax
 367:	c9                   	leave
 368:	c3                   	ret
 369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000370 <strchr>:

char*
strchr(const char *s, char c)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 37a:	0f b6 10             	movzbl (%eax),%edx
 37d:	84 d2                	test   %dl,%dl
 37f:	75 12                	jne    393 <strchr+0x23>
 381:	eb 1d                	jmp    3a0 <strchr+0x30>
 383:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 387:	90                   	nop
 388:	0f b6 50 01          	movzbl 0x1(%eax),%edx
 38c:	83 c0 01             	add    $0x1,%eax
 38f:	84 d2                	test   %dl,%dl
 391:	74 0d                	je     3a0 <strchr+0x30>
    if(*s == c)
 393:	38 d1                	cmp    %dl,%cl
 395:	75 f1                	jne    388 <strchr+0x18>
      return (char*)s;
  return 0;
}
 397:	5d                   	pop    %ebp
 398:	c3                   	ret
 399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return 0;
 3a0:	31 c0                	xor    %eax,%eax
}
 3a2:	5d                   	pop    %ebp
 3a3:	c3                   	ret
 3a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 3ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3af:	90                   	nop

000003b0 <gets>:

char*
gets(char *buf, int max)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	57                   	push   %edi
 3b4:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
 3b5:	8d 75 e7             	lea    -0x19(%ebp),%esi
{
 3b8:	53                   	push   %ebx
  for(i=0; i+1 < max; ){
 3b9:	31 db                	xor    %ebx,%ebx
{
 3bb:	83 ec 1c             	sub    $0x1c,%esp
  for(i=0; i+1 < max; ){
 3be:	eb 27                	jmp    3e7 <gets+0x37>
    cc = read(0, &c, 1);
 3c0:	83 ec 04             	sub    $0x4,%esp
 3c3:	6a 01                	push   $0x1
 3c5:	56                   	push   %esi
 3c6:	6a 00                	push   $0x0
 3c8:	e8 1e 01 00 00       	call   4eb <read>
    if(cc < 1)
 3cd:	83 c4 10             	add    $0x10,%esp
 3d0:	85 c0                	test   %eax,%eax
 3d2:	7e 1d                	jle    3f1 <gets+0x41>
      break;
    buf[i++] = c;
 3d4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 3d8:	8b 55 08             	mov    0x8(%ebp),%edx
 3db:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
    if(c == '\n' || c == '\r')
 3df:	3c 0a                	cmp    $0xa,%al
 3e1:	74 10                	je     3f3 <gets+0x43>
 3e3:	3c 0d                	cmp    $0xd,%al
 3e5:	74 0c                	je     3f3 <gets+0x43>
  for(i=0; i+1 < max; ){
 3e7:	89 df                	mov    %ebx,%edi
 3e9:	83 c3 01             	add    $0x1,%ebx
 3ec:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 3ef:	7c cf                	jl     3c0 <gets+0x10>
 3f1:	89 fb                	mov    %edi,%ebx
      break;
  }
  buf[i] = '\0';
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 3fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3fd:	5b                   	pop    %ebx
 3fe:	5e                   	pop    %esi
 3ff:	5f                   	pop    %edi
 400:	5d                   	pop    %ebp
 401:	c3                   	ret
 402:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000410 <stat>:

int
stat(const char *n, struct stat *st)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	56                   	push   %esi
 414:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 415:	83 ec 08             	sub    $0x8,%esp
 418:	6a 00                	push   $0x0
 41a:	ff 75 08             	push   0x8(%ebp)
 41d:	e8 f1 00 00 00       	call   513 <open>
  if(fd < 0)
 422:	83 c4 10             	add    $0x10,%esp
 425:	85 c0                	test   %eax,%eax
 427:	78 27                	js     450 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 429:	83 ec 08             	sub    $0x8,%esp
 42c:	ff 75 0c             	push   0xc(%ebp)
 42f:	89 c3                	mov    %eax,%ebx
 431:	50                   	push   %eax
 432:	e8 f4 00 00 00       	call   52b <fstat>
  close(fd);
 437:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 43a:	89 c6                	mov    %eax,%esi
  close(fd);
 43c:	e8 ba 00 00 00       	call   4fb <close>
  return r;
 441:	83 c4 10             	add    $0x10,%esp
}
 444:	8d 65 f8             	lea    -0x8(%ebp),%esp
 447:	89 f0                	mov    %esi,%eax
 449:	5b                   	pop    %ebx
 44a:	5e                   	pop    %esi
 44b:	5d                   	pop    %ebp
 44c:	c3                   	ret
 44d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 450:	be ff ff ff ff       	mov    $0xffffffff,%esi
 455:	eb ed                	jmp    444 <stat+0x34>
 457:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 45e:	66 90                	xchg   %ax,%ax

00000460 <atoi>:

int
atoi(const char *s)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	53                   	push   %ebx
 464:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 467:	0f be 02             	movsbl (%edx),%eax
 46a:	8d 48 d0             	lea    -0x30(%eax),%ecx
 46d:	80 f9 09             	cmp    $0x9,%cl
  n = 0;
 470:	b9 00 00 00 00       	mov    $0x0,%ecx
  while('0' <= *s && *s <= '9')
 475:	77 1e                	ja     495 <atoi+0x35>
 477:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 47e:	66 90                	xchg   %ax,%ax
    n = n*10 + *s++ - '0';
 480:	83 c2 01             	add    $0x1,%edx
 483:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
 486:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
  while('0' <= *s && *s <= '9')
 48a:	0f be 02             	movsbl (%edx),%eax
 48d:	8d 58 d0             	lea    -0x30(%eax),%ebx
 490:	80 fb 09             	cmp    $0x9,%bl
 493:	76 eb                	jbe    480 <atoi+0x20>
  return n;
}
 495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 498:	89 c8                	mov    %ecx,%eax
 49a:	c9                   	leave
 49b:	c3                   	ret
 49c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000004a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	57                   	push   %edi
 4a4:	8b 45 10             	mov    0x10(%ebp),%eax
 4a7:	8b 55 08             	mov    0x8(%ebp),%edx
 4aa:	56                   	push   %esi
 4ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4ae:	85 c0                	test   %eax,%eax
 4b0:	7e 13                	jle    4c5 <memmove+0x25>
 4b2:	01 d0                	add    %edx,%eax
  dst = vdst;
 4b4:	89 d7                	mov    %edx,%edi
 4b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 4bd:	8d 76 00             	lea    0x0(%esi),%esi
    *dst++ = *src++;
 4c0:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 4c1:	39 f8                	cmp    %edi,%eax
 4c3:	75 fb                	jne    4c0 <memmove+0x20>
  return vdst;
}
 4c5:	5e                   	pop    %esi
 4c6:	89 d0                	mov    %edx,%eax
 4c8:	5f                   	pop    %edi
 4c9:	5d                   	pop    %ebp
 4ca:	c3                   	ret

000004cb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4cb:	b8 01 00 00 00       	mov    $0x1,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret

000004d3 <exit>:
SYSCALL(exit)
 4d3:	b8 02 00 00 00       	mov    $0x2,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret

000004db <wait>:
SYSCALL(wait)
 4db:	b8 03 00 00 00       	mov    $0x3,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret

000004e3 <pipe>:
SYSCALL(pipe)
 4e3:	b8 04 00 00 00       	mov    $0x4,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret

000004eb <read>:
SYSCALL(read)
 4eb:	b8 05 00 00 00       	mov    $0x5,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret

000004f3 <write>:
SYSCALL(write)
 4f3:	b8 10 00 00 00       	mov    $0x10,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret

000004fb <close>:
SYSCALL(close)
 4fb:	b8 15 00 00 00       	mov    $0x15,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret

00000503 <kill>:
SYSCALL(kill)
 503:	b8 06 00 00 00       	mov    $0x6,%eax
 508:	cd 40                	int    $0x40
 50a:	c3                   	ret

0000050b <exec>:
SYSCALL(exec)
 50b:	b8 07 00 00 00       	mov    $0x7,%eax
 510:	cd 40                	int    $0x40
 512:	c3                   	ret

00000513 <open>:
SYSCALL(open)
 513:	b8 0f 00 00 00       	mov    $0xf,%eax
 518:	cd 40                	int    $0x40
 51a:	c3                   	ret

0000051b <mknod>:
SYSCALL(mknod)
 51b:	b8 11 00 00 00       	mov    $0x11,%eax
 520:	cd 40                	int    $0x40
 522:	c3                   	ret

00000523 <unlink>:
SYSCALL(unlink)
 523:	b8 12 00 00 00       	mov    $0x12,%eax
 528:	cd 40                	int    $0x40
 52a:	c3                   	ret

0000052b <fstat>:
SYSCALL(fstat)
 52b:	b8 08 00 00 00       	mov    $0x8,%eax
 530:	cd 40                	int    $0x40
 532:	c3                   	ret

00000533 <link>:
SYSCALL(link)
 533:	b8 13 00 00 00       	mov    $0x13,%eax
 538:	cd 40                	int    $0x40
 53a:	c3                   	ret

0000053b <mkdir>:
SYSCALL(mkdir)
 53b:	b8 14 00 00 00       	mov    $0x14,%eax
 540:	cd 40                	int    $0x40
 542:	c3                   	ret

00000543 <chdir>:
SYSCALL(chdir)
 543:	b8 09 00 00 00       	mov    $0x9,%eax
 548:	cd 40                	int    $0x40
 54a:	c3                   	ret

0000054b <dup>:
SYSCALL(dup)
 54b:	b8 0a 00 00 00       	mov    $0xa,%eax
 550:	cd 40                	int    $0x40
 552:	c3                   	ret

00000553 <getpid>:
SYSCALL(getpid)
 553:	b8 0b 00 00 00       	mov    $0xb,%eax
 558:	cd 40                	int    $0x40
 55a:	c3                   	ret

0000055b <sbrk>:
SYSCALL(sbrk)
 55b:	b8 0c 00 00 00       	mov    $0xc,%eax
 560:	cd 40                	int    $0x40
 562:	c3                   	ret

00000563 <sleep>:
SYSCALL(sleep)
 563:	b8 0d 00 00 00       	mov    $0xd,%eax
 568:	cd 40                	int    $0x40
 56a:	c3                   	ret

0000056b <uptime>:
SYSCALL(uptime)
 56b:	b8 0e 00 00 00       	mov    $0xe,%eax
 570:	cd 40                	int    $0x40
 572:	c3                   	ret

00000573 <getrss>:
SYSCALL(getrss)
 573:	b8 16 00 00 00       	mov    $0x16,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret

0000057b <getNumFreePages>:
 57b:	b8 17 00 00 00       	mov    $0x17,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret
 583:	66 90                	xchg   %ax,%ax
 585:	66 90                	xchg   %ax,%ax
 587:	66 90                	xchg   %ax,%ax
 589:	66 90                	xchg   %ax,%ax
 58b:	66 90                	xchg   %ax,%ax
 58d:	66 90                	xchg   %ax,%ax
 58f:	90                   	nop

00000590 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 590:	55                   	push   %ebp
 591:	89 e5                	mov    %esp,%ebp
 593:	57                   	push   %edi
 594:	56                   	push   %esi
 595:	53                   	push   %ebx
 596:	89 cb                	mov    %ecx,%ebx
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 598:	89 d1                	mov    %edx,%ecx
{
 59a:	83 ec 3c             	sub    $0x3c,%esp
 59d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  if(sgn && xx < 0){
 5a0:	85 d2                	test   %edx,%edx
 5a2:	0f 89 80 00 00 00    	jns    628 <printint+0x98>
 5a8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 5ac:	74 7a                	je     628 <printint+0x98>
    x = -xx;
 5ae:	f7 d9                	neg    %ecx
    neg = 1;
 5b0:	b8 01 00 00 00       	mov    $0x1,%eax
  } else {
    x = xx;
  }

  i = 0;
 5b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 5b8:	31 f6                	xor    %esi,%esi
 5ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
 5c0:	89 c8                	mov    %ecx,%eax
 5c2:	31 d2                	xor    %edx,%edx
 5c4:	89 f7                	mov    %esi,%edi
 5c6:	f7 f3                	div    %ebx
 5c8:	8d 76 01             	lea    0x1(%esi),%esi
 5cb:	0f b6 92 2c 0b 00 00 	movzbl 0xb2c(%edx),%edx
 5d2:	88 54 35 d7          	mov    %dl,-0x29(%ebp,%esi,1)
  }while((x /= base) != 0);
 5d6:	89 ca                	mov    %ecx,%edx
 5d8:	89 c1                	mov    %eax,%ecx
 5da:	39 da                	cmp    %ebx,%edx
 5dc:	73 e2                	jae    5c0 <printint+0x30>
  if(neg)
 5de:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 5e1:	85 c0                	test   %eax,%eax
 5e3:	74 07                	je     5ec <printint+0x5c>
    buf[i++] = '-';
 5e5:	c6 44 35 d8 2d       	movb   $0x2d,-0x28(%ebp,%esi,1)

  while(--i >= 0)
 5ea:	89 f7                	mov    %esi,%edi
 5ec:	8d 5d d8             	lea    -0x28(%ebp),%ebx
 5ef:	8b 75 c0             	mov    -0x40(%ebp),%esi
 5f2:	01 df                	add    %ebx,%edi
 5f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    putc(fd, buf[i]);
 5f8:	0f b6 07             	movzbl (%edi),%eax
  write(fd, &c, 1);
 5fb:	83 ec 04             	sub    $0x4,%esp
 5fe:	88 45 d7             	mov    %al,-0x29(%ebp)
 601:	8d 45 d7             	lea    -0x29(%ebp),%eax
 604:	6a 01                	push   $0x1
 606:	50                   	push   %eax
 607:	56                   	push   %esi
 608:	e8 e6 fe ff ff       	call   4f3 <write>
  while(--i >= 0)
 60d:	89 f8                	mov    %edi,%eax
 60f:	83 c4 10             	add    $0x10,%esp
 612:	83 ef 01             	sub    $0x1,%edi
 615:	39 c3                	cmp    %eax,%ebx
 617:	75 df                	jne    5f8 <printint+0x68>
}
 619:	8d 65 f4             	lea    -0xc(%ebp),%esp
 61c:	5b                   	pop    %ebx
 61d:	5e                   	pop    %esi
 61e:	5f                   	pop    %edi
 61f:	5d                   	pop    %ebp
 620:	c3                   	ret
 621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 628:	31 c0                	xor    %eax,%eax
 62a:	eb 89                	jmp    5b5 <printint+0x25>
 62c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000630 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 630:	55                   	push   %ebp
 631:	89 e5                	mov    %esp,%ebp
 633:	57                   	push   %edi
 634:	56                   	push   %esi
 635:	53                   	push   %ebx
 636:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 639:	8b 75 0c             	mov    0xc(%ebp),%esi
{
 63c:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i = 0; fmt[i]; i++){
 63f:	0f b6 1e             	movzbl (%esi),%ebx
 642:	83 c6 01             	add    $0x1,%esi
 645:	84 db                	test   %bl,%bl
 647:	74 67                	je     6b0 <printf+0x80>
 649:	8d 4d 10             	lea    0x10(%ebp),%ecx
 64c:	31 d2                	xor    %edx,%edx
 64e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
 651:	eb 34                	jmp    687 <printf+0x57>
 653:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 657:	90                   	nop
 658:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 65b:	ba 25 00 00 00       	mov    $0x25,%edx
      if(c == '%'){
 660:	83 f8 25             	cmp    $0x25,%eax
 663:	74 18                	je     67d <printf+0x4d>
  write(fd, &c, 1);
 665:	83 ec 04             	sub    $0x4,%esp
 668:	8d 45 e7             	lea    -0x19(%ebp),%eax
 66b:	88 5d e7             	mov    %bl,-0x19(%ebp)
 66e:	6a 01                	push   $0x1
 670:	50                   	push   %eax
 671:	57                   	push   %edi
 672:	e8 7c fe ff ff       	call   4f3 <write>
 677:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      } else {
        putc(fd, c);
 67a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 67d:	0f b6 1e             	movzbl (%esi),%ebx
 680:	83 c6 01             	add    $0x1,%esi
 683:	84 db                	test   %bl,%bl
 685:	74 29                	je     6b0 <printf+0x80>
    c = fmt[i] & 0xff;
 687:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 68a:	85 d2                	test   %edx,%edx
 68c:	74 ca                	je     658 <printf+0x28>
      }
    } else if(state == '%'){
 68e:	83 fa 25             	cmp    $0x25,%edx
 691:	75 ea                	jne    67d <printf+0x4d>
      if(c == 'd'){
 693:	83 f8 25             	cmp    $0x25,%eax
 696:	0f 84 04 01 00 00    	je     7a0 <printf+0x170>
 69c:	83 e8 63             	sub    $0x63,%eax
 69f:	83 f8 15             	cmp    $0x15,%eax
 6a2:	77 1c                	ja     6c0 <printf+0x90>
 6a4:	ff 24 85 d4 0a 00 00 	jmp    *0xad4(,%eax,4)
 6ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6af:	90                   	nop
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6b3:	5b                   	pop    %ebx
 6b4:	5e                   	pop    %esi
 6b5:	5f                   	pop    %edi
 6b6:	5d                   	pop    %ebp
 6b7:	c3                   	ret
 6b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 6bf:	90                   	nop
  write(fd, &c, 1);
 6c0:	83 ec 04             	sub    $0x4,%esp
 6c3:	8d 55 e7             	lea    -0x19(%ebp),%edx
 6c6:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 6ca:	6a 01                	push   $0x1
 6cc:	52                   	push   %edx
 6cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6d0:	57                   	push   %edi
 6d1:	e8 1d fe ff ff       	call   4f3 <write>
 6d6:	83 c4 0c             	add    $0xc,%esp
 6d9:	88 5d e7             	mov    %bl,-0x19(%ebp)
 6dc:	6a 01                	push   $0x1
 6de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 6e1:	52                   	push   %edx
 6e2:	57                   	push   %edi
 6e3:	e8 0b fe ff ff       	call   4f3 <write>
        putc(fd, c);
 6e8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6eb:	31 d2                	xor    %edx,%edx
 6ed:	eb 8e                	jmp    67d <printf+0x4d>
 6ef:	90                   	nop
        printint(fd, *ap, 16, 0);
 6f0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 6f3:	83 ec 0c             	sub    $0xc,%esp
 6f6:	b9 10 00 00 00       	mov    $0x10,%ecx
 6fb:	8b 13                	mov    (%ebx),%edx
 6fd:	6a 00                	push   $0x0
 6ff:	89 f8                	mov    %edi,%eax
        ap++;
 701:	83 c3 04             	add    $0x4,%ebx
        printint(fd, *ap, 16, 0);
 704:	e8 87 fe ff ff       	call   590 <printint>
        ap++;
 709:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 70c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 70f:	31 d2                	xor    %edx,%edx
 711:	e9 67 ff ff ff       	jmp    67d <printf+0x4d>
        s = (char*)*ap;
 716:	8b 45 d0             	mov    -0x30(%ebp),%eax
 719:	8b 18                	mov    (%eax),%ebx
        ap++;
 71b:	83 c0 04             	add    $0x4,%eax
 71e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 721:	85 db                	test   %ebx,%ebx
 723:	0f 84 87 00 00 00    	je     7b0 <printf+0x180>
        while(*s != 0){
 729:	0f b6 03             	movzbl (%ebx),%eax
      state = 0;
 72c:	31 d2                	xor    %edx,%edx
        while(*s != 0){
 72e:	84 c0                	test   %al,%al
 730:	0f 84 47 ff ff ff    	je     67d <printf+0x4d>
 736:	8d 55 e7             	lea    -0x19(%ebp),%edx
 739:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 73c:	89 de                	mov    %ebx,%esi
 73e:	89 d3                	mov    %edx,%ebx
  write(fd, &c, 1);
 740:	83 ec 04             	sub    $0x4,%esp
 743:	88 45 e7             	mov    %al,-0x19(%ebp)
          s++;
 746:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 749:	6a 01                	push   $0x1
 74b:	53                   	push   %ebx
 74c:	57                   	push   %edi
 74d:	e8 a1 fd ff ff       	call   4f3 <write>
        while(*s != 0){
 752:	0f b6 06             	movzbl (%esi),%eax
 755:	83 c4 10             	add    $0x10,%esp
 758:	84 c0                	test   %al,%al
 75a:	75 e4                	jne    740 <printf+0x110>
      state = 0;
 75c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
 75f:	31 d2                	xor    %edx,%edx
 761:	e9 17 ff ff ff       	jmp    67d <printf+0x4d>
        printint(fd, *ap, 10, 1);
 766:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 769:	83 ec 0c             	sub    $0xc,%esp
 76c:	b9 0a 00 00 00       	mov    $0xa,%ecx
 771:	8b 13                	mov    (%ebx),%edx
 773:	6a 01                	push   $0x1
 775:	eb 88                	jmp    6ff <printf+0xcf>
        putc(fd, *ap);
 777:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  write(fd, &c, 1);
 77a:	83 ec 04             	sub    $0x4,%esp
 77d:	8d 55 e7             	lea    -0x19(%ebp),%edx
        putc(fd, *ap);
 780:	8b 03                	mov    (%ebx),%eax
        ap++;
 782:	83 c3 04             	add    $0x4,%ebx
        putc(fd, *ap);
 785:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 788:	6a 01                	push   $0x1
 78a:	52                   	push   %edx
 78b:	57                   	push   %edi
 78c:	e8 62 fd ff ff       	call   4f3 <write>
        ap++;
 791:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 794:	83 c4 10             	add    $0x10,%esp
      state = 0;
 797:	31 d2                	xor    %edx,%edx
 799:	e9 df fe ff ff       	jmp    67d <printf+0x4d>
 79e:	66 90                	xchg   %ax,%ax
  write(fd, &c, 1);
 7a0:	83 ec 04             	sub    $0x4,%esp
 7a3:	88 5d e7             	mov    %bl,-0x19(%ebp)
 7a6:	8d 55 e7             	lea    -0x19(%ebp),%edx
 7a9:	6a 01                	push   $0x1
 7ab:	e9 31 ff ff ff       	jmp    6e1 <printf+0xb1>
 7b0:	b8 28 00 00 00       	mov    $0x28,%eax
          s = "(null)";
 7b5:	bb d6 09 00 00       	mov    $0x9d6,%ebx
 7ba:	e9 77 ff ff ff       	jmp    736 <printf+0x106>
 7bf:	90                   	nop

000007c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c1:	a1 40 0b 00 00       	mov    0xb40,%eax
{
 7c6:	89 e5                	mov    %esp,%ebp
 7c8:	57                   	push   %edi
 7c9:	56                   	push   %esi
 7ca:	53                   	push   %ebx
 7cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 7ce:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d8:	8b 10                	mov    (%eax),%edx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	39 c8                	cmp    %ecx,%eax
 7dc:	73 32                	jae    810 <free+0x50>
 7de:	39 d1                	cmp    %edx,%ecx
 7e0:	72 04                	jb     7e6 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e2:	39 d0                	cmp    %edx,%eax
 7e4:	72 32                	jb     818 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 7e9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 7ec:	39 fa                	cmp    %edi,%edx
 7ee:	74 30                	je     820 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7f0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7f3:	8b 50 04             	mov    0x4(%eax),%edx
 7f6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7f9:	39 f1                	cmp    %esi,%ecx
 7fb:	74 3a                	je     837 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7fd:	89 08                	mov    %ecx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
}
 7ff:	5b                   	pop    %ebx
  freep = p;
 800:	a3 40 0b 00 00       	mov    %eax,0xb40
}
 805:	5e                   	pop    %esi
 806:	5f                   	pop    %edi
 807:	5d                   	pop    %ebp
 808:	c3                   	ret
 809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	39 d0                	cmp    %edx,%eax
 812:	72 04                	jb     818 <free+0x58>
 814:	39 d1                	cmp    %edx,%ecx
 816:	72 ce                	jb     7e6 <free+0x26>
{
 818:	89 d0                	mov    %edx,%eax
 81a:	eb bc                	jmp    7d8 <free+0x18>
 81c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 820:	03 72 04             	add    0x4(%edx),%esi
 823:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 826:	8b 10                	mov    (%eax),%edx
 828:	8b 12                	mov    (%edx),%edx
 82a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 82d:	8b 50 04             	mov    0x4(%eax),%edx
 830:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 833:	39 f1                	cmp    %esi,%ecx
 835:	75 c6                	jne    7fd <free+0x3d>
    p->s.size += bp->s.size;
 837:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 83a:	a3 40 0b 00 00       	mov    %eax,0xb40
    p->s.size += bp->s.size;
 83f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 842:	8b 4b f8             	mov    -0x8(%ebx),%ecx
 845:	89 08                	mov    %ecx,(%eax)
}
 847:	5b                   	pop    %ebx
 848:	5e                   	pop    %esi
 849:	5f                   	pop    %edi
 84a:	5d                   	pop    %ebp
 84b:	c3                   	ret
 84c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000850 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 850:	55                   	push   %ebp
 851:	89 e5                	mov    %esp,%ebp
 853:	57                   	push   %edi
 854:	56                   	push   %esi
 855:	53                   	push   %ebx
 856:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 859:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 85c:	8b 15 40 0b 00 00    	mov    0xb40,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 862:	8d 78 07             	lea    0x7(%eax),%edi
 865:	c1 ef 03             	shr    $0x3,%edi
 868:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 86b:	85 d2                	test   %edx,%edx
 86d:	0f 84 8d 00 00 00    	je     900 <malloc+0xb0>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 873:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 875:	8b 48 04             	mov    0x4(%eax),%ecx
 878:	39 f9                	cmp    %edi,%ecx
 87a:	73 64                	jae    8e0 <malloc+0x90>
  if(nu < 4096)
 87c:	bb 00 10 00 00       	mov    $0x1000,%ebx
 881:	39 df                	cmp    %ebx,%edi
 883:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 886:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 88d:	eb 0a                	jmp    899 <malloc+0x49>
 88f:	90                   	nop
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 892:	8b 48 04             	mov    0x4(%eax),%ecx
 895:	39 f9                	cmp    %edi,%ecx
 897:	73 47                	jae    8e0 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 899:	89 c2                	mov    %eax,%edx
 89b:	3b 05 40 0b 00 00    	cmp    0xb40,%eax
 8a1:	75 ed                	jne    890 <malloc+0x40>
  p = sbrk(nu * sizeof(Header));
 8a3:	83 ec 0c             	sub    $0xc,%esp
 8a6:	56                   	push   %esi
 8a7:	e8 af fc ff ff       	call   55b <sbrk>
  if(p == (char*)-1)
 8ac:	83 c4 10             	add    $0x10,%esp
 8af:	83 f8 ff             	cmp    $0xffffffff,%eax
 8b2:	74 1c                	je     8d0 <malloc+0x80>
  hp->s.size = nu;
 8b4:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 8b7:	83 ec 0c             	sub    $0xc,%esp
 8ba:	83 c0 08             	add    $0x8,%eax
 8bd:	50                   	push   %eax
 8be:	e8 fd fe ff ff       	call   7c0 <free>
  return freep;
 8c3:	8b 15 40 0b 00 00    	mov    0xb40,%edx
      if((p = morecore(nunits)) == 0)
 8c9:	83 c4 10             	add    $0x10,%esp
 8cc:	85 d2                	test   %edx,%edx
 8ce:	75 c0                	jne    890 <malloc+0x40>
        return 0;
  }
}
 8d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 8d3:	31 c0                	xor    %eax,%eax
}
 8d5:	5b                   	pop    %ebx
 8d6:	5e                   	pop    %esi
 8d7:	5f                   	pop    %edi
 8d8:	5d                   	pop    %ebp
 8d9:	c3                   	ret
 8da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 8e0:	39 cf                	cmp    %ecx,%edi
 8e2:	74 4c                	je     930 <malloc+0xe0>
        p->s.size -= nunits;
 8e4:	29 f9                	sub    %edi,%ecx
 8e6:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 8e9:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 8ec:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 8ef:	89 15 40 0b 00 00    	mov    %edx,0xb40
}
 8f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 8f8:	83 c0 08             	add    $0x8,%eax
}
 8fb:	5b                   	pop    %ebx
 8fc:	5e                   	pop    %esi
 8fd:	5f                   	pop    %edi
 8fe:	5d                   	pop    %ebp
 8ff:	c3                   	ret
    base.s.ptr = freep = prevp = &base;
 900:	c7 05 40 0b 00 00 44 	movl   $0xb44,0xb40
 907:	0b 00 00 
    base.s.size = 0;
 90a:	b8 44 0b 00 00       	mov    $0xb44,%eax
    base.s.ptr = freep = prevp = &base;
 90f:	c7 05 44 0b 00 00 44 	movl   $0xb44,0xb44
 916:	0b 00 00 
    base.s.size = 0;
 919:	c7 05 48 0b 00 00 00 	movl   $0x0,0xb48
 920:	00 00 00 
    if(p->s.size >= nunits){
 923:	e9 54 ff ff ff       	jmp    87c <malloc+0x2c>
 928:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 92f:	90                   	nop
        prevp->s.ptr = p->s.ptr;
 930:	8b 08                	mov    (%eax),%ecx
 932:	89 0a                	mov    %ecx,(%edx)
 934:	eb b9                	jmp    8ef <malloc+0x9f>
