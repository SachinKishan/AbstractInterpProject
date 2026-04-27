# The Abstract Interpreter User Guide

This document provides instructions on how to use the provided abstract interpreter for static analysis 
on the given While language. This project was written in OCaml, and requires OCaml, Menhir to run.

## Setting up the interpreter
1. Download the given zip file. Extract its contents.
2. Open terminal in the given location

```
cd project
cd abstract-interp
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
* tbd
/ tbd
```

3.  

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

## Example scripts

Here are some examples highlighting the features of the interpreter, as well as the differences between the pentagon and interval domains.


## Other domains
Sign, Concrete and Sub domains are also available for use if desired.

```
cat myprogram.txt | ./analyzer --sign
```
```
cat myprogram.txt | ./analyzer --concrete
```
```
cat myprogram.txt | ./analyzer --sub
```



