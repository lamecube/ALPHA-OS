# Define board-specific build targets
rp2040: src/kernel/RP2040/rp2040.asm
	@echo "Building for RP2040..."
	mkdir -p build
	nasm -f elf32 src/kernel/RP2040/rp2040.asm -o build/rp2040.o
	ld -m elf_i386 -Ttext 0x0 --oformat binary build/rp2040.o -o build/rp2040.bin

# esp32: src/kernel/ESP32/esp32.asm
# 	@echo "Building for ESP32..."
# 	mkdir -p build
# 	nasm -f elf32 src/kernel/ESP32/esp32.asm -o build/esp32.o
# 	ld -m elf_i386 -Ttext 0x0 --oformat binary build/esp32.o -o build/esp32.bin

# stm32: src/kernel/STM32/stm32.asm
# 	@echo "Building for STM32..."
# 	mkdir -p build
# 	nasm -f elf32 src/kernel/STM32/stm32.asm -o build/stm32.o
# 	ld -m elf_i386 -Ttext 0x0 --oformat binary build/stm32.o -o build/stm32.bin

# raspberry_pi: src/kernel/RaspberryPi/raspberry_pi.asm
# 	@echo "Building for Raspberry Pi..."
# 	mkdir -p build
# 	nasm -f elf32 src/kernel/RaspberryPi/raspberry_pi.asm -o build/raspberry_pi.o
# 	ld -m elf_i386 -Ttext 0x0 --oformat binary build/raspberry_pi.o -o build/raspberry_pi.bin

# thumby: src/kernel/Thumby/thumby.asm
# 	@echo "Building for Thumby..."
# 	mkdir -p build
# 	nasm -f elf32 src/kernel/Thumby/thumby.asm -o build/thumby.o
# 	ld -m elf_i386 -Ttext 0x0 --oformat binary build/thumby.o -o build/thumby.bin

# Define target to build for all boards
all: rp2040 # esp32 stm32 raspberry_pi thumby

# Define target to clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/*

.PHONY: rp2040 # esp32 stm32 raspberry_pi thumby all clean
