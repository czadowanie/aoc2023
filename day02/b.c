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

int imax(int a, int b) {
  if (a > b) {
    return a;
  } else {
    return b;
  }
}

void skip_header(const char *line, size_t *pos) {
  *pos += 5; // skip "Game "

  while (isdigit(line[*pos])) {
    *pos += 1;
  }

  *pos += 2; // skip ": "
}

typedef struct {
  int r;
  int g;
  int b;
} MinCubeAmounts;

void parse_cube_amount_and_update(const char *line, size_t *pos,
                                  MinCubeAmounts *mca) {
  int amount = atoi(line + *pos);

  printf("amount %d\n", amount);

  while (isdigit(line[*pos])) {
    *pos += 1;
  }
  *pos += 1; // skip " "

  int *field = NULL;

  switch (line[*pos]) {
  case 'r':
    *pos += 3;
    field = &(mca->r);
    break;
  case 'g':
    *pos += 5;
    field = &(mca->g);
    break;
  case 'b':
    *pos += 4;
    field = &(mca->b);
    break;
  default:
    fprintf(stderr, "invalid input!");
    exit(1);
  }

  *field = imax(*field, amount);
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

    MinCubeAmounts mca = {0};

    while (pos < len) {
      parse_cube_amount_and_update(line, &pos, &mca);
      pos += 2;
    }

    sum += mca.r * mca.g * mca.b;
  }

  printf("sum: %d\n", sum);

  return 0;
}
