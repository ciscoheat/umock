#!/bin/bash
cd src

OUTPUT=${1:-../umock.zip}
rm -f $OUTPUT
zip -r $OUTPUT *

haxelib test $OUTPUT
