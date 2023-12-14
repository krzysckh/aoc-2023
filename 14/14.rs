use std::fs;
use std::fmt;
use std::collections::HashMap;
use std::ops::{Deref, DerefMut};

// this is my first time writing rust.
// and for my sanitys sake, i hope it's the last.

#[derive(Debug, Copy, Clone)]
enum Rock {
  Moveable,
  Static,
  None
}

struct RockMap(Vec<Vec<Rock>>);

impl Deref for RockMap {
  type Target = Vec<Vec<Rock>>;

  fn deref(&self) -> &Self::Target {
    &self.0
  }
}

impl DerefMut for RockMap {
  fn deref_mut(&mut self) -> &mut Self::Target {
    &mut self.0
  }
}

impl fmt::Display for RockMap {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    for line in self.iter() {
      for c in line {
        write!(f, "{}", match c {
          Rock::Moveable => 'O',
          Rock::Static => '#',
          Rock::None => '.',
        })?;
      }
      writeln!(f)?;
    }
    Ok(())
  }
}

#[allow(dead_code)]
fn print_map(map: &RockMap) {
  for line in map.iter() {
    for c in line {
      print!("{}", match c {
        Rock::Moveable  => 'O',
        Rock::Static  => '#',
        Rock::None  => '.',
      });
    }
    println!("");
  }
}

fn calc_weight(map: &RockMap) -> usize {
  let mut sum = 0;
  let mut n = map.len();

  for line in map.iter() {
    let n_rocks = line.iter().filter(|e| {
      matches!(e, Rock::Moveable)
    }).collect::<Vec<_>>().len();

    sum += n_rocks * n;
    n -= 1;
  }

  sum
}

fn rotate(map: &RockMap) -> RockMap {
  let mut ret: Vec<Vec<Rock>> = Vec::new();
  let w = map.len();
  let h = map[0].len();
  assert!(w == h);

  for _ in 0..w {
    ret.push(Vec::new());
  }

  for y in 0..h {
    for x in 0..w {
      ret[y].push(map[h-x-1][y]);
    }
  }

  RockMap(ret)
}

fn p1(mapp: &Vec<Vec<Rock>>) -> usize {
  let mut map = mapp.clone();
  for y in 0..map.len() {
    for x in 0..map[0].len() {
      match map[y][x] {
        Rock::Moveable => {
          if y > 0 {
            let mut dy = 0;
            loop {
              if 0 > y as i32 - dy as i32 - 1 {
                break;
              }
              if matches!(map[y-dy-1][x], Rock::None) {
                dy += 1;
              } else {
                break;
              }
            }
            map[y][x] = Rock::None;
            map[y-dy][x] = Rock::Moveable;
          }
        }
        _ => ()
      }
    }
  }

  calc_weight(&RockMap(map))
}

fn do_the_thing(mut map: RockMap) -> RockMap {
  for _ in 0..4 {
    for y in 0..map.len() {
      for x in 0..map[0].len() {
        match map[y][x] {
          Rock::Moveable => {
            if y > 0 {
              let mut dy = 0;
              loop {
                if 0 > y as i32 - dy as i32 - 1 {
                  break;
                }
                if matches!(map[y-dy-1][x], Rock::None) {
                  dy += 1;
                } else {
                  break;
                }
              }
              map[y][x] = Rock::None;
              map[y-dy][x] = Rock::Moveable;
            }
          }
          _ => ()
        }
      }
    }
    map = rotate(&map);
  }

  map
}

fn main() -> Result<(), ()> {
  let file = fs::read_to_string("./in").unwrap();
  let lines: Vec<_> = file.split("\n").collect();

  let mut map_pre: Vec<Vec<Rock>> = Vec::new();

  for line in lines {
    let mut lv: Vec<Rock> = Vec::new();
    for c in line.chars() {
      lv.push(match c {
        'O' => Rock::Moveable,
        '#' => Rock::Static,
        '.' => Rock::None,
        _   => panic!("invalid char in input")
      });
    }

    if lv.len() > 0 {
      map_pre.push(lv);
    }
  }

  println!("p1: {}", p1(&map_pre));

  let mut map = RockMap(map_pre);
  let target = 1000000000;
  let mut cache: HashMap<String, usize> = HashMap::new();
  let mut left = 0;

  for cur in 0..target {
    cache.insert(map.to_string(), cur);
    map = do_the_thing(map);

    if cache.contains_key(&map.to_string()) {
      let n = match cache.get(&map.to_string()) {
        Some(v) => v,
        None => unreachable!()
      };
      left = (target - cur - 1) % (cur + 1 - n);
      break;
    }
  }

  for _ in 0..left {
    map = do_the_thing(map);
  }

  println!("p2: {}", calc_weight(&map));
  Ok(())
}
