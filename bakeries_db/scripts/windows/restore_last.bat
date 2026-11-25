@echo off
chcp 65001 >nul
echo ==========================================
echo  Восстановление БД из ПОСЛЕДНЕГО бэкапа
echo ==========================================
echo.

:: Путь к папке бэкапов (внутри scripts)
set BACKUP_DIR=%~dp0..\backups

:: Проверяем, что папка существует
if not exist "%BACKUP_DIR%" (
    echo Папка backups не найдена!
    echo Сначала создайте бэкап через backup_windows.bat
    pause
    exit /b 1
)

:: Ищем последний бэкап (по дате изменения, самый свежий)
set LATEST=
for /f "delims=" %%f in ('dir /b /o-d "%BACKUP_DIR%\backup_*.sql" 2^>nul') do (
    if not defined LATEST set "LATEST=%BACKUP_DIR%\%%f"
)

:: Если бэкапов нет
if not defined LATEST (
    echo В папке backups нет ни одного бэкапа!
    echo Сначала создайте бэкап через backup_windows.bat
    pause
    exit /b 1
)

:: Настройки БД
set DB_NAME=bakery_chain
set DB_USER=postgres
set PG_PATH=C:\Program Files\PostgreSQL\18\bin

:: Показываем, что будем делать
echo Найден последний бэкап:
echo %LATEST%
echo.
for %%A in ("%LATEST%") do echo Размер файла: %%~zA байт
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
    echo Ошибка удаления БД. Проверьте пароль postgres.
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
"%PG_PATH%\psql.exe" -U %DB_USER% -d %DB_NAME% -f "%LATEST%" >nul 2>&1
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