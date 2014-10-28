#!/bin/bash

echo "\x1B[32mCompilando CoffeeScript servidor..."
coffee -c -b server.coffee
echo "\x1B[32mCompilando CoffeeScript app/..."
coffee -c -b app/*.coffee
echo "\x1B[32mCompilando CoffeeScript app/models..."
coffee -c -b app/models/*.coffee
echo "\x1B[32mCompilando CoffeeScript app/utils..."
coffee -c -b app/utils/*.coffee
echo "\x1B[32mCompilando CoffeeScript config..."
coffee -c -b config/*.coffee
echo "\x1B[32mCompilando CoffeeScript scripts/ -> scripts/js..."
coffee -o scripts/js -c scripts/*.coffee
echo "\x1B[31mCompilando Stylus"
stylus -c styles/*.styl -o styles/css/

echo "\x1B[22mTerminado"
