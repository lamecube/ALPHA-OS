cmake_minimum_required(VERSION 3.10)

project(MY_RP2040_ASM_PROJECT
        LANGUAGES C CXX ASM
        DESCRIPTION "RP2040 application in assembly"
)

# Add the assembly file to the project
add_executable(rp2040.elf rp2040.asm)

# Set the target properties
set_target_properties(rp2040.elf PROPERTIES
    OUTPUT_NAME "rp2040"  # Output file name
)

# Set compiler and linker flags
target_compile_options(rp2040.elf PRIVATE
    # Add any necessary compiler options here
)

target_link_options(rp2040.elf PRIVATE
    # Add any necessary linker options here
)
