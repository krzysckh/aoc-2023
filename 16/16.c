#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define _at(v,x,y) (v)[(w*(y))+(x)]
#define at(x,y) _at(map,(x),(y))
#define MAX(a,b) (((a)>(b))?a:b)

enum tile_type
{
  empty   = '.',
  lmirror = '\\',
  rmirror = '/',
  vsplit  = '-',
  hsplit  = '|',
};

typedef struct
{
  enum tile_type t;
  bool marked;
  bool ml, mr, mu, md; /* marked from: left, right, up, down */
} Tile;

static Tile *map_orig;
static Tile *map;
static int w = 0;
static int h = 0;

void
printmap(void)
{
  int i, j;

  for (i = 0; i < h; ++i) {
    for (j = 0; j < w; ++j)
      if (at(j, i).marked)
        putchar('#');
      else
        putchar(at(j, i).t);
    putchar('\n');
  }
}

int
get_energized(void)
{
  int i, j, n = 0;

  for (i = 0; i < h; ++i)
    for (j = 0; j < w; ++j)
      if (at(j, i).marked) n++;

  return n;
}

// i smell recursion
void
run(int x, int y, int dx, int dy, int lastx, int lasty)
{
  if (x < 0 || y < 0 || x >= w || y >= h)
    return;

  at(x,y).marked = true;
  if (x > lastx) {
    if (at(x,y).ml) return;
    at(x,y).ml = true;
  }
  if (x < lastx) {
    if (at(x,y).mr) return;
    at(x,y).mr = true;
  }
  if (y > lasty) {
    if (at(x,y).mu) return;
    at(x,y).mu = true;
  }
  if (y < lasty) {
    if (at(x,y).md) return;
    at(x,y).md = true;
  }

  //printmap();
  //puts("");
  switch (at(x, y).t) {
  case empty:
    run(x + dx, y + dy, dx, dy, x, y);
    break;
  case lmirror:
    if (lasty == y) {
      run(x, lastx > x ? y - 1 : y + 1, 0, lastx > x ? -1 : 1, x, y);
    } else {
      run(lasty > y ? x - 1 : x + 1, y, lasty > y ? -1 : 1, 0, x, y);
    }
    break;
  case rmirror:
    if (lasty == y) {
      run(x, lastx > x ? y + 1 : y - 1, 0, lastx > x ? 1 : -1, x, y);
    } else {
      run(lasty > y ? x + 1 : x - 1, y, lasty > y ? 1 : -1, 0, x, y);
    }
    break;
  case vsplit:
    if (lastx == x) {
      run(x - 1, y, -1, 0, x, y);
      run(x + 1, y, 1, 0, x, y);
    } else {
      run(x + dx, y + dy, dx, dy, x, y);
    }
    break;
  case hsplit:
    if (lasty == y) {
      run(x, y - 1, 0, -1, x, y);
      run(x, y + 1, 0, 1, x, y);
    } else {
      run(x + dx, y + dy, dx, dy, x, y);
    }
    break;
  }
}

void
findcomb(void)
{
  int i, x, y, *vals = malloc(sizeof(int) * ((w * 2) + (h * 2))), cur = 0, max = 0;

  // top and bottom row
  for (x = 0; x < w; ++x) {
    memcpy(map, map_orig, sizeof(Tile) * 128 * 128);
    run(x, 0, 0, 1, 0, 0);
    vals[cur++] = get_energized();

    memcpy(map, map_orig, sizeof(Tile) * 128 * 128);
    run(x, h-1, 0, -1, 0, 0);
    vals[cur++] = get_energized();
  }

  // L and R column
  for (y = 0; y < h; ++y) {
    memcpy(map, map_orig, sizeof(Tile) * 128 * 128);
    run(0, y, 1, 0, 0, 0);
    vals[cur++] = get_energized();

    memcpy(map, map_orig, sizeof(Tile) * 128 * 128);
    run(w-1, y, -1, 0, 0, 0);
    vals[cur++] = get_energized();
  }

  for (i = 0; i < (2 * w) + (h * 2); ++i)
    max = MAX(vals[i], max);

  printf("p2: %d\n", max);

  free(vals);
}

int
main(void)
{
  FILE *fp = fopen("in", "r");
  int c, W = 0, cur = 0;

  map = malloc(sizeof(Tile) * 128 * 128);
  map_orig = malloc(sizeof(Tile) * 128 * 128);

  extern int w, h;
  extern Tile *map;

  while ((c = fgetc(fp)) != EOF) {
    if (c == '\n') {
      w = MAX(W, w);
      ++h;
      W = 0;
    } else {
      W++;
      map[cur++] = (Tile) {
        .t = c,
        .marked = 0,
        .ml = 0, .mr = 0, .mu = 0, .md = 0
      };
    }
  }

  memcpy(map_orig, map, sizeof(Tile) * 128 * 128);

  //printmap();
  run(0, 0, 1, 0, 0, 0);

  printf("p1: %d\n", get_energized());

  findcomb();

  free(map);
  fclose(fp);
}
