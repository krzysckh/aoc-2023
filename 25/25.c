#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#ifdef __linux__
#include <bsd/err.h>
#elifdef _WIN32
void
errx(int n, char* s, ...)
{
  exit(n);
}

char
*strsep(char **stringp, const char *delim) {
  char *rv = *stringp;
  if (rv) {
    *stringp += strcspn(*stringp, delim);
    if (**stringp)
      *(*stringp)++ = '\0';
    else
      *stringp = 0; }
  return rv;
}
#else
#include <err.h>
#endif /* __linux__ */

#include <raylib.h>
#include <raymath.h>

/* holy hell i need to stop realloc-bumping by one and start using probably nob.h lol lmao */
/* yes i do know about the concept of a hash map */

struct Id
{
  int id;
  char* name;
};

struct Ids
{
  struct Id *id;
  int n;
};

typedef struct
{
  char *nam;
  int *conns;
  int n_conns;

  Vector2 p;
  Vector2 v;
  bool canmove;
} Component;

Component *components = NULL;
struct Ids* ids;

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

#define SCREEN_WIDTH 800
#define SCREEN_HEIGHT 600
#define COMP_RADIUS 8
#define COMP_COLOR ((Color){0xa7, 0xc0, 0x80, 0xff})
#define LIGHT_TEXT_COLOR ((Color){0xd3, 0xc6, 0xaa, 0xff})
#define FONT_SIZE 16
#define BACKGROUND_COLOR ((Color){0x2b, 0x33, 0x39, 0xff})
#define DARK_TEXT_COLOR BACKGROUND_COLOR

#define START_MAX_LINE_LEN 150.f
float max_line_len = START_MAX_LINE_LEN;

int vrand(int from, int to)
{
  return rand() % (abs(from) + abs(to)) - from;
}

void
randomize_component_positions(void)
{
  int i;
  for (i = 0; i < ids->n; ++i) {
    components[i].canmove = true;
    components[i].p = (Vector2) {
      .x = vrand(0, SCREEN_WIDTH),
      .y = vrand(0, SCREEN_HEIGHT),
    };
  }
}

void
draw_connections(Component *c)
{
  int i;
  Component *n;
  for (i = 0; i < c->n_conns; ++i) {
    n = &components[c->conns[i]];
    float dist = Vector2Distance(c->p, n->p);
    /* printf("dist = %f\n", dist); */
    if (dist > max_line_len) {
      if (n->canmove)
        n->p = Vector2MoveTowards(n->p, c->p, dist/10);
    }

    DrawLineV(c->p, n->p, LIGHT_TEXT_COLOR);
  }
}

void
draw_n_comps_in_rect(Rectangle *r)
{
  int i, n = 0;
  char buf[512] = {0};

  for (i = 0; i < ids->n; ++i)
    if (CheckCollisionCircleRec(components[i].p, COMP_RADIUS, *r))
      n++;

  snprintf(buf, 512, "%d", n);
  DrawText(buf, 0, 0, 32, LIGHT_TEXT_COLOR);
}

void
render(void)
{
  int i;
  float dt, V;
  Vector2 text_pt, text_sz, delta_mouse, mp;
  Component *currently_pressed = NULL;
  char buf[512];

  Rectangle box;
  bool box_drawing = false;

  randomize_component_positions();
  SetConfigFlags(FLAG_WINDOW_RESIZABLE);
  InitWindow(800, 600, "aoc day 25");

  while(!WindowShouldClose()) {
    BeginDrawing();
    {
      ClearBackground(BACKGROUND_COLOR);
      mp = GetMousePosition();
      dt = GetFrameTime();

      if (IsMouseButtonDown(MOUSE_BUTTON_RIGHT)) {
        if (box_drawing) {
          box.width  = mp.x - box.x;
          box.height = mp.y - box.y;

          DrawRectangleLinesEx(box, 2, RED);

          draw_n_comps_in_rect(&box);
        } else {
          box_drawing = 1;
          box.x = mp.x;
          box.y = mp.y;
        }
      } else {
        box_drawing = false;
      }

      if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
        if (currently_pressed == NULL) {
          for (i = 0; i < ids->n; ++i)
            if (CheckCollisionPointCircle(mp, components[i].p, COMP_RADIUS)) {
              currently_pressed = &components[i];
              delta_mouse.x = components[i].p.x - mp.x;
              delta_mouse.y = components[i].p.y - mp.y;
              break;
            }
        } else {
          currently_pressed->p.x = GetMouseX() - delta_mouse.x;
          currently_pressed->p.y = GetMouseY() - delta_mouse.y;
          currently_pressed->canmove = false;
        }
      } else {
        currently_pressed = NULL;
      }

      if (IsKeyDown(KEY_A)) max_line_len++;
      if (IsKeyDown(KEY_S)) max_line_len--;

      for (i = 0; i < ids->n; ++i)
        draw_connections(&components[i]);

      for (i = 0; i < ids->n; ++i) {
        components[i].p.x = components[i].p.x + components[i].v.x*dt;
        components[i].p.x = components[i].p.x + components[i].v.x*dt;

        DrawCircleV(components[i].p, COMP_RADIUS, COMP_COLOR);
        text_sz = MeasureTextEx(GetFontDefault(), components[i].nam, FONT_SIZE, 0);
        text_pt = (Vector2) {
          components[i].p.x - text_sz.x/2,
          components[i].p.y - text_sz.y/2
        };
        DrawText(components[i].nam, text_pt.x, text_pt.y, FONT_SIZE, DARK_TEXT_COLOR);

        components[i].v.x = MAX(0, components[i].v.x - 1.f*dt);
        components[i].v.y = MAX(0, components[i].v.y - 1.f*dt);
      }

      snprintf(buf, 512, "%f", max_line_len);
      DrawText(buf, 0, GetScreenHeight() - 20, 20, LIGHT_TEXT_COLOR);
    }
    EndDrawing();
  }
}

static bool
is_in_ids(char *s, struct Ids* ids)
{
  int i;
  for (i = 0; i < ids->n; ++i)
    if (strcmp(ids->id[i].name, s) == 0)
      return true;

  return false;
}

static struct Ids*
get_ids(char *f)
{
  struct Ids *ids = malloc(sizeof(struct Ids));
  char *tok, *dup = strdup(f), *tfree = dup;
  int i;

  *ids = (struct Ids) {
    .id = NULL,
    .n  = 0
  };

  for (i = 0; i < (int)strlen(dup); ++i)
    if (dup[i] == '\n' || dup[i] == ':')
      dup[i] = ' ';

  while ((tok = strsep(&dup, " "))) {
    if (strlen(tok) > 0) {
      if (!is_in_ids(tok, ids)) {
        ids->id = realloc(ids->id, sizeof(struct Id) * (ids->n + 1)); // slow
        ids->id[ids->n].id = ids->n;
        ids->id[ids->n].name = strdup(tok);
        ids->n++;
      }
    }
  }

  free(tfree);
  return ids;
}

char*
read_file(FILE *fp)
{
  char *buf = NULL;
  int read = 0;

  while (!feof(fp)) {
    buf = realloc(buf, read + 512);
    read += fread(buf + read, 1, 512, fp);
  }

  return buf;
}

int
nam2id(char *nam)
{
  int i;
  for (i = 0; i < ids->n; ++i)
    if (strcmp(nam, ids->id[i].name) == 0)
      return i;

  errx(1, "no such nam: %s", nam);
}

bool
has_conn(Component *a, int id)
{
  int i;

  for (i = 0; i < a->n_conns; ++i)
    if (a->conns[i] == id)
      return true;

  return false;
}

void
fix_conns(void)
{
  int i, j;
  Component *cur, *next;
  for (i = 0; i < ids->n; ++i) {
    cur = &components[i];

    for (j = 0; j < cur->n_conns; ++j) {
      next = &components[cur->conns[j]];
      if (!has_conn(next, i)) {
        next->conns = realloc(next->conns, sizeof(int) * (next->n_conns + 1));
        next->conns[next->n_conns] = i;
        next->n_conns++;
      }
    }
  }
}

void
get_components(char *f)
{
  char name[64] = {0}, line[128] = {0}, buf[16] = {0}, *lbuf, *tok, *lfree;
  Component *cur;

  while (sscanf(f, "%3s: %[a-zA-Z0-9 ]", name, line) == 2) {
    while (*++f && *f != '\n')
      ;

    cur = &components[nam2id(name)];

    lfree = lbuf = strdup(line);
    while ((tok = strsep(&lbuf, " "))) {
      cur->conns = realloc(cur->conns, sizeof(int) * (cur->n_conns + 1));
      cur->conns[cur->n_conns] = nam2id(tok);
      /* „Each connection between two components is represented only once” */
      cur->n_conns++;
    }

    free(lfree);
  }

  fix_conns();
}

int
main(void)
{
  int i;
  char *f = read_file(fopen("./in", "r"));
  ids = get_ids(f);

  components = malloc(sizeof(Component) * ids->n);
  memset(components, 0, sizeof(Component) * ids->n);

  for (i = 0; i < ids->n; ++i)
    components[i].nam = ids->id[i].name;

  get_components(f);

  printf("%d ids\n", ids->n);
  for (i = 0; i < ids->n; ++i)
    printf("%s: %d conns\n", ids->id[i].name, components[i].n_conns);

  render();

  free(components);
  return 0;
}
