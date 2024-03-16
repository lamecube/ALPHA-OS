# Use an ARM-based image as the base
FROM arm32v7/alpine

# Install necessary packages
RUN apk update && apk add --no-cache \
    build-base \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    git \
    qemu-system-arm-static

# Set the working directory
WORKDIR /alpha-os

# Copy the kernel source code into the container
COPY . .

# Build the kernel
RUN make clean && make

# Command to run QEMU with the built kernel
CMD qemu-system-arm-static -kernel kernel.elf
