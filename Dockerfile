# Use an existing base image as the starting point
FROM ubuntu:20.04 AS build

# Update the package list
RUN apt-get update

# Install NASM and LD
RUN apt-get install -y nasm binutils

# Copy the assembly code into the container
COPY hello.asm /app/

# Assemble and link the code
RUN nasm -f elf -o /app/hello.o /app/hello.asm
RUN ld -m elf_i386 -s -o /app/hello /app/hello.o

# Use a minimal image as the final image
FROM alpine:latest

# Copy the executable from the build stage
COPY --from=build /app/hello /app/

# Run the executable
CMD ["/app/hello"]