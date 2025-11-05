@echo off
REM git wrapper that delegates to git-smart.ps1
REM If GIT_SMART_ACTIVE==1 then call the real git.exe directly to avoid recursion.
REM 配置当前git路径
if "%GIT_SMART_ACTIVE%"=="1" (
    "X:\\xxx\\cmd\\git.exe" %*
    exit /b %ERRORLEVEL%
)

REM call git-smart ps1 (path to your script)(修改当前脚本路径)
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\\xxx\\\xxx\\git-smart.ps1" %*
exit /b %ERRORLEVEL%
