# Use an existing base image as the starting point
FROM ubuntu:20.04 AS build

# Update the package list and install necessary tools
RUN apt-get update && \
    apt-get install -y build-essential git qemu-system-arm

# Set the working directory
WORKDIR /alpha-os

# Copy the kernel source code into the container
COPY . .

# Build the kernel
RUN make clean && make

# Use a minimal image as the final image
FROM alpine:latest

# Install QEMU for ARM emulation
RUN apk --no-cache add qemu-system-arm

# Copy the built kernel from the build stage
COPY --from=build /alpha-os/kernel.elf /alpha-os/

# Command to run QEMU with the built kernel
CMD ["qemu-system-arm", "-kernel", "/alpha-os/kernel.elf"]
