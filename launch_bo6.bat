@echo off
cd /d "%~dp0"
setlocal ENABLEDELAYEDEXPANSION
title Launch COD BO6 (Clean Cache + GPU Prewarm Fix)

:: ============================================================
::  Auto Elevation - request administrator if not already
:: ============================================================
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    set "vbs=%temp%\getadmin_launch_bo6.vbs"
    >"%vbs%" echo Set UAC = CreateObject^("Shell.Application"^)
    >>"%vbs%" echo UAC.ShellExecute "%~s0", "", "", "runas", 1
    cscript //nologo "%vbs%" >nul 2>&1
    del "%vbs%" >nul 2>&1
    exit /b
)
cd /d "%~dp0"

:: ============================================================
::  Configuration
:: ============================================================
set "COD_LAUNCHER=%~dp0[KLIK INI UNTUK BERMAIN].bat"

:: ============================================================
::  Step 1: Clean Activision Cache
:: ============================================================
echo [1/3] Cleaning Activision local cache...
if exist "%LOCALAPPDATA%\Activision\Call Of Duty" (
    attrib -r -s -h "%LOCALAPPDATA%\Activision\Call Of Duty" /S >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\Activision\Call Of Duty" >nul 2>&1
    echo     -> Activision cache deleted.
) else (
    echo     -> Folder not found, skipping.
)

:: ============================================================
::  Step 2: Clean NVIDIA DirectX Cache
:: ============================================================
echo [2/3] Cleaning NVIDIA DXCache...
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" (
    del /f /q "%LOCALAPPDATA%\NVIDIA\DXCache\*" >nul 2>&1
    for /d %%D in ("%LOCALAPPDATA%\NVIDIA\DXCache\*") do rmdir /s /q "%%~fD" >nul 2>&1
    echo     -> DXCache cleaned.
) else (
    echo     -> DXCache not found, skipping.
)

:: ============================================================
::  Step 3: Prewarm GPU / DirectX using PowerShell WPF
:: ============================================================
echo [3/3] Initializing GPU (DirectX prewarm)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try {
     Add-Type -AssemblyName PresentationCore,PresentationFramework;
     $null = New-Object System.Windows.Media.Media3D.Viewport3D;
     Start-Sleep -Seconds 3
  } catch {}" >nul 2>&1
echo     -> GPU initialized.

:: ============================================================
::  Launch Game
:: ============================================================
echo Launching Call of Duty: Black Ops 6...
if exist "%COD_LAUNCHER%" (
    start "" /HIGH "%COD_LAUNCHER%"
) else (
    echo [!] Launcher not found: "%COD_LAUNCHER%"
    pause
)

endlocal
exit /b
