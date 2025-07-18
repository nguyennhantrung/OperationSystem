# Overview
## FAT 12
FAT 12 was designed for floppy disks and can manage a maximum size of 16 megabytes because it uses 12 bits to address the clusters.

## FAT 16
FAT 16 was designed for early hard disks and could handle a maximum size of 64K clusters * the cluster size. The larger the hard disk, the larger the cluster size would be, which leads to large amounts of "slack space" on the disk.

## FAT 32
FAT 32 was introduced to us by Windows95-B and Windows98. FAT32 solved some of FAT's problems. No more 64K max clusters! Although FAT32 uses 32 bits per FAT entry, only the bottom 28 bits are actually used to address clusters on the disk (top 4 bits are reserved). With 28 bits per FAT entry, the filesystem can address a maximum of about 270 million clusters in a partition. This enables very large hard disks to still maintain reasonably small cluster sizes and thus reduce slack space between files.

## ExFAT
ExFAT is the filesystem used on SDXC cards, created by Microsoft. It is FAT32 with actually 32 bits per FAT entry, with the ability to indicate a file is fully consecutive on disk (allowing you to skip reading the FAT), some more advanced features and a fully redesigned file entry system. Since it's so similar to FAT32, please merge any bits of info from the exFAT article into this one.

## VFAT
VFAT is an extension to the FAT file system that has the ability to use long filenames (up to 255 characters). First introduced by Windows 95, it uses a "kludge" whereby long filenames are marked with a "volume label" attribute and filenames are subsequently stored in 11 byte chunks in sequential directory entries. (This is a bit of an oversimplification, but close enough).
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Implementation Details
The FAT file system views the storage media as a flat array of clusters. If the physical media does not address its data as a flat list of sectors (really old hard disks and floppy disks) then the cluster numbers will need to be translated before being sent to the disk. The storage media is organized into three basic areas.

- The boot record
- The File Allocation Table (FAT)
- The directory and data area

## Boot Record
The boot record occupies one sector, and is always placed in logical sector number zero of the "partition". If the media is not divided into partitions, then this is the beginning of the media. This is the easiest sector on the partition for the computer to locate when it is loaded. If the storage media is partitioned (such as a hard disk), then the beginning of the actual media contains an MBR (x86) or other form of partition information. In this case each partition's first sector holds a Volume Boot Record.

### BPB (BIOS Parameter Block)
The boot record contains both code and data, mixed together. The data that isn't code is known as the BPB.
Offset (decimal)	Offset (hex)	Size (in bytes)		Meaning
0					0x00			3					The first three bytes EB 3C 90 disassemble to JMP SHORT 3C NOP. (The 3C value may be different.) The reason for this is to jump over the disk format information (the BPB and EBPB). Since the first sector of the disk is loaded into ram at location 0x0000:0x7c00 and executed, without this jump, the processor would attempt to execute data that isn't code. Even for non-bootable volumes, code matching this pattern (or using the E9 jump opcode) is required to be present by both Windows and OS X. To fulfil this requirement, an infinite loop can be placed here with the bytes EB FE 90.
3					0x03			8					OEM identifier. The first 8 Bytes (3 - 10) is the version of DOS being used. The next eight Bytes 29 3A 63 7E 2D 49 48 and 43 read out the name of the version. The official FAT Specification from Microsoft says that this field is really meaningless and is ignored by MS FAT Drivers, however it does recommend the value "MSWIN4.1" as some 3rd party drivers supposedly check it and expect it to have that value. Older versions of dos also report MSDOS5.1, linux-formatted floppy will likely to carry "mkdosfs" here, and FreeDOS formatted disks have been observed to have "FRDOS5.1" here. If the string is less than 8 bytes, it is padded with spaces.
11					0x0B			2					The number of Bytes per sector (remember, all numbers are in the little-endian format).
13					0x0D			1					Number of sectors per cluster.
14					0x0E			2					Number of reserved sectors. The boot record sectors are included in this value.
16					0x10			1					Number of File Allocation Tables (FAT's) on the storage media. Often this value is 2.
17					0x11			2					Number of root directory entries (must be set so that the root directory occupies entire sectors).
19					0x13			2					The total sectors in the logical volume. If this value is 0, it means there are more than 65535 sectors in the volume, and the actual count is stored in the Large Sector Count entry at 0x20.
21					0x15			1					This Byte indicates the media descriptor type.
22					0x16			2					Number of sectors per FAT. FAT12/FAT16 only.
24					0x18			2					Number of sectors per track.
26					0x1A			2					Number of heads or sides on the storage media.
28					0x1C			4					Number of hidden sectors. (i.e. the LBA of the beginning of the partition.)
32					0x20			4					Large sector count. This field is set if there are more than 65535 sectors in the volume, resulting in a value which does not fit in the Number of Sectors entry at 0x13.

--- Extended Boot Record ---
**(FAT 12 and FAT 16)**
Offset (decimal)	Offset (hex)	Size (in bytes)		Meaning
36					0x024			1					Drive number. The value here should be identical to the value returned by BIOS interrupt 0x13, or passed in the DL register; i.e. 0x00 for a floppy disk and 0x80 for hard disks. This number is useless because the media is likely to be moved to another machine and inserted in a drive with a different drive number.
37					0x025			1					Flags in Windows NT. Reserved otherwise.
38					0x026			1					Signature (must be 0x28 or 0x29).
39					0x027			4					VolumeID 'Serial' number. Used for tracking volumes between computers. You can ignore this if you want.
43					0x02B			11					Volume label string. This field is padded with spaces.
54					0x036			8					System identifier string. This field is a string representation of the FAT file system type. It is padded with spaces. The spec says never to trust the contents of this string for any use.
62					0x03E			448					Boot code.
510					0x1FE			2					Bootable partition signature 0xAA55.
**FAT 32**

Offset (decimal)	Offset (hexadecimal)	Length (in bytes)	Meaning
36					0x024			4					Sectors per FAT. The size of the FAT in sectors.
40					0x028			2					Flags.
42					0x02A			2					FAT version number. The high byte is the major version and the low byte is the minor version. FAT drivers should respect this field.
44					0x02C			4					The cluster number of the root directory. Often this field is set to 2.
48					0x030			2					The sector number of the FSInfo structure.
50					0x032			2					The sector number of the backup boot sector.
52					0x034			12					Reserved. When the volume is formated these bytes should be zero.
64					0x040			1					Drive number. The values here are identical to the values returned by the BIOS interrupt 0x13. 0x00 for a floppy disk and 0x80 for hard disks.
65					0x041			1					Flags in Windows NT. Reserved otherwise.
66					0x042			1					Signature (must be 0x28 or 0x29).
67					0x043			4					Volume ID 'Serial' number. Used for tracking volumes between computers. You can ignore this if you want.
71					0x047			11					Volume label string. This field is padded with spaces.
82					0x052			8					System identifier string. Always "FAT32   ". The spec says never to trust the contents of this string for any use.
90					0x05A			420					Boot code.
510					0x1FE			2					Bootable partition signature 0xAA55.

**FSInfo Structure (FAT32 only)**
Offset (decimal)	Offset (hexadecimal)	Length (in bytes)	Meaning
0					0x0				4					Lead signature (must be 0x41615252 to indicate a valid FSInfo structure)
4					0x4				480					Reserved, these bytes should never be used
484					0x1E4			4					Another signature (must be 0x61417272)
488					0x1E8			4					Contains the last known free cluster count on the volume. If the value is 0xFFFFFFFF, then the free count is unknown and must be computed. However, this value might be incorrect and should at least be range checked (<= volume cluster count)
492					0x1EC			4					Indicates the cluster number at which the filesystem driver should start looking for available clusters. If the value is 0xFFFFFFFF, then there is no hint and the driver should start searching at 2. Typically this value is set to the last allocated cluster number. As the previous field, this value should be range checked.
496					0x1F0			12					Reserved
508					0x1FC			4					Trail signature (0xAA550000)

**exFat boot record**
Offset (decimal)	Offset (hex)	Size (in bytes)	Meaning
0					0x00			3				The first three bytes EB 3C 90 disassemble to JMP SHORT 3C NOP. (The 3C value may be different.) The reason for this is to jump over the disk format information (the BPB and EBPB). Since the first sector of the disk is loaded into ram at location 0x0000:0x7c00 and executed, without this jump, the processor would attempt to execute data that isn't code. Even for non-bootable volumes, code matching this pattern (or using the E9 jump opcode) is required to be present by both Windows and OS X. To fulfil this requirement, an infinite loop can be placed here with the bytes EB FE 90.
3					0x03			8				OEM identifier. This contains the string "EXFAT ". Not to be used for filesystem determination, but it's a nice hint.
11					0x0B			53				Set to zero. This makes sure any FAT driver will not be able to load it.
64					0x40			8				Partition offset. No idea why the partition itself would have this, but it's here. Might be wrong. Probably best to just ignore.
72					0x48			8				Volume length.
80					0x50			4				FAT offset (in sectors) from start of partition.
84					0x54			4				FAT length (in sectors).
88					0x58			4				Cluster heap offset (in sectors).
92					0x5C			4				Cluster count
96					0x60			4				Root directory cluster. Typically 4 (but just read this value).
100					0x64			4				Serial number of partition.
104					0x68			2				Filesystem revision
106					0x6A			2				Flags
108					0x6C			1				Sector shift
109					0x6D			1				Cluster shift
110					0x6E			1				Number of FATs
111					0x6F			1				Drive select
112					0x70			1				Percentage in use
113					0x71			7				Reserved (set to 0).
