---
date: 2021-08-28 21:39
description: How to do a hello world in assambler for M1 Mac 💻
tags: Article, Assembly
---


# Hello Sillicon

## How the computer works

In this is post I'll talk about how to compiler assambler code to create a ```Hello World``` in M1, 
this code is following the course of the [Programming with 64-Bit ARM Assembly Language](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language/dp/1484258800/ref=sr_1_1?crid=34ED002YD0Y9Z&dchild=1&keywords=programming+with+64-bit+arm+assembly+language&qid=1610126434) 

Below is the code that you can find the book 
<br/>
```
//
// Assembler program to print "Hello World!"
// to stdout.
//
// X0-X2 - parameters to linux function services
// X16 - linux function number
//
.global _start             // Provide program starting address to linker
.align 2

// Setup the parameters to print hello world
// and then call Linux to do it.

_start: mov X0, #1     // 1 = StdOut
        adr X1, helloworld // string to print
        mov X2, #13     // length of our string
        mov X16, #4     // MacOS write system call
        svc 0     // Call linux to output the string

// Setup the parameters to exit the program
// and then call Linux to do it.

        mov     X0, #0      // Use 0 return code
        mov     X16, #1     // Service command code 1 terminates this program
        svc     0           // Call MacOS to terminate the program

helloworld:      .ascii  "Hello Sillicon!\n"
```
<br/>
Also we need to create a make file in order to compile our code
<br/>
```
HelloWorld: HelloWorld.o
     ld -macosx_version_min 11.0.0 -o HelloWorld HelloWorld.o -lSystem -syslibroot
             `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

HelloWorld.o: HelloWorld.s
     as -o HelloWorld.o HelloWorld.s
```
<br/>
Also please take in note that we need to install Xcode 12 at least with the compiler tools. Once we did that just open the folder 
in the terminal and run the following code
<br/>
```
$ make -B
```
<br/>
the `-B` is just to force the compiler to recompile even if the code doesn't change, so you can skip it if you want.
Then, if you run the executable you have to see the following
<br/>
```
$ ./HelloWorld
Hello Sillicon!
$
```
<br/>
And that's it this is our first program in assambler with M1 chip! 🚀

