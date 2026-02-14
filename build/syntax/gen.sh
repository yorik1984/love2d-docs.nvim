#!/bin/bash

# Set the current directory to the location of this script
pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" > /dev/null

# Quit on errors and unset vars
set -o errexit
set -o nounset

# Copy love-api to child directories
cp -rf love-api love-conf
cp -rf love-api lua

# Update after/syntax
rm -f ../../after/syntax/lua.vim
rm -f ../../after/queries/lua/highlights.scm
rm -f ../../test/example/api_full_list.lua
rm -f ../../test/example/conf.lua

# Create syntax files
$lua lua/main.lua > ../../after/syntax/lua.vim
$lua lua/treesitter.lua > ../../after/queries/lua/highlights.scm
$lua lua/generate_api_list.lua > ../../test/example/api_full_list.lua
$lua lua/generate_api_list.lua > ../../test/example/conf.lua

# Cleanup
rm -rf love-api
rm -rf love-conf
rm -rf lua/love-api

popd > /dev/null
