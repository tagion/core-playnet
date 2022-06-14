#!/bin/bash
docker run --net host --rm -v ${PWD}:/tgn/node -w /tgn/node/$1 tagion/playnet  ${@:2}