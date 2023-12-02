#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool find(const char *hay, char needle, size_t *len) {
  for (const char *it = hay; *it != 0; it++) {
    if (*it == needle) {
      *len = it - hay;
      return true;
    }
  }

  return false;
}

void skip_header(const char *line, size_t *pos) {
  *pos += 5; // skip "Game "

  while (isdigit(line[*pos])) {
    *pos += 1;
  }

  *pos += 2; // skip ": "
}

bool parse_cube_amount_and_check(const char *line, size_t *pos) {
  int amount = atoi(line + *pos);

  printf("amount %d\n", amount);

  while (isdigit(line[*pos])) {
    *pos += 1;
  }
  *pos += 1; // skip " "

  int max_amount;
  switch (line[*pos]) {
  case 'r':
    *pos += 3;
    max_amount = 12;
    break;
  case 'g':
    *pos += 5;
    max_amount = 13;
    break;
  case 'b':
    *pos += 4;
    max_amount = 14;
    break;
  default:
    fprintf(stderr, "invalid input!");
    exit(1);
  }

  if (amount > max_amount) {
    return false;
  } else {
    return true;
  }
}

int main(int argc, const char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s <input_file>\n", argv[0]);
    return 1;
  }

  FILE *input_file = fopen(argv[1], "r");
  if (input_file == NULL) {
    fprintf(stderr, "failed to open file '%s'\n", argv[1]);
    return 1;
  }

  fseek(input_file, 0, SEEK_END);
  size_t content_len = ftell(input_file);
  char *content = malloc(content_len);
  fseek(input_file, 0, SEEK_SET);
  fread(content, 1, content_len, input_file);

  int sum = 0;

  const char *line = content;
  size_t len;
  for (int index = 1; find(line, '\n', &len); line += len + 1, index += 1) {
    size_t pos = 0;
    skip_header(line, &pos);

    bool found_impossible = false;
    while (pos < len) {
      if (!parse_cube_amount_and_check(line, &pos)) {
        found_impossible = true;
        break;
      }
      pos += 2;
    }

    if (!found_impossible) {
      sum += index;
    }
  }

  printf("sum: %d\n", sum);

  return 0;
}
