#!/bin/bash

coffee -c -b server.coffee
coffee -c -b app/*.coffee
coffee -c -b app/models/*.coffee
coffee -c -b app/utils/*.coffee
coffee -c -b config/*.coffee
coffee -o scripts/js -c scripts/*.coffee
stylus -c styles/*.styl -o styles/css/
