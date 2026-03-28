@echo off
chcp 65001 >nul 2>&1

echo =========================================
echo   Customer Management API - Running Tests
echo =========================================

REM Check Java
where java >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed. Please install Java 21 or higher.
    exit /b 1
)

for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VER=%%~i
echo [INFO] Java version: %JAVA_VER%
echo.

REM Run tests
echo [INFO] Running tests...
echo.

call gradlew.bat test
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Some tests failed. Check the report below.
)

echo.
echo =========================================
echo   Test Results
echo =========================================

set REPORT=build\reports\tests\test\index.html
if exist "%REPORT%" (
    echo [INFO] HTML report: %REPORT%
    echo [INFO] Opening report in browser...
    start "" "%REPORT%"
) else (
    echo [WARN] Test report not found.
)
