
_memtest4:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
    exit();
}

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
    // printf(1, "Memtest starting\n");
    mem();
   6:	e8 05 00 00 00       	call   10 <mem>
   b:	66 90                	xchg   %ax,%ax
   d:	66 90                	xchg   %ax,%ax
   f:	90                   	nop

00000010 <mem>:
{
  10:	55                   	push   %ebp
  11:	89 e5                	mov    %esp,%ebp
  13:	57                   	push   %edi
  14:	56                   	push   %esi
  15:	53                   	push   %ebx
  16:	bb c8 00 00 00       	mov    $0xc8,%ebx
  1b:	83 ec 0c             	sub    $0xc,%esp
  1e:	66 90                	xchg   %ax,%ax
        char *memory = (char*) malloc(size); //4kb;
  20:	83 ec 0c             	sub    $0xc,%esp
  23:	68 00 10 00 00       	push   $0x1000
  28:	e8 a3 08 00 00       	call   8d0 <malloc>
    for(int j=0;j<200;++j){
  2d:	83 c4 10             	add    $0x10,%esp
        memory[0] = (char) (65);
  30:	c6 00 41             	movb   $0x41,(%eax)
    for(int j=0;j<200;++j){
  33:	83 eb 01             	sub    $0x1,%ebx
  36:	75 e8                	jne    20 <mem+0x10>
    pid = fork();
  38:	e8 0e 05 00 00       	call   54b <fork>
    if(pid > 0) {
  3d:	85 c0                	test   %eax,%eax
  3f:	0f 8e 8c 00 00 00    	jle    d1 <mem+0xc1>
  45:	be 64 00 00 00       	mov    $0x64,%esi
                memory[k] = (char)(65+(k%26));
  4a:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
            char *memory = (char*) malloc(size); //4kb;
  4f:	83 ec 0c             	sub    $0xc,%esp
  52:	68 00 10 00 00       	push   $0x1000
  57:	e8 74 08 00 00       	call   8d0 <malloc>
            if (memory == 0) goto failed;
  5c:	83 c4 10             	add    $0x10,%esp
            char *memory = (char*) malloc(size); //4kb;
  5f:	89 c3                	mov    %eax,%ebx
            if (memory == 0) goto failed;
  61:	85 c0                	test   %eax,%eax
  63:	74 58                	je     bd <mem+0xad>
            for(int k=0;k<size;++k){
  65:	31 c9                	xor    %ecx,%ecx
  67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  6e:	66 90                	xchg   %ax,%ax
                memory[k] = (char)(65+(k%26));
  70:	89 c8                	mov    %ecx,%eax
  72:	f7 e7                	mul    %edi
  74:	89 c8                	mov    %ecx,%eax
  76:	c1 ea 03             	shr    $0x3,%edx
  79:	6b d2 1a             	imul   $0x1a,%edx,%edx
  7c:	29 d0                	sub    %edx,%eax
  7e:	83 c0 41             	add    $0x41,%eax
  81:	88 04 0b             	mov    %al,(%ebx,%ecx,1)
            for(int k=0;k<size;++k){
  84:	83 c1 01             	add    $0x1,%ecx
  87:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  8d:	75 e1                	jne    70 <mem+0x60>
            for(int k=0;k<size;++k){
  8f:	31 c9                	xor    %ecx,%ecx
  91:	eb 14                	jmp    a7 <mem+0x97>
  93:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  97:	90                   	nop
  98:	83 c1 01             	add    $0x1,%ecx
  9b:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  a1:	0f 84 d1 00 00 00    	je     178 <mem+0x168>
                if(memory[k] != (char)(65+(k%26))) goto failed;
  a7:	89 c8                	mov    %ecx,%eax
  a9:	f7 e7                	mul    %edi
  ab:	89 c8                	mov    %ecx,%eax
  ad:	c1 ea 03             	shr    $0x3,%edx
  b0:	6b d2 1a             	imul   $0x1a,%edx,%edx
  b3:	29 d0                	sub    %edx,%eax
  b5:	83 c0 41             	add    $0x41,%eax
  b8:	38 04 0b             	cmp    %al,(%ebx,%ecx,1)
  bb:	74 db                	je     98 <mem+0x88>
        printf(1, "memtest3 Failed!\n");
  bd:	83 ec 08             	sub    $0x8,%esp
  c0:	68 19 0a 00 00       	push   $0xa19
  c5:	6a 01                	push   $0x1
  c7:	e8 e4 05 00 00       	call   6b0 <printf>
        exit();
  cc:	e8 82 04 00 00       	call   553 <exit>
    else if(pid < 0){ 
  d1:	0f 85 8b 00 00 00    	jne    162 <mem+0x152>
        sleep(100);
  d7:	83 ec 0c             	sub    $0xc,%esp
  da:	be 34 01 00 00       	mov    $0x134,%esi
                memory[k] = (char)(65+(k%26));
  df:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
        sleep(100);
  e4:	6a 64                	push   $0x64
  e6:	e8 f8 04 00 00       	call   5e3 <sleep>
  eb:	83 c4 10             	add    $0x10,%esp
            char *memory = (char*) malloc(size); //4kb;
  ee:	83 ec 0c             	sub    $0xc,%esp
  f1:	68 00 10 00 00       	push   $0x1000
  f6:	e8 d5 07 00 00       	call   8d0 <malloc>
            if (memory == 0) goto failed;
  fb:	83 c4 10             	add    $0x10,%esp
            char *memory = (char*) malloc(size); //4kb;
  fe:	89 c3                	mov    %eax,%ebx
            if (memory == 0) goto failed;
 100:	85 c0                	test   %eax,%eax
 102:	74 b9                	je     bd <mem+0xad>
            for(int k=0;k<size;++k){
 104:	31 c9                	xor    %ecx,%ecx
 106:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 10d:	8d 76 00             	lea    0x0(%esi),%esi
                memory[k] = (char)(65+(k%26));
 110:	89 c8                	mov    %ecx,%eax
 112:	f7 e7                	mul    %edi
 114:	89 c8                	mov    %ecx,%eax
 116:	c1 ea 03             	shr    $0x3,%edx
 119:	6b d2 1a             	imul   $0x1a,%edx,%edx
 11c:	29 d0                	sub    %edx,%eax
 11e:	83 c0 41             	add    $0x41,%eax
 121:	88 04 0b             	mov    %al,(%ebx,%ecx,1)
            for(int k=0;k<size;++k){
 124:	83 c1 01             	add    $0x1,%ecx
 127:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 12d:	75 e1                	jne    110 <mem+0x100>
            for(int k=0;k<size;++k){
 12f:	31 c9                	xor    %ecx,%ecx
 131:	eb 14                	jmp    147 <mem+0x137>
 133:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 137:	90                   	nop
 138:	83 c1 01             	add    $0x1,%ecx
 13b:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 141:	0f 84 c3 00 00 00    	je     20a <mem+0x1fa>
                if(memory[k] != (char)(65+(k%26))) goto failed;
 147:	89 c8                	mov    %ecx,%eax
 149:	f7 e7                	mul    %edi
 14b:	89 c8                	mov    %ecx,%eax
 14d:	c1 ea 03             	shr    $0x3,%edx
 150:	6b d2 1a             	imul   $0x1a,%edx,%edx
 153:	29 d0                	sub    %edx,%eax
 155:	83 c0 41             	add    $0x41,%eax
 158:	38 04 0b             	cmp    %al,(%ebx,%ecx,1)
 15b:	74 db                	je     138 <mem+0x128>
 15d:	e9 5b ff ff ff       	jmp    bd <mem+0xad>
            printf(1, "Fork Failed\n");
 162:	50                   	push   %eax
 163:	50                   	push   %eax
 164:	68 ca 09 00 00       	push   $0x9ca
 169:	6a 01                	push   $0x1
 16b:	e8 40 05 00 00       	call   6b0 <printf>
 170:	83 c4 10             	add    $0x10,%esp
        exit();
 173:	e8 db 03 00 00       	call   553 <exit>
        for(int j=0;j<100;++j){
 178:	83 ee 01             	sub    $0x1,%esi
 17b:	0f 85 ce fe ff ff    	jne    4f <mem+0x3f>
        printf(1,"Parent alloc-ed:\n");
 181:	50                   	push   %eax
 182:	50                   	push   %eax
 183:	68 b8 09 00 00       	push   $0x9b8
 188:	6a 01                	push   $0x1
 18a:	e8 21 05 00 00       	call   6b0 <printf>
        getrss();
 18f:	e8 5f 04 00 00       	call   5f3 <getrss>
        wait();
 194:	e8 c2 03 00 00       	call   55b <wait>
        pid = fork();
 199:	e8 ad 03 00 00       	call   54b <fork>
        if (pid > 0)
 19e:	83 c4 10             	add    $0x10,%esp
 1a1:	85 c0                	test   %eax,%eax
 1a3:	0f 8e 93 00 00 00    	jle    23c <mem+0x22c>
 1a9:	bf 64 00 00 00       	mov    $0x64,%edi
                    memory[k] = (char)(65 + (k % 26));
 1ae:	bb 1a 00 00 00       	mov    $0x1a,%ebx
                char *memory = (char *)malloc(size); // 4kb;
 1b3:	83 ec 0c             	sub    $0xc,%esp
 1b6:	68 00 10 00 00       	push   $0x1000
 1bb:	e8 10 07 00 00       	call   8d0 <malloc>
                if (memory == 0)
 1c0:	83 c4 10             	add    $0x10,%esp
                char *memory = (char *)malloc(size); // 4kb;
 1c3:	89 c6                	mov    %eax,%esi
                if (memory == 0)
 1c5:	85 c0                	test   %eax,%eax
 1c7:	0f 84 f0 fe ff ff    	je     bd <mem+0xad>
                for (int k = 0; k < size; ++k)
 1cd:	31 c9                	xor    %ecx,%ecx
                    memory[k] = (char)(65 + (k % 26));
 1cf:	89 c8                	mov    %ecx,%eax
 1d1:	99                   	cltd
 1d2:	f7 fb                	idiv   %ebx
 1d4:	83 c2 41             	add    $0x41,%edx
 1d7:	88 14 0e             	mov    %dl,(%esi,%ecx,1)
                for (int k = 0; k < size; ++k)
 1da:	83 c1 01             	add    $0x1,%ecx
 1dd:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 1e3:	75 ea                	jne    1cf <mem+0x1bf>
                for (int k = 0; k < size; ++k)
 1e5:	31 c9                	xor    %ecx,%ecx
 1e7:	eb 0f                	jmp    1f8 <mem+0x1e8>
 1e9:	83 c1 01             	add    $0x1,%ecx
 1ec:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 1f2:	0f 84 b4 00 00 00    	je     2ac <mem+0x29c>
                    if (memory[k] != (char)(65 + (k % 26)))
 1f8:	89 c8                	mov    %ecx,%eax
 1fa:	99                   	cltd
 1fb:	f7 fb                	idiv   %ebx
 1fd:	83 c2 41             	add    $0x41,%edx
 200:	38 14 0e             	cmp    %dl,(%esi,%ecx,1)
 203:	74 e4                	je     1e9 <mem+0x1d9>
 205:	e9 b3 fe ff ff       	jmp    bd <mem+0xad>
        for(int j=0;j<308;++j){
 20a:	83 ee 01             	sub    $0x1,%esi
 20d:	0f 85 db fe ff ff    	jne    ee <mem+0xde>
        printf(1,"Child alloc-ed\n");
 213:	50                   	push   %eax
 214:	50                   	push   %eax
 215:	68 d7 09 00 00       	push   $0x9d7
 21a:	6a 01                	push   $0x1
 21c:	e8 8f 04 00 00       	call   6b0 <printf>
        getrss();
 221:	e8 cd 03 00 00       	call   5f3 <getrss>
        printf(1, "memtest3 Passed part 1!\n");
 226:	5a                   	pop    %edx
 227:	59                   	pop    %ecx
 228:	68 00 0a 00 00       	push   $0xa00
 22d:	6a 01                	push   $0x1
 22f:	e8 7c 04 00 00       	call   6b0 <printf>
 234:	83 c4 10             	add    $0x10,%esp
 237:	e9 37 ff ff ff       	jmp    173 <mem+0x163>
        else if (pid < 0)
 23c:	0f 85 20 ff ff ff    	jne    162 <mem+0x152>
            sleep(100);
 242:	83 ec 0c             	sub    $0xc,%esp
 245:	bf 34 01 00 00       	mov    $0x134,%edi
                    memory[k] = (char)(65 + (k % 26));
 24a:	be 1a 00 00 00       	mov    $0x1a,%esi
            sleep(100);
 24f:	6a 64                	push   $0x64
 251:	e8 8d 03 00 00       	call   5e3 <sleep>
 256:	83 c4 10             	add    $0x10,%esp
                char *memory = (char *)malloc(size); // 4kb;
 259:	83 ec 0c             	sub    $0xc,%esp
 25c:	68 00 10 00 00       	push   $0x1000
 261:	e8 6a 06 00 00       	call   8d0 <malloc>
                if (memory == 0)
 266:	83 c4 10             	add    $0x10,%esp
                char *memory = (char *)malloc(size); // 4kb;
 269:	89 c3                	mov    %eax,%ebx
                if (memory == 0)
 26b:	85 c0                	test   %eax,%eax
 26d:	0f 84 4a fe ff ff    	je     bd <mem+0xad>
                for (int k = 0; k < size; ++k)
 273:	31 c9                	xor    %ecx,%ecx
                    memory[k] = (char)(65 + (k % 26));
 275:	89 c8                	mov    %ecx,%eax
 277:	99                   	cltd
 278:	f7 fe                	idiv   %esi
 27a:	83 c2 41             	add    $0x41,%edx
 27d:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
                for (int k = 0; k < size; ++k)
 280:	83 c1 01             	add    $0x1,%ecx
 283:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 289:	75 ea                	jne    275 <mem+0x265>
                for (int k = 0; k < size; ++k)
 28b:	31 c9                	xor    %ecx,%ecx
 28d:	eb 0b                	jmp    29a <mem+0x28a>
 28f:	83 c1 01             	add    $0x1,%ecx
 292:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 298:	74 3b                	je     2d5 <mem+0x2c5>
                    if (memory[k] != (char)(65 + (k % 26)))
 29a:	89 c8                	mov    %ecx,%eax
 29c:	99                   	cltd
 29d:	f7 fe                	idiv   %esi
 29f:	83 c2 41             	add    $0x41,%edx
 2a2:	38 14 0b             	cmp    %dl,(%ebx,%ecx,1)
 2a5:	74 e8                	je     28f <mem+0x27f>
 2a7:	e9 11 fe ff ff       	jmp    bd <mem+0xad>
            for (int j = 0; j < 100; ++j)
 2ac:	83 ef 01             	sub    $0x1,%edi
 2af:	0f 85 fe fe ff ff    	jne    1b3 <mem+0x1a3>
            printf(1, "Parent alloc-ed:\n");
 2b5:	50                   	push   %eax
 2b6:	50                   	push   %eax
 2b7:	68 b8 09 00 00       	push   $0x9b8
 2bc:	6a 01                	push   $0x1
 2be:	e8 ed 03 00 00       	call   6b0 <printf>
            getrss();
 2c3:	e8 2b 03 00 00       	call   5f3 <getrss>
            wait();
 2c8:	e8 8e 02 00 00       	call   55b <wait>
 2cd:	83 c4 10             	add    $0x10,%esp
 2d0:	e9 9e fe ff ff       	jmp    173 <mem+0x163>
            for (int j = 0; j < 308; ++j)
 2d5:	83 ef 01             	sub    $0x1,%edi
 2d8:	0f 85 7b ff ff ff    	jne    259 <mem+0x249>
            printf(1, "Child alloc-ed\n");
 2de:	53                   	push   %ebx
 2df:	53                   	push   %ebx
 2e0:	68 d7 09 00 00       	push   $0x9d7
 2e5:	6a 01                	push   $0x1
 2e7:	e8 c4 03 00 00       	call   6b0 <printf>
            getrss();
 2ec:	e8 02 03 00 00       	call   5f3 <getrss>
            printf(1, "memtest3 Passed part 2!\n");
 2f1:	5e                   	pop    %esi
 2f2:	5f                   	pop    %edi
 2f3:	68 e7 09 00 00       	push   $0x9e7
 2f8:	6a 01                	push   $0x1
 2fa:	e8 b1 03 00 00       	call   6b0 <printf>
 2ff:	83 c4 10             	add    $0x10,%esp
 302:	e9 6c fe ff ff       	jmp    173 <mem+0x163>
 307:	66 90                	xchg   %ax,%ax
 309:	66 90                	xchg   %ax,%ax
 30b:	66 90                	xchg   %ax,%ax
 30d:	66 90                	xchg   %ax,%ax
 30f:	90                   	nop

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
 64b:	0f b6 92 a0 0a 00 00 	movzbl 0xaa0(%edx),%edx
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
 724:	ff 24 85 48 0a 00 00 	jmp    *0xa48(,%eax,4)
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
 835:	bb 41 0a 00 00       	mov    $0xa41,%ebx
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
 841:	a1 00 2b 00 00       	mov    0x2b00,%eax
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
 880:	a3 00 2b 00 00       	mov    %eax,0x2b00
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
 8ba:	a3 00 2b 00 00       	mov    %eax,0x2b00
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
 8dc:	8b 15 00 2b 00 00    	mov    0x2b00,%edx
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
 91b:	3b 05 00 2b 00 00    	cmp    0x2b00,%eax
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
 943:	8b 15 00 2b 00 00    	mov    0x2b00,%edx
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
 96f:	89 15 00 2b 00 00    	mov    %edx,0x2b00
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
 980:	c7 05 00 2b 00 00 04 	movl   $0x2b04,0x2b00
 987:	2b 00 00 
    base.s.size = 0;
 98a:	b8 04 2b 00 00       	mov    $0x2b04,%eax
    base.s.ptr = freep = prevp = &base;
 98f:	c7 05 04 2b 00 00 04 	movl   $0x2b04,0x2b04
 996:	2b 00 00 
    base.s.size = 0;
 999:	c7 05 08 2b 00 00 00 	movl   $0x0,0x2b08
 9a0:	00 00 00 
    if(p->s.size >= nunits){
 9a3:	e9 54 ff ff ff       	jmp    8fc <malloc+0x2c>
 9a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 9af:	90                   	nop
        prevp->s.ptr = p->s.ptr;
 9b0:	8b 08                	mov    (%eax),%ecx
 9b2:	89 0a                	mov    %ecx,(%edx)
 9b4:	eb b9                	jmp    96f <malloc+0x9f>
