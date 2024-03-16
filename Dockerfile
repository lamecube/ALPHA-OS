# Use an ARM-based image as the base
FROM arm32v7/debian:bullseye

# Install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    git \
    qemu-system-arm

# Set the working directory
WORKDIR /alpha-os

# Copy the kernel source code into the container
COPY . .

# Build the kernel
RUN make clean && make

# Command to run QEMU with the built kernel
CMD qemu-system-arm -kernel kernel.elf
