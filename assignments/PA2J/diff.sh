#!/bin/bash

for clfile in ../../examples/*.cl; do
    echo "######## Diff " $clfile "#########"
    ../../bin/.i686/lexer $clfile > examples
    ./lexer $clfile > mine
    if diff examples mine; then
        echo "passed"
    fi
done

rm -rf examples mine