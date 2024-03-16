// kernel.c

void main() {
    // Video memory address
    char* video_memory = (char*) 0xb8000;
    // Message to display
    char* message = "Hello, World!";
    // Attribute byte for our message (white on black)
    char attribute_byte = 0x0F;
    // Display the message
    int i;
    for (i = 0; message[i] != '\0'; ++i) {
        // Display the character
        video_memory[i * 2] = message[i];
        // Set the attribute byte
        video_memory[i * 2 + 1] = attribute_byte;
    }
}
