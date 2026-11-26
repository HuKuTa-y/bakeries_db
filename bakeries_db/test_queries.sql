-- ==========================================
-- Файл: test_queries.sql
-- Проект: БД «Сеть пекарен»
-- Описание: Полный набор проверочных запросов (10 основных из документации + 20 дополнительных)
-- ==========================================

-- ==========================================
-- ЧАСТЬ 1: ОСНОВНЫЕ ТЕСТОВЫЕ ЗАПРОСЫ (ИЗ ДОКУМЕНТАЦИИ)
-- ==========================================

-- 1. Простая выборка с фильтром: активные пекарни
SELECT 
    name AS "Название пекарни",
    address AS "Адрес",
    rating AS "Рейтинг",
    work_hours_start AS "Открытие",
    work_hours_end AS "Закрытие"
FROM bakeries
WHERE status = 'active'
ORDER BY rating DESC;

-- 2. Добавление новой записи: регистрация клиента
INSERT INTO customers (fullname, telephone_number, email, date_birthday, registration_date, status)
VALUES (
    'Иванов Иван Иванович',
    '+79991234567',
    'ivanov@example.com',
    '1990-05-15',
    CURRENT_DATE,
    'active'
)
RETURNING id, fullname, registration_date;

-- 3. Простое связывание двух таблиц: продукты и категории
SELECT 
    p.name AS "Продукт",
    p.price_for_customer AS "Цена",
    pc.name AS "Категория",
    p.lifespan_hours AS "Срок годности (часов)"
FROM products p
JOIN product_categories pc ON p.category_id = pc.id
ORDER BY pc.name, p.name;

-- 4. Фильтрация по датам с JOIN: ингредиенты, истекающие через 7 дней
SELECT 
    i.name AS "Ингредиент", 
    i.unit_type AS "Ед. измерения", 
    SUM(inv.quantity) AS "Общий остаток",
    MIN(inv.expiration_date) AS "Ближайший срок годности"
FROM ingredients i
JOIN inventory_ingredients inv ON i.id = inv.ingredient_id
WHERE inv.expiration_date < CURRENT_DATE + INTERVAL '7 days'
GROUP BY i.name, i.unit_type
ORDER BY MIN(inv.expiration_date) ASC;

-- 5. Статистика продаж по пекарням
SELECT 
    b.name AS "Пекарня", 
    COUNT(s.id) AS "Количество чеков",
    ROUND(AVG(s.total_amount), 2) AS "Средний чек",
    SUM(s.total_amount) AS "Общая выручка",
    MAX(s.date) AS "Последняя продажа"
FROM sales s
JOIN bakeries b ON s.bakery_id = b.id
WHERE s.status = 'completed'
GROUP BY b.name 
HAVING COUNT(s.id) > 0
ORDER BY SUM(s.total_amount) DESC;

-- 6. Топ-10 клиентов программы лояльности
SELECT 
    c.fullname AS "ФИО клиента", 
    c.telephone_number AS "Телефон",
    lc.level AS "Уровень карты",
    lc.total_points AS "Баланс баллов",
    COUNT(s.id) AS "Количество покупок",
    SUM(s.total_amount) AS "Общая сумма покупок"
FROM customers c
JOIN loyalty_cards lc ON c.id = lc.customer_id
JOIN sales s ON s.customer_id = c.id
WHERE s.status = 'completed'
GROUP BY c.fullname, c.telephone_number, lc.level, lc.total_points
ORDER BY SUM(s.total_amount) DESC
LIMIT 10;

-- 7. Анализ возвратов с причинами (за 30 дней)
SELECT 
    p.name AS "Товар",
    pc.name AS "Категория",
    COUNT(r.id) AS "Количество возвратов",
    SUM(r.refund_amount) AS "Сумма возвратов"
FROM returns r
JOIN products p ON r.product_id = p.id
LEFT JOIN product_categories pc ON p.category_id = pc.id
WHERE r.return_date >= CURRENT_DATE - INTERVAL '30 days'
  AND r.status = 'completed'
GROUP BY p.name, pc.name
HAVING COUNT(r.id) >= 3
ORDER BY COUNT(r.id) DESC;

-- 8. Выручка по категориям продуктов (за последний месяц)
SELECT 
    pc.name AS "Категория",
    COUNT(DISTINCT s.id) AS "Количество чеков",
    SUM(sd.quantity) AS "Продано единиц",
    SUM(sd.total_per_item) AS "Выручка"
FROM sale_details sd
JOIN sales s ON sd.sale_id = s.id
JOIN products p ON sd.product_id = p.id
JOIN product_categories pc ON p.category_id = pc.id
WHERE s.date >= CURRENT_DATE - INTERVAL '30 days'
  AND s.status = 'completed'
GROUP BY pc.name
ORDER BY SUM(sd.total_per_item) DESC;

-- 9. Сотрудники с просроченными медкнижками
SELECT 
    e.fullname AS "ФИО сотрудника",
    e.position AS "Должность",
    b.name AS "Пекарня",
    mb.medical_record_number AS "Номер медкнижки",
    mb.issue_date AS "Дата выдачи",
    mb.validity_period AS "Срок действия (месяцев)",
    mb.issue_date + make_interval(months => mb.validity_period) AS "Дата истечения",
    CURRENT_DATE - (mb.issue_date + make_interval(months => mb.validity_period)) AS "Дней просрочки"
FROM employees e
JOIN medical_books mb ON e.id = mb.employee_id
JOIN bakeries b ON e.bakery_id = b.id
WHERE mb.status = 'overdue'
  AND e.status = 'active'
ORDER BY CURRENT_DATE - (mb.issue_date + make_interval(months => mb.validity_period)) DESC;

-- 10. Сравнение плана и факта производства (за последнюю неделю)
SELECT
    b.name AS "Пекарня",
    p.name AS "Продукт",
    pp.planned_date AS "Дата плана",
    pp.quantity AS "Запланировано",
    COALESCE(SUM(pb.quantity), 0) AS "Произведено",
    ROUND(COALESCE(SUM(pb.quantity), 0) * 100.0 / NULLIF(pp.quantity, 0), 1) AS "Выполнение, %"
FROM production_plans pp
JOIN bakeries b ON pp.bakery_id = b.id
JOIN products p ON pp.product_id = p.id
LEFT JOIN production_batches pb ON pp.bakery_id = pb.bakery_id 
    AND pp.product_id = pb.product_id 
    AND pp.planned_date = pb.production_date
    AND pb.status = 'ready'
WHERE pp.planned_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY b.name, p.name, pp.planned_date, pp.quantity
ORDER BY pp.planned_date DESC, "Выполнение, %" ASC;


-- ==========================================
-- ЧАСТЬ 2: ДОПОЛНИТЕЛЬНЫЕ ПРОВЕРОЧНЫЕ ЗАПРОСЫ (20 шт.)
-- ==========================================

-- 11. Ингредиенты, срок годности которых истекает в ближайшие 7 дней (альтернативный вид)
SELECT i.name AS "Ингредиент", i.unit_type AS "Ед. изм.", SUM(inv.quantity) AS "Остаток"
FROM ingredients i
JOIN inventory_ingredients inv ON i.id = inv.ingredient_id
WHERE inv.expiration_date < CURRENT_DATE + INTERVAL '7 days'
GROUP BY i.name, i.unit_type;

-- 12. Продукты, срок годности которых скоро истекает
SELECT p.name AS "Продукт", SUM(inv.quantity) AS "Остаток на складе"
FROM products p
JOIN inventory_products inv ON p.id = inv.product_id
WHERE inv.expiration_date < CURRENT_DATE + INTERVAL '3 days'
GROUP BY p.name;

-- 13. Товары, которые возвращали за последнюю неделю, и причины
SELECT p.name AS "Товар", COUNT(r.id) AS "Кол-во возвратов", r.reason AS "Причина"
FROM products p
JOIN returns r ON p.id = r.product_id
WHERE r.return_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.name, r.reason
ORDER BY COUNT(r.id) DESC;

-- 14. Активные работники пекарни 'Пекарня Зерно' и сумма к выдаче (оклад + премия)
SELECT e.fullname AS "ФИО", e.position AS "Должность", e.base_salary AS "Оклад", e.bonus AS "Премия", 
       (e.base_salary + e.bonus) AS "Итоговая сумма к выдаче"
FROM bakeries b
JOIN employees e ON e.bakery_id = b.id
WHERE b.name = 'Пекарня Зерно' AND e.status = 'active';

-- 15. Топ-5 самых щедрых клиентов за всё время
SELECT c.fullname AS "ФИО", c.telephone_number AS "Телефон", SUM(s.total_amount) AS "Потрачено"
FROM customers c
JOIN sales s ON s.customer_id = c.id
WHERE s.status = 'completed'
GROUP BY c.fullname, c.telephone_number
ORDER BY SUM(s.total_amount) DESC
LIMIT 5;

-- 16. ФИО и почта работников с истекшей медкнижкой (исправленная арифметика дат)
SELECT e.fullname AS "ФИО", e.email AS "Почта", mb.medical_record_number AS "№ медкнижки",
       mb.issue_date + make_interval(months => mb.validity_period) AS "Дата истечения"
FROM employees e
JOIN medical_books mb ON mb.employee_id = e.id
WHERE mb.status = 'overdue';

-- 17. Общее кол-во проданных единиц для каждого товара за последние 3 года
SELECT p.name AS "Продукт", SUM(sd.quantity) AS "Количество продаж" 
FROM sale_details sd 
JOIN sales s ON sd.sale_id = s.id
JOIN products p ON sd.product_id = p.id
WHERE s.date >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY p.name
ORDER BY SUM(sd.quantity) DESC;

-- 18. Средняя сумма чека для каждого магазина за все время
SELECT b.name AS "Пекарня", ROUND(AVG(s.total_amount), 2) AS "Средний чек" 
FROM sales s
JOIN bakeries b ON s.bakery_id = b.id
WHERE s.status = 'completed'
GROUP BY b.name 
ORDER BY AVG(s.total_amount) DESC;

-- 19. Кол-во продаж для каждого сотрудника БЕЗ применения скидок
SELECT e.fullname AS "Сотрудник", COUNT(s.id) AS "Кол-во продаж без скидок" 
FROM sales s
JOIN employees e ON s.employee_id = e.id
JOIN sale_details sd ON sd.sale_id = s.id
WHERE sd.discount_id IS NULL
GROUP BY e.id, e.fullname
HAVING COUNT(s.id) > 0
ORDER BY COUNT(s.id) DESC;

-- 20. Самый частый способ оплаты в сети
SELECT payment_method AS "Способ оплаты", COUNT(*) AS "Количество оплат"
FROM sales
GROUP BY payment_method
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 21. Остаток ингредиентов для каждого склада
SELECT w.name AS "Склад", i.name AS "Ингредиент", SUM(inv.quantity) AS "Остаток", i.unit_type AS "Ед. изм."
FROM inventory_ingredients inv
JOIN warehouses w ON inv.warehouse_id = w.id
JOIN ingredients i ON inv.ingredient_id = i.id
GROUP BY w.name, i.name, i.unit_type
ORDER BY w.name, SUM(inv.quantity) DESC;

-- 22. Остаток готовой продукции для каждого склада
SELECT w.name AS "Склад", p.name AS "Продукт", SUM(inv.quantity) AS "Остаток"
FROM inventory_products inv
JOIN warehouses w ON inv.warehouse_id = w.id
JOIN products p ON inv.product_id = p.id
GROUP BY w.name, p.name
ORDER BY w.name, SUM(inv.quantity) DESC;

-- 23. Пекарни, произведшие более 200 единиц продукции за последние 3 года
SELECT b.name AS "Пекарня", SUM(pb.quantity) AS "Кол-во продукции" 
FROM production_batches pb
JOIN bakeries b ON pb.bakery_id = b.id
WHERE pb.production_date >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY b.id, b.name
HAVING SUM(pb.quantity) > 200
ORDER BY SUM(pb.quantity) DESC;

-- 24. Топ-10 категорий по количеству видов продукции в них
SELECT pc.name AS "Категория", COUNT(p.id) AS "Кол-во продуктов" 
FROM products p
JOIN product_categories pc ON p.category_id = pc.id
GROUP BY pc.name 
ORDER BY COUNT(p.id) DESC
LIMIT 10;

-- 25. Выручка по каждой пекарне за сегодня
SELECT b.name AS "Пекарня", SUM(s.total_amount) AS "Выручка за сегодня" 
FROM sales s
JOIN bakeries b ON s.bakery_id = b.id
WHERE s.date = CURRENT_DATE AND s.status = 'completed'
GROUP BY b.name
ORDER BY SUM(s.total_amount) DESC;

-- 26. Топ-10 товаров-бестселлеров за последнюю неделю
SELECT p.name AS "Продукт", SUM(sd.quantity) AS "Кол-во продаж" 
FROM products p
JOIN sale_details sd ON sd.product_id = p.id
JOIN sales s ON sd.sale_id = s.id
WHERE s.status = 'completed' AND s.date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.name
ORDER BY SUM(sd.quantity) DESC
LIMIT 10;

-- 27. Рецепт, ингредиенты и их количество для 'Торт Наполеон'
SELECT p.name AS "Блюдо", i.name AS "Ингредиент", r.quantity AS "Количество", i.unit_type AS "Ед. изм.", r.instructions AS "Инструкция" 
FROM recipes r
JOIN ingredients i ON r.ingredient_id = i.id
JOIN products p ON r.product_id = p.id
WHERE p.name = 'Торт Наполеон';

-- 28. Топ-5 самых дорогих доставок от поставщиков (с учетом актуальной цены ингредиента)
SELECT 
    s.name_company AS "Поставщик", 
    i.name AS "Ингредиент", 
    wd.quantity AS "Количество", 
    i.unit_type AS "Ед. изм.",
    ROUND(wd.quantity * COALESCE((SELECT price_for_unit FROM ingredient_price_history WHERE ingredient_id = wd.ingredient_id AND status = 'active' ORDER BY start_date DESC LIMIT 1), 0), 2) AS "Стоимость продуктов", 
    ROUND(wd.delivery_cost, 2) AS "Стоимость доставки",
    ROUND(wd.delivery_cost + (wd.quantity * COALESCE((SELECT price_for_unit FROM ingredient_price_history WHERE ingredient_id = wd.ingredient_id AND status = 'active' ORDER BY start_date DESC LIMIT 1), 0)), 2) AS "Итоговая сумма"
FROM warehouse_deliveries wd
JOIN suppliers s ON wd.supplier_id = s.id
JOIN ingredients i ON wd.ingredient_id = i.id
ORDER BY "Итоговая сумма" DESC
LIMIT 5;

-- 29. Кол-во списанного или находящегося в ремонте оборудования
SELECT COUNT(*) AS "Ремонт/списанное оборудование"
FROM equipment_units
WHERE status IN ('written_off', 'in_repair');

-- 30. Топ-5 работников, произведших больше всего продукции за всё время (через CTE)
WITH top_workers AS (
    SELECT employee_id, SUM(quantity) AS total_quantity
    FROM production_batches
    WHERE status = 'ready'
    GROUP BY employee_id
    ORDER BY total_quantity DESC
    LIMIT 5
)
SELECT e.fullname AS "ФИО", tw.total_quantity AS "Кол-во продукции", e.position AS "Должность"
FROM employees e
JOIN top_workers tw ON tw.employee_id = e.id;

-- 31.1 Остаток ингредиентов на складе на сегодняшний день,
-- сортировка по срочности срока годности
SELECT 
    i.name AS "Ингредиент",
   	SUM(ii.quantity) AS "Остаток на складе",
	i.unit_type AS "Ед. измерения", 
	ii.expiration_date AS "Срок годности", 
	ii.expiration_date - CURRENT_DATE AS "Дней осталось"
FROM inventory_ingredients ii
JOIN ingredients i ON ii.ingredient_id = i.id
WHERE ii.expiration_date >= CURRENT_DATE
GROUP BY i.name, i.unit_type, ii.expiration_date
HAVING SUM(ii.quantity) > 0
ORDER BY SUM(ii.expiration_date - CURRENT_DATE) ASC;


-- 31.2 Остаток продуктов на складе на сегодняшний день, 
-- сортировка по срочности срока годности
SELECT 
    p.name AS "Продукт",
    pc.name AS "Категория",
    SUM(ip.quantity) AS "Остаток на складе (шт)",
	ip.expiration_date AS "Срок годности",
	ip.expiration_date - CURRENT_DATE AS "Дней осталось"
FROM inventory_products ip
JOIN products p ON ip.product_id = p.id
JOIN product_categories pc ON p.category_id = pc.id
WHERE ip.expiration_date >= CURRENT_DATE
GROUP BY p.name, pc.name, ip.expiration_date
HAVING SUM(ip.quantity) > 0
ORDER BY SUM(ip.expiration_date - CURRENT_DATE) ASC;