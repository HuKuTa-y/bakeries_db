#!/bin/bash
# ==========================================
# Восстановление БД с ВЫБОРОМ бэкапа
# Использование: ./restore_choose.sh
# ==========================================

# Путь к папке бэкапов
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/../backups"

# Настройки БД
DB_NAME="bakery_chain"
DB_USER="postgres"

echo "=========================================="
echo " Доступные бэкапы:"
echo "=========================================="

# Проверяем, что папка существует
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Папка backups не найдена!"
    exit 1
fi

# Собираем бэкапы в массив
mapfile -t BACKUPS < <(ls -t "$BACKUP_DIR"/backup_*.sql 2>/dev/null)

# Если бэкапов нет
if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "Бэкапы не найдены в папке backups!"
    echo "Сначала создайте бэкап через backup_linux.sh"
    exit 1
fi

# Выводим список
for i in "${!BACKUPS[@]}"; do
    FILE="${BACKUPS[$i]}"
    SIZE=$(du -h "$FILE" | cut -f1)
    NAME=$(basename "$FILE")
    echo "  [$((i+1))] $NAME   ($SIZE)"
done

echo ""
echo "Всего найдено бэкапов: ${#BACKUPS[@]}"
echo ""
read -p "Введите номер бэкапа (1-${#BACKUPS[@]}): " CHOICE

# Проверяем корректность ввода
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#BACKUPS[@]}" ]; then
    echo "Неверный номер!"
    exit 1
fi

BACKUP_FILE="${BACKUPS[$((CHOICE-1))]}"

echo ""
echo "Выбран бэкап:"
echo "  $BACKUP_FILE"
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
    echo "Ошибка удаления БД."
    exit 1
fi

echo "[2/3] Создание новой базы данных..."
createdb -U "$DB_USER" "$DB_NAME"
if [ $? -ne 0 ]; then
    echo "Ошибка создания БД."
    exit 1
fi

echo "[3/3] Восстановление данных..."
psql -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE" > /dev/null 2>&1
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