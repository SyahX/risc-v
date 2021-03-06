RM	:= rm -f
GCCPREFIX := /PATH/bin/riscv32-unknown-elf-
# linux 下编译器的地址，可能根据不同的操作系统有所修改
LD	:= $(GCCPREFIX)ld
CC	:= $(GCCPREFIX)gcc
AS  := $(GCCPREFIX)as
OBJDUMP := $(GCCPREFIX)objdump
MODULE	:= init
OBJDIR	:= obj
INCLUDE	:= include
SRCDIR	:= kern
LDSCRIPT	:= kern/kernel.ld
SRC	:= $(foreach sdir, $(SRCDIR), $(wildcard $(sdir)/*.S))
OBJ	:= $(patsubst $(SRCDIR)/%.S, $(OBJDIR)/%.o, $(SRC))
TARGET	:= kernel.elf
ASFLAG	:= -D__ASSEMBLY__ -march=rv32i -mabi=ilp32 -g

override ON_FPGA ?= n

ifeq ($(ON_FPGA), y)
	MACH_DEF = -DMACH_FPGA
else
   	MACH_DEF = -DMACH_QEMU
endif
ASFLAG += $(MACH_DEF)

.PHONY: all clean show-utest

all:checkdirs $(TARGET) kernel.bin

$(TARGET): $(OBJ) $(LDSCRIPT)
	$(LD) $(OBJ) -T$(LDSCRIPT)

kernel: $(OBJ) $(LDSCRIPT)
	$(LD) $(OBJ) -T$(LDSCRIPT)

checkdirs: $(OBJDIR)

$(OBJDIR):
	test -d $@ || mkdir $@

$(OBJ): $(OBJDIR)/%.o : $(SRCDIR)/%.S
	$(CC) -o $@ $< -c -I$(INCLUDE) $(ASFLAG)

kernel.bin: $(TARGET)
	@$(GCCPREFIX)objcopy -j .text -j .text.* -O binary -v $< kernel.bin

show-utest: $(TARGET)
	@$(GCCPREFIX)objdump -D $< | grep "^[0-9a-f]\{8\} <UTEST_" | grep -n --color=auto 'UTEST_'

final : $(TARGET)
	$(OBJDUMP) -d $< > final.txt

clean:
	-$(RM) -r $(OBJDIR)