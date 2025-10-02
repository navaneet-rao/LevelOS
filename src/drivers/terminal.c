#include "drivers/terminal.h"

/* Level OS - terminal driver Implementation
 * VGA terminal driver
 */

// Global terminal state
static terminal_t terminal;

/* Private function declarations */
static size_t strlen(const char *str);

/* Public function implementations */
void terminal_initialize(void)
{
    terminal.row = 0;
    terminal.column = 0;
    terminal.color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal.buffer = (uint16_t *)VGA_MEMORY;

    // Clear the screen
    terminal_clear();
}

void terminal_setcolor(uint8_t color)
{
    terminal.color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y)
{
    const size_t index = y * VGA_WIDTH + x;
    terminal.buffer[index] = vga_entry(c, color);
}

void terminal_putchar(char c)
{
    if (c == '\n')
    {
        terminal.column = 0;
        if (++terminal.row == VGA_HEIGHT)
        {
            terminal.row = 0;
        }
        return;
    }

    terminal_putentryat(c, terminal.color, terminal.column, terminal.row);

    if (++terminal.column == VGA_WIDTH)
    {
        terminal.column = 0;
        if (++terminal.row == VGA_HEIGHT)
        {
            terminal.row = 0;
        }
    }
}

void terminal_write(const char *data, size_t size)
{
    for (size_t i = 0; i < size; i++)
    {
        terminal_putchar(data[i]);
    }
}

void terminal_writestring(const char *data)
{
    terminal_write(data, strlen(data));
}

void terminal_clear(void)
{
    for (size_t y = 0; y < VGA_HEIGHT; y++)
    {
        for (size_t x = 0; x < VGA_WIDTH; x++)
        {
            const size_t index = y * VGA_WIDTH + x;
            terminal.buffer[index] = vga_entry(' ', terminal.color);
        }
    }
    terminal.row = 0;
    terminal.column = 0;
}

/* Private function implementations */
static size_t strlen(const char *str)
{
    size_t len = 0;
    while (str[len])
    {
        len++;
    }
    return len;
}
