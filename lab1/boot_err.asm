
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007d00 <start>:
    7d00:	fa                   	cli    
    7d01:	fc                   	cld    
    7d02:	31 c0                	xor    %eax,%eax
    7d04:	8e d8                	mov    %eax,%ds
    7d06:	8e c0                	mov    %eax,%es
    7d08:	8e d0                	mov    %eax,%ss

00007d0a <seta20.1>:
    7d0a:	e4 64                	in     $0x64,%al
    7d0c:	a8 02                	test   $0x2,%al
    7d0e:	75 fa                	jne    7d0a <seta20.1>
    7d10:	b0 d1                	mov    $0xd1,%al
    7d12:	e6 64                	out    %al,$0x64

00007d14 <seta20.2>:
    7d14:	e4 64                	in     $0x64,%al
    7d16:	a8 02                	test   $0x2,%al
    7d18:	75 fa                	jne    7d14 <seta20.2>
    7d1a:	b0 df                	mov    $0xdf,%al
    7d1c:	e6 60                	out    %al,$0x60
    7d1e:	0f 01 16             	lgdtl  (%esi)
    7d21:	64 7d 0f             	fs jge 7d33 <protcseg+0x1>
    7d24:	20 c0                	and    %al,%al
    7d26:	66 83 c8 01          	or     $0x1,%ax
    7d2a:	0f 22 c0             	mov    %eax,%cr0
    7d2d:	ea                   	.byte 0xea
    7d2e:	32 7d 08             	xor    0x8(%ebp),%bh
	...

00007d32 <protcseg>:
    7d32:	66 b8 10 00          	mov    $0x10,%ax
    7d36:	8e d8                	mov    %eax,%ds
    7d38:	8e c0                	mov    %eax,%es
    7d3a:	8e e0                	mov    %eax,%fs
    7d3c:	8e e8                	mov    %eax,%gs
    7d3e:	8e d0                	mov    %eax,%ss
    7d40:	bc 00 7d 00 00       	mov    $0x7d00,%esp
    7d45:	e8 cf 00 00 00       	call   7e19 <bootmain>

00007d4a <spin>:
    7d4a:	eb fe                	jmp    7d4a <spin>

00007d4c <gdt>:
	...
    7d54:	ff                   	(bad)  
    7d55:	ff 00                	incl   (%eax)
    7d57:	00 00                	add    %al,(%eax)
    7d59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7d60:	00                   	.byte 0x0
    7d61:	92                   	xchg   %eax,%edx
    7d62:	cf                   	iret   
	...

00007d64 <gdtdesc>:
    7d64:	17                   	pop    %ss
    7d65:	00 4c 7d 00          	add    %cl,0x0(%ebp,%edi,2)
	...

00007d6a <waitdisk>:
    7d6a:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7d6f:	ec                   	in     (%dx),%al
    7d70:	83 e0 c0             	and    $0xffffffc0,%eax
    7d73:	3c 40                	cmp    $0x40,%al
    7d75:	75 f8                	jne    7d6f <waitdisk+0x5>
    7d77:	c3                   	ret    

00007d78 <readsect>:
    7d78:	55                   	push   %ebp
    7d79:	89 e5                	mov    %esp,%ebp
    7d7b:	57                   	push   %edi
    7d7c:	50                   	push   %eax
    7d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    7d80:	e8 e5 ff ff ff       	call   7d6a <waitdisk>
    7d85:	b0 01                	mov    $0x1,%al
    7d87:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7d8c:	ee                   	out    %al,(%dx)
    7d8d:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7d92:	89 c8                	mov    %ecx,%eax
    7d94:	ee                   	out    %al,(%dx)
    7d95:	89 c8                	mov    %ecx,%eax
    7d97:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7d9c:	c1 e8 08             	shr    $0x8,%eax
    7d9f:	ee                   	out    %al,(%dx)
    7da0:	89 c8                	mov    %ecx,%eax
    7da2:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7da7:	c1 e8 10             	shr    $0x10,%eax
    7daa:	ee                   	out    %al,(%dx)
    7dab:	89 c8                	mov    %ecx,%eax
    7dad:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7db2:	c1 e8 18             	shr    $0x18,%eax
    7db5:	83 c8 e0             	or     $0xffffffe0,%eax
    7db8:	ee                   	out    %al,(%dx)
    7db9:	b0 20                	mov    $0x20,%al
    7dbb:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7dc0:	ee                   	out    %al,(%dx)
    7dc1:	e8 a4 ff ff ff       	call   7d6a <waitdisk>
    7dc6:	b9 80 00 00 00       	mov    $0x80,%ecx
    7dcb:	8b 7d 08             	mov    0x8(%ebp),%edi
    7dce:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7dd3:	fc                   	cld    
    7dd4:	f2 6d                	repnz insl (%dx),%es:(%edi)
    7dd6:	5a                   	pop    %edx
    7dd7:	5f                   	pop    %edi
    7dd8:	5d                   	pop    %ebp
    7dd9:	c3                   	ret    

00007dda <readseg>:
    7dda:	55                   	push   %ebp
    7ddb:	89 e5                	mov    %esp,%ebp
    7ddd:	57                   	push   %edi
    7dde:	56                   	push   %esi
    7ddf:	53                   	push   %ebx
    7de0:	83 ec 0c             	sub    $0xc,%esp
    7de3:	8b 7d 10             	mov    0x10(%ebp),%edi
    7de6:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7de9:	8b 75 0c             	mov    0xc(%ebp),%esi
    7dec:	c1 ef 09             	shr    $0x9,%edi
    7def:	01 de                	add    %ebx,%esi
    7df1:	47                   	inc    %edi
    7df2:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
    7df8:	39 f3                	cmp    %esi,%ebx
    7dfa:	73 15                	jae    7e11 <readseg+0x37>
    7dfc:	50                   	push   %eax
    7dfd:	50                   	push   %eax
    7dfe:	57                   	push   %edi
    7dff:	47                   	inc    %edi
    7e00:	53                   	push   %ebx
    7e01:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7e07:	e8 6c ff ff ff       	call   7d78 <readsect>
    7e0c:	83 c4 10             	add    $0x10,%esp
    7e0f:	eb e7                	jmp    7df8 <readseg+0x1e>
    7e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7e14:	5b                   	pop    %ebx
    7e15:	5e                   	pop    %esi
    7e16:	5f                   	pop    %edi
    7e17:	5d                   	pop    %ebp
    7e18:	c3                   	ret    

00007e19 <bootmain>:
    7e19:	55                   	push   %ebp
    7e1a:	89 e5                	mov    %esp,%ebp
    7e1c:	56                   	push   %esi
    7e1d:	53                   	push   %ebx
    7e1e:	52                   	push   %edx
    7e1f:	6a 00                	push   $0x0
    7e21:	68 00 10 00 00       	push   $0x1000
    7e26:	68 00 00 01 00       	push   $0x10000
    7e2b:	e8 aa ff ff ff       	call   7dda <readseg>
    7e30:	83 c4 10             	add    $0x10,%esp
    7e33:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7e3a:	45 4c 46 
    7e3d:	75 38                	jne    7e77 <bootmain+0x5e>
    7e3f:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7e44:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7e4b:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    7e51:	c1 e6 05             	shl    $0x5,%esi
    7e54:	01 de                	add    %ebx,%esi
    7e56:	39 f3                	cmp    %esi,%ebx
    7e58:	73 17                	jae    7e71 <bootmain+0x58>
    7e5a:	50                   	push   %eax
    7e5b:	83 c3 20             	add    $0x20,%ebx
    7e5e:	ff 73 e4             	push   -0x1c(%ebx)
    7e61:	ff 73 f4             	push   -0xc(%ebx)
    7e64:	ff 73 ec             	push   -0x14(%ebx)
    7e67:	e8 6e ff ff ff       	call   7dda <readseg>
    7e6c:	83 c4 10             	add    $0x10,%esp
    7e6f:	eb e5                	jmp    7e56 <bootmain+0x3d>
    7e71:	ff 15 18 00 01 00    	call   *0x10018
    7e77:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7e7c:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7e81:	66 ef                	out    %ax,(%dx)
    7e83:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7e88:	66 ef                	out    %ax,(%dx)
    7e8a:	eb fe                	jmp    7e8a <bootmain+0x71>
