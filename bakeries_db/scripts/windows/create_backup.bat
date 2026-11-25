@echo off
chcp 65001 >nul
echo ==========================================
echo  Бэкап БД "Сеть пекарен" (Windows)
echo ==========================================

:: Настройки
set DB_NAME=bakery_chain
set DB_USER=postgres
set BACKUP_DIR=.\backups
set PG_DUMP="C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"

:: Создаём папку для бэкапов
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Формируем имя файла с датой
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set FILENAME=backup_%datetime:~0,8%_%datetime:~8,6%.sql

:: Делаем бэкап
echo Создание бэкапа...
%PG_DUMP% -U %DB_USER% -d %DB_NAME% > "%BACKUP_DIR%\%FILENAME%"

:: Проверяем результат
if %errorlevel% equ 0 (
    echo Бэкап успешно создан: %BACKUP_DIR%\%FILENAME%
) else (
    echo Ошибка при создании бэкапа!
)

pause