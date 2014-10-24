#!/bin/bash

coffee -c -b app/*.coffee
coffee -c -b app/models/*.coffee
coffee -c -b app/utils/*.coffee
coffee -o scripts/js -c scripts/*.coffee
stylus -c styles/*.styl -o styles/css/
