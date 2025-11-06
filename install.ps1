# ================================================
# install.ps1 - Git Smart Wrapper 安装脚本 (增强版)
# ================================================
# 功能：
#    自动创建安装目录 (默认 C:\Tools\git-smart)
#    自动复制 git-smart.ps1
#    自动生成动态路径版 git.cmd
#    自动添加 PATH 环境变量
#    验证安装结果
# ================================================

[CmdletBinding()]
param(
    [string]$InstallPath = "C:\Tools\git-smart"
)

Write-Host " Git Smart Wrapper 安装程序" -ForegroundColor Cyan
Write-Host "==============================================="

# -----------------------------
#  检查执行策略
# -----------------------------
$execPolicy = Get-ExecutionPolicy
if ($execPolicy -eq "Restricted") {
    Write-Host "`n️  当前 PowerShell 执行策略为 Restricted，脚本无法运行。" -ForegroundColor Yellow
    Write-Host " 请以管理员身份执行以下命令后重新运行 install.ps1：" -ForegroundColor Cyan
    Write-Host "   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Green
    exit 1
}

# -----------------------------
#  创建安装目录
# -----------------------------
if (-not (Test-Path $InstallPath)) {
    Write-Host "`n 正在创建安装目录: $InstallPath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
} else {
    Write-Host "`n 检测到已有安装目录: $InstallPath" -ForegroundColor Yellow
}

# -----------------------------
#  复制 git-smart.ps1
# -----------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcSmart = Join-Path $scriptDir "git-smart.ps1"
$dstSmart = Join-Path $InstallPath "git-smart.ps1"

if (Test-Path $srcSmart) {
    Copy-Item $srcSmart $dstSmart -Force
    Write-Host " 已复制: git-smart.ps1" -ForegroundColor Green
} else {
    Write-Host " 未找到 git-smart.ps1，请确保文件与 install.ps1 位于同一目录。" -ForegroundColor Red
    exit 1
}

# -----------------------------
#  生成动态 git.cmd
# -----------------------------
$cmdPath = Join-Path $InstallPath "git.cmd"

$cmdContent = @'
@echo off
REM ================================================
REM git.cmd - 智能 Git 包装器入口 (自动生成版)
REM ================================================
REM 自动生成时间: {0}
REM 安装目录: {1}
REM ================================================

setlocal

REM --- 检测脚本目录
set "SCRIPT_DIR={1}"

REM --- 自动查找 git.exe
for /f "usebackq tokens=* delims=" %%i in (`where git.exe 2^>nul`) do (
    set "GIT_EXE=%%i"
    goto found_git
)
echo  未找到 git.exe，请确认已安装 Git 并加入系统 PATH。
exit /b 1

:found_git
REM --- 调用 PowerShell 脚本
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass ^
    -File "%SCRIPT_DIR%\git-smart.ps1" %*

endlocal
exit /b %ERRORLEVEL%
'@ -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $InstallPath

Set-Content -Path $cmdPath -Value $cmdContent -Encoding UTF8
Write-Host " 已生成动态路径版: git.cmd" -ForegroundColor Green

# -----------------------------
# 添加 PATH 环境变量（系统优先）
# -----------------------------

# 检查是否管理员
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# 获取 PATH 环境变量
$level = if ($IsAdmin) { "Machine" } else { "User" }
$envPaths = [System.Environment]::GetEnvironmentVariable("Path", $level).Split(";") | Where-Object { $_ -ne "" }

if ($envPaths -notcontains $InstallPath) {
    if ($IsAdmin) {
        Write-Host "`n正在添加到系统 PATH..." -ForegroundColor Cyan
    } else {
        Write-Host "`n当前非管理员，正在添加到用户 PATH..." -ForegroundColor Yellow
    }

    $newPath = [String]::Join(";", $envPaths + $InstallPath)
    try {
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, $level)
        Write-Host "已添加到 $level PATH: $InstallPath" -ForegroundColor Green
    } catch {
        Write-Host "添加 PATH 失败，请以管理员身份运行 PowerShell。" -ForegroundColor Red
    }
} else {
    Write-Host "`nPATH 中已包含: $InstallPath" -ForegroundColor Yellow
}


# -----------------------------
#  验证安装结果
# -----------------------------
Write-Host "`n 正在验证安装..." -ForegroundColor Cyan
$gitCheck = & cmd /c "where git.cmd" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " Git Smart Wrapper 安装成功！" -ForegroundColor Green
    Write-Host "`n可以直接使用以下命令：" -ForegroundColor Cyan
    Write-Host "   git status"
    Write-Host "   git -fp pull"
} else {
    Write-Host "️ 未检测到 git.cmd，请尝试重新打开终端。" -ForegroundColor Yellow
}

Write-Host "`n 安装完成！如需卸载，请删除目录并移除 PATH: $InstallPath" -ForegroundColor Green
