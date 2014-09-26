MemAlloc
========

Memory allocator in x86 Assembly (class project, 2012).

*Note: Works on 64-bit Linux. Does not work on Mac OS X 10.10. Not sure about other environments.*

Usage
=====

Build the project with
```
make
```

If you're running a 32-bit operating system, you might need to remove some flags from the Makefile that were added for 64-bit compatibility.

Then, run the project with
```
./alocador
```

When running, the program allocates and deallocates areas of memory randomly. The map displayed in the output shows that: allocated areas are represented by ```*```, while dealocated (freed) areas are represented by ```-```.
