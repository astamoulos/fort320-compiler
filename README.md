# Compiler for language FORT320
To compile your FORT320 compiler, you can use the provided Makefile.
```bash
make
```
Once compiled successfully, you can run your compiler using the following command:
```bash
./a.out test
```
## Language Description
FORT320 is a high-level programming language similar to FORTRAN . It is defined as follows. FORT320 incorporates structured commands and supports record structures, similar to Pascal or C.

Unlike classic FORTRAN, FORT320 does not impose strict formatting rules on programs. Instead, whitespace plays a role in the program's structure, similar to modern programming languages.

Furthermore, FORT320 allows the definition of subprograms at a single external level, similar to FORTRAN. However, it utilizes a stack for subprogram calls, enabling recursion.
## Keywords
The following words are independent lexical tokens in FORT320:
```
FUNCTION SUBROUTINE END INTEGER REAL LOGICAL CHARACTER RECORD ENDREC
DATA CONTINUE GOTO CALL READ WRITE IF THEN ELSE ENDIF DO ENDDO STOP
RETURN
```