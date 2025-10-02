/* LevelOS - Test Framework
 * Simple test framework for kernel testing
 */

#include "test_framework.h"
#include "drivers/terminal.h"

static int tests_run = 0;
static int tests_passed = 0;
static int tests_failed = 0;

void test_init(void) {
    tests_run = 0;
    tests_passed = 0;
    tests_failed = 0;
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK));
    terminal_writestring("LevelOS Test Framework\n");
    terminal_writestring("=====================\n");
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
}

void test_assert(int condition, const char* test_name) {
    tests_run++;
    
    if (condition) {
        tests_passed++;
        terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
        terminal_writestring("[PASS] ");
    } else {
        tests_failed++;
        terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK));
        terminal_writestring("[FAIL] ");
    }
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
    terminal_writestring(test_name);
    terminal_writestring("\n");
}

void test_summary(void) {
    terminal_writestring("\nTest Summary:\n");
    terminal_writestring("=============\n");
    
    // Simple integer to string conversion for display
    char buffer[16];
    
    terminal_writestring("Tests run: ");
    simple_itoa(tests_run, buffer);
    terminal_writestring(buffer);
    terminal_writestring("\n");
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
    terminal_writestring("Passed: ");
    simple_itoa(tests_passed, buffer);
    terminal_writestring(buffer);
    terminal_writestring("\n");
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK));
    terminal_writestring("Failed: ");
    simple_itoa(tests_failed, buffer);
    terminal_writestring(buffer);
    terminal_writestring("\n");
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
}

void simple_itoa(int value, char* buffer) {
    if (value == 0) {
        buffer[0] = '0';
        buffer[1] = '\0';
        return;
    }
    
    int i = 0;
    while (value > 0) {
        buffer[i++] = '0' + (value % 10);
        value /= 10;
    }
    buffer[i] = '\0';
    
    // Reverse the string
    int start = 0, end = i - 1;
    while (start < end) {
        char temp = buffer[start];
        buffer[start] = buffer[end];
        buffer[end] = temp;
        start++;
        end--;
    }
}