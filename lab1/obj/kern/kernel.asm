
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 ba 12 01 00    	add    $0x112ba,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 fc 08 ff ff    	lea    -0xf704(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 ce 0a 00 00       	call   f0100b31 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 18 09 ff ff    	lea    -0xf6e8(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 a8 0a 00 00       	call   f0100b31 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 ed 07 00 00       	call   f010088e <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 52 12 01 00    	add    $0x11252,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 f3 16 00 00       	call   f01017c2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3e 05 00 00       	call   f0100612 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 33 09 ff ff    	lea    -0xf6cd(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 49 0a 00 00       	call   f0100b31 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 77 08 00 00       	call   f0100978 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	56                   	push   %esi
f010010a:	53                   	push   %ebx
f010010b:	e8 ac 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100110:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
	va_list ap;

	if (panicstr)
f0100116:	83 bb 5c 1d 00 00 00 	cmpl   $0x0,0x1d5c(%ebx)
f010011d:	74 0f                	je     f010012e <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011f:	83 ec 0c             	sub    $0xc,%esp
f0100122:	6a 00                	push   $0x0
f0100124:	e8 4f 08 00 00       	call   f0100978 <monitor>
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	eb f1                	jmp    f010011f <_panic+0x19>
	panicstr = fmt;
f010012e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100131:	89 83 5c 1d 00 00    	mov    %eax,0x1d5c(%ebx)
	asm volatile("cli; cld");
f0100137:	fa                   	cli    
f0100138:	fc                   	cld    
	va_start(ap, fmt);
f0100139:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	ff 75 0c             	push   0xc(%ebp)
f0100142:	ff 75 08             	push   0x8(%ebp)
f0100145:	8d 83 4e 09 ff ff    	lea    -0xf6b2(%ebx),%eax
f010014b:	50                   	push   %eax
f010014c:	e8 e0 09 00 00       	call   f0100b31 <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	56                   	push   %esi
f0100155:	ff 75 10             	push   0x10(%ebp)
f0100158:	e8 9d 09 00 00       	call   f0100afa <vcprintf>
	cprintf("\n");
f010015d:	8d 83 8a 09 ff ff    	lea    -0xf676(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 c6 09 00 00       	call   f0100b31 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb af                	jmp    f010011f <_panic+0x19>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8a 11 01 00    	add    $0x1118a,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	push   0xc(%ebp)
f0100189:	ff 75 08             	push   0x8(%ebp)
f010018c:	8d 83 66 09 ff ff    	lea    -0xf69a(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 99 09 00 00       	call   f0100b31 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	push   0x10(%ebp)
f010019f:	e8 56 09 00 00       	call   f0100afa <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 8a 09 ff ff    	lea    -0xf676(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 7f 09 00 00       	call   f0100b31 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 1c             	sub    $0x1c,%esp
f01001e3:	e8 6a 05 00 00       	call   f0100752 <__x86.get_pc_thunk.si>
f01001e8:	81 c6 1c 11 01 00    	add    $0x1111c,%esi
f01001ee:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f0:	8d 1d 9c 1d 00 00    	lea    0x1d9c,%ebx
f01001f6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ff:	eb 25                	jmp    f0100226 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100201:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100208:	8d 51 01             	lea    0x1(%ecx),%edx
f010020b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010020e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100211:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100217:	b8 00 00 00 00       	mov    $0x0,%eax
f010021c:	0f 44 d0             	cmove  %eax,%edx
f010021f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100229:	ff d0                	call   *%eax
f010022b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010022e:	74 06                	je     f0100236 <cons_intr+0x5c>
		if (c == 0)
f0100230:	85 c0                	test   %eax,%eax
f0100232:	75 cd                	jne    f0100201 <cons_intr+0x27>
f0100234:	eb f0                	jmp    f0100226 <cons_intr+0x4c>
	}
}
f0100236:	83 c4 1c             	add    $0x1c,%esp
f0100239:	5b                   	pop    %ebx
f010023a:	5e                   	pop    %esi
f010023b:	5f                   	pop    %edi
f010023c:	5d                   	pop    %ebp
f010023d:	c3                   	ret    

f010023e <kbd_proc_data>:
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	56                   	push   %esi
f0100242:	53                   	push   %ebx
f0100243:	e8 74 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100248:	81 c3 bc 10 01 00    	add    $0x110bc,%ebx
f010024e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100253:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100254:	a8 01                	test   $0x1,%al
f0100256:	0f 84 f7 00 00 00    	je     f0100353 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010025c:	a8 20                	test   $0x20,%al
f010025e:	0f 85 f6 00 00 00    	jne    f010035a <kbd_proc_data+0x11c>
f0100264:	ba 60 00 00 00       	mov    $0x60,%edx
f0100269:	ec                   	in     (%dx),%al
f010026a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026c:	3c e0                	cmp    $0xe0,%al
f010026e:	74 64                	je     f01002d4 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100270:	84 c0                	test   %al,%al
f0100272:	78 75                	js     f01002e9 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100274:	8b 8b 7c 1d 00 00    	mov    0x1d7c(%ebx),%ecx
f010027a:	f6 c1 40             	test   $0x40,%cl
f010027d:	74 0e                	je     f010028d <kbd_proc_data+0x4f>
		data |= 0x80;
f010027f:	83 c8 80             	or     $0xffffff80,%eax
f0100282:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100284:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100287:	89 8b 7c 1d 00 00    	mov    %ecx,0x1d7c(%ebx)
	shift |= shiftcode[data];
f010028d:	0f b6 d2             	movzbl %dl,%edx
f0100290:	0f b6 84 13 bc 0a ff 	movzbl -0xf544(%ebx,%edx,1),%eax
f0100297:	ff 
f0100298:	0b 83 7c 1d 00 00    	or     0x1d7c(%ebx),%eax
	shift ^= togglecode[data];
f010029e:	0f b6 8c 13 bc 09 ff 	movzbl -0xf644(%ebx,%edx,1),%ecx
f01002a5:	ff 
f01002a6:	31 c8                	xor    %ecx,%eax
f01002a8:	89 83 7c 1d 00 00    	mov    %eax,0x1d7c(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ae:	89 c1                	mov    %eax,%ecx
f01002b0:	83 e1 03             	and    $0x3,%ecx
f01002b3:	8b 8c 8b fc 1c 00 00 	mov    0x1cfc(%ebx,%ecx,4),%ecx
f01002ba:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002be:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002c1:	a8 08                	test   $0x8,%al
f01002c3:	74 61                	je     f0100326 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ca:	83 f9 19             	cmp    $0x19,%ecx
f01002cd:	77 4b                	ja     f010031a <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002cf:	83 ee 20             	sub    $0x20,%esi
f01002d2:	eb 0c                	jmp    f01002e0 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d4:	83 8b 7c 1d 00 00 40 	orl    $0x40,0x1d7c(%ebx)
		return 0;
f01002db:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e0:	89 f0                	mov    %esi,%eax
f01002e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5e                   	pop    %esi
f01002e7:	5d                   	pop    %ebp
f01002e8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e9:	8b 8b 7c 1d 00 00    	mov    0x1d7c(%ebx),%ecx
f01002ef:	83 e0 7f             	and    $0x7f,%eax
f01002f2:	f6 c1 40             	test   $0x40,%cl
f01002f5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f8:	0f b6 d2             	movzbl %dl,%edx
f01002fb:	0f b6 84 13 bc 0a ff 	movzbl -0xf544(%ebx,%edx,1),%eax
f0100302:	ff 
f0100303:	83 c8 40             	or     $0x40,%eax
f0100306:	0f b6 c0             	movzbl %al,%eax
f0100309:	f7 d0                	not    %eax
f010030b:	21 c8                	and    %ecx,%eax
f010030d:	89 83 7c 1d 00 00    	mov    %eax,0x1d7c(%ebx)
		return 0;
f0100313:	be 00 00 00 00       	mov    $0x0,%esi
f0100318:	eb c6                	jmp    f01002e0 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010031d:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100320:	83 fa 1a             	cmp    $0x1a,%edx
f0100323:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100326:	f7 d0                	not    %eax
f0100328:	a8 06                	test   $0x6,%al
f010032a:	75 b4                	jne    f01002e0 <kbd_proc_data+0xa2>
f010032c:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100332:	75 ac                	jne    f01002e0 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100334:	83 ec 0c             	sub    $0xc,%esp
f0100337:	8d 83 80 09 ff ff    	lea    -0xf680(%ebx),%eax
f010033d:	50                   	push   %eax
f010033e:	e8 ee 07 00 00       	call   f0100b31 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100343:	b8 03 00 00 00       	mov    $0x3,%eax
f0100348:	ba 92 00 00 00       	mov    $0x92,%edx
f010034d:	ee                   	out    %al,(%dx)
}
f010034e:	83 c4 10             	add    $0x10,%esp
f0100351:	eb 8d                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f0100353:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100358:	eb 86                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f010035a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035f:	e9 7c ff ff ff       	jmp    f01002e0 <kbd_proc_data+0xa2>

f0100364 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100364:	55                   	push   %ebp
f0100365:	89 e5                	mov    %esp,%ebp
f0100367:	57                   	push   %edi
f0100368:	56                   	push   %esi
f0100369:	53                   	push   %ebx
f010036a:	83 ec 1c             	sub    $0x1c,%esp
f010036d:	e8 4a fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100372:	81 c3 92 0f 01 00    	add    $0x10f92,%ebx
f0100378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010037b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100380:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100385:	b9 84 00 00 00       	mov    $0x84,%ecx
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038d:	a8 20                	test   $0x20,%al
f010038f:	75 13                	jne    f01003a4 <cons_putc+0x40>
f0100391:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100397:	7f 0b                	jg     f01003a4 <cons_putc+0x40>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
	     i++)
f010039f:	83 c6 01             	add    $0x1,%esi
f01003a2:	eb e6                	jmp    f010038a <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003a4:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a8:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003b0:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	bf 79 03 00 00       	mov    $0x379,%edi
f01003bb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c0:	89 fa                	mov    %edi,%edx
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c9:	7f 0f                	jg     f01003da <cons_putc+0x76>
f01003cb:	84 c0                	test   %al,%al
f01003cd:	78 0b                	js     f01003da <cons_putc+0x76>
f01003cf:	89 ca                	mov    %ecx,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	ec                   	in     (%dx),%al
f01003d4:	ec                   	in     (%dx),%al
f01003d5:	83 c6 01             	add    $0x1,%esi
f01003d8:	eb e6                	jmp    f01003c0 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003da:	ba 78 03 00 00       	mov    $0x378,%edx
f01003df:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003e3:	ee                   	out    %al,(%dx)
f01003e4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ee:	ee                   	out    %al,(%dx)
f01003ef:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f4:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f8:	89 f8                	mov    %edi,%eax
f01003fa:	80 cc 07             	or     $0x7,%ah
f01003fd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100403:	0f 45 c7             	cmovne %edi,%eax
f0100406:	89 c7                	mov    %eax,%edi
f0100408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010040b:	0f b6 c0             	movzbl %al,%eax
f010040e:	89 f9                	mov    %edi,%ecx
f0100410:	80 f9 0a             	cmp    $0xa,%cl
f0100413:	0f 84 e4 00 00 00    	je     f01004fd <cons_putc+0x199>
f0100419:	83 f8 0a             	cmp    $0xa,%eax
f010041c:	7f 46                	jg     f0100464 <cons_putc+0x100>
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	0f 84 a8 00 00 00    	je     f01004cf <cons_putc+0x16b>
f0100427:	83 f8 09             	cmp    $0x9,%eax
f010042a:	0f 85 da 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 2a ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 20 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 16 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 0c ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100458:	b8 20 00 00 00       	mov    $0x20,%eax
f010045d:	e8 02 ff ff ff       	call   f0100364 <cons_putc>
		break;
f0100462:	eb 26                	jmp    f010048a <cons_putc+0x126>
	switch (c & 0xff) {
f0100464:	83 f8 0d             	cmp    $0xd,%eax
f0100467:	0f 85 9d 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010046d:	0f b7 83 a4 1f 00 00 	movzwl 0x1fa4(%ebx),%eax
f0100474:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010047a:	c1 e8 16             	shr    $0x16,%eax
f010047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100480:	c1 e0 04             	shl    $0x4,%eax
f0100483:	66 89 83 a4 1f 00 00 	mov    %ax,0x1fa4(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010048a:	66 81 bb a4 1f 00 00 	cmpw   $0x7cf,0x1fa4(%ebx)
f0100491:	cf 07 
f0100493:	0f 87 98 00 00 00    	ja     f0100531 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100499:	8b 8b ac 1f 00 00    	mov    0x1fac(%ebx),%ecx
f010049f:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a4:	89 ca                	mov    %ecx,%edx
f01004a6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a7:	0f b7 9b a4 1f 00 00 	movzwl 0x1fa4(%ebx),%ebx
f01004ae:	8d 71 01             	lea    0x1(%ecx),%esi
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	66 c1 e8 08          	shr    $0x8,%ax
f01004b7:	89 f2                	mov    %esi,%edx
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	89 d8                	mov    %ebx,%eax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004ca:	5b                   	pop    %ebx
f01004cb:	5e                   	pop    %esi
f01004cc:	5f                   	pop    %edi
f01004cd:	5d                   	pop    %ebp
f01004ce:	c3                   	ret    
		if (crt_pos > 0) {
f01004cf:	0f b7 83 a4 1f 00 00 	movzwl 0x1fa4(%ebx),%eax
f01004d6:	66 85 c0             	test   %ax,%ax
f01004d9:	74 be                	je     f0100499 <cons_putc+0x135>
			crt_pos--;
f01004db:	83 e8 01             	sub    $0x1,%eax
f01004de:	66 89 83 a4 1f 00 00 	mov    %ax,0x1fa4(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ec:	b2 00                	mov    $0x0,%dl
f01004ee:	83 ca 20             	or     $0x20,%edx
f01004f1:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f01004f7:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004fb:	eb 8d                	jmp    f010048a <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004fd:	66 83 83 a4 1f 00 00 	addw   $0x50,0x1fa4(%ebx)
f0100504:	50 
f0100505:	e9 63 ff ff ff       	jmp    f010046d <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050a:	0f b7 83 a4 1f 00 00 	movzwl 0x1fa4(%ebx),%eax
f0100511:	8d 50 01             	lea    0x1(%eax),%edx
f0100514:	66 89 93 a4 1f 00 00 	mov    %dx,0x1fa4(%ebx)
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	8b 93 a8 1f 00 00    	mov    0x1fa8(%ebx),%edx
f0100524:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010052c:	e9 59 ff ff ff       	jmp    f010048a <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100531:	8b 83 a8 1f 00 00    	mov    0x1fa8(%ebx),%eax
f0100537:	83 ec 04             	sub    $0x4,%esp
f010053a:	68 00 0f 00 00       	push   $0xf00
f010053f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100545:	52                   	push   %edx
f0100546:	50                   	push   %eax
f0100547:	e8 bc 12 00 00       	call   f0101808 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054c:	8b 93 a8 1f 00 00    	mov    0x1fa8(%ebx),%edx
f0100552:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100558:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010055e:	83 c4 10             	add    $0x10,%esp
f0100561:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100566:	83 c0 02             	add    $0x2,%eax
f0100569:	39 d0                	cmp    %edx,%eax
f010056b:	75 f4                	jne    f0100561 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010056d:	66 83 ab a4 1f 00 00 	subw   $0x50,0x1fa4(%ebx)
f0100574:	50 
f0100575:	e9 1f ff ff ff       	jmp    f0100499 <cons_putc+0x135>

f010057a <serial_intr>:
{
f010057a:	e8 cf 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f010057f:	05 85 0d 01 00       	add    $0x10d85,%eax
	if (serial_exists)
f0100584:	80 b8 b0 1f 00 00 00 	cmpb   $0x0,0x1fb0(%eax)
f010058b:	75 01                	jne    f010058e <serial_intr+0x14>
f010058d:	c3                   	ret    
{
f010058e:	55                   	push   %ebp
f010058f:	89 e5                	mov    %esp,%ebp
f0100591:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100594:	8d 80 bc ee fe ff    	lea    -0x11144(%eax),%eax
f010059a:	e8 3b fc ff ff       	call   f01001da <cons_intr>
}
f010059f:	c9                   	leave  
f01005a0:	c3                   	ret    

f01005a1 <kbd_intr>:
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	83 ec 08             	sub    $0x8,%esp
f01005a7:	e8 a2 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f01005ac:	05 58 0d 01 00       	add    $0x10d58,%eax
	cons_intr(kbd_proc_data);
f01005b1:	8d 80 3a ef fe ff    	lea    -0x110c6(%eax),%eax
f01005b7:	e8 1e fc ff ff       	call   f01001da <cons_intr>
}
f01005bc:	c9                   	leave  
f01005bd:	c3                   	ret    

f01005be <cons_getc>:
{
f01005be:	55                   	push   %ebp
f01005bf:	89 e5                	mov    %esp,%ebp
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 04             	sub    $0x4,%esp
f01005c5:	e8 f2 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 3a 0d 01 00    	add    $0x10d3a,%ebx
	serial_intr();
f01005d0:	e8 a5 ff ff ff       	call   f010057a <serial_intr>
	kbd_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005da:	8b 83 9c 1f 00 00    	mov    0x1f9c(%ebx),%eax
	return 0;
f01005e0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005e5:	3b 83 a0 1f 00 00    	cmp    0x1fa0(%ebx),%eax
f01005eb:	74 1e                	je     f010060b <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005ed:	8d 48 01             	lea    0x1(%eax),%ecx
f01005f0:	0f b6 94 03 9c 1d 00 	movzbl 0x1d9c(%ebx,%eax,1),%edx
f01005f7:	00 
			cons.rpos = 0;
f01005f8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	0f 45 c1             	cmovne %ecx,%eax
f0100605:	89 83 9c 1f 00 00    	mov    %eax,0x1f9c(%ebx)
}
f010060b:	89 d0                	mov    %edx,%eax
f010060d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	57                   	push   %edi
f0100616:	56                   	push   %esi
f0100617:	53                   	push   %ebx
f0100618:	83 ec 1c             	sub    $0x1c,%esp
f010061b:	e8 9c fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100620:	81 c3 e4 0c 01 00    	add    $0x10ce4,%ebx
	was = *cp;
f0100626:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100634:	5a a5 
	if (*cp != 0xA55A) {
f0100636:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063d:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100642:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100647:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064b:	0f 84 ac 00 00 00    	je     f01006fd <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100651:	89 8b ac 1f 00 00    	mov    %ecx,0x1fac(%ebx)
f0100657:	b8 0e 00 00 00       	mov    $0xe,%eax
f010065c:	89 ca                	mov    %ecx,%edx
f010065e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065f:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	89 f2                	mov    %esi,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	0f b6 c0             	movzbl %al,%eax
f0100668:	c1 e0 08             	shl    $0x8,%eax
f010066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100676:	89 f2                	mov    %esi,%edx
f0100678:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100679:	89 bb a8 1f 00 00    	mov    %edi,0x1fa8(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100685:	66 89 83 a4 1f 00 00 	mov    %ax,0x1fa4(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100691:	89 c8                	mov    %ecx,%eax
f0100693:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100698:	ee                   	out    %al,(%dx)
f0100699:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010069e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b0:	ee                   	out    %al,(%dx)
f01006b1:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006b6:	89 c8                	mov    %ecx,%eax
f01006b8:	89 f2                	mov    %esi,%edx
f01006ba:	ee                   	out    %al,(%dx)
f01006bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c0:	89 fa                	mov    %edi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006c8:	89 c8                	mov    %ecx,%eax
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d0:	89 f2                	mov    %esi,%edx
f01006d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006d8:	ec                   	in     (%dx),%al
f01006d9:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006db:	3c ff                	cmp    $0xff,%al
f01006dd:	0f 95 83 b0 1f 00 00 	setne  0x1fb0(%ebx)
f01006e4:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e9:	ec                   	in     (%dx),%al
f01006ea:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ef:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f0:	80 f9 ff             	cmp    $0xff,%cl
f01006f3:	74 1e                	je     f0100713 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f8:	5b                   	pop    %ebx
f01006f9:	5e                   	pop    %esi
f01006fa:	5f                   	pop    %edi
f01006fb:	5d                   	pop    %ebp
f01006fc:	c3                   	ret    
		*cp = was;
f01006fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100704:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100709:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f010070e:	e9 3e ff ff ff       	jmp    f0100651 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100713:	83 ec 0c             	sub    $0xc,%esp
f0100716:	8d 83 8c 09 ff ff    	lea    -0xf674(%ebx),%eax
f010071c:	50                   	push   %eax
f010071d:	e8 0f 04 00 00       	call   f0100b31 <cprintf>
f0100722:	83 c4 10             	add    $0x10,%esp
}
f0100725:	eb ce                	jmp    f01006f5 <cons_init+0xe3>

f0100727 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100727:	55                   	push   %ebp
f0100728:	89 e5                	mov    %esp,%ebp
f010072a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010072d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100730:	e8 2f fc ff ff       	call   f0100364 <cons_putc>
}
f0100735:	c9                   	leave  
f0100736:	c3                   	ret    

f0100737 <getchar>:

int
getchar(void)
{
f0100737:	55                   	push   %ebp
f0100738:	89 e5                	mov    %esp,%ebp
f010073a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010073d:	e8 7c fe ff ff       	call   f01005be <cons_getc>
f0100742:	85 c0                	test   %eax,%eax
f0100744:	74 f7                	je     f010073d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100746:	c9                   	leave  
f0100747:	c3                   	ret    

f0100748 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	c3                   	ret    

f010074e <__x86.get_pc_thunk.ax>:
f010074e:	8b 04 24             	mov    (%esp),%eax
f0100751:	c3                   	ret    

f0100752 <__x86.get_pc_thunk.si>:
f0100752:	8b 34 24             	mov    (%esp),%esi
f0100755:	c3                   	ret    

f0100756 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	56                   	push   %esi
f010075a:	53                   	push   %ebx
f010075b:	e8 5c fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100760:	81 c3 a4 0b 01 00    	add    $0x10ba4,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100766:	83 ec 04             	sub    $0x4,%esp
f0100769:	8d 83 bc 0b ff ff    	lea    -0xf444(%ebx),%eax
f010076f:	50                   	push   %eax
f0100770:	8d 83 da 0b ff ff    	lea    -0xf426(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	8d b3 df 0b ff ff    	lea    -0xf421(%ebx),%esi
f010077d:	56                   	push   %esi
f010077e:	e8 ae 03 00 00       	call   f0100b31 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	8d 83 8c 0c ff ff    	lea    -0xf374(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	8d 83 e8 0b ff ff    	lea    -0xf418(%ebx),%eax
f0100793:	50                   	push   %eax
f0100794:	56                   	push   %esi
f0100795:	e8 97 03 00 00       	call   f0100b31 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	8d 83 f1 0b ff ff    	lea    -0xf40f(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	8d 83 ff 0b ff ff    	lea    -0xf401(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	56                   	push   %esi
f01007ac:	e8 80 03 00 00       	call   f0100b31 <cprintf>
	return 0;
}
f01007b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b9:	5b                   	pop    %ebx
f01007ba:	5e                   	pop    %esi
f01007bb:	5d                   	pop    %ebp
f01007bc:	c3                   	ret    

f01007bd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	57                   	push   %edi
f01007c1:	56                   	push   %esi
f01007c2:	53                   	push   %ebx
f01007c3:	83 ec 18             	sub    $0x18,%esp
f01007c6:	e8 f1 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007cb:	81 c3 39 0b 01 00    	add    $0x10b39,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d1:	8d 83 09 0c ff ff    	lea    -0xf3f7(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 54 03 00 00       	call   f0100b31 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dd:	83 c4 08             	add    $0x8,%esp
f01007e0:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f01007e6:	8d 83 b4 0c ff ff    	lea    -0xf34c(%ebx),%eax
f01007ec:	50                   	push   %eax
f01007ed:	e8 3f 03 00 00       	call   f0100b31 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100801:	50                   	push   %eax
f0100802:	57                   	push   %edi
f0100803:	8d 83 dc 0c ff ff    	lea    -0xf324(%ebx),%eax
f0100809:	50                   	push   %eax
f010080a:	e8 22 03 00 00       	call   f0100b31 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	c7 c0 f1 1b 10 f0    	mov    $0xf0101bf1,%eax
f0100818:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081e:	52                   	push   %edx
f010081f:	50                   	push   %eax
f0100820:	8d 83 00 0d ff ff    	lea    -0xf300(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 05 03 00 00       	call   f0100b31 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100835:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083b:	52                   	push   %edx
f010083c:	50                   	push   %eax
f010083d:	8d 83 24 0d ff ff    	lea    -0xf2dc(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 e8 02 00 00       	call   f0100b31 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f0100852:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100858:	50                   	push   %eax
f0100859:	56                   	push   %esi
f010085a:	8d 83 48 0d ff ff    	lea    -0xf2b8(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 cb 02 00 00       	call   f0100b31 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100869:	29 fe                	sub    %edi,%esi
f010086b:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	c1 fe 0a             	sar    $0xa,%esi
f0100874:	56                   	push   %esi
f0100875:	8d 83 6c 0d ff ff    	lea    -0xf294(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 b0 02 00 00       	call   f0100b31 <cprintf>
	return 0;
}
f0100881:	b8 00 00 00 00       	mov    $0x0,%eax
f0100886:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5f                   	pop    %edi
f010088c:	5d                   	pop    %ebp
f010088d:	c3                   	ret    

f010088e <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088e:	55                   	push   %ebp
f010088f:	89 e5                	mov    %esp,%ebp
f0100891:	57                   	push   %edi
f0100892:	56                   	push   %esi
f0100893:	53                   	push   %ebx
f0100894:	83 ec 58             	sub    $0x58,%esp
f0100897:	e8 20 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010089c:	81 c3 68 0a 01 00    	add    $0x10a68,%ebx
    cprintf("Stack backtrace:\n");
f01008a2:	8d 83 22 0c ff ff    	lea    -0xf3de(%ebx),%eax
f01008a8:	50                   	push   %eax
f01008a9:	e8 83 02 00 00       	call   f0100b31 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 e8                	mov    %ebp,%eax
f01008b0:	89 c6                	mov    %eax,%esi
    
    uint32_t ebp = read_ebp();
    
    while (ebp != 0) {
f01008b2:	83 c4 10             	add    $0x10,%esp
        
        for (int i = 0; i < 5; i++) {
            args[i] = *(uint32_t *)(ebp + 8 + i * 4);
        }
        
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008b5:	8d 83 98 0d ff ff    	lea    -0xf268(%ebx),%eax
f01008bb:	89 45 b0             	mov    %eax,-0x50(%ebp)
                ebp, eip, args[0], args[1], args[2], args[3], args[4]);
        
        // 确保这部分代码存在且被调用
        struct Eipdebuginfo info;
        cprintf("DEBUG: Calling debuginfo_eip for eip %08x\n", eip);  // 添加这个调试输出
f01008be:	8d 83 d0 0d ff ff    	lea    -0xf230(%ebx),%eax
f01008c4:	89 45 ac             	mov    %eax,-0x54(%ebp)
    while (ebp != 0) {
f01008c7:	eb 02                	jmp    f01008cb <mon_backtrace+0x3d>
                    info.eip_file, info.eip_line,
                    info.eip_fn_namelen, info.eip_fn_name,
                    eip - info.eip_fn_addr);
        }
        
        ebp = *(uint32_t *)ebp;
f01008c9:	8b 36                	mov    (%esi),%esi
    while (ebp != 0) {
f01008cb:	85 f6                	test   %esi,%esi
f01008cd:	0f 84 98 00 00 00    	je     f010096b <mon_backtrace+0xdd>
        uint32_t eip = *(uint32_t *)(ebp + 4);
f01008d3:	8b 7e 04             	mov    0x4(%esi),%edi
f01008d6:	8d 46 08             	lea    0x8(%esi),%eax
f01008d9:	8d 4e 1c             	lea    0x1c(%esi),%ecx
            args[i] = *(uint32_t *)(ebp + 8 + i * 4);
f01008dc:	8d 55 bc             	lea    -0x44(%ebp),%edx
f01008df:	29 f2                	sub    %esi,%edx
f01008e1:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f01008e4:	8b 30                	mov    (%eax),%esi
f01008e6:	89 74 02 f8          	mov    %esi,-0x8(%edx,%eax,1)
        for (int i = 0; i < 5; i++) {
f01008ea:	83 c0 04             	add    $0x4,%eax
f01008ed:	39 c8                	cmp    %ecx,%eax
f01008ef:	75 f3                	jne    f01008e4 <mon_backtrace+0x56>
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008f1:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f01008f4:	ff 75 cc             	push   -0x34(%ebp)
f01008f7:	ff 75 c8             	push   -0x38(%ebp)
f01008fa:	ff 75 c4             	push   -0x3c(%ebp)
f01008fd:	ff 75 c0             	push   -0x40(%ebp)
f0100900:	ff 75 bc             	push   -0x44(%ebp)
f0100903:	57                   	push   %edi
f0100904:	56                   	push   %esi
f0100905:	ff 75 b0             	push   -0x50(%ebp)
f0100908:	e8 24 02 00 00       	call   f0100b31 <cprintf>
        cprintf("DEBUG: Calling debuginfo_eip for eip %08x\n", eip);  // 添加这个调试输出
f010090d:	83 c4 18             	add    $0x18,%esp
f0100910:	57                   	push   %edi
f0100911:	ff 75 ac             	push   -0x54(%ebp)
f0100914:	e8 18 02 00 00       	call   f0100b31 <cprintf>
        int ret = debuginfo_eip(eip, &info);
f0100919:	83 c4 08             	add    $0x8,%esp
f010091c:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010091f:	50                   	push   %eax
f0100920:	57                   	push   %edi
f0100921:	e8 14 03 00 00       	call   f0100c3a <debuginfo_eip>
        cprintf("DEBUG: debuginfo_eip returned: %d\n", ret);
f0100926:	83 c4 08             	add    $0x8,%esp
f0100929:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f010092c:	50                   	push   %eax
f010092d:	8d 83 fc 0d ff ff    	lea    -0xf204(%ebx),%eax
f0100933:	50                   	push   %eax
f0100934:	e8 f8 01 00 00       	call   f0100b31 <cprintf>
        if (ret == 0) {
f0100939:	83 c4 10             	add    $0x10,%esp
f010093c:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0100940:	75 87                	jne    f01008c9 <mon_backtrace+0x3b>
            cprintf("         %s:%d: %.*s+%d\n",
f0100942:	83 ec 08             	sub    $0x8,%esp
f0100945:	89 f8                	mov    %edi,%eax
f0100947:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010094a:	50                   	push   %eax
f010094b:	ff 75 d8             	push   -0x28(%ebp)
f010094e:	ff 75 dc             	push   -0x24(%ebp)
f0100951:	ff 75 d4             	push   -0x2c(%ebp)
f0100954:	ff 75 d0             	push   -0x30(%ebp)
f0100957:	8d 83 34 0c ff ff    	lea    -0xf3cc(%ebx),%eax
f010095d:	50                   	push   %eax
f010095e:	e8 ce 01 00 00       	call   f0100b31 <cprintf>
f0100963:	83 c4 20             	add    $0x20,%esp
f0100966:	e9 5e ff ff ff       	jmp    f01008c9 <mon_backtrace+0x3b>
    }
    
    return 0;
}
f010096b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100970:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100973:	5b                   	pop    %ebx
f0100974:	5e                   	pop    %esi
f0100975:	5f                   	pop    %edi
f0100976:	5d                   	pop    %ebp
f0100977:	c3                   	ret    

f0100978 <monitor>:



void
monitor(struct Trapframe *tf)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	57                   	push   %edi
f010097c:	56                   	push   %esi
f010097d:	53                   	push   %ebx
f010097e:	83 ec 68             	sub    $0x68,%esp
f0100981:	e8 36 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100986:	81 c3 7e 09 01 00    	add    $0x1097e,%ebx
    char *buf;

    cprintf("Welcome to the JOS kernel monitor!\n");
f010098c:	8d 83 20 0e ff ff    	lea    -0xf1e0(%ebx),%eax
f0100992:	50                   	push   %eax
f0100993:	e8 99 01 00 00       	call   f0100b31 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
f0100998:	8d 83 44 0e ff ff    	lea    -0xf1bc(%ebx),%eax
f010099e:	89 04 24             	mov    %eax,(%esp)
f01009a1:	e8 8b 01 00 00       	call   f0100b31 <cprintf>
f01009a6:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009a9:	8d bb 51 0c ff ff    	lea    -0xf3af(%ebx),%edi
f01009af:	eb 4a                	jmp    f01009fb <monitor+0x83>
f01009b1:	83 ec 08             	sub    $0x8,%esp
f01009b4:	0f be c0             	movsbl %al,%eax
f01009b7:	50                   	push   %eax
f01009b8:	57                   	push   %edi
f01009b9:	e8 c5 0d 00 00       	call   f0101783 <strchr>
f01009be:	83 c4 10             	add    $0x10,%esp
f01009c1:	85 c0                	test   %eax,%eax
f01009c3:	74 08                	je     f01009cd <monitor+0x55>
			*buf++ = 0;
f01009c5:	c6 06 00             	movb   $0x0,(%esi)
f01009c8:	8d 76 01             	lea    0x1(%esi),%esi
f01009cb:	eb 76                	jmp    f0100a43 <monitor+0xcb>
		if (*buf == 0)
f01009cd:	80 3e 00             	cmpb   $0x0,(%esi)
f01009d0:	74 7c                	je     f0100a4e <monitor+0xd6>
		if (argc == MAXARGS-1) {
f01009d2:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009d6:	74 0f                	je     f01009e7 <monitor+0x6f>
		argv[argc++] = buf;
f01009d8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009db:	8d 48 01             	lea    0x1(%eax),%ecx
f01009de:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009e1:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e5:	eb 41                	jmp    f0100a28 <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009e7:	83 ec 08             	sub    $0x8,%esp
f01009ea:	6a 10                	push   $0x10
f01009ec:	8d 83 56 0c ff ff    	lea    -0xf3aa(%ebx),%eax
f01009f2:	50                   	push   %eax
f01009f3:	e8 39 01 00 00       	call   f0100b31 <cprintf>
			return 0;
f01009f8:	83 c4 10             	add    $0x10,%esp

    while (1) {
        buf = readline("K> ");
f01009fb:	8d 83 4d 0c ff ff    	lea    -0xf3b3(%ebx),%eax
f0100a01:	89 c6                	mov    %eax,%esi
f0100a03:	83 ec 0c             	sub    $0xc,%esp
f0100a06:	56                   	push   %esi
f0100a07:	e8 26 0b 00 00       	call   f0101532 <readline>
        if (buf != NULL)
f0100a0c:	83 c4 10             	add    $0x10,%esp
f0100a0f:	85 c0                	test   %eax,%eax
f0100a11:	74 f0                	je     f0100a03 <monitor+0x8b>
	argv[argc] = 0;
f0100a13:	89 c6                	mov    %eax,%esi
f0100a15:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a1c:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a23:	eb 1e                	jmp    f0100a43 <monitor+0xcb>
			buf++;
f0100a25:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a28:	0f b6 06             	movzbl (%esi),%eax
f0100a2b:	84 c0                	test   %al,%al
f0100a2d:	74 14                	je     f0100a43 <monitor+0xcb>
f0100a2f:	83 ec 08             	sub    $0x8,%esp
f0100a32:	0f be c0             	movsbl %al,%eax
f0100a35:	50                   	push   %eax
f0100a36:	57                   	push   %edi
f0100a37:	e8 47 0d 00 00       	call   f0101783 <strchr>
f0100a3c:	83 c4 10             	add    $0x10,%esp
f0100a3f:	85 c0                	test   %eax,%eax
f0100a41:	74 e2                	je     f0100a25 <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a43:	0f b6 06             	movzbl (%esi),%eax
f0100a46:	84 c0                	test   %al,%al
f0100a48:	0f 85 63 ff ff ff    	jne    f01009b1 <monitor+0x39>
	argv[argc] = 0;
f0100a4e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a51:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a58:	00 
	if (argc == 0)
f0100a59:	85 c0                	test   %eax,%eax
f0100a5b:	74 9e                	je     f01009fb <monitor+0x83>
f0100a5d:	8d b3 1c 1d 00 00    	lea    0x1d1c(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a68:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a6b:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a6d:	83 ec 08             	sub    $0x8,%esp
f0100a70:	ff 36                	push   (%esi)
f0100a72:	ff 75 a8             	push   -0x58(%ebp)
f0100a75:	e8 a9 0c 00 00       	call   f0101723 <strcmp>
f0100a7a:	83 c4 10             	add    $0x10,%esp
f0100a7d:	85 c0                	test   %eax,%eax
f0100a7f:	74 28                	je     f0100aa9 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a81:	83 c7 01             	add    $0x1,%edi
f0100a84:	83 c6 0c             	add    $0xc,%esi
f0100a87:	83 ff 03             	cmp    $0x3,%edi
f0100a8a:	75 e1                	jne    f0100a6d <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a8c:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a8f:	83 ec 08             	sub    $0x8,%esp
f0100a92:	ff 75 a8             	push   -0x58(%ebp)
f0100a95:	8d 83 73 0c ff ff    	lea    -0xf38d(%ebx),%eax
f0100a9b:	50                   	push   %eax
f0100a9c:	e8 90 00 00 00       	call   f0100b31 <cprintf>
	return 0;
f0100aa1:	83 c4 10             	add    $0x10,%esp
f0100aa4:	e9 52 ff ff ff       	jmp    f01009fb <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100aa9:	89 f8                	mov    %edi,%eax
f0100aab:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100aae:	83 ec 04             	sub    $0x4,%esp
f0100ab1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ab4:	ff 75 08             	push   0x8(%ebp)
f0100ab7:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aba:	52                   	push   %edx
f0100abb:	ff 75 a4             	push   -0x5c(%ebp)
f0100abe:	ff 94 83 24 1d 00 00 	call   *0x1d24(%ebx,%eax,4)
            if (runcmd(buf, tf) < 0)
f0100ac5:	83 c4 10             	add    $0x10,%esp
f0100ac8:	85 c0                	test   %eax,%eax
f0100aca:	0f 89 2b ff ff ff    	jns    f01009fb <monitor+0x83>
                break;
    }
}
f0100ad0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad3:	5b                   	pop    %ebx
f0100ad4:	5e                   	pop    %esi
f0100ad5:	5f                   	pop    %edi
f0100ad6:	5d                   	pop    %ebp
f0100ad7:	c3                   	ret    

f0100ad8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
f0100adb:	53                   	push   %ebx
f0100adc:	83 ec 10             	sub    $0x10,%esp
f0100adf:	e8 d8 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ae4:	81 c3 20 08 01 00    	add    $0x10820,%ebx
	cputchar(ch);
f0100aea:	ff 75 08             	push   0x8(%ebp)
f0100aed:	e8 35 fc ff ff       	call   f0100727 <cputchar>
	*cnt++;
}
f0100af2:	83 c4 10             	add    $0x10,%esp
f0100af5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100af8:	c9                   	leave  
f0100af9:	c3                   	ret    

f0100afa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100afa:	55                   	push   %ebp
f0100afb:	89 e5                	mov    %esp,%ebp
f0100afd:	53                   	push   %ebx
f0100afe:	83 ec 14             	sub    $0x14,%esp
f0100b01:	e8 b6 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100b06:	81 c3 fe 07 01 00    	add    $0x107fe,%ebx
	int cnt = 0;
f0100b0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b13:	ff 75 0c             	push   0xc(%ebp)
f0100b16:	ff 75 08             	push   0x8(%ebp)
f0100b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b1c:	50                   	push   %eax
f0100b1d:	8d 83 d4 f7 fe ff    	lea    -0x1082c(%ebx),%eax
f0100b23:	50                   	push   %eax
f0100b24:	e8 e8 04 00 00       	call   f0101011 <vprintfmt>
	return cnt;
}
f0100b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b2f:	c9                   	leave  
f0100b30:	c3                   	ret    

f0100b31 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b31:	55                   	push   %ebp
f0100b32:	89 e5                	mov    %esp,%ebp
f0100b34:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b37:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b3a:	50                   	push   %eax
f0100b3b:	ff 75 08             	push   0x8(%ebp)
f0100b3e:	e8 b7 ff ff ff       	call   f0100afa <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b43:	c9                   	leave  
f0100b44:	c3                   	ret    

f0100b45 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b45:	55                   	push   %ebp
f0100b46:	89 e5                	mov    %esp,%ebp
f0100b48:	57                   	push   %edi
f0100b49:	56                   	push   %esi
f0100b4a:	53                   	push   %ebx
f0100b4b:	83 ec 14             	sub    $0x14,%esp
f0100b4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b51:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b54:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b57:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b5a:	8b 1a                	mov    (%edx),%ebx
f0100b5c:	8b 01                	mov    (%ecx),%eax
f0100b5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b61:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b68:	eb 2f                	jmp    f0100b99 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b6a:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b6d:	39 c3                	cmp    %eax,%ebx
f0100b6f:	7f 4e                	jg     f0100bbf <stab_binsearch+0x7a>
f0100b71:	0f b6 0a             	movzbl (%edx),%ecx
f0100b74:	83 ea 0c             	sub    $0xc,%edx
f0100b77:	39 f1                	cmp    %esi,%ecx
f0100b79:	75 ef                	jne    f0100b6a <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b7b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b7e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b81:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b85:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b88:	73 3a                	jae    f0100bc4 <stab_binsearch+0x7f>
			*region_left = m;
f0100b8a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b8d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b8f:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100b92:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b99:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b9c:	7f 53                	jg     f0100bf1 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ba1:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100ba4:	89 d0                	mov    %edx,%eax
f0100ba6:	c1 e8 1f             	shr    $0x1f,%eax
f0100ba9:	01 d0                	add    %edx,%eax
f0100bab:	89 c7                	mov    %eax,%edi
f0100bad:	d1 ff                	sar    %edi
f0100baf:	83 e0 fe             	and    $0xfffffffe,%eax
f0100bb2:	01 f8                	add    %edi,%eax
f0100bb4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bb7:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100bbb:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bbd:	eb ae                	jmp    f0100b6d <stab_binsearch+0x28>
			l = true_m + 1;
f0100bbf:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100bc2:	eb d5                	jmp    f0100b99 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100bc4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bc7:	76 14                	jbe    f0100bdd <stab_binsearch+0x98>
			*region_right = m - 1;
f0100bc9:	83 e8 01             	sub    $0x1,%eax
f0100bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bcf:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bd2:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100bd4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bdb:	eb bc                	jmp    f0100b99 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100be0:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100be2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100be6:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100be8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bef:	eb a8                	jmp    f0100b99 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bf1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bf5:	75 15                	jne    f0100c0c <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bfa:	8b 00                	mov    (%eax),%eax
f0100bfc:	83 e8 01             	sub    $0x1,%eax
f0100bff:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c02:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c04:	83 c4 14             	add    $0x14,%esp
f0100c07:	5b                   	pop    %ebx
f0100c08:	5e                   	pop    %esi
f0100c09:	5f                   	pop    %edi
f0100c0a:	5d                   	pop    %ebp
f0100c0b:	c3                   	ret    
		for (l = *region_right;
f0100c0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c0f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c14:	8b 0f                	mov    (%edi),%ecx
f0100c16:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c19:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c1c:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100c20:	39 c1                	cmp    %eax,%ecx
f0100c22:	7d 0f                	jge    f0100c33 <stab_binsearch+0xee>
f0100c24:	0f b6 1a             	movzbl (%edx),%ebx
f0100c27:	83 ea 0c             	sub    $0xc,%edx
f0100c2a:	39 f3                	cmp    %esi,%ebx
f0100c2c:	74 05                	je     f0100c33 <stab_binsearch+0xee>
		     l--)
f0100c2e:	83 e8 01             	sub    $0x1,%eax
f0100c31:	eb ed                	jmp    f0100c20 <stab_binsearch+0xdb>
		*region_left = l;
f0100c33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c36:	89 07                	mov    %eax,(%edi)
}
f0100c38:	eb ca                	jmp    f0100c04 <stab_binsearch+0xbf>

f0100c3a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c3a:	55                   	push   %ebp
f0100c3b:	89 e5                	mov    %esp,%ebp
f0100c3d:	57                   	push   %edi
f0100c3e:	56                   	push   %esi
f0100c3f:	53                   	push   %ebx
f0100c40:	83 ec 3c             	sub    $0x3c,%esp
f0100c43:	e8 74 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c48:	81 c3 bc 06 01 00    	add    $0x106bc,%ebx
f0100c4e:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c51:	8d 83 69 0e ff ff    	lea    -0xf197(%ebx),%eax
f0100c57:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c59:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c60:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c63:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c6d:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c70:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c77:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0100c7c:	0f 86 b2 01 00 00    	jbe    f0100e34 <debuginfo_eip+0x1fa>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
// 添加调试输出 1: 检查 STAB 表信息
        cprintf("DEBUG: stabs=%p, stab_end=%p, num_stabs=%d\n", 
                stabs, stab_end, (int)(stab_end - stabs));
f0100c82:	c7 c1 74 5e 10 f0    	mov    $0xf0105e74,%ecx
f0100c88:	c7 c2 6c 24 10 f0    	mov    $0xf010246c,%edx
f0100c8e:	89 c8                	mov    %ecx,%eax
f0100c90:	29 d0                	sub    %edx,%eax
        cprintf("DEBUG: stabs=%p, stab_end=%p, num_stabs=%d\n", 
f0100c92:	c1 f8 02             	sar    $0x2,%eax
f0100c95:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100c9b:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100c9e:	50                   	push   %eax
f0100c9f:	51                   	push   %ecx
f0100ca0:	52                   	push   %edx
f0100ca1:	8d 83 90 0e ff ff    	lea    -0xf170(%ebx),%eax
f0100ca7:	50                   	push   %eax
f0100ca8:	e8 84 fe ff ff       	call   f0100b31 <cprintf>
        cprintf("DEBUG: stabstr=%p, stabstr_end=%p\n", stabstr, stabstr_end);
f0100cad:	83 c4 0c             	add    $0xc,%esp
f0100cb0:	c7 c7 d6 74 10 f0    	mov    $0xf01074d6,%edi
f0100cb6:	57                   	push   %edi
f0100cb7:	c7 c0 75 5e 10 f0    	mov    $0xf0105e75,%eax
f0100cbd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100cc0:	50                   	push   %eax
f0100cc1:	8d 83 bc 0e ff ff    	lea    -0xf144(%ebx),%eax
f0100cc7:	50                   	push   %eax
f0100cc8:	e8 64 fe ff ff       	call   f0100b31 <cprintf>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ccd:	83 c4 10             	add    $0x10,%esp
f0100cd0:	3b 7d c4             	cmp    -0x3c(%ebp),%edi
f0100cd3:	0f 86 17 02 00 00    	jbe    f0100ef0 <debuginfo_eip+0x2b6>
f0100cd9:	c7 c0 d6 74 10 f0    	mov    $0xf01074d6,%eax
f0100cdf:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100ce3:	0f 85 0e 02 00 00    	jne    f0100ef7 <debuginfo_eip+0x2bd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ce9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100cf0:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100cf3:	83 e8 01             	sub    $0x1,%eax
f0100cf6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cf9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cfc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cff:	83 ec 08             	sub    $0x8,%esp
f0100d02:	ff 75 08             	push   0x8(%ebp)
f0100d05:	6a 64                	push   $0x64
f0100d07:	c7 c0 6c 24 10 f0    	mov    $0xf010246c,%eax
f0100d0d:	e8 33 fe ff ff       	call   f0100b45 <stab_binsearch>
// 添加调试输出 2: 检查文件查找结果
    cprintf("DEBUG: file search for addr %p: lfile=%d, rfile=%d\n", addr, lfile, rfile);
f0100d12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d15:	89 c7                	mov    %eax,%edi
f0100d17:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0100d1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d1d:	50                   	push   %eax
f0100d1e:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d21:	52                   	push   %edx
f0100d22:	ff 75 08             	push   0x8(%ebp)
f0100d25:	8d 83 e0 0e ff ff    	lea    -0xf120(%ebx),%eax
f0100d2b:	50                   	push   %eax
f0100d2c:	e8 00 fe ff ff       	call   f0100b31 <cprintf>
	if (lfile == 0)
f0100d31:	83 c4 20             	add    $0x20,%esp
f0100d34:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d37:	85 d2                	test   %edx,%edx
f0100d39:	0f 84 bf 01 00 00    	je     f0100efe <debuginfo_eip+0x2c4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d3f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100d42:	89 7d d8             	mov    %edi,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d45:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d48:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d4b:	83 ec 08             	sub    $0x8,%esp
f0100d4e:	ff 75 08             	push   0x8(%ebp)
f0100d51:	6a 24                	push   $0x24
f0100d53:	c7 c0 6c 24 10 f0    	mov    $0xf010246c,%eax
f0100d59:	e8 e7 fd ff ff       	call   f0100b45 <stab_binsearch>

// 添加调试输出 3: 检查函数查找结果
    cprintf("DEBUG: function search: lfun=%d, rfun=%d\n", lfun, rfun);
f0100d5e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d64:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0100d67:	83 c4 0c             	add    $0xc,%esp
f0100d6a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0100d6d:	52                   	push   %edx
f0100d6e:	89 c7                	mov    %eax,%edi
f0100d70:	50                   	push   %eax
f0100d71:	8d 83 14 0f ff ff    	lea    -0xf0ec(%ebx),%eax
f0100d77:	50                   	push   %eax
f0100d78:	e8 b4 fd ff ff       	call   f0100b31 <cprintf>

	if (lfun <= rfun) {
f0100d7d:	83 c4 10             	add    $0x10,%esp
f0100d80:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100d83:	0f 8c c6 00 00 00    	jl     f0100e4f <debuginfo_eip+0x215>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d89:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d8c:	c7 c2 6c 24 10 f0    	mov    $0xf010246c,%edx
f0100d92:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0100d95:	8b 0a                	mov    (%edx),%ecx
f0100d97:	c7 c0 d6 74 10 f0    	mov    $0xf01074d6,%eax
f0100d9d:	81 e8 75 5e 10 f0    	sub    $0xf0105e75,%eax
f0100da3:	39 c1                	cmp    %eax,%ecx
f0100da5:	73 09                	jae    f0100db0 <debuginfo_eip+0x176>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100da7:	81 c1 75 5e 10 f0    	add    $0xf0105e75,%ecx
f0100dad:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100db0:	8b 42 08             	mov    0x8(%edx),%eax
f0100db3:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100db6:	29 45 08             	sub    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0100db9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100dbc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		rline = rfun;
f0100dbf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100dc2:	89 7d d0             	mov    %edi,-0x30(%ebp)

// 添加调试输出 4: 显示找到的函数信息
        cprintf("DEBUG: found function '%s' at value %p, strx=%d\n", 
f0100dc5:	ff 32                	push   (%edx)
f0100dc7:	50                   	push   %eax
f0100dc8:	ff 76 08             	push   0x8(%esi)
f0100dcb:	8d 83 40 0f ff ff    	lea    -0xf0c0(%ebx),%eax
f0100dd1:	50                   	push   %eax
f0100dd2:	e8 5a fd ff ff       	call   f0100b31 <cprintf>
f0100dd7:	83 c4 10             	add    $0x10,%esp
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100dda:	83 ec 08             	sub    $0x8,%esp
f0100ddd:	6a 3a                	push   $0x3a
f0100ddf:	ff 76 08             	push   0x8(%esi)
f0100de2:	e8 bf 09 00 00       	call   f01017a6 <strfind>
f0100de7:	2b 46 08             	sub    0x8(%esi),%eax
f0100dea:	89 46 0c             	mov    %eax,0xc(%esi)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

        // 在 [lline, rline] 范围内查找行号
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100ded:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100df0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100df3:	83 c4 08             	add    $0x8,%esp
f0100df6:	ff 75 08             	push   0x8(%ebp)
f0100df9:	6a 44                	push   $0x44
f0100dfb:	c7 c0 6c 24 10 f0    	mov    $0xf010246c,%eax
f0100e01:	e8 3f fd ff ff       	call   f0100b45 <stab_binsearch>
        if (lline <= rline) {
f0100e06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e09:	83 c4 10             	add    $0x10,%esp
f0100e0c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100e0f:	0f 8f f0 00 00 00    	jg     f0100f05 <debuginfo_eip+0x2cb>
                info->eip_line = stabs[lline].n_desc;
f0100e15:	89 c2                	mov    %eax,%edx
f0100e17:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e1a:	c7 c0 6c 24 10 f0    	mov    $0xf010246c,%eax
f0100e20:	0f b7 7c 88 06       	movzwl 0x6(%eax,%ecx,4),%edi
f0100e25:	89 7e 04             	mov    %edi,0x4(%esi)
f0100e28:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100e2c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e2f:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e32:	eb 38                	jmp    f0100e6c <debuginfo_eip+0x232>
  	        panic("User address");
f0100e34:	83 ec 04             	sub    $0x4,%esp
f0100e37:	8d 83 73 0e ff ff    	lea    -0xf18d(%ebx),%eax
f0100e3d:	50                   	push   %eax
f0100e3e:	68 83 00 00 00       	push   $0x83
f0100e43:	8d 83 80 0e ff ff    	lea    -0xf180(%ebx),%eax
f0100e49:	50                   	push   %eax
f0100e4a:	e8 b7 f2 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100e4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e52:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0100e55:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100e58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e5b:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100e5e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e61:	e9 74 ff ff ff       	jmp    f0100dda <debuginfo_eip+0x1a0>
f0100e66:	83 ea 01             	sub    $0x1,%edx
f0100e69:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e6c:	39 d7                	cmp    %edx,%edi
f0100e6e:	7f 3c                	jg     f0100eac <debuginfo_eip+0x272>
	       && stabs[lline].n_type != N_SOL
f0100e70:	0f b6 08             	movzbl (%eax),%ecx
f0100e73:	80 f9 84             	cmp    $0x84,%cl
f0100e76:	74 0b                	je     f0100e83 <debuginfo_eip+0x249>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e78:	80 f9 64             	cmp    $0x64,%cl
f0100e7b:	75 e9                	jne    f0100e66 <debuginfo_eip+0x22c>
f0100e7d:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e81:	74 e3                	je     f0100e66 <debuginfo_eip+0x22c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e83:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e86:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e89:	c7 c0 6c 24 10 f0    	mov    $0xf010246c,%eax
f0100e8f:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e92:	c7 c0 d6 74 10 f0    	mov    $0xf01074d6,%eax
f0100e98:	81 e8 75 5e 10 f0    	sub    $0xf0105e75,%eax
f0100e9e:	39 c2                	cmp    %eax,%edx
f0100ea0:	73 0d                	jae    f0100eaf <debuginfo_eip+0x275>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ea2:	81 c2 75 5e 10 f0    	add    $0xf0105e75,%edx
f0100ea8:	89 16                	mov    %edx,(%esi)
f0100eaa:	eb 03                	jmp    f0100eaf <debuginfo_eip+0x275>
f0100eac:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100eaf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100eb4:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100eb7:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100eba:	7e 55                	jle    f0100f11 <debuginfo_eip+0x2d7>
		for (lline = lfun + 1;
f0100ebc:	89 f8                	mov    %edi,%eax
f0100ebe:	83 c0 01             	add    $0x1,%eax
f0100ec1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100ec4:	c7 c2 6c 24 10 f0    	mov    $0xf010246c,%edx
f0100eca:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100ece:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ed1:	eb 04                	jmp    f0100ed7 <debuginfo_eip+0x29d>
			info->eip_fn_narg++;
f0100ed3:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ed7:	39 c3                	cmp    %eax,%ebx
f0100ed9:	7e 31                	jle    f0100f0c <debuginfo_eip+0x2d2>
f0100edb:	0f b6 0a             	movzbl (%edx),%ecx
f0100ede:	83 c0 01             	add    $0x1,%eax
f0100ee1:	83 c2 0c             	add    $0xc,%edx
f0100ee4:	80 f9 a0             	cmp    $0xa0,%cl
f0100ee7:	74 ea                	je     f0100ed3 <debuginfo_eip+0x299>
	return 0;
f0100ee9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eee:	eb 21                	jmp    f0100f11 <debuginfo_eip+0x2d7>
		return -1;
f0100ef0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ef5:	eb 1a                	jmp    f0100f11 <debuginfo_eip+0x2d7>
f0100ef7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100efc:	eb 13                	jmp    f0100f11 <debuginfo_eip+0x2d7>
		return -1;
f0100efe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f03:	eb 0c                	jmp    f0100f11 <debuginfo_eip+0x2d7>
                return -1;
f0100f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f0a:	eb 05                	jmp    f0100f11 <debuginfo_eip+0x2d7>
	return 0;
f0100f0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f14:	5b                   	pop    %ebx
f0100f15:	5e                   	pop    %esi
f0100f16:	5f                   	pop    %edi
f0100f17:	5d                   	pop    %ebp
f0100f18:	c3                   	ret    

f0100f19 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f19:	55                   	push   %ebp
f0100f1a:	89 e5                	mov    %esp,%ebp
f0100f1c:	57                   	push   %edi
f0100f1d:	56                   	push   %esi
f0100f1e:	53                   	push   %ebx
f0100f1f:	83 ec 2c             	sub    $0x2c,%esp
f0100f22:	e8 07 06 00 00       	call   f010152e <__x86.get_pc_thunk.cx>
f0100f27:	81 c1 dd 03 01 00    	add    $0x103dd,%ecx
f0100f2d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f30:	89 c7                	mov    %eax,%edi
f0100f32:	89 d6                	mov    %edx,%esi
f0100f34:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f37:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f3a:	89 d1                	mov    %edx,%ecx
f0100f3c:	89 c2                	mov    %eax,%edx
f0100f3e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f41:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100f44:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f47:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f4d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f54:	39 c2                	cmp    %eax,%edx
f0100f56:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100f59:	72 41                	jb     f0100f9c <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f5b:	83 ec 0c             	sub    $0xc,%esp
f0100f5e:	ff 75 18             	push   0x18(%ebp)
f0100f61:	83 eb 01             	sub    $0x1,%ebx
f0100f64:	53                   	push   %ebx
f0100f65:	50                   	push   %eax
f0100f66:	83 ec 08             	sub    $0x8,%esp
f0100f69:	ff 75 e4             	push   -0x1c(%ebp)
f0100f6c:	ff 75 e0             	push   -0x20(%ebp)
f0100f6f:	ff 75 d4             	push   -0x2c(%ebp)
f0100f72:	ff 75 d0             	push   -0x30(%ebp)
f0100f75:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f78:	e8 43 0a 00 00       	call   f01019c0 <__udivdi3>
f0100f7d:	83 c4 18             	add    $0x18,%esp
f0100f80:	52                   	push   %edx
f0100f81:	50                   	push   %eax
f0100f82:	89 f2                	mov    %esi,%edx
f0100f84:	89 f8                	mov    %edi,%eax
f0100f86:	e8 8e ff ff ff       	call   f0100f19 <printnum>
f0100f8b:	83 c4 20             	add    $0x20,%esp
f0100f8e:	eb 13                	jmp    f0100fa3 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f90:	83 ec 08             	sub    $0x8,%esp
f0100f93:	56                   	push   %esi
f0100f94:	ff 75 18             	push   0x18(%ebp)
f0100f97:	ff d7                	call   *%edi
f0100f99:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f9c:	83 eb 01             	sub    $0x1,%ebx
f0100f9f:	85 db                	test   %ebx,%ebx
f0100fa1:	7f ed                	jg     f0100f90 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fa3:	83 ec 08             	sub    $0x8,%esp
f0100fa6:	56                   	push   %esi
f0100fa7:	83 ec 04             	sub    $0x4,%esp
f0100faa:	ff 75 e4             	push   -0x1c(%ebp)
f0100fad:	ff 75 e0             	push   -0x20(%ebp)
f0100fb0:	ff 75 d4             	push   -0x2c(%ebp)
f0100fb3:	ff 75 d0             	push   -0x30(%ebp)
f0100fb6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100fb9:	e8 22 0b 00 00       	call   f0101ae0 <__umoddi3>
f0100fbe:	83 c4 14             	add    $0x14,%esp
f0100fc1:	0f be 84 03 71 0f ff 	movsbl -0xf08f(%ebx,%eax,1),%eax
f0100fc8:	ff 
f0100fc9:	50                   	push   %eax
f0100fca:	ff d7                	call   *%edi
}
f0100fcc:	83 c4 10             	add    $0x10,%esp
f0100fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fd2:	5b                   	pop    %ebx
f0100fd3:	5e                   	pop    %esi
f0100fd4:	5f                   	pop    %edi
f0100fd5:	5d                   	pop    %ebp
f0100fd6:	c3                   	ret    

f0100fd7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fd7:	55                   	push   %ebp
f0100fd8:	89 e5                	mov    %esp,%ebp
f0100fda:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fdd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100fe1:	8b 10                	mov    (%eax),%edx
f0100fe3:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fe6:	73 0a                	jae    f0100ff2 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100fe8:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100feb:	89 08                	mov    %ecx,(%eax)
f0100fed:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ff0:	88 02                	mov    %al,(%edx)
}
f0100ff2:	5d                   	pop    %ebp
f0100ff3:	c3                   	ret    

f0100ff4 <printfmt>:
{
f0100ff4:	55                   	push   %ebp
f0100ff5:	89 e5                	mov    %esp,%ebp
f0100ff7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100ffa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ffd:	50                   	push   %eax
f0100ffe:	ff 75 10             	push   0x10(%ebp)
f0101001:	ff 75 0c             	push   0xc(%ebp)
f0101004:	ff 75 08             	push   0x8(%ebp)
f0101007:	e8 05 00 00 00       	call   f0101011 <vprintfmt>
}
f010100c:	83 c4 10             	add    $0x10,%esp
f010100f:	c9                   	leave  
f0101010:	c3                   	ret    

f0101011 <vprintfmt>:
{
f0101011:	55                   	push   %ebp
f0101012:	89 e5                	mov    %esp,%ebp
f0101014:	57                   	push   %edi
f0101015:	56                   	push   %esi
f0101016:	53                   	push   %ebx
f0101017:	83 ec 3c             	sub    $0x3c,%esp
f010101a:	e8 2f f7 ff ff       	call   f010074e <__x86.get_pc_thunk.ax>
f010101f:	05 e5 02 01 00       	add    $0x102e5,%eax
f0101024:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101027:	8b 75 08             	mov    0x8(%ebp),%esi
f010102a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010102d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101030:	8d 80 40 1d 00 00    	lea    0x1d40(%eax),%eax
f0101036:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101039:	eb 0a                	jmp    f0101045 <vprintfmt+0x34>
			putch(ch, putdat);
f010103b:	83 ec 08             	sub    $0x8,%esp
f010103e:	57                   	push   %edi
f010103f:	50                   	push   %eax
f0101040:	ff d6                	call   *%esi
f0101042:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101045:	83 c3 01             	add    $0x1,%ebx
f0101048:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010104c:	83 f8 25             	cmp    $0x25,%eax
f010104f:	74 0c                	je     f010105d <vprintfmt+0x4c>
			if (ch == '\0')
f0101051:	85 c0                	test   %eax,%eax
f0101053:	75 e6                	jne    f010103b <vprintfmt+0x2a>
}
f0101055:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101058:	5b                   	pop    %ebx
f0101059:	5e                   	pop    %esi
f010105a:	5f                   	pop    %edi
f010105b:	5d                   	pop    %ebp
f010105c:	c3                   	ret    
		padc = ' ';
f010105d:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0101061:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101068:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010106f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101076:	b9 00 00 00 00       	mov    $0x0,%ecx
f010107b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010107e:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101081:	8d 43 01             	lea    0x1(%ebx),%eax
f0101084:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101087:	0f b6 13             	movzbl (%ebx),%edx
f010108a:	8d 42 dd             	lea    -0x23(%edx),%eax
f010108d:	3c 55                	cmp    $0x55,%al
f010108f:	0f 87 fd 03 00 00    	ja     f0101492 <.L20>
f0101095:	0f b6 c0             	movzbl %al,%eax
f0101098:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010109b:	89 ce                	mov    %ecx,%esi
f010109d:	03 b4 81 00 10 ff ff 	add    -0xf000(%ecx,%eax,4),%esi
f01010a4:	ff e6                	jmp    *%esi

f01010a6 <.L68>:
f01010a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01010a9:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01010ad:	eb d2                	jmp    f0101081 <vprintfmt+0x70>

f01010af <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01010af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010b2:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01010b6:	eb c9                	jmp    f0101081 <vprintfmt+0x70>

f01010b8 <.L31>:
f01010b8:	0f b6 d2             	movzbl %dl,%edx
f01010bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01010be:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c3:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01010c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01010c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01010cd:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01010d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01010d3:	83 f9 09             	cmp    $0x9,%ecx
f01010d6:	77 58                	ja     f0101130 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01010d8:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01010db:	eb e9                	jmp    f01010c6 <.L31+0xe>

f01010dd <.L34>:
			precision = va_arg(ap, int);
f01010dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e0:	8b 00                	mov    (%eax),%eax
f01010e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e8:	8d 40 04             	lea    0x4(%eax),%eax
f01010eb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010ee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01010f1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010f5:	79 8a                	jns    f0101081 <vprintfmt+0x70>
				width = precision, precision = -1;
f01010f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010fd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0101104:	e9 78 ff ff ff       	jmp    f0101081 <vprintfmt+0x70>

f0101109 <.L33>:
f0101109:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010110c:	85 d2                	test   %edx,%edx
f010110e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101113:	0f 49 c2             	cmovns %edx,%eax
f0101116:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101119:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010111c:	e9 60 ff ff ff       	jmp    f0101081 <vprintfmt+0x70>

f0101121 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0101121:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0101124:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f010112b:	e9 51 ff ff ff       	jmp    f0101081 <vprintfmt+0x70>
f0101130:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101133:	89 75 08             	mov    %esi,0x8(%ebp)
f0101136:	eb b9                	jmp    f01010f1 <.L34+0x14>

f0101138 <.L27>:
			lflag++;
f0101138:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010113c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010113f:	e9 3d ff ff ff       	jmp    f0101081 <vprintfmt+0x70>

f0101144 <.L30>:
			putch(va_arg(ap, int), putdat);
f0101144:	8b 75 08             	mov    0x8(%ebp),%esi
f0101147:	8b 45 14             	mov    0x14(%ebp),%eax
f010114a:	8d 58 04             	lea    0x4(%eax),%ebx
f010114d:	83 ec 08             	sub    $0x8,%esp
f0101150:	57                   	push   %edi
f0101151:	ff 30                	push   (%eax)
f0101153:	ff d6                	call   *%esi
			break;
f0101155:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101158:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010115b:	e9 c8 02 00 00       	jmp    f0101428 <.L25+0x45>

f0101160 <.L28>:
			err = va_arg(ap, int);
f0101160:	8b 75 08             	mov    0x8(%ebp),%esi
f0101163:	8b 45 14             	mov    0x14(%ebp),%eax
f0101166:	8d 58 04             	lea    0x4(%eax),%ebx
f0101169:	8b 10                	mov    (%eax),%edx
f010116b:	89 d0                	mov    %edx,%eax
f010116d:	f7 d8                	neg    %eax
f010116f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101172:	83 f8 06             	cmp    $0x6,%eax
f0101175:	7f 27                	jg     f010119e <.L28+0x3e>
f0101177:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010117a:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010117d:	85 d2                	test   %edx,%edx
f010117f:	74 1d                	je     f010119e <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0101181:	52                   	push   %edx
f0101182:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101185:	8d 80 92 0f ff ff    	lea    -0xf06e(%eax),%eax
f010118b:	50                   	push   %eax
f010118c:	57                   	push   %edi
f010118d:	56                   	push   %esi
f010118e:	e8 61 fe ff ff       	call   f0100ff4 <printfmt>
f0101193:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101196:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101199:	e9 8a 02 00 00       	jmp    f0101428 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010119e:	50                   	push   %eax
f010119f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011a2:	8d 80 89 0f ff ff    	lea    -0xf077(%eax),%eax
f01011a8:	50                   	push   %eax
f01011a9:	57                   	push   %edi
f01011aa:	56                   	push   %esi
f01011ab:	e8 44 fe ff ff       	call   f0100ff4 <printfmt>
f01011b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01011b3:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01011b6:	e9 6d 02 00 00       	jmp    f0101428 <.L25+0x45>

f01011bb <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01011bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01011be:	8b 45 14             	mov    0x14(%ebp),%eax
f01011c1:	83 c0 04             	add    $0x4,%eax
f01011c4:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01011c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ca:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01011cc:	85 d2                	test   %edx,%edx
f01011ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011d1:	8d 80 82 0f ff ff    	lea    -0xf07e(%eax),%eax
f01011d7:	0f 45 c2             	cmovne %edx,%eax
f01011da:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01011dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01011e1:	7e 06                	jle    f01011e9 <.L24+0x2e>
f01011e3:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01011e7:	75 0d                	jne    f01011f6 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01011ec:	89 c3                	mov    %eax,%ebx
f01011ee:	03 45 d4             	add    -0x2c(%ebp),%eax
f01011f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011f4:	eb 58                	jmp    f010124e <.L24+0x93>
f01011f6:	83 ec 08             	sub    $0x8,%esp
f01011f9:	ff 75 d8             	push   -0x28(%ebp)
f01011fc:	ff 75 c8             	push   -0x38(%ebp)
f01011ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101202:	e8 48 04 00 00       	call   f010164f <strnlen>
f0101207:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010120a:	29 c2                	sub    %eax,%edx
f010120c:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010120f:	83 c4 10             	add    $0x10,%esp
f0101212:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0101214:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101218:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010121b:	eb 0f                	jmp    f010122c <.L24+0x71>
					putch(padc, putdat);
f010121d:	83 ec 08             	sub    $0x8,%esp
f0101220:	57                   	push   %edi
f0101221:	ff 75 d4             	push   -0x2c(%ebp)
f0101224:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101226:	83 eb 01             	sub    $0x1,%ebx
f0101229:	83 c4 10             	add    $0x10,%esp
f010122c:	85 db                	test   %ebx,%ebx
f010122e:	7f ed                	jg     f010121d <.L24+0x62>
f0101230:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0101233:	85 d2                	test   %edx,%edx
f0101235:	b8 00 00 00 00       	mov    $0x0,%eax
f010123a:	0f 49 c2             	cmovns %edx,%eax
f010123d:	29 c2                	sub    %eax,%edx
f010123f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101242:	eb a5                	jmp    f01011e9 <.L24+0x2e>
					putch(ch, putdat);
f0101244:	83 ec 08             	sub    $0x8,%esp
f0101247:	57                   	push   %edi
f0101248:	52                   	push   %edx
f0101249:	ff d6                	call   *%esi
f010124b:	83 c4 10             	add    $0x10,%esp
f010124e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101251:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101253:	83 c3 01             	add    $0x1,%ebx
f0101256:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010125a:	0f be d0             	movsbl %al,%edx
f010125d:	85 d2                	test   %edx,%edx
f010125f:	74 4b                	je     f01012ac <.L24+0xf1>
f0101261:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101265:	78 06                	js     f010126d <.L24+0xb2>
f0101267:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010126b:	78 1e                	js     f010128b <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010126d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101271:	74 d1                	je     f0101244 <.L24+0x89>
f0101273:	0f be c0             	movsbl %al,%eax
f0101276:	83 e8 20             	sub    $0x20,%eax
f0101279:	83 f8 5e             	cmp    $0x5e,%eax
f010127c:	76 c6                	jbe    f0101244 <.L24+0x89>
					putch('?', putdat);
f010127e:	83 ec 08             	sub    $0x8,%esp
f0101281:	57                   	push   %edi
f0101282:	6a 3f                	push   $0x3f
f0101284:	ff d6                	call   *%esi
f0101286:	83 c4 10             	add    $0x10,%esp
f0101289:	eb c3                	jmp    f010124e <.L24+0x93>
f010128b:	89 cb                	mov    %ecx,%ebx
f010128d:	eb 0e                	jmp    f010129d <.L24+0xe2>
				putch(' ', putdat);
f010128f:	83 ec 08             	sub    $0x8,%esp
f0101292:	57                   	push   %edi
f0101293:	6a 20                	push   $0x20
f0101295:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101297:	83 eb 01             	sub    $0x1,%ebx
f010129a:	83 c4 10             	add    $0x10,%esp
f010129d:	85 db                	test   %ebx,%ebx
f010129f:	7f ee                	jg     f010128f <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01012a1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01012a4:	89 45 14             	mov    %eax,0x14(%ebp)
f01012a7:	e9 7c 01 00 00       	jmp    f0101428 <.L25+0x45>
f01012ac:	89 cb                	mov    %ecx,%ebx
f01012ae:	eb ed                	jmp    f010129d <.L24+0xe2>

f01012b0 <.L29>:
	if (lflag >= 2)
f01012b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01012b6:	83 f9 01             	cmp    $0x1,%ecx
f01012b9:	7f 1b                	jg     f01012d6 <.L29+0x26>
	else if (lflag)
f01012bb:	85 c9                	test   %ecx,%ecx
f01012bd:	74 63                	je     f0101322 <.L29+0x72>
		return va_arg(*ap, long);
f01012bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c2:	8b 00                	mov    (%eax),%eax
f01012c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012c7:	99                   	cltd   
f01012c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ce:	8d 40 04             	lea    0x4(%eax),%eax
f01012d1:	89 45 14             	mov    %eax,0x14(%ebp)
f01012d4:	eb 17                	jmp    f01012ed <.L29+0x3d>
		return va_arg(*ap, long long);
f01012d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d9:	8b 50 04             	mov    0x4(%eax),%edx
f01012dc:	8b 00                	mov    (%eax),%eax
f01012de:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e7:	8d 40 08             	lea    0x8(%eax),%eax
f01012ea:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01012ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012f0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01012f3:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01012f8:	85 db                	test   %ebx,%ebx
f01012fa:	0f 89 0e 01 00 00    	jns    f010140e <.L25+0x2b>
				putch('-', putdat);
f0101300:	83 ec 08             	sub    $0x8,%esp
f0101303:	57                   	push   %edi
f0101304:	6a 2d                	push   $0x2d
f0101306:	ff d6                	call   *%esi
				num = -(long long) num;
f0101308:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010130b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010130e:	f7 d9                	neg    %ecx
f0101310:	83 d3 00             	adc    $0x0,%ebx
f0101313:	f7 db                	neg    %ebx
f0101315:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101318:	ba 0a 00 00 00       	mov    $0xa,%edx
f010131d:	e9 ec 00 00 00       	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, int);
f0101322:	8b 45 14             	mov    0x14(%ebp),%eax
f0101325:	8b 00                	mov    (%eax),%eax
f0101327:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010132a:	99                   	cltd   
f010132b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010132e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101331:	8d 40 04             	lea    0x4(%eax),%eax
f0101334:	89 45 14             	mov    %eax,0x14(%ebp)
f0101337:	eb b4                	jmp    f01012ed <.L29+0x3d>

f0101339 <.L23>:
	if (lflag >= 2)
f0101339:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010133c:	8b 75 08             	mov    0x8(%ebp),%esi
f010133f:	83 f9 01             	cmp    $0x1,%ecx
f0101342:	7f 1e                	jg     f0101362 <.L23+0x29>
	else if (lflag)
f0101344:	85 c9                	test   %ecx,%ecx
f0101346:	74 32                	je     f010137a <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101348:	8b 45 14             	mov    0x14(%ebp),%eax
f010134b:	8b 08                	mov    (%eax),%ecx
f010134d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101352:	8d 40 04             	lea    0x4(%eax),%eax
f0101355:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101358:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f010135d:	e9 ac 00 00 00       	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101362:	8b 45 14             	mov    0x14(%ebp),%eax
f0101365:	8b 08                	mov    (%eax),%ecx
f0101367:	8b 58 04             	mov    0x4(%eax),%ebx
f010136a:	8d 40 08             	lea    0x8(%eax),%eax
f010136d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101370:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0101375:	e9 94 00 00 00       	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010137a:	8b 45 14             	mov    0x14(%ebp),%eax
f010137d:	8b 08                	mov    (%eax),%ecx
f010137f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101384:	8d 40 04             	lea    0x4(%eax),%eax
f0101387:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010138a:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f010138f:	eb 7d                	jmp    f010140e <.L25+0x2b>

f0101391 <.L26>:
	if (lflag >= 2)
f0101391:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101394:	8b 75 08             	mov    0x8(%ebp),%esi
f0101397:	83 f9 01             	cmp    $0x1,%ecx
f010139a:	7f 1b                	jg     f01013b7 <.L26+0x26>
	else if (lflag)
f010139c:	85 c9                	test   %ecx,%ecx
f010139e:	74 2c                	je     f01013cc <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01013a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a3:	8b 08                	mov    (%eax),%ecx
f01013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013aa:	8d 40 04             	lea    0x4(%eax),%eax
f01013ad:	89 45 14             	mov    %eax,0x14(%ebp)
    			base = 8;
f01013b0:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f01013b5:	eb 57                	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01013b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ba:	8b 08                	mov    (%eax),%ecx
f01013bc:	8b 58 04             	mov    0x4(%eax),%ebx
f01013bf:	8d 40 08             	lea    0x8(%eax),%eax
f01013c2:	89 45 14             	mov    %eax,0x14(%ebp)
    			base = 8;
f01013c5:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f01013ca:	eb 42                	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01013cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01013cf:	8b 08                	mov    (%eax),%ecx
f01013d1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013d6:	8d 40 04             	lea    0x4(%eax),%eax
f01013d9:	89 45 14             	mov    %eax,0x14(%ebp)
    			base = 8;
f01013dc:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f01013e1:	eb 2b                	jmp    f010140e <.L25+0x2b>

f01013e3 <.L25>:
			putch('0', putdat);
f01013e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01013e6:	83 ec 08             	sub    $0x8,%esp
f01013e9:	57                   	push   %edi
f01013ea:	6a 30                	push   $0x30
f01013ec:	ff d6                	call   *%esi
			putch('x', putdat);
f01013ee:	83 c4 08             	add    $0x8,%esp
f01013f1:	57                   	push   %edi
f01013f2:	6a 78                	push   $0x78
f01013f4:	ff d6                	call   *%esi
			num = (unsigned long long)
f01013f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f9:	8b 08                	mov    (%eax),%ecx
f01013fb:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0101400:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101403:	8d 40 04             	lea    0x4(%eax),%eax
f0101406:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101409:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f010140e:	83 ec 0c             	sub    $0xc,%esp
f0101411:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101415:	50                   	push   %eax
f0101416:	ff 75 d4             	push   -0x2c(%ebp)
f0101419:	52                   	push   %edx
f010141a:	53                   	push   %ebx
f010141b:	51                   	push   %ecx
f010141c:	89 fa                	mov    %edi,%edx
f010141e:	89 f0                	mov    %esi,%eax
f0101420:	e8 f4 fa ff ff       	call   f0100f19 <printnum>
			break;
f0101425:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101428:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010142b:	e9 15 fc ff ff       	jmp    f0101045 <vprintfmt+0x34>

f0101430 <.L21>:
	if (lflag >= 2)
f0101430:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101433:	8b 75 08             	mov    0x8(%ebp),%esi
f0101436:	83 f9 01             	cmp    $0x1,%ecx
f0101439:	7f 1b                	jg     f0101456 <.L21+0x26>
	else if (lflag)
f010143b:	85 c9                	test   %ecx,%ecx
f010143d:	74 2c                	je     f010146b <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f010143f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101442:	8b 08                	mov    (%eax),%ecx
f0101444:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101449:	8d 40 04             	lea    0x4(%eax),%eax
f010144c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010144f:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0101454:	eb b8                	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101456:	8b 45 14             	mov    0x14(%ebp),%eax
f0101459:	8b 08                	mov    (%eax),%ecx
f010145b:	8b 58 04             	mov    0x4(%eax),%ebx
f010145e:	8d 40 08             	lea    0x8(%eax),%eax
f0101461:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101464:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0101469:	eb a3                	jmp    f010140e <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010146b:	8b 45 14             	mov    0x14(%ebp),%eax
f010146e:	8b 08                	mov    (%eax),%ecx
f0101470:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101475:	8d 40 04             	lea    0x4(%eax),%eax
f0101478:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010147b:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0101480:	eb 8c                	jmp    f010140e <.L25+0x2b>

f0101482 <.L35>:
			putch(ch, putdat);
f0101482:	8b 75 08             	mov    0x8(%ebp),%esi
f0101485:	83 ec 08             	sub    $0x8,%esp
f0101488:	57                   	push   %edi
f0101489:	6a 25                	push   $0x25
f010148b:	ff d6                	call   *%esi
			break;
f010148d:	83 c4 10             	add    $0x10,%esp
f0101490:	eb 96                	jmp    f0101428 <.L25+0x45>

f0101492 <.L20>:
			putch('%', putdat);
f0101492:	8b 75 08             	mov    0x8(%ebp),%esi
f0101495:	83 ec 08             	sub    $0x8,%esp
f0101498:	57                   	push   %edi
f0101499:	6a 25                	push   $0x25
f010149b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010149d:	83 c4 10             	add    $0x10,%esp
f01014a0:	89 d8                	mov    %ebx,%eax
f01014a2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01014a6:	74 05                	je     f01014ad <.L20+0x1b>
f01014a8:	83 e8 01             	sub    $0x1,%eax
f01014ab:	eb f5                	jmp    f01014a2 <.L20+0x10>
f01014ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014b0:	e9 73 ff ff ff       	jmp    f0101428 <.L25+0x45>

f01014b5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014b5:	55                   	push   %ebp
f01014b6:	89 e5                	mov    %esp,%ebp
f01014b8:	53                   	push   %ebx
f01014b9:	83 ec 14             	sub    $0x14,%esp
f01014bc:	e8 fb ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014c1:	81 c3 43 fe 00 00    	add    $0xfe43,%ebx
f01014c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014d0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014d4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014de:	85 c0                	test   %eax,%eax
f01014e0:	74 2b                	je     f010150d <vsnprintf+0x58>
f01014e2:	85 d2                	test   %edx,%edx
f01014e4:	7e 27                	jle    f010150d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014e6:	ff 75 14             	push   0x14(%ebp)
f01014e9:	ff 75 10             	push   0x10(%ebp)
f01014ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014ef:	50                   	push   %eax
f01014f0:	8d 83 d3 fc fe ff    	lea    -0x1032d(%ebx),%eax
f01014f6:	50                   	push   %eax
f01014f7:	e8 15 fb ff ff       	call   f0101011 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101502:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101505:	83 c4 10             	add    $0x10,%esp
}
f0101508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010150b:	c9                   	leave  
f010150c:	c3                   	ret    
		return -E_INVAL;
f010150d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101512:	eb f4                	jmp    f0101508 <vsnprintf+0x53>

f0101514 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101514:	55                   	push   %ebp
f0101515:	89 e5                	mov    %esp,%ebp
f0101517:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010151a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010151d:	50                   	push   %eax
f010151e:	ff 75 10             	push   0x10(%ebp)
f0101521:	ff 75 0c             	push   0xc(%ebp)
f0101524:	ff 75 08             	push   0x8(%ebp)
f0101527:	e8 89 ff ff ff       	call   f01014b5 <vsnprintf>
	va_end(ap);

	return rc;
}
f010152c:	c9                   	leave  
f010152d:	c3                   	ret    

f010152e <__x86.get_pc_thunk.cx>:
f010152e:	8b 0c 24             	mov    (%esp),%ecx
f0101531:	c3                   	ret    

f0101532 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101532:	55                   	push   %ebp
f0101533:	89 e5                	mov    %esp,%ebp
f0101535:	57                   	push   %edi
f0101536:	56                   	push   %esi
f0101537:	53                   	push   %ebx
f0101538:	83 ec 1c             	sub    $0x1c,%esp
f010153b:	e8 7c ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101540:	81 c3 c4 fd 00 00    	add    $0xfdc4,%ebx
f0101546:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101549:	85 c0                	test   %eax,%eax
f010154b:	74 13                	je     f0101560 <readline+0x2e>
		cprintf("%s", prompt);
f010154d:	83 ec 08             	sub    $0x8,%esp
f0101550:	50                   	push   %eax
f0101551:	8d 83 92 0f ff ff    	lea    -0xf06e(%ebx),%eax
f0101557:	50                   	push   %eax
f0101558:	e8 d4 f5 ff ff       	call   f0100b31 <cprintf>
f010155d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101560:	83 ec 0c             	sub    $0xc,%esp
f0101563:	6a 00                	push   $0x0
f0101565:	e8 de f1 ff ff       	call   f0100748 <iscons>
f010156a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010156d:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101570:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0101575:	8d 83 bc 1f 00 00    	lea    0x1fbc(%ebx),%eax
f010157b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010157e:	eb 45                	jmp    f01015c5 <readline+0x93>
			cprintf("read error: %e\n", c);
f0101580:	83 ec 08             	sub    $0x8,%esp
f0101583:	50                   	push   %eax
f0101584:	8d 83 58 11 ff ff    	lea    -0xeea8(%ebx),%eax
f010158a:	50                   	push   %eax
f010158b:	e8 a1 f5 ff ff       	call   f0100b31 <cprintf>
			return NULL;
f0101590:	83 c4 10             	add    $0x10,%esp
f0101593:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101598:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010159b:	5b                   	pop    %ebx
f010159c:	5e                   	pop    %esi
f010159d:	5f                   	pop    %edi
f010159e:	5d                   	pop    %ebp
f010159f:	c3                   	ret    
			if (echoing)
f01015a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015a4:	75 05                	jne    f01015ab <readline+0x79>
			i--;
f01015a6:	83 ef 01             	sub    $0x1,%edi
f01015a9:	eb 1a                	jmp    f01015c5 <readline+0x93>
				cputchar('\b');
f01015ab:	83 ec 0c             	sub    $0xc,%esp
f01015ae:	6a 08                	push   $0x8
f01015b0:	e8 72 f1 ff ff       	call   f0100727 <cputchar>
f01015b5:	83 c4 10             	add    $0x10,%esp
f01015b8:	eb ec                	jmp    f01015a6 <readline+0x74>
			buf[i++] = c;
f01015ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015bd:	89 f0                	mov    %esi,%eax
f01015bf:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01015c2:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01015c5:	e8 6d f1 ff ff       	call   f0100737 <getchar>
f01015ca:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015cc:	85 c0                	test   %eax,%eax
f01015ce:	78 b0                	js     f0101580 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015d0:	83 f8 08             	cmp    $0x8,%eax
f01015d3:	0f 94 c0             	sete   %al
f01015d6:	83 fe 7f             	cmp    $0x7f,%esi
f01015d9:	0f 94 c2             	sete   %dl
f01015dc:	08 d0                	or     %dl,%al
f01015de:	74 04                	je     f01015e4 <readline+0xb2>
f01015e0:	85 ff                	test   %edi,%edi
f01015e2:	7f bc                	jg     f01015a0 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015e4:	83 fe 1f             	cmp    $0x1f,%esi
f01015e7:	7e 1c                	jle    f0101605 <readline+0xd3>
f01015e9:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01015ef:	7f 14                	jg     f0101605 <readline+0xd3>
			if (echoing)
f01015f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015f5:	74 c3                	je     f01015ba <readline+0x88>
				cputchar(c);
f01015f7:	83 ec 0c             	sub    $0xc,%esp
f01015fa:	56                   	push   %esi
f01015fb:	e8 27 f1 ff ff       	call   f0100727 <cputchar>
f0101600:	83 c4 10             	add    $0x10,%esp
f0101603:	eb b5                	jmp    f01015ba <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0101605:	83 fe 0a             	cmp    $0xa,%esi
f0101608:	74 05                	je     f010160f <readline+0xdd>
f010160a:	83 fe 0d             	cmp    $0xd,%esi
f010160d:	75 b6                	jne    f01015c5 <readline+0x93>
			if (echoing)
f010160f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101613:	75 13                	jne    f0101628 <readline+0xf6>
			buf[i] = 0;
f0101615:	c6 84 3b bc 1f 00 00 	movb   $0x0,0x1fbc(%ebx,%edi,1)
f010161c:	00 
			return buf;
f010161d:	8d 83 bc 1f 00 00    	lea    0x1fbc(%ebx),%eax
f0101623:	e9 70 ff ff ff       	jmp    f0101598 <readline+0x66>
				cputchar('\n');
f0101628:	83 ec 0c             	sub    $0xc,%esp
f010162b:	6a 0a                	push   $0xa
f010162d:	e8 f5 f0 ff ff       	call   f0100727 <cputchar>
f0101632:	83 c4 10             	add    $0x10,%esp
f0101635:	eb de                	jmp    f0101615 <readline+0xe3>

f0101637 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101637:	55                   	push   %ebp
f0101638:	89 e5                	mov    %esp,%ebp
f010163a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010163d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101642:	eb 03                	jmp    f0101647 <strlen+0x10>
		n++;
f0101644:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101647:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010164b:	75 f7                	jne    f0101644 <strlen+0xd>
	return n;
}
f010164d:	5d                   	pop    %ebp
f010164e:	c3                   	ret    

f010164f <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010164f:	55                   	push   %ebp
f0101650:	89 e5                	mov    %esp,%ebp
f0101652:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101655:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101658:	b8 00 00 00 00       	mov    $0x0,%eax
f010165d:	eb 03                	jmp    f0101662 <strnlen+0x13>
		n++;
f010165f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101662:	39 d0                	cmp    %edx,%eax
f0101664:	74 08                	je     f010166e <strnlen+0x1f>
f0101666:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010166a:	75 f3                	jne    f010165f <strnlen+0x10>
f010166c:	89 c2                	mov    %eax,%edx
	return n;
}
f010166e:	89 d0                	mov    %edx,%eax
f0101670:	5d                   	pop    %ebp
f0101671:	c3                   	ret    

f0101672 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101672:	55                   	push   %ebp
f0101673:	89 e5                	mov    %esp,%ebp
f0101675:	53                   	push   %ebx
f0101676:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010167c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101681:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101685:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101688:	83 c0 01             	add    $0x1,%eax
f010168b:	84 d2                	test   %dl,%dl
f010168d:	75 f2                	jne    f0101681 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010168f:	89 c8                	mov    %ecx,%eax
f0101691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101694:	c9                   	leave  
f0101695:	c3                   	ret    

f0101696 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101696:	55                   	push   %ebp
f0101697:	89 e5                	mov    %esp,%ebp
f0101699:	53                   	push   %ebx
f010169a:	83 ec 10             	sub    $0x10,%esp
f010169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016a0:	53                   	push   %ebx
f01016a1:	e8 91 ff ff ff       	call   f0101637 <strlen>
f01016a6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01016a9:	ff 75 0c             	push   0xc(%ebp)
f01016ac:	01 d8                	add    %ebx,%eax
f01016ae:	50                   	push   %eax
f01016af:	e8 be ff ff ff       	call   f0101672 <strcpy>
	return dst;
}
f01016b4:	89 d8                	mov    %ebx,%eax
f01016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016b9:	c9                   	leave  
f01016ba:	c3                   	ret    

f01016bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016bb:	55                   	push   %ebp
f01016bc:	89 e5                	mov    %esp,%ebp
f01016be:	56                   	push   %esi
f01016bf:	53                   	push   %ebx
f01016c0:	8b 75 08             	mov    0x8(%ebp),%esi
f01016c3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016c6:	89 f3                	mov    %esi,%ebx
f01016c8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016cb:	89 f0                	mov    %esi,%eax
f01016cd:	eb 0f                	jmp    f01016de <strncpy+0x23>
		*dst++ = *src;
f01016cf:	83 c0 01             	add    $0x1,%eax
f01016d2:	0f b6 0a             	movzbl (%edx),%ecx
f01016d5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01016d8:	80 f9 01             	cmp    $0x1,%cl
f01016db:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01016de:	39 d8                	cmp    %ebx,%eax
f01016e0:	75 ed                	jne    f01016cf <strncpy+0x14>
	}
	return ret;
}
f01016e2:	89 f0                	mov    %esi,%eax
f01016e4:	5b                   	pop    %ebx
f01016e5:	5e                   	pop    %esi
f01016e6:	5d                   	pop    %ebp
f01016e7:	c3                   	ret    

f01016e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01016e8:	55                   	push   %ebp
f01016e9:	89 e5                	mov    %esp,%ebp
f01016eb:	56                   	push   %esi
f01016ec:	53                   	push   %ebx
f01016ed:	8b 75 08             	mov    0x8(%ebp),%esi
f01016f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016f3:	8b 55 10             	mov    0x10(%ebp),%edx
f01016f6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01016f8:	85 d2                	test   %edx,%edx
f01016fa:	74 21                	je     f010171d <strlcpy+0x35>
f01016fc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101700:	89 f2                	mov    %esi,%edx
f0101702:	eb 09                	jmp    f010170d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101704:	83 c1 01             	add    $0x1,%ecx
f0101707:	83 c2 01             	add    $0x1,%edx
f010170a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f010170d:	39 c2                	cmp    %eax,%edx
f010170f:	74 09                	je     f010171a <strlcpy+0x32>
f0101711:	0f b6 19             	movzbl (%ecx),%ebx
f0101714:	84 db                	test   %bl,%bl
f0101716:	75 ec                	jne    f0101704 <strlcpy+0x1c>
f0101718:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010171a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010171d:	29 f0                	sub    %esi,%eax
}
f010171f:	5b                   	pop    %ebx
f0101720:	5e                   	pop    %esi
f0101721:	5d                   	pop    %ebp
f0101722:	c3                   	ret    

f0101723 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101723:	55                   	push   %ebp
f0101724:	89 e5                	mov    %esp,%ebp
f0101726:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101729:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010172c:	eb 06                	jmp    f0101734 <strcmp+0x11>
		p++, q++;
f010172e:	83 c1 01             	add    $0x1,%ecx
f0101731:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0101734:	0f b6 01             	movzbl (%ecx),%eax
f0101737:	84 c0                	test   %al,%al
f0101739:	74 04                	je     f010173f <strcmp+0x1c>
f010173b:	3a 02                	cmp    (%edx),%al
f010173d:	74 ef                	je     f010172e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010173f:	0f b6 c0             	movzbl %al,%eax
f0101742:	0f b6 12             	movzbl (%edx),%edx
f0101745:	29 d0                	sub    %edx,%eax
}
f0101747:	5d                   	pop    %ebp
f0101748:	c3                   	ret    

f0101749 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101749:	55                   	push   %ebp
f010174a:	89 e5                	mov    %esp,%ebp
f010174c:	53                   	push   %ebx
f010174d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101750:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101753:	89 c3                	mov    %eax,%ebx
f0101755:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101758:	eb 06                	jmp    f0101760 <strncmp+0x17>
		n--, p++, q++;
f010175a:	83 c0 01             	add    $0x1,%eax
f010175d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101760:	39 d8                	cmp    %ebx,%eax
f0101762:	74 18                	je     f010177c <strncmp+0x33>
f0101764:	0f b6 08             	movzbl (%eax),%ecx
f0101767:	84 c9                	test   %cl,%cl
f0101769:	74 04                	je     f010176f <strncmp+0x26>
f010176b:	3a 0a                	cmp    (%edx),%cl
f010176d:	74 eb                	je     f010175a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010176f:	0f b6 00             	movzbl (%eax),%eax
f0101772:	0f b6 12             	movzbl (%edx),%edx
f0101775:	29 d0                	sub    %edx,%eax
}
f0101777:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010177a:	c9                   	leave  
f010177b:	c3                   	ret    
		return 0;
f010177c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101781:	eb f4                	jmp    f0101777 <strncmp+0x2e>

f0101783 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101783:	55                   	push   %ebp
f0101784:	89 e5                	mov    %esp,%ebp
f0101786:	8b 45 08             	mov    0x8(%ebp),%eax
f0101789:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010178d:	eb 03                	jmp    f0101792 <strchr+0xf>
f010178f:	83 c0 01             	add    $0x1,%eax
f0101792:	0f b6 10             	movzbl (%eax),%edx
f0101795:	84 d2                	test   %dl,%dl
f0101797:	74 06                	je     f010179f <strchr+0x1c>
		if (*s == c)
f0101799:	38 ca                	cmp    %cl,%dl
f010179b:	75 f2                	jne    f010178f <strchr+0xc>
f010179d:	eb 05                	jmp    f01017a4 <strchr+0x21>
			return (char *) s;
	return 0;
f010179f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017a4:	5d                   	pop    %ebp
f01017a5:	c3                   	ret    

f01017a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017a6:	55                   	push   %ebp
f01017a7:	89 e5                	mov    %esp,%ebp
f01017a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017b0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017b3:	38 ca                	cmp    %cl,%dl
f01017b5:	74 09                	je     f01017c0 <strfind+0x1a>
f01017b7:	84 d2                	test   %dl,%dl
f01017b9:	74 05                	je     f01017c0 <strfind+0x1a>
	for (; *s; s++)
f01017bb:	83 c0 01             	add    $0x1,%eax
f01017be:	eb f0                	jmp    f01017b0 <strfind+0xa>
			break;
	return (char *) s;
}
f01017c0:	5d                   	pop    %ebp
f01017c1:	c3                   	ret    

f01017c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01017c2:	55                   	push   %ebp
f01017c3:	89 e5                	mov    %esp,%ebp
f01017c5:	57                   	push   %edi
f01017c6:	56                   	push   %esi
f01017c7:	53                   	push   %ebx
f01017c8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017ce:	85 c9                	test   %ecx,%ecx
f01017d0:	74 2f                	je     f0101801 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017d2:	89 f8                	mov    %edi,%eax
f01017d4:	09 c8                	or     %ecx,%eax
f01017d6:	a8 03                	test   $0x3,%al
f01017d8:	75 21                	jne    f01017fb <memset+0x39>
		c &= 0xFF;
f01017da:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01017de:	89 d0                	mov    %edx,%eax
f01017e0:	c1 e0 08             	shl    $0x8,%eax
f01017e3:	89 d3                	mov    %edx,%ebx
f01017e5:	c1 e3 18             	shl    $0x18,%ebx
f01017e8:	89 d6                	mov    %edx,%esi
f01017ea:	c1 e6 10             	shl    $0x10,%esi
f01017ed:	09 f3                	or     %esi,%ebx
f01017ef:	09 da                	or     %ebx,%edx
f01017f1:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01017f3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01017f6:	fc                   	cld    
f01017f7:	f3 ab                	rep stos %eax,%es:(%edi)
f01017f9:	eb 06                	jmp    f0101801 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01017fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017fe:	fc                   	cld    
f01017ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101801:	89 f8                	mov    %edi,%eax
f0101803:	5b                   	pop    %ebx
f0101804:	5e                   	pop    %esi
f0101805:	5f                   	pop    %edi
f0101806:	5d                   	pop    %ebp
f0101807:	c3                   	ret    

f0101808 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101808:	55                   	push   %ebp
f0101809:	89 e5                	mov    %esp,%ebp
f010180b:	57                   	push   %edi
f010180c:	56                   	push   %esi
f010180d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101810:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101813:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101816:	39 c6                	cmp    %eax,%esi
f0101818:	73 32                	jae    f010184c <memmove+0x44>
f010181a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010181d:	39 c2                	cmp    %eax,%edx
f010181f:	76 2b                	jbe    f010184c <memmove+0x44>
		s += n;
		d += n;
f0101821:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101824:	89 d6                	mov    %edx,%esi
f0101826:	09 fe                	or     %edi,%esi
f0101828:	09 ce                	or     %ecx,%esi
f010182a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101830:	75 0e                	jne    f0101840 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101832:	83 ef 04             	sub    $0x4,%edi
f0101835:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101838:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010183b:	fd                   	std    
f010183c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010183e:	eb 09                	jmp    f0101849 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101840:	83 ef 01             	sub    $0x1,%edi
f0101843:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101846:	fd                   	std    
f0101847:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101849:	fc                   	cld    
f010184a:	eb 1a                	jmp    f0101866 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010184c:	89 f2                	mov    %esi,%edx
f010184e:	09 c2                	or     %eax,%edx
f0101850:	09 ca                	or     %ecx,%edx
f0101852:	f6 c2 03             	test   $0x3,%dl
f0101855:	75 0a                	jne    f0101861 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101857:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010185a:	89 c7                	mov    %eax,%edi
f010185c:	fc                   	cld    
f010185d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010185f:	eb 05                	jmp    f0101866 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0101861:	89 c7                	mov    %eax,%edi
f0101863:	fc                   	cld    
f0101864:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101866:	5e                   	pop    %esi
f0101867:	5f                   	pop    %edi
f0101868:	5d                   	pop    %ebp
f0101869:	c3                   	ret    

f010186a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010186a:	55                   	push   %ebp
f010186b:	89 e5                	mov    %esp,%ebp
f010186d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101870:	ff 75 10             	push   0x10(%ebp)
f0101873:	ff 75 0c             	push   0xc(%ebp)
f0101876:	ff 75 08             	push   0x8(%ebp)
f0101879:	e8 8a ff ff ff       	call   f0101808 <memmove>
}
f010187e:	c9                   	leave  
f010187f:	c3                   	ret    

f0101880 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101880:	55                   	push   %ebp
f0101881:	89 e5                	mov    %esp,%ebp
f0101883:	56                   	push   %esi
f0101884:	53                   	push   %ebx
f0101885:	8b 45 08             	mov    0x8(%ebp),%eax
f0101888:	8b 55 0c             	mov    0xc(%ebp),%edx
f010188b:	89 c6                	mov    %eax,%esi
f010188d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101890:	eb 06                	jmp    f0101898 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101892:	83 c0 01             	add    $0x1,%eax
f0101895:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0101898:	39 f0                	cmp    %esi,%eax
f010189a:	74 14                	je     f01018b0 <memcmp+0x30>
		if (*s1 != *s2)
f010189c:	0f b6 08             	movzbl (%eax),%ecx
f010189f:	0f b6 1a             	movzbl (%edx),%ebx
f01018a2:	38 d9                	cmp    %bl,%cl
f01018a4:	74 ec                	je     f0101892 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01018a6:	0f b6 c1             	movzbl %cl,%eax
f01018a9:	0f b6 db             	movzbl %bl,%ebx
f01018ac:	29 d8                	sub    %ebx,%eax
f01018ae:	eb 05                	jmp    f01018b5 <memcmp+0x35>
	}

	return 0;
f01018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018b5:	5b                   	pop    %ebx
f01018b6:	5e                   	pop    %esi
f01018b7:	5d                   	pop    %ebp
f01018b8:	c3                   	ret    

f01018b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018b9:	55                   	push   %ebp
f01018ba:	89 e5                	mov    %esp,%ebp
f01018bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01018bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01018c2:	89 c2                	mov    %eax,%edx
f01018c4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01018c7:	eb 03                	jmp    f01018cc <memfind+0x13>
f01018c9:	83 c0 01             	add    $0x1,%eax
f01018cc:	39 d0                	cmp    %edx,%eax
f01018ce:	73 04                	jae    f01018d4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018d0:	38 08                	cmp    %cl,(%eax)
f01018d2:	75 f5                	jne    f01018c9 <memfind+0x10>
			break;
	return (void *) s;
}
f01018d4:	5d                   	pop    %ebp
f01018d5:	c3                   	ret    

f01018d6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01018d6:	55                   	push   %ebp
f01018d7:	89 e5                	mov    %esp,%ebp
f01018d9:	57                   	push   %edi
f01018da:	56                   	push   %esi
f01018db:	53                   	push   %ebx
f01018dc:	8b 55 08             	mov    0x8(%ebp),%edx
f01018df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01018e2:	eb 03                	jmp    f01018e7 <strtol+0x11>
		s++;
f01018e4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01018e7:	0f b6 02             	movzbl (%edx),%eax
f01018ea:	3c 20                	cmp    $0x20,%al
f01018ec:	74 f6                	je     f01018e4 <strtol+0xe>
f01018ee:	3c 09                	cmp    $0x9,%al
f01018f0:	74 f2                	je     f01018e4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01018f2:	3c 2b                	cmp    $0x2b,%al
f01018f4:	74 2a                	je     f0101920 <strtol+0x4a>
	int neg = 0;
f01018f6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01018fb:	3c 2d                	cmp    $0x2d,%al
f01018fd:	74 2b                	je     f010192a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018ff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101905:	75 0f                	jne    f0101916 <strtol+0x40>
f0101907:	80 3a 30             	cmpb   $0x30,(%edx)
f010190a:	74 28                	je     f0101934 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010190c:	85 db                	test   %ebx,%ebx
f010190e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101913:	0f 44 d8             	cmove  %eax,%ebx
f0101916:	b9 00 00 00 00       	mov    $0x0,%ecx
f010191b:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010191e:	eb 46                	jmp    f0101966 <strtol+0x90>
		s++;
f0101920:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0101923:	bf 00 00 00 00       	mov    $0x0,%edi
f0101928:	eb d5                	jmp    f01018ff <strtol+0x29>
		s++, neg = 1;
f010192a:	83 c2 01             	add    $0x1,%edx
f010192d:	bf 01 00 00 00       	mov    $0x1,%edi
f0101932:	eb cb                	jmp    f01018ff <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101934:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101938:	74 0e                	je     f0101948 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010193a:	85 db                	test   %ebx,%ebx
f010193c:	75 d8                	jne    f0101916 <strtol+0x40>
		s++, base = 8;
f010193e:	83 c2 01             	add    $0x1,%edx
f0101941:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101946:	eb ce                	jmp    f0101916 <strtol+0x40>
		s += 2, base = 16;
f0101948:	83 c2 02             	add    $0x2,%edx
f010194b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101950:	eb c4                	jmp    f0101916 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101952:	0f be c0             	movsbl %al,%eax
f0101955:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101958:	3b 45 10             	cmp    0x10(%ebp),%eax
f010195b:	7d 3a                	jge    f0101997 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f010195d:	83 c2 01             	add    $0x1,%edx
f0101960:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0101964:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0101966:	0f b6 02             	movzbl (%edx),%eax
f0101969:	8d 70 d0             	lea    -0x30(%eax),%esi
f010196c:	89 f3                	mov    %esi,%ebx
f010196e:	80 fb 09             	cmp    $0x9,%bl
f0101971:	76 df                	jbe    f0101952 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0101973:	8d 70 9f             	lea    -0x61(%eax),%esi
f0101976:	89 f3                	mov    %esi,%ebx
f0101978:	80 fb 19             	cmp    $0x19,%bl
f010197b:	77 08                	ja     f0101985 <strtol+0xaf>
			dig = *s - 'a' + 10;
f010197d:	0f be c0             	movsbl %al,%eax
f0101980:	83 e8 57             	sub    $0x57,%eax
f0101983:	eb d3                	jmp    f0101958 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0101985:	8d 70 bf             	lea    -0x41(%eax),%esi
f0101988:	89 f3                	mov    %esi,%ebx
f010198a:	80 fb 19             	cmp    $0x19,%bl
f010198d:	77 08                	ja     f0101997 <strtol+0xc1>
			dig = *s - 'A' + 10;
f010198f:	0f be c0             	movsbl %al,%eax
f0101992:	83 e8 37             	sub    $0x37,%eax
f0101995:	eb c1                	jmp    f0101958 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101997:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010199b:	74 05                	je     f01019a2 <strtol+0xcc>
		*endptr = (char *) s;
f010199d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019a0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01019a2:	89 c8                	mov    %ecx,%eax
f01019a4:	f7 d8                	neg    %eax
f01019a6:	85 ff                	test   %edi,%edi
f01019a8:	0f 45 c8             	cmovne %eax,%ecx
}
f01019ab:	89 c8                	mov    %ecx,%eax
f01019ad:	5b                   	pop    %ebx
f01019ae:	5e                   	pop    %esi
f01019af:	5f                   	pop    %edi
f01019b0:	5d                   	pop    %ebp
f01019b1:	c3                   	ret    
f01019b2:	66 90                	xchg   %ax,%ax
f01019b4:	66 90                	xchg   %ax,%ax
f01019b6:	66 90                	xchg   %ax,%ax
f01019b8:	66 90                	xchg   %ax,%ax
f01019ba:	66 90                	xchg   %ax,%ax
f01019bc:	66 90                	xchg   %ax,%ax
f01019be:	66 90                	xchg   %ax,%ax

f01019c0 <__udivdi3>:
f01019c0:	f3 0f 1e fb          	endbr32 
f01019c4:	55                   	push   %ebp
f01019c5:	57                   	push   %edi
f01019c6:	56                   	push   %esi
f01019c7:	53                   	push   %ebx
f01019c8:	83 ec 1c             	sub    $0x1c,%esp
f01019cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01019cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01019d3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01019d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01019db:	85 c0                	test   %eax,%eax
f01019dd:	75 19                	jne    f01019f8 <__udivdi3+0x38>
f01019df:	39 f3                	cmp    %esi,%ebx
f01019e1:	76 4d                	jbe    f0101a30 <__udivdi3+0x70>
f01019e3:	31 ff                	xor    %edi,%edi
f01019e5:	89 e8                	mov    %ebp,%eax
f01019e7:	89 f2                	mov    %esi,%edx
f01019e9:	f7 f3                	div    %ebx
f01019eb:	89 fa                	mov    %edi,%edx
f01019ed:	83 c4 1c             	add    $0x1c,%esp
f01019f0:	5b                   	pop    %ebx
f01019f1:	5e                   	pop    %esi
f01019f2:	5f                   	pop    %edi
f01019f3:	5d                   	pop    %ebp
f01019f4:	c3                   	ret    
f01019f5:	8d 76 00             	lea    0x0(%esi),%esi
f01019f8:	39 f0                	cmp    %esi,%eax
f01019fa:	76 14                	jbe    f0101a10 <__udivdi3+0x50>
f01019fc:	31 ff                	xor    %edi,%edi
f01019fe:	31 c0                	xor    %eax,%eax
f0101a00:	89 fa                	mov    %edi,%edx
f0101a02:	83 c4 1c             	add    $0x1c,%esp
f0101a05:	5b                   	pop    %ebx
f0101a06:	5e                   	pop    %esi
f0101a07:	5f                   	pop    %edi
f0101a08:	5d                   	pop    %ebp
f0101a09:	c3                   	ret    
f0101a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a10:	0f bd f8             	bsr    %eax,%edi
f0101a13:	83 f7 1f             	xor    $0x1f,%edi
f0101a16:	75 48                	jne    f0101a60 <__udivdi3+0xa0>
f0101a18:	39 f0                	cmp    %esi,%eax
f0101a1a:	72 06                	jb     f0101a22 <__udivdi3+0x62>
f0101a1c:	31 c0                	xor    %eax,%eax
f0101a1e:	39 eb                	cmp    %ebp,%ebx
f0101a20:	77 de                	ja     f0101a00 <__udivdi3+0x40>
f0101a22:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a27:	eb d7                	jmp    f0101a00 <__udivdi3+0x40>
f0101a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a30:	89 d9                	mov    %ebx,%ecx
f0101a32:	85 db                	test   %ebx,%ebx
f0101a34:	75 0b                	jne    f0101a41 <__udivdi3+0x81>
f0101a36:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a3b:	31 d2                	xor    %edx,%edx
f0101a3d:	f7 f3                	div    %ebx
f0101a3f:	89 c1                	mov    %eax,%ecx
f0101a41:	31 d2                	xor    %edx,%edx
f0101a43:	89 f0                	mov    %esi,%eax
f0101a45:	f7 f1                	div    %ecx
f0101a47:	89 c6                	mov    %eax,%esi
f0101a49:	89 e8                	mov    %ebp,%eax
f0101a4b:	89 f7                	mov    %esi,%edi
f0101a4d:	f7 f1                	div    %ecx
f0101a4f:	89 fa                	mov    %edi,%edx
f0101a51:	83 c4 1c             	add    $0x1c,%esp
f0101a54:	5b                   	pop    %ebx
f0101a55:	5e                   	pop    %esi
f0101a56:	5f                   	pop    %edi
f0101a57:	5d                   	pop    %ebp
f0101a58:	c3                   	ret    
f0101a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a60:	89 f9                	mov    %edi,%ecx
f0101a62:	ba 20 00 00 00       	mov    $0x20,%edx
f0101a67:	29 fa                	sub    %edi,%edx
f0101a69:	d3 e0                	shl    %cl,%eax
f0101a6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a6f:	89 d1                	mov    %edx,%ecx
f0101a71:	89 d8                	mov    %ebx,%eax
f0101a73:	d3 e8                	shr    %cl,%eax
f0101a75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101a79:	09 c1                	or     %eax,%ecx
f0101a7b:	89 f0                	mov    %esi,%eax
f0101a7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a81:	89 f9                	mov    %edi,%ecx
f0101a83:	d3 e3                	shl    %cl,%ebx
f0101a85:	89 d1                	mov    %edx,%ecx
f0101a87:	d3 e8                	shr    %cl,%eax
f0101a89:	89 f9                	mov    %edi,%ecx
f0101a8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101a8f:	89 eb                	mov    %ebp,%ebx
f0101a91:	d3 e6                	shl    %cl,%esi
f0101a93:	89 d1                	mov    %edx,%ecx
f0101a95:	d3 eb                	shr    %cl,%ebx
f0101a97:	09 f3                	or     %esi,%ebx
f0101a99:	89 c6                	mov    %eax,%esi
f0101a9b:	89 f2                	mov    %esi,%edx
f0101a9d:	89 d8                	mov    %ebx,%eax
f0101a9f:	f7 74 24 08          	divl   0x8(%esp)
f0101aa3:	89 d6                	mov    %edx,%esi
f0101aa5:	89 c3                	mov    %eax,%ebx
f0101aa7:	f7 64 24 0c          	mull   0xc(%esp)
f0101aab:	39 d6                	cmp    %edx,%esi
f0101aad:	72 19                	jb     f0101ac8 <__udivdi3+0x108>
f0101aaf:	89 f9                	mov    %edi,%ecx
f0101ab1:	d3 e5                	shl    %cl,%ebp
f0101ab3:	39 c5                	cmp    %eax,%ebp
f0101ab5:	73 04                	jae    f0101abb <__udivdi3+0xfb>
f0101ab7:	39 d6                	cmp    %edx,%esi
f0101ab9:	74 0d                	je     f0101ac8 <__udivdi3+0x108>
f0101abb:	89 d8                	mov    %ebx,%eax
f0101abd:	31 ff                	xor    %edi,%edi
f0101abf:	e9 3c ff ff ff       	jmp    f0101a00 <__udivdi3+0x40>
f0101ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ac8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101acb:	31 ff                	xor    %edi,%edi
f0101acd:	e9 2e ff ff ff       	jmp    f0101a00 <__udivdi3+0x40>
f0101ad2:	66 90                	xchg   %ax,%ax
f0101ad4:	66 90                	xchg   %ax,%ax
f0101ad6:	66 90                	xchg   %ax,%ax
f0101ad8:	66 90                	xchg   %ax,%ax
f0101ada:	66 90                	xchg   %ax,%ax
f0101adc:	66 90                	xchg   %ax,%ax
f0101ade:	66 90                	xchg   %ax,%ax

f0101ae0 <__umoddi3>:
f0101ae0:	f3 0f 1e fb          	endbr32 
f0101ae4:	55                   	push   %ebp
f0101ae5:	57                   	push   %edi
f0101ae6:	56                   	push   %esi
f0101ae7:	53                   	push   %ebx
f0101ae8:	83 ec 1c             	sub    $0x1c,%esp
f0101aeb:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101aef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101af3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0101af7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0101afb:	89 f0                	mov    %esi,%eax
f0101afd:	89 da                	mov    %ebx,%edx
f0101aff:	85 ff                	test   %edi,%edi
f0101b01:	75 15                	jne    f0101b18 <__umoddi3+0x38>
f0101b03:	39 dd                	cmp    %ebx,%ebp
f0101b05:	76 39                	jbe    f0101b40 <__umoddi3+0x60>
f0101b07:	f7 f5                	div    %ebp
f0101b09:	89 d0                	mov    %edx,%eax
f0101b0b:	31 d2                	xor    %edx,%edx
f0101b0d:	83 c4 1c             	add    $0x1c,%esp
f0101b10:	5b                   	pop    %ebx
f0101b11:	5e                   	pop    %esi
f0101b12:	5f                   	pop    %edi
f0101b13:	5d                   	pop    %ebp
f0101b14:	c3                   	ret    
f0101b15:	8d 76 00             	lea    0x0(%esi),%esi
f0101b18:	39 df                	cmp    %ebx,%edi
f0101b1a:	77 f1                	ja     f0101b0d <__umoddi3+0x2d>
f0101b1c:	0f bd cf             	bsr    %edi,%ecx
f0101b1f:	83 f1 1f             	xor    $0x1f,%ecx
f0101b22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101b26:	75 40                	jne    f0101b68 <__umoddi3+0x88>
f0101b28:	39 df                	cmp    %ebx,%edi
f0101b2a:	72 04                	jb     f0101b30 <__umoddi3+0x50>
f0101b2c:	39 f5                	cmp    %esi,%ebp
f0101b2e:	77 dd                	ja     f0101b0d <__umoddi3+0x2d>
f0101b30:	89 da                	mov    %ebx,%edx
f0101b32:	89 f0                	mov    %esi,%eax
f0101b34:	29 e8                	sub    %ebp,%eax
f0101b36:	19 fa                	sbb    %edi,%edx
f0101b38:	eb d3                	jmp    f0101b0d <__umoddi3+0x2d>
f0101b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b40:	89 e9                	mov    %ebp,%ecx
f0101b42:	85 ed                	test   %ebp,%ebp
f0101b44:	75 0b                	jne    f0101b51 <__umoddi3+0x71>
f0101b46:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b4b:	31 d2                	xor    %edx,%edx
f0101b4d:	f7 f5                	div    %ebp
f0101b4f:	89 c1                	mov    %eax,%ecx
f0101b51:	89 d8                	mov    %ebx,%eax
f0101b53:	31 d2                	xor    %edx,%edx
f0101b55:	f7 f1                	div    %ecx
f0101b57:	89 f0                	mov    %esi,%eax
f0101b59:	f7 f1                	div    %ecx
f0101b5b:	89 d0                	mov    %edx,%eax
f0101b5d:	31 d2                	xor    %edx,%edx
f0101b5f:	eb ac                	jmp    f0101b0d <__umoddi3+0x2d>
f0101b61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b68:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101b6c:	ba 20 00 00 00       	mov    $0x20,%edx
f0101b71:	29 c2                	sub    %eax,%edx
f0101b73:	89 c1                	mov    %eax,%ecx
f0101b75:	89 e8                	mov    %ebp,%eax
f0101b77:	d3 e7                	shl    %cl,%edi
f0101b79:	89 d1                	mov    %edx,%ecx
f0101b7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101b7f:	d3 e8                	shr    %cl,%eax
f0101b81:	89 c1                	mov    %eax,%ecx
f0101b83:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101b87:	09 f9                	or     %edi,%ecx
f0101b89:	89 df                	mov    %ebx,%edi
f0101b8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b8f:	89 c1                	mov    %eax,%ecx
f0101b91:	d3 e5                	shl    %cl,%ebp
f0101b93:	89 d1                	mov    %edx,%ecx
f0101b95:	d3 ef                	shr    %cl,%edi
f0101b97:	89 c1                	mov    %eax,%ecx
f0101b99:	89 f0                	mov    %esi,%eax
f0101b9b:	d3 e3                	shl    %cl,%ebx
f0101b9d:	89 d1                	mov    %edx,%ecx
f0101b9f:	89 fa                	mov    %edi,%edx
f0101ba1:	d3 e8                	shr    %cl,%eax
f0101ba3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ba8:	09 d8                	or     %ebx,%eax
f0101baa:	f7 74 24 08          	divl   0x8(%esp)
f0101bae:	89 d3                	mov    %edx,%ebx
f0101bb0:	d3 e6                	shl    %cl,%esi
f0101bb2:	f7 e5                	mul    %ebp
f0101bb4:	89 c7                	mov    %eax,%edi
f0101bb6:	89 d1                	mov    %edx,%ecx
f0101bb8:	39 d3                	cmp    %edx,%ebx
f0101bba:	72 06                	jb     f0101bc2 <__umoddi3+0xe2>
f0101bbc:	75 0e                	jne    f0101bcc <__umoddi3+0xec>
f0101bbe:	39 c6                	cmp    %eax,%esi
f0101bc0:	73 0a                	jae    f0101bcc <__umoddi3+0xec>
f0101bc2:	29 e8                	sub    %ebp,%eax
f0101bc4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101bc8:	89 d1                	mov    %edx,%ecx
f0101bca:	89 c7                	mov    %eax,%edi
f0101bcc:	89 f5                	mov    %esi,%ebp
f0101bce:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101bd2:	29 fd                	sub    %edi,%ebp
f0101bd4:	19 cb                	sbb    %ecx,%ebx
f0101bd6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101bdb:	89 d8                	mov    %ebx,%eax
f0101bdd:	d3 e0                	shl    %cl,%eax
f0101bdf:	89 f1                	mov    %esi,%ecx
f0101be1:	d3 ed                	shr    %cl,%ebp
f0101be3:	d3 eb                	shr    %cl,%ebx
f0101be5:	09 e8                	or     %ebp,%eax
f0101be7:	89 da                	mov    %ebx,%edx
f0101be9:	83 c4 1c             	add    $0x1c,%esp
f0101bec:	5b                   	pop    %ebx
f0101bed:	5e                   	pop    %esi
f0101bee:	5f                   	pop    %edi
f0101bef:	5d                   	pop    %ebp
f0101bf0:	c3                   	ret    
