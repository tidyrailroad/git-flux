#!/bin/sh

apk update &&
    apk upgrade &&
    apk add git &&
    apk add util-linux &&
    apk add vim &&
    true