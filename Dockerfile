# Use an existing base image as the starting point
FROM ubuntu:20.04 AS build
ENV DEBIAN_FRONTEND noninteractive
# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    unzip

# Set up Pico SDK
ENV PICO_SDK_PATH=/pico-sdk
RUN git clone -b master https://github.com/raspberrypi/pico-sdk.git $PICO_SDK_PATH

# Set the working directory
WORKDIR /alpha-os

# Copy the Pico SDK import CMake file
COPY ./src/kernel/RP2040/ .

# Build the project
RUN cmake -DCMAKE_BUILD_TYPE=Release . && \
    make

# Use a minimal image as the final image
FROM alpine:latest

# Copy the built kernel from the build stage
COPY --from=build /alpha-os/rp2040.elf /alpha-os/

# Install QEMU for ARM emulation
RUN apk --no-cache add qemu-system-arm

# Command to run QEMU with the built kernel
CMD ["qemu-system-arm", "-kernel", "/alpha-os/rp2040.elf"]
