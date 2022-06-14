#!/bin/bash
docker run --net host --rm -v ${PWD}:/tgn/node tagion/playnet ${@:1}