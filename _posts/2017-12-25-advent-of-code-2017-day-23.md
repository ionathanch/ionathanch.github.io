---
layout: post
title: "Advent of Code 2017, Day 23"
tags:
  - Advent of Code 2017
  - Haskell
  - C
categories:
  - Advent of Code
---

As with Day 18, today’s problem involved running a custom assembly program. However, as stated in part b, the program run with `a = 1` is much too inefficient to run directly. Whereas with 18 you could simulate a machine in whichever language you choose and finish running the program in a reasonable amount of time, this problem requires deciphering what the program actually does, then optimizing it. We begin with the input (whose real values I won’t bother with hiding):

<!--more-->

```asm
set b 81
set c b
jnz a 2
jnz 1 5
mul b 100
sub b -100000
set c b
sub c -17000
set f 1
set d 2
set e 2
set g d
mul g e
sub g b
jnz g 2
set f 0
sub e -1
set g e
sub g b
jnz g -8
sub d -1
set g d
sub g b
jnz g -13
jnz f 2
sub h -1
set g b
sub g c
jnz g 2
jnz 1 3
sub b -17
jnz 1 -23
```

We can first divide up the program into chunks where the loops are located by identifying negative jumps. The first negative jump is the innermost loop:

```asm
set g d
mul g e
sub g b
jnz g 2
set f 0
sub e -1
set g e
sub g b
jnz g -8
```

Then the next one is the middle loop:

```asm
set e 2
<inner loop>
sub d -1
set g d
sub g b
jnz g -13
```

And at last the outer loop:

```asm
set f 1
set d 2
<middle loop>
jnz f 2
sub h -1
set g b
sub g c
jnz g 2
jnz 1 3
sub b -17
jnz 1 -23
```

This leaves the beginning of the program:

```asm
set b 81         int b = 81;
set c b          int c = b;
jnz a 2          // a == 1 so this step always executes
jnz 1 5          // skipped by previous step
mul b 100        b *= 100;
sub b -100000    b += 100000;
set c b          c = b;
sub c -17000     c += 17000;
<outer loop>
```

In short,

```asm
int b = 108100;
int c = 125100;
<outer loop>
```

Next, translating the inner loop:

```asm
set g t      g = d;
mul g e      g *= e;
sub g b      g -= b;
jnz g 2      if (g == 0) {
set f 0          f = 0;
             }
sub e -1     e += 1;
set g e      g = e;
sub g b      g -= b;
jnz g -13    if (g == 0) {
                 // go back to beginning of loop
             }
```

Register g appears to be used as the working register rather than a data-holding register. The last four lines will become a familiar pattern. It is equivalent to

```c
if (e++ != b) {
    // loop
}
```

which is clearly the classic for-loop. Combined with the first four lines checking if `d * e == b`, we have the final for-loop:

```c
for (int e = 2; e < b; e++) {
    if (d * e == b) {
        f = 0;
    }
}
```

The first line of the middle loop sets the initial value of `e` to 2; the last four lines follow the aforementioned pattern of breaking when `d == b`. Thus:

```c
for (int d = 2; d < b; d++) {
    for (int e = 2; e < b; e++) {
        if (d * e == b) {
            f = 0;
        }
    }
}
```

The first two lines set `f` to 1 (by now we know `f` only takes on values 0 or 1 so it can be a `bool`) and initialize `d` to 2. Translating the last eight lines,

```c
jnz f 2      if (!f) {
sub h -1         h += 1;
             }
set g b      g = b;
sub g c      g -= c;
jnz g 2      if (g == 0) {
jnz 1 3          break;
             }
sub b -17    b += 17;
jnz 1 -23    // loop
```

This outer loop is also a for loop, only checks for `b == c` and increments b by 17 each time. Note however that the incrementation is done *after* checking the condition! This is equivalent to having `b <= c` in the for loop in place of `b < c`.

Putting it all together now:

```c
int a = 1;
int h = 0;
int c = 125100;
for (int b = 108100; b <= c; b += 17) {
    bool f = true;
    for (int d = 2; d < b; d++) {
        for (int e = 2; e < b; e++) {
            if (d * e == b) {
                f = false;
            }
        }
    }
    if (!f) {
        h++;
    }
}
return h;
```

This program checks if, for every number `b` in `[108100, 108117..125100]`, there exists some factors `d` and `e`, i.e. checks if `b` is prime, and counts the number of non-prime numbers. This check can be simplified by checking if for all `d` in `[2..sqrt b]` we have `b % d == 0`. Also optimizing for space with judicious data type choices, we have the final program:

```c
unsigned short h = 0;
for (long b = 108100; b < 125100; b += 17) {
    bool f = true;
    for (unsigned short d = 2; f && d * d <= b; d++) {
        if (b % d == 0) {
            f = false;
        }
    }
    h += !f;
}
return h;
```

Alternatively, any prime-checking algorithm for checking the primality of `b` will do.

The equivalent in Haskell can be written concisely as a fold:

```haskell
foldr 
    (\b h -> h + 
        (fromEnum . or . map (\d -> b `mod` d == 0) $ 
        [2..(floor . sqrt . fromIntegral) b]
    )) 
    0 [108100, 108117..125100]
``
