[CmdletBinding()]
param(
    [switch]$fp,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$GitArgs
)

# -----------------------------
# 🧱 防递归保护
# -----------------------------
if ($env:GIT_SMART_ACTIVE -eq "1") {
    & git $GitArgs
    exit $LASTEXITCODE
}

$env:GIT_SMART_ACTIVE = "1"

# -----------------------------
# 🧭 获取系统代理（Windows）
# -----------------------------
function Get-SystemProxy {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    try {
        $proxyEnabled = (Get-ItemProperty -Path $regPath -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
        if ($proxyEnabled -ne 1) { return $null }

        $proxyServer = (Get-ItemProperty -Path $regPath -Name ProxyServer -ErrorAction SilentlyContinue).ProxyServer
        if (-not $proxyServer) { return $null }

        if ($proxyServer -match "http=") {
            if ($proxyServer -match "http=([^;]+)") { $http = $matches[1] }
            if ($proxyServer -match "https=([^;]+)") { $https = $matches[1] } else { $https = $http }
        } else {
            $http = $proxyServer
            $https = $proxyServer
        }

        return @{
            HttpProxy = "http://$http"
            HttpsProxy = "https://$https"
        }
    } catch {
        return $null
    }
}

# -----------------------------
# 🚀 主逻辑
# -----------------------------
if ($GitArgs.Count -eq 0) {
    Write-Host "Usage: git [-fp] <git-command> [options]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  git push origin main"
    Write-Host "  git -fp clone https://github.com/user/repo.git"
    Remove-Item Env:\GIT_SMART_ACTIVE -ErrorAction SilentlyContinue
    exit 1
}

if ($fp) {
    # --- 强制直连模式 ---
    Write-Host " Forcing direct connection (no proxy)..." -ForegroundColor Yellow
    $proxyArgs = @("-c", "http.proxy=", "-c", "https.proxy=") + $GitArgs
    & git $proxyArgs
}
else {
    # --- 默认使用代理 ---
    Write-Host " Default mode: trying to use system proxy..." -ForegroundColor Cyan
    $proxy = Get-SystemProxy
    if ($proxy -ne $null) {
        Write-Host " Using system proxy: $($proxy.HttpProxy)" -ForegroundColor Green
        $proxyArgs = @(
            "-c", "http.proxy=$($proxy.HttpProxy)",
            "-c", "https.proxy=$($proxy.HttpsProxy)"
        ) + $GitArgs
        & git $proxyArgs
    } else {
        Write-Host " No system proxy found, running git directly." -ForegroundColor Yellow
        & git $GitArgs
    }
}

# -----------------------------
# 🧹 清理环境变量
# -----------------------------
Remove-Item Env:\GIT_SMART_ACTIVE -ErrorAction SilentlyContinue
exit $LASTEXITCODE
