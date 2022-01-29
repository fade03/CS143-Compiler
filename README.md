# Intro

There are two versions of assignments(Java or C++) for the CS143-Compiler course, this repo is my Java-version solution.

Platform: Ubuntu 18.04

Course resources:

- This course is available in [bilibili](https://www.bilibili.com/video/BV17K4y147Bz?p=41&spm_id_from=pageDriver).

- You can download the student-dist in [edx.org](https://courses.edx.org/asset-v1%3AStanfordOnline%2BSOE.YCSCS1%2B1T2020%2Btype%40asset%2Bblock%40student-dist.tar.gz).

Here are my notes: 
- [Lexical Analysis](https://www.wolai.com/6tSHdusbr1vidwU9EvbLh3)
- [Parsing](https://www.wolai.com/uDhUNDns7h4EHzwyd3jNiK)

# PA
## PA2J
This assignment is to write a lexical analyser for COOL, using jlex(Java).

By the way, the jlex framework is a bit outdated, you can install jflex to replace it:
```
> brew install jfelx
> apt-get install jfelx
```

Generate lexer:
```
> jflex --jlex cool.lex
> make lexer
> make dotest
```

To test if the lexer generated works, you can run `diff.sh` which compares the output of our own lexer and the standard lexer(`./bin/lexer`) with all cool files in `./examples` as input:
```
> ./diff.sh
```

## PA3J
First of all, if you didn't use the virtual machine given by teacher, you should install the `CUP` in your own machine:
```
> apt-get install cup
```
Then modify the `PA3J/Makefile` and change the `CUP path` to your own path(if you don't know the path, you can run `which cup`):
```Makefile
## PA3J/Makefile

JAVAC := javac
# CUP := /usr/class/cs143/bin/java_cup
CUP := /usr/bin/cup
```
Generate Paser:
```
> make source
> make parser
> make dotest
```





