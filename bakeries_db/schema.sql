-- ============================================
-- Файл:    schema.sql
-- Проект:  БД «Сеть пекарен»
-- СУБД:    PostgreSQL 18+
-- Объекты: 9 ENUM-типов, 33 таблицы, 55+ индексов
-- Автор:   [Назаров Никита], группа [РПО 24/3]
-- Дата:    12.11.2026
-- ============================================
BEGIN;

CREATE TYPE defects_status AS ENUM ('processed', 'in_processing', 'not_processed');
CREATE TYPE defects_type AS ENUM ('manufacturing', 'transit', 'warehouse');
CREATE TYPE classic_status AS ENUM ('active', 'inactive');
CREATE TYPE pp_status AS ENUM ('completed', 'not_completed', 'in_progress');
CREATE TYPE sp_status AS ENUM ('completed', 'not_completed', 'in_progress');
CREATE TYPE maintenance_type AS ENUM ('preventive', 'repair', 'inspection', 'calibration');
CREATE TYPE maintenance_status AS ENUM ('planned', 'in_progress', 'completed', 'cancelled');
CREATE TYPE loyalty_level AS ENUM ('bronze', 'silver', 'gold', 'platinum');
CREATE TYPE card_status AS ENUM ('active', 'blocked', 'expired');



CREATE TABLE product_categories
(
	id SERIAL PRIMARY KEY,
	description TEXT,
	name VARCHAR(40) NOT NULL UNIQUE,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE ingredients
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL UNIQUE,
	description TEXT,
	unit_type VARCHAR(15) NOT NULL,
	storage_temp_min DECIMAL(4, 1) NOT NULL,
	storage_temp_max DECIMAL(4, 1) NOT NULL,
	barcode VARCHAR(64) NOT NULL UNIQUE,
	allergen_info TEXT,
	country_from_origin VARCHAR(65) NOT NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE suppliers
(
	id SERIAL PRIMARY KEY,
	name_company VARCHAR(200) NOT NULL,
	license BOOLEAN NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
	email VARCHAR(254) UNIQUE,
	telephone_number VARCHAR(20) NOT NULL UNIQUE,
	reputation DECIMAL(3, 2),
	website VARCHAR(2048) UNIQUE,
	address VARCHAR(200),
	tin VARCHAR(12) NOT NULL UNIQUE,
	contract_date DATE NOT NULL
);


CREATE TABLE supplier_ingredients
(
	id SERIAL PRIMARY KEY,
	supplier_id INTEGER REFERENCES suppliers(id) ON DELETE CASCADE,
	ingredient_id INTEGER REFERENCES ingredients(id)  ON DELETE CASCADE
);


CREATE TABLE bakeries
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL,
	size DECIMAL(6, 2) NOT NULL CHECK (size > 0),
	rent DECIMAL(10, 2) NOT NULL CHECK (rent >= 0),
	address VARCHAR(200) NOT NULL,
	rating DECIMAL(3, 2),
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'in_repair')),
	open_date DATE NOT NULL,
	work_hours_start TIME NOT NULL,
	work_hours_end TIME NOT NULL
);


CREATE TABLE warehouses
(
	id SERIAL PRIMARY KEY,
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE RESTRICT,
	name VARCHAR(40),
	size DECIMAL(6, 2) NOT NULL CHECK (size > 0),
	max_temperature DECIMAL(4, 1) NOT NULL,
	min_temperature DECIMAL(4, 1) NOT NULL,
	status VARCHAR(9) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'in_repair')),
	central_warehouse_flag BOOLEAN,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE equipment_units
(
	id SERIAL PRIMARY KEY,
	type VARCHAR(25) NOT NULL,
	description TEXT,
	name VARCHAR(25) NOT NULL,
	service_life INTEGER NOT NULL,
	warranty_period INTEGER NOT NULL,
	last_maintenance_date DATE NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'written_off', 'in_repair')),
	brand TEXT NOT NULL,
	purchase_date DATE,
	warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE SET NULL
);


CREATE TABLE employees
(
	id SERIAL PRIMARY KEY,
	fullname VARCHAR(50),
	telephone_number VARCHAR(20) NOT NULL UNIQUE,
	email VARCHAR(254) NOT NULL UNIQUE,
	passport_data TEXT UNIQUE,
	date_birthday DATE NOT NULL,
	start_date DATE NOT NULL,
	position VARCHAR(25) NOT NULL,
	base_salary DECIMAL(10, 2) NOT NULL CHECK(base_salary > 0),
	bonus DECIMAL(10, 2) NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dismissed', 'on_leave')),
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE SET NULL,
	education TEXT
);


CREATE TABLE customers
(
	id SERIAL PRIMARY KEY,
	fullname VARCHAR(50) NOT NULL,
	telephone_number VARCHAR(20) NOT NULL UNIQUE,
	email VARCHAR(254) UNIQUE,
	passport_data TEXT UNIQUE,
	registration_date DATE,
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),
	date_birthday DATE 	
);


CREATE TABLE warehouse_access
(
	id SERIAL PRIMARY KEY,
	warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE CASCADE,
	employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
	access_level TEXT NOT NULL
);


CREATE TABLE medical_books
(
	id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
	medical_record_number VARCHAR(8) NOT NULL UNIQUE,
	issue_date DATE NOT NULL,
	validity_period INTEGER NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'overdue'))
);


CREATE TABLE products
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL UNIQUE,
	description TEXT,
	price_for_customer DECIMAL(7, 2) NOT NULL,
	lifespan_hours INTEGER NOT NULL,
	age_restriction VARCHAR(3),
	category_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
	barcode VARCHAR(64) NOT NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE recipes
(
	id SERIAL PRIMARY KEY,
	ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE CASCADE,
	product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
	quantity DECIMAL(8, 2) NOT NULL,
	instructions TEXT NOT NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE production_batches
(
	id SERIAL PRIMARY KEY,
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE RESTRICT,
	employee_id INTEGER REFERENCES employees(id) ON DELETE RESTRICT,
	product_id INTEGER REFERENCES products(id) ON DELETE RESTRICT,
	quantity INTEGER NOT NULL,
	production_date DATE,
	production_time DECIMAL(6, 2),
	status VARCHAR NOT NULL DEFAULT 'ready' CHECK (status IN ('ready', 'in_production'))
);


CREATE TABLE warehouse_deliveries
(
	id SERIAL PRIMARY KEY,
	supplier_id INTEGER REFERENCES suppliers(id) ON DELETE RESTRICT,
	ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE RESTRICT,
	quantity DECIMAL(10, 2),
	date_dispatch DATE NOT NULL,
	date_receipt DATE NOT NULL,
	type VARCHAR(25),
	warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE RESTRICT,
	delivery_cost DECIMAL(10, 2) NOT NULL
);


CREATE TABLE discounts
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(40),
	description TEXT,
	value DECIMAL(8, 2) NOT NULL,
	type VARCHAR(20) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE sales
(
	id SERIAL PRIMARY KEY,
	customer_id INTEGER REFERENCES customers(id) ON DELETE SET NULL,
	employee_id INTEGER REFERENCES employees(id) ON DELETE RESTRICT,
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE RESTRICT,
	date DATE NOT NULL,
	payment_method VARCHAR(30) NOT NULL,
	total_amount DECIMAL(8, 2) NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'not_completed'))
);


CREATE TABLE sale_details
(
	id SERIAL PRIMARY KEY,
	sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
	product_id INTEGER REFERENCES products(id) ON DELETE RESTRICT,
	quantity DECIMAL(8, 2) NOT NULL,
	total_per_item DECIMAL(8, 2),
	discount_id INTEGER REFERENCES discounts(id) ON DELETE RESTRICT,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE returns 
(
	id SERIAL PRIMARY KEY,
	sale_id INTEGER REFERENCES sales(id) ON DELETE RESTRICT,
	sale_detail_id INTEGER REFERENCES sale_details(id) ON DELETE SET NULL,
	product_id INTEGER REFERENCES products(id) ON DELETE RESTRICT,
	employee_id INTEGER REFERENCES employees(id) ON DELETE RESTRICT,
	customer_id INTEGER REFERENCES customers(id) ON DELETE SET NULL,
	reason TEXT,
	return_date DATE NOT NULL,
	refund_amount DECIMAL(8, 2) NOT NULL,
	status VARCHAR NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'not_completed'))
);


CREATE TABLE price_history
(
	id SERIAL PRIMARY KEY,
	date_change TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	new_price DECIMAL (8, 2) NOT NULL CHECK (new_price >= 0),
	old_price DECIMAL (8, 2) NOT NULL CHECK (old_price >= 0),
	reason TEXT,
	effective_date DATE NOT NULL,
	status VARCHAR NOT NULL CHECK (status IN ('active', 'inactive')),
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE SET NULL,
	product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE write_offs
(
	id SERIAL PRIMARY KEY,
	quantity DECIMAL (10, 2) NOT NULL CHECK (quantity >= 0),
	cost_per_unit DECIMAL(8, 2) NOT NULL,
	reason TEXT NOT NULL,
	date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR NOT NULL CHECK (status IN ('completed', 'denied', 'in_progress')),
	product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
	employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
	warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE SET NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);	


CREATE TABLE inventory_products
(
	id SERIAL PRIMARY KEY,
	warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE CASCADE,
	product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
	quantity DECIMAL(8, 2) NOT NULL,
	expiration_date DATE NOT NULL,
	date_last_update DATE
);

CREATE TABLE inventory_ingredients
(
	id SERIAL PRIMARY KEY,
	warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE CASCADE,
	ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE SET NULL,
	quantity DECIMAL(8, 2) NOT NULL,
	expiration_date DATE NOT NULL,
	date_last_update DATE
);


CREATE TABLE work_schedules
(
	id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
	start_date TIMESTAMP NOT NULL,
	end_date TIMESTAMP NOT NULL,
	break_duration_minutes INTEGER NOT NULL,
	tip_day VARCHAR NOT NULL CHECK (tip_day IN ('day_off', 'worker', 'disease', 'vacation'))
);


CREATE TABLE vacations
(
	id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
	year VARCHAR(4) NOT NULL,
	type VARCHAR(30) NOT NULL,
	start_date TIMESTAMP NOT NULL,
	end_date TIMESTAMP NOT NULL,
	day_count INTEGER NOT NULL,
	status VARCHAR NOT NULL CHECK (status IN ('active', 'inactive'))
);


CREATE TABLE delivery_defects
(
	id SERIAL PRIMARY KEY,
	defect_type defects_type NOT NULL, 
	quantity DECIMAL(8, 2) NOT NULL CHECK (quantity > 0),
	comment TEXT,
	defect_date TIMESTAMP NOT NULL,
	delivery_id INTEGER REFERENCES warehouse_deliveries(id) ON DELETE CASCADE,
	ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE CASCADE,
	employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
	status defects_status NOT NULL DEFAULT 'in_processing'
);


CREATE TABLE ingredient_price_history
(
	id SERIAL PRIMARY KEY,
	supplier_id INTEGER REFERENCES suppliers(id) ON DELETE SET NULL,
	ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE CASCADE,
	price_for_unit DECIMAL(8, 2) NOT NULL CHECK (price_for_unit >= 0),
	unit_type VARCHAR(30) NOT NULL,
	status classic_status NOT NULL DEFAULT 'active',
	start_date TIMESTAMP NOT NULL,
	end_date TIMESTAMP,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE production_plans
(
	id SERIAL PRIMARY KEY,
	planned_date DATE NOT NULL,
	deadline TIMESTAMP NOT NULL,
	quantity DECIMAL(8, 2) NOT NULL CHECK (quantity > 0),
	status pp_status NOT NULL DEFAULT 'in_progress',
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE CASCADE,
	product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
	employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL
);


CREATE TABLE cost_products
(
	id SERIAL PRIMARY KEY,
	product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
	effective_date DATE NOT NULL,
	end_date DATE,
	production_cost DECIMAL(8, 2) NOT NULL CHECK (production_cost >= 0),
	selling_price DECIMAL(8, 2) NOT NULL,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE salary_payments
(
	id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
	bakery_id INTEGER REFERENCES bakeries(id) ON DELETE RESTRICT,
	start_billing_period DATE NOT NULL,
	end_billing_period DATE NOT NULL,
	base_amount DECIMAL(10, 2) NOT NULL CHECK (base_amount >= 0),
	bonus_amount DECIMAL(10, 2) NOT NULL CHECK (bonus_amount >= 0) DEFAULT 0,
	taxes_amount DECIMAL(10, 2) NOT NULL CHECK (taxes_amount >= 0),
	total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
	status sp_status NOT NULL DEFAULT 'completed',	
	payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
	CONSTRAINT check_periods CHECK (end_billing_period >= start_billing_period),
	CONSTRAINT total_amount_check CHECK (total_amount = base_amount + bonus_amount + taxes_amount)
);


CREATE TABLE equipment_maintenance
(
    id SERIAL PRIMARY KEY,
	executing_company VARCHAR(100) NOT NULL,
    master_name VARCHAR(50) NOT NULL,
    master_phone VARCHAR(12),     
    work_order_number VARCHAR(10),
    equipment_id INTEGER REFERENCES equipment_units(id) ON DELETE CASCADE,
    bakery_id INTEGER REFERENCES bakeries(id) ON DELETE RESTRICT,
    maintenance_type maintenance_type NOT NULL,
    status maintenance_status NOT NULL DEFAULT 'planned',
    planned_date DATE NOT NULL,
    actual_date DATE,
    description TEXT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL CHECK (cost >= 0),
    next_maintenance_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_dates CHECK (actual_date IS NULL OR actual_date >= planned_date)
);


CREATE TABLE customer_complaints
(
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    bakery_id INTEGER NOT NULL REFERENCES bakeries(id),
    sale_id INTEGER REFERENCES sales(id),
    complaint_type VARCHAR NOT NULL CHECK (complaint_type IN ('hygiene', 'quality', 'service', 'expectation')),
    description TEXT NOT NULL,
    severity VARCHAR NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    status VARCHAR(20) NOT NULL 	CHECK (status IN ('open', 'completed')) DEFAULT 'open',
    incident_date TIMESTAMP NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE loyalty_cards
(
    id SERIAL PRIMARY KEY,
    customer_id INTEGER UNIQUE REFERENCES customers(id) ON DELETE CASCADE,
	favorite_category_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
    card_number VARCHAR(19) NOT NULL UNIQUE,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    activation_date DATE,  
    expiration_date DATE, 
    total_points INTEGER NOT NULL DEFAULT 0 CHECK (total_points >= 0),
    earned_points INTEGER NOT NULL DEFAULT 0 CHECK (earned_points >= 0),
    spent_points INTEGER NOT NULL DEFAULT 0 CHECK (spent_points >= 0),
    level loyalty_level NOT NULL DEFAULT 'bronze',
    points_multiplier DECIMAL(3, 2) NOT NULL DEFAULT 1.00 CHECK (points_multiplier >= 1.00),
    points_to_ruble DECIMAL(5, 2) NOT NULL DEFAULT 1.00 CHECK (points_to_ruble > 0),
    purchase_count INTEGER NOT NULL DEFAULT 0 CHECK (purchase_count >= 0),
    last_purchase_date TIMESTAMP,      
    birthday_discount_percent DECIMAL(5, 2) DEFAULT 10.00 CHECK (birthday_discount_percent >= 0),
    status card_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_dates CHECK (
        activation_date IS NULL OR 
        activation_date >= issue_date
    ),
    CONSTRAINT check_expiration CHECK (
        expiration_date IS NULL OR 
        expiration_date > issue_date
    ),
    CONSTRAINT check_points_balance CHECK (
        total_points = earned_points - spent_points
    )
);


CREATE TABLE audit_logs (
	id SERIAL PRIMARY KEY,
	table_name VARCHAR(24) NOT NULL,
	record_id INTEGER,
	action VARCHAR NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
	employee_id INTEGER REFERENCES employees(id),
	old_value JSONB,
	new_value JSONB,
	changed_by INTEGER REFERENCES employees(id),
	changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_supplier_ingredients_supplier_id ON supplier_ingredients(supplier_id);
CREATE INDEX idx_supplier_ingredients_ingredient_id ON supplier_ingredients(ingredient_id);

CREATE INDEX idx_warehouses_bakery_id ON warehouses(bakery_id);

CREATE INDEX idx_equipment_units_warehouse_id ON equipment_units(warehouse_id);

CREATE INDEX idx_employees_bakery_id ON employees(bakery_id);

CREATE INDEX idx_warehouse_access_warehouse_id ON warehouse_access(warehouse_id);
CREATE INDEX idx_warehouse_access_employee_id ON warehouse_access(employee_id);

CREATE INDEX idx_medical_books_employee_id ON medical_books(employee_id);

CREATE INDEX idx_products_category_id ON products(category_id);

CREATE INDEX idx_recipes_ingredient_id ON recipes(ingredient_id);
CREATE INDEX idx_recipes_product_id ON recipes(product_id);

CREATE INDEX idx_production_batches_bakery_id ON production_batches(bakery_id);
CREATE INDEX idx_production_batches_employee_id ON production_batches(employee_id);
CREATE INDEX idx_production_batches_product_id ON production_batches(product_id);

CREATE INDEX idx_inventory_ingredients_warehouse_id ON inventory_ingredients(warehouse_id);
CREATE INDEX idx_inventory_ingredients_ingredient_id ON inventory_ingredients(ingredient_id);

CREATE INDEX idx_inventory_products_warehouse_id ON inventory_products(warehouse_id);
CREATE INDEX idx_inventory_products_product_id ON inventory_products(product_id);

CREATE INDEX idx_warehouse_deliveries_supplier_id ON warehouse_deliveries(supplier_id);
CREATE INDEX idx_warehouse_deliveries_ingredient_id ON warehouse_deliveries(ingredient_id);
CREATE INDEX idx_warehouse_deliveries_warehouse_id ON warehouse_deliveries(warehouse_id);

CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_sales_employee_id ON sales(employee_id);
CREATE INDEX idx_sales_bakery_id ON sales(bakery_id);

CREATE INDEX idx_sale_details_sale_id ON sale_details(sale_id);
CREATE INDEX idx_sale_details_product_id ON sale_details(product_id);
CREATE INDEX idx_sale_details_discount_id ON sale_details(discount_id);

CREATE INDEX idx_returns_sale_id ON returns(sale_id);
CREATE INDEX idx_returns_sale_detail_id ON returns(sale_detail_id);
CREATE INDEX idx_returns_product_id ON returns(product_id);
CREATE INDEX idx_returns_employee_id ON returns(employee_id);
CREATE INDEX idx_returns_customer_id ON returns(customer_id);

CREATE INDEX idx_work_schedules_employee_id ON work_schedules(employee_id);

CREATE INDEX idx_vacations_employee_id ON vacations(employee_id);

CREATE INDEX idx_price_history_bakery_id ON price_history(bakery_id);
CREATE INDEX idx_price_history_product_id ON price_history(product_id);

CREATE INDEX idx_write_offs_product_id ON write_offs(product_id);
CREATE INDEX idx_write_offs_employee_id ON write_offs(employee_id);
CREATE INDEX idx_write_offs_warehouse_id ON write_offs(warehouse_id);

CREATE INDEX idx_production_plans_bakery_id ON production_plans(bakery_id);
CREATE INDEX idx_production_plans_product_id ON production_plans(product_id);
CREATE INDEX idx_production_plans_employee_id ON production_plans(employee_id);

CREATE INDEX idx_cost_products_product_id ON cost_products(product_id);

CREATE INDEX idx_salary_payments_employee_id ON salary_payments(employee_id);
CREATE INDEX idx_salary_payments_bakery_id ON salary_payments(bakery_id);

CREATE INDEX idx_equipment_maintenance_equipment_id ON equipment_maintenance(equipment_id);
CREATE INDEX idx_equipment_maintenance_bakery_id ON equipment_maintenance(bakery_id);

CREATE INDEX idx_customer_complaints_customer_id ON customer_complaints(customer_id);
CREATE INDEX idx_customer_complaints_bakery_id ON customer_complaints(bakery_id);
CREATE INDEX idx_customer_complaints_sale_id ON customer_complaints(sale_id);

CREATE INDEX idx_loyalty_cards_customer_id ON loyalty_cards(customer_id);
CREATE INDEX idx_loyalty_cards_fav_category_id ON loyalty_cards(favorite_category_id);

CREATE INDEX idx_delivery_defects_delivery_id   ON delivery_defects(delivery_id);
CREATE INDEX idx_delivery_defects_ingredient_id ON delivery_defects(ingredient_id);
CREATE INDEX idx_delivery_defects_employee_id   ON delivery_defects(employee_id);

CREATE INDEX idx_ingredient_price_history_supplier_id   ON ingredient_price_history(supplier_id);
CREATE INDEX idx_ingredient_price_history_ingredient_id ON ingredient_price_history(ingredient_id);

CREATE INDEX idx_audit_logs_changed_by ON audit_logs(changed_by);

COMMIT;