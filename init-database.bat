@echo off
REM Database Initialization Script for PocketPilot
REM This script initializes the MySQL database for Docker

echo.
echo ============================================
echo PocketPilot Database Initialization
echo ============================================
echo.

REM Check if MySQL CLI is available
if not exist "C:\xampp2\mysql\bin\mysql.exe" (
    echo ERROR: MySQL not found at C:\xampp2\mysql\bin\mysql.exe
    echo Please ensure XAMPP is installed properly.
    pause
    exit /b 1
)

REM Create database and import tables
echo Initializing PocketPilot database...
"C:\xampp2\mysql\bin\mysql.exe" -u root < "database-setup.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Database initialized successfully!
    echo.
) else (
    echo.
    echo ✗ Database initialization failed!
    echo.
    pause
    exit /b 1
)

REM Verify the database was created
echo.
echo Verifying database creation...
"C:\xampp2\mysql\bin\mysql.exe" -u root -e "SHOW DATABASES;" | findstr /i "PP"

if %ERRORLEVEL% EQU 0 (
    echo ✓ PP database exists!
    echo.
    echo Database initialization complete.
    echo.
    pause
) else (
    echo ✗ Failed to create PP database
    pause
    exit /b 1
)
