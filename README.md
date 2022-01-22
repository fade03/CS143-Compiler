# Intro

There are two versions of assignments for the CS143-Compiler course, This repo is my Java version solution.

Course resources:

- This course is available in [Bilibili](https://www.bilibili.com/video/BV17K4y147Bz?p=41&spm_id_from=pageDriver).

- You can download the student-dist in [edx.org](https://link.zhihu.com/?target=https%3A//courses.edx.org/asset-v1%3AStanfordOnline%2BSOE.YCSCS1%2B1T2020%2Btype%40asset%2Bblock%40student-dist.tar.gz).

# PA
## PA2J
This assignment is to write a lexical analyser for COOL, using jlex(Java).

By the way, the jlex framework is a bit outdated, you can install jflex to replace it:
```
brew install jfelx
apt-get install jfelx
```

Generate lexer:
```
> jflex --jlex cool.lex
> make lexer
> make dotest
```

To test if the lexer works, you can run `diff.sh` which compares the output of our own lexer and the standard lexer(/bin/lexer) with all cool file in `/examples` as input:
```
> ./diff.sh
```

