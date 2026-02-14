@echo off

REM Allows mkdir to create parent directories automatically
setlocal EnableExtensions

REM Set the current directory to the location of this script
pushd %~dp0

REM Copy love-api to child directories
xcopy /e /q /y love-api love-conf\love-api\
xcopy /e /q /y love-api lua\love-api\

REM Update after\syntax
del /f /q ..\..\after\syntax\lua.vim
del /f /q ..\..\after\queries\lua\highlights.scm
del /f /q ..\..\test\example\api_full_list.lua
del /f /q ..\..\test\example\conf.lua

REM Create syntax files
!lua! lua\main.lua > ..\..\after\syntax\lua.vim
!lua! lua\treesitter.lua > ..\..\after\queries\lua\highlights.scm
!lua! lua\generate_api_list.lua > ..\..\test\example\api_full_list.lua
!lua! lua\generate_conf.lua > ..\..\test\example\conf.lua

REM Cleanup
rd /q /s love-api
rd /q /s love-conf
rd /q /s lua\love-api

popd
