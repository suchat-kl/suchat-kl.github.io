# สร้าง user-guide.pdf จาก user-guide.html ด้วย Chrome (หรือ Edge) แบบ headless
# วิธีใช้: คลิกขวาไฟล์นี้ > Run with PowerShell  หรือ  powershell -ExecutionPolicy Bypass -File build-pdf.ps1
# ผลลัพธ์: ..\user-guide.pdf (แอปเปิดจาก https://suchat-kl.github.io/studentscore/user-guide.pdf)
# แล้ว commit + push repo นี้ ประมาณ 1-2 นาทีหน้าเว็บจะอัปเดต
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $here 'user-guide.html'
$pdf = Join-Path (Split-Path -Parent $here) 'user-guide.pdf'
$browsers = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$exe = $browsers | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $exe) { throw 'ไม่พบ Chrome หรือ Edge' }
$url = ([System.Uri]$html).AbsoluteUri
$tmp = Join-Path $env:TEMP ('guide-pdf-' + [guid]::NewGuid())
if (Test-Path $pdf) { Remove-Item $pdf }
$chromeArgs = @('--headless=new', '--disable-gpu', '--no-pdf-header-footer', "--user-data-dir=`"$tmp`"", '--virtual-time-budget=5000', "--print-to-pdf=`"$pdf`"", $url)
Start-Process -FilePath $exe -ArgumentList $chromeArgs -Wait -WindowStyle Hidden
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
if (-not (Test-Path $pdf)) { throw 'สร้าง PDF ไม่สำเร็จ' }
Write-Host ('สร้างแล้ว: ' + $pdf + '  (' + [math]::Round((Get-Item $pdf).Length / 1KB) + ' KB)')
