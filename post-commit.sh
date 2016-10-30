#!/bin/sh

while ! git push origin $(git rev-parse --abbrev-ref HEAD)
do
    sleep 10 &&
        true
done &&
    true