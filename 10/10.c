#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/wait.h>
#include "tg.h"

typedef enum
{
  V     = '-',
  H     = '|',
  NE    = 'L',
  NW    = 'J',
  SW    = '7',
  SE    = 'F',
  GND   = '.',
  START = 'S'
} pipe_dir_t;

typedef struct pipe_t
{
  pipe_dir_t d;
  struct pipe_t *l, *r;
  int distance, x, y, is_loop;
} pipe_t;

static pipe_t *start = NULL;
static pipe_t *map = NULL;
#define MAP_W 140
#define MAP_H 140
static int map_sz = MAP_W * MAP_H;

#define UP    (i > MAP_W ? &map[i-MAP_W] : NULL)
#define DOWN  (i < (map_sz - MAP_W) ? &map[i+MAP_W] : NULL)
#define LEFT  (i > 0 && i % MAP_W != 0 ? &map[i-1] : NULL)
#define RIGHT (i > 0 && (i+1) % MAP_W != 0 ? &map[i+1] : NULL)

static
void
parsemap(void)
{
  int i = 0, found = 0;
  for (; i < map_sz; ++i) {
    switch (map[i].d) {
    case V:
      map[i].l = LEFT;
      map[i].r = RIGHT;
      break;
    case H:
      map[i].l = UP;
      map[i].r = DOWN;
      break;
    case NE:
      map[i].l = UP;
      map[i].r = RIGHT;
      break;
    case NW:
      map[i].l = UP;
      map[i].r = LEFT;
      break;
    case SW:
      map[i].l = DOWN;
      map[i].r = LEFT;
      break;
    case SE:
      map[i].l = DOWN;
      map[i].r = RIGHT;
      break;
    case GND:
      map[i].l = NULL;
      map[i].r = NULL;
      break;
    case START:
      start = &map[i];
      if (map[i-1].d == V || map[i-1].d == NE || map[i-1].d == SE) {
        if (found) map[i].r = &map[i-1];
        else       map[i].l = &map[i-1];

        found = 1;
      }
      if (map[i+1].d == V || map[i+1].d == NW || map[i+1].d == SW) {
        if (found) map[i].r = &map[i+1];
        else       map[i].l = &map[i+1];
        found = 1;
      }
      if (map[i-MAP_W].d == H || map[i-MAP_W].d == SW || map[i-MAP_W].d == SE) {
        if (found) map[i].r = &map[i-MAP_W];
        else       map[i].l = &map[i-MAP_W];
        found = 1;
      }
      if (map[i+MAP_W].d == H || map[i+MAP_W].d == NE || map[i+MAP_W].d == NW) {
        if (found) map[i].r = &map[i+MAP_W];
        else       map[i].l = &map[i+MAP_W];
        found = 1;
      }
    break;
    }
  }
}

__attribute__((unused))
static
void
printmap(void)
{
  int i = 0;
  for (; i < map_sz; ++i) {
    putchar(map[i].d);
    if ((i+1) % MAP_W == 0)
      putchar('\n');
  }
}

static
int
get_full_distance(void)
{
  pipe_t *cur = start,
         *prev = start->l;
  int dist = 0;
  while (1) {
    if (cur->l == prev) {
      prev = cur;
      cur = cur->r;
    } else {
      prev = cur;
      cur = cur->l;
    }

    if (cur == start) break;
    dist++;
  }

  return dist;
}

static
void
set_distance(void)
{
  pipe_t *cur = start,
         *prev = start->l;
  int full_dist = get_full_distance(),
      cur_dist = 0,
      after_half = 0;
  while (1) {
    cur->distance = cur_dist;
    cur->is_loop = 1;
    if (!after_half)
      cur_dist++;
    else
      cur_dist--;

    if (cur_dist > (full_dist / 2))
      after_half = 1;

    if (cur->l == prev) {
      prev = cur;
      cur = cur->r;
    } else {
      prev = cur;
      cur = cur->l;
    }

    if (cur == start) break;
  }
}

__attribute__((unused))
static
void
print_with_distance(void)
{
  pipe_t *cur = start,
         *prev = start->l;
  while (1) {
    printf("%d ", cur->distance);
    if (cur->l == prev) {
      prev = cur;
      cur = cur->r;
    } else {
      prev = cur;
      cur = cur->l;
    }

    if (cur == start) break;
  }

  putchar('\n');
}

static
int
get_max(void)
{
  pipe_t *cur = start,
         *prev = start->l;
  int max = cur->distance;
  while (1) {
    max = cur->distance > max ? cur->distance : max;
    if (cur->l == prev) {
      prev = cur;
      cur = cur->r;
    } else {
      prev = cur;
      cur = cur->l;
    }

    if (cur == start) break;
  }

  return max;
}

static
struct tg_ring*
create_tg_ring(void)
{
  int npoints = 2 + get_full_distance(), i = 0;
  struct tg_point *points = malloc(sizeof(struct tg_point) * (npoints));
  /* idk if i can free those */

  pipe_t *cur = start,
         *prev = start->l;

  while (1) {
    points[i++] = (struct tg_point){ cur->x, cur->y };

    if (cur->l == prev) {
      prev = cur;
      cur = cur->r;
    } else {
      prev = cur;
      cur = cur->l;
    }

    if (cur == start) break;
  }

  points[i] = (struct tg_point){ cur->x, cur->y };

  return tg_ring_new(points, npoints);
}

static
void
gp_write_poly(void)
{
  FILE *fp = fopen("poly.dat", "w");
  pipe_t *cur = start,
         *prev = start->l;
  if (fp == NULL) abort();

  while (1) {
    if (cur->l == prev) {
      prev = cur;
      cur = cur->r;
    } else {
      prev = cur;
      cur = cur->l;
    }

    fprintf(fp, "%d %d\n", cur->x, cur->y);

    if (cur == start) break;
  }

  fclose(fp);
}

static
void
gp_write_points(void)
{
  FILE *fp = fopen("gnd.dat", "w");
  int i = 0, n = 0;
  struct tg_ring *p = create_tg_ring();

  if (fp == NULL) abort();

  for (; i < map_sz; ++i) {
    if (map[i].is_loop == 0) {
      if (tg_geom_intersects_xy((struct tg_geom*)p, map[i].x, map[i].y)) {
        n++;
        fprintf(fp, "%d %d\n", map[i].x, map[i].y);
      }
    }
  }

  printf("p2: %d\n", n);
  fclose(fp);
}

static
void
exec_gnuplot(void)
{
  if (fork() == 0)
    execlp("gnuplot", "gnuplot", "-p", "plot.gp", NULL);
  else
    wait(NULL);
}

static
void
write_gnuplot_data(void)
{
  gp_write_poly();
  gp_write_points();
  exec_gnuplot();
}

int
main(void)
{
  FILE *in = fopen("in", "r");
  int c, i = 0;
  if (!in) abort();

  map = malloc(sizeof(pipe_t) * map_sz);
  while ((c = fgetc(in)) != EOF) {
    if (c != '\n') {
      map[i].x = i % MAP_W;
      map[i].y = i / MAP_W;
      map[i].is_loop = 0;
      map[i++].d = c;
    }
  }
  fclose(in);

  parsemap();
  set_distance();
  /*print_with_distance();*/
  printf("p1: %d\n", get_max());
  write_gnuplot_data();

  free(map);
}
