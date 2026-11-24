# ТЕХНИЧЕСКАЯ ДОКУМЕНТАЦИЯ: БАЗА ДАННЫХ «СЕТЬ ПЕКАРЕН»

- **Количество таблиц:** 33
- **Бизнес-блоков:** 6
- **Собственных ENUM типов:** 9

---

## ГЛАВНОЕ НАЗНАЧЕНИЕ БД
Автоматизация полного цикла работы сети пекарен — от закупки ингредиентов у поставщиков до продажи готовой продукции клиентам, с полным контролем качества, финансов, персонала и оборудования.

> **Ключевая ценность:** Система превращает разрозненные бизнес-процессы в единую управляемую экосистему, где каждое действие фиксируется, анализируется и оптимизируется.

---

## ПРЕИМУЩЕСТВА СИСТЕМЫ
1. **Полная прозрачность бизнеса:** Каждое действие фиксируется — от закупки муки до продажи круассана. Руководство видит всю картину в реальном времени.
2. **Автоматизация контроля:** Система сама блокирует просроченные медкнижки, сигнализирует о низких остатках, напоминает о ТО оборудования.
3. **Защита от потерь:** Контроль воровства на кухне, хищений на складах, ошибок кассиров. Каждое списание обосновано и задокументировано.
4. **Единое качество:** Все пекарни готовят по одним рецептам, соблюдают одни стандарты хранения. Клиент получает одинаковый продукт в любой точке сети.
5. **Аналитика и оптимизация:** Система показывает, какие продукты приносят больше прибыли, какие поставщики надёжнее, какие пекарни эффективнее.
6. **Масштабируемость:** Архитектура позволяет легко добавлять новые пекарни, склады, сотрудников без перестройки системы.

---

## ENUM ТИПЫ

1. **`defects_status`** — Статус обработки брака
   - **Где используется:** таблица `delivery_defects`
   - **Что описывает:** На каком этапе находится обработка обнаруженного брака при поставке.
   - **Значения:**
     1. `not_processed` — Брак только что обнаружен, ещё никто не начал с ним работать. «Лежит и ждёт внимания»
     2. `in_processing` — Сотрудник уже разбирается с браком: составляет акт, связывается с поставщиком, решает, что делать с товаром
     3. `processed` — Брак полностью обработан: оформлены документы, выставлены претензии поставщику, товар утилизирован или возвращён
   - **Жизненный цикл:** `not_processed` → `in_processing` → `processed`

2. **`defects_type`** — Тип дефекта
   - **Где используется:** таблица `delivery_defects`
   - **Что описывает:** На каком этапе возник брак — это важно, чтобы понять, кто виноват (поставщик, транспортная компания или склад).
   - **Значения:**
     1. `manufacturing` — Производственный брак. Товар уже был испорчен на заводе поставщика (например, мука пришла с жучками, а сахар — с комками). Виноват поставщик.
     2. `transit` — Брак при транспортировке. Товар испортился по дороге (например, шоколад растаял в фуре, стекло разбилось). Виновата транспортная компания.
     3. `warehouse` — Брак на складе. Товар испортился уже у нас на складе (например, из-за неправильной температуры в холодильнике). Виноваты наши кладовщики.
   - **Зачем нужно:** Чтобы понимать, с кем работать — менять поставщика, жаловаться на транспортников или обучать своих сотрудников.

3. **`classic_status`** — Классический статус «активен/неактивен»
   - **Где используется:** таблица `ingredients_price_history`
   - **Что описывает:** Универсальный переключатель "включено/выключено" для записей, которые могут быть актуальными или устаревшими.
   - **Значения:**
     1. `active` — Запись актуальна и используется в работе. Например, текущая цена ингредиента.
     2. `inactive` — Запись устарела и больше не применяется. Например, старая цена, которая уже не действует.
   - **Зачем нужно:** Чтобы хранить историю, но не путать старые данные с актуальными.

4. **`pp_status`** — Статус плана производства
   - **Где используется:** таблица `production_plans`
   - **Что описывает:** На каком этапе находится план производства на день.
   - **Значения:**
     1. `in_progress` — План создан, производство идёт. Пекари уже начали готовить продукцию по этому плану.
     2. `completed` — План полностью выполнен. Всё, что было запланировано, произведено.
     3. `not_completed` — План не выполнен в срок. Например, не хватило ингредиентов или сломалась печь. Это сигнал для руководителя — нужно разбираться, почему.
   - **Жизненный цикл:** `in_progress` → `completed` или `not_completed`

5. **`sp_status`** — Статус выплаты зарплаты
   - **Где используется:** таблица `salary_payments`
   - **Что описывает:** На каком этапе находится выплата зарплаты сотруднику за расчётный период.
   - **Значения:**
     1. `in_progress` — Бухгалтерия считает зарплату: проверяет отработанные часы, премии, налоги. Деньги ещё не выплачены.
     2. `completed` — Зарплата полностью начислена и выплачена сотруднику. Все документы оформлены.
     3. `not_completed` — Выплата по какой-то причине не состоялась (например, сотрудник уволился в процессе расчёта или возникла ошибка в данных). Требует внимания бухгалтера.
   - **Жизненный цикл:** `in_progress` → `completed` или `not_completed`

6. **`maintenance_type`** — Тип технического обслуживания
   - **Где используется:** таблица `equipment_maintenance`
   - **Что описывает:** Какой именно вид работ проводится с оборудованием.
   - **Значения:**
     1. `preventive` — Профилактика. Плановые работы, чтобы оборудование не сломалось (например, чистка печи, смазка механизмов). Делается регулярно, даже если всё работает.
     2. `repair` — Ремонт. Оборудование сломалось, и его чинят. Это внеплановые работы, которые стоят дороже профилактики.
     3. `inspection` — Проверка/осмотр. Специалист приходит, проверяет оборудование, составляет акт. Ничего не чинит, просто оценивает состояние.
     4. `calibration` — Калибровка. Точная настройка оборудования (например, весов или термометров), чтобы оно показывало правильные значения. Важно для точности рецептов.
   - **Зачем нужно:** Чтобы понимать, на какие виды работ уходят деньги, и планировать бюджет.

7. **`maintenance_status`** — Статус технического обслуживания
   - **Где используется:** таблица `equipment_maintenance`
   - **Что описывает:** На каком этапе находится работа по обслуживанию оборудования.
   - **Значения:**
     1. `planned` — Работа запланирована на будущую дату. Мастер ещё не приезжал, но всё согласовано.
     2. `in_progress` — Мастер уже на месте и выполняет работу. Оборудование может быть выведено из строя.
     3. `completed` — Работа успешно завершена. Оборудование снова в строю.
     4. `cancelled` — Работа отменена (например, оборудование продали, или решили сделать позже).
   - **Жизненный цикл:** `planned` → `in_progress` → `completed` (или `cancelled` на любом этапе)

8. **`loyalty_level`** — Уровень карты лояльности
   - **Где используется:** таблица `loyalty_cards`
   - **Что описывает:** Статус клиента в программе лояльности. Чем больше покупок — тем выше уровень и больше бонусов.
   - **Значения:**
     1. `bronze` (бронза) — Начальный уровень. Множитель начисления баллов: х1.00. Клиент только что получил карту.
     2. `silver` (серебро) — Клиент уже сделал несколько покупок. Множитель: х1.20 (на 20% больше баллов за каждую покупку).
     3. `gold` (золото) — Активный покупатель. Множитель: х1.50 (на 50% больше баллов).
     4. `platinum` (платина) — VIP-клиент, самый преданный покупатель. Множитель: x2.00 (в 2 раза больше баллов) + максимальные привилегии.
   - **Зачем нужно:** Мотивировать клиентов покупать больше и чаще — ради перехода на следующий уровень.

9. **`card_status`** — Статус карты лояльности
   - **Где используется:** таблица `loyalty_cards`
   - **Что описывает:** Текущее состояние карты клиента — можно ли ей пользоваться.
   - **Значения:**
     1. `active` — Карта активна, клиент может копить и тратить баллы. Всё в порядке.
     2. `blocked` — Карта заблокирована (например, клиент потерял карту, или его заподозрили в мошенничестве). Баллы сохраняются, но пользоваться картой нельзя.
     3. `expired` — Срок действия карты истёк. Клиент давно не делал покупок, и карта "сгорела". Нужно выпустить новую.
   - **Зачем нужно:** Чтобы контролировать, какие карты работают, а какие нет, и не начислять бонусы на недействительные карты.

---

## БИЗНЕС-БЛОКИ

### БЛОК 1: СПРАВОЧНИКИ И КАТАЛОГИ
- **Бизнес-функция:** Единая система классификации продукции и сырья
- **Зачем нужна:** Создаёт фундамент для всех бизнес-процессов — без чёткой классификации невозможно ни продавать, ни производить, ни анализировать.
- **Какие проблемы решает:**
  1. Структурирует ассортимент — все продукты разбиты по категориям (хлеб, выпечка, торты), что позволяет анализировать выручку по категориям
  2. Контролирует качество сырья — каждый ингредиент имеет характеристики хранения (температура), аллергены, страну происхождения
  3. Автоматизирует маркировку — штрих-коды для ингредиентов и продуктов позволяют работать со сканерами на кассе и складе
  4. Защищает от аллергических реакций — поле `allergen_info` позволяет автоматически предупреждать клиентов об аллергенах
- **Таблицы блока:** `product_categories`, `ingredients`, `products`

### БЛОК 2: ЗАКУПКИ И ПОСТАВКИ
- **Бизнес-функция:** Управление взаимоотношениями с поставщиками и контроль поставок
- **Зачем нужна:** Обеспечивает пекарню сырьём, контролирует качество поставок и стоимость закупок.
- **Какие проблемы решает:**
  1. Выбирает надёжных поставщиков — показывает рейтинг, наличие лицензии, статус контракта позволяют оценивать партнёров
  2. Контролирует условия поставок — даты отправки/получения, стоимость доставки, тип транспорта
  3. Выявляет брак при приёмке — таблица `delivery_defects` фиксирует дефекты с указанием типа (брак производства/транспорта/склада)
  4. Анализирует динамику цен — `ingredients_price_history` показывает, как менялись закупочные цены, позволяет планировать бюджет
  5. Защищает от мошенничества — ИНН поставщика (`tin`) уникален, нельзя создать дубликат
- **Таблицы блока:** `suppliers`, `supplier_ingredients`, `warehouse_deliveries`, `delivery_defects`, `ingredients_price_history`

### БЛОК 3: СТРУКТУРА СЕТИ И СКЛАДСКАЯ ЛОГИСТИКА
- **Бизнес-функция:** Управление торговой сетью и контроль остатков
- **Зачем нужна:** Организует физическую структуру сети (пекарни + склады) и обеспечивает точный учёт товаров.
- **Какие проблемы решает:**
  1. Контролирует эффективность точек — рейтинг, площадь, аренда позволяют сравнивать прибыльность каждой пекарни
  2. Разделяет учёт остатков — центральный склад получает поставки от поставщиков, локальные склады пекарен получают товары с центрального
  3. Соблюдает санитарные нормы — контроль температурного режима на складах (`min_temperature`, `max_temperature`)
  4. Предотвращает списание просрочки — система отслеживает `expiration_date` и автоматически сигнализирует о необходимости списания
  5. Планирует закупки — зная текущие остатки, система может рекомендовать, что нужно заказать
- **Таблицы блока:** `bakeries`, `warehouses`, `inventory_ingredients`, `inventory_products`, `write_offs`

### БЛОК 4: ПРОИЗВОДСТВО И ПЛАНИРОВАНИЕ
- **Бизнес-функция:** Управление производственным циклом и контроль себестоимости
- **Зачем нужна:** Обеспечивает единое качество продукции во всех точках сети и точный расчёт себестоимости.
- **Какие проблемы решает:**
  1. Гарантирует единый вкус — рецепты (`recipes`) хранят точные пропорции ингредиентов, все пекарни готовят по одним стандартам
  2. Исключает воровство — система точно знает, сколько муки должно уйти на 100 круассанов. Если фактический расход больше — это сигнал
  3. Планирует загрузку пекарен — `production_plans` содержит план производства на каждый день с дедлайнами
  4. Контролирует выполнение плана — статус (`completed`/`in_progress`/`not_completed`) показывает, успеваем ли мы
  5. Рассчитывает себестоимость — `cost_products` хранит затраты на производство, позволяет считать реальную прибыль
- **Таблицы блока:** `recipes`, `production_plans`, `production_batches`, `cost_products`, `equipment_units`, `equipment_maintenance`

### БЛОК 5: ПРОДАЖИ И РАБОТА С КЛИЕНТАМИ
- **Бизнес-функция:** Управление продажами, возвратами и программой лояльности
- **Зачем нужна:** Фиксирует все транзакции, обрабатывает возвраты, удерживает клиентов через программу лояльности.
- **Какие проблемы решает:**
  1. Контролирует выручку — каждая продажа фиксируется с указанием кассира, пекарни, способа оплаты
  2. Анализирует структуру чека — `sale_items` показывает, что именно купил клиент, позволяет анализировать популярные товары
  3. Обрабатывает возвраты — `returns` привязывает возврат к конкретной продаже, контролирует сумму возврата
  4. Удерживает клиентов — многоуровневая система лояльности (бронза → серебро → золото → платина) мотивирует покупать больше
  5. Персонализирует предложения — анализ любимой категории клиента позволяет делать целевые акции
  6. Автоматизирует birthday-маркетинг — скидка в день рождения повышает лояльность
  7. Защищает от ошибок — баланс бонусов всегда сходится: `total_points = earned_points - spent_points`
- **Таблицы блока:** `customers`, `loyalty_cards`, `discounts`, `sales`, `sale_details`, `returns`, `price_history`, `customer_complaints`

### БЛОК 6: УПРАВЛЕНИЕ ПЕРСОНАЛОМ (HR)
- **Бизнес-функция:** Полный цикл управления сотрудниками — от найма до увольнения
- **Зачем нужна:** Контролирует допуск к работе, планирует графики, рассчитывает зарплату, обеспечивает соблюдение трудового законодательства.
- **Какие проблемы решает:**
  1. Защищает от штрафов — автоматически блокирует допуск к производству сотрудников с истекшими медкнижками
  2. Предотвращает хищения — система знает, кто именно имел доступ к складу в момент списания товара
  3. Автоматизирует составление графиков — `work_schedules` учитывает рабочие дни, выходные, больничные, отпуска
  4. Соблюдает трудовое законодательство — контроль перерывов (`break_duration_minutes`), учёт отпусков
  5. Рассчитывает зарплату автоматически — оклад + премия + налоги = итого
  6. Контролирует ФОТ по точкам — можно посчитать расходы на персонал для каждой пекарни отдельно
- **Таблицы блока:** `employees`, `medical_books`, `warehouse_access`, `work_schedules`, `vacations`, `salary_payments`

---

## СВЯЗИ МЕЖДУ БЛОКАМИ
**Ключевые бизнес-цепочки:**
- **Цепочка 1: Закупка → Склад → Производство → Продажа**  
  *Бизнес-смысл:* Полный цикл движения товара от поставщика до клиента
- **Цепочка 2: План → Факт → Анализ**  
  *Бизнес-смысл:* Сравнение запланированного с фактическим, расчёт отклонений
- **Цепочка 3: Клиент → Покупка → Лояльность**  
  *Бизнес-смысл:* Накопление баллов, повышение уровня, персональные предложения
- **Цепочка 4: Сотрудник → Допуск → Ответственность**  
  *Бизнес-смысл:* Контроль допуска к работе и материальная ответственность

---

## ОПИСАНИЕ ТАБЛИЦ

### БЛОК 1. СПРАВОЧНИКИ И КАТАЛОГИ

#### 1. `product_categories`
**Назначение:** Справочник категорий готовой продукции. Нужна для группировки товаров и аналитики продаж по категориям (хлеб, выпечка, торты).
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор категории
- `description`: TEXT — описание категории
- `name`: VARCHAR(40), NOT NULL, UNIQUE — название категории
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 2. `ingredients`
**Назначение:** Справочник ингредиентов (сырья), из которых производится продукция. Нужна для учёта условий хранения, аллергенов и расчёта себестоимости.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор ингредиента
- `name`: VARCHAR(40), NOT NULL, UNIQUE — название ингредиента
- `description`: TEXT — описание ингредиента
- `unit_type`: VARCHAR(15), NOT NULL — единица измерения (кг, л, шт.)
- `storage_temp_min`: DECIMAL(4,1), NOT NULL — минимальная температура хранения
- `storage_temp_max`: DECIMAL(4,1), NOT NULL — максимальная температура хранения
- `barcode`: VARCHAR(64), NOT NULL, UNIQUE — штрих-код ингредиента
- `allergen_info`: TEXT — информация об аллергенах
- `country_from_origin`: VARCHAR(65), NOT NULL — страна-производитель
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 3. `products`
**Назначение:** Справочник готовой продукции, которая продаётся клиентам. Используется на кассе для оформления чеков.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор продукта
- `name`: VARCHAR(40), NOT NULL, UNIQUE — название продукта
- `description`: TEXT — описание (состав, особенности)
- `price_for_customer`: DECIMAL(7,2), NOT NULL — цена для покупателя
- `lifespan_hours`: INTEGER, NOT NULL — срок годности в часах
- `age_restriction`: VARCHAR(3) — возрастное ограничение (0+, 18+)
- `category_id`: INTEGER, FK → `product_categories.id`, ON DELETE SET NULL — ID категории
- `barcode`: VARCHAR(64), NOT NULL — штрих-код продукта
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

### БЛОК 2. ЗАКУПКИ И ПОСТАВКИ

#### 4. `suppliers`
**Назначение:** Справочник компаний-поставщиков. Хранит контакты, репутацию и условия контрактов. Позволяет выбирать надёжных партнёров.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор поставщика
- `name_company`: VARCHAR(200), NOT NULL — название компании
- `license`: BOOLEAN, NOT NULL — наличие лицензии
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','inactive')) — статус контракта
- `email`: VARCHAR(254), UNIQUE — электронная почта
- `telephone_number`: VARCHAR(20), NOT NULL, UNIQUE — номер телефона
- `reputation`: DECIMAL(3,2) — рейтинг репутации
- `website`: VARCHAR(2048), UNIQUE — сайт компании
- `address`: VARCHAR(200) — юридический адрес
- `tin`: VARCHAR(12), NOT NULL, UNIQUE — ИНН компании
- `contract_date`: DATE, NOT NULL — дата подписания договора

#### 5. `supplier_ingredients`
**Назначение:** Связующая таблица M:N между поставщиками и ингредиентами. Один поставщик может продавать несколько ингредиентов, один ингредиент могут поставлять разные компании.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор связи
- `supplier_id`: INTEGER, FK → `suppliers.id`, ON DELETE CASCADE — ID поставщика
- `ingredient_id`: INTEGER, FK → `ingredients.id`, ON DELETE CASCADE — ID ингредиента

#### 6. `warehouse_deliveries`
**Назначение:** Факты поставок сырья на склады. Позволяет контролировать сроки, стоимость доставки и соответствие заявленному количеству.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор поставки
- `supplier_id`: INTEGER, FK → `suppliers.id`, ON DELETE RESTRICT — ID поставщика
- `ingredient_id`: INTEGER, FK → `ingredients.id`, ON DELETE RESTRICT — ID ингредиента
- `quantity`: DECIMAL(10,2) — количество поставленного сырья
- `date_dispatch`: DATE, NOT NULL — дата отправки
- `date_receipt`: DATE, NOT NULL — дата получения
- `type`: VARCHAR(25) — тип доставки (авто, ж/д и т.д.)
- `warehouse_id`: INTEGER, FK → `warehouses.id`, ON DELETE RESTRICT — ID склада приёмки
- `delivery_cost`: DECIMAL(10,2), NOT NULL — стоимость доставки

#### 7. `delivery_defects`
**Назначение:** Учёт брака при приёмке поставок. Позволяет фиксировать дефекты, их тип и предъявлять претензии поставщикам.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор дефекта
- `defect_type`: `defects_type` (ENUM), NOT NULL — тип дефекта (manufacturing/transit/warehouse)
- `quantity`: DECIMAL(8,2), NOT NULL, CHECK (quantity > 0) — количество бракованного товара
- `comment`: TEXT — комментарий к дефекту
- `defect_date`: TIMESTAMP, NOT NULL — дата обнаружения
- `delivery_id`: INTEGER, FK → `warehouse_deliveries.id`, ON DELETE CASCADE — ID поставки
- `ingredient_id`: INTEGER, FK → `ingredients.id`, ON DELETE CASCADE — ID ингредиента
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE SET NULL — ID сотрудника, выявившего брак
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи
- `status`: `defects_status` (ENUM), NOT NULL, DEFAULT 'in_processing' — статус обработки

#### 8. `ingredients_price_history`
**Назначение:** История изменения закупочных цен на ингредиенты. Позволяет анализировать динамику цен и прогнозировать бюджет.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `supplier_id`: INTEGER, FK → `suppliers.id`, ON DELETE SET NULL — ID поставщика
- `ingredient_id`: INTEGER, FK → `ingredients.id`, ON DELETE CASCADE — ID ингредиента
- `price_for_unit`: DECIMAL(8,2), NOT NULL, CHECK (price_for_unit >= 0) — цена за единицу
- `unit_type`: VARCHAR(30), NOT NULL — единица измерения цены
- `status`: `classic_status` (ENUM), NOT NULL, DEFAULT 'active' — статус записи
- `start_date`: TIMESTAMP, NOT NULL — дата начала действия цены
- `end_date`: TIMESTAMP — дата окончания действия цены
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

### БЛОК 3. СТРУКТУРА СЕТИ И СКЛАДЫ

#### 9. `bakeries`
**Назначение:** Справочник торговых точек сети. Хранит информацию о каждой пекарне для анализа эффективности и планирования.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор пекарни
- `name`: VARCHAR(40), NOT NULL — название пекарни
- `size`: DECIMAL(6,2), NOT NULL, CHECK (size > 0) — площадь помещения (м²)
- `rent`: DECIMAL(10,2), NOT NULL, CHECK (rent >= 0) — стоимость аренды
- `address`: VARCHAR(200), NOT NULL — адрес
- `rating`: DECIMAL(3,2) — рейтинг по отзывам
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','inactive','in_repair')) — статус работы
- `open_date`: DATE, NOT NULL — дата открытия
- `work_hours_start`: TIME, NOT NULL — время открытия
- `work_hours_end`: TIME, NOT NULL — время закрытия

#### 10. `warehouses`
**Назначение:** Справочник складов (локальных при пекарнях и центрального). Хранит параметры хранения и тип склада.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор склада
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE RESTRICT — ID пекарни
- `name`: VARCHAR(40) — название склада
- `size`: DECIMAL(6,2), NOT NULL, CHECK (size > 0) — площадь склада (м²)
- `max_temperature`: DECIMAL(4,1), NOT NULL — максимальная температура хранения
- `min_temperature`: DECIMAL(4,1), NOT NULL — минимальная температура хранения
- `status`: VARCHAR(9), NOT NULL, DEFAULT 'active', CHECK (status IN ('active','inactive','in_repair')) — статус склада
- `central_warehouse_flag`: BOOLEAN — флаг центрального склада
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 11. `inventory_ingredients`
**Назначение:** Остатки ингредиентов на складах с контролем сроков годности. Позволяет планировать производство и закупки.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `warehouse_id`: INTEGER, FK → `warehouses.id`, ON DELETE CASCADE — ID склада
- `ingredient_id`: INTEGER, FK → `ingredients.id`, ON DELETE SET NULL — ID ингредиента
- `quantity`: DECIMAL(8,2), NOT NULL — текущее количество
- `expiration_date`: DATE, NOT NULL — срок годности
- `date_last_update`: DATE — дата последнего обновления

#### 12. `inventory_products`
**Назначение:** Остатки готовой продукции на складах с контролем сроков годности. Учитывает скоропортящийся характер выпечки.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `warehouse_id`: INTEGER, FK → `warehouses.id`, ON DELETE CASCADE — ID склада
- `product_id`: INTEGER, FK → `products.id`, ON DELETE SET NULL — ID продукта
- `quantity`: DECIMAL(8,2), NOT NULL — текущее количество
- `expiration_date`: DATE, NOT NULL — срок годности
- `date_last_update`: DATE — дата последнего обновления

#### 13. `write_offs`
**Назначение:** Учёт списаний товаров (просрочка, брак, хищения). Позволяет контролировать потери и выявлять ответственных.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор списания
- `quantity`: DECIMAL(10,2), NOT NULL, CHECK (quantity >= 0) — количество списанного товара
- `cost_per_unit`: DECIMAL(8,2), NOT NULL — стоимость единицы
- `reason`: TEXT, NOT NULL — причина списания
- `date`: TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата списания
- `status`: VARCHAR, NOT NULL, CHECK (status IN ('completed','denied','in_progress')) — статус списания
- `product_id`: INTEGER, FK → `products.id`, ON DELETE SET NULL — ID продукта
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE SET NULL — ID ответственного сотрудника
- `warehouse_id`: INTEGER, FK → `warehouses.id`, ON DELETE SET NULL — ID склада
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

### БЛОК 4. ПРОИЗВОДСТВО И ПЛАНИРОВАНИЕ

#### 14. `recipes`
**Назначение:** Технологические карты (рецепты). Описывает точные пропорции ингредиентов для каждого продукта — основа единого качества.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `ingredient_id`: INTEGER, FK → `ingredients.id`, ON DELETE CASCADE — ID ингредиента
- `product_id`: INTEGER, FK → `products.id`, ON DELETE CASCADE — ID продукта
- `quantity`: DECIMAL(8,2), NOT NULL — количество ингредиента
- `instructions`: TEXT, NOT NULL — инструкция по приготовлению
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 15. `production_plans`
**Назначение:** Планы производства на каждый день. Позволяет планировать загрузку пекарен и закупку ингредиентов.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор плана
- `planned_date`: DATE, NOT NULL — плановая дата производства
- `deadline`: TIMESTAMP, NOT NULL — дедлайн выполнения
- `quantity`: DECIMAL(8,2), NOT NULL, CHECK (quantity > 0) — плановое количество
- `status`: `pp_status` (ENUM), NOT NULL, DEFAULT 'in_progress' — статус (completed/not_completed/in_progress)
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE CASCADE — ID пекарни
- `product_id`: INTEGER, FK → `products.id`, ON DELETE SET NULL — ID продукта
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE SET NULL — ID ответственного

#### 16. `production_batches`
**Назначение:** Факты производства. Фиксирует, кто, когда и сколько произвёл — основа для сравнения плана с фактом.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор партии
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE RESTRICT — ID пекарни
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE RESTRICT — ID пекаря
- `product_id`: INTEGER, FK → `products.id`, ON DELETE RESTRICT — ID продукта
- `quantity`: INTEGER, NOT NULL — количество произведённой продукции
- `production_date`: DATE — дата производства
- `production_time`: DECIMAL(6,2) — время производства (в минутах)
- `status`: VARCHAR, NOT NULL, DEFAULT 'ready', CHECK (status IN ('ready','in_production')) — статус

#### 17. `cost_products`
**Назначение:** История себестоимости и цены продажи продуктов. Позволяет рассчитывать реальную прибыль за любой период.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `product_id`: INTEGER, FK → `products.id`, ON DELETE SET NULL — ID продукта
- `effective_date`: DATE, NOT NULL — дата вступления цены в силу
- `end_date`: DATE — дата окончания действия цены
- `production_cost`: DECIMAL(8,2), NOT NULL, CHECK (production_cost >= 0) — себестоимость
- `selling_price`: DECIMAL(8,2), NOT NULL — цена продажи
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 18. `equipment_units`
**Назначение:** Справочник оборудования (печи, холодильники, миксеры). Позволяет планировать ремонты и контролировать износ.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор оборудования
- `type`: VARCHAR(25), NOT NULL — тип оборудования
- `description`: TEXT — техническое описание
- `name`: VARCHAR(25), NOT NULL — название
- `service_life`: INTEGER, NOT NULL — срок службы (в месяцах)
- `warranty_period`: INTEGER, NOT NULL — гарантийный срок (в месяцах)
- `last_maintenance_date`: DATE, NOT NULL — дата последнего ТО
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','written_off','in_repair')) — статус
- `brand`: TEXT, NOT NULL — бренд производителя
- `purchase_date`: DATE — дата покупки
- `warehouse_id`: INTEGER, FK → `warehouses.id`, ON DELETE SET NULL — ID склада размещения

#### 19. `equipment_maintenance`
**Назначение:** Журнал технического обслуживания оборудования. Фиксирует все работы (профилактика, ремонт, калибровка) и их стоимость.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `executing_company`: VARCHAR(100), NOT NULL — название обслуживающей компании
- `master_name`: VARCHAR(50), NOT NULL — ФИО мастера
- `master_phone`: VARCHAR(12) — телефон мастера
- `work_order_number`: VARCHAR(10) — номер заказа-наряда
- `equipment_id`: INTEGER, FK → `equipment_units.id`, ON DELETE CASCADE — ID оборудования
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE RESTRICT — ID пекарни
- `maintenance_type`: `maintenance_type` (ENUM), NOT NULL — тип работ (preventive/repair/inspection/calibration)
- `status`: `maintenance_status` (ENUM), NOT NULL, DEFAULT 'planned' — статус (planned/in_progress/completed/cancelled)
- `planned_date`: DATE, NOT NULL — плановая дата ТО
- `actual_date`: DATE — фактическая дата ТО
- `description`: TEXT, NOT NULL — описание работ
- `cost`: DECIMAL(10,2), NOT NULL, CHECK (cost >= 0) — стоимость работ
- `next_maintenance_date`: DATE — дата следующего ТО
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи
- `CONSTRAINT check_dates`: CHECK (actual_date IS NULL OR actual_date >= planned_date) — проверка дат

### БЛОК 5. ПРОДАЖИ И КЛИЕНТЫ

#### 20. `customers`
**Назначение:** Справочник покупателей. Хранит контактные данные для программы лояльности и анализа поведения клиентов.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор клиента
- `fullname`: VARCHAR(50), NOT NULL — ФИО клиента
- `telephone_number`: VARCHAR(20), NOT NULL, UNIQUE — номер телефона
- `email`: VARCHAR(254), UNIQUE — электронная почта
- `passport_data`: TEXT, UNIQUE — паспортные данные
- `registration_date`: DATE — дата регистрации
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','inactive','blocked')) — статус
- `date_birthday`: DATE — дата рождения (для birthday-скидок)

#### 21. `loyalty_cards`
**Назначение:** Карты лояльности с многоуровневой системой (бронза → серебро → золото → платина). Основа CRM-системы.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор карты
- `customer_id`: INTEGER, UNIQUE, FK → `customers.id`, ON DELETE CASCADE — ID клиента
- `favorite_category_id`: INTEGER, FK → `product_categories.id`, ON DELETE SET NULL — ID любимой категории
- `card_number`: VARCHAR(19), NOT NULL, UNIQUE — номер карты
- `issue_date`: DATE, NOT NULL, DEFAULT CURRENT_DATE — дата выпуска
- `activation_date`: DATE — дата активации
- `expiration_date`: DATE — срок действия
- `total_points`: INTEGER, NOT NULL, DEFAULT 0, CHECK (total_points >= 0) — текущий баланс баллов
- `earned_points`: INTEGER, NOT NULL, DEFAULT 0, CHECK (earned_points >= 0) — всего заработано баллов
- `spent_points`: INTEGER, NOT NULL, DEFAULT 0, CHECK (spent_points >= 0) — всего потрачено баллов
- `level`: `loyalty_level` (ENUM), NOT NULL, DEFAULT 'bronze' — уровень карты
- `points_multiplier`: DECIMAL(3,2), NOT NULL, DEFAULT 1.00, CHECK (points_multiplier >= 1.00) — множитель начисления
- `points_to_ruble`: DECIMAL(5,2), NOT NULL, DEFAULT 1.00, CHECK (points_to_ruble > 0) — курс баллов к рублю
- `purchase_count`: INTEGER, NOT NULL, DEFAULT 0, CHECK (purchase_count >= 0) — количество покупок
- `last_purchase_date`: TIMESTAMP — дата последней покупки
- `birthday_discount_percent`: DECIMAL(5,2), DEFAULT 10.00, CHECK (birthday_discount_percent >= 0) — скидка в ДР
- `status`: `card_status` (ENUM), NOT NULL, DEFAULT 'active' — статус карты
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи
- `CONSTRAINT check_dates`: CHECK (activation_date IS NULL OR activation_date >= issue_date)
- `CONSTRAINT check_expiration`: CHECK (expiration_date IS NULL OR expiration_date > issue_date)
- `CONSTRAINT check_points_balance`: CHECK (total_points = earned_points - spent_points)

#### 22. `discounts`
**Назначение:** Справочник скидок и акций. Управляет ценообразованием и стимулирует продажи.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор скидки
- `name`: VARCHAR(40) — название скидки
- `description`: TEXT — описание для клиента
- `value`: DECIMAL(8,2), NOT NULL — значение скидки
- `type`: VARCHAR(20), NOT NULL — тип (рубли/проценты)
- `start_date`: DATE, NOT NULL — дата начала действия
- `end_date`: DATE, NOT NULL — дата окончания действия
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','inactive')) — статус
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 23. `sales`
**Назначение:** Факты продаж (чеки). Основа для расчёта выручки и контроля кассиров.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор продажи
- `customer_id`: INTEGER, FK → `customers.id`, ON DELETE SET NULL — ID клиента
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE RESTRICT — ID кассира
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE RESTRICT — ID пекарни
- `date`: DATE, NOT NULL — дата продажи
- `payment_method`: VARCHAR(30), NOT NULL — способ оплаты
- `total_amount`: DECIMAL(8,2), NOT NULL — итоговая сумма чека
- `status`: VARCHAR, NOT NULL, DEFAULT 'completed', CHECK (status IN ('completed','not_completed')) — статус

#### 24. `sale_details`
**Назначение:** Позиции в чеке. Позволяет анализировать структуру продаж и эффективность скидок.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор позиции
- `sale_id`: INTEGER, FK → `sales.id`, ON DELETE CASCADE — ID продажи
- `product_id`: INTEGER, FK → `products.id`, ON DELETE RESTRICT — ID продукта
- `quantity`: DECIMAL(8,2), NOT NULL — количество товара
- `total_per_item`: DECIMAL(8,2) — сумма по позиции
- `discount_id`: INTEGER, FK → `discounts.id`, ON DELETE RESTRICT — ID применённой скидки
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 25. `returns`
**Назначение:** Учёт возвратов товаров. Позволяет контролировать качество и анализировать причины возвратов.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор возврата
- `sale_id`: INTEGER, FK → `sales.id`, ON DELETE RESTRICT — ID исходной продажи
- `sale_detail_id`: INTEGER, FK → `sale_details.id`, ON DELETE SET NULL — ID позиции в чеке
- `product_id`: INTEGER, FK → `products.id`, ON DELETE RESTRICT — ID возвращаемого продукта
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE RESTRICT — ID сотрудника, принявшего возврат
- `customer_id`: INTEGER, FK → `customers.id`, ON DELETE SET NULL — ID клиента
- `reason`: TEXT — причина возврата
- `return_date`: DATE, NOT NULL — дата возврата
- `refund_amount`: DECIMAL(8,2), NOT NULL — сумма возврата
- `status`: VARCHAR, NOT NULL, DEFAULT 'completed', CHECK (status IN ('completed','not_completed')) — статус

#### 26. `price_history`
**Назначение:** История изменения розничных цен. Позволяет анализировать ценовую политику и причины изменений.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `date_change`: TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата изменения
- `new_price`: DECIMAL(8,2), NOT NULL, CHECK (new_price >= 0) — новая цена
- `old_price`: DECIMAL(8,2), NOT NULL, CHECK (old_price >= 0) — старая цена
- `reason`: TEXT — причина изменения
- `effective_date`: DATE, NOT NULL — дата вступления в силу
- `status`: VARCHAR, NOT NULL, CHECK (status IN ('active','inactive')) — статус
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE SET NULL — ID пекарни
- `product_id`: INTEGER, FK → `products.id`, ON DELETE SET NULL — ID продукта
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

#### 27. `customer_complaints`
**Назначение:** Учёт жалоб клиентов. Позволяет быстро реагировать на проблемы и защищать репутацию бренда.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор жалобы
- `customer_id`: INTEGER, FK → `customers.id` — ID клиента
- `bakery_id`: INTEGER, NOT NULL, FK → `bakeries.id` — ID пекарни
- `sale_id`: INTEGER, FK → `sales.id` — ID связанной продажи
- `complaint_type`: VARCHAR, NOT NULL, CHECK (complaint_type IN ('hygiene','quality','service','expectation')) — тип жалобы
- `description`: TEXT, NOT NULL — описание жалобы
- `severity`: VARCHAR, NOT NULL, CHECK (severity IN ('low','medium','high','critical')) — серьёзность
- `status`: VARCHAR(20), NOT NULL, DEFAULT 'open', CHECK (status IN ('open','completed')) — статус
- `incident_date`: TIMESTAMP, NOT NULL — дата инцидента
- `created_at`: TIMESTAMPTZ, NOT NULL, DEFAULT CURRENT_TIMESTAMP — дата создания записи

### БЛОК 6. ПЕРСОНАЛ (HR)

#### 28. `employees`
**Назначение:** Справочник сотрудников. Хранит личные данные, должности, оклады и привязку к пекарне.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор сотрудника
- `fullname`: VARCHAR(50) — ФИО сотрудника
- `telephone_number`: VARCHAR(20), NOT NULL, UNIQUE — номер телефона
- `email`: VARCHAR(254), NOT NULL, UNIQUE — электронная почта
- `passport_data`: TEXT, UNIQUE — паспортные данные
- `date_birthday`: DATE, NOT NULL — дата рождения
- `start_date`: DATE, NOT NULL — дата приёма на работу
- `position`: VARCHAR(25), NOT NULL — должность
- `base_salary`: DECIMAL(10,2), NOT NULL, CHECK (base_salary > 0) — оклад
- `bonus`: DECIMAL(10,2), NOT NULL — премия
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','dismissed','on_leave')) — статус
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE SET NULL — ID пекарни
- `education`: TEXT — образование

#### 29. `medical_books`
**Назначение:** Учёт медицинских книжек сотрудников. Автоматически блокирует допуск к производству при просрочке.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE CASCADE — ID сотрудника
- `medical_record_number`: VARCHAR(8), NOT NULL, UNIQUE — номер медкнижки
- `issue_date`: DATE, NOT NULL — дата выдачи
- `validity_period`: INTEGER, NOT NULL — срок действия (в месяцах)
- `status`: VARCHAR, NOT NULL, DEFAULT 'active', CHECK (status IN ('active','overdue')) — статус

#### 30. `warehouse_access`
**Назначение:** Права доступа сотрудников к складам. Обеспечивает сохранность товаров и предотвращает хищения.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `warehouse_id`: INTEGER, FK → `warehouses.id`, ON DELETE CASCADE — ID склада
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE CASCADE — ID сотрудника
- `access_level`: TEXT, NOT NULL — уровень доступа

#### 31. `work_schedules`
**Назначение:** Графики работы сотрудников. Учитывает рабочие дни, выходные, больничные и отпуска.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE SET NULL — ID сотрудника
- `start_date`: TIMESTAMP, NOT NULL — начало смены/периода
- `end_date`: TIMESTAMP, NOT NULL — конец смены/периода
- `break_duration_minutes`: INTEGER, NOT NULL — длительность перерыва (минуты)
- `tip_day`: VARCHAR, NOT NULL, CHECK (tip_day IN ('day_off','worker','disease','vacation')) — тип дня

#### 32. `vacations`
**Назначение:** Учёт отпусков сотрудников по годам. Помогает планировать замену на время отсутствия.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор записи
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE SET NULL — ID сотрудника
- `year`: VARCHAR(4), NOT NULL — год отпуска
- `type`: VARCHAR(30), NOT NULL — тип отпуска
- `start_date`: TIMESTAMP, NOT NULL — дата начала
- `end_date`: TIMESTAMP, NOT NULL — дата окончания
- `day_count`: INTEGER, NOT NULL — количество дней
- `status`: VARCHAR, NOT NULL, CHECK (status IN ('active','inactive')) — статус

#### 33. `salary_payments`
**Назначение:** Начисления и выплаты зарплаты. Автоматически рассчитывает итоговую сумму с учётом оклада, премии и налогов.
- `id`: SERIAL, PRIMARY KEY — уникальный идентификатор выплаты
- `employee_id`: INTEGER, FK → `employees.id`, ON DELETE SET NULL — ID сотрудника
- `bakery_id`: INTEGER, FK → `bakeries.id`, ON DELETE RESTRICT — ID пекарни
- `start_billing_period`: DATE, NOT NULL — начало расчётного периода
- `end_billing_period`: DATE, NOT NULL — конец расчётного периода
- `base_amount`: DECIMAL(10,2), NOT NULL, CHECK (base_amount >= 0) — оклад за период
- `bonus_amount`: DECIMAL(10,2), NOT NULL, DEFAULT 0, CHECK (bonus_amount >= 0) — премия
- `taxes_amount`: DECIMAL(10,2), NOT NULL, CHECK (taxes_amount >= 0) — налоги
- `total_amount`: DECIMAL(10,2), NOT NULL, CHECK (total_amount >= 0) — итоговая сумма
- `status`: `sp_status` (ENUM), NOT NULL, DEFAULT 'completed' — статус выплаты
- `payment_date`: DATE, NOT NULL, DEFAULT CURRENT_DATE — дата выплаты
- `CONSTRAINT check_periods`: CHECK (end_billing_period >= start_billing_period)
- `CONSTRAINT total_amount_check`: CHECK (total_amount = base_amount + bonus_amount + taxes_amount)

---

## ОПТИМИЗАЦИЯ ПРОИЗВОДИТЕЛЬНОСТИ И ИНДЕКСАЦИЯ

Для обеспечения высокой скорости отклика системы при росте объема данных (масштабировании сети пекарен) в базе данных применена продуманная стратегия индексации.

Поскольку подавляющее большинство бизнес-операций (формирование чека, анализ остатков, расчет заработной платы, сверка планов производства) строятся на операциях объединения таблиц (JOIN), на все внешние ключи (Foreign Keys) созданы отдельные B-Tree индексы. Это гарантирует, что время выполнения основных запросов останется в пределах миллисекунд даже при миллионах записей в таблицах `sales` и `production_batches`.

Индексы логически сгруппированы по бизнес-доменам:
1. **Оптимизация продаж и работы с клиентами (CRM)**
   - *Индексы:* `idx_sales_*`, `idx_sale_details_*`, `idx_returns_*`, `idx_loyalty_cards_*`
   - *Бизнес-ценность:* Обеспечивают мгновенный поиск истории покупок конкретного клиента, быстрое формирование состава чека на кассе и моментальный расчет бонусов лояльности без блокировки таблицы продаж.
2. **Оптимизация складского учета и логистики**
   - *Индексы:* `idx_inventory_ingredients_*`, `idx_inventory_products_*`, `idx_warehouse_deliveries_*`
   - *Бизнес-ценность:* Позволяют кладовщикам и системе мгновенно проверять остатки конкретного ингредиента или продукта на конкретном складе, а также быстро формировать историю поставок от выбранного поставщика.
3. **Оптимизация производственных процессов**
   - *Индексы:* `idx_production_batches_*`, `idx_production_plans_*`, `idx_equipment_maintenance_*`
   - *Бизнес-ценность:* Критически важны для ежедневного сравнения плана и факта производства. Ускоряют фильтрацию выпущенных партий по дате, пекарне или конкретному продукту.
4. **Оптимизация HR-процессов и финансов**
   - *Индексы:* `idx_employees_*`, `idx_work_schedules_*`, `idx_salary_payments_*`, `idx_medical_books_*`
   - *Бизнес-ценность:* Обеспечивают быстрый расчет графиков смен и начисление заработной платы по конкретному сотруднику или пекарне, не сканируя всю таблицу персонала.
5. **Оптимизация контроля качества и ценообразования**
   - *Индексы:* `idx_customer_complaints_*`, `idx_price_history_*`, `idx_write_offs_*`
   - *Бизнес-ценность:* Позволяют службе качества и финансовому отделу мгновенно агрегировать жалобы по конкретным точкам или отслеживать историю изменения цен на конкретный продукт.

> **Примечание:** Полный DDL-скрипт создания всех 40+ индексов вынесен в отдельный файл инициализации базы данных (`schema.sql`) для поддержания чистоты и читаемости основной структуры таблиц.

