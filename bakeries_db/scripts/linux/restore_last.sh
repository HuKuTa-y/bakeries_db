#!/bin/bash
# ==========================================
# Восстановление БД из ПОСЛЕДНЕГО бэкапа
# Использование: ./restore_last.sh
# ==========================================

# Путь к папке бэкапов (на уровень выше scripts/linux)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/../backups"

# Настройки БД
DB_NAME="bakery_chain"
DB_USER="postgres"

# Проверяем, что папка существует
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Папка backups не найдена!"
    echo "Сначала создайте бэкап через backup_linux.sh"
    exit 1
fi

# Ищем последний бэкап (по дате изменения)
LATEST=$(ls -t "$BACKUP_DIR"/backup_*.sql 2>/dev/null | head -n 1)

# Если бэкапов нет
if [ -z "$LATEST" ]; then
    echo "В папке backups нет ни одного бэкапа!"
    echo "Сначала создайте бэкап через backup_linux.sh"
    exit 1
fi

# Показываем, что будем делать
echo "=========================================="
echo " Восстановление БД из ПОСЛЕДНЕГО бэкапа"
echo "=========================================="
echo ""
echo "Найден последний бэкап:"
echo "  $LATEST"
echo "  Размер: $(du -h "$LATEST" | cut -f1)"
echo ""
echo "ВНИМАНИЕ!"
echo "  База данных '$DB_NAME' будет ПОЛНОСТЬЮ УДАЛЕНА"
echo "  и восстановлена из выбранного бэкапа."
echo ""
read -p "Продолжить? (введите 'yes' для подтверждения): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Отменено."
    exit 0
fi

echo ""
echo "[1/3] Удаление старой базы данных..."
dropdb -U "$DB_USER" --if-exists "$DB_NAME"
if [ $? -ne 0 ]; then
    echo "Ошибка удаления БД. Проверьте пароль postgres."
    exit 1
fi

echo "[2/3] Создание новой базы данных..."
createdb -U "$DB_USER" "$DB_NAME"
if [ $? -ne 0 ]; then
    echo "Ошибка создания БД."
    exit 1
fi

echo "[3/3] Восстановление данных..."
psql -U "$DB_USER" -d "$DB_NAME" -f "$LATEST" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo " УСПЕХ! База данных восстановлена."
    echo "=========================================="
else
    echo ""
    echo "ОШИБКА при восстановлении!"
    exit 1
fi