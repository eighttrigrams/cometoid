#!/bin/bash

mix deps.get
mkdir -p priv/static/assets
cp -r assets/node_modules/bootstrap-icons/font/fonts priv/static/assets
cp -r assets/node_modules/bootstrap-icons/font/bootstrap-icons.css priv/static/assets
npm i --prefix=./assets