
_testcow1:     file format elf32-i386


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
  11:	68 30 0a 00 00       	push   $0xa30
  16:	6a 01                	push   $0x1
  18:	e8 a3 05 00 00       	call   5c0 <printf>
	test();
  1d:	e8 0e 00 00 00       	call   30 <test>
  22:	66 90                	xchg   %ax,%ax
  24:	66 90                	xchg   %ax,%ax
  26:	66 90                	xchg   %ax,%ax
  28:	66 90                	xchg   %ax,%ax
  2a:	66 90                	xchg   %ax,%ax
  2c:	66 90                	xchg   %ax,%ax
  2e:	66 90                	xchg   %ax,%ax

00000030 <test>:
{
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	57                   	push   %edi
    long long size = ((prev_free_pages - 20) * 4096); // 20 pages will be used by kernel to create kstack, and process related datastructures.
  34:	31 ff                	xor    %edi,%edi
{
  36:	56                   	push   %esi
  37:	53                   	push   %ebx
  38:	83 ec 1c             	sub    $0x1c,%esp
    uint prev_free_pages = getNumFreePages();
  3b:	e8 cb 04 00 00       	call   50b <getNumFreePages>
    printf(1, "Allocating %d bytes for each process\n", prev_free_pages);
  40:	83 ec 04             	sub    $0x4,%esp
  43:	50                   	push   %eax
  44:	68 c8 08 00 00       	push   $0x8c8
  49:	6a 01                	push   $0x1
  4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  4e:	e8 6d 05 00 00       	call   5c0 <printf>
    long long size = ((prev_free_pages - 20) * 4096); // 20 pages will be used by kernel to create kstack, and process related datastructures.
  53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    printf(1, "Allocating %d bytes for each process\n", size);
  56:	57                   	push   %edi
    long long size = ((prev_free_pages - 20) * 4096); // 20 pages will be used by kernel to create kstack, and process related datastructures.
  57:	8d 5a ec             	lea    -0x14(%edx),%ebx
  5a:	89 55 d8             	mov    %edx,-0x28(%ebp)
  5d:	c1 e3 0c             	shl    $0xc,%ebx
    printf(1, "Allocating %d bytes for each process\n", size);
  60:	53                   	push   %ebx
  61:	68 c8 08 00 00       	push   $0x8c8
  66:	6a 01                	push   $0x1
  68:	e8 53 05 00 00       	call   5c0 <printf>
    char *m1 = (char*)malloc(size);
  6d:	83 c4 14             	add    $0x14,%esp
  70:	53                   	push   %ebx
  71:	e8 6a 07 00 00       	call   7e0 <malloc>
    printf(1, "Allocating %d %d bytes for each process\n", size,curr_free_pages);
  76:	8b 55 d8             	mov    -0x28(%ebp),%edx
    char *m1 = (char*)malloc(size);
  79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    printf(1, "Allocating %d %d bytes for each process\n", size,curr_free_pages);
  7c:	89 14 24             	mov    %edx,(%esp)
  7f:	57                   	push   %edi
  80:	53                   	push   %ebx
  81:	68 f0 08 00 00       	push   $0x8f0
  86:	6a 01                	push   $0x1
  88:	e8 33 05 00 00       	call   5c0 <printf>
    if (m1 == 0) goto out_of_memory;
  8d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  90:	83 c4 20             	add    $0x20,%esp
  93:	85 f6                	test   %esi,%esi
  95:	0f 84 69 01 00 00    	je     204 <test+0x1d4>
    for(int k=0;k<size;++k){
  9b:	89 d8                	mov    %ebx,%eax
  9d:	31 c9                	xor    %ecx,%ecx
  9f:	89 de                	mov    %ebx,%esi
  a1:	09 f8                	or     %edi,%eax
  a3:	74 2d                	je     d2 <test+0xa2>
  a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  a8:	89 7d dc             	mov    %edi,-0x24(%ebp)
  ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        m1[k] = (char)(65+(k%26));
  ae:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
  b3:	f7 e1                	mul    %ecx
  b5:	c1 ea 03             	shr    $0x3,%edx
  b8:	6b c2 1a             	imul   $0x1a,%edx,%eax
  bb:	89 ca                	mov    %ecx,%edx
  bd:	29 c2                	sub    %eax,%edx
  bf:	83 c2 41             	add    $0x41,%edx
  c2:	88 14 0f             	mov    %dl,(%edi,%ecx,1)
    for(int k=0;k<size;++k){
  c5:	83 c1 01             	add    $0x1,%ecx
  c8:	39 cb                	cmp    %ecx,%ebx
  ca:	75 e2                	jne    ae <test+0x7e>
  cc:	8b 75 d8             	mov    -0x28(%ebp),%esi
  cf:	8b 7d dc             	mov    -0x24(%ebp),%edi
    printf(1, "\n*** Forking ***\n");
  d2:	83 ec 08             	sub    $0x8,%esp
  d5:	68 ce 09 00 00       	push   $0x9ce
  da:	6a 01                	push   $0x1
  dc:	e8 df 04 00 00       	call   5c0 <printf>
    pid = fork();
  e1:	e8 75 03 00 00       	call   45b <fork>
    if (pid < 0) goto fork_failed; // Fork failed
  e6:	83 c4 10             	add    $0x10,%esp
  e9:	85 c0                	test   %eax,%eax
  eb:	0f 88 1f 01 00 00    	js     210 <test+0x1e0>
    if (pid == 0) { // Child process
  f1:	75 7c                	jne    16f <test+0x13f>
        printf(1, "\n*** Child ***\n");
  f3:	50                   	push   %eax
  f4:	50                   	push   %eax
  f5:	68 fb 09 00 00       	push   $0x9fb
  fa:	6a 01                	push   $0x1
  fc:	e8 bf 04 00 00       	call   5c0 <printf>
        for(int k=0;k<size;++k){
 101:	83 c4 10             	add    $0x10,%esp
 104:	85 db                	test   %ebx,%ebx
 106:	0f 84 b8 00 00 00    	je     1c4 <test+0x194>
			if(m1[k] != (char)(65+(k%26))) goto failed;
 10c:	89 75 d8             	mov    %esi,-0x28(%ebp)
        for(int k=0;k<size;++k){
 10f:	31 c9                	xor    %ecx,%ecx
 111:	31 db                	xor    %ebx,%ebx
			if(m1[k] != (char)(65+(k%26))) goto failed;
 113:	89 7d dc             	mov    %edi,-0x24(%ebp)
 116:	eb 18                	jmp    130 <test+0x100>
        for(int k=0;k<size;++k){
 118:	83 c1 01             	add    $0x1,%ecx
 11b:	8b 45 d8             	mov    -0x28(%ebp),%eax
 11e:	8b 55 dc             	mov    -0x24(%ebp),%edx
 121:	83 d3 00             	adc    $0x0,%ebx
 124:	89 de                	mov    %ebx,%esi
 126:	39 c1                	cmp    %eax,%ecx
 128:	19 d6                	sbb    %edx,%esi
 12a:	0f 8d 94 00 00 00    	jge    1c4 <test+0x194>
			if(m1[k] != (char)(65+(k%26))) goto failed;
 130:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
 135:	f7 e1                	mul    %ecx
 137:	89 d0                	mov    %edx,%eax
 139:	89 ca                	mov    %ecx,%edx
 13b:	c1 e8 03             	shr    $0x3,%eax
 13e:	6b c0 1a             	imul   $0x1a,%eax,%eax
 141:	29 c2                	sub    %eax,%edx
 143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 146:	83 c2 41             	add    $0x41,%edx
 149:	38 14 08             	cmp    %dl,(%eax,%ecx,1)
 14c:	74 ca                	je     118 <test+0xe8>
    printf(1, "Copy failed: The memory contents of the processes is inconsistent!\n");
 14e:	50                   	push   %eax
 14f:	50                   	push   %eax
 150:	68 60 09 00 00       	push   $0x960
	printf(1, "Failed to fork a process!\n");
 155:	6a 01                	push   $0x1
 157:	e8 64 04 00 00       	call   5c0 <printf>
    printf(1, "Lab5 test failed!\n");
 15c:	58                   	pop    %eax
 15d:	5a                   	pop    %edx
 15e:	68 bb 09 00 00       	push   $0x9bb
 163:	6a 01                	push   $0x1
 165:	e8 56 04 00 00       	call   5c0 <printf>
	exit();
 16a:	e8 f4 02 00 00       	call   463 <exit>
        printf(1, "\n*** Parent ***\n");
 16f:	50                   	push   %eax
 170:	50                   	push   %eax
 171:	68 0b 0a 00 00       	push   $0xa0b
 176:	6a 01                	push   $0x1
 178:	e8 43 04 00 00       	call   5c0 <printf>
        for(int k=0;k<size;++k){
 17d:	83 c4 10             	add    $0x10,%esp
 180:	85 db                	test   %ebx,%ebx
 182:	74 56                	je     1da <test+0x1aa>
            if(m1[k] != (char)(65+(k%26))) goto failed;
 184:	89 75 d8             	mov    %esi,-0x28(%ebp)
        for(int k=0;k<size;++k){
 187:	31 c9                	xor    %ecx,%ecx
 189:	31 db                	xor    %ebx,%ebx
            if(m1[k] != (char)(65+(k%26))) goto failed;
 18b:	89 7d dc             	mov    %edi,-0x24(%ebp)
 18e:	eb 14                	jmp    1a4 <test+0x174>
        for(int k=0;k<size;++k){
 190:	83 c1 01             	add    $0x1,%ecx
 193:	8b 45 d8             	mov    -0x28(%ebp),%eax
 196:	8b 55 dc             	mov    -0x24(%ebp),%edx
 199:	83 d3 00             	adc    $0x0,%ebx
 19c:	89 de                	mov    %ebx,%esi
 19e:	39 c1                	cmp    %eax,%ecx
 1a0:	19 d6                	sbb    %edx,%esi
 1a2:	7d 36                	jge    1da <test+0x1aa>
            if(m1[k] != (char)(65+(k%26))) goto failed;
 1a4:	b8 4f ec c4 4e       	mov    $0x4ec4ec4f,%eax
 1a9:	f7 e1                	mul    %ecx
 1ab:	89 d0                	mov    %edx,%eax
 1ad:	89 ca                	mov    %ecx,%edx
 1af:	c1 e8 03             	shr    $0x3,%eax
 1b2:	6b c0 1a             	imul   $0x1a,%eax,%eax
 1b5:	29 c2                	sub    %eax,%edx
 1b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1ba:	83 c2 41             	add    $0x41,%edx
 1bd:	38 14 08             	cmp    %dl,(%eax,%ecx,1)
 1c0:	74 ce                	je     190 <test+0x160>
 1c2:	eb 8a                	jmp    14e <test+0x11e>
        printf(1, "[COW1] Lab5 Child test passed!\n");
 1c4:	50                   	push   %eax
 1c5:	50                   	push   %eax
 1c6:	68 1c 09 00 00       	push   $0x91c
 1cb:	6a 01                	push   $0x1
 1cd:	e8 ee 03 00 00       	call   5c0 <printf>
 1d2:	83 c4 10             	add    $0x10,%esp
    exit();
 1d5:	e8 89 02 00 00       	call   463 <exit>
        wait();
 1da:	e8 8c 02 00 00       	call   46b <wait>
        printf(1, "done processing %d\n", x);
 1df:	52                   	push   %edx
 1e0:	68 ae ad 01 00       	push   $0x1adae
 1e5:	68 1c 0a 00 00       	push   $0xa1c
 1ea:	6a 01                	push   $0x1
 1ec:	e8 cf 03 00 00       	call   5c0 <printf>
        printf(1, "[COW1] Lab5 Parent test passed!\n");
 1f1:	59                   	pop    %ecx
 1f2:	5b                   	pop    %ebx
 1f3:	68 3c 09 00 00       	push   $0x93c
 1f8:	6a 01                	push   $0x1
 1fa:	e8 c1 03 00 00       	call   5c0 <printf>
 1ff:	83 c4 10             	add    $0x10,%esp
 202:	eb d1                	jmp    1d5 <test+0x1a5>
	printf(1, "Exceeded the PHYSTOP!\n");
 204:	53                   	push   %ebx
 205:	53                   	push   %ebx
 206:	68 a4 09 00 00       	push   $0x9a4
 20b:	e9 45 ff ff ff       	jmp    155 <test+0x125>
	printf(1, "Failed to fork a process!\n");
 210:	51                   	push   %ecx
 211:	51                   	push   %ecx
 212:	68 e0 09 00 00       	push   $0x9e0
 217:	e9 39 ff ff ff       	jmp    155 <test+0x125>
 21c:	66 90                	xchg   %ax,%ax
 21e:	66 90                	xchg   %ax,%ax

00000220 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 220:	55                   	push   %ebp
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 221:	31 c0                	xor    %eax,%eax
{
 223:	89 e5                	mov    %esp,%ebp
 225:	53                   	push   %ebx
 226:	8b 4d 08             	mov    0x8(%ebp),%ecx
 229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 22c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while((*s++ = *t++) != 0)
 230:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
 234:	88 14 01             	mov    %dl,(%ecx,%eax,1)
 237:	83 c0 01             	add    $0x1,%eax
 23a:	84 d2                	test   %dl,%dl
 23c:	75 f2                	jne    230 <strcpy+0x10>
    ;
  return os;
}
 23e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 241:	89 c8                	mov    %ecx,%eax
 243:	c9                   	leave
 244:	c3                   	ret
 245:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 24c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000250 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	53                   	push   %ebx
 254:	8b 55 08             	mov    0x8(%ebp),%edx
 257:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 25a:	0f b6 02             	movzbl (%edx),%eax
 25d:	84 c0                	test   %al,%al
 25f:	75 17                	jne    278 <strcmp+0x28>
 261:	eb 3a                	jmp    29d <strcmp+0x4d>
 263:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 267:	90                   	nop
 268:	0f b6 42 01          	movzbl 0x1(%edx),%eax
    p++, q++;
 26c:	83 c2 01             	add    $0x1,%edx
 26f:	8d 59 01             	lea    0x1(%ecx),%ebx
  while(*p && *p == *q)
 272:	84 c0                	test   %al,%al
 274:	74 1a                	je     290 <strcmp+0x40>
 276:	89 d9                	mov    %ebx,%ecx
 278:	0f b6 19             	movzbl (%ecx),%ebx
 27b:	38 c3                	cmp    %al,%bl
 27d:	74 e9                	je     268 <strcmp+0x18>
  return (uchar)*p - (uchar)*q;
 27f:	29 d8                	sub    %ebx,%eax
}
 281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 284:	c9                   	leave
 285:	c3                   	ret
 286:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 28d:	8d 76 00             	lea    0x0(%esi),%esi
  return (uchar)*p - (uchar)*q;
 290:	0f b6 59 01          	movzbl 0x1(%ecx),%ebx
 294:	31 c0                	xor    %eax,%eax
 296:	29 d8                	sub    %ebx,%eax
}
 298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 29b:	c9                   	leave
 29c:	c3                   	ret
  return (uchar)*p - (uchar)*q;
 29d:	0f b6 19             	movzbl (%ecx),%ebx
 2a0:	31 c0                	xor    %eax,%eax
 2a2:	eb db                	jmp    27f <strcmp+0x2f>
 2a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2af:	90                   	nop

000002b0 <strlen>:

uint
strlen(const char *s)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
 2b6:	80 3a 00             	cmpb   $0x0,(%edx)
 2b9:	74 15                	je     2d0 <strlen+0x20>
 2bb:	31 c0                	xor    %eax,%eax
 2bd:	8d 76 00             	lea    0x0(%esi),%esi
 2c0:	83 c0 01             	add    $0x1,%eax
 2c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
 2c7:	89 c1                	mov    %eax,%ecx
 2c9:	75 f5                	jne    2c0 <strlen+0x10>
    ;
  return n;
}
 2cb:	89 c8                	mov    %ecx,%eax
 2cd:	5d                   	pop    %ebp
 2ce:	c3                   	ret
 2cf:	90                   	nop
  for(n = 0; s[n]; n++)
 2d0:	31 c9                	xor    %ecx,%ecx
}
 2d2:	5d                   	pop    %ebp
 2d3:	89 c8                	mov    %ecx,%eax
 2d5:	c3                   	ret
 2d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2dd:	8d 76 00             	lea    0x0(%esi),%esi

000002e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	57                   	push   %edi
 2e4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 2e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ed:	89 d7                	mov    %edx,%edi
 2ef:	fc                   	cld
 2f0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2f2:	8b 7d fc             	mov    -0x4(%ebp),%edi
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	c9                   	leave
 2f8:	c3                   	ret
 2f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000300 <strchr>:

char*
strchr(const char *s, char c)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 30a:	0f b6 10             	movzbl (%eax),%edx
 30d:	84 d2                	test   %dl,%dl
 30f:	75 12                	jne    323 <strchr+0x23>
 311:	eb 1d                	jmp    330 <strchr+0x30>
 313:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 317:	90                   	nop
 318:	0f b6 50 01          	movzbl 0x1(%eax),%edx
 31c:	83 c0 01             	add    $0x1,%eax
 31f:	84 d2                	test   %dl,%dl
 321:	74 0d                	je     330 <strchr+0x30>
    if(*s == c)
 323:	38 d1                	cmp    %dl,%cl
 325:	75 f1                	jne    318 <strchr+0x18>
      return (char*)s;
  return 0;
}
 327:	5d                   	pop    %ebp
 328:	c3                   	ret
 329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return 0;
 330:	31 c0                	xor    %eax,%eax
}
 332:	5d                   	pop    %ebp
 333:	c3                   	ret
 334:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 33b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 33f:	90                   	nop

00000340 <gets>:

char*
gets(char *buf, int max)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	57                   	push   %edi
 344:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
 345:	8d 75 e7             	lea    -0x19(%ebp),%esi
{
 348:	53                   	push   %ebx
  for(i=0; i+1 < max; ){
 349:	31 db                	xor    %ebx,%ebx
{
 34b:	83 ec 1c             	sub    $0x1c,%esp
  for(i=0; i+1 < max; ){
 34e:	eb 27                	jmp    377 <gets+0x37>
    cc = read(0, &c, 1);
 350:	83 ec 04             	sub    $0x4,%esp
 353:	6a 01                	push   $0x1
 355:	56                   	push   %esi
 356:	6a 00                	push   $0x0
 358:	e8 1e 01 00 00       	call   47b <read>
    if(cc < 1)
 35d:	83 c4 10             	add    $0x10,%esp
 360:	85 c0                	test   %eax,%eax
 362:	7e 1d                	jle    381 <gets+0x41>
      break;
    buf[i++] = c;
 364:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 368:	8b 55 08             	mov    0x8(%ebp),%edx
 36b:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
    if(c == '\n' || c == '\r')
 36f:	3c 0a                	cmp    $0xa,%al
 371:	74 10                	je     383 <gets+0x43>
 373:	3c 0d                	cmp    $0xd,%al
 375:	74 0c                	je     383 <gets+0x43>
  for(i=0; i+1 < max; ){
 377:	89 df                	mov    %ebx,%edi
 379:	83 c3 01             	add    $0x1,%ebx
 37c:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 37f:	7c cf                	jl     350 <gets+0x10>
 381:	89 fb                	mov    %edi,%ebx
      break;
  }
  buf[i] = '\0';
 383:	8b 45 08             	mov    0x8(%ebp),%eax
 386:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 38a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 38d:	5b                   	pop    %ebx
 38e:	5e                   	pop    %esi
 38f:	5f                   	pop    %edi
 390:	5d                   	pop    %ebp
 391:	c3                   	ret
 392:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000003a0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	56                   	push   %esi
 3a4:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a5:	83 ec 08             	sub    $0x8,%esp
 3a8:	6a 00                	push   $0x0
 3aa:	ff 75 08             	push   0x8(%ebp)
 3ad:	e8 f1 00 00 00       	call   4a3 <open>
  if(fd < 0)
 3b2:	83 c4 10             	add    $0x10,%esp
 3b5:	85 c0                	test   %eax,%eax
 3b7:	78 27                	js     3e0 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 3b9:	83 ec 08             	sub    $0x8,%esp
 3bc:	ff 75 0c             	push   0xc(%ebp)
 3bf:	89 c3                	mov    %eax,%ebx
 3c1:	50                   	push   %eax
 3c2:	e8 f4 00 00 00       	call   4bb <fstat>
  close(fd);
 3c7:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 3ca:	89 c6                	mov    %eax,%esi
  close(fd);
 3cc:	e8 ba 00 00 00       	call   48b <close>
  return r;
 3d1:	83 c4 10             	add    $0x10,%esp
}
 3d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
 3d7:	89 f0                	mov    %esi,%eax
 3d9:	5b                   	pop    %ebx
 3da:	5e                   	pop    %esi
 3db:	5d                   	pop    %ebp
 3dc:	c3                   	ret
 3dd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 3e0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 3e5:	eb ed                	jmp    3d4 <stat+0x34>
 3e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 3ee:	66 90                	xchg   %ax,%ax

000003f0 <atoi>:

int
atoi(const char *s)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	53                   	push   %ebx
 3f4:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f7:	0f be 02             	movsbl (%edx),%eax
 3fa:	8d 48 d0             	lea    -0x30(%eax),%ecx
 3fd:	80 f9 09             	cmp    $0x9,%cl
  n = 0;
 400:	b9 00 00 00 00       	mov    $0x0,%ecx
  while('0' <= *s && *s <= '9')
 405:	77 1e                	ja     425 <atoi+0x35>
 407:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 40e:	66 90                	xchg   %ax,%ax
    n = n*10 + *s++ - '0';
 410:	83 c2 01             	add    $0x1,%edx
 413:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
 416:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
  while('0' <= *s && *s <= '9')
 41a:	0f be 02             	movsbl (%edx),%eax
 41d:	8d 58 d0             	lea    -0x30(%eax),%ebx
 420:	80 fb 09             	cmp    $0x9,%bl
 423:	76 eb                	jbe    410 <atoi+0x20>
  return n;
}
 425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 428:	89 c8                	mov    %ecx,%eax
 42a:	c9                   	leave
 42b:	c3                   	ret
 42c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000430 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	57                   	push   %edi
 434:	8b 45 10             	mov    0x10(%ebp),%eax
 437:	8b 55 08             	mov    0x8(%ebp),%edx
 43a:	56                   	push   %esi
 43b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 43e:	85 c0                	test   %eax,%eax
 440:	7e 13                	jle    455 <memmove+0x25>
 442:	01 d0                	add    %edx,%eax
  dst = vdst;
 444:	89 d7                	mov    %edx,%edi
 446:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 44d:	8d 76 00             	lea    0x0(%esi),%esi
    *dst++ = *src++;
 450:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 451:	39 f8                	cmp    %edi,%eax
 453:	75 fb                	jne    450 <memmove+0x20>
  return vdst;
}
 455:	5e                   	pop    %esi
 456:	89 d0                	mov    %edx,%eax
 458:	5f                   	pop    %edi
 459:	5d                   	pop    %ebp
 45a:	c3                   	ret

0000045b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 45b:	b8 01 00 00 00       	mov    $0x1,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret

00000463 <exit>:
SYSCALL(exit)
 463:	b8 02 00 00 00       	mov    $0x2,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret

0000046b <wait>:
SYSCALL(wait)
 46b:	b8 03 00 00 00       	mov    $0x3,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret

00000473 <pipe>:
SYSCALL(pipe)
 473:	b8 04 00 00 00       	mov    $0x4,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret

0000047b <read>:
SYSCALL(read)
 47b:	b8 05 00 00 00       	mov    $0x5,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret

00000483 <write>:
SYSCALL(write)
 483:	b8 10 00 00 00       	mov    $0x10,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret

0000048b <close>:
SYSCALL(close)
 48b:	b8 15 00 00 00       	mov    $0x15,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret

00000493 <kill>:
SYSCALL(kill)
 493:	b8 06 00 00 00       	mov    $0x6,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret

0000049b <exec>:
SYSCALL(exec)
 49b:	b8 07 00 00 00       	mov    $0x7,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret

000004a3 <open>:
SYSCALL(open)
 4a3:	b8 0f 00 00 00       	mov    $0xf,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret

000004ab <mknod>:
SYSCALL(mknod)
 4ab:	b8 11 00 00 00       	mov    $0x11,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret

000004b3 <unlink>:
SYSCALL(unlink)
 4b3:	b8 12 00 00 00       	mov    $0x12,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret

000004bb <fstat>:
SYSCALL(fstat)
 4bb:	b8 08 00 00 00       	mov    $0x8,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret

000004c3 <link>:
SYSCALL(link)
 4c3:	b8 13 00 00 00       	mov    $0x13,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret

000004cb <mkdir>:
SYSCALL(mkdir)
 4cb:	b8 14 00 00 00       	mov    $0x14,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret

000004d3 <chdir>:
SYSCALL(chdir)
 4d3:	b8 09 00 00 00       	mov    $0x9,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret

000004db <dup>:
SYSCALL(dup)
 4db:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret

000004e3 <getpid>:
SYSCALL(getpid)
 4e3:	b8 0b 00 00 00       	mov    $0xb,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret

000004eb <sbrk>:
SYSCALL(sbrk)
 4eb:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret

000004f3 <sleep>:
SYSCALL(sleep)
 4f3:	b8 0d 00 00 00       	mov    $0xd,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret

000004fb <uptime>:
SYSCALL(uptime)
 4fb:	b8 0e 00 00 00       	mov    $0xe,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret

00000503 <getrss>:
SYSCALL(getrss)
 503:	b8 16 00 00 00       	mov    $0x16,%eax
 508:	cd 40                	int    $0x40
 50a:	c3                   	ret

0000050b <getNumFreePages>:
 50b:	b8 17 00 00 00       	mov    $0x17,%eax
 510:	cd 40                	int    $0x40
 512:	c3                   	ret
 513:	66 90                	xchg   %ax,%ax
 515:	66 90                	xchg   %ax,%ax
 517:	66 90                	xchg   %ax,%ax
 519:	66 90                	xchg   %ax,%ax
 51b:	66 90                	xchg   %ax,%ax
 51d:	66 90                	xchg   %ax,%ax
 51f:	90                   	nop

00000520 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	57                   	push   %edi
 524:	56                   	push   %esi
 525:	53                   	push   %ebx
 526:	89 cb                	mov    %ecx,%ebx
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 528:	89 d1                	mov    %edx,%ecx
{
 52a:	83 ec 3c             	sub    $0x3c,%esp
 52d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  if(sgn && xx < 0){
 530:	85 d2                	test   %edx,%edx
 532:	0f 89 80 00 00 00    	jns    5b8 <printint+0x98>
 538:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 53c:	74 7a                	je     5b8 <printint+0x98>
    x = -xx;
 53e:	f7 d9                	neg    %ecx
    neg = 1;
 540:	b8 01 00 00 00       	mov    $0x1,%eax
  } else {
    x = xx;
  }

  i = 0;
 545:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 548:	31 f6                	xor    %esi,%esi
 54a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
 550:	89 c8                	mov    %ecx,%eax
 552:	31 d2                	xor    %edx,%edx
 554:	89 f7                	mov    %esi,%edi
 556:	f7 f3                	div    %ebx
 558:	8d 76 01             	lea    0x1(%esi),%esi
 55b:	0f b6 92 a4 0a 00 00 	movzbl 0xaa4(%edx),%edx
 562:	88 54 35 d7          	mov    %dl,-0x29(%ebp,%esi,1)
  }while((x /= base) != 0);
 566:	89 ca                	mov    %ecx,%edx
 568:	89 c1                	mov    %eax,%ecx
 56a:	39 da                	cmp    %ebx,%edx
 56c:	73 e2                	jae    550 <printint+0x30>
  if(neg)
 56e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 571:	85 c0                	test   %eax,%eax
 573:	74 07                	je     57c <printint+0x5c>
    buf[i++] = '-';
 575:	c6 44 35 d8 2d       	movb   $0x2d,-0x28(%ebp,%esi,1)

  while(--i >= 0)
 57a:	89 f7                	mov    %esi,%edi
 57c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
 57f:	8b 75 c0             	mov    -0x40(%ebp),%esi
 582:	01 df                	add    %ebx,%edi
 584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    putc(fd, buf[i]);
 588:	0f b6 07             	movzbl (%edi),%eax
  write(fd, &c, 1);
 58b:	83 ec 04             	sub    $0x4,%esp
 58e:	88 45 d7             	mov    %al,-0x29(%ebp)
 591:	8d 45 d7             	lea    -0x29(%ebp),%eax
 594:	6a 01                	push   $0x1
 596:	50                   	push   %eax
 597:	56                   	push   %esi
 598:	e8 e6 fe ff ff       	call   483 <write>
  while(--i >= 0)
 59d:	89 f8                	mov    %edi,%eax
 59f:	83 c4 10             	add    $0x10,%esp
 5a2:	83 ef 01             	sub    $0x1,%edi
 5a5:	39 c3                	cmp    %eax,%ebx
 5a7:	75 df                	jne    588 <printint+0x68>
}
 5a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5ac:	5b                   	pop    %ebx
 5ad:	5e                   	pop    %esi
 5ae:	5f                   	pop    %edi
 5af:	5d                   	pop    %ebp
 5b0:	c3                   	ret
 5b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 5b8:	31 c0                	xor    %eax,%eax
 5ba:	eb 89                	jmp    545 <printint+0x25>
 5bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000005c0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	57                   	push   %edi
 5c4:	56                   	push   %esi
 5c5:	53                   	push   %ebx
 5c6:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5c9:	8b 75 0c             	mov    0xc(%ebp),%esi
{
 5cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i = 0; fmt[i]; i++){
 5cf:	0f b6 1e             	movzbl (%esi),%ebx
 5d2:	83 c6 01             	add    $0x1,%esi
 5d5:	84 db                	test   %bl,%bl
 5d7:	74 67                	je     640 <printf+0x80>
 5d9:	8d 4d 10             	lea    0x10(%ebp),%ecx
 5dc:	31 d2                	xor    %edx,%edx
 5de:	89 4d d0             	mov    %ecx,-0x30(%ebp)
 5e1:	eb 34                	jmp    617 <printf+0x57>
 5e3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 5e7:	90                   	nop
 5e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 5eb:	ba 25 00 00 00       	mov    $0x25,%edx
      if(c == '%'){
 5f0:	83 f8 25             	cmp    $0x25,%eax
 5f3:	74 18                	je     60d <printf+0x4d>
  write(fd, &c, 1);
 5f5:	83 ec 04             	sub    $0x4,%esp
 5f8:	8d 45 e7             	lea    -0x19(%ebp),%eax
 5fb:	88 5d e7             	mov    %bl,-0x19(%ebp)
 5fe:	6a 01                	push   $0x1
 600:	50                   	push   %eax
 601:	57                   	push   %edi
 602:	e8 7c fe ff ff       	call   483 <write>
 607:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      } else {
        putc(fd, c);
 60a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 60d:	0f b6 1e             	movzbl (%esi),%ebx
 610:	83 c6 01             	add    $0x1,%esi
 613:	84 db                	test   %bl,%bl
 615:	74 29                	je     640 <printf+0x80>
    c = fmt[i] & 0xff;
 617:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 61a:	85 d2                	test   %edx,%edx
 61c:	74 ca                	je     5e8 <printf+0x28>
      }
    } else if(state == '%'){
 61e:	83 fa 25             	cmp    $0x25,%edx
 621:	75 ea                	jne    60d <printf+0x4d>
      if(c == 'd'){
 623:	83 f8 25             	cmp    $0x25,%eax
 626:	0f 84 04 01 00 00    	je     730 <printf+0x170>
 62c:	83 e8 63             	sub    $0x63,%eax
 62f:	83 f8 15             	cmp    $0x15,%eax
 632:	77 1c                	ja     650 <printf+0x90>
 634:	ff 24 85 4c 0a 00 00 	jmp    *0xa4c(,%eax,4)
 63b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 63f:	90                   	nop
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 640:	8d 65 f4             	lea    -0xc(%ebp),%esp
 643:	5b                   	pop    %ebx
 644:	5e                   	pop    %esi
 645:	5f                   	pop    %edi
 646:	5d                   	pop    %ebp
 647:	c3                   	ret
 648:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 64f:	90                   	nop
  write(fd, &c, 1);
 650:	83 ec 04             	sub    $0x4,%esp
 653:	8d 55 e7             	lea    -0x19(%ebp),%edx
 656:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 65a:	6a 01                	push   $0x1
 65c:	52                   	push   %edx
 65d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 660:	57                   	push   %edi
 661:	e8 1d fe ff ff       	call   483 <write>
 666:	83 c4 0c             	add    $0xc,%esp
 669:	88 5d e7             	mov    %bl,-0x19(%ebp)
 66c:	6a 01                	push   $0x1
 66e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 671:	52                   	push   %edx
 672:	57                   	push   %edi
 673:	e8 0b fe ff ff       	call   483 <write>
        putc(fd, c);
 678:	83 c4 10             	add    $0x10,%esp
      state = 0;
 67b:	31 d2                	xor    %edx,%edx
 67d:	eb 8e                	jmp    60d <printf+0x4d>
 67f:	90                   	nop
        printint(fd, *ap, 16, 0);
 680:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 683:	83 ec 0c             	sub    $0xc,%esp
 686:	b9 10 00 00 00       	mov    $0x10,%ecx
 68b:	8b 13                	mov    (%ebx),%edx
 68d:	6a 00                	push   $0x0
 68f:	89 f8                	mov    %edi,%eax
        ap++;
 691:	83 c3 04             	add    $0x4,%ebx
        printint(fd, *ap, 16, 0);
 694:	e8 87 fe ff ff       	call   520 <printint>
        ap++;
 699:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 69c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 69f:	31 d2                	xor    %edx,%edx
 6a1:	e9 67 ff ff ff       	jmp    60d <printf+0x4d>
        s = (char*)*ap;
 6a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
 6a9:	8b 18                	mov    (%eax),%ebx
        ap++;
 6ab:	83 c0 04             	add    $0x4,%eax
 6ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 6b1:	85 db                	test   %ebx,%ebx
 6b3:	0f 84 87 00 00 00    	je     740 <printf+0x180>
        while(*s != 0){
 6b9:	0f b6 03             	movzbl (%ebx),%eax
      state = 0;
 6bc:	31 d2                	xor    %edx,%edx
        while(*s != 0){
 6be:	84 c0                	test   %al,%al
 6c0:	0f 84 47 ff ff ff    	je     60d <printf+0x4d>
 6c6:	8d 55 e7             	lea    -0x19(%ebp),%edx
 6c9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 6cc:	89 de                	mov    %ebx,%esi
 6ce:	89 d3                	mov    %edx,%ebx
  write(fd, &c, 1);
 6d0:	83 ec 04             	sub    $0x4,%esp
 6d3:	88 45 e7             	mov    %al,-0x19(%ebp)
          s++;
 6d6:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 6d9:	6a 01                	push   $0x1
 6db:	53                   	push   %ebx
 6dc:	57                   	push   %edi
 6dd:	e8 a1 fd ff ff       	call   483 <write>
        while(*s != 0){
 6e2:	0f b6 06             	movzbl (%esi),%eax
 6e5:	83 c4 10             	add    $0x10,%esp
 6e8:	84 c0                	test   %al,%al
 6ea:	75 e4                	jne    6d0 <printf+0x110>
      state = 0;
 6ec:	8b 75 d4             	mov    -0x2c(%ebp),%esi
 6ef:	31 d2                	xor    %edx,%edx
 6f1:	e9 17 ff ff ff       	jmp    60d <printf+0x4d>
        printint(fd, *ap, 10, 1);
 6f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 6f9:	83 ec 0c             	sub    $0xc,%esp
 6fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
 701:	8b 13                	mov    (%ebx),%edx
 703:	6a 01                	push   $0x1
 705:	eb 88                	jmp    68f <printf+0xcf>
        putc(fd, *ap);
 707:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  write(fd, &c, 1);
 70a:	83 ec 04             	sub    $0x4,%esp
 70d:	8d 55 e7             	lea    -0x19(%ebp),%edx
        putc(fd, *ap);
 710:	8b 03                	mov    (%ebx),%eax
        ap++;
 712:	83 c3 04             	add    $0x4,%ebx
        putc(fd, *ap);
 715:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 718:	6a 01                	push   $0x1
 71a:	52                   	push   %edx
 71b:	57                   	push   %edi
 71c:	e8 62 fd ff ff       	call   483 <write>
        ap++;
 721:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 724:	83 c4 10             	add    $0x10,%esp
      state = 0;
 727:	31 d2                	xor    %edx,%edx
 729:	e9 df fe ff ff       	jmp    60d <printf+0x4d>
 72e:	66 90                	xchg   %ax,%ax
  write(fd, &c, 1);
 730:	83 ec 04             	sub    $0x4,%esp
 733:	88 5d e7             	mov    %bl,-0x19(%ebp)
 736:	8d 55 e7             	lea    -0x19(%ebp),%edx
 739:	6a 01                	push   $0x1
 73b:	e9 31 ff ff ff       	jmp    671 <printf+0xb1>
 740:	b8 28 00 00 00       	mov    $0x28,%eax
          s = "(null)";
 745:	bb 42 0a 00 00       	mov    $0xa42,%ebx
 74a:	e9 77 ff ff ff       	jmp    6c6 <printf+0x106>
 74f:	90                   	nop

00000750 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 750:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 751:	a1 b8 0a 00 00       	mov    0xab8,%eax
{
 756:	89 e5                	mov    %esp,%ebp
 758:	57                   	push   %edi
 759:	56                   	push   %esi
 75a:	53                   	push   %ebx
 75b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 75e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 761:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	8b 10                	mov    (%eax),%edx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	39 c8                	cmp    %ecx,%eax
 76c:	73 32                	jae    7a0 <free+0x50>
 76e:	39 d1                	cmp    %edx,%ecx
 770:	72 04                	jb     776 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	39 d0                	cmp    %edx,%eax
 774:	72 32                	jb     7a8 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 776:	8b 73 fc             	mov    -0x4(%ebx),%esi
 779:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 77c:	39 fa                	cmp    %edi,%edx
 77e:	74 30                	je     7b0 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 783:	8b 50 04             	mov    0x4(%eax),%edx
 786:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 789:	39 f1                	cmp    %esi,%ecx
 78b:	74 3a                	je     7c7 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 78d:	89 08                	mov    %ecx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
}
 78f:	5b                   	pop    %ebx
  freep = p;
 790:	a3 b8 0a 00 00       	mov    %eax,0xab8
}
 795:	5e                   	pop    %esi
 796:	5f                   	pop    %edi
 797:	5d                   	pop    %ebp
 798:	c3                   	ret
 799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a0:	39 d0                	cmp    %edx,%eax
 7a2:	72 04                	jb     7a8 <free+0x58>
 7a4:	39 d1                	cmp    %edx,%ecx
 7a6:	72 ce                	jb     776 <free+0x26>
{
 7a8:	89 d0                	mov    %edx,%eax
 7aa:	eb bc                	jmp    768 <free+0x18>
 7ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 7b0:	03 72 04             	add    0x4(%edx),%esi
 7b3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	8b 10                	mov    (%eax),%edx
 7b8:	8b 12                	mov    (%edx),%edx
 7ba:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 7bd:	8b 50 04             	mov    0x4(%eax),%edx
 7c0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7c3:	39 f1                	cmp    %esi,%ecx
 7c5:	75 c6                	jne    78d <free+0x3d>
    p->s.size += bp->s.size;
 7c7:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 7ca:	a3 b8 0a 00 00       	mov    %eax,0xab8
    p->s.size += bp->s.size;
 7cf:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7d2:	8b 4b f8             	mov    -0x8(%ebx),%ecx
 7d5:	89 08                	mov    %ecx,(%eax)
}
 7d7:	5b                   	pop    %ebx
 7d8:	5e                   	pop    %esi
 7d9:	5f                   	pop    %edi
 7da:	5d                   	pop    %ebp
 7db:	c3                   	ret
 7dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000007e0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e0:	55                   	push   %ebp
 7e1:	89 e5                	mov    %esp,%ebp
 7e3:	57                   	push   %edi
 7e4:	56                   	push   %esi
 7e5:	53                   	push   %ebx
 7e6:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e9:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 7ec:	8b 15 b8 0a 00 00    	mov    0xab8,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f2:	8d 78 07             	lea    0x7(%eax),%edi
 7f5:	c1 ef 03             	shr    $0x3,%edi
 7f8:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 7fb:	85 d2                	test   %edx,%edx
 7fd:	0f 84 8d 00 00 00    	je     890 <malloc+0xb0>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 803:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 805:	8b 48 04             	mov    0x4(%eax),%ecx
 808:	39 f9                	cmp    %edi,%ecx
 80a:	73 64                	jae    870 <malloc+0x90>
  if(nu < 4096)
 80c:	bb 00 10 00 00       	mov    $0x1000,%ebx
 811:	39 df                	cmp    %ebx,%edi
 813:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 816:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 81d:	eb 0a                	jmp    829 <malloc+0x49>
 81f:	90                   	nop
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 820:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 822:	8b 48 04             	mov    0x4(%eax),%ecx
 825:	39 f9                	cmp    %edi,%ecx
 827:	73 47                	jae    870 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 829:	89 c2                	mov    %eax,%edx
 82b:	3b 05 b8 0a 00 00    	cmp    0xab8,%eax
 831:	75 ed                	jne    820 <malloc+0x40>
  p = sbrk(nu * sizeof(Header));
 833:	83 ec 0c             	sub    $0xc,%esp
 836:	56                   	push   %esi
 837:	e8 af fc ff ff       	call   4eb <sbrk>
  if(p == (char*)-1)
 83c:	83 c4 10             	add    $0x10,%esp
 83f:	83 f8 ff             	cmp    $0xffffffff,%eax
 842:	74 1c                	je     860 <malloc+0x80>
  hp->s.size = nu;
 844:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 847:	83 ec 0c             	sub    $0xc,%esp
 84a:	83 c0 08             	add    $0x8,%eax
 84d:	50                   	push   %eax
 84e:	e8 fd fe ff ff       	call   750 <free>
  return freep;
 853:	8b 15 b8 0a 00 00    	mov    0xab8,%edx
      if((p = morecore(nunits)) == 0)
 859:	83 c4 10             	add    $0x10,%esp
 85c:	85 d2                	test   %edx,%edx
 85e:	75 c0                	jne    820 <malloc+0x40>
        return 0;
  }
}
 860:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 863:	31 c0                	xor    %eax,%eax
}
 865:	5b                   	pop    %ebx
 866:	5e                   	pop    %esi
 867:	5f                   	pop    %edi
 868:	5d                   	pop    %ebp
 869:	c3                   	ret
 86a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 870:	39 cf                	cmp    %ecx,%edi
 872:	74 4c                	je     8c0 <malloc+0xe0>
        p->s.size -= nunits;
 874:	29 f9                	sub    %edi,%ecx
 876:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 879:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 87c:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 87f:	89 15 b8 0a 00 00    	mov    %edx,0xab8
}
 885:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 888:	83 c0 08             	add    $0x8,%eax
}
 88b:	5b                   	pop    %ebx
 88c:	5e                   	pop    %esi
 88d:	5f                   	pop    %edi
 88e:	5d                   	pop    %ebp
 88f:	c3                   	ret
    base.s.ptr = freep = prevp = &base;
 890:	c7 05 b8 0a 00 00 bc 	movl   $0xabc,0xab8
 897:	0a 00 00 
    base.s.size = 0;
 89a:	b8 bc 0a 00 00       	mov    $0xabc,%eax
    base.s.ptr = freep = prevp = &base;
 89f:	c7 05 bc 0a 00 00 bc 	movl   $0xabc,0xabc
 8a6:	0a 00 00 
    base.s.size = 0;
 8a9:	c7 05 c0 0a 00 00 00 	movl   $0x0,0xac0
 8b0:	00 00 00 
    if(p->s.size >= nunits){
 8b3:	e9 54 ff ff ff       	jmp    80c <malloc+0x2c>
 8b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 8bf:	90                   	nop
        prevp->s.ptr = p->s.ptr;
 8c0:	8b 08                	mov    (%eax),%ecx
 8c2:	89 0a                	mov    %ecx,(%edx)
 8c4:	eb b9                	jmp    87f <malloc+0x9f>
