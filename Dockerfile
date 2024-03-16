# Use an existing base image as the starting point
FROM arm32v7/alpine AS build

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

# Use a minimal image as the final image
FROM arm32v7/alpine:latest

# Copy the built kernel from the build stage
COPY --from=build /alpha-os/kernel.elf /alpha-os/

# Command to run QEMU with the built kernel
CMD ["qemu-system-arm-static", "-kernel", "/alpha-os/kernel.elf"]
