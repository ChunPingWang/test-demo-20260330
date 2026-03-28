@echo off
chcp 65001 >nul 2>&1

echo =========================================
echo   Customer Management API - Starting
echo =========================================

REM Check Java
where java >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed. Please install Java 21 or higher.
    exit /b 1
)

for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VER=%%~i
echo [INFO] Java version: %JAVA_VER%

REM Build
echo.
echo [INFO] Building project...
call gradlew.bat build -x test --quiet
if %errorlevel% neq 0 (
    echo [ERROR] Build failed.
    exit /b 1
)

REM Run
echo [INFO] Starting application on http://localhost:8080
echo [INFO] Swagger UI: http://localhost:8080/swagger-ui.html
echo [INFO] H2 Console: http://localhost:8080/h2-console
echo [INFO] Press Ctrl+C to stop.
echo.

call gradlew.bat bootRun --quiet
