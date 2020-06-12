#!/bin/bash

pybabel extract -o ../../src/demo/locale/messages.pot ../../src/demo/
pybabel update -i ../../src/demo/locale/messages.pot -d ../../src/demo/locale/
pybabel compile -d ../../src/demo/locale/
