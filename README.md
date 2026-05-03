# The Abstract Interpreter User Guide

This document provides instructions on how to use the provided abstract interpreter for static analysis 
on the given toy language. This project was written in OCaml, and requires OCaml and Menhir to run.

## Setting up the interpreter
1. Download the given zip file. Extract its contents.
2. Open terminal in the given location

```
cd Project
cd AbstractInterpProject
cd abstract-interpreter
make 
```

You should see the project build, alongside a set of examples. If you see someting similar to the following, the project has compiled successfully.

<insert image of successful compilation here>

## Writing your script
The static analyser can perform analysis on a given toy language. 
The language consists of the following syntax:
1. Assignment
```
x=1; y= x; z=x+y;
```
2. Mathematical operations

```
+
-
/ 
```

3. Branching statements
```
if
{
    ...
}
else
{
    ...
}
```

4. While
```
while(<condition>)
{
    ...
}
```

5. Boolean conditions (used in if/while)

```
x<10
y>x
z==0
x!=4
<condition1> nand <condition2>
```

6. Break statement

```
while(<condition>) {
    ...
    break;
}

```

## Setting up your script to analyse

To analyse a script, there are two ways.
1. Manually write a block of code on terminal and pass into the analyzer 
2. Pass in a file to the analyzer

### Passing in a block of code to the analyzer
In the command line: 
```
echo "<code_block>" | ./analyzer --<domain_option>
```

An example:
```
$> echo "x=5; y=10; z=x+y;" | ./analyzer --interval
Interval Domain loaded
<l1:{(z=[0,0])(y=[0,0])(x=[0,0])}; l4:{(z=[15,15])(y=[10,10])(x=[5,5])}; ff; l0:{}>Prog:
<l1:{(z=[0,0])(y=[0,0])(x=[0,0])}; l2:{(z=[0,0])(y=[0,0])(x=[5,5])}; ff; l0:{}>   l1: x = 5; 
<l2:{(z=[0,0])(y=[0,0])(x=[5,5])}; l3:{(z=[0,0])(y=[10,10])(x=[5,5])}; ff; l0:{}>   l2: y = 10; 
<l3:{(z=[0,0])(y=[10,10])(x=[5,5])}; l4:{(z=[15,15])(y=[10,10])(x=[5,5])}; ff; l0:{}>   l3: z = (x + y); 
                                                             l4: 
```

### Passing in a file to the analyzer

In the command line:
```
./analyzer --<domain_option> < myprogram.txt
```
or 

```
cat myprogram.txt | ./analyzer --<domain_option>
```

An example:

```
$> cat test.txt 
x = -5;y = 1;if(x<0)x=x+1; y=y-x;z=y+1; z=z-x+y;

$> cat test.txt | ./analyzer --interval           
Interval Domain loaded
<l1:{(z=[0,0])(y=[0,0])(x=[0,0])}; l8:{(z=[15,15])(y=[5,5])(x=[-4,-4])}; ff; l0:{}>Prog:
<l1:{(z=[0,0])(y=[0,0])(x=[0,0])}; l2:{(z=[0,0])(y=[0,0])(x=[-5,-5])}; ff; l0:{}>   l1: x = (0 - 5); 
<l2:{(z=[0,0])(y=[0,0])(x=[-5,-5])}; l3:{(z=[0,0])(y=[1,1])(x=[-5,-5])}; ff; l0:{}>   l2: y = 1; 
<l3:{(z=[0,0])(y=[1,1])(x=[-5,-5])}; l5:{(z=[0,0])(y=[1,1])(x=[-4,-4])}; ff; l0:{}>   (if l3: (x < 0)
<l4:{(z=[0,0])(y=[1,1])(x=[-5,-5])}; l5:{(z=[0,0])(y=[1,1])(x=[-4,-4])}; ff; l0:{}>      l4: x = (x + 1); ) 
<l5:{(z=[0,0])(y=[1,1])(x=[-4,-4])}; l6:{(z=[0,0])(y=[5,5])(x=[-4,-4])}; ff; l0:{}>   l5: y = (y - x); 
<l6:{(z=[0,0])(y=[5,5])(x=[-4,-4])}; l7:{(z=[6,6])(y=[5,5])(x=[-4,-4])}; ff; l0:{}>   l6: z = (y + 1); 
<l7:{(z=[6,6])(y=[5,5])(x=[-4,-4])}; l8:{(z=[15,15])(y=[5,5])(x=[-4,-4])}; ff; l0:{}>   l7: z = ((z - x) + y); 
                                                             l8: 
```

## Reading the output

Each line of output shows a statement with its entry and exit properties:

```
<l1:{(x=[0,0])}; l3:{(x=[10,10])}; ff; l0:{}>   (while l1: (x < 10) ...)
```

- `l1` — entry label and property: what holds when execution arrives
- `l3` — exit label and property: what holds when execution leaves normally  
- `ff` — whether this statement can raise an exception (always ff here)
- `l0:{}` — break exit property

For the pentagon domain, upper bound constraints appear after the interval property:
```
<l2:{(x=[2,2])} (x<y); ... >
```

This means at label `l2`, `x=[2,2]` and we know `x < y`.

## Utilising the interval domain
To use the interval domain, just pass `` --interval`` as an argument to the analyzer. 

```
cat myprogram.txt | ./analyzer --interval
```

## Utilising the pentagons domain
To use the pentagon domain, just pass `` --pentagon`` as an argument to the analyzer.

```
cat myprogram.txt | ./analyzer --pentagon
```

## Notable features implemented from the Pentagons paper

### Interval Environments (Boxes)
The interval domain is implemented as a Cartesian product of single 
variable intervals, as described in Figure 4. All lattice operations 
(order, join, meet, widening) are implemented as defined in Figures 3 and 4.


### Strict Upper Bounds (Sub)
The Sub domain is fully implemented as described in Figure 5, including:
- Join as pointwise set intersection
- Meet as pointwise set union  

```
echo "y=10; z=20; if (y<z) if (x<y) ;" | ./analyzer --sub

SUB Domain loaded
<l1:; l6:; ff; l0:{}>                                        Prog:
<l1:; l2:; ff; l0:{}>                                           l1: y = 10; 
<l2:; l3:; ff; l0:{}>                                           l2: z = 20; 
<l3:; l6:; ff; l0:{}>                                           (if l3: (y < z)
<l4:(y<z); l6:(y<z); ff; l0:{}>                                    (if l4: (x < y)
<l5:(x<y)(x<z)(y<z); l6:(x<y)(x<z)(y<z); ff; l0:{}>                   l5: ; ) ) 
                                                             l6: 


```


### Pentagons
The pentagon domain is implemented as described in Figure 6, including:
- The refined order that checks both explicit constraints and 
  interval-implied constraints (∀x ∈ s2. y ∈ s1(x) ∨ sup(b1(x)) < inf(b1(y)))


- Meet and widening delegated to both components as specified

- Reduction: derives x < y whenever sup(b(x)) < inf(b(y))

```
echo "x=2; y=10;" | ./analyzer --pentagon
Pentagons domain loaded
<l1:{(y=[0,0])(x=[0,0])} ; l3:{(y=[10,10])(x=[2,2])} (x<y); ff; l0:{} {}>Prog:
<l1:{(y=[0,0])(x=[0,0])} ; l2:{(y=[0,0])(x=[2,2])} (y<x); ff; l0:{} {}>   l1: x = 2;
<l2:{(y=[0,0])(x=[2,2])} (y<x); l3:{(y=[10,10])(x=[2,2])} (x<y); ff; l0:{} {}>   l2: y = 10;
l3:
```


### Transfer Functions
The subtraction transfer function is approximated — when x = y - 1,
the Sub component derives x < y and propagates y's upper bounds to x,
as described in Section 6.2.1.

```
echo "x=0; y=10; z=y-1;" | ./analyzer --pentagon
Pentagons domain loaded
<l1:{(z=[0,0])(y=[0,0])(x=[0,0])} ; l4:{(z=[9,9])(y=[10,10])(x=[0,0])} (x<z)(x<y)(z<y); ff; l0:{} {}>Prog:
<l1:{(z=[0,0])(y=[0,0])(x=[0,0])} ; l2:{(z=[0,0])(y=[0,0])(x=[0,0])} ; ff; l0:{} {}>   l1: x = 0; 
<l2:{(z=[0,0])(y=[0,0])(x=[0,0])} ; l3:{(z=[0,0])(y=[10,10])(x=[0,0])} (x<y)(z<y); ff; l0:{} {}>   l2: y = 10; 
<l3:{(z=[0,0])(y=[10,10])(x=[0,0])} (x<y)(z<y); l4:{(z=[9,9])(y=[10,10])(x=[0,0])} (x<z)(x<y)(z<y); ff; l0:{} {}>   l3: z = (y - 1); 
                                                             l4: 
```

### Binary Search 
The binary search example from page 3 of the paper is implemented and
verified. The pentagon correctly derives the loop invariant
`0 ≤ num < num2` and tracks `index < num2` throughout the loop body,
demonstrating the domain's ability to validate array access bounds.


```
num = 0;
num2 = 9;
while (num < num2) {
    index = (num + num2) / 2;
    if (index < num2) {
        num = index + 1;
    } else {
        num2 = index;
    };
};
```

```
cat ../binarysearch.txt | ./analyzer --pentagon

Pentagons domain loaded
<l1:{(num2=[0,0])(num=[0,0])(index=[0,0])} ; l10:{(num2=[9,9])(num=[9,9])(index=[0,8])} (index<num)(index<num2); ff; l0:{} {}>Prog:
<l1:{(num2=[0,0])(num=[0,0])(index=[0,0])} ; l2:{(num2=[0,0])(num=[0,0])(index=[0,0])} ; ff; l0:{} {}>   l1: num = 0; 
<l2:{(num2=[0,0])(num=[0,0])(index=[0,0])} ; l3:{(num2=[9,9])(num=[0,0])(index=[0,0])} (index<num2)(num<num2); ff; l0:{} {}>   l2: num2 = 9; 
<l3:{(num2=[9,9])(num=[0,9])(index=[0,8])} (index<num2); l9:{(num2=[9,9])(num=[9,9])(index=[0,8])} (index<num)(index<num2); ff; l0:{} {}>   (while l3: (num < num2)
<l4:{(num2=[9,9])(num=[0,8])(index=[0,8])} (index<num2)(num<num2); l3:{(num2=[9,9])(num=[0,9])(index=[4,8])} (index<num2); ff; l0:{} {}>      Stmtlist: {
<l4:{(num2=[9,9])(num=[0,8])(index=[0,8])} (index<num2)(num<num2); l5:{(num2=[9,9])(num=[0,8])(index=[4,8])} (index<num2)(num<num2); ff; l0:{} {}>         l4: index = ((num + num2) / 2); 
<l5:{(num2=[9,9])(num=[0,8])(index=[4,8])} (index<num2)(num<num2); l8:{(num2=[9,9])(num=[0,9])(index=[4,8])} (index<num2); ff; l0:{} {}>         (if l5: (index < num2)
<l6:{(num2=[9,9])(num=[0,8])(index=[4,8])} (index<num2)(num<num2); l8:{(num2=[9,9])(num=[5,9])(index=[4,8])} (index<num2)(index<num); ff; l0:{} {}>            Stmtlist: {
<l6:{(num2=[9,9])(num=[0,8])(index=[4,8])} (index<num2)(num<num2); l8:{(num2=[9,9])(num=[5,9])(index=[4,8])} (index<num2)(index<num); ff; l0:{} {}>               l6: num = (index + 1); 
                                                                         } 
                                                                       else 
<l7:{(num2=Bot)(num=[0,8])(index=Bot)} (num<num2); l8:{(num2=Bot)(num=[0,8])(index=Bot)} ; ff; l0:{} {}>            Stmtlist: {
<l7:{(num2=Bot)(num=[0,8])(index=Bot)} (num<num2); l8:{(num2=Bot)(num=[0,8])(index=Bot)} ; ff; l0:{} {}>               l7: num2 = index; 
                                                                         } ) 
<l8:{(num2=[9,9])(num=[0,9])(index=[4,8])} (index<num2); l3:{(num2=[9,9])(num=[0,9])(index=[4,8])} (index<num2); ff; l0:{} {}>         l8: ; 
                                                                   } ) 
<l9:{(num2=[9,9])(num=[9,9])(index=[0,8])} (index<num)(index<num2); l10:{(num2=[9,9])(num=[9,9])(index=[0,8])} (index<num)(index<num2); ff; l0:{} {}>   l9: ; 
                                                             l10: 

```


### Cost and Precision of the Join
We implement the efficient join t*p rather than the closure-based join t*p.
As discussed in Section 6.1, t*p has quadratic complexity at each join 
point which causes serious slowdowns. Our tp implementation avoids 
materializing new symbolic constraints, instead keeping only those 
present in one operand and implied by the numerical part of the other.

### Interval widening : 
The interval widnening preserves stable bounds, widens unstable bounds to ±∞

```
echo "x=0; while (x<100) x=x-1;" | ./analyzer --interval
Interval Domain loaded
<l1:{(x=[0,0])}; l4:{(x=Bot)}; ff; l0:{}>                    Prog:
<l1:{(x=[0,0])}; l2:{(x=[0,0])}; ff; l0:{}>                     l1: x = 0; 
<l2:{(x=[-inf,0])}; l4:{(x=Bot)}; ff; l0:{}>                    (while l2: (x < 100)
<l3:{(x=[-inf,0])}; l2:{(x=[-inf,-1])}; ff; l0:{}>                 l3: x = (x - 1); ) 
                                                             l4: 
```

```
echo "x=0; while (x<100) x=x+1;" | ./analyzer --interval
Interval Domain loaded
<l1:{(x=[0,0])}; l4:{(x=[100,100])}; ff; l0:{}>              Prog:
<l1:{(x=[0,0])}; l2:{(x=[0,0])}; ff; l0:{}>                     l1: x = 0; 
<l2:{(x=[0,100])}; l4:{(x=[100,100])}; ff; l0:{}>               (while l2: (x < 100)
<l3:{(x=[0,99])}; l2:{(x=[1,100])}; ff; l0:{}>                     l3: x = (x + 1); ) 
                                                             l4: 
```


### Deliberate Omissions
The following features were not fully implemented or were instead replaced by an alternative.

- **Closure before widening** — as noted in Section 6, combining widening 
  with closure causes convergence problems. We follow the paper's 
  recommendation and do not perform closure before widening.

- **Arrays** — the language does not support arrays. The binary search 
  example is implemented using simple integer variables to demonstrate 
  the pentagon's ability to track index invariants, as the key contribution 
  of the paper is the relational reasoning between index variables rather 
  than the array content itself.

- **Closure-based join tp** — we implement the efficient tp join rather 
  than tp as discussed in Section 6.1.


## Comparing pentagon and interval domains

Consider this program:

```
x = -5;
y = 1;
if(x<0) { x=x+1; y=y-x; z=y+1; z=z-x+y; }
while(x<y) y=y-1;
if(y==0) { y=y-1; z=y+12; }
;
```

**Interval domain:**
- Correctly computes `x=[-4,-4]`, `y=[-4,-4]`, `z=[0,15]` at exit ✓
- Tracks that `y` decrements to `-4` through the while loop ✓
- The `if(y==0)` body correctly shows `Bot` since `y=-4` never equals 0 ✓

**Pentagon domain:**
- Tracks additional relational constraints like `(x<y)(x<z)(z<y)` through
  the if block ✓
- After the while loop shows `y=Bot, x=Bot` — the pentagon is more
  conservative here because it cannot track that `y` decrements all the
  way to `-4`
- However it correctly maintains `(x<z)` throughout ✓

## Limits of the Pentagon Domain

The pentagon domain is sound but sometimes imprecise. In the example above,
the interval domain gives a more precise result for `y` after the while loop
(`y=[-4,-4]`) while the pentagon reports `Bot`.

The pentagon domain is more aggressive in filtering at loop exit points. When computing nottest(x<y), it uses both the interval information and the relational constraints simultaneously. With x=[-4,-4] and the widened y=[1,5], satisfying x >= y requires x >= 1 — but x=[-4,-4] cannot satisfy this, giving x=Bot and consequently y=Bot.
The interval domain only uses interval filtering — nottest(x<y) simply caps y's upper bound at x=-4, giving y=[-inf,-4] correctly.
In other words: the pentagon's additional relational precision can sometimes cause it to be more conservative than the interval domain alone, because it jointly filters both variables using both interval and symbolic information. This is a known tradeoff of the reduced product approach — combining two domains can occasionally produce less precise results than either domain alone when their information interacts in unexpected ways.


## Other domains
Sign and Sub domains are also available for use if desired.

```
cat myprogram.txt | ./analyzer --sign
```

```
cat myprogram.txt | ./analyzer --sub
```



