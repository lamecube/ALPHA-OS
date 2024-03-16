# Use a base image with necessary development tools
FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    nasm \
    gcc \
    grub-common \
    xorriso \
    qemu-system-x86

# Set up a working directory
WORKDIR /alpha_os

# Copy the source files into the container
COPY ./src/ .

# Compile the bootloader
RUN nasm -f bin bootloader.asm -o bootloader.bin

# Compile the kernel
RUN gcc -ffreestanding -c kernel.c -o kernel.o

# Link the kernel object file and convert to binary format
RUN ld -o kernel.elf -Ttext 0x1000 kernel.o
RUN objcopy -O binary kernel.elf kernel.bin

# Create disk image
RUN mkdir -p isodir/boot/grub \
    && cp kernel.bin isodir/boot/kernel.bin \
    && echo "menuentry 'Hello World OS' { multiboot /boot/kernel.bin }" > isodir/boot/grub/grub.cfg \
    && grub-mkrescue -o os.iso isodir

# Define a command to run when the container starts
CMD ["qemu-system-x86_64", "-cdrom", "os.iso"]
