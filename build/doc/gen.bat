	@echo off

REM Set the current directory to the location of this script
pushd %~dp0

REM Update the doc directory
del /f /q ..\..\doc\love2d-docs.txt

REM Generate documentation
%lua% main.lua > ..\..\doc\love2d-docs.txt

REM Generate helptags
%nvim% -c "helptags ../../doc" -c "qa!"

REM Cleanup
rd /q /s love-api

popd
