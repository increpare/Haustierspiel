haxe -cp src -lib heaps -js hello.js -main Main -debug
if %errorlevel% neq 0 exit /b %errorlevel%
del hello.js.map
if %errorlevel% neq 0 exit /b %errorlevel%
.\runserver.bat
if %errorlevel% neq 0 exit /b %errorlevel%
