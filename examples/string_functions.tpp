# Comprehensive example demonstrating strlen and substr
# This mimics the real-world usage from prog_pause.tpp

# Define string and numeric registers
pause_location := SR[10]
dummy_str1 := SR[23]
dummy_str2 := SR[24]
dummy_r1 := R[173]
dvar1 := R[270]

# Initialize the string (this would normally come from somewhere else)
# In real code: pause_location would be set by another part of the program

# Example 1: Get length of string
dummy_r1 = strlen(pause_location)

# Example 2: Extract first 10 characters
dummy_str1 = substr(pause_location, 1, 10)

# Example 3: Calculate remaining length and extract rest of string
dvar1 = dummy_r1 - 10
dummy_str2 = substr(pause_location, 11, dvar1)

# Example 4: Work with different string registers
my_text := SR[50]
part1 := SR[51]
part2 := SR[52]
text_len := R[100]
part2_len := R[101]

# Get full length
text_len = strlen(my_text)

# Split string in half
part1 = substr(my_text, 1, 5)
part2_len = text_len - 5
part2 = substr(my_text, 6, part2_len)

# Example 5: Using with conditionals
check_len := R[200]
short_flag := F[100]

check_len = strlen(my_text)
if check_len < 10
  turn_on short_flag
end
