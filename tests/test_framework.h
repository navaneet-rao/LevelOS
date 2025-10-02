/* LevelOS - Test Framework Header
 * Simple test framework for kernel testing
 */

#ifndef TEST_FRAMEWORK_H
#define TEST_FRAMEWORK_H

// Test framework functions
void test_init(void);
void test_assert(int condition, const char* test_name);
void test_summary(void);

// Utility functions
void simple_itoa(int value, char* buffer);

// Test macros
#define TEST_ASSERT(condition, name) test_assert((condition), (name))
#define TEST_ASSERT_EQ(a, b, name) test_assert((a) == (b), (name))
#define TEST_ASSERT_NEQ(a, b, name) test_assert((a) != (b), (name))

#endif // TEST_FRAMEWORK_H