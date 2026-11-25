#!/bin/bash
# ==========================================
# Скрипт бэкапа БД «Сеть пекарен»
# Использование: ./backup.sh
# ==========================================

# Настройки
DB_NAME="bakery_chain"
DB_USER="postgres"
BACKUP_DIR="./backups"

# Создаём папку для бэкапов, если её нет
mkdir -p "$BACKUP_DIR"

# Генерируем имя файла с датой и временем
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="backup_${DATE}.sql"
FILEPATH="${BACKUP_DIR}/${FILENAME}"

# Делаем бэкап
echo "Создание бэкапа базы данных '${DB_NAME}'..."
pg_dump -U "$DB_USER" -d "$DB_NAME" > "$FILEPATH"

# Проверяем успех
if [ $? -eq 0 ]; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "Бэкап успешно создан!"
    echo "Файл: $FILEPATH"
    echo "Размер: $SIZE"
else
    echo "Ошибка при создании бэкапа!"
    exit 1
fi