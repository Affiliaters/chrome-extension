@echo off
rem install.bat — one-time auto-update setup (Windows).
rem
rem Double-click this ONCE from inside the extension folder, wherever you put
rem it. It registers a Task Scheduler job that runs update.ps1 every hour,
rem pointing at THIS folder — so the extension can live anywhere. If you ever
rem move the folder, just double-click this again from the new location.
setlocal

set "SCRIPT_DIR=%~dp0"
set "TASK_NAME=AffiliatersExtensionUpdater"

echo.
echo Affiliaters Deal Converter - auto-update setup
echo Extension folder: %SCRIPT_DIR%
echo.

if not exist "%SCRIPT_DIR%manifest.json" (
    echo ERROR: run this from inside the extension folder ^(manifest.json not found^).
    pause
    exit /b 1
)
if not exist "%SCRIPT_DIR%update.ps1" (
    echo ERROR: update.ps1 not found next to this installer.
    pause
    exit /b 1
)

rem /F overwrites any previous registration (handles re-runs and folder moves).
schtasks /Create /F /SC HOURLY /MO 1 /TN "%TASK_NAME%" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%SCRIPT_DIR%update.ps1\"" >nul
if errorlevel 1 (
    echo ERROR: could not register the scheduled task.
    pause
    exit /b 1
)
echo OK: Windows auto-update installed ^(checks every hour^).

echo.
echo Running the first update check now...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update.ps1"
echo Done. Details are in last-update.log inside the extension folder.
echo.
echo From now on the extension updates itself automatically.
echo If you ever MOVE this folder, double-click this installer again from the new location.
pause
exit /b 0
