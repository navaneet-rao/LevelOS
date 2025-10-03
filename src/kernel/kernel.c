#include "kernel/kernel.h"
#include "drivers/terminal.h"

/* Level OS - Main Kernel
 * Entry point and basic kernel functionality
 */

void kernel_main(void)
{
    // Initialize terminal/display
    terminal_initialize();

    // Set colors for our welcome message
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));

    // Print our "Hello World" message
    terminal_writestring("Hello World!\n");
    terminal_writestring("Welcome to Level OS v");

    // Print version info from build system
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK));

    // Convert version numbers to strings and display
    char version_str[64];
    char major_str[8], minor_str[8], patch_str[8], build_str[16];

    // Simple integer to string conversion
    int major = VERSION_MAJOR;
    int minor = VERSION_MINOR;
    int patch = VERSION_PATCH;
    int build = BUILD_NUMBER;

    // Convert major version
    major_str[0] = '0' + major;
    major_str[1] = '\0';

    // Convert minor version
    minor_str[0] = '0' + minor;
    minor_str[1] = '\0';

    // Convert patch version
    patch_str[0] = '0' + patch;
    patch_str[1] = '\0';

    // Convert build number (supports up to 99)
    if (build < 10)
    {
        build_str[0] = '0' + build;
        build_str[1] = '\0';
    }
    else
    {
        build_str[0] = '0' + (build / 10);
        build_str[1] = '0' + (build % 10);
        build_str[2] = '\0';
    }

    // Build version string: "major.minor.patch+buildN"
    int i = 0;
    version_str[i++] = major_str[0];
    version_str[i++] = '.';
    version_str[i++] = minor_str[0];
    version_str[i++] = '.';
    version_str[i++] = patch_str[0];
    version_str[i++] = '+';
    version_str[i++] = 'b';
    version_str[i++] = 'u';
    version_str[i++] = 'i';
    version_str[i++] = 'l';
    version_str[i++] = 'd';
    // Copy build number
    int j = 0;
    while (build_str[j] != '\0')
    {
        version_str[i++] = build_str[j++];
    }
    version_str[i] = '\0';

    terminal_writestring(version_str);

    // Reset color and add some info
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
    terminal_writestring("\n\nKernel loaded successfully!");
    terminal_writestring("\nSystem initialized and ready.");

    // Add some colorful text to show we can control colors
    terminal_writestring("\n\n");
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK));
    terminal_writestring("Level OS");
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
    terminal_writestring(" - A learning journey into OS development\n");

    // Simple status message
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK));
    terminal_writestring("Status: Basic terminal output working!\n");

    // Infinite loop to prevent kernel from exiting
    while (1)
    {
        // In a real OS, this would be the scheduler
        // For now, we just loop forever
        __asm__ volatile("hlt"); // Halt instruction to save CPU cycles
    }
}

void kernel_panic(const char *message)
{
    // Set error colors (white text on red background)
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_RED));
    terminal_clear();

    terminal_writestring("KERNEL PANIC: ");
    terminal_writestring(message);
    terminal_writestring("\nSystem halted.");

    // Disable interrupts and halt
    __asm__ volatile("cli; hlt");

    // Infinite loop as backup
    while (1)
    {
        __asm__ volatile("hlt");
    }
}