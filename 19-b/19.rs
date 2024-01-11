use std::fs;
use std::collections::HashMap;
use std::ops::Mul;
use std::cmp::{min,max};

// god i hate myseldf

// 𝑥∈[𝑓𝑟𝑜𝑚,𝑡𝑜]
// yes, i know about the builtin range
#[derive(Debug,Clone,Copy)]
struct Range {
  from: i32,
  to: i32
}

// this is so stupid
impl Mul for Range {
  type Output = u64;
  fn mul(self, rhs: Self) -> u64 {
    let v1 = 1 + self.to - self.from;
    let v2 = 1 + rhs.to - rhs.from;

    return v1 as u64 * v2 as u64
  }
}

#[derive(Debug)]
struct Rating {
  x: i32,
  m: i32,
  a: i32,
  s: i32,
}

#[derive(Debug,Clone,Copy)]
struct RatingRange {
  x: Range,
  m: Range,
  a: Range,
  s: Range
}

#[derive(Debug,PartialEq)]
enum Status {
  R,
  A
}

#[derive(Clone,Debug)]
struct Rule {
  ch: char,
  sign: char,
  val: i32,
  then: String
}

#[derive(Debug)]
struct RuleSet {
  rules: Vec<Rule>,
  finally: String,
}

type RuleSets<'a> = HashMap<&'a str, RuleSet>;
type Ratings = Vec<Rating>;

fn get_rule(s: String) -> Rule {
  match s.find(':') {
    Some(v) => {
      let cond = &s[0..v];

      Rule{
        ch: s.chars().nth(0).unwrap(),
        sign: s.chars().nth(1).unwrap(),
        val: cond[2..].to_string().parse::<i32>().unwrap(),
        then: String::from(&s[v+1..])
      }
    }
    None => Rule{ch: 0 as char, sign: 0 as char, val: 0, then: s}
  }
}

fn get_rulesets(lines: Vec<&str>) -> RuleSets {
  let mut ret = HashMap::new();

  for line in lines {
    let key = &line[0..line.find('{').unwrap()];
    let rules_str = &line[line.find('{').unwrap()+1..line.find('}').unwrap()];
    let rules: Vec<Rule> = rules_str
      .split(',')
      .map(|v| get_rule(v.to_string()))
      .collect();

    let rs = RuleSet{
      rules: rules[0..rules.len()-1].to_vec(),
      finally: rules[rules.len()-1].then.clone(),
    };

    ret.insert(key, rs);
  }

  ret
}

// not a lisp??
fn get_ratings(lines: Vec<&str>) -> Ratings {
  lines.iter().map(|s| {
    let vs: Vec<_> = s[1..s.len()-1]
      .split(',')
      .map(|e| e[2..]
           .parse::<i32>()
           .unwrap())
      .collect();

    Rating{x: vs[0], m: vs[1], a: vs[2], s: vs[3]}
  }).collect()
}

// for part 1
fn follow(rules: &HashMap<&str, RuleSet>, v: &Rating, cur: &str) -> Status {
  match cur.as_ref() {
    "R" => return Status::R,
    "A" => return Status::A,
    _ => 0
  };

  let rs = rules.get(cur).unwrap();

  for r in &rs.rules {
    let left_val = match r.ch {
      'x' => v.x,
      'm' => v.m,
      'a' => v.a,
      's' => v.s,
      _ => panic!()
    };

    let b = match r.sign {
      '<' => left_val < r.val,
      '>' => left_val > r.val,
      _ => panic!()
    };

    if b {
      return follow(rules, v, &r.then);
    }
  }

  follow(rules, v, &rs.finally)
}

fn p1(rulesets: &RuleSets, ratings: &Ratings) {
  let mut n = 0;

  for r in ratings {
    let res = follow(&rulesets, &r, "in");
    if res == Status::A {
      n += r.x + r.m + r.a + r.s;
    }
  }

  println!("p1: {n}");
}

fn is_range_possible(r: &Range) -> bool {
  r.from < r.to
}

fn is_rrange_possible(r: &RatingRange) -> bool{
  is_range_possible(&r.x)
    && is_range_possible(&r.m)
    && is_range_possible(&r.a)
    && is_range_possible(&r.s)
}

// rss = RuleSetS loll
fn p2(rss: &RuleSets, cur: &str, rr_real: &RatingRange) -> Vec<RatingRange> {
  let mut rr = rr_real.clone();
  if cur == "A" {
    return vec![rr.clone()];
  }
  if cur == "R" {
    return vec![]
  }
  let rs = rss.get(cur).unwrap();
  let mut ret: Vec<RatingRange> = vec![];

  // i don't remember writing half of that
  for rule in &rs.rules {
    let xs = if rule.ch == 'x' {
      if rule.sign == '<' {
        Range{from: rr.x.from, to: min(rule.val - 1, rr.x.to)}
      } else {
        Range{from: max(rule.val + 1, rr.x.from), to: rr.x.to}
      }
    } else { rr.x };

    let ms = if rule.ch == 'm' {
      if rule.sign == '<' {
        Range{from: rr.m.from, to: min(rule.val - 1, rr.m.to)}
      } else {
        Range{from: max(rule.val + 1, rr.m.from), to: rr.m.to}
      }
    } else { rr.m };

    let aas = if rule.ch == 'a' {
      if rule.sign == '<' {
        Range{from: rr.a.from, to: min(rule.val - 1, rr.a.to)}
      } else {
        Range{from: max(rule.val + 1, rr.a.from), to: rr.a.to}
      }
    } else { rr.a };

    let ss = if rule.ch == 's' {
      if rule.sign == '<' {
        Range{from: rr.s.from, to: min(rule.val - 1, rr.s.to)}
      } else {
        Range{from: max(rule.val + 1, rr.s.from), to: rr.s.to}
      }
    } else { rr.s };

    let tmp = rr.clone();
    rr = RatingRange{
      x: xs, m: ms, a: aas, s: ss
    };

    // not proud of that
    if is_rrange_possible(&rr) {
      ret.extend(p2(rss, rule.then.as_str(), &rr));
      let rx = tmp.x.from..tmp.x.to+1;
      let rm = tmp.m.from..tmp.m.to+1;
      let ra = tmp.a.from..tmp.a.to+1;
      let rs = tmp.s.from..tmp.s.to+1;

      let xs = if rule.ch == 'x' {
        let v: Vec<_> = rx.clone().filter(|v| !(rr.x.from..rr.x.to+1).contains(v)).collect();
        Range{from: v[0], to: *v.last().unwrap()}
      } else {
        tmp.x
      };

      let ms = if rule.ch == 'm' {
        let v: Vec<_> = rm.clone().filter(|v| !(rr.m.from..rr.m.to+1).contains(v)).collect();
        Range{from: v[0], to: *v.last().unwrap()}
      } else {
        tmp.m
      };

      let aas = if rule.ch == 'a' {
        let v: Vec<_> = ra.clone().filter(|v| !(rr.a.from..rr.a.to+1).contains(v)).collect();
        Range{from: v[0], to: *v.last().unwrap()}
      } else {
        tmp.a
      };

      let ss = if rule.ch == 's' {
        let v: Vec<_> = rs.clone().filter(|v| !(rr.s.from..rr.s.to+1).contains(v)).collect();
        Range{from: v[0], to: *v.last().unwrap()}
      } else {
        tmp.s
      };

      rr = RatingRange{x: xs, m: ms, a: aas, s: ss};
    } else {
      rr = tmp;
    }
  }

  ret.extend(p2(rss, &rs.finally, &rr));

  ret
}

fn sum_rr(r: &RatingRange) -> u64 {
  ((r.x * r.m) * (r.a * r.s)) as u64
}

fn sum_rrs(rrs: Vec<RatingRange>) -> u64 {
  rrs.iter().map(sum_rr).sum()
}

fn main() {
  let full_file = fs::read_to_string("./in").unwrap();
  let lines: Vec<&str> = full_file.split('\n').collect();

  let mut rule_lines: Vec<&str> = vec![];
  let mut rating_lines: Vec<&str> = vec![];

  let mut cur = &mut rule_lines;
  for line in lines {
    if line == "" {
      cur = &mut rating_lines;
      continue
    }

    cur.push(&line);
  }

  let rulesets = get_rulesets(rule_lines);
  let ratings  = get_ratings(rating_lines);

  p1(&rulesets, &ratings);
  let rrs = p2(&rulesets, "in", &RatingRange{
    x: Range{from: 1, to: 4000},
    m: Range{from: 1, to: 4000},
    a: Range{from: 1, to: 4000},
    s: Range{from: 1, to: 4000},
  });

  let p2_sum = sum_rrs(rrs);
  println!("p2: {p2_sum}");
}
