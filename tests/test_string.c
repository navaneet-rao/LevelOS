/* LevelOS - String Library Tests
 * Unit tests for string manipulation functions
 */

#include "test_framework.h"
#include "lib/string.h"

void test_string_functions(void) {
    // Test strlen
    TEST_ASSERT_EQ(strlen("hello"), 5, "strlen basic test");
    TEST_ASSERT_EQ(strlen(""), 0, "strlen empty string");
    
    // Test memset
    char buffer[10];
    memset(buffer, 'A', 5);
    buffer[5] = '\0';
    TEST_ASSERT(buffer[0] == 'A' && buffer[4] == 'A', "memset test");
    
    // Test memcpy
    char src[] = "test";
    char dest[5];
    memcpy(dest, src, 5);
    TEST_ASSERT_EQ(memcmp(src, dest, 4), 0, "memcpy test");
    
    // Test memcmp
    TEST_ASSERT_EQ(memcmp("abc", "abc", 3), 0, "memcmp equal strings");
    TEST_ASSERT_NEQ(memcmp("abc", "abd", 3), 0, "memcmp different strings");
}

void run_string_tests(void) {
    test_string_functions();
}