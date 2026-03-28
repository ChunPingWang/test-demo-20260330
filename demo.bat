@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

if "%~1"=="" (set BASE_URL=http://localhost:8080) else (set BASE_URL=%~1)
set API_URL=%BASE_URL%/api/customers
set PASS=0
set FAIL=0

echo.
echo   Customer Management API - Demo Script
echo   Base URL: %API_URL%

REM =========================================
REM Step 1
REM =========================================
echo.
echo =========================================
echo   Step 1: Query customer - should NOT exist
echo =========================================

curl -s "%API_URL%" > %TEMP%\demo_resp.txt
type %TEMP%\demo_resp.txt
echo.

findstr /C:"san.zhang@example.com" %TEMP%\demo_resp.txt >nul 2>&1
if %errorlevel% neq 0 (
    echo [PASS] Customer should not exist
    set /a PASS+=1
) else (
    echo [FAIL] Customer should not exist
    set /a FAIL+=1
)

REM =========================================
REM Step 2
REM =========================================
echo.
echo =========================================
echo   Step 2: Create customer
echo =========================================

curl -s -w "%%{http_code}" -X POST "%API_URL%" -H "Content-Type: application/json" -d "{\"name\":\"Zhang San\",\"email\":\"san.zhang@example.com\",\"phone\":\"0912345678\",\"address\":\"Taipei, Taiwan\"}" > %TEMP%\demo_resp.txt

set /p RESULT=<%TEMP%\demo_resp.txt
echo Response: !RESULT!

echo !RESULT! | findstr /C:"201" >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Create should return 201
    set /a PASS+=1
) else (
    echo [FAIL] Create should return 201
    set /a FAIL+=1
)

REM Extract ID
for /f "tokens=2 delims=:," %%a in ('echo !RESULT! ^| findstr /R "\"id\":"') do (
    set CUSTOMER_ID=%%a
    goto :got_id
)
:got_id
echo Created customer ID: %CUSTOMER_ID%

REM =========================================
REM Step 3
REM =========================================
echo.
echo =========================================
echo   Step 3: Query customer by ID - should exist
echo =========================================

curl -s -w "\n%%{http_code}" "%API_URL%/%CUSTOMER_ID%" > %TEMP%\demo_resp.txt
type %TEMP%\demo_resp.txt
echo.

findstr /C:"Zhang San" %TEMP%\demo_resp.txt >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Name should be Zhang San
    set /a PASS+=1
) else (
    echo [FAIL] Name should be Zhang San
    set /a FAIL+=1
)

REM =========================================
REM Step 4
REM =========================================
echo.
echo =========================================
echo   Step 4: Update customer
echo =========================================

curl -s -w "%%{http_code}" -X PUT "%API_URL%/%CUSTOMER_ID%" -H "Content-Type: application/json" -d "{\"name\":\"Zhang San\",\"email\":\"san.zhang@example.com\",\"phone\":\"0987654321\",\"address\":\"Kaohsiung, Taiwan\"}" > %TEMP%\demo_resp.txt

set /p RESULT=<%TEMP%\demo_resp.txt
echo Response: !RESULT!

echo !RESULT! | findstr /C:"0987654321" >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Phone should be updated
    set /a PASS+=1
) else (
    echo [FAIL] Phone should be updated
    set /a FAIL+=1
)

REM =========================================
REM Step 5
REM =========================================
echo.
echo =========================================
echo   Step 5: Query customer again - should reflect updates
echo =========================================

curl -s "%API_URL%/%CUSTOMER_ID%" > %TEMP%\demo_resp.txt
type %TEMP%\demo_resp.txt
echo.

findstr /C:"Kaohsiung" %TEMP%\demo_resp.txt >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Address should be Kaohsiung, Taiwan
    set /a PASS+=1
) else (
    echo [FAIL] Address should be Kaohsiung, Taiwan
    set /a FAIL+=1
)

REM =========================================
REM Step 6
REM =========================================
echo.
echo =========================================
echo   Step 6: Delete customer
echo =========================================

curl -s -o nul -w "%%{http_code}" -X DELETE "%API_URL%/%CUSTOMER_ID%" > %TEMP%\demo_resp.txt
set /p HTTP_CODE=<%TEMP%\demo_resp.txt
echo Response: %HTTP_CODE%

echo %HTTP_CODE% | findstr /C:"204" >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Delete should return 204
    set /a PASS+=1
) else (
    echo [FAIL] Delete should return 204
    set /a FAIL+=1
)

REM =========================================
REM Step 7
REM =========================================
echo.
echo =========================================
echo   Step 7: Query customer again - should NOT exist
echo =========================================

curl -s -w "\n%%{http_code}" "%API_URL%/%CUSTOMER_ID%" > %TEMP%\demo_resp.txt
type %TEMP%\demo_resp.txt
echo.

findstr /C:"400" %TEMP%\demo_resp.txt >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Query deleted customer should return 400
    set /a PASS+=1
) else (
    echo [FAIL] Query deleted customer should return 400
    set /a FAIL+=1
)

REM =========================================
REM Summary
REM =========================================
echo.
echo =========================================
echo   Results: %PASS% passed, %FAIL% failed
echo =========================================

if %FAIL% gtr 0 exit /b 1
