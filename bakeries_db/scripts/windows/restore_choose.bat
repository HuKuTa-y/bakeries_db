@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Путь к папке бэкапов (внутри scripts)
set BACKUP_DIR=%~dp0..\backups

:: Настройки БД
set DB_NAME=bakery_chain
set DB_USER=postgres
set PG_PATH=C:\Program Files\PostgreSQL\18\bin

echo ==========================================
echo  Доступные бэкапы:
echo ==========================================

:: Проверяем, что папка существует
if not exist "%BACKUP_DIR%" (
    echo Папка backups не найдена!
    pause
    exit /b 1
)

:: Считаем и выводим бэкапы
set /a count=0
for %%f in ("%BACKUP_DIR%\backup_*.sql") do (
    set /a count+=1
    set "file!count!=%%f"
    echo   [!count!] %%~nxf   ^(%%~zA байт^)
)

if %count%==0 (
    echo.
    echo Бэкапы не найдены в папке backups!
    echo Сначала создайте бэкап через backup_windows.bat
    pause
    exit /b 1
)

echo.
echo Всего найдено бэкапов: %count%
echo.
set /p choice="Введите номер бэкапа (1-%count%): "

set "BACKUP_FILE=!file%choice%!"

if not defined BACKUP_FILE (
    echo.
    echo Неверный номер!
    pause
    exit /b 1
)

echo.
echo Выбран бэкап:
echo %BACKUP_FILE%
echo.
echo ==========================================
echo  ВНИМАНИЕ!
echo  База данных '%DB_NAME%' будет ПОЛНОСТЬЮ УДАЛЕНА
echo  и восстановлена из выбранного бэкапа.
echo ==========================================
echo.
set /p CONFIRM="Продолжить? (yes/no): "

if /i not "%CONFIRM%"=="yes" (
    echo Отменено.
    pause
    exit /b 0
)

echo.
echo [1/3] Удаление старой базы данных...
"%PG_PATH%\dropdb.exe" -U %DB_USER% --if-exists %DB_NAME%
if %errorlevel% neq 0 (
    echo Ошибка удаления БД.
    pause
    exit /b 1
)

echo [2/3] Создание новой базы данных...
"%PG_PATH%\createdb.exe" -U %DB_USER% %DB_NAME%
if %errorlevel% neq 0 (
    echo Ошибка создания БД.
    pause
    exit /b 1
)

echo [3/3] Восстановление данных...
"%PG_PATH%\psql.exe" -U %DB_USER% -d %DB_NAME% -f "%BACKUP_FILE%" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo  УСПЕХ! База данных восстановлена.
    echo ==========================================
) else (
    echo.
    echo ОШИБКА при восстановлении!
)

echo.
pause