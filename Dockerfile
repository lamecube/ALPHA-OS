# Use an existing base image as the starting point
FROM ubuntu:20.04 AS build

# Update the package list and install necessary tools including NASM
RUN apt-get update && \
    apt-get install -y build-essential git nasm binutils qemu-user-static

# Set the working directory
WORKDIR /alpha-os

# Copy the kernel source code into the container
COPY . .

# Build the kernel
RUN nasm -f elf32 ./src/kernel/RP2040/rp2040.asm -o rp2040.o && \
    ld -m elf_i386 -o rp2040.elf rp2040.o

# Use a minimal image as the final image
FROM alpine:latest

# Install QEMU for ARM emulation
RUN apk --no-cache add qemu-system-arm

# Copy the built kernel from the build stage
COPY --from=build /alpha-os/rp2040.elf /alpha-os/

# Command to run QEMU with the built kernel
CMD ["qemu-system-arm", "-kernel", "/alpha-os/rp2040.elf"]
