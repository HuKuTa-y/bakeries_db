--
-- PostgreSQL database dump
--

\restrict 2w8bkjGYgYMnBzoSfgjn5hKGpHLGCzqp34WO0tnaZefsd7Fu3KSJyAlLqo0M7mY

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: bakery_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.bakery_status AS ENUM (
    'active',
    'in_repair',
    'inactive'
);


ALTER TYPE public.bakery_status OWNER TO postgres;

--
-- Name: card_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.card_status AS ENUM (
    'active',
    'blocked',
    'expired'
);


ALTER TYPE public.card_status OWNER TO postgres;

--
-- Name: classic_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.classic_status AS ENUM (
    'active',
    'inactive'
);


ALTER TYPE public.classic_status OWNER TO postgres;

--
-- Name: defects_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.defects_status AS ENUM (
    'processed',
    'in_processing',
    'not_processed'
);


ALTER TYPE public.defects_status OWNER TO postgres;

--
-- Name: defects_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.defects_type AS ENUM (
    'manufacturing',
    'transit',
    'warehouse'
);


ALTER TYPE public.defects_type OWNER TO postgres;

--
-- Name: employee_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.employee_status AS ENUM (
    'active',
    'dismissed',
    'on_leave'
);


ALTER TYPE public.employee_status OWNER TO postgres;

--
-- Name: loyalty_level; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.loyalty_level AS ENUM (
    'bronze',
    'silver',
    'gold',
    'platinum'
);


ALTER TYPE public.loyalty_level OWNER TO postgres;

--
-- Name: maintenance_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.maintenance_status AS ENUM (
    'planned',
    'in_progress',
    'completed',
    'cancelled'
);


ALTER TYPE public.maintenance_status OWNER TO postgres;

--
-- Name: maintenance_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.maintenance_type AS ENUM (
    'preventive',
    'repair',
    'inspection',
    'calibration'
);


ALTER TYPE public.maintenance_type OWNER TO postgres;

--
-- Name: pp_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.pp_status AS ENUM (
    'completed',
    'not_completed',
    'in_progress'
);


ALTER TYPE public.pp_status OWNER TO postgres;

--
-- Name: sp_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sp_status AS ENUM (
    'completed',
    'not_completed',
    'in_progress'
);


ALTER TYPE public.sp_status OWNER TO postgres;

--
-- Name: status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status AS ENUM (
    'active',
    'in_repair',
    'inactive'
);


ALTER TYPE public.status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    table_name character varying(24) NOT NULL,
    record_id integer,
    action character varying NOT NULL,
    employee_id integer,
    old_value jsonb,
    new_value jsonb,
    changed_by integer,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT audit_logs_action_check CHECK (((action)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: bakeries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bakeries (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    size numeric(6,2) NOT NULL,
    rent_monthly numeric(10,2) CONSTRAINT bakeries_rent_not_null NOT NULL,
    address character varying(200) NOT NULL,
    rating numeric(3,2),
    open_date date NOT NULL,
    work_hours_start time without time zone NOT NULL,
    work_hours_end time without time zone NOT NULL,
    status public.bakery_status,
    CONSTRAINT bakeries_rent_check CHECK ((rent_monthly >= (0)::numeric)),
    CONSTRAINT bakeries_size_check CHECK ((size > (0)::numeric))
);


ALTER TABLE public.bakeries OWNER TO postgres;

--
-- Name: bakeries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bakeries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bakeries_id_seq OWNER TO postgres;

--
-- Name: bakeries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bakeries_id_seq OWNED BY public.bakeries.id;


--
-- Name: cost_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cost_products (
    id integer NOT NULL,
    product_id integer,
    effective_date date NOT NULL,
    end_date date,
    production_cost numeric(8,2) NOT NULL,
    selling_price numeric(8,2) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT cost_products_production_cost_check CHECK ((production_cost >= (0)::numeric))
);


ALTER TABLE public.cost_products OWNER TO postgres;

--
-- Name: cost_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cost_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cost_products_id_seq OWNER TO postgres;

--
-- Name: cost_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cost_products_id_seq OWNED BY public.cost_products.id;


--
-- Name: customer_complaints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_complaints (
    id integer NOT NULL,
    customer_id integer,
    bakery_id integer NOT NULL,
    sale_id integer,
    complaint_type character varying NOT NULL,
    description text NOT NULL,
    severity character varying NOT NULL,
    status character varying(20) DEFAULT 'open'::character varying NOT NULL,
    incident_date timestamp without time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT customer_complaints_complaint_type_check CHECK (((complaint_type)::text = ANY ((ARRAY['hygiene'::character varying, 'quality'::character varying, 'service'::character varying, 'expectation'::character varying])::text[]))),
    CONSTRAINT customer_complaints_severity_check CHECK (((severity)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'critical'::character varying])::text[]))),
    CONSTRAINT customer_complaints_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'completed'::character varying])::text[])))
);


ALTER TABLE public.customer_complaints OWNER TO postgres;

--
-- Name: customer_complaints_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_complaints_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_complaints_id_seq OWNER TO postgres;

--
-- Name: customer_complaints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_complaints_id_seq OWNED BY public.customer_complaints.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    fullname character varying(50) NOT NULL,
    telephone_number character varying(20) NOT NULL,
    email character varying(254),
    passport_data text,
    registration_date date,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    date_birthday date,
    CONSTRAINT customers_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying, 'blocked'::character varying])::text[])))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: delivery_defects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delivery_defects (
    id integer NOT NULL,
    defect_type public.defects_type NOT NULL,
    quantity numeric(8,2) NOT NULL,
    comment text,
    defect_date timestamp without time zone NOT NULL,
    delivery_id integer,
    ingredient_id integer,
    employee_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public.defects_status DEFAULT 'in_processing'::public.defects_status NOT NULL,
    CONSTRAINT delivery_defects_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.delivery_defects OWNER TO postgres;

--
-- Name: delivery_defects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.delivery_defects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.delivery_defects_id_seq OWNER TO postgres;

--
-- Name: delivery_defects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.delivery_defects_id_seq OWNED BY public.delivery_defects.id;


--
-- Name: discounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discounts (
    id integer NOT NULL,
    name character varying(40),
    description text,
    value numeric(8,2) NOT NULL,
    type character varying(20) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_value CHECK (((((type)::text = 'percentage'::text) AND (value <= (100)::numeric)) OR ((type)::text = 'fixed'::text))),
    CONSTRAINT discounts_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.discounts OWNER TO postgres;

--
-- Name: discounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.discounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.discounts_id_seq OWNER TO postgres;

--
-- Name: discounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.discounts_id_seq OWNED BY public.discounts.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    fullname character varying(50),
    telephone_number character varying(20) NOT NULL,
    email character varying(254) NOT NULL,
    passport_data text,
    date_birthday date NOT NULL,
    date_employment date CONSTRAINT employees_start_date_not_null NOT NULL,
    "position" character varying(25) NOT NULL,
    base_salary numeric(10,2) NOT NULL,
    bonus numeric(10,2) NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    bakery_id integer,
    education text,
    CONSTRAINT chk_bonus CHECK ((bonus >= (0)::numeric)),
    CONSTRAINT employees_base_salary_check CHECK ((base_salary > (0)::numeric)),
    CONSTRAINT employees_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'dismissed'::character varying, 'on_leave'::character varying])::text[])))
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: equipment_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipment_units (
    id integer CONSTRAINT equipment_id_not_null NOT NULL,
    type character varying(25) CONSTRAINT equipment_type_not_null NOT NULL,
    description text,
    name character varying(25) CONSTRAINT equipment_name_not_null NOT NULL,
    service_life integer CONSTRAINT equipment_service_life_not_null NOT NULL,
    warranty_period integer CONSTRAINT equipment_warranty_period_not_null NOT NULL,
    last_maintenance_date date CONSTRAINT equipment_last_maintenance_date_not_null NOT NULL,
    status character varying DEFAULT 'active'::character varying CONSTRAINT equipment_status_not_null NOT NULL,
    brand text CONSTRAINT equipment_brand_not_null NOT NULL,
    purchase_date date,
    warehouse_id integer,
    CONSTRAINT equipment_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'written_off'::character varying, 'in_repair'::character varying])::text[])))
);


ALTER TABLE public.equipment_units OWNER TO postgres;

--
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_id_seq OWNER TO postgres;

--
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.equipment_units.id;


--
-- Name: equipment_maintenance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipment_maintenance (
    id integer CONSTRAINT equipment_maintenance_logs_id_not_null NOT NULL,
    executing_company character varying(100) CONSTRAINT equipment_maintenance_logs_executing_company_not_null NOT NULL,
    master_name character varying(50) CONSTRAINT equipment_maintenance_logs_master_name_not_null NOT NULL,
    master_phone character varying(12),
    work_order_number character varying(10),
    equipment_id integer,
    bakery_id integer,
    maintenance_type public.maintenance_type CONSTRAINT equipment_maintenance_logs_maintenance_type_not_null NOT NULL,
    status public.maintenance_status DEFAULT 'planned'::public.maintenance_status CONSTRAINT equipment_maintenance_logs_status_not_null NOT NULL,
    planned_date date CONSTRAINT equipment_maintenance_logs_planned_date_not_null NOT NULL,
    actual_date date,
    description text CONSTRAINT equipment_maintenance_logs_description_not_null NOT NULL,
    cost numeric(10,2) CONSTRAINT equipment_maintenance_logs_cost_not_null NOT NULL,
    next_maintenance_date date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT equipment_maintenance_logs_created_at_not_null NOT NULL,
    CONSTRAINT check_dates CHECK (((actual_date IS NULL) OR (actual_date >= planned_date))),
    CONSTRAINT equipment_maintenance_logs_cost_check CHECK ((cost >= (0)::numeric))
);


ALTER TABLE public.equipment_maintenance OWNER TO postgres;

--
-- Name: equipment_maintenance_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipment_maintenance_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_maintenance_logs_id_seq OWNER TO postgres;

--
-- Name: equipment_maintenance_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipment_maintenance_logs_id_seq OWNED BY public.equipment_maintenance.id;


--
-- Name: ingredient_price_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient_price_history (
    id integer CONSTRAINT ingredients_price_history_id_not_null NOT NULL,
    supplier_id integer,
    ingredient_id integer,
    price_for_unit numeric(8,2) CONSTRAINT ingredients_price_history_price_for_unit_not_null NOT NULL,
    unit_type character varying(30) CONSTRAINT ingredients_price_history_unit_type_not_null NOT NULL,
    status public.classic_status DEFAULT 'active'::public.classic_status CONSTRAINT ingredients_price_history_status_not_null NOT NULL,
    start_date timestamp without time zone CONSTRAINT ingredients_price_history_start_date_not_null NOT NULL,
    end_date timestamp without time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT ingredients_price_history_created_at_not_null NOT NULL,
    CONSTRAINT ingredients_price_history_price_for_unit_check CHECK ((price_for_unit >= (0)::numeric))
);


ALTER TABLE public.ingredient_price_history OWNER TO postgres;

--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredients (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    description text,
    unit_type character varying(15) NOT NULL,
    storage_temp_min numeric(4,1) NOT NULL,
    storage_temp_max numeric(4,1) NOT NULL,
    barcode character varying(64) NOT NULL,
    allergen_info text,
    country_from_origin character varying(65) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.ingredients OWNER TO postgres;

--
-- Name: ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingredients_id_seq OWNER TO postgres;

--
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;


--
-- Name: ingredients_price_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredients_price_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingredients_price_history_id_seq OWNER TO postgres;

--
-- Name: ingredients_price_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredients_price_history_id_seq OWNED BY public.ingredient_price_history.id;


--
-- Name: inventory_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_ingredients (
    id integer CONSTRAINT inventory_id_not_null NOT NULL,
    warehouse_id integer,
    ingredient_id integer,
    quantity numeric(8,2) CONSTRAINT inventory_quantity_not_null NOT NULL,
    expiration_date date CONSTRAINT inventory_expiration_date_not_null NOT NULL,
    date_last_update date
);


ALTER TABLE public.inventory_ingredients OWNER TO postgres;

--
-- Name: inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_id_seq OWNER TO postgres;

--
-- Name: inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_id_seq OWNED BY public.inventory_ingredients.id;


--
-- Name: inventory_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_products (
    id integer NOT NULL,
    warehouse_id integer,
    product_id integer,
    quantity numeric(8,2) NOT NULL,
    expiration_date date NOT NULL,
    date_last_update date
);


ALTER TABLE public.inventory_products OWNER TO postgres;

--
-- Name: inventory_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_products_id_seq OWNER TO postgres;

--
-- Name: inventory_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_products_id_seq OWNED BY public.inventory_products.id;


--
-- Name: loyalty_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loyalty_cards (
    id integer NOT NULL,
    customer_id integer,
    favorite_category_id integer,
    card_number character varying(19) NOT NULL,
    issue_date date DEFAULT CURRENT_DATE NOT NULL,
    activation_date date,
    expiration_date date,
    total_points integer DEFAULT 0 NOT NULL,
    earned_points integer DEFAULT 0 NOT NULL,
    spent_points integer DEFAULT 0 NOT NULL,
    level public.loyalty_level DEFAULT 'bronze'::public.loyalty_level NOT NULL,
    points_multiplier numeric(3,2) DEFAULT 1.00 NOT NULL,
    points_to_ruble numeric(5,2) DEFAULT 1.00 NOT NULL,
    purchase_count integer DEFAULT 0 NOT NULL,
    last_purchase_date timestamp without time zone,
    birthday_discount_percent numeric(5,2) DEFAULT 10.00,
    status public.card_status DEFAULT 'active'::public.card_status NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_dates CHECK (((activation_date IS NULL) OR (activation_date >= issue_date))),
    CONSTRAINT check_expiration CHECK (((expiration_date IS NULL) OR (expiration_date > issue_date))),
    CONSTRAINT check_points_balance CHECK ((total_points = (earned_points - spent_points))),
    CONSTRAINT loyalty_cards_birthday_discount_percent_check CHECK ((birthday_discount_percent >= (0)::numeric)),
    CONSTRAINT loyalty_cards_earned_points_check CHECK ((earned_points >= 0)),
    CONSTRAINT loyalty_cards_points_multiplier_check CHECK ((points_multiplier >= 1.00)),
    CONSTRAINT loyalty_cards_points_to_ruble_check CHECK ((points_to_ruble > (0)::numeric)),
    CONSTRAINT loyalty_cards_purchase_count_check CHECK ((purchase_count >= 0)),
    CONSTRAINT loyalty_cards_spent_points_check CHECK ((spent_points >= 0)),
    CONSTRAINT loyalty_cards_total_points_check CHECK ((total_points >= 0))
);


ALTER TABLE public.loyalty_cards OWNER TO postgres;

--
-- Name: loyalty_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.loyalty_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.loyalty_cards_id_seq OWNER TO postgres;

--
-- Name: loyalty_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.loyalty_cards_id_seq OWNED BY public.loyalty_cards.id;


--
-- Name: medical_books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_books (
    id integer NOT NULL,
    employee_id integer,
    medical_record_number character varying(8) NOT NULL,
    issue_date date NOT NULL,
    validity_period integer NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    CONSTRAINT medical_books_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'overdue'::character varying])::text[])))
);


ALTER TABLE public.medical_books OWNER TO postgres;

--
-- Name: medical_books_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medical_books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medical_books_id_seq OWNER TO postgres;

--
-- Name: medical_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medical_books_id_seq OWNED BY public.medical_books.id;


--
-- Name: price_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_history (
    id integer NOT NULL,
    date_change timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    new_price numeric(8,2) NOT NULL,
    old_price numeric(8,2) NOT NULL,
    reason text,
    effective_date date NOT NULL,
    status character varying NOT NULL,
    bakery_id integer,
    product_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT price_history_new_price_check CHECK ((new_price >= (0)::numeric)),
    CONSTRAINT price_history_old_price_check CHECK ((old_price >= (0)::numeric)),
    CONSTRAINT price_history_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.price_history OWNER TO postgres;

--
-- Name: price_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_history_id_seq OWNER TO postgres;

--
-- Name: price_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_history_id_seq OWNED BY public.price_history.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_categories (
    id integer NOT NULL,
    description text,
    name character varying(40) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.product_categories OWNER TO postgres;

--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_categories_id_seq OWNER TO postgres;

--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_categories_id_seq OWNED BY public.product_categories.id;


--
-- Name: production_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_batches (
    id integer CONSTRAINT production_id_not_null NOT NULL,
    bakery_id integer,
    employee_id integer,
    product_id integer,
    quantity integer CONSTRAINT production_quantity_not_null NOT NULL,
    production_date date,
    production_time numeric(6,2),
    status character varying DEFAULT 'ready'::character varying CONSTRAINT production_status_not_null NOT NULL,
    CONSTRAINT production_status_check CHECK (((status)::text = ANY ((ARRAY['ready'::character varying, 'in_production'::character varying])::text[])))
);


ALTER TABLE public.production_batches OWNER TO postgres;

--
-- Name: production_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.production_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.production_id_seq OWNER TO postgres;

--
-- Name: production_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.production_id_seq OWNED BY public.production_batches.id;


--
-- Name: production_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_plans (
    id integer NOT NULL,
    planned_date date NOT NULL,
    deadline timestamp without time zone NOT NULL,
    quantity numeric(8,2) NOT NULL,
    status public.pp_status DEFAULT 'in_progress'::public.pp_status NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    bakery_id integer,
    product_id integer,
    employee_id integer,
    CONSTRAINT production_plans_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.production_plans OWNER TO postgres;

--
-- Name: production_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.production_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.production_plans_id_seq OWNER TO postgres;

--
-- Name: production_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.production_plans_id_seq OWNED BY public.production_plans.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    description text,
    price_for_customer numeric(7,2) NOT NULL,
    lifespan_hours integer NOT NULL,
    age_restriction character varying(3),
    category_id integer,
    barcode character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipes (
    id integer NOT NULL,
    ingredient_id integer,
    product_id integer,
    quantity numeric(8,2) NOT NULL,
    instructions text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.recipes OWNER TO postgres;

--
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recipes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipes_id_seq OWNER TO postgres;

--
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipes_id_seq OWNED BY public.recipes.id;


--
-- Name: returns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.returns (
    id integer NOT NULL,
    sale_id integer,
    sale_item_id integer,
    product_id integer,
    employee_id integer,
    customer_id integer,
    reason text,
    return_date date NOT NULL,
    refund_amount numeric(8,2) NOT NULL,
    status character varying DEFAULT 'completed'::character varying NOT NULL,
    CONSTRAINT returns_status_check CHECK (((status)::text = ANY ((ARRAY['completed'::character varying, 'not_completed'::character varying])::text[])))
);


ALTER TABLE public.returns OWNER TO postgres;

--
-- Name: returns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.returns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.returns_id_seq OWNER TO postgres;

--
-- Name: returns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.returns_id_seq OWNED BY public.returns.id;


--
-- Name: salary_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_payments (
    id integer NOT NULL,
    employee_id integer,
    bakery_id integer,
    start_billing_period date NOT NULL,
    end_billing_period date NOT NULL,
    base_amount numeric(10,2) NOT NULL,
    bonus_amount numeric(10,2) DEFAULT 0 NOT NULL,
    taxes_amount numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    status public.sp_status DEFAULT 'completed'::public.sp_status NOT NULL,
    payment_date date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT check_periods CHECK ((end_billing_period >= start_billing_period)),
    CONSTRAINT salary_payments_base_amount_check CHECK ((base_amount >= (0)::numeric)),
    CONSTRAINT salary_payments_bonus_amount_check CHECK ((bonus_amount >= (0)::numeric)),
    CONSTRAINT salary_payments_taxes_amount_check CHECK ((taxes_amount >= (0)::numeric)),
    CONSTRAINT salary_payments_total_amount_check CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT total_amount_check CHECK ((total_amount = ((base_amount + bonus_amount) + taxes_amount)))
);


ALTER TABLE public.salary_payments OWNER TO postgres;

--
-- Name: salary_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.salary_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salary_payments_id_seq OWNER TO postgres;

--
-- Name: salary_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.salary_payments_id_seq OWNED BY public.salary_payments.id;


--
-- Name: sale_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sale_details (
    id integer CONSTRAINT sale_items_id_not_null NOT NULL,
    sale_id integer,
    product_id integer,
    quantity numeric(8,2) CONSTRAINT sale_items_quantity_not_null NOT NULL,
    total_per_item numeric(8,2) CONSTRAINT sale_items_total_per_item_not_null NOT NULL,
    discount_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT sale_items_created_at_not_null NOT NULL
);


ALTER TABLE public.sale_details OWNER TO postgres;

--
-- Name: sale_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sale_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sale_items_id_seq OWNER TO postgres;

--
-- Name: sale_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sale_items_id_seq OWNED BY public.sale_details.id;


--
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    id integer NOT NULL,
    customer_id integer,
    employee_id integer,
    bakery_id integer,
    date timestamp without time zone NOT NULL,
    payment_method character varying(30) NOT NULL,
    total_amount numeric(8,2) NOT NULL,
    status character varying DEFAULT 'completed'::character varying NOT NULL,
    points_earned integer DEFAULT 0 NOT NULL,
    points_spent integer DEFAULT 0 NOT NULL,
    CONSTRAINT sales_points_earned_check CHECK ((points_earned >= 0)),
    CONSTRAINT sales_points_spent_check CHECK ((points_spent >= 0)),
    CONSTRAINT sales_status_check CHECK (((status)::text = ANY ((ARRAY['completed'::character varying, 'not_completed'::character varying])::text[])))
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- Name: sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_id_seq OWNER TO postgres;

--
-- Name: sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_id_seq OWNED BY public.sales.id;


--
-- Name: supplier_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_ingredients (
    id integer CONSTRAINT supplier_ingredient_id_not_null NOT NULL,
    supplier_id integer,
    ingredient_id integer
);


ALTER TABLE public.supplier_ingredients OWNER TO postgres;

--
-- Name: supplier_ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_ingredient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_ingredient_id_seq OWNER TO postgres;

--
-- Name: supplier_ingredient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_ingredient_id_seq OWNED BY public.supplier_ingredients.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    name_company character varying(200) NOT NULL,
    license boolean NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    email character varying(254),
    telephone_number character varying(20) NOT NULL,
    reputation numeric(3,2),
    website character varying(2048),
    address character varying(200),
    tin character varying(12) NOT NULL,
    contract_date date NOT NULL,
    CONSTRAINT suppliers_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_id_seq OWNER TO postgres;

--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: v_sales_full; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_sales_full AS
 SELECT s.id AS sale_id,
    s.date,
    s.total_amount,
    s.payment_method,
    s.points_earned,
    s.points_spent,
    s.status,
    b.name AS bakery_name,
    e.fullname AS employee_name,
    e."position" AS employee_position,
    c.fullname AS customer_name
   FROM (((public.sales s
     JOIN public.bakeries b ON ((b.id = s.bakery_id)))
     JOIN public.employees e ON ((e.id = s.employee_id)))
     LEFT JOIN public.customers c ON ((c.id = s.customer_id)));


ALTER VIEW public.v_sales_full OWNER TO postgres;

--
-- Name: vacations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vacations (
    id integer NOT NULL,
    employee_id integer,
    year character varying(4) NOT NULL,
    type character varying(30) NOT NULL,
    start_date_vacation timestamp without time zone CONSTRAINT vacations_start_date_not_null NOT NULL,
    end_date_vacation timestamp without time zone CONSTRAINT vacations_end_date_not_null NOT NULL,
    day_count integer NOT NULL,
    status character varying NOT NULL,
    CONSTRAINT vacations_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.vacations OWNER TO postgres;

--
-- Name: vacations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vacations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vacations_id_seq OWNER TO postgres;

--
-- Name: vacations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vacations_id_seq OWNED BY public.vacations.id;


--
-- Name: warehouse_access; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse_access (
    id integer NOT NULL,
    warehouse_id integer,
    employee_id integer,
    access_level text NOT NULL
);


ALTER TABLE public.warehouse_access OWNER TO postgres;

--
-- Name: warehouse_access_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouse_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouse_access_id_seq OWNER TO postgres;

--
-- Name: warehouse_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouse_access_id_seq OWNED BY public.warehouse_access.id;


--
-- Name: warehouse_deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse_deliveries (
    id integer NOT NULL,
    supplier_id integer,
    ingredient_id integer,
    quantity numeric(10,2),
    date_dispatch date NOT NULL,
    date_receipt date NOT NULL,
    type character varying(25),
    warehouse_id integer,
    delivery_cost numeric(10,2) NOT NULL,
    unit_price numeric(10,2) NOT NULL
);


ALTER TABLE public.warehouse_deliveries OWNER TO postgres;

--
-- Name: warehouse_deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouse_deliveries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouse_deliveries_id_seq OWNER TO postgres;

--
-- Name: warehouse_deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouse_deliveries_id_seq OWNED BY public.warehouse_deliveries.id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    id integer NOT NULL,
    bakery_id integer,
    name character varying(40),
    size numeric(6,2) NOT NULL,
    max_temperature numeric(4,1) NOT NULL,
    min_temperature numeric(4,1) NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    central_warehouse_flag boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT warehouses_size_check CHECK ((size > (0)::numeric)),
    CONSTRAINT warehouses_status_check CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text, ('in_repair'::character varying)::text])))
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_id_seq OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouses_id_seq OWNED BY public.warehouses.id;


--
-- Name: work_schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_schedules (
    id integer NOT NULL,
    employee_id integer,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    break_duration_minutes integer NOT NULL,
    tip_day character varying NOT NULL,
    CONSTRAINT work_schedules_tip_day_check CHECK (((tip_day)::text = ANY ((ARRAY['day_off'::character varying, 'worker'::character varying, 'disease'::character varying, 'vacation'::character varying])::text[])))
);


ALTER TABLE public.work_schedules OWNER TO postgres;

--
-- Name: work_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.work_schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.work_schedules_id_seq OWNER TO postgres;

--
-- Name: work_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.work_schedules_id_seq OWNED BY public.work_schedules.id;


--
-- Name: write_offs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.write_offs (
    id integer NOT NULL,
    quantity numeric(10,2) NOT NULL,
    cost_per_unit numeric(8,2) NOT NULL,
    reason text NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status character varying NOT NULL,
    product_id integer,
    employee_id integer,
    warehouse_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT write_offs_quantity_check CHECK ((quantity >= (0)::numeric)),
    CONSTRAINT write_offs_status_check CHECK (((status)::text = ANY ((ARRAY['completed'::character varying, 'denied'::character varying, 'in_progress'::character varying])::text[])))
);


ALTER TABLE public.write_offs OWNER TO postgres;

--
-- Name: write_offs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.write_offs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.write_offs_id_seq OWNER TO postgres;

--
-- Name: write_offs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.write_offs_id_seq OWNED BY public.write_offs.id;


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: bakeries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakeries ALTER COLUMN id SET DEFAULT nextval('public.bakeries_id_seq'::regclass);


--
-- Name: cost_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_products ALTER COLUMN id SET DEFAULT nextval('public.cost_products_id_seq'::regclass);


--
-- Name: customer_complaints id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_complaints ALTER COLUMN id SET DEFAULT nextval('public.customer_complaints_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: delivery_defects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_defects ALTER COLUMN id SET DEFAULT nextval('public.delivery_defects_id_seq'::regclass);


--
-- Name: discounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discounts ALTER COLUMN id SET DEFAULT nextval('public.discounts_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: equipment_maintenance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_maintenance ALTER COLUMN id SET DEFAULT nextval('public.equipment_maintenance_logs_id_seq'::regclass);


--
-- Name: equipment_units id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_units ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- Name: ingredient_price_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_price_history ALTER COLUMN id SET DEFAULT nextval('public.ingredients_price_history_id_seq'::regclass);


--
-- Name: ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);


--
-- Name: inventory_ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_ingredients ALTER COLUMN id SET DEFAULT nextval('public.inventory_id_seq'::regclass);


--
-- Name: inventory_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_products ALTER COLUMN id SET DEFAULT nextval('public.inventory_products_id_seq'::regclass);


--
-- Name: loyalty_cards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_cards ALTER COLUMN id SET DEFAULT nextval('public.loyalty_cards_id_seq'::regclass);


--
-- Name: medical_books id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_books ALTER COLUMN id SET DEFAULT nextval('public.medical_books_id_seq'::regclass);


--
-- Name: price_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_history ALTER COLUMN id SET DEFAULT nextval('public.price_history_id_seq'::regclass);


--
-- Name: product_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories ALTER COLUMN id SET DEFAULT nextval('public.product_categories_id_seq'::regclass);


--
-- Name: production_batches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_batches ALTER COLUMN id SET DEFAULT nextval('public.production_id_seq'::regclass);


--
-- Name: production_plans id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_plans ALTER COLUMN id SET DEFAULT nextval('public.production_plans_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: recipes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes ALTER COLUMN id SET DEFAULT nextval('public.recipes_id_seq'::regclass);


--
-- Name: returns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns ALTER COLUMN id SET DEFAULT nextval('public.returns_id_seq'::regclass);


--
-- Name: salary_payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_payments ALTER COLUMN id SET DEFAULT nextval('public.salary_payments_id_seq'::regclass);


--
-- Name: sale_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_details ALTER COLUMN id SET DEFAULT nextval('public.sale_items_id_seq'::regclass);


--
-- Name: sales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales ALTER COLUMN id SET DEFAULT nextval('public.sales_id_seq'::regclass);


--
-- Name: supplier_ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_ingredients ALTER COLUMN id SET DEFAULT nextval('public.supplier_ingredient_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Name: vacations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vacations ALTER COLUMN id SET DEFAULT nextval('public.vacations_id_seq'::regclass);


--
-- Name: warehouse_access id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_access ALTER COLUMN id SET DEFAULT nextval('public.warehouse_access_id_seq'::regclass);


--
-- Name: warehouse_deliveries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_deliveries ALTER COLUMN id SET DEFAULT nextval('public.warehouse_deliveries_id_seq'::regclass);


--
-- Name: warehouses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN id SET DEFAULT nextval('public.warehouses_id_seq'::regclass);


--
-- Name: work_schedules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedules ALTER COLUMN id SET DEFAULT nextval('public.work_schedules_id_seq'::regclass);


--
-- Name: write_offs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.write_offs ALTER COLUMN id SET DEFAULT nextval('public.write_offs_id_seq'::regclass);


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, table_name, record_id, action, employee_id, old_value, new_value, changed_by, changed_at) FROM stdin;
1	products	1	UPDATE	1	{"price_for_customer": 80.00}	{"price_for_customer": 95.00}	3	2026-11-20 09:15:00+03
2	products	2	UPDATE	2	{"price_for_customer": 150.00}	{"price_for_customer": 180.00}	3	2026-11-20 09:20:00+03
3	products	3	UPDATE	3	{"price_for_customer": 220.00}	{"price_for_customer": 250.00}	3	2026-11-20 10:00:00+03
4	products	4	UPDATE	4	{"price_for_customer": 120.00}	{"price_for_customer": 135.00}	3	2026-11-21 08:30:00+03
5	products	5	UPDATE	5	{"price_for_customer": 300.00}	{"price_for_customer": 350.00}	3	2026-11-21 09:00:00+03
6	products	34	INSERT	\N	\N	{"name": "Круассан миндальный", "category_id": 2, "lifespan_hours": 24, "price_for_customer": 140.00}	5	2026-11-21 11:00:00+03
7	products	35	INSERT	\N	\N	{"name": "Пирог с вишней", "category_id": 3, "lifespan_hours": 48, "price_for_customer": 450.00}	5	2026-11-21 11:30:00+03
8	products	36	INSERT	\N	\N	{"name": "Булочка с корицей", "category_id": 2, "lifespan_hours": 24, "price_for_customer": 90.00}	5	2026-11-22 09:00:00+03
9	inventory_ingredients	1	UPDATE	7	{"quantity": 50.00}	{"quantity": 35.50}	7	2026-11-20 14:00:00+03
10	inventory_ingredients	2	UPDATE	7	{"quantity": 100.00}	{"quantity": 80.00}	7	2026-11-20 14:15:00+03
11	inventory_ingredients	3	UPDATE	8	{"quantity": 200.00}	{"quantity": 150.00}	8	2026-11-21 10:00:00+03
12	inventory_products	1	UPDATE	9	{"quantity": 30}	{"quantity": 15}	9	2026-11-21 18:00:00+03
13	inventory_products	2	UPDATE	9	{"quantity": 25}	{"quantity": 10}	9	2026-11-21 18:30:00+03
14	inventory_products	3	UPDATE	10	{"quantity": 40}	{"quantity": 20}	10	2026-11-22 17:00:00+03
15	warehouse_deliveries	1	INSERT	\N	\N	{"quantity": 500.00, "supplier_id": 1, "delivery_cost": 1500.00, "ingredient_id": 1}	6	2026-11-19 08:00:00+03
16	warehouse_deliveries	2	INSERT	\N	\N	{"quantity": 200.00, "supplier_id": 2, "delivery_cost": 800.00, "ingredient_id": 3}	6	2026-11-20 08:00:00+03
17	warehouse_deliveries	3	INSERT	\N	\N	{"quantity": 150.00, "supplier_id": 1, "delivery_cost": 600.00, "ingredient_id": 5}	6	2026-11-21 08:00:00+03
18	warehouse_deliveries	4	INSERT	\N	\N	{"quantity": 300.00, "supplier_id": 3, "delivery_cost": 1200.00, "ingredient_id": 7}	6	2026-11-22 08:00:00+03
19	sales	101	INSERT	\N	\N	{"bakery_id": 1, "customer_id": 5, "employee_id": 2, "total_amount": 450.00, "payment_method": "card"}	2	2026-11-22 10:30:00+03
20	sales	102	INSERT	\N	\N	{"bakery_id": 1, "customer_id": 8, "employee_id": 2, "total_amount": 320.00, "payment_method": "cash"}	2	2026-11-22 11:15:00+03
21	sales	103	INSERT	\N	\N	{"bakery_id": 2, "customer_id": 12, "employee_id": 4, "total_amount": 780.00, "payment_method": "card"}	4	2026-11-22 12:00:00+03
22	sales	104	INSERT	\N	\N	{"bakery_id": 2, "customer_id": 3, "employee_id": 4, "total_amount": 250.00, "payment_method": "cash"}	4	2026-11-22 13:30:00+03
23	sales	105	INSERT	\N	\N	{"bakery_id": 3, "customer_id": 15, "employee_id": 6, "total_amount": 920.00, "payment_method": "card"}	6	2026-11-23 09:45:00+03
24	sales	101	UPDATE	2	{"status": "not_completed"}	{"status": "completed"}	2	2026-11-22 10:35:00+03
25	sales	102	UPDATE	2	{"status": "not_completed"}	{"status": "completed"}	2	2026-11-22 11:20:00+03
26	sales	103	UPDATE	4	{"status": "not_completed"}	{"status": "completed"}	4	2026-11-22 12:05:00+03
27	returns	1	INSERT	\N	\N	{"reason": "Не понравился вкус", "sale_id": 101, "product_id": 5, "refund_amount": 140.00}	2	2026-11-22 15:00:00+03
28	returns	2	INSERT	\N	\N	{"reason": "Просроченный товар", "sale_id": 103, "product_id": 8, "refund_amount": 250.00}	4	2026-11-22 16:30:00+03
29	returns	3	INSERT	\N	\N	{"reason": "Брак продукции", "sale_id": 105, "product_id": 12, "refund_amount": 180.00}	6	2026-11-23 14:00:00+03
30	write_offs	1	INSERT	\N	\N	{"reason": "Истёк срок годности", "status": "completed", "quantity": 5.00, "product_id": 20, "cost_per_unit": 120.00}	7	2026-11-22 20:00:00+03
31	write_offs	2	INSERT	\N	\N	{"reason": "Повреждена упаковка", "status": "completed", "quantity": 3.00, "product_id": 21, "cost_per_unit": 150.00}	8	2026-11-22 20:30:00+03
32	write_offs	3	INSERT	\N	\N	{"reason": "Истёк срок годности", "status": "in_progress", "quantity": 10.00, "product_id": 22, "cost_per_unit": 90.00}	9	2026-11-23 21:00:00+03
33	medical_books	1	UPDATE	1	{"status": "active"}	{"status": "overdue"}	5	2026-11-18 09:00:00+03
34	medical_books	2	UPDATE	3	{"status": "active"}	{"status": "overdue"}	5	2026-11-19 09:00:00+03
35	medical_books	4	UPDATE	5	{"status": "overdue"}	{"status": "active"}	5	2026-11-20 10:00:00+03
36	medical_books	6	INSERT	\N	\N	{"status": "active", "employee_id": 8, "validity_period": 12, "medical_record_number": "МК-2026-008"}	5	2026-11-21 11:00:00+03
37	medical_books	7	INSERT	\N	\N	{"status": "active", "employee_id": 9, "validity_period": 12, "medical_record_number": "МК-2026-009"}	5	2026-11-21 11:30:00+03
38	work_schedules	1	INSERT	\N	\N	{"tip_day": "worker", "end_date": "2026-11-25 17:00:00", "start_date": "2026-11-25 08:00:00", "employee_id": 1}	5	2026-11-20 16:00:00+03
39	work_schedules	2	INSERT	\N	\N	{"tip_day": "worker", "end_date": "2026-11-25 17:00:00", "start_date": "2026-11-25 08:00:00", "employee_id": 2}	5	2026-11-20 16:05:00+03
40	work_schedules	3	INSERT	\N	\N	{"tip_day": "day_off", "end_date": "2026-11-25 23:59:59", "start_date": "2026-11-25 00:00:00", "employee_id": 3}	5	2026-11-20 16:10:00+03
41	work_schedules	4	UPDATE	1	{"tip_day": "worker"}	{"tip_day": "disease"}	5	2026-11-22 08:00:00+03
42	vacations	1	INSERT	\N	\N	{"type": "Ежегодный", "year": "2026", "status": "active", "end_date": "2026-12-14 23:59:59", "day_count": 14, "start_date": "2026-12-01 00:00:00", "employee_id": 4}	5	2026-11-15 10:00:00+03
43	vacations	2	INSERT	\N	\N	{"type": "Ежегодный", "year": "2026", "status": "active", "end_date": "2026-12-28 23:59:59", "day_count": 14, "start_date": "2026-12-15 00:00:00", "employee_id": 6}	5	2026-11-15 10:30:00+03
44	vacations	3	INSERT	\N	\N	{"type": "За свой счёт", "year": "2026", "status": "active", "end_date": "2026-11-30 23:59:59", "day_count": 3, "start_date": "2026-11-28 00:00:00", "employee_id": 8}	5	2026-11-20 14:00:00+03
45	salary_payments	1	INSERT	\N	\N	{"status": "completed", "bakery_id": 1, "base_amount": 45000.00, "employee_id": 1, "bonus_amount": 5000.00, "taxes_amount": 6500.00, "total_amount": 56500.00}	5	2026-11-10 09:00:00+03
46	salary_payments	2	INSERT	\N	\N	{"status": "completed", "bakery_id": 1, "base_amount": 40000.00, "employee_id": 2, "bonus_amount": 4000.00, "taxes_amount": 5720.00, "total_amount": 49720.00}	5	2026-11-10 09:15:00+03
47	salary_payments	3	INSERT	\N	\N	{"status": "completed", "bakery_id": 2, "base_amount": 50000.00, "employee_id": 3, "bonus_amount": 7000.00, "taxes_amount": 7410.00, "total_amount": 64410.00}	5	2026-11-10 09:30:00+03
48	customer_complaints	1	INSERT	\N	\N	{"status": "open", "severity": "medium", "bakery_id": 1, "customer_id": 5, "complaint_type": "quality"}	2	2026-11-22 14:00:00+03
49	customer_complaints	2	INSERT	\N	\N	{"status": "open", "severity": "low", "bakery_id": 2, "customer_id": 8, "complaint_type": "service"}	4	2026-11-22 15:30:00+03
50	customer_complaints	3	INSERT	\N	\N	{"status": "open", "severity": "high", "bakery_id": 1, "customer_id": 12, "complaint_type": "hygiene"}	2	2026-11-23 10:00:00+03
51	customer_complaints	1	UPDATE	2	{"status": "open"}	{"status": "completed"}	3	2026-11-23 11:00:00+03
52	delivery_defects	1	INSERT	\N	\N	{"status": "in_processing", "comment": "Мука с комками", "quantity": 10.00, "defect_type": "manufacturing"}	7	2026-11-19 10:00:00+03
53	delivery_defects	2	INSERT	\N	\N	{"status": "processed", "comment": "Шоколад растаял при транспортировке", "quantity": 5.00, "defect_type": "transit"}	7	2026-11-20 11:00:00+03
54	delivery_defects	3	INSERT	\N	\N	{"status": "in_processing", "comment": "Нарушен температурный режим хранения", "quantity": 3.00, "defect_type": "warehouse"}	8	2026-11-21 14:00:00+03
55	discounts	15	DELETE	3	{"name": "Чёрная пятница", "type": "percentage", "value": 20.00, "status": "inactive"}	\N	3	2026-11-23 18:00:00+03
56	sale_details	450	DELETE	2	{"sale_id": 101, "quantity": 2.00, "product_id": 5, "total_per_item": 280.00}	\N	2	2026-11-22 16:00:00+03
\.


--
-- Data for Name: bakeries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bakeries (id, name, size, rent_monthly, address, rating, open_date, work_hours_start, work_hours_end, status) FROM stdin;
1	Пекарня Колос	150.50	100000.00	г. Москва, ул. Хлебная, 1	4.80	2020-05-10	07:00:00	21:00:00	active
2	Пекарня Зерно	120.00	85000.00	г. Москва, ул. Зерновая, 5	4.50	2021-02-15	08:00:00	20:00:00	in_repair
21	Пекарня Баранка	85.00	55000.00	г. Ярославль, ул. Кипяченая, 5	4.10	2019-08-15	07:30:00	18:30:00	in_repair
25	Пекарня Кулебяка	140.00	110000.00	г. Владивосток, ул. Рыбная, 4	4.80	2021-07-07	08:00:00	21:00:00	in_repair
49	Пекарня Плетенка	110.50	82000.00	г. Архангельск, ул. Косая, 7	4.40	2020-05-20	07:00:00	20:00:00	in_repair
13	Пекарня Ватрушка	92.00	62000.00	г. Челябинск, ул. Творожная, 9	4.20	2019-05-22	07:00:00	19:00:00	inactive
17	Пекарня Сочник	80.25	50000.00	г. Волгоград, ул. Мучная, 2	3.90	2018-11-11	08:00:00	17:00:00	inactive
42	Пекарня Подовый	130.00	95000.00	г. Якутск, ул. Морозная, 18	4.70	2021-11-11	06:30:00	21:30:00	inactive
3	Пекарня Батон	90.25	60000.00	г. Тула, пр. Ленина, 12	4.20	2019-11-20	07:30:00	19:30:00	active
4	Пекарня Круассан	110.00	95000.00	г. Санкт-Петербург, наб. Реки, 3	4.90	2022-01-10	06:00:00	22:00:00	active
5	Пекарня Сдоба	130.75	75000.00	г. Казань, ул. Сладкая, 8	4.60	2020-08-05	07:00:00	20:00:00	active
6	Пекарня Ржаной	85.00	55000.00	г. Воронеж, ул. Фермерская, 15	4.10	2018-04-12	08:00:00	18:00:00	active
7	Пекарня Пирог	140.00	110000.00	г. Екатеринбург, ул. Пекарская, 20	4.70	2021-06-18	07:00:00	21:00:00	active
8	Пекарня Булочка	95.50	65000.00	г. Новосибирск, ул. Мучная, 7	4.30	2019-09-25	07:30:00	19:00:00	active
9	Пекарня Торт	160.00	120000.00	г. Краснодар, ул. Кондитерская, 10	4.80	2022-03-14	08:00:00	22:00:00	active
10	Пекарня Печенье	105.25	70000.00	г. Ростов-на-Дону, ул. Сладкая, 4	4.40	2020-12-01	07:00:00	20:00:00	active
11	Пекарня Пряник	88.00	58000.00	г. Самара, ул. Старая, 11	4.00	2017-07-07	08:00:00	18:00:00	active
12	Пекарня Слойка	115.75	88000.00	г. Омск, ул. Слоеная, 6	4.50	2021-10-10	06:30:00	21:30:00	active
14	Пекарня Пончик	100.00	72000.00	г. Уфа, ул. Жареная, 14	4.60	2020-02-28	07:30:00	20:30:00	active
15	Пекарня Кекс	125.50	90000.00	г. Красноярск, ул. Сдобная, 3	4.70	2022-05-05	08:00:00	21:00:00	active
16	Пекарня Рулет	135.00	105000.00	г. Пермь, ул. Бисквитная, 18	4.80	2021-01-15	07:00:00	22:00:00	active
18	Пекарня Хачапури	145.75	115000.00	г. Сочи, ул. Горная, 25	4.90	2022-08-20	06:00:00	23:00:00	active
19	Пекарня Лепешка	110.00	80000.00	г. Тюмень, ул. Пресная, 7	4.40	2020-04-10	07:00:00	20:00:00	active
20	Пекарня Сухарь	75.50	45000.00	г. Саратов, ул. Черствая, 1	3.50	2016-03-03	09:00:00	16:00:00	active
22	Пекарня Пирожок	130.25	95000.00	г. Ижевск, ул. Жареная, 12	4.60	2021-12-12	07:00:00	21:00:00	active
23	Пекарня Чебурек	150.00	125000.00	г. Барнаул, ул. Мясная, 8	4.70	2022-02-22	06:30:00	22:30:00	active
24	Пекарня Самса	120.75	88000.00	г. Иркутск, ул. Слоеная, 16	4.50	2020-09-09	07:00:00	20:00:00	active
26	Пекарня Расстегай	95.50	68000.00	г. Хабаровск, ул. Открытая, 10	4.30	2019-01-25	07:30:00	19:30:00	active
27	Пекарня Курник	160.25	130000.00	г. Оренбург, ул. Куриная, 20	4.90	2022-11-11	06:00:00	22:00:00	active
28	Пекарня Штрудель	115.00	85000.00	г. Томск, ул. Фруктовая, 6	4.40	2020-06-18	07:00:00	20:00:00	active
29	Пекарня Маца	70.75	40000.00	г. Рязань, ул. Пресная, 2	3.80	2017-05-05	08:00:00	17:00:00	active
30	Пекарня Лаваш	105.50	75000.00	г. Астрахань, ул. Тонкая, 14	4.50	2021-03-30	07:00:00	21:00:00	active
31	Пекарня Чиабатта	135.00	100000.00	г. Пенза, ул. Итальянская, 9	4.70	2022-04-04	06:30:00	21:30:00	active
32	Пекарня Фокачча	125.25	92000.00	г. Липецк, ул. Масляная, 11	4.60	2020-10-10	07:30:00	20:30:00	active
33	Пекарня Бородинский	90.00	60000.00	г. Киров, ул. Ржаная, 3	4.20	2019-12-12	07:00:00	19:00:00	active
34	Пекарня Дарницкий	88.50	58000.00	г. Тверь, ул. Серая, 7	4.10	2018-08-08	08:00:00	18:00:00	active
35	Пекарня Зерновой	110.75	82000.00	г. Белгород, ул. Полезная, 15	4.50	2021-05-05	07:00:00	20:00:00	active
36	Пекарня Безглютеновый	85.00	70000.00	г. Калуга, ул. Диетическая, 5	4.30	2020-01-15	08:00:00	19:00:00	active
37	Пекарня Цельнозерновой	95.25	65000.00	г. Смоленск, ул. Грубая, 10	4.40	2019-06-20	07:30:00	19:30:00	active
38	Пекарня Овсяный	100.00	68000.00	г. Махачкала, ул. Геркулесовая, 8	4.20	2021-09-09	07:00:00	20:00:00	active
39	Пекарня Гречишный	80.50	55000.00	г. Саранск, ул. Зеленая, 4	4.00	2018-02-14	08:00:00	17:00:00	active
40	Пекарня Пшеничный	120.00	85000.00	г. Йошкар-Ола, ул. Светлая, 12	4.60	2022-06-06	07:00:00	21:00:00	active
41	Пекарня Формовой	115.75	80000.00	г. Чебоксары, ул. Кирпичная, 6	4.50	2020-03-20	07:30:00	20:30:00	active
43	Пекарня Детский	90.25	75000.00	г. Грозный, ул. Милая, 9	4.40	2019-04-25	07:00:00	19:00:00	active
44	Пекарня Диетический	85.50	65000.00	г. Ижевск, ул. Легкая, 5	4.20	2020-07-07	08:00:00	19:00:00	active
45	Пекарня Веганский	105.00	80000.00	г. Ульяновск, ул. Постная, 11	4.50	2021-02-18	07:30:00	20:00:00	active
46	Пекарня Сезонный	140.75	110000.00	г. Курск, ул. Праздничная, 14	4.80	2022-09-09	06:00:00	22:00:00	active
47	Пекарня Авторский	150.00	125000.00	г. Иваново, ул. Уникальная, 20	4.90	2022-12-12	06:00:00	23:00:00	active
48	Пекарня Фирменный	160.25	135000.00	г. Магнитогорск, ул. Главная, 1	4.90	2023-01-15	05:00:00	23:00:00	active
50	Пекарня Рогалик	95.00	68000.00	г. Мурманск, ул. Северная, 3	4.30	2019-10-10	07:30:00	19:30:00	active
\.


--
-- Data for Name: cost_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_products (id, product_id, effective_date, end_date, production_cost, selling_price, created_at) FROM stdin;
1	2	2025-11-20	2025-11-26	37.00	64.75	2026-10-29 13:52:38.082949+03
2	3	2025-11-27	2025-12-03	44.00	77.00	2026-10-29 13:52:38.082949+03
3	4	2025-12-04	2025-12-10	51.00	89.25	2026-10-29 13:52:38.082949+03
4	5	2025-12-11	2025-12-17	58.00	101.50	2026-10-29 13:52:38.082949+03
5	6	2025-12-18	2025-12-24	65.00	113.75	2026-10-29 13:52:38.082949+03
6	7	2025-12-25	2025-12-31	72.00	126.00	2026-10-29 13:52:38.082949+03
7	8	2026-01-01	2026-01-07	79.00	138.25	2026-10-29 13:52:38.082949+03
8	9	2026-01-08	2026-01-14	86.00	150.50	2026-10-29 13:52:38.082949+03
9	10	2026-01-15	2026-01-21	93.00	162.75	2026-10-29 13:52:38.082949+03
10	11	2026-01-22	2026-01-28	100.00	175.00	2026-10-29 13:52:38.082949+03
11	12	2026-01-29	2026-02-04	107.00	187.25	2026-10-29 13:52:38.082949+03
12	13	2026-02-05	2026-02-11	114.00	199.50	2026-10-29 13:52:38.082949+03
13	14	2026-02-12	2026-02-18	121.00	211.75	2026-10-29 13:52:38.082949+03
14	15	2026-02-19	2026-02-25	128.00	224.00	2026-10-29 13:52:38.082949+03
15	16	2026-02-26	2026-03-04	135.00	236.25	2026-10-29 13:52:38.082949+03
16	17	2026-03-05	2026-03-11	142.00	248.50	2026-10-29 13:52:38.082949+03
17	18	2026-03-12	2026-03-18	149.00	260.75	2026-10-29 13:52:38.082949+03
18	19	2026-03-19	2026-03-25	156.00	273.00	2026-10-29 13:52:38.082949+03
19	20	2026-03-26	2026-04-01	163.00	285.25	2026-10-29 13:52:38.082949+03
20	21	2026-04-02	2026-04-08	170.00	297.50	2026-10-29 13:52:38.082949+03
21	22	2026-04-09	2026-04-15	177.00	309.75	2026-10-29 13:52:38.082949+03
22	23	2026-04-16	2026-04-22	184.00	322.00	2026-10-29 13:52:38.082949+03
23	24	2026-04-23	2026-04-29	191.00	334.25	2026-10-29 13:52:38.082949+03
24	25	2026-04-30	2026-05-06	198.00	346.50	2026-10-29 13:52:38.082949+03
25	26	2026-05-07	2026-05-13	35.00	61.25	2026-10-29 13:52:38.082949+03
26	27	2026-05-14	2026-05-20	42.00	73.50	2026-10-29 13:52:38.082949+03
27	28	2026-05-21	2026-05-27	49.00	85.75	2026-10-29 13:52:38.082949+03
28	29	2026-05-28	2026-06-03	56.00	98.00	2026-10-29 13:52:38.082949+03
29	30	2026-06-04	2026-06-10	63.00	110.25	2026-10-29 13:52:38.082949+03
30	31	2026-06-11	2026-06-17	70.00	122.50	2026-10-29 13:52:38.082949+03
31	32	2026-06-18	2026-06-24	77.00	134.75	2026-10-29 13:52:38.082949+03
32	33	2026-06-25	2026-07-01	84.00	147.00	2026-10-29 13:52:38.082949+03
33	34	2026-07-02	2026-07-08	91.00	159.25	2026-10-29 13:52:38.082949+03
34	35	2026-07-09	2026-07-15	98.00	171.50	2026-10-29 13:52:38.082949+03
35	36	2026-07-16	2026-07-22	105.00	183.75	2026-10-29 13:52:38.082949+03
36	37	2026-07-23	2026-07-29	112.00	196.00	2026-10-29 13:52:38.082949+03
37	38	2026-07-30	2026-08-05	119.00	208.25	2026-10-29 13:52:38.082949+03
38	39	2026-08-06	2026-08-12	126.00	220.50	2026-10-29 13:52:38.082949+03
39	40	2026-08-13	2026-08-19	133.00	232.75	2026-10-29 13:52:38.082949+03
40	41	2026-08-20	2026-08-26	140.00	245.00	2026-10-29 13:52:38.082949+03
41	42	2026-08-27	2026-09-02	147.00	257.25	2026-10-29 13:52:38.082949+03
42	43	2026-09-03	2026-09-09	154.00	269.50	2026-10-29 13:52:38.082949+03
43	44	2026-09-10	2026-09-16	161.00	281.75	2026-10-29 13:52:38.082949+03
44	45	2026-09-17	2026-09-23	168.00	294.00	2026-10-29 13:52:38.082949+03
45	46	2026-09-24	2026-09-30	175.00	306.25	2026-10-29 13:52:38.082949+03
46	47	2026-10-01	2026-10-07	182.00	318.50	2026-10-29 13:52:38.082949+03
47	48	2026-10-08	\N	189.00	330.75	2026-10-29 13:52:38.082949+03
48	49	2026-10-15	\N	196.00	343.00	2026-10-29 13:52:38.082949+03
49	50	2026-10-22	\N	33.00	57.75	2026-10-29 13:52:38.082949+03
50	1	2026-10-29	\N	40.00	70.00	2026-10-29 13:52:38.082949+03
\.


--
-- Data for Name: customer_complaints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_complaints (id, customer_id, bakery_id, sale_id, complaint_type, description, severity, status, incident_date, created_at) FROM stdin;
1	2	2	2	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-11-02 10:34:58.106404	2026-11-05 11:34:58.106404+03
2	3	3	3	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-10-30 09:34:58.106404	2026-11-05 11:34:58.106404+03
3	4	4	4	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-10-27 08:34:58.106404	2026-11-05 11:34:58.106404+03
4	5	5	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-10-24 07:34:58.106404	2026-11-05 11:34:58.106404+03
5	6	6	6	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-10-21 06:34:58.106404	2026-11-05 11:34:58.106404+03
6	7	7	7	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-10-18 05:34:58.106404	2026-11-05 11:34:58.106404+03
7	\N	8	8	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-10-15 04:34:58.106404	2026-11-05 11:34:58.106404+03
8	\N	9	9	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-10-12 03:34:58.106404	2026-11-05 11:34:58.106404+03
9	\N	10	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-10-09 02:34:58.106404	2026-11-05 11:34:58.106404+03
10	11	11	11	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-10-06 01:34:58.106404	2026-11-05 11:34:58.106404+03
11	12	12	12	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-10-03 00:34:58.106404	2026-11-05 11:34:58.106404+03
12	13	13	13	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-09-29 23:34:58.106404	2026-11-05 11:34:58.106404+03
13	14	14	14	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-09-26 22:34:58.106404	2026-11-05 11:34:58.106404+03
14	15	15	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-09-23 21:34:58.106404	2026-11-05 11:34:58.106404+03
15	16	16	16	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-09-20 20:34:58.106404	2026-11-05 11:34:58.106404+03
16	17	17	17	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-09-17 19:34:58.106404	2026-11-05 11:34:58.106404+03
17	\N	18	18	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-09-14 18:34:58.106404	2026-11-05 11:34:58.106404+03
18	\N	19	19	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-09-11 17:34:58.106404	2026-11-05 11:34:58.106404+03
19	\N	20	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-09-08 16:34:58.106404	2026-11-05 11:34:58.106404+03
20	21	21	21	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-09-05 15:34:58.106404	2026-11-05 11:34:58.106404+03
21	22	22	22	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-09-02 14:34:58.106404	2026-11-05 11:34:58.106404+03
22	23	23	23	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-08-30 13:34:58.106404	2026-11-05 11:34:58.106404+03
23	24	24	24	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-08-27 12:34:58.106404	2026-11-05 11:34:58.106404+03
24	25	25	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-08-25 11:34:58.106404	2026-11-05 11:34:58.106404+03
25	26	26	26	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-08-22 10:34:58.106404	2026-11-05 11:34:58.106404+03
26	27	27	27	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-08-19 09:34:58.106404	2026-11-05 11:34:58.106404+03
27	\N	28	28	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-08-16 08:34:58.106404	2026-11-05 11:34:58.106404+03
28	\N	29	29	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-08-13 07:34:58.106404	2026-11-05 11:34:58.106404+03
29	\N	30	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-08-10 06:34:58.106404	2026-11-05 11:34:58.106404+03
30	31	31	31	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-08-07 05:34:58.106404	2026-11-05 11:34:58.106404+03
31	32	32	32	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-08-04 04:34:58.106404	2026-11-05 11:34:58.106404+03
32	33	33	33	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-08-01 03:34:58.106404	2026-11-05 11:34:58.106404+03
33	34	34	34	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-07-29 02:34:58.106404	2026-11-05 11:34:58.106404+03
34	35	35	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-07-26 01:34:58.106404	2026-11-05 11:34:58.106404+03
35	36	36	36	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-07-23 00:34:58.106404	2026-11-05 11:34:58.106404+03
36	37	37	37	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-07-19 23:34:58.106404	2026-11-05 11:34:58.106404+03
37	\N	38	38	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-07-16 22:34:58.106404	2026-11-05 11:34:58.106404+03
38	\N	39	39	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-07-13 21:34:58.106404	2026-11-05 11:34:58.106404+03
39	\N	40	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-07-10 20:34:58.106404	2026-11-05 11:34:58.106404+03
40	41	41	41	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-07-07 19:34:58.106404	2026-11-05 11:34:58.106404+03
41	42	42	42	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-07-04 18:34:58.106404	2026-11-05 11:34:58.106404+03
42	43	43	43	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-07-01 17:34:58.106404	2026-11-05 11:34:58.106404+03
43	44	44	44	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-06-28 16:34:58.106404	2026-11-05 11:34:58.106404+03
44	45	45	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-06-25 15:34:58.106404	2026-11-05 11:34:58.106404+03
45	46	46	46	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-06-22 14:34:58.106404	2026-11-05 11:34:58.106404+03
46	47	47	47	quality	Продукт оказался несвежим, чувствовался неприятный запах	low	open	2026-06-19 13:34:58.106404	2026-11-05 11:34:58.106404+03
47	\N	48	48	quality	Выпечка подгорелая и невкусная, деньги на ветер	medium	completed	2026-06-16 12:34:58.106404	2026-11-05 11:34:58.106404+03
48	\N	49	49	service	Грубое обслуживание, хамство со стороны персонала	high	completed	2026-06-14 11:34:58.106404	2026-11-05 11:34:58.106404+03
49	\N	50	\N	expectation	Не положили заказанный товар в чек, обсчитали	critical	completed	2026-06-11 10:34:58.106404	2026-11-05 11:34:58.106404+03
50	1	1	1	hygiene	В пекарне было грязно, на столах крошки, пол не мыт	low	open	2026-06-08 09:34:58.106404	2026-11-05 11:34:58.106404+03
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, fullname, telephone_number, email, passport_data, registration_date, status, date_birthday) FROM stdin;
1	Сmith John Smith	+79222000001	cust1@mail.ru	4501 200001	2020-01-15	active	1990-01-15
2	Doe Jane Doe	+79222000002	cust2@mail.ru	4501 200002	2020-02-20	active	1985-02-20
3	Brown Robert Brown	+79222000003	cust3@mail.ru	4501 200003	2020-03-25	inactive	1992-03-25
4	Davis Michael Davis	+79222000004	cust4@mail.ru	4501 200004	2020-04-10	active	1988-04-10
5	Miller Sarah Miller	+79222000005	cust5@mail.ru	4501 200005	2020-05-12	active	1995-05-12
6	Wilson David Wilson	+79222000006	cust6@mail.ru	4501 200006	2020-06-18	blocked	1980-06-18
7	Moore Emily Moore	+79222000007	cust7@mail.ru	4501 200007	2020-07-22	active	1993-07-22
8	Taylor James Taylor	+79222000008	cust8@mail.ru	4501 200008	2020-08-30	active	1987-08-30
9	Anderson Lisa Anderson	+79222000009	cust9@mail.ru	4501 200009	2020-09-14	active	1991-09-14
10	Thomas William Thomas	+79222000010	cust10@mail.ru	4501 200010	2020-10-01	inactive	1984-10-01
11	Jackson Mary Jackson	+79222000011	cust11@mail.ru	4501 200011	2020-11-11	active	1996-11-11
12	White Richard White	+79222000012	cust12@mail.ru	4501 200012	2020-12-05	active	1989-12-05
13	Harris Patricia Harris	+79222000013	cust13@mail.ru	4501 200013	2021-01-10	active	1994-01-10
14	Martin Charles Martin	+79222000014	cust14@mail.ru	4501 200014	2021-02-28	blocked	1982-02-28
15	Thompson Jennifer Thomp	+79222000015	cust15@mail.ru	4501 200015	2021-03-05	active	1997-03-05
16	Garcia Daniel Garcia	+79222000016	cust16@mail.ru	4501 200016	2021-04-18	active	1986-04-18
17	Martinez Susan Martinez	+79222000017	cust17@mail.ru	4501 200017	2021-05-22	inactive	1990-05-22
18	Robinson Matthew Robinso	+79222000018	cust18@mail.ru	4501 200018	2021-06-12	active	1983-06-12
19	Clark Karen Clark	+79222000019	cust19@mail.ru	4501 200019	2021-07-09	active	1995-07-09
20	Rodriguez Anthony Rodrig	+79222000020	cust20@mail.ru	4501 200020	2021-08-15	active	1988-08-15
21	Lewis Nancy Lewis	+79222000021	cust21@mail.ru	4501 200021	2021-09-20	active	1992-09-20
22	Lee Mark Lee	+79222000022	cust22@mail.ru	4501 200022	2021-10-25	blocked	1987-10-25
23	Walker Betty Walker	+79222000023	cust23@mail.ru	4501 200023	2021-11-11	active	1994-11-11
24	Hall Steven Hall	+79222000024	cust24@mail.ru	4501 200024	2021-12-01	active	1981-12-01
25	Allen Dorothy Allen	+79222000025	cust25@mail.ru	4501 200025	2022-01-15	inactive	1996-01-15
26	Young Sandra Young	+79222000026	cust26@mail.ru	4501 200026	2022-02-20	active	1989-02-20
27	King Paul King	+79222000027	cust27@mail.ru	4501 200027	2022-03-25	active	1993-03-25
28	Wright Ashley Wright	+79222000028	cust28@mail.ru	4501 200028	2022-04-10	active	1984-04-10
29	Scott Kimberly Scott	+79222000029	cust29@mail.ru	4501 200029	2022-05-12	active	1997-05-12
30	Green Andrew Green	+79222000030	cust30@mail.ru	4501 200030	2022-06-18	blocked	1986-06-18
31	Baker Donna Baker	+79222000031	cust31@mail.ru	4501 200031	2022-07-22	active	1991-07-22
32	Adams Joshua Adams	+79222000032	cust32@mail.ru	4501 200032	2022-08-30	active	1988-08-30
33	Nelson Michelle Nelson	+79222000033	cust33@mail.ru	4501 200033	2022-09-14	inactive	1995-09-14
34	Carter Ronald Carter	+79222000034	cust34@mail.ru	4501 200034	2022-10-01	active	1982-10-01
35	Mitchell Laura Mitchell	+79222000035	cust35@mail.ru	4501 200035	2022-11-11	active	1990-11-11
36	Perez Edward Perez	+79222000036	cust36@mail.ru	4501 200036	2022-12-05	active	1985-12-05
37	Roberts Deborah Roberts	+79222000037	cust37@mail.ru	4501 200037	2023-01-10	active	1993-01-10
38	Turner Kevin Turner	+79222000038	cust38@mail.ru	4501 200038	2023-02-28	blocked	1987-02-28
39	Phillips Maria Phillips	+79222000039	cust39@mail.ru	4501 200039	2023-03-05	active	1996-03-05
40	Campbell Brian Campbell	+79222000040	cust40@mail.ru	4501 200040	2023-04-18	active	1981-04-18
41	Parker Amy Parker	+79222000041	cust41@mail.ru	4501 200041	2023-05-22	inactive	1992-05-22
42	Evans Jason Evans	+79222000042	cust42@mail.ru	4501 200042	2023-06-12	active	1989-06-12
43	Edwards Shirley Edwards	+79222000043	cust43@mail.ru	4501 200043	2023-07-09	active	1994-07-09
44	Collins Dennis Collins	+79222000044	cust44@mail.ru	4501 200044	2023-08-15	active	1986-08-15
45	Stewart Brenda Stewart	+79222000045	cust45@mail.ru	4501 200045	2023-09-20	active	1991-09-20
46	Sanchez Timothy Sanchez	+79222000046	cust46@mail.ru	4501 200046	2023-10-25	blocked	1988-10-25
47	Morris Kathryn Morris	+79222000047	cust47@mail.ru	4501 200047	2023-11-11	active	1995-11-11
48	Rogers Gregory Rogers	+79222000048	cust48@mail.ru	4501 200048	2023-12-01	active	1982-12-01
49	Reed Anna Reed	+79222000049	cust49@mail.ru	4501 200049	2024-01-15	inactive	1990-01-15
50	Cook Jack Cook	+79222000050	cust50@mail.ru	4501 200050	2024-02-20	active	1985-02-20
\.


--
-- Data for Name: delivery_defects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delivery_defects (id, defect_type, quantity, comment, defect_date, delivery_id, ingredient_id, employee_id, created_at, status) FROM stdin;
1	warehouse	5.82	Нарушена целостность упаковки	2026-10-26 12:40:15.795386	2	2	2	2026-10-29 12:40:15.795386+03	in_processing
2	warehouse	7.98	Несоответствие заявленному качеству	2026-10-23 12:40:15.795386	3	3	3	2026-10-29 12:40:15.795386+03	processed
3	transit	4.11	Истёк срок годности при приёмке	2026-10-20 12:40:15.795386	4	4	4	2026-10-29 12:40:15.795386+03	in_processing
4	transit	14.71	Повреждение при транспортировке	2026-10-17 12:40:15.795386	5	5	5	2026-10-29 12:40:15.795386+03	in_processing
5	transit	15.00	Обнаружен посторонний предмет	2026-10-14 12:40:15.795386	6	6	6	2026-10-29 12:40:15.795386+03	not_processed
6	warehouse	3.16	Нарушена целостность упаковки	2026-10-11 12:40:15.795386	7	7	7	2026-10-29 12:40:15.795386+03	processed
7	warehouse	7.93	Несоответствие заявленному качеству	2026-10-08 12:40:15.795386	8	8	8	2026-10-29 12:40:15.795386+03	not_processed
8	manufacturing	5.05	Истёк срок годности при приёмке	2026-10-05 12:40:15.795386	9	9	9	2026-10-29 12:40:15.795386+03	processed
9	transit	17.83	Повреждение при транспортировке	2026-10-02 12:40:15.795386	10	10	10	2026-10-29 12:40:15.795386+03	not_processed
10	transit	5.87	Обнаружен посторонний предмет	2026-09-29 12:40:15.795386	11	11	11	2026-10-29 12:40:15.795386+03	processed
11	warehouse	13.52	Нарушена целостность упаковки	2026-09-26 12:40:15.795386	12	12	12	2026-10-29 12:40:15.795386+03	not_processed
12	manufacturing	6.16	Несоответствие заявленному качеству	2026-09-23 12:40:15.795386	13	13	13	2026-10-29 12:40:15.795386+03	in_processing
13	warehouse	15.96	Истёк срок годности при приёмке	2026-09-20 12:40:15.795386	14	14	14	2026-10-29 12:40:15.795386+03	processed
14	transit	13.10	Повреждение при транспортировке	2026-09-17 12:40:15.795386	15	15	15	2026-10-29 12:40:15.795386+03	processed
15	warehouse	15.38	Обнаружен посторонний предмет	2026-09-14 12:40:15.795386	16	16	16	2026-10-29 12:40:15.795386+03	processed
16	warehouse	9.29	Нарушена целостность упаковки	2026-09-11 12:40:15.795386	17	17	17	2026-10-29 12:40:15.795386+03	processed
17	warehouse	7.09	Несоответствие заявленному качеству	2026-09-08 12:40:15.795386	18	18	18	2026-10-29 12:40:15.795386+03	in_processing
18	manufacturing	7.95	Истёк срок годности при приёмке	2026-09-05 12:40:15.795386	19	19	19	2026-10-29 12:40:15.795386+03	in_processing
19	warehouse	18.04	Повреждение при транспортировке	2026-09-02 12:40:15.795386	20	20	20	2026-10-29 12:40:15.795386+03	processed
20	warehouse	15.38	Обнаружен посторонний предмет	2026-08-30 12:40:15.795386	21	21	21	2026-10-29 12:40:15.795386+03	not_processed
21	manufacturing	18.91	Нарушена целостность упаковки	2026-08-27 12:40:15.795386	22	22	22	2026-10-29 12:40:15.795386+03	processed
22	manufacturing	15.79	Несоответствие заявленному качеству	2026-08-24 12:40:15.795386	23	23	23	2026-10-29 12:40:15.795386+03	processed
23	transit	1.67	Истёк срок годности при приёмке	2026-08-21 12:40:15.795386	24	24	24	2026-10-29 12:40:15.795386+03	not_processed
24	transit	11.01	Повреждение при транспортировке	2026-08-18 12:40:15.795386	25	25	25	2026-10-29 12:40:15.795386+03	in_processing
25	manufacturing	16.77	Обнаружен посторонний предмет	2026-08-15 12:40:15.795386	26	26	26	2026-10-29 12:40:15.795386+03	in_processing
26	manufacturing	3.87	Нарушена целостность упаковки	2026-08-12 12:40:15.795386	27	27	27	2026-10-29 12:40:15.795386+03	in_processing
27	transit	4.42	Несоответствие заявленному качеству	2026-08-09 12:40:15.795386	28	28	28	2026-10-29 12:40:15.795386+03	processed
28	warehouse	2.75	Истёк срок годности при приёмке	2026-08-06 12:40:15.795386	29	29	29	2026-10-29 12:40:15.795386+03	processed
29	warehouse	3.73	Повреждение при транспортировке	2026-08-03 12:40:15.795386	30	30	30	2026-10-29 12:40:15.795386+03	in_processing
30	transit	3.63	Обнаружен посторонний предмет	2026-07-31 12:40:15.795386	31	31	31	2026-10-29 12:40:15.795386+03	in_processing
31	manufacturing	4.84	Нарушена целостность упаковки	2026-07-28 12:40:15.795386	32	32	32	2026-10-29 12:40:15.795386+03	processed
32	transit	17.77	Несоответствие заявленному качеству	2026-07-25 12:40:15.795386	33	33	33	2026-10-29 12:40:15.795386+03	not_processed
33	manufacturing	18.64	Истёк срок годности при приёмке	2026-07-22 12:40:15.795386	34	34	34	2026-10-29 12:40:15.795386+03	not_processed
34	manufacturing	15.33	Повреждение при транспортировке	2026-07-19 12:40:15.795386	35	35	35	2026-10-29 12:40:15.795386+03	not_processed
35	transit	18.00	Обнаружен посторонний предмет	2026-07-16 12:40:15.795386	36	36	36	2026-10-29 12:40:15.795386+03	processed
36	transit	16.64	Нарушена целостность упаковки	2026-07-13 12:40:15.795386	37	37	37	2026-10-29 12:40:15.795386+03	not_processed
37	transit	15.78	Несоответствие заявленному качеству	2026-07-10 12:40:15.795386	38	38	38	2026-10-29 12:40:15.795386+03	not_processed
38	transit	18.48	Истёк срок годности при приёмке	2026-07-07 12:40:15.795386	39	39	39	2026-10-29 12:40:15.795386+03	processed
39	transit	3.67	Повреждение при транспортировке	2026-07-04 12:40:15.795386	40	40	40	2026-10-29 12:40:15.795386+03	in_processing
40	warehouse	7.71	Обнаружен посторонний предмет	2026-07-01 12:40:15.795386	41	41	41	2026-10-29 12:40:15.795386+03	processed
41	manufacturing	5.73	Нарушена целостность упаковки	2026-06-28 12:40:15.795386	42	42	42	2026-10-29 12:40:15.795386+03	not_processed
42	warehouse	14.22	Несоответствие заявленному качеству	2026-06-25 12:40:15.795386	43	43	43	2026-10-29 12:40:15.795386+03	in_processing
43	manufacturing	15.67	Истёк срок годности при приёмке	2026-06-22 12:40:15.795386	44	44	44	2026-10-29 12:40:15.795386+03	not_processed
44	transit	19.72	Повреждение при транспортировке	2026-06-19 12:40:15.795386	45	45	45	2026-10-29 12:40:15.795386+03	in_processing
45	transit	0.91	Обнаружен посторонний предмет	2026-06-16 12:40:15.795386	46	46	46	2026-10-29 12:40:15.795386+03	processed
46	warehouse	18.38	Нарушена целостность упаковки	2026-06-13 12:40:15.795386	47	47	47	2026-10-29 12:40:15.795386+03	not_processed
47	manufacturing	15.80	Несоответствие заявленному качеству	2026-06-10 12:40:15.795386	48	48	48	2026-10-29 12:40:15.795386+03	processed
48	warehouse	12.58	Истёк срок годности при приёмке	2026-06-07 12:40:15.795386	49	49	49	2026-10-29 12:40:15.795386+03	processed
49	manufacturing	1.96	Повреждение при транспортировке	2026-06-04 12:40:15.795386	50	50	50	2026-10-29 12:40:15.795386+03	in_processing
50	transit	4.46	Обнаружен посторонний предмет	2026-06-01 12:40:15.795386	1	1	1	2026-10-29 12:40:15.795386+03	processed
\.


--
-- Data for Name: discounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discounts (id, name, description, value, type, start_date, end_date, status, created_at) FROM stdin;
1	Скидка 5%	Стандартная скидка 5%	5.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
2	Скидка 10%	Скидка 10% для своих	10.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
3	Скидка 15%	Акция на выпечку	15.00	percentage	2024-01-10	2024-02-10	active	2026-10-02 13:47:44.710671+03
4	Скидка 20%	Скидка на торты	20.00	percentage	2024-01-15	2024-03-15	active	2026-10-02 13:47:44.710671+03
5	Скидка 25%	Скидка на круассаны	25.00	percentage	2024-01-05	2024-01-25	inactive	2026-10-02 13:47:44.710671+03
6	Скидка 30%	Распродажа	30.00	percentage	2024-01-20	2024-01-31	active	2026-10-02 13:47:44.710671+03
7	Скидка 50 руб	Фиксированная скидка	50.00	fixed	2024-01-01	2024-06-30	active	2026-10-02 13:47:44.710671+03
8	Скидка 100 руб	Скидка при покупке от 1000	100.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
9	Скидка 150 руб	Акция выходного дня	150.00	fixed	2024-01-13	2024-01-14	active	2026-10-02 13:47:44.710671+03
10	Скидка 200 руб	Скидка на новый год	200.00	fixed	2023-12-20	2024-01-10	inactive	2026-10-02 13:47:44.710671+03
11	Скидка именинника	Скидка в день рождения	20.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
12	Скидка на хлеб	Скидка на черный хлеб	10.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
13	Скидка на кофе	Скидка на кофейню	15.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
14	Акция 2+1	Третий товар в подарок	33.00	percentage	2024-01-15	2024-02-15	active	2026-10-02 13:47:44.710671+03
15	Скидка для студентов	По студенческому билету	10.00	percentage	2024-01-01	2024-06-30	active	2026-10-02 13:47:44.710671+03
16	Скидка для пенсионеров	По пенсионному удостоверению	15.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
17	Скидка 500 руб	Крупная покупка	500.00	fixed	2024-01-01	2024-12-31	inactive	2026-10-02 13:47:44.710671+03
18	Скидка 7%	Скидка по карте лояльности	7.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
19	Скидка 12%	Скидка на слойки	12.00	percentage	2024-01-10	2024-02-10	active	2026-10-02 13:47:44.710671+03
20	Скидка 18%	Скидка на пирожные	18.00	percentage	2024-01-05	2024-01-20	active	2026-10-02 13:47:44.710671+03
21	Скидка 3%	Минимальная скидка	3.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
22	Скидка 8%	Скидка на печенье	8.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
23	Скидка 22%	Скидка на авторские торты	22.00	percentage	2024-01-15	2024-03-15	active	2026-10-02 13:47:44.710671+03
24	Скидка 250 руб	Скидка на заказ	250.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
25	Скидка 300 руб	Скидка на корпоратив	300.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
26	Скидка 40%	Максимальная скидка	40.00	percentage	2024-01-25	2024-01-31	inactive	2026-10-02 13:47:44.710671+03
27	Скидка 6%	Скидка на багеты	6.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
28	Скидка 14%	Скидка на ватрушки	14.00	percentage	2024-01-10	2024-02-10	active	2026-10-02 13:47:44.710671+03
29	Скидка 16%	Скидка на пончики	16.00	percentage	2024-01-05	2024-01-25	active	2026-10-02 13:47:44.710671+03
30	Скидка 350 руб	Скидка на свадьбу	350.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
31	Скидка 400 руб	Скидка на юбилей	400.00	fixed	2024-01-01	2024-12-31	inactive	2026-10-02 13:47:44.710671+03
32	Скидка 9%	Скидка на кексы	9.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
33	Скидка 11%	Скидка на маффины	11.00	percentage	2024-01-10	2024-02-10	active	2026-10-02 13:47:44.710671+03
34	Скидка 13%	Скидка на рулеты	13.00	percentage	2024-01-05	2024-01-20	active	2026-10-02 13:47:44.710671+03
35	Скидка 450 руб	Скидка на фуршет	450.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
36	Скидка 2%	Скидка на сухари	2.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
37	Скидка 4%	Скидка на баранки	4.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
38	Скидка 17%	Скидка на пироги	17.00	percentage	2024-01-15	2024-02-15	active	2026-10-02 13:47:44.710671+03
39	Скидка 19%	Скидка на кулебяки	19.00	percentage	2024-01-05	2024-01-25	active	2026-10-02 13:47:44.710671+03
40	Скидка 600 руб	Скидка VIP клиент	600.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
41	Скидка 1%	Микро скидка	1.00	percentage	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
42	Скидка 21%	Скидка на штрудели	21.00	percentage	2024-01-10	2024-02-10	active	2026-10-02 13:47:44.710671+03
43	Скидка 23%	Скидка на хачапури	23.00	percentage	2024-01-05	2024-01-20	active	2026-10-02 13:47:44.710671+03
44	Скидка 700 руб	Скидка на банкет	700.00	fixed	2024-01-01	2024-12-31	inactive	2026-10-02 13:47:44.710671+03
45	Скидка 800 руб	Скидка на кейтеринг	800.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
46	Скидка 24%	Скидка на лаваш	24.00	percentage	2024-01-15	2024-03-15	active	2026-10-02 13:47:44.710671+03
47	Скидка 26%	Скидка на чиабатту	26.00	percentage	2024-01-05	2024-01-25	active	2026-10-02 13:47:44.710671+03
48	Скидка 900 руб	Скидка оптовикам	900.00	fixed	2024-01-01	2024-12-31	active	2026-10-02 13:47:44.710671+03
49	Скидка 27%	Скидка на фокаччу	27.00	percentage	2024-01-10	2024-02-10	active	2026-10-02 13:47:44.710671+03
50	Скидка 28%	Скидка на дарницкий	28.00	percentage	2024-01-05	2024-01-20	active	2026-10-02 13:47:44.710671+03
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, fullname, telephone_number, email, passport_data, date_birthday, date_employment, "position", base_salary, bonus, status, bakery_id, education) FROM stdin;
1	Иванов Иван Иванович	+79111000001	emp1@bakery.ru	4500 100001	1990-01-15	2020-05-10	Пекарь	60000.00	10000.00	active	1	Среднее специальное
2	Петров Петр Петрович	+79111000002	emp2@bakery.ru	4500 100002	1985-02-20	2021-02-15	Старший пекарь	80000.00	15000.00	active	2	Высшее
3	Сидоров Сидор Сидорович	+79111000003	emp3@bakery.ru	4500 100003	1992-03-25	2019-11-20	Кондитер	65000.00	12000.00	active	3	Среднее специальное
4	Кузнецов Алексей Васильев	+79111000004	emp4@bakery.ru	4500 100004	1988-04-10	2022-01-10	Директор	120000.00	30000.00	on_leave	4	Высшее
5	Смирнова Елена Сергеевна	+79111000005	emp5@bakery.ru	4500 100005	1995-05-12	2020-08-05	Кассир	45000.00	5000.00	dismissed	5	Среднее
6	Попов Андрей Николаевич	+79111000006	emp6@bakery.ru	4500 100006	1980-06-18	2018-04-12	Зам директора	100000.00	25000.00	on_leave	6	Высшее
7	Васильева Ольга Ивановна	+79111000007	emp7@bakery.ru	4500 100007	1993-07-22	2021-06-18	Уборщик	35000.00	3000.00	active	7	Среднее
8	Соколов Михаил Дмитриевич	+79111000008	emp8@bakery.ru	4500 100008	1987-08-30	2019-09-25	Пекарь	60000.00	10000.00	active	8	Среднее специальное
9	Михайлова Анна Петровна	+79111000009	emp9@bakery.ru	4500 100009	1991-09-14	2022-03-14	Кондитер	65000.00	12000.00	active	9	Высшее
10	Новиков Сергей Александров	+79111000010	emp10@bakery.ru	4500 100010	1984-10-01	2020-12-01	Технолог	90000.00	20000.00	active	10	Высшее
11	Федоров Дмитрий Олегович	+79111000011	emp11@bakery.ru	4500 100011	1996-11-11	2017-07-07	Грузчик	40000.00	4000.00	active	11	Среднее
12	Морозова Светлана Юрьевна	+79111000012	emp12@bakery.ru	4500 100012	1989-12-05	2021-10-10	Пекарь	60000.00	10000.00	active	12	Среднее специальное
13	Волкова Мария Игоревна	+79111000013	emp13@bakery.ru	4500 100013	1994-01-10	2019-05-22	Кондитер	65000.00	12000.00	dismissed	13	Высшее
14	Алексеев Константин Викт	+79111000014	emp14@bakery.ru	4500 100014	1982-02-28	2020-02-28	Директор	120000.00	30000.00	dismissed	14	Высшее
15	Лебедева Наталья Сергеев	+79111000015	emp15@bakery.ru	4500 100015	1997-03-05	2022-05-05	Кассир	45000.00	5000.00	active	15	Среднее
16	Семенов Артем Валерьевич	+79111000016	emp16@bakery.ru	4500 100016	1986-04-18	2021-01-15	Пекарь	60000.00	10000.00	on_leave	16	Среднее специальное
17	Егорова Татьяна Павловна	+79111000017	emp17@bakery.ru	4500 100017	1990-05-22	2018-11-11	Уборщик	35000.00	3000.00	active	17	Среднее
18	Козлов Игорь Станиславов	+79111000018	emp18@bakery.ru	4500 100018	1983-06-12	2022-08-20	Технолог	90000.00	20000.00	active	18	Высшее
19	Пономарева Юлия Андреевна	+79111000019	emp19@bakery.ru	4500 100019	1995-07-09	2020-04-10	Кондитер	65000.00	12000.00	active	19	Высшее
20	Орлов Виктор Михайлович	+79111000020	emp20@bakery.ru	4500 100020	1988-08-15	2016-03-03	Зам директора	100000.00	25000.00	active	20	Высшее
21	Макаров Евгений Олегович	+79111000021	emp21@bakery.ru	4500 100021	1992-09-20	2019-08-15	Пекарь	60000.00	10000.00	active	21	Среднее специальное
22	Андреева Оксана Дмитриевна	+79111000022	emp22@bakery.ru	4500 100022	1987-10-25	2021-12-12	Кондитер	65000.00	12000.00	active	22	Высшее
23	Ковалев Роман Сергеевич	+79111000023	emp23@bakery.ru	4500 100023	1994-11-11	2022-02-22	Грузчик	40000.00	4000.00	on_leave	23	Среднее
24	Ильина Вера Николаевна	+79111000024	emp24@bakery.ru	4500 100024	1981-12-01	2020-09-09	Директор	120000.00	30000.00	active	24	Высшее
25	Гусев Антон Викторович	+79111000025	emp25@bakery.ru	4500 100025	1996-01-15	2017-05-05	Уборщик	35000.00	3000.00	active	25	Среднее
26	Тарасова Ирина Борисовна	+79111000026	emp26@bakery.ru	4500 100026	1989-02-20	2021-03-30	Кассир	45000.00	5000.00	active	26	Среднее
27	Белов Денис Александрови	+79111000027	emp27@bakery.ru	4500 100027	1993-03-25	2022-04-04	Пекарь	60000.00	10000.00	active	27	Среднее специальное
28	Комарова Людмила Петровна	+79111000028	emp28@bakery.ru	4500 100028	1984-04-10	2020-10-10	Технолог	90000.00	20000.00	dismissed	28	Высшее
29	Орлова Галина Ивановна	+79111000029	emp29@bakery.ru	4500 100029	1997-05-12	2019-12-12	Кондитер	65000.00	12000.00	active	29	Высшее
30	Киселев Максим Игоревич	+79111000030	emp30@bakery.ru	4500 100030	1986-06-18	2018-08-08	Зам директора	100000.00	25000.00	dismissed	30	Высшее
31	Макарова Елена Сергеевна	+79111000031	emp31@bakery.ru	4500 100031	1991-07-22	2021-05-05	Пекарь	60000.00	10000.00	active	31	Среднее специальное
32	Андреев Павел Олегович	+79111000032	emp32@bakery.ru	4500 100032	1988-08-30	2020-01-15	Грузчик	40000.00	4000.00	active	32	Среднее
33	Воробьева Наталья Юрьевна	+79111000033	emp33@bakery.ru	4500 100033	1995-09-14	2019-06-20	Кассир	45000.00	5000.00	on_leave	33	Среднее
34	Новикова Анна Дмитриевна	+79111000034	emp34@bakery.ru	4500 100034	1982-10-01	2021-09-09	Кондитер	65000.00	12000.00	active	34	Высшее
35	Дмитриев Сергей Викторов	+79111000035	emp35@bakery.ru	4500 100035	1990-11-11	2018-02-14	Пекарь	60000.00	10000.00	active	35	Среднее специальное
36	Николаева Ольга Ивановна	+79111000036	emp36@bakery.ru	4500 100036	1985-12-05	2022-06-06	Уборщик	35000.00	3000.00	active	36	Среднее
37	Соловьев Артем Валерьевич	+79111000037	emp37@bakery.ru	4500 100037	1993-01-10	2020-03-20	Технолог	90000.00	20000.00	active	37	Высшее
38	Фронова Татьяна Павловна	+79111000038	emp38@bakery.ru	4500 100038	1987-02-28	2019-04-25	Директор	120000.00	30000.00	active	38	Высшее
39	Журавлев Виктор Михайлов	+79111000039	emp39@bakery.ru	4500 100039	1996-03-05	2020-07-07	Грузчик	40000.00	4000.00	active	39	Среднее
40	Корнева Вера Николаевна	+79111000040	emp40@bakery.ru	4500 100040	1981-04-18	2021-02-18	Кассир	45000.00	5000.00	active	40	Среднее
41	Александров Денис Алексан	+79111000041	emp41@bakery.ru	4500 100041	1992-05-22	2020-05-20	Пекарь	60000.00	10000.00	on_leave	41	Среднее специальное
42	Беляева Ирина Борисовна	+79111000042	emp42@bakery.ru	4500 100042	1989-06-12	2019-10-10	Кондитер	65000.00	12000.00	dismissed	42	Высшее
43	Смирнов Антон Викторович	+79111000043	emp43@bakery.ru	4500 100043	1994-07-09	2022-09-09	Зам директора	100000.00	25000.00	active	43	Высшее
44	Овчинникова Людмила Петр	+79111000044	emp44@bakery.ru	4500 100044	1986-08-15	2022-12-12	Уборщик	35000.00	3000.00	active	44	Среднее
45	Романова Галина Ивановна	+79111000045	emp45@bakery.ru	4500 100045	1991-09-20	2023-01-15	Технолог	90000.00	20000.00	on_leave	45	Высшее
46	Воронов Максим Игоревич	+79111000046	emp46@bakery.ru	4500 100046	1988-10-25	2020-05-20	Пекарь	60000.00	10000.00	active	46	Среднее специальное
47	Давыдова Елена Сергеевна	+79111000047	emp47@bakery.ru	4500 100047	1995-11-11	2019-04-25	Кассир	45000.00	5000.00	active	47	Среднее
48	Калинина Наталья Юрьевна	+79111000048	emp48@bakery.ru	4500 100048	1982-12-01	2021-11-11	Кондитер	65000.00	12000.00	active	48	Высшее
49	Степанов Павел Олегович	+79111000049	emp49@bakery.ru	4500 100049	1990-01-15	2020-05-20	Грузчик	40000.00	4000.00	on_leave	49	Среднее
50	Яковлева Анна Дмитриевна	+79111000050	emp50@bakery.ru	4500 100050	1985-02-20	2019-10-10	Директор	120000.00	30000.00	active	50	Высшее
\.


--
-- Data for Name: equipment_maintenance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment_maintenance (id, executing_company, master_name, master_phone, work_order_number, equipment_id, bakery_id, maintenance_type, status, planned_date, actual_date, description, cost, next_maintenance_date, created_at) FROM stdin;
1	ХолодМастер	Петров П.П.	+79000000137	З-001001	2	2	repair	completed	2026-05-11	2026-05-12	Замена изношенных деталей, восстановление работоспособности	8211.00	\N	2026-11-03 11:04:02.017033+03
2	ПекарьСервис	Сидоров С.С.	+79000000274	З-001002	3	3	inspection	completed	2026-05-15	2026-05-17	Проверка соответствия техническим требованиям	2194.00	\N	2026-11-03 11:04:02.017033+03
3	ТехноРемонт	Кузнецов А.В.	+79000000411	З-001003	4	4	calibration	in_progress	2026-05-19	\N	Калибровка датчиков и настройка параметров	4453.00	2026-08-20	2026-11-03 11:04:02.017033+03
4	ПродМашСервис	Смирнов В.А.	+79000000548	З-001004	5	5	preventive	planned	2026-05-23	\N	Плановая профилактика: чистка, смазка, проверка узлов	3548.00	\N	2026-11-03 11:04:02.017033+03
5	СервисПлюс ООО	Попов Д.М.	+79000000685	З-001005	6	6	repair	cancelled	2026-05-27	\N	Замена изношенных деталей, восстановление работоспособности	9055.00	\N	2026-11-03 11:04:02.017033+03
6	ХолодМастер	Волков К.Н.	+79000000822	З-001006	7	7	inspection	completed	2026-05-31	2026-05-31	Проверка соответствия техническим требованиям	2582.00	2026-09-04	2026-11-03 11:04:02.017033+03
7	ПекарьСервис	Соколов М.Е.	+79000000959	З-001007	8	8	calibration	completed	2026-06-04	2026-06-05	Калибровка датчиков и настройка параметров	5057.00	\N	2026-11-03 11:04:02.017033+03
8	ТехноРемонт	Михайлов Р.Т.	+79000001096	З-001008	9	9	preventive	completed	2026-06-08	2026-06-10	Плановая профилактика: чистка, смазка, проверка узлов	4096.00	\N	2026-11-03 11:04:02.017033+03
9	ПродМашСервис	Новиков Е.С.	+79000001233	З-001009	10	10	repair	in_progress	2026-06-12	\N	Замена изношенных деталей, восстановление работоспособности	9899.00	2026-09-19	2026-11-03 11:04:02.017033+03
10	СервисПлюс ООО	Иванов И.И.	+79000001370	З-001010	11	1	inspection	planned	2026-06-16	\N	Проверка соответствия техническим требованиям	2970.00	\N	2026-11-03 11:04:02.017033+03
11	ХолодМастер	Петров П.П.	+79000001507	З-001011	12	2	calibration	cancelled	2026-06-20	\N	Калибровка датчиков и настройка параметров	5661.00	\N	2026-11-03 11:04:02.017033+03
12	ПекарьСервис	Сидоров С.С.	+79000001644	З-001012	13	3	preventive	completed	2026-06-24	2026-06-24	Плановая профилактика: чистка, смазка, проверка узлов	4644.00	2026-10-04	2026-11-03 11:04:02.017033+03
13	ТехноРемонт	Кузнецов А.В.	+79000001781	З-001013	14	4	repair	completed	2026-06-28	2026-06-29	Замена изношенных деталей, восстановление работоспособности	10743.00	\N	2026-11-03 11:04:02.017033+03
14	ПродМашСервис	Смирнов В.А.	+79000001918	З-001014	15	5	inspection	completed	2026-07-02	2026-07-04	Проверка соответствия техническим требованиям	3358.00	\N	2026-11-03 11:04:02.017033+03
15	СервисПлюс ООО	Попов Д.М.	+79000002055	З-001015	16	6	calibration	in_progress	2026-07-06	\N	Калибровка датчиков и настройка параметров	6265.00	2026-10-19	2026-11-03 11:04:02.017033+03
16	ХолодМастер	Волков К.Н.	+79000002192	З-001016	17	7	preventive	planned	2026-07-10	\N	Плановая профилактика: чистка, смазка, проверка узлов	5192.00	\N	2026-11-03 11:04:02.017033+03
17	ПекарьСервис	Соколов М.Е.	+79000002329	З-001017	18	8	repair	cancelled	2026-07-14	\N	Замена изношенных деталей, восстановление работоспособности	11587.00	\N	2026-11-03 11:04:02.017033+03
18	ТехноРемонт	Михайлов Р.Т.	+79000002466	З-001018	19	9	inspection	completed	2026-07-18	2026-07-18	Проверка соответствия техническим требованиям	3746.00	2026-11-03	2026-11-03 11:04:02.017033+03
19	ПродМашСервис	Новиков Е.С.	+79000002603	З-001019	20	10	calibration	completed	2026-07-22	2026-07-23	Калибровка датчиков и настройка параметров	6869.00	\N	2026-11-03 11:04:02.017033+03
20	СервисПлюс ООО	Иванов И.И.	+79000002740	З-001020	21	1	preventive	completed	2026-07-26	2026-07-28	Плановая профилактика: чистка, смазка, проверка узлов	5740.00	\N	2026-11-03 11:04:02.017033+03
21	ХолодМастер	Петров П.П.	+79000002877	З-001021	22	2	repair	in_progress	2026-07-30	\N	Замена изношенных деталей, восстановление работоспособности	12431.00	2026-11-18	2026-11-03 11:04:02.017033+03
22	ПекарьСервис	Сидоров С.С.	+79000003014	З-001022	23	3	inspection	planned	2026-08-03	\N	Проверка соответствия техническим требованиям	4134.00	\N	2026-11-03 11:04:02.017033+03
23	ТехноРемонт	Кузнецов А.В.	+79000003151	З-001023	24	4	calibration	cancelled	2026-08-07	\N	Калибровка датчиков и настройка параметров	7473.00	\N	2026-11-03 11:04:02.017033+03
24	ПродМашСервис	Смирнов В.А.	+79000003288	З-001024	25	5	preventive	completed	2026-08-11	2026-08-11	Плановая профилактика: чистка, смазка, проверка узлов	6288.00	2026-12-03	2026-11-03 11:04:02.017033+03
25	СервисПлюс ООО	Попов Д.М.	+79000003425	З-001025	26	6	repair	completed	2026-08-15	2026-08-16	Замена изношенных деталей, восстановление работоспособности	13275.00	\N	2026-11-03 11:04:02.017033+03
26	ХолодМастер	Волков К.Н.	+79000003562	З-001026	27	7	inspection	completed	2026-08-19	2026-08-21	Проверка соответствия техническим требованиям	4522.00	\N	2026-11-03 11:04:02.017033+03
27	ПекарьСервис	Соколов М.Е.	+79000003699	З-001027	28	8	calibration	in_progress	2026-08-23	\N	Калибровка датчиков и настройка параметров	8077.00	2026-12-18	2026-11-03 11:04:02.017033+03
28	ТехноРемонт	Михайлов Р.Т.	+79000003836	З-001028	29	9	preventive	planned	2026-08-27	\N	Плановая профилактика: чистка, смазка, проверка узлов	6836.00	\N	2026-11-03 11:04:02.017033+03
29	ПродМашСервис	Новиков Е.С.	+79000003973	З-001029	30	10	repair	cancelled	2026-08-31	\N	Замена изношенных деталей, восстановление работоспособности	14119.00	\N	2026-11-03 11:04:02.017033+03
30	СервисПлюс ООО	Иванов И.И.	+79000004110	З-001030	1	1	inspection	completed	2026-09-04	2026-09-04	Проверка соответствия техническим требованиям	4910.00	2027-01-02	2026-11-03 11:04:02.017033+03
31	ХолодМастер	Петров П.П.	+79000004247	З-001031	2	2	calibration	completed	2026-09-08	2026-09-09	Калибровка датчиков и настройка параметров	8681.00	\N	2026-11-03 11:04:02.017033+03
32	ПекарьСервис	Сидоров С.С.	+79000004384	З-001032	3	3	preventive	completed	2026-09-12	2026-09-14	Плановая профилактика: чистка, смазка, проверка узлов	7384.00	\N	2026-11-03 11:04:02.017033+03
33	ТехноРемонт	Кузнецов А.В.	+79000004521	З-001033	4	4	repair	in_progress	2026-09-16	\N	Замена изношенных деталей, восстановление работоспособности	14963.00	2027-01-17	2026-11-03 11:04:02.017033+03
34	ПродМашСервис	Смирнов В.А.	+79000004658	З-001034	5	5	inspection	planned	2026-09-20	\N	Проверка соответствия техническим требованиям	2298.00	\N	2026-11-03 11:04:02.017033+03
35	СервисПлюс ООО	Попов Д.М.	+79000004795	З-001035	6	6	calibration	cancelled	2026-09-24	\N	Калибровка датчиков и настройка параметров	9285.00	\N	2026-11-03 11:04:02.017033+03
36	ХолодМастер	Волков К.Н.	+79000004932	З-001036	7	7	preventive	completed	2026-09-28	2026-09-28	Плановая профилактика: чистка, смазка, проверка узлов	7932.00	2027-02-01	2026-11-03 11:04:02.017033+03
37	ПекарьСервис	Соколов М.Е.	+79000005069	З-001037	8	8	repair	completed	2026-10-02	2026-10-03	Замена изношенных деталей, восстановление работоспособности	15807.00	\N	2026-11-03 11:04:02.017033+03
38	ТехноРемонт	Михайлов Р.Т.	+79000005206	З-001038	9	9	inspection	completed	2026-10-06	2026-10-08	Проверка соответствия техническим требованиям	2686.00	\N	2026-11-03 11:04:02.017033+03
39	ПродМашСервис	Новиков Е.С.	+79000005343	З-001039	10	10	calibration	in_progress	2026-10-10	\N	Калибровка датчиков и настройка параметров	9889.00	2027-02-16	2026-11-03 11:04:02.017033+03
40	СервисПлюс ООО	Иванов И.И.	+79000005480	З-001040	11	1	preventive	planned	2026-10-14	\N	Плановая профилактика: чистка, смазка, проверка узлов	3480.00	\N	2026-11-03 11:04:02.017033+03
41	ХолодМастер	Петров П.П.	+79000005617	З-001041	12	2	repair	cancelled	2026-10-18	\N	Замена изношенных деталей, восстановление работоспособности	16651.00	\N	2026-11-03 11:04:02.017033+03
42	ПекарьСервис	Сидоров С.С.	+79000005754	З-001042	13	3	inspection	completed	2026-10-22	2026-10-22	Проверка соответствия техническим требованиям	3074.00	2027-03-03	2026-11-03 11:04:02.017033+03
43	ТехноРемонт	Кузнецов А.В.	+79000005891	З-001043	14	4	calibration	completed	2026-10-26	2026-10-27	Калибровка датчиков и настройка параметров	4493.00	\N	2026-11-03 11:04:02.017033+03
44	ПродМашСервис	Смирнов В.А.	+79000006028	З-001044	15	5	preventive	completed	2026-10-30	2026-11-01	Плановая профилактика: чистка, смазка, проверка узлов	4028.00	\N	2026-11-03 11:04:02.017033+03
45	СервисПлюс ООО	Попов Д.М.	+79000006165	З-001045	16	6	repair	in_progress	2026-11-03	\N	Замена изношенных деталей, восстановление работоспособности	17495.00	2027-03-18	2026-11-03 11:04:02.017033+03
46	ХолодМастер	Волков К.Н.	+79000006302	З-001046	17	7	inspection	planned	2026-11-07	\N	Проверка соответствия техническим требованиям	3462.00	\N	2026-11-03 11:04:02.017033+03
47	ПекарьСервис	Соколов М.Е.	+79000006439	З-001047	18	8	calibration	cancelled	2026-11-11	\N	Калибровка датчиков и настройка параметров	5097.00	\N	2026-11-03 11:04:02.017033+03
48	ТехноРемонт	Михайлов Р.Т.	+79000006576	З-001048	19	9	preventive	completed	2026-11-15	2026-11-15	Плановая профилактика: чистка, смазка, проверка узлов	4576.00	2027-04-02	2026-11-03 11:04:02.017033+03
49	ПродМашСервис	Новиков Е.С.	+79000006713	З-001049	20	10	repair	completed	2026-11-19	2026-11-20	Замена изношенных деталей, восстановление работоспособности	18339.00	\N	2026-11-03 11:04:02.017033+03
50	СервисПлюс ООО	Иванов И.И.	+79000006850	З-001050	21	1	inspection	completed	2026-11-23	2026-11-25	Проверка соответствия техническим требованиям	3850.00	\N	2026-11-03 11:04:02.017033+03
\.


--
-- Data for Name: equipment_units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment_units (id, type, description, name, service_life, warranty_period, last_maintenance_date, status, brand, purchase_date, warehouse_id) FROM stdin;
1	Печь	Конвекционная печь на 6 уровней	Печь конвекц.	3650	365	2023-10-01	active	Bongard	2020-05-10	1
2	Миксер	Спиральный тестомес 60л	Тестомес	2500	180	2023-11-15	active	Diosna	2021-02-15	2
3	Холодильник	Шкаф холодильный 1400л	Шкаф холод.	3650	730	2023-09-20	active	Polair	2019-11-20	3
4	Весы	Электронные весы до 150кг	Весы напольн.	1800	365	2023-12-01	written_off	CAS	2018-04-12	4
5	Тестоделитель	Порционный делитель теста	Делитель теста	2000	365	2023-08-10	active	Rondo	2022-01-10	5
6	Расстоечный шкаф	Шкаф расстойки на 16 тележек	Расстойка	3000	365	2023-10-25	active	Wachtel	2021-06-18	6
7	Микроволновка	Промышленная СВЧ печь	СВЧ печь	1500	180	2023-07-05	in_repair	Panasonic	2019-09-25	7
8	Блендер	Погружной блендер 20л	Пром. блендер	1200	180	2023-11-10	active	Robot Coupe	2022-03-14	8
9	Слайсер	Автоматическая хлеборезка	Хлеборезка	2500	365	2023-09-15	active	Graef	2020-12-01	9
10	Мойка	Купольная посудомоечная машина	Посудомойка	2000	365	2023-10-05	active	Hobart	2018-11-11	10
11	Соковыжималка	Шнековая соковыжималка	Пром. соковиж.	1000	180	2023-12-10	active	Zumex	2021-10-10	11
12	Кофемолка	Профессиональная мясорубка	Мясорубка	1500	180	2023-08-20	written_off	Sirman	2019-05-22	12
13	Тестоформовоч	Тестоформовочная машина	Формовочная	2500	365	2023-11-01	active	Rondo	2020-02-28	13
14	Ламинатор	Машина для слоеного теста	Тестоламинат.	3000	365	2023-09-25	active	Rondo	2022-05-05	14
15	Фритюр	Промышленная фритюрница 15л	Фритюрница	1200	180	2023-10-15	in_repair	Frymaster	2021-01-15	15
16	Гриль	Гриль для выпечки и жарки	Конвекц. гриль	2000	365	2023-12-05	active	Rational	2020-04-10	16
17	Варочный котел	Наклонный варочный котел 100л	Котел варочный	3650	365	2023-08-15	active	Tefal	2017-07-07	17
18	Мороженица	Фризер для мягкого мороженого	Фризер	1500	365	2023-11-20	active	Carpigiani	2022-08-20	18
19	Вафельница	Ротационная вафельница	Пром. вафельн.	1000	180	2023-09-10	active	Stalgast	2020-09-09	19
20	Тостер	Конвейерный тостер	Конвейер. тост	1200	180	2023-10-20	active	Bunn	2021-07-07	20
21	Льдогенератор	Произв-сть 50кг/сутки	Генератор льда	2500	365	2023-12-15	written_off	Hoshizaki	2018-11-11	21
22	Сушильный шкаф	Для сушки зелени и фруктов	Шкаф сушильн.	2000	365	2023-08-05	active	Exid	2019-01-25	22
23	Упаковщик	Настольный вакуумный упаковщик	Вакуумный упако	1500	180	2023-11-05	active	VacMaster	2022-02-22	23
24	Запайщик	Полуавтоматический запайщик	Запайчик лотков	1800	365	2023-09-30	active	Sirman	2020-06-18	24
25	Шкаф выпечки	Шкаф для разогрева выпечки	Шкаф разогрева	1500	365	2023-10-10	in_repair	Rational	2017-05-05	25
26	Машина мытья	Автомат для мытья яиц	Машина для яиц	2000	365	2023-12-20	active	Moba	2021-03-30	26
27	Дозатор	Дозатор для жидких ингредиентов	Жидкий дозатор	1200	180	2023-08-25	active	Bizerba	2022-04-04	27
28	Смеситель	Смеситель для сыпучих продуктов	Смеситель сыпуч	2500	365	2023-11-15	active	Diosna	2020-10-10	28
29	Просеиватель	Вибрационный просеиватель	Просеив. муки	3000	365	2023-09-05	active	Diosna	2019-12-12	29
30	Машина нарезки	Машина для нарезки багета	Машина нарезки	1500	180	2023-10-30	active	Graef	2018-08-08	30
31	Весы порцион.	Порционные весы до 5кг	Весы порцион.	1000	180	2023-12-25	written_off	CAS	2021-05-05	31
32	Термометр	Цифровой термометр-щуп	Щуп термометр	500	90	2023-08-30	active	Testo	2020-01-15	32
33	pH-метр	pH-метр для теста	Измеритель pH	800	180	2023-11-25	active	Hanna	2019-06-20	33
34	Влагомер	Влагомер для муки и зерна	Влагомер зерна	1000	180	2023-09-15	active	Pfeuffer	2021-09-09	34
35	Стол производ.	Производственный стол 1.5м	Стол из нержав.	5000	0	2023-10-05	active	Stalgast	2018-02-14	35
36	Стеллаж	Усиленный стеллаж до 500кг	Стеллаж груз.	5000	0	2023-12-10	active	Mebelberg	2022-06-06	36
37	Тележка	Грузовая тележка 300кг	Тележка груз.	3000	0	2023-08-10	active	Roxon	2020-03-20	37
38	Тележка хлеб.	Тележка-витрина для хлеба	Тележка для хлеба	2000	0	2023-11-05	active	Bartscher	2019-04-25	38
39	Витрина	Холодильная витрина 1.2м	Витрина охлажд.	2500	365	2023-09-20	active	Polair	2020-07-07	39
40	Касса	Кассовый терминал с весами	POS-терминал	1500	365	2023-10-15	active	Atol	2021-02-18	40
41	Принтер	Термопринтер этикеток	Принтер этикет	1200	180	2023-12-05	active	Zebra	2022-09-09	41
42	Сканер	2D сканер штрих-кодов	Сканер штрихко	1000	180	2023-08-20	written_off	Honeywell	2019-10-10	42
43	Кондиционер	Промышленный кондиционер 24кBTU	Сплит-система	3650	730	2023-11-10	active	Daikin	2018-05-20	43
44	Вентиляция	Вытяжной зонт с фильтрами	Вытяжной зонт	5000	365	2023-09-25	active	Systemair	2020-05-20	44
45	Освещение	Светодиодные панели 60х60	LED панели	10000	1000	2023-10-20	active	Philips	2019-10-10	45
46	Пожарная сист	Система пожарной сигнализации	Датчики дыма	5000	365	2023-12-15	active	Bolid	2019-04-25	46
47	Охрана	IP камеры видеонаблюдения	Камеры видеон.	3000	365	2023-08-05	active	Hikvision	2020-05-20	47
48	Роутер	Промышленный Wi-Fi роутер	Wi-Fi роутер	1500	180	2023-11-20	active	MikroTik	2019-10-10	48
49	ИБП	ИБП для кассового оборудования	Источник бесп	2000	365	2023-09-10	in_repair	APC	2018-02-14	49
50	Генератор	Резервный генератор 10кВт	Бензогенератор	3650	365	2023-10-05	active	Honda	2021-05-05	50
\.


--
-- Data for Name: ingredient_price_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredient_price_history (id, supplier_id, ingredient_id, price_for_unit, unit_type, status, start_date, end_date, created_at) FROM stdin;
1	2	2	507.19	л	active	2023-01-16 00:00:00	2023-04-16 00:00:00	2026-10-29 12:40:15.795386+03
2	3	3	503.74	г	active	2023-01-31 00:00:00	2023-05-01 00:00:00	2026-10-29 12:40:15.795386+03
3	4	4	42.32	упак	inactive	2023-02-15 00:00:00	\N	2026-10-29 12:40:15.795386+03
4	5	5	494.72	г	active	2023-03-02 00:00:00	2023-05-31 00:00:00	2026-10-29 12:40:15.795386+03
5	6	6	318.36	кг	active	2023-03-17 00:00:00	2023-06-15 00:00:00	2026-10-29 12:40:15.795386+03
6	7	7	281.95	г	active	2023-04-01 00:00:00	\N	2026-10-29 12:40:15.795386+03
7	8	8	365.15	шт	active	2023-04-16 00:00:00	2023-07-15 00:00:00	2026-10-29 12:40:15.795386+03
8	9	9	196.27	г	active	2023-05-01 00:00:00	2023-07-30 00:00:00	2026-10-29 12:40:15.795386+03
9	10	10	446.04	шт	active	2023-05-16 00:00:00	\N	2026-10-29 12:40:15.795386+03
10	11	11	340.51	кг	active	2023-05-31 00:00:00	2023-08-29 00:00:00	2026-10-29 12:40:15.795386+03
11	12	12	30.64	упак	active	2023-06-15 00:00:00	2023-09-13 00:00:00	2026-10-29 12:40:15.795386+03
12	13	13	45.53	г	inactive	2023-06-30 00:00:00	\N	2026-10-29 12:40:15.795386+03
13	14	14	477.97	кг	active	2023-07-15 00:00:00	2023-10-13 00:00:00	2026-10-29 12:40:15.795386+03
14	15	15	385.24	л	inactive	2023-07-30 00:00:00	2023-10-28 00:00:00	2026-10-29 12:40:15.795386+03
15	16	16	40.01	кг	active	2023-08-14 00:00:00	\N	2026-10-29 12:40:15.795386+03
16	17	17	68.55	г	inactive	2023-08-29 00:00:00	2023-11-27 00:00:00	2026-10-29 12:40:15.795386+03
17	18	18	112.45	л	active	2023-09-13 00:00:00	2023-12-12 00:00:00	2026-10-29 12:40:15.795386+03
18	19	19	82.93	кг	inactive	2023-09-28 00:00:00	\N	2026-10-29 12:40:15.795386+03
19	20	20	218.52	упак	inactive	2023-10-13 00:00:00	2024-01-11 00:00:00	2026-10-29 12:40:15.795386+03
20	21	21	137.34	л	inactive	2023-10-28 00:00:00	2024-01-26 00:00:00	2026-10-29 12:40:15.795386+03
21	22	22	457.53	л	active	2023-11-12 00:00:00	\N	2026-10-29 12:40:15.795386+03
22	23	23	480.54	г	active	2023-11-27 00:00:00	2024-02-25 00:00:00	2026-10-29 12:40:15.795386+03
23	24	24	210.87	кг	active	2023-12-12 00:00:00	2024-03-11 00:00:00	2026-10-29 12:40:15.795386+03
24	25	25	318.25	г	inactive	2023-12-27 00:00:00	\N	2026-10-29 12:40:15.795386+03
25	26	26	273.38	л	active	2024-01-11 00:00:00	2024-04-10 00:00:00	2026-10-29 12:40:15.795386+03
26	27	27	286.68	л	inactive	2024-01-26 00:00:00	2024-04-25 00:00:00	2026-10-29 12:40:15.795386+03
27	28	28	26.78	шт	active	2024-02-10 00:00:00	\N	2026-10-29 12:40:15.795386+03
28	29	29	423.35	шт	active	2024-02-25 00:00:00	2024-05-25 00:00:00	2026-10-29 12:40:15.795386+03
29	30	30	306.94	г	active	2024-03-11 00:00:00	2024-06-09 00:00:00	2026-10-29 12:40:15.795386+03
30	31	31	484.89	г	active	2024-03-26 00:00:00	\N	2026-10-29 12:40:15.795386+03
31	32	32	202.84	упак	active	2024-04-10 00:00:00	2024-07-09 00:00:00	2026-10-29 12:40:15.795386+03
32	33	33	427.87	упак	active	2024-04-25 00:00:00	2024-07-24 00:00:00	2026-10-29 12:40:15.795386+03
33	34	34	385.12	шт	active	2024-05-10 00:00:00	\N	2026-10-29 12:40:15.795386+03
34	35	35	40.80	л	active	2024-05-25 00:00:00	2024-08-23 00:00:00	2026-10-29 12:40:15.795386+03
35	36	36	257.15	г	active	2024-06-09 00:00:00	2024-09-07 00:00:00	2026-10-29 12:40:15.795386+03
36	37	37	110.46	л	active	2024-06-24 00:00:00	\N	2026-10-29 12:40:15.795386+03
37	38	38	390.95	кг	active	2024-07-09 00:00:00	2024-10-07 00:00:00	2026-10-29 12:40:15.795386+03
38	39	39	124.28	упак	active	2024-07-24 00:00:00	2024-10-22 00:00:00	2026-10-29 12:40:15.795386+03
39	40	40	492.14	шт	active	2024-08-08 00:00:00	\N	2026-10-29 12:40:15.795386+03
40	41	41	25.86	л	inactive	2024-08-23 00:00:00	2024-11-21 00:00:00	2026-10-29 12:40:15.795386+03
41	42	42	338.55	кг	active	2024-09-07 00:00:00	2024-12-06 00:00:00	2026-10-29 12:40:15.795386+03
42	43	43	222.36	упак	inactive	2024-09-22 00:00:00	\N	2026-10-29 12:40:15.795386+03
43	44	44	238.91	л	inactive	2024-10-07 00:00:00	2025-01-05 00:00:00	2026-10-29 12:40:15.795386+03
44	45	45	33.33	упак	active	2024-10-22 00:00:00	2025-01-20 00:00:00	2026-10-29 12:40:15.795386+03
45	46	46	271.68	кг	active	2024-11-06 00:00:00	\N	2026-10-29 12:40:15.795386+03
46	47	47	213.69	упак	inactive	2024-11-21 00:00:00	2025-02-19 00:00:00	2026-10-29 12:40:15.795386+03
47	48	48	18.43	кг	active	2024-12-06 00:00:00	2025-03-06 00:00:00	2026-10-29 12:40:15.795386+03
48	49	49	95.08	шт	inactive	2024-12-21 00:00:00	\N	2026-10-29 12:40:15.795386+03
49	50	50	124.98	кг	inactive	2025-01-05 00:00:00	2025-04-05 00:00:00	2026-10-29 12:40:15.795386+03
50	1	1	235.25	г	active	2025-01-20 00:00:00	2025-04-20 00:00:00	2026-10-29 12:40:15.795386+03
\.


--
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredients (id, name, description, unit_type, storage_temp_min, storage_temp_max, barcode, allergen_info, country_from_origin, created_at) FROM stdin;
1	Мука пшеничная в/с	Высший сорт	kg	5.0	20.0	4600000000001	Gluten	Russia	2026-10-02 12:58:26.191319+03
2	Мука ржаная	Обдирная	kg	5.0	20.0	4600000000002	Gluten	Russia	2026-10-02 12:58:26.191319+03
3	Сахар-песок	Белый сахар	kg	5.0	25.0	4600000000003	None	Russia	2026-10-02 12:58:26.191319+03
4	Сахарная пудра	Мелкий помол	kg	5.0	25.0	4600000000004	None	Russia	2026-10-02 12:58:26.191319+03
5	Соль пищевая	Экстра	kg	5.0	30.0	4600000000005	None	Russia	2026-10-02 12:58:26.191319+03
6	Дрожжи сухие	Инстантные	kg	2.0	15.0	4600000000006	None	France	2026-10-02 12:58:26.191319+03
7	Дрожжи прессованные	Живые дрожжи	kg	0.0	8.0	4600000000007	None	Russia	2026-10-02 12:58:26.191319+03
8	Масло сливочное 82%	Традиционное	kg	2.0	6.0	4600000000008	Dairy	Russia	2026-10-02 12:58:26.191319+03
9	Масло подсолнечное	Рафинированное	l	5.0	20.0	4600000000009	None	Russia	2026-10-02 12:58:26.191319+03
10	Молоко цельное	Пастеризованное	l	2.0	6.0	4600000000010	Dairy	Russia	2026-10-02 12:58:26.191319+03
11	Яйцо куриное С1	Столовое	pcs	2.0	10.0	4600000000011	Eggs	Russia	2026-10-02 12:58:26.191319+03
12	Меланж яичный	Замороженный	kg	-18.0	-12.0	4600000000012	Eggs	Russia	2026-10-02 12:58:26.191319+03
13	Вода питьевая	Артезианская	l	5.0	20.0	4600000000013	None	Russia	2026-10-02 12:58:26.191319+03
14	Разрыхлитель теста	Пекарский порошок	kg	5.0	25.0	4600000000014	None	Germany	2026-10-02 12:58:26.191319+03
15	Сода пищевая	Бикарбонат натрия	kg	5.0	25.0	4600000000015	None	Russia	2026-10-02 12:58:26.191319+03
16	Уксус столовый 9%	Пищевой	l	5.0	20.0	4600000000016	None	Russia	2026-10-02 12:58:26.191319+03
17	Ванилин	Кристаллический	kg	5.0	20.0	4600000000017	None	France	2026-10-02 12:58:26.191319+03
18	Корица молотая	Специя	kg	5.0	20.0	4600000000018	None	Sri Lanka	2026-10-02 12:58:26.191319+03
19	Какао-порошок	Обезжиренный	kg	5.0	20.0	4600000000019	None	Ivory Coast	2026-10-02 12:58:26.191319+03
20	Шоколад темный	Кондитерский	kg	12.0	18.0	4600000000020	Dairy, Soy	Belgium	2026-10-02 12:58:26.191319+03
21	Орехи грецкие	Очищенные	kg	5.0	15.0	4600000000021	Nuts	Moldova	2026-10-02 12:58:26.191319+03
22	Изюм светлый	Без косточек	kg	5.0	15.0	4600000000022	Sulfites	Uzbekistan	2026-10-02 12:58:26.191319+03
23	Мак пищевой	Кондитерский	kg	5.0	20.0	4600000000023	None	Russia	2026-10-02 12:58:26.191319+03
24	Кунжут белый	Семена	kg	5.0	20.0	4600000000024	Sesame	India	2026-10-02 12:58:26.191319+03
25	Семена льна	Целые	kg	5.0	20.0	4600000000025	None	Russia	2026-10-02 12:58:26.191319+03
26	Мед натуральный	Цветочный	kg	5.0	20.0	4600000000026	None	Russia	2026-10-02 12:58:26.191319+03
27	Патока крахмальная	Светлая	kg	5.0	15.0	4600000000027	None	Russia	2026-10-02 12:58:26.191319+03
28	Желатин листовой	200 блум	kg	5.0	25.0	4600000000028	None	France	2026-10-02 12:58:26.191319+03
29	Агар-агар	Растительный	kg	5.0	25.0	4600000000029	None	Japan	2026-10-02 12:58:26.191319+03
30	Пектин яблочный	Желирующее вещество	kg	5.0	25.0	4600000000030	None	Poland	2026-10-02 12:58:26.191319+03
31	Крахмал кукурузный	Пищевой	kg	5.0	25.0	4600000000031	None	Russia	2026-10-02 12:58:26.191319+03
32	Сливки 33%	Пастеризованные	l	2.0	6.0	4600000000032	Dairy	Russia	2026-10-02 12:58:26.191319+03
33	Творог 9%	Зерненый	kg	2.0	6.0	4600000000033	Dairy	Russia	2026-10-02 12:58:26.191319+03
34	Сыр Гауда	Твердый	kg	2.0	8.0	4600000000034	Dairy	Netherlands	2026-10-02 12:58:26.191319+03
35	Ветчина	Рубленая	kg	0.0	6.0	4600000000035	None	Russia	2026-10-02 12:58:26.191319+03
36	Грибы шампиньоны	Свежие	kg	2.0	6.0	4600000000036	None	Russia	2026-10-02 12:58:26.191319+03
37	Лук репчатый	Свежий	kg	2.0	10.0	4600000000037	None	Russia	2026-10-02 12:58:26.191319+03
38	Чеснок	Свежий	kg	2.0	10.0	4600000000038	None	China	2026-10-02 12:58:26.191319+03
39	Укроп свежий	Зелень	kg	0.0	5.0	4600000000039	None	Russia	2026-10-02 12:58:26.191319+03
40	Петрушка	Зелень	kg	0.0	5.0	4600000000040	None	Russia	2026-10-02 12:58:26.191319+03
41	Базилик	Зелень	kg	0.0	5.0	4600000000041	None	Russia	2026-10-02 12:58:26.191319+03
42	Перец черный	Молотый	kg	5.0	20.0	4600000000042	None	Vietnam	2026-10-02 12:58:26.191319+03
43	Лавровый лист	Специя	kg	5.0	20.0	4600000000043	None	Russia	2026-10-02 12:58:26.191319+03
44	Гвоздика	Специя	kg	5.0	20.0	4600000000044	None	Madagascar	2026-10-02 12:58:26.191319+03
45	Мускатный орех	Молотый	kg	5.0	20.0	4600000000045	None	Indonesia	2026-10-02 12:58:26.191319+03
46	Имбирь	Молотый	kg	5.0	20.0	4600000000046	None	India	2026-10-02 12:58:26.191319+03
47	Кардамон	Зерна	kg	5.0	20.0	4600000000047	None	Guatemala	2026-10-02 12:58:26.191319+03
48	Паприка	Молотая	kg	5.0	20.0	4600000000048	None	Spain	2026-10-02 12:58:26.191319+03
49	Куркума	Молотая	kg	5.0	20.0	4600000000049	None	India	2026-10-02 12:58:26.191319+03
50	Кориандр	Молотый	kg	5.0	20.0	4600000000050	None	Russia	2026-10-02 12:58:26.191319+03
\.


--
-- Data for Name: inventory_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_ingredients (id, warehouse_id, ingredient_id, quantity, expiration_date, date_last_update) FROM stdin;
1	1	1	500.00	2024-06-15	2024-01-15
2	1	2	300.00	2024-06-10	2024-01-15
3	2	3	400.00	2025-01-20	2024-01-15
4	2	4	150.00	2025-01-20	2024-01-15
5	3	5	200.00	2025-12-31	2024-01-15
6	3	6	50.00	2024-08-10	2024-01-15
7	4	7	80.00	2024-03-15	2024-01-15
8	4	8	120.00	2024-02-28	2024-01-15
9	5	9	200.00	2024-12-31	2024-01-15
10	5	10	300.00	2024-02-10	2024-01-15
11	6	11	1000.00	2024-02-05	2024-01-15
12	6	12	150.00	2024-07-20	2024-01-15
13	7	13	5000.00	2025-12-31	2024-01-15
14	7	14	100.00	2025-06-30	2024-01-15
15	8	15	80.00	2025-12-31	2024-01-15
16	8	16	150.00	2024-12-31	2024-01-15
17	9	17	20.00	2025-06-30	2024-01-15
18	9	18	30.00	2025-06-30	2024-01-15
19	10	19	50.00	2025-03-31	2024-01-15
20	10	20	80.00	2024-09-15	2024-01-15
21	11	21	40.00	2024-10-20	2024-01-15
22	11	22	60.00	2024-11-30	2024-01-15
23	12	23	25.00	2025-06-30	2024-01-15
24	12	24	35.00	2025-06-30	2024-01-15
25	13	25	20.00	2025-06-30	2024-01-15
26	13	26	40.00	2025-01-31	2024-01-15
27	14	27	100.00	2024-12-31	2024-01-15
28	14	28	30.00	2025-06-30	2024-01-15
29	15	29	25.00	2025-06-30	2024-01-15
30	15	30	40.00	2025-06-30	2024-01-15
31	16	\N	50.00	2024-01-17	2024-01-15
32	16	\N	40.00	2024-01-18	2024-01-15
33	17	\N	60.00	2024-01-17	2024-01-15
34	17	\N	30.00	2024-01-16	2024-01-15
35	18	\N	80.00	2024-01-19	2024-01-15
36	18	\N	70.00	2024-01-19	2024-01-15
37	19	\N	100.00	2024-01-17	2024-01-15
38	19	\N	90.00	2024-01-17	2024-01-15
39	20	\N	25.00	2024-01-19	2024-01-15
40	20	\N	30.00	2024-01-18	2024-01-15
41	21	\N	10.00	2024-01-21	2024-01-15
42	21	\N	12.00	2024-01-20	2024-01-15
43	22	\N	150.00	2024-07-15	2024-01-15
44	22	\N	140.00	2024-07-15	2024-01-15
45	23	\N	50.00	2024-04-15	2024-01-15
46	23	\N	60.00	2024-01-17	2024-01-15
47	24	\N	55.00	2024-01-17	2024-01-15
48	24	\N	65.00	2024-01-18	2024-01-15
49	25	\N	20.00	2024-01-17	2024-01-15
50	25	\N	18.00	2024-01-17	2024-01-15
\.


--
-- Data for Name: inventory_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_products (id, warehouse_id, product_id, quantity, expiration_date, date_last_update) FROM stdin;
1	1	1	150.00	2026-10-16	2026-10-15
2	1	2	120.00	2026-10-16	2026-10-15
3	1	3	80.00	2026-10-17	2026-10-15
4	1	4	60.00	2026-10-17	2026-10-15
5	1	5	100.00	2026-10-18	2026-10-15
6	1	6	90.00	2026-10-18	2026-10-15
7	1	16	15.00	2026-10-19	2026-10-15
8	1	17	12.00	2026-10-19	2026-10-15
9	1	18	10.00	2026-10-20	2026-10-15
10	2	1	45.00	2026-10-16	2026-10-15
11	2	2	38.00	2026-10-16	2026-10-15
12	2	3	25.00	2026-10-17	2026-10-15
13	2	7	30.00	2026-10-16	2026-10-15
14	2	8	28.00	2026-10-16	2026-10-15
15	2	9	22.00	2026-10-16	2026-10-15
16	2	10	20.00	2026-10-16	2026-10-15
17	2	12	35.00	2026-10-16	2026-10-15
18	2	13	32.00	2026-10-16	2026-10-15
19	2	19	18.00	2026-10-17	2026-10-15
20	3	1	30.00	2026-10-16	2026-10-15
21	3	3	20.00	2026-10-17	2026-10-15
22	3	5	25.00	2026-10-18	2026-10-15
23	3	6	22.00	2026-10-18	2026-10-15
24	3	11	28.00	2026-10-16	2026-10-15
25	3	14	15.00	2026-10-16	2026-10-15
26	3	15	14.00	2026-10-16	2026-10-15
27	3	20	24.00	2026-10-17	2026-10-15
28	4	1	18.00	2026-10-16	2026-10-15
29	4	2	15.00	2026-10-16	2026-10-15
30	4	3	12.00	2026-10-17	2026-10-15
31	4	7	16.00	2026-10-16	2026-10-15
32	4	9	10.00	2026-10-16	2026-10-15
33	4	12	14.00	2026-10-16	2026-10-15
34	4	16	4.00	2026-10-19	2026-10-15
35	5	1	25.00	2026-10-16	2026-10-15
36	5	2	22.00	2026-10-16	2026-10-15
37	5	3	18.00	2026-10-17	2026-10-15
38	5	5	20.00	2026-10-18	2026-10-15
39	5	6	18.00	2026-10-18	2026-10-15
40	5	7	20.00	2026-10-16	2026-10-15
41	5	8	18.00	2026-10-16	2026-10-15
42	5	10	15.00	2026-10-16	2026-10-15
43	5	13	20.00	2026-10-16	2026-10-15
44	5	17	6.00	2026-10-19	2026-10-15
45	5	18	5.00	2026-10-20	2026-10-15
46	5	19	12.00	2026-10-17	2026-10-15
47	5	20	16.00	2026-10-17	2026-10-15
\.


--
-- Data for Name: loyalty_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loyalty_cards (id, customer_id, favorite_category_id, card_number, issue_date, activation_date, expiration_date, total_points, earned_points, spent_points, level, points_multiplier, points_to_ruble, purchase_count, last_purchase_date, birthday_discount_percent, status, created_at) FROM stdin;
2	1	2	0137-0251-0373-0499	2026-09-19	2026-09-21	2029-09-19	2718	3053	335	silver	1.25	1.00	11	2026-10-28 11:51:33.573238	11.00	active	2026-11-03 11:51:33.573238+03
3	2	3	0274-0502-0746-0998	2026-09-04	2026-09-07	2029-09-04	10685	12142	1457	gold	1.50	1.00	32	2026-10-23 11:51:33.573238	12.00	active	2026-11-03 11:51:33.573238+03
4	3	4	0411-0753-1119-1497	2026-08-20	2026-08-24	2029-08-20	30704	35291	4587	platinum	2.00	1.00	83	2026-10-18 11:51:33.573238	13.00	active	2026-11-03 11:51:33.573238+03
5	4	5	0548-1004-1492-1996	2026-08-05	2026-08-10	2029-08-05	558	648	90	bronze	1.00	1.00	5	2026-10-13 11:51:33.573238	14.00	active	2026-11-03 11:51:33.573238+03
6	5	6	0685-1255-1865-2495	2026-07-21	2026-07-27	\N	2776	3265	489	silver	1.25	1.00	15	2026-10-08 11:51:33.573238	15.00	active	2026-11-03 11:51:33.573238+03
7	6	7	0822-1506-2238-2994	2026-07-06	2026-07-13	2029-07-06	10438	12426	1988	gold	1.50	1.00	36	2026-10-03 11:51:33.573238	16.00	active	2026-11-03 11:51:33.573238+03
8	7	8	0959-1757-2611-3493	2026-06-21	2026-06-29	2029-06-21	29614	35679	6065	platinum	2.00	1.00	87	\N	17.00	active	2026-11-03 11:51:33.573238+03
9	8	9	1096-2008-2984-3992	2026-06-06	2026-06-15	2029-06-06	653	796	143	bronze	1.00	1.00	9	2026-09-23 11:51:33.573238	18.00	blocked	2026-11-03 11:51:33.573238+03
10	9	10	1233-2259-3357-4491	2026-05-22	2026-06-01	2029-05-22	2817	3477	660	silver	1.25	1.00	19	2026-09-18 11:51:33.573238	19.00	expired	2026-11-03 11:51:33.573238+03
11	10	1	1370-2510-3730-4990	2026-05-07	\N	\N	10168	12710	2542	gold	1.50	1.00	40	2026-09-13 11:51:33.573238	20.00	active	2026-11-03 11:51:33.573238+03
12	11	2	1507-2761-4103-5489	2026-04-22	2026-05-04	2029-04-22	28493	36067	7574	platinum	2.00	1.00	91	2026-09-08 11:51:33.573238	21.00	active	2026-11-03 11:51:33.573238+03
13	12	3	1644-3012-4476-5988	2026-04-07	2026-04-20	2029-04-07	737	944	207	bronze	1.00	1.00	3	2026-09-03 11:51:33.573238	22.00	active	2026-11-03 11:51:33.573238+03
14	13	4	1781-3263-4849-6487	2026-03-23	2026-04-06	2029-03-23	2841	3689	848	silver	1.25	1.00	23	2026-08-29 11:51:33.573238	23.00	active	2026-11-03 11:51:33.573238+03
15	14	5	1918-3514-5222-6986	2026-03-08	2026-03-09	2029-03-08	9876	12994	3118	gold	1.50	1.00	44	\N	24.00	active	2026-11-03 11:51:33.573238+03
16	15	6	2055-3765-5595-7485	2026-02-21	2026-02-23	\N	27342	36455	9113	platinum	2.00	1.00	95	2026-08-19 11:51:33.573238	25.00	active	2026-11-03 11:51:33.573238+03
17	16	7	2192-4016-5968-7984	2026-02-06	2026-02-09	2029-02-06	809	1092	283	bronze	1.00	1.00	7	2026-08-14 11:51:33.573238	10.00	active	2026-11-03 11:51:33.573238+03
18	17	8	2329-4267-6341-8483	2026-01-22	2026-01-26	2029-01-22	2848	3901	1053	silver	1.25	1.00	27	2026-08-09 11:51:33.573238	11.00	active	2026-11-03 11:51:33.573238+03
19	18	9	2466-4518-6714-8982	2026-01-07	2026-01-12	2029-01-07	9561	13278	3717	gold	1.50	1.00	48	2026-08-04 11:51:33.573238	12.00	blocked	2026-11-03 11:51:33.573238+03
20	19	10	2603-4769-7087-9481	2025-12-23	2025-12-29	2028-12-23	26159	36843	10684	platinum	2.00	1.00	99	2026-07-30 11:51:33.573238	13.00	expired	2026-11-03 11:51:33.573238+03
21	20	1	2740-5020-7460-9980	2025-12-08	\N	\N	868	1240	372	bronze	1.00	1.00	1	2026-07-25 11:51:33.573238	14.00	active	2026-11-03 11:51:33.573238+03
22	21	2	2877-5271-7833-0479	2025-11-23	2025-12-01	2028-11-23	2838	4113	1275	silver	1.25	1.00	31	\N	15.00	active	2026-11-03 11:51:33.573238+03
23	22	3	3014-5522-8206-0978	2025-11-08	2025-11-17	2028-11-08	9223	13562	4339	gold	1.50	1.00	52	2026-07-15 11:51:33.573238	16.00	active	2026-11-03 11:51:33.573238+03
24	23	4	3151-5773-8579-1477	2025-10-24	2025-11-03	2028-10-24	24945	37231	12286	platinum	2.00	1.00	103	2026-07-10 11:51:33.573238	17.00	active	2026-11-03 11:51:33.573238+03
25	24	5	3288-6024-8952-1976	2025-10-09	2025-10-20	2028-10-09	917	1388	471	bronze	1.00	1.00	5	2026-07-05 11:51:33.573238	18.00	active	2026-11-03 11:51:33.573238+03
26	25	6	3425-6275-9325-2475	2025-09-24	2025-10-06	\N	2812	4325	1513	silver	1.25	1.00	35	2026-06-30 11:51:33.573238	19.00	active	2026-11-03 11:51:33.573238+03
27	26	7	3562-6526-9698-2974	2025-09-09	2025-09-22	2028-09-09	8862	13846	4984	gold	1.50	1.00	56	2026-06-25 11:51:33.573238	20.00	active	2026-11-03 11:51:33.573238+03
28	27	8	3699-6777-0071-3473	2025-08-25	2025-09-08	2028-08-25	23700	37619	13919	platinum	2.00	1.00	107	2026-06-20 11:51:33.573238	21.00	active	2026-11-03 11:51:33.573238+03
29	28	9	3836-7028-0444-3972	2025-08-10	2025-08-11	2028-08-10	953	1536	583	bronze	1.00	1.00	9	\N	22.00	blocked	2026-11-03 11:51:33.573238+03
30	29	10	3973-7279-0817-4471	2025-07-26	2025-07-28	2028-07-26	2768	4537	1769	silver	1.25	1.00	39	2026-06-10 11:51:33.573238	23.00	expired	2026-11-03 11:51:33.573238+03
31	30	1	4110-7530-1190-4970	2025-07-11	\N	\N	8478	14130	5652	gold	1.50	1.00	60	2026-06-05 11:51:33.573238	24.00	active	2026-11-03 11:51:33.573238+03
32	31	2	4247-7781-1563-5469	2025-06-26	2025-06-30	2028-06-26	22425	38007	15582	platinum	2.00	1.00	111	2026-05-31 11:51:33.573238	25.00	active	2026-11-03 11:51:33.573238+03
33	32	3	4384-8032-1936-5968	2025-06-11	2025-06-16	2028-06-11	977	1684	707	bronze	1.00	1.00	3	2026-05-26 11:51:33.573238	10.00	active	2026-11-03 11:51:33.573238+03
34	33	4	4521-8283-2309-6467	2025-05-27	2025-06-02	2028-05-27	2707	4749	2042	silver	1.25	1.00	13	2026-05-21 11:51:33.573238	11.00	active	2026-11-03 11:51:33.573238+03
35	34	5	4658-8534-2682-6966	2025-05-12	2025-05-19	2028-05-12	8072	14414	6342	gold	1.50	1.00	64	2026-05-16 11:51:33.573238	12.00	active	2026-11-03 11:51:33.573238+03
36	35	6	4795-8785-3055-7465	2025-04-27	2025-05-05	\N	21118	38395	17277	platinum	2.00	1.00	115	\N	13.00	active	2026-11-03 11:51:33.573238+03
37	36	7	4932-9036-3428-7964	2025-04-12	2025-04-21	2028-04-12	990	1832	842	bronze	1.00	1.00	7	2026-05-06 11:51:33.573238	14.00	active	2026-11-03 11:51:33.573238+03
38	37	8	5069-9287-3801-8463	2025-03-28	2025-04-07	2028-03-28	2630	4961	2331	silver	1.25	1.00	17	2026-05-01 11:51:33.573238	15.00	active	2026-11-03 11:51:33.573238+03
39	38	9	5206-9538-4174-8962	2025-03-13	2025-03-24	2028-03-13	7643	14698	7055	gold	1.50	1.00	68	2026-04-26 11:51:33.573238	16.00	blocked	2026-11-03 11:51:33.573238+03
40	39	10	5343-9789-4547-9461	2025-02-26	2025-03-10	2028-02-26	19780	38783	19003	platinum	2.00	1.00	119	2026-04-21 11:51:33.573238	17.00	expired	2026-11-03 11:51:33.573238+03
41	40	1	5480-0040-4920-9960	2025-02-11	\N	\N	990	1980	990	bronze	1.00	1.00	1	2026-04-16 11:51:33.573238	18.00	active	2026-11-03 11:51:33.573238+03
42	41	2	5617-0291-5293-0459	2025-01-27	2025-02-10	2028-01-27	2535	5173	2638	silver	1.25	1.00	21	2026-04-11 11:51:33.573238	19.00	active	2026-11-03 11:51:33.573238+03
43	42	3	5754-0542-5666-0958	2025-01-12	2025-01-13	2028-01-12	7192	14982	7790	gold	1.50	1.00	72	\N	20.00	active	2026-11-03 11:51:33.573238+03
44	43	4	5891-0793-6039-1457	2024-12-28	2024-12-30	2027-12-28	18411	39171	20760	platinum	2.00	1.00	123	2026-04-01 11:51:33.573238	21.00	active	2026-11-03 11:51:33.573238+03
45	44	5	6028-1044-6412-1956	2024-12-13	2024-12-16	2027-12-13	979	2128	1149	bronze	1.00	1.00	5	2026-03-27 11:51:33.573238	22.00	active	2026-11-03 11:51:33.573238+03
46	45	6	6165-1295-6785-2455	2024-11-28	2024-12-02	\N	2424	5385	2961	silver	1.25	1.00	25	2026-03-22 11:51:33.573238	23.00	active	2026-11-03 11:51:33.573238+03
47	46	7	6302-1546-7158-2954	2024-11-13	2024-11-18	2027-11-13	6718	15266	8548	gold	1.50	1.00	76	2026-03-17 11:51:33.573238	24.00	active	2026-11-03 11:51:33.573238+03
48	47	8	6439-1797-7531-3453	2024-10-29	2024-11-04	2027-10-29	17011	39559	22548	platinum	2.00	1.00	127	2026-03-12 11:51:33.573238	25.00	active	2026-11-03 11:51:33.573238+03
49	48	9	6576-2048-7904-3952	2024-10-14	2024-10-21	2027-10-14	956	2276	1320	bronze	1.00	1.00	9	2026-03-07 11:51:33.573238	10.00	blocked	2026-11-03 11:51:33.573238+03
50	49	10	6713-2299-8277-4451	2024-09-29	2024-10-07	2027-09-29	2295	5597	3302	silver	1.25	1.00	29	\N	11.00	expired	2026-11-03 11:51:33.573238+03
51	50	1	6850-2550-8650-4950	2024-09-14	\N	\N	6220	15550	9330	gold	1.50	1.00	80	2026-02-25 11:51:33.573238	12.00	active	2026-11-03 11:51:33.573238+03
\.


--
-- Data for Name: medical_books; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_books (id, employee_id, medical_record_number, issue_date, validity_period, status) FROM stdin;
1	1	MB000001	2023-01-15	365	active
2	2	MB000002	2023-02-20	365	active
3	3	MB000003	2023-03-25	365	active
4	4	MB000004	2023-04-10	365	active
5	5	MB000005	2023-05-12	365	active
6	6	MB000006	2022-06-18	365	overdue
7	7	MB000007	2023-07-22	365	active
8	8	MB000008	2023-08-30	365	active
9	9	MB000009	2023-09-14	365	active
10	10	MB000010	2023-10-01	365	active
11	11	MB000011	2023-11-11	365	active
12	12	MB000012	2023-12-05	365	active
13	13	MB000013	2024-01-10	365	active
14	14	MB000014	2024-02-28	365	active
15	15	MB000015	2024-03-05	365	active
16	16	MB000016	2024-04-18	365	active
17	17	MB000017	2022-05-22	365	overdue
18	18	MB000018	2024-06-12	365	active
19	19	MB000019	2024-07-09	365	active
20	20	MB000020	2024-08-15	365	active
21	21	MB000021	2024-09-20	365	active
22	22	MB000022	2024-10-25	365	active
23	23	MB000023	2024-11-11	365	active
24	24	MB000024	2024-12-01	365	active
25	25	MB000025	2023-01-15	365	active
26	26	MB000026	2023-02-20	365	active
27	27	MB000027	2023-03-25	365	active
28	28	MB000028	2022-04-10	365	overdue
29	29	MB000029	2023-05-12	365	active
30	30	MB000030	2023-06-18	365	active
31	31	MB000031	2023-07-22	365	active
32	32	MB000032	2023-08-30	365	active
33	33	MB000033	2023-09-14	365	active
34	34	MB000034	2023-10-01	365	active
35	35	MB000035	2022-11-11	365	overdue
36	36	MB000036	2023-12-05	365	active
37	37	MB000037	2024-01-10	365	active
38	38	MB000038	2024-02-28	365	active
39	39	MB000039	2024-03-05	365	active
40	40	MB000040	2022-04-18	365	overdue
41	41	MB000041	2024-05-22	365	active
42	42	MB000042	2024-06-12	365	active
43	43	MB000043	2024-07-09	365	active
44	44	MB000044	2024-08-15	365	active
45	45	MB000045	2024-09-20	365	active
46	46	MB000046	2024-10-25	365	active
47	47	MB000047	2024-11-11	365	active
48	48	MB000048	2024-12-01	365	active
49	49	MB000049	2023-01-15	365	active
50	50	MB000050	2023-02-20	365	active
\.


--
-- Data for Name: price_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_history (id, date_change, new_price, old_price, reason, effective_date, status, bakery_id, product_id, created_at) FROM stdin;
1	2026-10-21 13:44:33.240623	60.00	48.00	Изменение себестоимости	2026-10-21	inactive	2	2	2026-10-22 13:44:33.240623+03
2	2026-10-20 13:44:33.240623	70.00	56.00	Акция	2026-10-20	active	3	3	2026-10-22 13:44:33.240623+03
3	2026-10-19 13:44:33.240623	80.00	64.00	Корректировка цены	2026-10-19	inactive	4	4	2026-10-22 13:44:33.240623+03
4	2026-10-18 13:44:33.240623	90.00	72.00	Сезонное изменение	2026-10-18	active	5	5	2026-10-22 13:44:33.240623+03
5	2026-10-17 13:44:33.240623	100.00	80.00	Изменение себестоимости	2026-10-17	inactive	6	6	2026-10-22 13:44:33.240623+03
6	2026-10-16 13:44:33.240623	110.00	88.00	Акция	2026-10-16	active	7	7	2026-10-22 13:44:33.240623+03
7	2026-10-15 13:44:33.240623	120.00	96.00	Корректировка цены	2026-10-15	inactive	8	8	2026-10-22 13:44:33.240623+03
8	2026-10-14 13:44:33.240623	130.00	104.00	Сезонное изменение	2026-10-14	active	9	9	2026-10-22 13:44:33.240623+03
9	2026-10-13 13:44:33.240623	140.00	112.00	Изменение себестоимости	2026-10-13	inactive	10	10	2026-10-22 13:44:33.240623+03
10	2026-10-12 13:44:33.240623	150.00	120.00	Акция	2026-10-12	active	1	11	2026-10-22 13:44:33.240623+03
11	2026-10-11 13:44:33.240623	160.00	128.00	Корректировка цены	2026-10-11	inactive	2	12	2026-10-22 13:44:33.240623+03
12	2026-10-10 13:44:33.240623	170.00	136.00	Сезонное изменение	2026-10-10	active	3	13	2026-10-22 13:44:33.240623+03
13	2026-10-09 13:44:33.240623	180.00	144.00	Изменение себестоимости	2026-10-09	inactive	4	14	2026-10-22 13:44:33.240623+03
14	2026-10-08 13:44:33.240623	190.00	152.00	Акция	2026-10-08	active	5	15	2026-10-22 13:44:33.240623+03
15	2026-10-07 13:44:33.240623	200.00	160.00	Корректировка цены	2026-10-07	inactive	6	16	2026-10-22 13:44:33.240623+03
16	2026-10-06 13:44:33.240623	210.00	168.00	Сезонное изменение	2026-10-06	active	7	17	2026-10-22 13:44:33.240623+03
17	2026-10-05 13:44:33.240623	220.00	176.00	Изменение себестоимости	2026-10-05	inactive	8	18	2026-10-22 13:44:33.240623+03
18	2026-10-04 13:44:33.240623	230.00	184.00	Акция	2026-10-04	active	9	19	2026-10-22 13:44:33.240623+03
19	2026-10-03 13:44:33.240623	240.00	192.00	Корректировка цены	2026-10-03	inactive	10	20	2026-10-22 13:44:33.240623+03
20	2026-10-02 13:44:33.240623	50.00	200.00	Сезонное изменение	2026-10-02	active	1	21	2026-10-22 13:44:33.240623+03
21	2026-10-01 13:44:33.240623	60.00	208.00	Изменение себестоимости	2026-10-01	inactive	2	22	2026-10-22 13:44:33.240623+03
22	2026-09-30 13:44:33.240623	70.00	216.00	Акция	2026-09-30	active	3	23	2026-10-22 13:44:33.240623+03
23	2026-09-29 13:44:33.240623	80.00	44.00	Корректировка цены	2026-09-29	inactive	4	24	2026-10-22 13:44:33.240623+03
24	2026-09-28 13:44:33.240623	90.00	52.00	Сезонное изменение	2026-09-28	active	5	25	2026-10-22 13:44:33.240623+03
25	2026-09-27 13:44:33.240623	100.00	60.00	Изменение себестоимости	2026-09-27	inactive	6	26	2026-10-22 13:44:33.240623+03
26	2026-09-26 13:44:33.240623	110.00	68.00	Акция	2026-09-26	active	7	27	2026-10-22 13:44:33.240623+03
27	2026-09-25 13:44:33.240623	120.00	76.00	Корректировка цены	2026-09-25	inactive	8	28	2026-10-22 13:44:33.240623+03
28	2026-09-24 13:44:33.240623	130.00	84.00	Сезонное изменение	2026-09-24	active	9	29	2026-10-22 13:44:33.240623+03
29	2026-09-23 13:44:33.240623	140.00	92.00	Изменение себестоимости	2026-09-23	inactive	10	30	2026-10-22 13:44:33.240623+03
30	2026-09-22 13:44:33.240623	150.00	100.00	Акция	2026-09-22	active	1	31	2026-10-22 13:44:33.240623+03
31	2026-09-21 13:44:33.240623	160.00	108.00	Корректировка цены	2026-09-21	inactive	2	32	2026-10-22 13:44:33.240623+03
32	2026-09-20 13:44:33.240623	170.00	116.00	Сезонное изменение	2026-09-20	active	3	33	2026-10-22 13:44:33.240623+03
33	2026-09-19 13:44:33.240623	180.00	124.00	Изменение себестоимости	2026-09-19	inactive	4	34	2026-10-22 13:44:33.240623+03
34	2026-09-18 13:44:33.240623	190.00	132.00	Акция	2026-09-18	active	5	35	2026-10-22 13:44:33.240623+03
35	2026-09-17 13:44:33.240623	200.00	140.00	Корректировка цены	2026-09-17	inactive	6	36	2026-10-22 13:44:33.240623+03
36	2026-09-16 13:44:33.240623	210.00	148.00	Сезонное изменение	2026-09-16	active	7	37	2026-10-22 13:44:33.240623+03
37	2026-09-15 13:44:33.240623	220.00	156.00	Изменение себестоимости	2026-09-15	inactive	8	38	2026-10-22 13:44:33.240623+03
38	2026-09-14 13:44:33.240623	230.00	164.00	Акция	2026-09-14	active	9	39	2026-10-22 13:44:33.240623+03
39	2026-09-13 13:44:33.240623	240.00	172.00	Корректировка цены	2026-09-13	inactive	10	40	2026-10-22 13:44:33.240623+03
40	2026-09-12 13:44:33.240623	50.00	180.00	Сезонное изменение	2026-09-12	active	1	41	2026-10-22 13:44:33.240623+03
41	2026-09-11 13:44:33.240623	60.00	188.00	Изменение себестоимости	2026-09-11	inactive	2	42	2026-10-22 13:44:33.240623+03
42	2026-09-10 13:44:33.240623	70.00	196.00	Акция	2026-09-10	active	3	43	2026-10-22 13:44:33.240623+03
43	2026-09-09 13:44:33.240623	80.00	204.00	Корректировка цены	2026-09-09	inactive	4	44	2026-10-22 13:44:33.240623+03
44	2026-09-08 13:44:33.240623	90.00	212.00	Сезонное изменение	2026-09-08	active	5	45	2026-10-22 13:44:33.240623+03
45	2026-09-07 13:44:33.240623	100.00	40.00	Изменение себестоимости	2026-09-07	inactive	6	46	2026-10-22 13:44:33.240623+03
46	2026-09-06 13:44:33.240623	110.00	48.00	Акция	2026-09-06	active	7	47	2026-10-22 13:44:33.240623+03
47	2026-09-05 13:44:33.240623	120.00	56.00	Корректировка цены	2026-09-05	inactive	8	48	2026-10-22 13:44:33.240623+03
48	2026-09-04 13:44:33.240623	130.00	64.00	Сезонное изменение	2026-09-04	active	9	49	2026-10-22 13:44:33.240623+03
49	2026-09-03 13:44:33.240623	140.00	72.00	Изменение себестоимости	2026-09-03	inactive	10	50	2026-10-22 13:44:33.240623+03
50	2026-09-02 13:44:33.240623	150.00	80.00	Акция	2026-09-02	active	1	1	2026-10-22 13:44:33.240623+03
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_categories (id, description, name, created_at) FROM stdin;
1	Классические хлебобулочные изделия	Хлеб	2026-10-02 12:58:26.191319+03
2	Нарезные батоны и багеты	Батоны	2026-10-02 12:58:26.191319+03
3	Сладкие и несладкие булочки	Булочки	2026-10-02 12:58:26.191319+03
4	Мелкоштучные кондитерские изделия	Пирожные	2026-10-02 12:58:26.191319+03
5	Штучные торты и торты на заказ	Торты	2026-10-02 12:58:26.191319+03
6	Все виды печенья	Печенье	2026-10-02 12:58:26.191319+03
7	Пряники и коврижки	Пряники	2026-10-02 12:58:26.191319+03
8	Слоеные изделия	Слойки	2026-10-02 12:58:26.191319+03
9	Круассаны и датская выпечка	Круассаны	2026-10-02 12:58:26.191319+03
10	Ватрушки с начинкой	Ватрушки	2026-10-02 12:58:26.191319+03
11	Открытые и закрытые пироги	Пироги	2026-10-02 12:58:26.191319+03
12	Жареные и печеные пончики	Пончики	2026-10-02 12:58:26.191319+03
13	Маффины и кексы	Кексы	2026-10-02 12:58:26.191319+03
14	Бисквитные и дрожжевые рулеты	Рулеты	2026-10-02 12:58:26.191319+03
15	Сочники с творогом	Сочники	2026-10-02 12:58:26.191319+03
16	Национальные лепешки с сыром	Хачапури	2026-10-02 12:58:26.191319+03
17	Пресные и дрожжевые лепешки	Лепешки	2026-10-02 12:58:26.191319+03
18	Сухари и хлебцы	Сухари	2026-10-02 12:58:26.191319+03
19	Баранки, бублики, сушки	Баранки	2026-10-02 12:58:26.191319+03
20	Жареные и печеные пирожки	Пирожки	2026-10-02 12:58:26.191319+03
21	Чебуреки и беляши	Чебуреки	2026-10-02 12:58:26.191319+03
22	Слоеная самса	Самса	2026-10-02 12:58:26.191319+03
23	Кулебяки с начинкой	Кулебяки	2026-10-02 12:58:26.191319+03
24	Открытые пирожки	Расстегаи	2026-10-02 12:58:26.191319+03
25	Пироги с курицей	Курники	2026-10-02 12:58:26.191319+03
26	Штрудели с фруктами	Штрудели	2026-10-02 12:58:26.191319+03
27	Пресный хлеб	Маца	2026-10-02 12:58:26.191319+03
28	Тонкий и армянский лаваш	Лаваш	2026-10-02 12:58:26.191319+03
29	Итальянский хлеб	Чиабатта	2026-10-02 12:58:26.191319+03
30	Итальянская лепешка	Фокачча	2026-10-02 12:58:26.191319+03
31	Ржаной хлеб	Бородинский	2026-10-02 12:58:26.191319+03
32	Ржано-пшеничный хлеб	Дарницкий	2026-10-02 12:58:26.191319+03
33	Хлеб с зернами	Зерновой	2026-10-02 12:58:26.191319+03
34	Диетическая выпечка	Безглютеновый	2026-10-02 12:58:26.191319+03
35	Хлеб из цельного зерна	Цельнозерновой	2026-10-02 12:58:26.191319+03
36	Выпечка с овсянкой	Овсяный	2026-10-02 12:58:26.191319+03
37	Выпечка с гречкой	Гречишный	2026-10-02 12:58:26.191319+03
38	Хлеб на ржаной муке	Ржаной	2026-10-02 12:58:26.191319+03
39	Хлеб из пшеничной муки	Пшеничный	2026-10-02 12:58:26.191319+03
40	Хлеб из формы	Формовой	2026-10-02 12:58:26.191319+03
41	Подовый хлеб	Подовый	2026-10-02 12:58:26.191319+03
42	Специальная выпечка для детей	Детский	2026-10-02 12:58:26.191319+03
43	Выпечка без сахара	Диетический	2026-10-02 12:58:26.191319+03
44	Постная выпечка	Веганский	2026-10-02 12:58:26.191319+03
45	Праздничная выпечка	Сезонный	2026-10-02 12:58:26.191319+03
46	Эксклюзивные рецепты	Авторский	2026-10-02 12:58:26.191319+03
47	Уникальные изделия пекарни	Фирменный	2026-10-02 12:58:26.191319+03
48	Сдобные булочки и плетенки	Сдоба	2026-10-02 12:58:26.191319+03
49	Плетеные изделия	Плетенки	2026-10-02 12:58:26.191319+03
50	Маленькие рогалики	Рогалики	2026-10-02 12:58:26.191319+03
\.


--
-- Data for Name: production_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_batches (id, bakery_id, employee_id, product_id, quantity, production_date, production_time, status) FROM stdin;
1	1	1	1	100	2024-01-15	2.50	ready
2	1	1	2	80	2024-01-15	3.00	ready
3	2	2	3	120	2024-01-15	2.00	ready
4	2	2	4	60	2024-01-15	1.50	ready
5	3	3	5	150	2024-01-16	1.80	ready
6	3	3	6	140	2024-01-16	1.80	ready
7	4	9	7	200	2024-01-16	1.20	ready
8	4	9	8	180	2024-01-16	1.40	ready
9	5	3	9	50	2024-01-17	4.00	ready
10	5	3	10	60	2024-01-17	3.50	ready
11	6	12	11	20	2024-01-17	8.00	ready
12	6	12	12	25	2024-01-17	7.50	ready
13	7	16	13	300	2024-01-18	2.00	ready
14	7	16	14	280	2024-01-18	2.00	ready
15	8	21	15	100	2024-01-18	2.50	ready
16	8	21	16	120	2024-01-18	2.00	ready
17	9	22	17	110	2024-01-19	2.20	ready
18	9	22	18	130	2024-01-19	2.00	ready
19	10	27	19	40	2024-01-19	5.00	ready
20	10	27	20	35	2024-01-19	5.50	ready
21	11	31	21	150	2024-01-20	1.50	ready
22	11	31	22	140	2024-01-20	1.50	ready
23	12	34	23	80	2024-01-20	3.00	ready
24	12	34	24	90	2024-01-20	2.50	ready
25	13	41	25	60	2024-01-21	4.00	ready
26	13	41	26	55	2024-01-21	4.00	ready
27	14	46	27	120	2024-01-21	2.00	ready
28	14	46	28	80	2024-01-21	1.80	ready
29	15	1	29	200	2024-01-22	1.00	ready
30	15	1	30	90	2024-01-22	2.50	ready
31	16	2	31	70	2024-01-22	2.50	ready
32	16	2	32	100	2024-01-22	3.00	ready
33	17	3	33	85	2024-01-23	3.50	ready
34	17	3	34	75	2024-01-23	4.00	ready
35	18	9	35	80	2024-01-23	3.50	ready
36	18	9	36	150	2024-01-23	1.50	ready
37	19	12	37	140	2024-01-24	1.50	ready
38	19	12	38	100	2024-01-24	1.80	ready
39	20	16	39	120	2024-01-24	2.00	ready
40	20	16	40	30	2024-01-24	6.00	ready
41	21	21	41	110	2024-01-25	2.00	ready
42	21	21	42	25	2024-01-25	7.00	ready
43	22	22	43	50	2024-01-25	4.50	ready
44	22	22	44	70	2024-01-25	4.00	ready
45	23	27	45	180	2024-01-26	1.20	ready
46	23	27	46	100	2024-01-26	3.00	ready
47	24	31	47	200	2024-01-26	2.50	ready
48	24	31	48	190	2024-01-26	2.50	ready
49	25	34	49	90	2024-01-27	3.00	in_production
50	25	34	50	150	2024-01-27	1.50	in_production
\.


--
-- Data for Name: production_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_plans (id, planned_date, deadline, quantity, status, created_at, bakery_id, product_id, employee_id) FROM stdin;
1	2026-09-05	2026-09-05 18:00:00	37.00	completed	2026-11-03 10:10:08.567085+03	2	2	2
2	2026-09-06	2026-09-06 18:00:00	54.00	completed	2026-11-03 10:10:08.567085+03	3	3	3
3	2026-09-07	2026-09-08 18:00:00	71.00	not_completed	2026-11-03 10:10:08.567085+03	4	4	4
4	2026-09-08	2026-09-08 18:00:00	88.00	completed	2026-11-03 10:10:08.567085+03	5	5	5
5	2026-09-09	2026-09-09 18:00:00	105.00	completed	2026-11-03 10:10:08.567085+03	6	6	6
6	2026-09-10	2026-09-11 18:00:00	122.00	in_progress	2026-11-03 10:10:08.567085+03	7	7	7
7	2026-09-11	2026-09-11 18:00:00	139.00	completed	2026-11-03 10:10:08.567085+03	8	8	8
8	2026-09-12	2026-09-12 18:00:00	156.00	completed	2026-11-03 10:10:08.567085+03	9	9	9
9	2026-09-13	2026-09-14 18:00:00	173.00	completed	2026-11-03 10:10:08.567085+03	10	10	10
10	2026-09-14	2026-09-14 18:00:00	190.00	not_completed	2026-11-03 10:10:08.567085+03	1	11	11
11	2026-09-15	2026-09-15 18:00:00	207.00	in_progress	2026-11-03 10:10:08.567085+03	2	12	12
12	2026-09-16	2026-09-17 18:00:00	224.00	not_completed	2026-11-03 10:10:08.567085+03	3	13	13
13	2026-09-17	2026-09-17 18:00:00	241.00	completed	2026-11-03 10:10:08.567085+03	4	14	14
14	2026-09-18	2026-09-18 18:00:00	258.00	completed	2026-11-03 10:10:08.567085+03	5	15	15
15	2026-09-19	2026-09-20 18:00:00	275.00	completed	2026-11-03 10:10:08.567085+03	6	16	16
16	2026-09-20	2026-09-20 18:00:00	292.00	completed	2026-11-03 10:10:08.567085+03	7	17	17
17	2026-09-21	2026-09-21 18:00:00	28.00	completed	2026-11-03 10:10:08.567085+03	8	18	18
18	2026-09-22	2026-09-23 18:00:00	45.00	completed	2026-11-03 10:10:08.567085+03	9	19	19
19	2026-09-23	2026-09-23 18:00:00	62.00	not_completed	2026-11-03 10:10:08.567085+03	10	20	20
20	2026-09-24	2026-09-24 18:00:00	79.00	completed	2026-11-03 10:10:08.567085+03	1	21	1
21	2026-09-25	2026-09-26 18:00:00	96.00	not_completed	2026-11-03 10:10:08.567085+03	2	22	2
22	2026-09-26	2026-09-26 18:00:00	113.00	completed	2026-11-03 10:10:08.567085+03	3	23	3
23	2026-09-27	2026-09-27 18:00:00	130.00	not_completed	2026-11-03 10:10:08.567085+03	4	24	4
24	2026-09-28	2026-09-29 18:00:00	147.00	in_progress	2026-11-03 10:10:08.567085+03	5	25	5
25	2026-09-29	2026-09-29 18:00:00	164.00	in_progress	2026-11-03 10:10:08.567085+03	6	26	6
26	2026-09-30	2026-09-30 18:00:00	181.00	not_completed	2026-11-03 10:10:08.567085+03	7	27	7
27	2026-10-01	2026-10-02 18:00:00	198.00	completed	2026-11-03 10:10:08.567085+03	8	28	8
28	2026-10-02	2026-10-02 18:00:00	215.00	not_completed	2026-11-03 10:10:08.567085+03	9	29	9
29	2026-10-03	2026-10-03 18:00:00	232.00	in_progress	2026-11-03 10:10:08.567085+03	10	30	10
30	2026-10-04	2026-10-05 18:00:00	249.00	not_completed	2026-11-03 10:10:08.567085+03	1	31	11
31	2026-10-05	2026-10-05 18:00:00	266.00	not_completed	2026-11-03 10:10:08.567085+03	2	32	12
32	2026-10-06	2026-10-06 18:00:00	283.00	in_progress	2026-11-03 10:10:08.567085+03	3	33	13
33	2026-10-07	2026-10-08 18:00:00	300.00	completed	2026-11-03 10:10:08.567085+03	4	34	14
34	2026-10-08	2026-10-08 18:00:00	36.00	in_progress	2026-11-03 10:10:08.567085+03	5	35	15
35	2026-10-09	2026-10-09 18:00:00	53.00	completed	2026-11-03 10:10:08.567085+03	6	36	16
36	2026-10-10	2026-10-11 18:00:00	70.00	completed	2026-11-03 10:10:08.567085+03	7	37	17
37	2026-10-11	2026-10-11 18:00:00	87.00	completed	2026-11-03 10:10:08.567085+03	8	38	18
38	2026-10-12	2026-10-12 18:00:00	104.00	in_progress	2026-11-03 10:10:08.567085+03	9	39	19
39	2026-10-13	2026-10-14 18:00:00	121.00	completed	2026-11-03 10:10:08.567085+03	10	40	20
40	2026-10-14	2026-10-14 18:00:00	138.00	not_completed	2026-11-03 10:10:08.567085+03	1	41	1
41	2026-10-15	2026-10-15 18:00:00	155.00	not_completed	2026-11-03 10:10:08.567085+03	2	42	2
42	2026-10-16	2026-10-17 18:00:00	172.00	completed	2026-11-03 10:10:08.567085+03	3	43	3
43	2026-10-17	2026-10-17 18:00:00	189.00	not_completed	2026-11-03 10:10:08.567085+03	4	44	4
44	2026-10-18	2026-10-18 18:00:00	206.00	not_completed	2026-11-03 10:10:08.567085+03	5	45	5
45	2026-10-19	2026-10-20 18:00:00	223.00	completed	2026-11-03 10:10:08.567085+03	6	46	6
46	2026-10-20	2026-10-20 18:00:00	240.00	completed	2026-11-03 10:10:08.567085+03	7	47	7
47	2026-10-21	2026-10-21 18:00:00	257.00	completed	2026-11-03 10:10:08.567085+03	8	48	8
48	2026-10-22	2026-10-23 18:00:00	274.00	completed	2026-11-03 10:10:08.567085+03	9	49	9
49	2026-10-23	2026-10-23 18:00:00	291.00	completed	2026-11-03 10:10:08.567085+03	10	50	10
50	2026-10-24	2026-10-24 18:00:00	27.00	completed	2026-11-03 10:10:08.567085+03	1	1	11
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, price_for_customer, lifespan_hours, age_restriction, category_id, barcode, created_at) FROM stdin;
1	Белый хлеб	Классический пшеничный хлеб	65.00	48	\N	1	4690000000001	2026-10-02 13:42:34.038543+03
2	Бородинский	Ржаной заварной хлеб	85.00	72	\N	31	4690000000002	2026-10-02 13:42:34.038543+03
3	Батон нарезной	Нарезной батон из муки в/с	55.00	48	\N	2	4690000000003	2026-10-02 13:42:34.038543+03
4	Багет французский	Хрустящий багет	95.00	24	\N	2	4690000000004	2026-10-02 13:42:34.038543+03
5	Булочка с маком	Сдобная булочка с маком	45.00	72	\N	3	4690000000005	2026-10-02 13:42:34.038543+03
6	Булочка с изюмом	Сдобная булочка с изюмом	50.00	72	\N	3	4690000000006	2026-10-02 13:42:34.038543+03
7	Круассан классич.	Слоеный круассан с маслом	75.00	24	\N	9	4690000000007	2026-10-02 13:42:34.038543+03
8	Круассан с шокол.	Круассан с шоколадной начинкой	85.00	24	\N	9	4690000000008	2026-10-02 13:42:34.038543+03
9	Пирожное Картошка	Пирожное с кремом и какао	120.00	36	\N	4	4690000000009	2026-10-02 13:42:34.038543+03
10	Эклер заварной	Пирожное с заварным кремом	110.00	24	\N	4	4690000000010	2026-10-02 13:42:34.038543+03
11	Торт Наполеон	Слоеный торт с кремом	850.00	48	\N	5	4690000000011	2026-10-02 13:42:34.038543+03
12	Торт Медовик	Медовый торт со сметанным кремом	780.00	72	\N	5	4690000000012	2026-10-02 13:42:34.038543+03
13	Печенье Овсяное	Овсяное печенье с изюмом	180.00	180	\N	6	4690000000013	2026-10-02 13:42:34.038543+03
14	Печенье Песочное	Классическое песочное печенье	160.00	180	\N	6	4690000000014	2026-10-02 13:42:34.038543+03
15	Пряник Тульский	Пряник с яблочной начинкой	65.00	90	\N	7	4690000000015	2026-10-02 13:42:34.038543+03
16	Слойка с сыром	Слоеная булочка с сыром	70.00	24	\N	8	4690000000016	2026-10-02 13:42:34.038543+03
17	Слойка с яблоком	Слоеная булочка с яблоком	75.00	24	\N	8	4690000000017	2026-10-02 13:42:34.038543+03
18	Ватрушка с творог.	Ватрушка с творогом и изюмом	55.00	48	\N	10	4690000000018	2026-10-02 13:42:34.038543+03
19	Пирог с капустой	Закрытый пирог с капустой	320.00	48	\N	11	4690000000019	2026-10-02 13:42:34.038543+03
20	Пирог с мясом	Закрытый пирог с мясной начинкой	380.00	48	\N	11	4690000000020	2026-10-02 13:42:34.038543+03
21	Пончик с джемом	Жареный пончик с ягодным джемом	60.00	24	\N	12	4690000000021	2026-10-02 13:42:34.038543+03
22	Пончик в глазури	Пончик в сахарной глазури	65.00	24	\N	12	4690000000022	2026-10-02 13:42:34.038543+03
23	Кекс Столичный	Кекс с изюмом	220.00	96	\N	13	4690000000023	2026-10-02 13:42:34.038543+03
24	Маффин шоколадный	Шоколадный маффин	95.00	48	\N	13	4690000000024	2026-10-02 13:42:34.038543+03
25	Рулет с маком	Дрожжевой рулет с маковой начинкой	280.00	72	\N	14	4690000000025	2026-10-02 13:42:34.038543+03
26	Рулет с корицей	Сдобный рулет с корицей	260.00	72	\N	14	4690000000026	2026-10-02 13:42:34.038543+03
27	Сочник с творогом	Сочник из песочного теста	55.00	48	\N	15	4690000000027	2026-10-02 13:42:34.038543+03
28	Хачапури по-аджар.	Хачапури с яйцом и сыром	180.00	12	\N	16	4690000000028	2026-10-02 13:42:34.038543+03
29	Лаваш тонкий	Тонкий армянский лаваш	45.00	72	\N	28	4690000000029	2026-10-02 13:42:34.038543+03
30	Чиабатта	Итальянский пшеничный хлеб	110.00	24	\N	29	4690000000030	2026-10-02 13:42:34.038543+03
31	Фокачча с розмар.	Итальянская лепешка с травами	130.00	24	\N	30	4690000000031	2026-10-02 13:42:34.038543+03
32	Дарницкий хлеб	Ржано-пшеничный формовой	75.00	72	\N	32	4690000000032	2026-10-02 13:42:34.038543+03
33	Зерновой хлеб	Хлеб с семенами подсолнечника	95.00	72	\N	33	4690000000033	2026-10-02 13:42:34.038543+03
34	Цельнозерновой	Хлеб из цельного зерна	105.00	72	\N	35	4690000000034	2026-10-02 13:42:34.038543+03
35	Овсяный хлеб	Хлеб с овсяными хлопьями	100.00	72	\N	36	4690000000035	2026-10-02 13:42:34.038543+03
36	Пирожок с картошк.	Жареный пирожок с картофелем	50.00	24	\N	20	4690000000036	2026-10-02 13:42:34.038543+03
37	Пирожок с яйцом	Пирожок с яйцом и луком	55.00	24	\N	20	4690000000037	2026-10-02 13:42:34.038543+03
38	Чебурек с мясом	Жареный чебурек с мясом	120.00	12	\N	21	4690000000038	2026-10-02 13:42:34.038543+03
39	Самса с курицей	Слоеная самса с курицей	95.00	24	\N	22	4690000000039	2026-10-02 13:42:34.038543+03
40	Кулебяка с рыбой	Пирог с рыбной начинкой	420.00	48	\N	23	4690000000040	2026-10-02 13:42:34.038543+03
41	Расстегай с грибами	Открытый пирожок с грибами	85.00	24	\N	24	4690000000041	2026-10-02 13:42:34.038543+03
42	Курник	Пирог с курицей и рисом	480.00	48	\N	25	4690000000042	2026-10-02 13:42:34.038543+03
43	Штрудель яблочный	Штрудель с яблоками и корицей	320.00	48	\N	26	4690000000043	2026-10-02 13:42:34.038543+03
44	Плетенка с маком	Плетеная сдоба с маком	180.00	72	\N	49	4690000000044	2026-10-02 13:42:34.038543+03
45	Рогалик с повидлом	Маленький рогалик с повидлом	35.00	72	\N	50	4690000000045	2026-10-02 13:42:34.038543+03
46	Сухари домашние	Сухари из белого хлеба	90.00	180	\N	18	4690000000046	2026-10-02 13:42:34.038543+03
47	Баранки обычные	Обычные баранки	70.00	90	\N	19	4690000000047	2026-10-02 13:42:34.038543+03
48	Сушки с маком	Сушки с маком	80.00	90	\N	19	4690000000048	2026-10-02 13:42:34.038543+03
49	Калач московский	Сдобный калач	95.00	48	\N	48	4690000000049	2026-10-02 13:42:34.038543+03
50	Пампушка с чесноком	Пампушка к борщу	40.00	24	\N	48	4690000000050	2026-10-02 13:42:34.038543+03
\.


--
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipes (id, ingredient_id, product_id, quantity, instructions, created_at) FROM stdin;
1	1	1	0.50	Замесить тесто, дать подняться 2 часа, выпекать при 220°C 25 минут	2026-10-02 13:42:34.038543+03
2	2	2	0.45	Приготовить заварку, замесить ржаное тесто, расстойка 3 часа, выпекать 40 минут	2026-10-02 13:42:34.038543+03
3	1	3	0.40	Замесить опарное тесто, сформировать батон, выпекать 20 минут	2026-10-02 13:42:34.038543+03
4	1	4	0.35	Замесить крутое тесто, сформировать багет, надрезать, выпекать при 240°C	2026-10-02 13:42:34.038543+03
5	1	5	0.15	Приготовить сдобное тесто, добавить мак, сформировать булочки, выпекать 15 минут	2026-10-02 13:42:34.038543+03
6	1	6	0.15	Замесить сдобное тесто с изюмом, расстойка 1 час, выпекать 18 минут	2026-10-02 13:42:34.038543+03
7	1	7	0.12	Приготовить слоеное тесто, раскатать, сформировать круассан, выпекать 12 минут	2026-10-02 13:42:34.038543+03
8	1	8	0.15	Слоеное тесто с шоколадной начинкой, расстойка 2 часа, выпекать 14 минут	2026-10-02 13:42:34.038543+03
9	1	9	0.20	Приготовить бисквит, пропитать сиропом, покрыть кремом с какао	2026-10-02 13:42:34.038543+03
10	1	10	0.18	Заварное тесто, выпекать полые пирожные, наполнить заварным кремом	2026-10-02 13:42:34.038543+03
11	1	11	1.50	Приготовить слоеные коржи, промазать кремом, пропитать 12 часов	2026-10-02 13:42:34.038543+03
12	1	12	1.40	Медовые коржи, сметанный крем, пропитка 8 часов	2026-10-02 13:42:34.038543+03
13	1	13	0.80	Овсяные хлопья, сахар, масло, изюм, выпекать 15 минут при 180°C	2026-10-02 13:42:34.038543+03
14	1	14	0.70	Песочное тесто, формочки, выпекать 12 минут при 190°C	2026-10-02 13:42:34.038543+03
15	1	15	0.15	Пряничное тесто на меду, начинка яблочная, выпекать 20 минут	2026-10-02 13:42:34.038543+03
16	1	16	0.18	Слоеное тесто, начинка из сыра, выпекать 18 минут	2026-10-02 13:42:34.038543+03
17	1	17	0.20	Слоеное тесто, яблочная начинка, выпекать 20 минут	2026-10-02 13:42:34.038543+03
18	1	18	0.20	Дрожжевое тесто, начинка творог с изюмом, выпекать 20 минут	2026-10-02 13:42:34.038543+03
19	1	19	1.20	Дрожжевое тесто, начинка капуста, расстойка, выпекать 35 минут	2026-10-02 13:42:34.038543+03
20	1	20	1.30	Дрожжевое тесто, мясная начинка, выпекать 40 минут	2026-10-02 13:42:34.038543+03
21	1	21	0.15	Дрожжевое тесто, жарить в масле, начинить джемом	2026-10-02 13:42:34.038543+03
22	1	22	0.15	Дрожжевое тесто, жарить в масле, покрыть глазурью	2026-10-02 13:42:34.038543+03
23	1	23	0.80	Кексовое тесто с изюмом, выпекать в форме 50 минут	2026-10-02 13:42:34.038543+03
24	1	24	0.12	Шоколадное тесто в формочках, выпекать 20 минут	2026-10-02 13:42:34.038543+03
25	1	25	1.00	Дрожжевое тесто, маковая начинка, свернуть рулетом, выпекать 30 минут	2026-10-02 13:42:34.038543+03
26	1	26	1.00	Сдобное тесто, посыпать корицей, свернуть, выпекать 35 минут	2026-10-02 13:42:34.038543+03
27	1	27	0.18	Песочное тесто, творожная начинка, выпекать 18 минут	2026-10-02 13:42:34.038543+03
28	1	28	0.35	Дрожжевое тесто, сыр, яйцо, выпекать 15 минут при 250°C	2026-10-02 13:42:34.038543+03
29	1	29	0.25	Пресное тесто, раскатать тонко, выпекать на сковороде 1 минуту	2026-10-02 13:42:34.038543+03
30	1	30	0.40	Жидкое дрожжевое тесто, выпекать на поду 25 минут	2026-10-02 13:42:34.038543+03
31	1	31	0.45	Тесто с оливковым маслом, розмарин, выпекать 20 минут	2026-10-02 13:42:34.038543+03
32	2	32	0.50	Ржано-пшеничное тесто, формовая выпечка, 45 минут	2026-10-02 13:42:34.038543+03
33	1	33	0.55	Тесто с семенами, расстойка, выпекать 40 минут	2026-10-02 13:42:34.038543+03
34	1	34	0.60	Цельнозерновая мука, долгая расстойка, выпекать 50 минут	2026-10-02 13:42:34.038543+03
35	1	35	0.55	Тесто с овсянкой, выпекать в форме 45 минут	2026-10-02 13:42:34.038543+03
36	1	36	0.15	Дрожжевое тесто, начинка картофель, жарить в масле	2026-10-02 13:42:34.038543+03
37	1	37	0.15	Дрожжевое тесто, начинка яйцо с луком, жарить	2026-10-02 13:42:34.038543+03
38	1	38	0.20	Пресное тесто, мясная начинка, жарить во фритюре	2026-10-02 13:42:34.038543+03
39	1	39	0.18	Слоеное тесто, куриная начинка, выпекать 25 минут	2026-10-02 13:42:34.038543+03
40	1	40	1.40	Дрожжевое тесто, рыбная начинка, выпекать 45 минут	2026-10-02 13:42:34.038543+03
41	1	41	0.18	Дрожжевое тесто, грибы, открытый пирожок, выпекать 20 минут	2026-10-02 13:42:34.038543+03
42	1	42	1.60	Дрожжевое тесто, курица с рисом, выпекать 50 минут	2026-10-02 13:42:34.038543+03
43	1	43	0.90	Вытяжное тесто, яблоки с корицей, свернуть, выпекать 35 минут	2026-10-02 13:42:34.038543+03
44	1	44	0.80	Сдобное тесто, мак, заплести косичкой, выпекать 40 минут	2026-10-02 13:42:34.038543+03
45	1	45	0.08	Сдобное тесто, повидло, свернуть рогаликом, выпекать 12 минут	2026-10-02 13:42:34.038543+03
46	1	46	0.50	Черствый хлеб нарезать, сушить в духовке 2 часа	2026-10-02 13:42:34.038543+03
47	1	47	0.30	Заварное крутое тесто, формировать баранки, варить, выпекать	2026-10-02 13:42:34.038543+03
48	1	48	0.25	Заварное тесто с маком, формировать сушки, выпекать	2026-10-02 13:42:34.038543+03
49	1	49	0.30	Сдобное тесто, расстойка, выпекать в форме 30 минут	2026-10-02 13:42:34.038543+03
50	1	50	0.10	Дрожжевое тесто, чесночная намазка, выпекать 12 минут	2026-10-02 13:42:34.038543+03
\.


--
-- Data for Name: returns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.returns (id, sale_id, sale_item_id, product_id, employee_id, customer_id, reason, return_date, refund_amount, status) FROM stdin;
1	2	2	2	2	2	Неверный товар выдали вместо заказанного	2026-11-02	87.00	completed
2	3	3	3	3	3	Продукт подгорелый, непригоден к употреблению	2026-10-30	124.00	completed
3	4	4	4	4	4	Покупатель передумал, товар не вскрывался	2026-10-27	161.00	completed
4	5	5	5	5	\N	Посторонний предмет в выпечке	2026-10-24	198.00	completed
5	6	6	6	6	6	Нарушена целостность упаковки	2026-10-21	235.00	completed
6	7	7	7	7	7	Аллергическая реакция на ингредиент	2026-10-18	272.00	completed
7	8	8	8	8	8	Продукт оказался несвежим, истёк срок годности	2026-10-15	309.00	not_completed
8	9	9	9	9	9	Неверный товар выдали вместо заказанного	2026-10-12	346.00	not_completed
9	10	10	10	10	\N	Продукт подгорелый, непригоден к употреблению	2026-10-09	383.00	not_completed
10	11	11	11	11	11	Покупатель передумал, товар не вскрывался	2026-10-06	420.00	completed
11	12	12	12	12	12	Посторонний предмет в выпечке	2026-10-03	457.00	completed
12	13	13	13	13	13	Нарушена целостность упаковки	2026-09-30	494.00	completed
13	14	14	14	14	14	Аллергическая реакция на ингредиент	2026-09-27	531.00	completed
14	15	15	15	15	\N	Продукт оказался несвежим, истёк срок годности	2026-10-08	568.00	completed
15	16	16	16	16	16	Неверный товар выдали вместо заказанного	2026-10-05	605.00	completed
16	17	17	17	17	17	Продукт подгорелый, непригоден к употреблению	2026-10-02	642.00	completed
17	18	18	18	18	18	Покупатель передумал, товар не вскрывался	2026-09-29	679.00	not_completed
18	19	19	19	19	19	Посторонний предмет в выпечке	2026-09-26	716.00	not_completed
19	20	20	20	20	\N	Нарушена целостность упаковки	2026-09-23	753.00	not_completed
20	21	21	21	21	21	Аллергическая реакция на ингредиент	2026-09-20	790.00	completed
21	22	22	22	22	22	Продукт оказался несвежим, истёк срок годности	2026-09-17	827.00	completed
22	23	23	23	23	23	Неверный товар выдали вместо заказанного	2026-09-14	864.00	completed
23	24	24	24	24	24	Продукт подгорелый, непригоден к употреблению	2026-09-11	901.00	completed
24	25	25	25	25	\N	Покупатель передумал, товар не вскрывался	2026-09-08	938.00	completed
25	26	26	26	26	26	Посторонний предмет в выпечке	2026-09-05	975.00	completed
26	27	27	27	27	27	Нарушена целостность упаковки	2026-09-02	1012.00	completed
27	28	28	28	28	28	Аллергическая реакция на ингредиент	2026-08-30	1049.00	not_completed
28	29	29	29	29	29	Продукт оказался несвежим, истёк срок годности	2026-09-10	1086.00	not_completed
29	30	30	30	30	\N	Неверный товар выдали вместо заказанного	2026-09-07	1123.00	not_completed
30	31	31	31	31	31	Продукт подгорелый, непригоден к употреблению	2026-09-04	1160.00	completed
31	32	32	32	32	32	Покупатель передумал, товар не вскрывался	2026-09-01	1197.00	completed
32	33	33	33	33	33	Посторонний предмет в выпечке	2026-08-29	1234.00	completed
33	34	34	34	34	34	Нарушена целостность упаковки	2026-08-26	1271.00	completed
34	35	35	35	35	\N	Аллергическая реакция на ингредиент	2026-08-23	1308.00	completed
35	36	36	36	36	36	Продукт оказался несвежим, истёк срок годности	2026-08-20	1345.00	completed
36	37	37	37	37	37	Неверный товар выдали вместо заказанного	2026-08-17	1382.00	completed
37	38	38	38	38	38	Продукт подгорелый, непригоден к употреблению	2026-08-14	1419.00	not_completed
38	39	39	39	39	39	Покупатель передумал, товар не вскрывался	2026-08-11	1456.00	not_completed
39	40	40	40	40	\N	Посторонний предмет в выпечке	2026-08-08	1493.00	not_completed
40	41	41	41	41	41	Нарушена целостность упаковки	2026-08-05	80.00	completed
41	42	42	42	42	42	Аллергическая реакция на ингредиент	2026-08-02	117.00	completed
42	43	43	43	43	43	Продукт оказался несвежим, истёк срок годности	2026-08-13	154.00	completed
43	44	44	44	44	44	Неверный товар выдали вместо заказанного	2026-08-10	191.00	completed
44	45	45	45	45	\N	Продукт подгорелый, непригоден к употреблению	2026-08-07	228.00	completed
45	46	46	46	46	46	Покупатель передумал, товар не вскрывался	2026-08-04	265.00	completed
46	47	47	47	47	47	Посторонний предмет в выпечке	2026-08-01	302.00	completed
47	48	48	48	48	48	Нарушена целостность упаковки	2026-07-29	339.00	not_completed
48	49	49	49	49	49	Аллергическая реакция на ингредиент	2026-07-26	376.00	not_completed
49	50	50	50	50	\N	Продукт оказался несвежим, истёк срок годности	2026-07-23	413.00	not_completed
50	1	1	1	1	1	Неверный товар выдали вместо заказанного	2026-07-20	450.00	completed
\.


--
-- Data for Name: salary_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary_payments (id, employee_id, bakery_id, start_billing_period, end_billing_period, base_amount, bonus_amount, taxes_amount, total_amount, status, payment_date) FROM stdin;
1	2	2	2026-10-01	2026-10-31	31103.00	733.00	9550.80	41386.80	in_progress	2026-11-07
2	3	3	2026-09-01	2026-09-30	32206.00	1466.00	10101.60	43773.60	not_completed	2026-10-08
3	4	4	2026-08-01	2026-08-31	33309.00	2199.00	10652.40	46160.40	completed	2026-09-09
4	5	5	2026-07-01	2026-07-31	34412.00	2932.00	11203.20	48547.20	not_completed	2026-08-10
5	6	6	2026-06-01	2026-06-30	35515.00	3665.00	11754.00	50934.00	completed	2026-07-11
6	7	7	2026-05-01	2026-05-31	36618.00	4398.00	12304.80	53320.80	completed	2026-06-06
7	8	8	2026-04-01	2026-04-30	37721.00	5131.00	12855.60	55707.60	not_completed	2026-05-07
8	9	9	2026-03-01	2026-03-31	38824.00	5864.00	13406.40	58094.40	not_completed	2026-04-08
9	10	10	2026-02-01	2026-02-28	39927.00	6597.00	13957.20	60481.20	completed	2026-03-09
10	11	1	2026-01-01	2026-01-31	41030.00	7330.00	14508.00	62868.00	in_progress	2026-02-10
11	12	2	2025-12-01	2025-12-31	42133.00	8063.00	15058.80	65254.80	completed	2026-01-11
12	13	3	2026-11-01	2026-11-30	43236.00	8796.00	15609.60	67641.60	in_progress	2026-12-06
13	14	4	2026-10-01	2026-10-31	44339.00	9529.00	16160.40	70028.40	completed	2026-11-07
14	15	5	2026-09-01	2026-09-30	45442.00	10262.00	16711.20	72415.20	completed	2026-10-08
15	16	6	2026-08-01	2026-08-31	46545.00	10995.00	17262.00	74802.00	not_completed	2026-09-09
16	17	7	2026-07-01	2026-07-31	47648.00	11728.00	17812.80	77188.80	completed	2026-08-10
17	18	8	2026-06-01	2026-06-30	48751.00	12461.00	18363.60	79575.60	not_completed	2026-07-11
18	19	9	2026-05-01	2026-05-31	49854.00	13194.00	18914.40	81962.40	completed	2026-06-06
19	20	10	2026-04-01	2026-04-30	50957.00	13927.00	19465.20	84349.20	completed	2026-05-07
20	21	1	2026-03-01	2026-03-31	52060.00	14660.00	20016.00	86736.00	in_progress	2026-04-08
21	22	2	2026-02-01	2026-02-28	53163.00	15393.00	20566.80	89122.80	completed	2026-03-09
22	23	3	2026-01-01	2026-01-31	54266.00	16126.00	21117.60	91509.60	in_progress	2026-02-10
23	24	4	2025-12-01	2025-12-31	55369.00	16859.00	21668.40	93896.40	not_completed	2026-01-11
24	25	5	2026-11-01	2026-11-30	56472.00	17592.00	22219.20	96283.20	completed	2026-12-06
25	26	6	2026-10-01	2026-10-31	57575.00	18325.00	22770.00	98670.00	not_completed	2026-11-07
26	27	7	2026-09-01	2026-09-30	58678.00	19058.00	23320.80	101056.80	completed	2026-10-08
27	28	8	2026-08-01	2026-08-31	59781.00	19791.00	23871.60	103443.60	not_completed	2026-09-09
28	29	9	2026-07-01	2026-07-31	60884.00	523.00	18422.10	79829.10	not_completed	2026-08-10
29	30	10	2026-06-01	2026-06-30	61987.00	1256.00	18972.90	82215.90	completed	2026-07-11
30	31	1	2026-05-01	2026-05-31	63090.00	1989.00	19523.70	84602.70	in_progress	2026-06-06
31	32	2	2026-04-01	2026-04-30	64193.00	2722.00	20074.50	86989.50	not_completed	2026-05-07
32	33	3	2026-03-01	2026-03-31	65296.00	3455.00	20625.30	89376.30	completed	2026-04-08
33	34	4	2026-02-01	2026-02-28	66399.00	4188.00	21176.10	91763.10	completed	2026-03-09
34	35	5	2026-01-01	2026-01-31	67502.00	4921.00	21726.90	94149.90	completed	2026-02-10
35	36	6	2025-12-01	2025-12-31	68605.00	5654.00	22277.70	96536.70	completed	2026-01-11
36	37	7	2026-11-01	2026-11-30	69708.00	6387.00	22828.50	98923.50	completed	2026-12-06
37	38	8	2026-10-01	2026-10-31	70811.00	7120.00	23379.30	101310.30	in_progress	2026-11-07
38	39	9	2026-09-01	2026-09-30	71914.00	7853.00	23930.10	103697.10	completed	2026-10-08
39	40	10	2026-08-01	2026-08-31	73017.00	8586.00	24480.90	106083.90	completed	2026-09-09
40	41	1	2026-07-01	2026-07-31	74120.00	9319.00	25031.70	108470.70	completed	2026-08-10
41	42	2	2026-06-01	2026-06-30	75223.00	10052.00	25582.50	110857.50	not_completed	2026-07-11
42	43	3	2026-05-01	2026-05-31	76326.00	10785.00	26133.30	113244.30	not_completed	2026-06-06
43	44	4	2026-04-01	2026-04-30	77429.00	11518.00	26684.10	115631.10	completed	2026-05-07
44	45	5	2026-03-01	2026-03-31	78532.00	12251.00	27234.90	118017.90	in_progress	2026-04-08
45	46	6	2026-02-01	2026-02-28	79635.00	12984.00	27785.70	120404.70	completed	2026-03-09
46	47	7	2026-01-01	2026-01-31	30738.00	13717.00	13336.50	57791.50	not_completed	2026-02-10
47	48	8	2025-12-01	2025-12-31	31841.00	14450.00	13887.30	60178.30	not_completed	2026-01-11
48	49	9	2026-11-01	2026-11-30	32944.00	15183.00	14438.10	62565.10	completed	2026-12-06
49	50	10	2026-10-01	2026-10-31	34047.00	15916.00	14988.90	64951.90	completed	2026-11-07
50	1	1	2026-09-01	2026-09-30	35150.00	16649.00	15539.70	67338.70	not_completed	2026-10-08
\.


--
-- Data for Name: sale_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sale_details (id, sale_id, product_id, quantity, total_per_item, discount_id, created_at) FROM stdin;
1	2	2	2.00	170.00	2	2026-11-05 11:19:12.148599+03
2	3	3	3.00	165.00	3	2026-11-05 11:19:12.148599+03
3	4	4	4.00	380.00	\N	2026-11-05 11:19:12.148599+03
4	5	5	5.00	225.00	\N	2026-11-05 11:19:12.148599+03
5	6	6	1.00	50.00	\N	2026-11-05 11:19:12.148599+03
6	7	7	2.00	150.00	\N	2026-11-05 11:19:12.148599+03
7	8	8	3.00	255.00	\N	2026-11-05 11:19:12.148599+03
8	9	9	4.00	480.00	\N	2026-11-05 11:19:12.148599+03
9	10	10	5.00	550.00	\N	2026-11-05 11:19:12.148599+03
10	11	11	1.00	850.00	11	2026-11-05 11:19:12.148599+03
11	12	12	2.00	1560.00	12	2026-11-05 11:19:12.148599+03
12	13	13	3.00	540.00	13	2026-11-05 11:19:12.148599+03
13	14	14	4.00	640.00	\N	2026-11-05 11:19:12.148599+03
14	15	15	5.00	325.00	\N	2026-11-05 11:19:12.148599+03
15	16	16	1.00	70.00	\N	2026-11-05 11:19:12.148599+03
16	17	17	2.00	150.00	\N	2026-11-05 11:19:12.148599+03
17	18	18	3.00	165.00	\N	2026-11-05 11:19:12.148599+03
18	19	19	4.00	1280.00	\N	2026-11-05 11:19:12.148599+03
19	20	20	5.00	1900.00	\N	2026-11-05 11:19:12.148599+03
20	21	21	1.00	60.00	21	2026-11-05 11:19:12.148599+03
21	22	22	2.00	130.00	22	2026-11-05 11:19:12.148599+03
22	23	23	3.00	660.00	23	2026-11-05 11:19:12.148599+03
23	24	24	4.00	380.00	\N	2026-11-05 11:19:12.148599+03
24	25	25	5.00	1400.00	\N	2026-11-05 11:19:12.148599+03
25	26	26	1.00	260.00	\N	2026-11-05 11:19:12.148599+03
26	27	27	2.00	110.00	\N	2026-11-05 11:19:12.148599+03
27	28	28	3.00	540.00	\N	2026-11-05 11:19:12.148599+03
28	29	29	4.00	180.00	\N	2026-11-05 11:19:12.148599+03
29	30	30	5.00	550.00	\N	2026-11-05 11:19:12.148599+03
30	31	31	1.00	130.00	31	2026-11-05 11:19:12.148599+03
31	32	32	2.00	150.00	32	2026-11-05 11:19:12.148599+03
32	33	33	3.00	285.00	33	2026-11-05 11:19:12.148599+03
33	34	34	4.00	420.00	\N	2026-11-05 11:19:12.148599+03
34	35	35	5.00	500.00	\N	2026-11-05 11:19:12.148599+03
35	36	36	1.00	50.00	\N	2026-11-05 11:19:12.148599+03
36	37	37	2.00	110.00	\N	2026-11-05 11:19:12.148599+03
37	38	38	3.00	360.00	\N	2026-11-05 11:19:12.148599+03
38	39	39	4.00	380.00	\N	2026-11-05 11:19:12.148599+03
39	40	40	5.00	2100.00	\N	2026-11-05 11:19:12.148599+03
40	41	41	1.00	85.00	41	2026-11-05 11:19:12.148599+03
41	42	42	2.00	960.00	42	2026-11-05 11:19:12.148599+03
42	43	43	3.00	960.00	43	2026-11-05 11:19:12.148599+03
43	44	44	4.00	720.00	\N	2026-11-05 11:19:12.148599+03
44	45	45	5.00	175.00	\N	2026-11-05 11:19:12.148599+03
45	46	46	1.00	90.00	\N	2026-11-05 11:19:12.148599+03
46	47	47	2.00	140.00	\N	2026-11-05 11:19:12.148599+03
47	48	48	3.00	240.00	\N	2026-11-05 11:19:12.148599+03
48	49	49	4.00	380.00	\N	2026-11-05 11:19:12.148599+03
49	50	50	5.00	200.00	\N	2026-11-05 11:19:12.148599+03
50	1	1	1.00	65.00	1	2026-11-05 11:19:12.148599+03
\.


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales (id, customer_id, employee_id, bakery_id, date, payment_method, total_amount, status, points_earned, points_spent) FROM stdin;
1	2	2	2	2026-11-01 00:00:00	наличные	223.00	completed	28	0
2	3	3	3	2026-10-28 00:00:00	банковская_карта	296.00	completed	44	0
3	4	4	4	2026-10-24 00:00:00	банковская_карта	369.00	completed	74	0
4	5	5	5	2026-10-20 00:00:00	банковская_карта	442.00	completed	44	0
5	6	6	6	2026-10-21 00:00:00	СБП	515.00	completed	64	77
6	7	7	7	2026-10-17 00:00:00	наличные	588.00	completed	88	0
7	\N	8	8	2026-10-13 00:00:00	наличные	661.00	completed	0	0
8	\N	9	9	2026-10-09 00:00:00	банковская_карта	734.00	completed	0	0
9	\N	10	10	2026-10-05 00:00:00	банковская_карта	807.00	completed	0	0
10	11	11	1	2026-10-06 00:00:00	банковская_карта	880.00	not_completed	132	132
11	12	12	2	2026-10-02 00:00:00	СБП	953.00	completed	191	0
12	13	13	3	2026-09-28 00:00:00	наличные	1026.00	completed	103	0
13	14	14	4	2026-09-24 00:00:00	наличные	1099.00	completed	137	0
14	15	15	5	2026-09-20 00:00:00	банковская_карта	1172.00	completed	176	0
15	16	16	6	2026-09-21 00:00:00	банковская_карта	1245.00	completed	249	187
16	17	17	7	2026-09-17 00:00:00	банковская_карта	1318.00	completed	132	0
17	\N	18	8	2026-09-13 00:00:00	СБП	1391.00	completed	0	0
18	\N	19	9	2026-09-09 00:00:00	наличные	1464.00	completed	0	0
19	\N	20	10	2026-09-05 00:00:00	наличные	1537.00	completed	0	0
20	21	21	1	2026-09-06 00:00:00	банковская_карта	1610.00	not_completed	161	242
21	22	22	2	2026-09-02 00:00:00	банковская_карта	1683.00	completed	210	0
22	23	23	3	2026-08-29 00:00:00	банковская_карта	1756.00	completed	263	0
23	24	24	4	2026-08-25 00:00:00	СБП	1829.00	completed	366	0
24	25	25	5	2026-08-21 00:00:00	наличные	1902.00	completed	190	0
25	26	26	6	2026-08-22 00:00:00	наличные	1975.00	completed	247	296
26	27	27	7	2026-08-18 00:00:00	банковская_карта	2048.00	completed	307	0
27	\N	28	8	2026-08-14 00:00:00	банковская_карта	2121.00	completed	0	0
28	\N	29	9	2026-08-10 00:00:00	банковская_карта	2194.00	completed	0	0
29	\N	30	10	2026-08-06 00:00:00	СБП	2267.00	completed	0	0
30	31	31	1	2026-08-07 00:00:00	наличные	2340.00	not_completed	351	351
31	32	32	2	2026-08-03 00:00:00	наличные	2413.00	completed	483	0
32	33	33	3	2026-07-30 00:00:00	банковская_карта	2486.00	completed	249	0
33	34	34	4	2026-07-26 00:00:00	банковская_карта	2559.00	completed	320	0
34	35	35	5	2026-07-22 00:00:00	банковская_карта	2632.00	completed	395	0
35	36	36	6	2026-07-23 00:00:00	СБП	2705.00	completed	541	406
36	37	37	7	2026-07-19 00:00:00	наличные	2778.00	completed	278	0
37	\N	38	8	2026-07-15 00:00:00	наличные	2851.00	completed	0	0
38	\N	39	9	2026-07-11 00:00:00	банковская_карта	2924.00	completed	0	0
39	\N	40	10	2026-07-07 00:00:00	банковская_карта	2997.00	completed	0	0
40	41	41	1	2026-07-08 00:00:00	банковская_карта	3070.00	not_completed	307	461
41	42	42	2	2026-07-04 00:00:00	СБП	3143.00	completed	393	0
42	43	43	3	2026-06-30 00:00:00	наличные	3216.00	completed	482	0
43	44	44	4	2026-06-26 00:00:00	наличные	3289.00	completed	658	0
44	45	45	5	2026-06-22 00:00:00	банковская_карта	3362.00	completed	336	0
45	46	46	6	2026-06-23 00:00:00	банковская_карта	3435.00	completed	429	515
46	47	47	7	2026-06-19 00:00:00	банковская_карта	158.00	completed	24	0
47	\N	48	8	2026-06-15 00:00:00	СБП	231.00	completed	0	0
48	\N	49	9	2026-06-11 00:00:00	наличные	304.00	completed	0	0
49	\N	50	10	2026-06-07 00:00:00	наличные	377.00	completed	0	0
50	1	1	1	2026-06-08 00:00:00	банковская_карта	450.00	not_completed	68	68
\.


--
-- Data for Name: supplier_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier_ingredients (id, supplier_id, ingredient_id) FROM stdin;
1	1	1
2	2	2
3	3	3
4	4	4
5	5	5
6	6	6
7	7	7
8	8	8
9	9	9
10	10	10
11	11	11
12	12	12
13	13	13
14	14	14
15	15	15
16	16	16
17	17	17
18	18	18
19	19	19
20	20	20
21	21	21
22	22	22
23	23	23
24	24	24
25	25	25
26	26	26
27	27	27
28	28	28
29	29	29
30	30	30
31	31	31
32	32	32
33	33	33
34	34	34
35	35	35
36	36	36
37	37	37
38	38	38
39	39	39
40	40	40
41	41	41
42	42	42
43	43	43
44	44	44
45	45	45
46	46	46
47	47	47
48	48	48
49	49	49
50	50	50
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, name_company, license, status, email, telephone_number, reputation, website, address, tin, contract_date) FROM stdin;
1	ООО Мельник	t	active	info@melnik.ru	+79001000001	4.50	https://melnik.ru	г. Москва, ул. Зерновая, 1	7700000001	2023-01-15
2	ИП Иванов А.И.	t	active	ivanov@mail.ru	+79001000002	4.80	https://ivanov-farm.ru	г. Тула, пр. Ленина, 10	7100000002	2023-02-20
3	АО СахарТорг	t	active	sales@sakhar.ru	+79001000003	4.20	https://sakartorg.ru	г. Курск, ул. Сладкая, 5	4600000003	2023-03-10
4	ООО Молочный Дом	t	active	order@moldom.ru	+79001000004	4.90	https://moldom.ru	г. Воронеж, ул. Фермерская, 12	3600000004	2023-04-05
5	ИП Петров С.В.	t	inactive	petrov.eggs@gmail.com	+79001000005	3.50	https://petrov-eggs.ru	г. Рязань, пер. Куриный, 3	6200000005	2023-05-12
6	ООО СпецииМир	t	active	info@spices.ru	+79001000006	4.60	https://spicesmir.ru	г. Казань, ул. Восточная, 45	1600000006	2023-06-18
7	ЗАО МаслоДел	t	active	b2b@maslodel.ru	+79001000007	4.70	https://maslodel.ru	г. Вологда, ш. Молочное, 7	3500000007	2023-07-22
8	ООО ДрожжиПлюс	t	active	sales@drozhzhi.ru	+79001000008	4.10	https://drozhzhiplus.ru	г. Москва, ул. Пекарская, 8	7700000008	2023-08-30
9	ИП Сидоров К.М.	t	active	sidorov.fruit@yandex.ru	+79001000009	4.40	https://sidorov-fruit.ru	г. Краснодар, ул. Фруктовая, 15	2300000009	2023-09-14
10	ООО Ореховая Роща	t	active	info@orehi.ru	+79001000010	4.30	https://orehovayaroscha.ru	г. Сочи, ул. Горная, 22	2300000010	2023-10-01
11	АО КондитерСнаб	t	active	zakaz@konditer.ru	+79001000011	4.80	https://konditersnab.ru	г. Санкт-Петербург, наб. Реки, 3	7800000011	2023-11-11
12	ООО Медовый Спас	t	active	info@medospas.ru	+79001000012	4.90	https://medospas.ru	г. Башкортостан, с. Пасека, 1	0200000012	2023-12-05
13	ИП Кузнецов Д.А.	t	active	kuznetsov.veg@mail.ru	+79001000013	4.00	https://kuznetsov-veg.ru	г. Астрахань, ул. Огородная, 9	3000000013	2024-01-10
14	ООО Шоколадный Рай	t	active	sales@shokoray.ru	+79001000014	4.70	https://shokoray.ru	г. Москва, ул. Сладкая, 14	7700000014	2024-02-14
15	ЗАО Мак и Кунжут	t	active	info@mak-kunzhut.ru	+79001000015	4.20	https://mak-kunzhut.ru	г. Ростов-на-Дону, ул. Полевая, 5	6100000015	2024-03-18
16	ООО КрахмалТорг	t	inactive	sales@krakhmal.ru	+79001000016	3.80	https://krakhmaltorg.ru	г. Рязань, пр. Заводской, 11	6200000016	2024-04-22
17	ИП Смирнова Е.В.	t	active	smirnova.dairy@gmail.com	+79001000017	4.60	https://smirnova-dairy.ru	г. Тверь, ул. Корovnaya, 7	6900000017	2024-05-05
18	ООО Сырный Дом	t	active	info@sirniydom.ru	+79001000018	4.50	https://sirniydom.ru	г. Алтай, с. Сырное, 2	2200000018	2024-06-12
19	АО Мясной Двор	t	active	zakaz@myasdvor.ru	+79001000019	4.40	https://myasdvor.ru	г. Белгород, ул. Фермерская, 20	3100000019	2024-07-19
20	ООО Грибная Поляна	t	active	info@gribnaya.ru	+79001000020	4.10	https://gribnayapolyana.ru	г. Тверь, ул. Лесная, 33	6900000020	2024-08-25
21	ИП Орлов П.С.	t	active	orlov.green@yandex.ru	+79001000021	4.30	https://orlov-green.ru	г. Волгоград, ул. Садовая, 4	3400000021	2024-09-01
22	ООО Пряности	t	active	sales@pryanosti.ru	+79001000022	4.80	https://pryanosti.ru	г. Москва, ул. Ароматная, 6	7700000022	2024-10-10
23	ЗАО Уксус и Соус	t	active	info@uksus-sous.ru	+79001000023	4.00	https://uksus-sous.ru	г. Екатеринбург, ул. Кислая, 8	6600000023	2024-11-15
24	ООО Ваниль и Корица	t	active	zakaz@vanil-korica.ru	+79001000024	4.70	https://vanil-korica.ru	г. Казань, ул. Сладкая, 10	1600000024	2024-12-01
25	ИП Николаев И.И.	t	active	nikolaev.water@mail.ru	+79001000025	4.50	https://nikolaev-water.ru	г. Владимир, ул. Родниковая, 1	3300000025	2025-01-12
26	ООО Желатин-Агар	t	active	info@jelagin-agar.ru	+79001000026	4.20	https://jelagin-agar.ru	г. Москва, ул. Химическая, 15	7700000026	2025-02-18
27	АО ПектинСнаб	t	active	sales@pektin.ru	+79001000027	4.60	https://pektinsnab.ru	г. Краснодар, ул. Фруктовая, 25	2300000027	2025-03-22
28	ООО Сливки и Творог	t	inactive	info@slivki-tvorog.ru	+79001000028	3.90	https://slivki-tvorog.ru	г. Омск, ул. Молочная, 5	5500000028	2025-04-05
29	ИП Васильев С.А.	t	active	vasilev.meat@gmail.com	+79001000029	4.40	https://vasilev-meat.ru	г. Самара, ул. Мясная, 12	6300000029	2025-05-10
30	ООО Луковая Сотка	t	active	zakaz@lukovaya.ru	+79001000030	4.10	https://lukovayasotka.ru	г. Астрахань, ул. Огородная, 18	3000000030	2025-06-15
31	ЗАО Чеснок и Укроп	t	active	info@chesnok-ukrop.ru	+79001000031	4.30	https://chesnok-ukrop.ru	г. Ростов-на-Дону, ул. Зелёная, 7	6100000031	2025-07-20
32	ООО Травы и Специи	t	active	sales@travy-specii.ru	+79001000032	4.80	https://travy-specii.ru	г. Сочи, ул. Горная, 30	2300000032	2025-08-25
33	ИП Федоров А.В.	t	active	fedorov.pepper@yandex.ru	+79001000033	4.50	https://fedorov-pepper.ru	г. Краснодар, ул. Острая, 4	2300000033	2025-09-01
34	ООО Лавр и Гвоздика	t	active	info@lavr-gvozdika.ru	+79001000034	4.20	https://lavr-gvozdika.ru	г. Москва, ул. Пряная, 9	7700000034	2025-10-10
35	АО Мускат и Имбирь	t	active	zakaz@muskat-imbir.ru	+79001000035	4.70	https://muskat-imbir.ru	г. Санкт-Петербург, наб. Чайная, 2	7800000035	2025-11-15
36	ООО Кардамон и Паприка	t	active	info@cardamon-paprika.ru	+79001000036	4.00	https://cardamon-paprika.ru	г. Казань, ул. Восточная, 50	1600000036	2025-12-01
37	ИП Морозов Д.К.	t	active	morozov.kurkuma@mail.ru	+79001000037	4.40	https://morozov-kurkuma.ru	г. Новосибирск, ул. Желтая, 11	5400000037	2026-01-12
38	ООО КориандрТорг	t	active	sales@koriandr.ru	+79001000038	4.60	https://koriandrtorg.ru	г. Воронеж, ул. Ароматная, 14	3600000038	2026-02-18
39	ЗАО Семена и Зерна	t	active	info@semena-zerna.ru	+79001000039	4.30	https://semena-zerna.ru	г. Алтай, с. Полевое, 5	2200000039	2026-03-22
40	ООО Ореховый Микс	t	inactive	zakaz@orehoviy-mix.ru	+79001000040	3.70	https://orehoviy-mix.ru	г. Краснодар, ул. Ореховая, 8	2300000040	2026-04-05
41	ИП Белов И.П.	t	active	belov.izyum@gmail.com	+79001000041	4.50	https://belov-izyum.ru	г. Ростов-на-Дону, ул. Сладкая, 16	6100000041	2026-05-10
42	ООО Мак и Семена	t	active	info@mak-semena.ru	+79001000042	4.10	https://mak-semena.ru	г. Тула, ул. Маковая, 3	7100000042	2026-06-15
43	АО Кунжут и Лен	t	active	sales@kunzhut-len.ru	+79001000043	4.80	https://kunzhut-len.ru	г. Москва, ул. Зерновая, 20	7700000043	2026-07-20
44	ООО Патока и Сироп	t	active	info@patoka-sirop.ru	+79001000044	4.20	https://patoka-sirop.ru	г. Рязань, ул. Сладкая, 7	6200000044	2026-08-25
45	ИП Соловьев А.М.	t	active	solovev.med@yandex.ru	+79001000045	4.40	https://solovev-med.ru	г. Башкортостан, с. Медовое, 2	0200000045	2026-09-01
46	ООО Желатин и Агар	t	active	zakaz@jelagin-agar2.ru	+79001000046	4.70	https://jelagin-agar2.ru	г. Санкт-Петербург, ул. Химическая, 10	7800000046	2026-10-10
47	ЗАО Пектин и Крахмал	t	active	info@pektin-krakhmal.ru	+79001000047	4.00	https://pektin-krakhmal.ru	г. Краснодар, ул. Фруктовая, 30	2300000047	2026-11-15
48	ООО Сливки и Молоко	t	active	sales@slivki-moloko.ru	+79001000048	4.60	https://slivki-moloko.ru	г. Вологда, ш. Молочное, 15	3500000048	2026-12-01
49	ИП Гусев В.Е.	t	active	gusev.tvorog@mail.ru	+79001000049	4.30	https://gusev-tvorog.ru	г. Тверь, ул. Фермерская, 9	6900000049	2027-01-12
50	ООО Сыр и Ветчина	t	active	info@sir-vetchina.ru	+79001000050	4.90	https://sir-vetchina.ru	г. Белгород, ул. Мясная, 25	3100000050	2027-02-18
\.


--
-- Data for Name: vacations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vacations (id, employee_id, year, type, start_date_vacation, end_date_vacation, day_count, status) FROM stdin;
1	1	2024	Учебный отпуск	2024-06-02 00:00:00	2024-06-15 00:00:00	14	inactive
2	2	2024	Без сохранения ЗП	2024-06-03 00:00:00	2024-06-16 00:00:00	14	active
3	3	2024	Ежегодный оплачиваемый	2024-06-04 00:00:00	2024-06-17 00:00:00	14	inactive
4	4	2024	Учебный отпуск	2024-06-05 00:00:00	2024-06-18 00:00:00	14	active
5	5	2024	Без сохранения ЗП	2024-06-06 00:00:00	2024-06-19 00:00:00	14	inactive
6	6	2024	Ежегодный оплачиваемый	2024-06-07 00:00:00	2024-06-20 00:00:00	14	active
7	7	2024	Учебный отпуск	2024-06-08 00:00:00	2024-06-21 00:00:00	14	inactive
8	8	2024	Без сохранения ЗП	2024-06-09 00:00:00	2024-06-22 00:00:00	14	active
9	9	2024	Ежегодный оплачиваемый	2024-06-10 00:00:00	2024-06-23 00:00:00	14	inactive
10	10	2024	Учебный отпуск	2024-06-11 00:00:00	2024-06-24 00:00:00	14	active
11	11	2024	Без сохранения ЗП	2024-06-12 00:00:00	2024-06-25 00:00:00	14	inactive
12	12	2024	Ежегодный оплачиваемый	2024-06-13 00:00:00	2024-06-26 00:00:00	14	active
13	13	2024	Учебный отпуск	2024-06-14 00:00:00	2024-06-27 00:00:00	14	inactive
14	14	2024	Без сохранения ЗП	2024-06-15 00:00:00	2024-06-28 00:00:00	14	active
15	15	2024	Ежегодный оплачиваемый	2024-06-16 00:00:00	2024-06-29 00:00:00	14	inactive
16	16	2024	Учебный отпуск	2024-06-17 00:00:00	2024-06-30 00:00:00	14	active
17	17	2024	Без сохранения ЗП	2024-06-18 00:00:00	2024-07-01 00:00:00	14	inactive
18	18	2024	Ежегодный оплачиваемый	2024-06-19 00:00:00	2024-07-02 00:00:00	14	active
19	19	2024	Учебный отпуск	2024-06-20 00:00:00	2024-07-03 00:00:00	14	inactive
20	20	2024	Без сохранения ЗП	2024-06-21 00:00:00	2024-07-04 00:00:00	14	active
21	21	2024	Ежегодный оплачиваемый	2024-06-01 00:00:00	2024-06-14 00:00:00	14	inactive
22	22	2024	Учебный отпуск	2024-06-02 00:00:00	2024-06-15 00:00:00	14	active
23	23	2024	Без сохранения ЗП	2024-06-03 00:00:00	2024-06-16 00:00:00	14	inactive
24	24	2024	Ежегодный оплачиваемый	2024-06-04 00:00:00	2024-06-17 00:00:00	14	active
25	25	2024	Учебный отпуск	2024-06-05 00:00:00	2024-06-18 00:00:00	14	inactive
26	26	2024	Без сохранения ЗП	2024-06-06 00:00:00	2024-06-19 00:00:00	14	active
27	27	2024	Ежегодный оплачиваемый	2024-06-07 00:00:00	2024-06-20 00:00:00	14	inactive
28	28	2024	Учебный отпуск	2024-06-08 00:00:00	2024-06-21 00:00:00	14	active
29	29	2024	Без сохранения ЗП	2024-06-09 00:00:00	2024-06-22 00:00:00	14	inactive
30	30	2024	Ежегодный оплачиваемый	2024-06-10 00:00:00	2024-06-23 00:00:00	14	active
31	31	2024	Учебный отпуск	2024-06-11 00:00:00	2024-06-24 00:00:00	14	inactive
32	32	2024	Без сохранения ЗП	2024-06-12 00:00:00	2024-06-25 00:00:00	14	active
33	33	2024	Ежегодный оплачиваемый	2024-06-13 00:00:00	2024-06-26 00:00:00	14	inactive
34	34	2024	Учебный отпуск	2024-06-14 00:00:00	2024-06-27 00:00:00	14	active
35	35	2024	Без сохранения ЗП	2024-06-15 00:00:00	2024-06-28 00:00:00	14	inactive
36	36	2024	Ежегодный оплачиваемый	2024-06-16 00:00:00	2024-06-29 00:00:00	14	active
37	37	2024	Учебный отпуск	2024-06-17 00:00:00	2024-06-30 00:00:00	14	inactive
38	38	2024	Без сохранения ЗП	2024-06-18 00:00:00	2024-07-01 00:00:00	14	active
39	39	2024	Ежегодный оплачиваемый	2024-06-19 00:00:00	2024-07-02 00:00:00	14	inactive
40	40	2024	Учебный отпуск	2024-06-20 00:00:00	2024-07-03 00:00:00	14	active
41	41	2024	Без сохранения ЗП	2024-06-21 00:00:00	2024-07-04 00:00:00	14	inactive
42	42	2024	Ежегодный оплачиваемый	2024-06-01 00:00:00	2024-06-14 00:00:00	14	active
43	43	2024	Учебный отпуск	2024-06-02 00:00:00	2024-06-15 00:00:00	14	inactive
44	44	2024	Без сохранения ЗП	2024-06-03 00:00:00	2024-06-16 00:00:00	14	active
45	45	2024	Ежегодный оплачиваемый	2024-06-04 00:00:00	2024-06-17 00:00:00	14	inactive
46	46	2024	Учебный отпуск	2024-06-05 00:00:00	2024-06-18 00:00:00	14	active
47	47	2024	Без сохранения ЗП	2024-06-06 00:00:00	2024-06-19 00:00:00	14	inactive
48	48	2024	Ежегодный оплачиваемый	2024-06-07 00:00:00	2024-06-20 00:00:00	14	active
49	49	2024	Учебный отпуск	2024-06-08 00:00:00	2024-06-21 00:00:00	14	inactive
50	50	2024	Без сохранения ЗП	2024-06-09 00:00:00	2024-06-22 00:00:00	14	active
51	1	2024	Ежегодный оплачиваемый	2024-06-01 00:00:00	2024-06-10 00:00:00	10	active
52	2	2024	Учебный отпуск	2024-06-05 00:00:00	2024-06-15 00:00:00	11	active
53	3	2024	Без сохранения ЗП	2024-06-08 00:00:00	2024-06-18 00:00:00	11	active
54	4	2024	Ежегодный оплачиваемый	2024-06-10 00:00:00	2024-06-20 00:00:00	11	active
55	5	2024	Учебный отпуск	2024-06-12 00:00:00	2024-06-22 00:00:00	11	active
56	21	2024	Ежегодный оплачиваемый	2024-06-01 00:00:00	2024-06-14 00:00:00	14	active
57	42	2024	Без сохранения ЗП	2024-06-01 00:00:00	2024-06-14 00:00:00	14	active
58	6	2024	Ежегодный оплачиваемый	2024-06-01 00:00:00	2024-06-05 00:00:00	5	active
59	7	2024	Учебный отпуск	2024-06-10 00:00:00	2024-06-15 00:00:00	6	active
60	8	2024	Без сохранения ЗП	2024-06-20 00:00:00	2024-06-25 00:00:00	6	inactive
\.


--
-- Data for Name: warehouse_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouse_access (id, warehouse_id, employee_id, access_level) FROM stdin;
1	1	1	Полный доступ
2	2	2	Полный доступ
3	3	3	Частичный доступ
4	4	4	Полный доступ
5	5	5	Частичный доступ
6	6	6	Полный доступ
7	7	7	Частичный доступ
8	8	8	Полный доступ
9	9	9	Частичный доступ
10	10	10	Полный доступ
11	11	11	Частичный доступ
12	12	12	Полный доступ
13	13	13	Частичный доступ
14	14	14	Полный доступ
15	15	15	Частичный доступ
16	16	16	Полный доступ
17	17	17	Частичный доступ
18	18	18	Полный доступ
19	19	19	Частичный доступ
20	20	20	Полный доступ
21	21	21	Частичный доступ
22	22	22	Полный доступ
23	23	23	Частичный доступ
24	24	24	Полный доступ
25	25	25	Частичный доступ
26	26	26	Полный доступ
27	27	27	Частичный доступ
28	28	28	Полный доступ
29	29	29	Частичный доступ
30	30	30	Полный доступ
31	31	31	Частичный доступ
32	32	32	Полный доступ
33	33	33	Частичный доступ
34	34	34	Полный доступ
35	35	35	Частичный доступ
36	36	36	Полный доступ
37	37	37	Частичный доступ
38	38	38	Полный доступ
39	39	39	Частичный доступ
40	40	40	Полный доступ
41	41	41	Частичный доступ
42	42	42	Полный доступ
43	43	43	Частичный доступ
44	44	44	Полный доступ
45	45	45	Частичный доступ
46	46	46	Полный доступ
47	47	47	Частичный доступ
48	48	48	Полный доступ
49	49	49	Частичный доступ
50	50	50	Полный доступ
\.


--
-- Data for Name: warehouse_deliveries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouse_deliveries (id, supplier_id, ingredient_id, quantity, date_dispatch, date_receipt, type, warehouse_id, delivery_cost, unit_price) FROM stdin;
1	1	1	1000.00	2024-01-10	2024-01-12	Автомобильная	1	21940.00	15.00
2	1	1	800.00	2024-01-20	2024-01-22	Автомобильная	1	18940.00	15.00
3	2	2	500.00	2024-01-11	2024-01-13	Автомобильная	1	14940.00	16.00
4	3	3	600.00	2024-01-12	2024-01-14	Железнодорожная	2	11940.00	8.33
5	3	4	200.00	2024-01-13	2024-01-15	Автомобильная	2	9940.00	15.00
6	4	5	300.00	2024-01-14	2024-01-15	Автомобильная	3	9440.00	8.33
7	5	6	100.00	2024-01-10	2024-01-12	Рефрижератор	3	10940.00	40.00
8	6	7	150.00	2024-01-11	2024-01-13	Рефрижератор	4	12440.00	36.67
9	7	8	200.00	2024-01-12	2024-01-13	Рефрижератор	4	12940.00	30.00
10	8	9	400.00	2024-01-13	2024-01-14	Автомобильная	5	10440.00	8.75
11	9	10	500.00	2024-01-14	2024-01-15	Рефрижератор	5	11440.00	9.00
12	10	11	2000.00	2024-01-10	2024-01-11	Автомобильная	6	14940.00	4.00
13	11	12	300.00	2024-01-11	2024-01-13	Рефрижератор	6	13940.00	23.33
14	12	13	10000.00	2024-01-12	2024-01-15	Железнодорожная	7	16940.00	1.00
15	13	14	200.00	2024-01-13	2024-01-15	Автомобильная	7	9440.00	12.50
16	14	15	150.00	2024-01-14	2024-01-16	Автомобильная	8	8940.00	13.33
17	15	16	250.00	2024-01-10	2024-01-12	Автомобильная	8	9940.00	12.00
18	16	17	50.00	2024-01-11	2024-01-14	Авиа	9	21940.00	300.00
19	17	18	60.00	2024-01-12	2024-01-15	Авиа	9	24940.00	300.00
20	18	19	100.00	2024-01-13	2024-01-16	Автомобильная	10	10940.00	40.00
21	19	20	150.00	2024-01-14	2024-01-16	Рефрижератор	10	13440.00	43.33
22	20	21	80.00	2024-01-10	2024-01-13	Автомобильная	11	10440.00	43.75
23	21	22	120.00	2024-01-11	2024-01-14	Автомобильная	11	11440.00	37.50
24	22	23	50.00	2024-01-12	2024-01-15	Автомобильная	12	9440.00	50.00
25	23	24	70.00	2024-01-13	2024-01-16	Автомобильная	12	9940.00	42.86
26	24	25	40.00	2024-01-14	2024-01-16	Автомобильная	13	8940.00	50.00
27	25	26	80.00	2024-01-10	2024-01-12	Автомобильная	13	10440.00	43.75
28	26	27	200.00	2024-01-11	2024-01-13	Автомобильная	14	10940.00	20.00
29	27	28	60.00	2024-01-12	2024-01-14	Рефрижератор	14	11940.00	83.33
30	28	29	50.00	2024-01-13	2024-01-15	Автомобильная	15	9440.00	50.00
31	29	30	80.00	2024-01-14	2024-01-16	Автомобильная	15	10440.00	43.75
32	30	31	100.00	2024-01-10	2024-01-12	Автомобильная	16	10940.00	40.00
33	31	32	200.00	2024-01-11	2024-01-13	Рефрижератор	16	12940.00	30.00
34	32	33	150.00	2024-01-12	2024-01-14	Рефрижератор	17	12440.00	36.67
35	33	34	80.00	2024-01-13	2024-01-15	Автомобильная	17	10440.00	43.75
36	34	35	100.00	2024-01-14	2024-01-16	Автомобильная	18	10940.00	40.00
37	35	36	120.00	2024-01-10	2024-01-12	Рефрижератор	18	11940.00	41.67
38	36	37	60.00	2024-01-11	2024-01-13	Автомобильная	19	9940.00	50.00
39	37	38	90.00	2024-01-12	2024-01-14	Рефрижератор	19	11440.00	50.00
40	38	39	70.00	2024-01-13	2024-01-15	Автомобильная	20	10440.00	50.00
41	39	40	50.00	2024-01-14	2024-01-16	Автомобильная	20	9440.00	50.00
42	40	41	80.00	2024-01-10	2024-01-12	Автомобильная	21	10440.00	43.75
43	41	42	100.00	2024-01-11	2024-01-13	Рефрижератор	21	11440.00	45.00
44	42	43	60.00	2024-01-12	2024-01-14	Автомобильная	22	9940.00	50.00
45	43	44	90.00	2024-01-13	2024-01-15	Рефрижератор	22	10940.00	44.44
46	44	45	70.00	2024-01-14	2024-01-16	Автомобильная	23	10440.00	50.00
47	45	46	50.00	2024-01-10	2024-01-12	Автомобильная	23	9440.00	50.00
48	46	47	80.00	2024-01-11	2024-01-13	Автомобильная	24	10440.00	43.75
49	47	48	100.00	2024-01-12	2024-01-14	Автомобильная	24	10940.00	40.00
50	48	49	60.00	2024-01-13	2024-01-15	Автомобильная	25	9940.00	50.00
51	49	50	90.00	2024-01-14	2024-01-16	Автомобильная	25	10940.00	44.44
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouses (id, bakery_id, name, size, max_temperature, min_temperature, status, central_warehouse_flag, created_at) FROM stdin;
1	1	Склад муки 1	150.00	20.0	5.0	active	t	2026-10-02 13:37:27.260413+03
2	2	Склад сахара 2	120.50	22.0	10.0	active	f	2026-10-02 13:37:27.260413+03
3	3	Холодный цех 3	80.00	8.0	2.0	active	f	2026-10-02 13:37:27.260413+03
4	4	Склад инвентаря 4	200.00	25.0	15.0	inactive	t	2026-10-02 13:37:27.260413+03
5	5	Склад упаковки 5	100.00	20.0	5.0	active	f	2026-10-02 13:37:27.260413+03
6	6	Основной склад 6	300.00	18.0	0.0	active	t	2026-10-02 13:37:27.260413+03
7	7	Склад специй 7	50.00	20.0	10.0	in_repair	f	2026-10-02 13:37:27.260413+03
8	8	Склад масел 8	75.50	15.0	5.0	active	f	2026-10-02 13:37:27.260413+03
9	9	Склад дрожжей 9	40.00	8.0	2.0	active	t	2026-10-02 13:37:27.260413+03
10	10	Склад фруктов 10	90.00	10.0	0.0	active	f	2026-10-02 13:37:27.260413+03
11	11	Склад ягод 11	60.00	5.0	-5.0	active	f	2026-10-02 13:37:27.260413+03
12	12	Склад орехов 12	55.00	18.0	10.0	inactive	f	2026-10-02 13:37:27.260413+03
13	13	Склад шоколада 13	45.00	18.0	12.0	active	t	2026-10-02 13:37:27.260413+03
14	14	Склад молочки 14	85.00	6.0	2.0	active	f	2026-10-02 13:37:27.260413+03
15	15	Склад мяса 15	70.00	4.0	0.0	in_repair	f	2026-10-02 13:37:27.260413+03
16	16	Склад овощей 16	110.00	12.0	2.0	active	f	2026-10-02 13:37:27.260413+03
17	17	Склад зелени 17	30.00	5.0	0.0	active	f	2026-10-02 13:37:27.260413+03
18	18	Склад заморозки 18	100.00	-18.0	-22.0	active	t	2026-10-02 13:37:27.260413+03
19	19	Склад полуфабр. 19	130.00	-10.0	-15.0	active	f	2026-10-02 13:37:27.260413+03
20	20	Склад тары 20	250.00	25.0	10.0	active	f	2026-10-02 13:37:27.260413+03
21	21	Склад химии 21	40.00	20.0	10.0	inactive	f	2026-10-02 13:37:27.260413+03
22	22	Склад белья 22	60.00	20.0	15.0	active	f	2026-10-02 13:37:27.260413+03
23	23	Склад запчастей 23	80.00	22.0	10.0	active	t	2026-10-02 13:37:27.260413+03
24	24	Склад бумаги 24	90.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
25	25	Склад посуды 25	70.00	20.0	5.0	in_repair	f	2026-10-02 13:37:27.260413+03
26	26	Склад формы 26	100.00	25.0	10.0	active	f	2026-10-02 13:37:27.260413+03
27	27	Склад ножей 27	30.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
28	28	Склад весов 28	20.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
29	29	Склад упаковки 29	150.00	20.0	5.0	active	t	2026-10-02 13:37:27.260413+03
30	30	Склад этикеток 30	40.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
31	31	Склад красителей 31	35.00	18.0	10.0	inactive	f	2026-10-02 13:37:27.260413+03
32	32	Склад ароматиз. 32	25.00	18.0	10.0	active	f	2026-10-02 13:37:27.260413+03
33	33	Склад разрыхл. 33	30.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
34	34	Склад соли 34	50.00	25.0	10.0	active	f	2026-10-02 13:37:27.260413+03
35	35	Склад воды 35	100.00	15.0	5.0	active	t	2026-10-02 13:37:27.260413+03
36	36	Склад соков 36	80.00	10.0	2.0	active	f	2026-10-02 13:37:27.260413+03
37	37	Склад сиропов 37	60.00	15.0	5.0	in_repair	f	2026-10-02 13:37:27.260413+03
38	38	Склад меда 38	40.00	18.0	10.0	active	f	2026-10-02 13:37:27.260413+03
39	39	Склад патоки 39	50.00	15.0	5.0	active	f	2026-10-02 13:37:27.260413+03
40	40	Склад крахмала 40	45.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
41	41	Склад желатина 41	20.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
42	42	Склад агара 42	20.00	20.0	10.0	inactive	f	2026-10-02 13:37:27.260413+03
43	43	Склад пектина 43	25.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
44	44	Склад какао 44	30.00	18.0	10.0	active	f	2026-10-02 13:37:27.260413+03
45	45	Склад чая 45	40.00	20.0	10.0	active	t	2026-10-02 13:37:27.260413+03
46	46	Склад кофе 46	40.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
47	47	Склад подарков 47	80.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
48	48	Склад сувениров 48	60.00	20.0	10.0	active	f	2026-10-02 13:37:27.260413+03
49	49	Склад рекламы 49	50.00	20.0	10.0	in_repair	f	2026-10-02 13:37:27.260413+03
50	50	Главный склад 50	500.00	20.0	0.0	active	t	2026-10-02 13:37:27.260413+03
\.


--
-- Data for Name: work_schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_schedules (id, employee_id, start_date, end_date, break_duration_minutes, tip_day) FROM stdin;
1	1	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
2	2	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
3	3	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
4	4	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
5	5	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
6	6	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
7	7	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
8	8	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
9	9	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
10	10	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
11	11	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
12	12	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
13	13	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
14	14	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
15	15	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
16	16	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
17	17	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
18	18	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
19	19	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
20	20	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
21	21	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
22	22	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
23	23	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
24	24	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
25	25	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
26	26	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
27	27	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
28	28	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
29	29	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
30	30	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
31	31	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
32	32	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
33	33	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
34	34	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
35	35	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
36	36	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
37	37	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
38	38	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
39	39	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
40	40	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
41	41	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
42	42	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
43	43	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
44	44	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
45	45	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
46	46	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
47	47	2024-06-01 09:00:00	2024-06-01 18:00:00	60	disease
48	48	2024-06-01 09:00:00	2024-06-01 18:00:00	60	vacation
49	49	2024-06-01 09:00:00	2024-06-01 18:00:00	60	worker
50	50	2024-06-01 09:00:00	2024-06-01 18:00:00	60	day_off
51	1	2024-06-05 09:00:00	2024-06-05 18:00:00	60	worker
52	2	2024-06-08 09:00:00	2024-06-08 18:00:00	60	worker
53	3	2024-06-10 09:00:00	2024-06-10 18:00:00	60	worker
54	4	2024-06-12 09:00:00	2024-06-12 18:00:00	60	worker
55	5	2024-06-15 09:00:00	2024-06-15 18:00:00	60	worker
56	21	2024-06-03 09:00:00	2024-06-03 18:00:00	60	worker
57	21	2024-06-07 09:00:00	2024-06-07 18:00:00	60	worker
58	42	2024-06-05 09:00:00	2024-06-05 18:00:00	60	worker
59	42	2024-06-10 09:00:00	2024-06-10 18:00:00	60	worker
60	42	2024-06-13 09:00:00	2024-06-13 18:00:00	60	worker
\.


--
-- Data for Name: write_offs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.write_offs (id, quantity, cost_per_unit, reason, date, status, product_id, employee_id, warehouse_id, created_at) FROM stdin;
1	2.00	33.00	Брак производства	2026-10-20 13:44:33.240623	denied	2	2	2	2026-10-22 13:44:33.240623+03
2	3.00	36.00	Повреждение упаковки	2026-10-18 13:44:33.240623	in_progress	3	3	3	2026-10-22 13:44:33.240623+03
3	4.00	39.00	Нарушение температурного режима	2026-10-16 13:44:33.240623	completed	4	4	4	2026-10-22 13:44:33.240623+03
4	5.00	42.00	Ошибка маркировки	2026-10-14 13:44:33.240623	denied	5	5	5	2026-10-22 13:44:33.240623+03
5	6.00	45.00	Истек срок годности	2026-10-12 13:44:33.240623	in_progress	6	6	6	2026-10-22 13:44:33.240623+03
6	7.00	48.00	Брак производства	2026-10-10 13:44:33.240623	completed	7	7	7	2026-10-22 13:44:33.240623+03
7	8.00	51.00	Повреждение упаковки	2026-10-08 13:44:33.240623	denied	8	8	8	2026-10-22 13:44:33.240623+03
8	9.00	54.00	Нарушение температурного режима	2026-10-06 13:44:33.240623	in_progress	9	9	9	2026-10-22 13:44:33.240623+03
9	10.00	57.00	Ошибка маркировки	2026-10-04 13:44:33.240623	completed	10	10	10	2026-10-22 13:44:33.240623+03
10	11.00	60.00	Истек срок годности	2026-10-02 13:44:33.240623	denied	11	11	1	2026-10-22 13:44:33.240623+03
11	12.00	63.00	Брак производства	2026-09-30 13:44:33.240623	in_progress	12	12	2	2026-10-22 13:44:33.240623+03
12	13.00	66.00	Повреждение упаковки	2026-09-28 13:44:33.240623	completed	13	13	3	2026-10-22 13:44:33.240623+03
13	14.00	69.00	Нарушение температурного режима	2026-09-26 13:44:33.240623	denied	14	14	4	2026-10-22 13:44:33.240623+03
14	15.00	72.00	Ошибка маркировки	2026-09-24 13:44:33.240623	in_progress	15	15	5	2026-10-22 13:44:33.240623+03
15	16.00	75.00	Истек срок годности	2026-09-22 13:44:33.240623	completed	16	16	6	2026-10-22 13:44:33.240623+03
16	17.00	78.00	Брак производства	2026-09-20 13:44:33.240623	denied	17	17	7	2026-10-22 13:44:33.240623+03
17	18.00	81.00	Повреждение упаковки	2026-09-18 13:44:33.240623	in_progress	18	18	8	2026-10-22 13:44:33.240623+03
18	19.00	84.00	Нарушение температурного режима	2026-09-16 13:44:33.240623	completed	19	19	9	2026-10-22 13:44:33.240623+03
19	20.00	87.00	Ошибка маркировки	2026-09-14 13:44:33.240623	denied	20	20	10	2026-10-22 13:44:33.240623+03
20	21.00	90.00	Истек срок годности	2026-09-12 13:44:33.240623	in_progress	21	21	1	2026-10-22 13:44:33.240623+03
21	22.00	93.00	Брак производства	2026-09-10 13:44:33.240623	completed	22	22	2	2026-10-22 13:44:33.240623+03
22	23.00	96.00	Повреждение упаковки	2026-09-08 13:44:33.240623	denied	23	23	3	2026-10-22 13:44:33.240623+03
23	24.00	99.00	Нарушение температурного режима	2026-09-06 13:44:33.240623	in_progress	24	24	4	2026-10-22 13:44:33.240623+03
24	25.00	102.00	Ошибка маркировки	2026-09-04 13:44:33.240623	completed	25	25	5	2026-10-22 13:44:33.240623+03
25	26.00	105.00	Истек срок годности	2026-09-02 13:44:33.240623	denied	26	26	6	2026-10-22 13:44:33.240623+03
26	27.00	108.00	Брак производства	2026-08-31 13:44:33.240623	in_progress	27	27	7	2026-10-22 13:44:33.240623+03
27	28.00	111.00	Повреждение упаковки	2026-08-29 13:44:33.240623	completed	28	28	8	2026-10-22 13:44:33.240623+03
28	29.00	114.00	Нарушение температурного режима	2026-08-27 13:44:33.240623	denied	29	29	9	2026-10-22 13:44:33.240623+03
29	30.00	117.00	Ошибка маркировки	2026-08-25 13:44:33.240623	in_progress	30	30	10	2026-10-22 13:44:33.240623+03
30	31.00	120.00	Истек срок годности	2026-08-23 13:44:33.240623	completed	31	31	1	2026-10-22 13:44:33.240623+03
31	32.00	123.00	Брак производства	2026-08-21 13:44:33.240623	denied	32	32	2	2026-10-22 13:44:33.240623+03
32	33.00	126.00	Повреждение упаковки	2026-08-19 13:44:33.240623	in_progress	33	33	3	2026-10-22 13:44:33.240623+03
33	34.00	129.00	Нарушение температурного режима	2026-08-17 13:44:33.240623	completed	34	34	4	2026-10-22 13:44:33.240623+03
34	35.00	132.00	Ошибка маркировки	2026-08-15 13:44:33.240623	denied	35	35	5	2026-10-22 13:44:33.240623+03
35	36.00	135.00	Истек срок годности	2026-08-13 13:44:33.240623	in_progress	36	36	6	2026-10-22 13:44:33.240623+03
36	37.00	138.00	Брак производства	2026-08-11 13:44:33.240623	completed	37	37	7	2026-10-22 13:44:33.240623+03
37	38.00	141.00	Повреждение упаковки	2026-08-09 13:44:33.240623	denied	38	38	8	2026-10-22 13:44:33.240623+03
38	39.00	144.00	Нарушение температурного режима	2026-08-07 13:44:33.240623	in_progress	39	39	9	2026-10-22 13:44:33.240623+03
39	40.00	147.00	Ошибка маркировки	2026-08-05 13:44:33.240623	completed	40	40	10	2026-10-22 13:44:33.240623+03
40	41.00	150.00	Истек срок годности	2026-08-03 13:44:33.240623	denied	41	41	1	2026-10-22 13:44:33.240623+03
41	42.00	153.00	Брак производства	2026-08-01 13:44:33.240623	in_progress	42	42	2	2026-10-22 13:44:33.240623+03
42	43.00	156.00	Повреждение упаковки	2026-07-30 13:44:33.240623	completed	43	43	3	2026-10-22 13:44:33.240623+03
43	44.00	159.00	Нарушение температурного режима	2026-07-28 13:44:33.240623	denied	44	44	4	2026-10-22 13:44:33.240623+03
44	45.00	162.00	Ошибка маркировки	2026-07-26 13:44:33.240623	in_progress	45	45	5	2026-10-22 13:44:33.240623+03
45	46.00	165.00	Истек срок годности	2026-07-24 13:44:33.240623	completed	46	46	6	2026-10-22 13:44:33.240623+03
46	47.00	168.00	Брак производства	2026-07-22 13:44:33.240623	denied	47	47	7	2026-10-22 13:44:33.240623+03
47	48.00	171.00	Повреждение упаковки	2026-07-20 13:44:33.240623	in_progress	48	48	8	2026-10-22 13:44:33.240623+03
48	49.00	174.00	Нарушение температурного режима	2026-07-18 13:44:33.240623	completed	49	49	9	2026-10-22 13:44:33.240623+03
49	50.00	177.00	Ошибка маркировки	2026-07-16 13:44:33.240623	denied	50	50	10	2026-10-22 13:44:33.240623+03
50	1.00	30.00	Истек срок годности	2026-07-14 13:44:33.240623	in_progress	1	1	1	2026-10-22 13:44:33.240623+03
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 56, true);


--
-- Name: bakeries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bakeries_id_seq', 50, true);


--
-- Name: cost_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_products_id_seq', 50, true);


--
-- Name: customer_complaints_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_complaints_id_seq', 50, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 50, true);


--
-- Name: delivery_defects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delivery_defects_id_seq', 50, true);


--
-- Name: discounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.discounts_id_seq', 50, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 50, true);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipment_id_seq', 50, true);


--
-- Name: equipment_maintenance_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipment_maintenance_logs_id_seq', 50, true);


--
-- Name: ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredients_id_seq', 50, true);


--
-- Name: ingredients_price_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredients_price_history_id_seq', 50, true);


--
-- Name: inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_id_seq', 50, true);


--
-- Name: inventory_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_products_id_seq', 47, true);


--
-- Name: loyalty_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.loyalty_cards_id_seq', 51, true);


--
-- Name: medical_books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medical_books_id_seq', 50, true);


--
-- Name: price_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_history_id_seq', 50, true);


--
-- Name: product_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_categories_id_seq', 50, true);


--
-- Name: production_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.production_id_seq', 50, true);


--
-- Name: production_plans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.production_plans_id_seq', 50, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 50, true);


--
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipes_id_seq', 50, true);


--
-- Name: returns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.returns_id_seq', 50, true);


--
-- Name: salary_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.salary_payments_id_seq', 50, true);


--
-- Name: sale_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sale_items_id_seq', 50, true);


--
-- Name: sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_id_seq', 50, true);


--
-- Name: supplier_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_ingredient_id_seq', 50, true);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 50, true);


--
-- Name: vacations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vacations_id_seq', 60, true);


--
-- Name: warehouse_access_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouse_access_id_seq', 50, true);


--
-- Name: warehouse_deliveries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouse_deliveries_id_seq', 51, true);


--
-- Name: warehouses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouses_id_seq', 50, true);


--
-- Name: work_schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.work_schedules_id_seq', 60, true);


--
-- Name: write_offs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.write_offs_id_seq', 50, true);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bakeries bakeries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakeries
    ADD CONSTRAINT bakeries_pkey PRIMARY KEY (id);


--
-- Name: cost_products cost_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_products
    ADD CONSTRAINT cost_products_pkey PRIMARY KEY (id);


--
-- Name: customer_complaints customer_complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_complaints
    ADD CONSTRAINT customer_complaints_pkey PRIMARY KEY (id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_passport_data_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_passport_data_key UNIQUE (passport_data);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers customers_telephone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_telephone_number_key UNIQUE (telephone_number);


--
-- Name: delivery_defects delivery_defects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_defects
    ADD CONSTRAINT delivery_defects_pkey PRIMARY KEY (id);


--
-- Name: discounts discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);


--
-- Name: employees employees_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_email_key UNIQUE (email);


--
-- Name: employees employees_passport_data_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_passport_data_key UNIQUE (passport_data);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: employees employees_telephone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_telephone_number_key UNIQUE (telephone_number);


--
-- Name: equipment_maintenance equipment_maintenance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_maintenance
    ADD CONSTRAINT equipment_maintenance_logs_pkey PRIMARY KEY (id);


--
-- Name: equipment_units equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_units
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: ingredients ingredients_barcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_barcode_key UNIQUE (barcode);


--
-- Name: ingredients ingredients_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_name_key UNIQUE (name);


--
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- Name: ingredient_price_history ingredients_price_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_price_history
    ADD CONSTRAINT ingredients_price_history_pkey PRIMARY KEY (id);


--
-- Name: inventory_ingredients inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_ingredients
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (id);


--
-- Name: inventory_products inventory_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_products
    ADD CONSTRAINT inventory_products_pkey PRIMARY KEY (id);


--
-- Name: loyalty_cards loyalty_cards_card_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_cards
    ADD CONSTRAINT loyalty_cards_card_number_key UNIQUE (card_number);


--
-- Name: loyalty_cards loyalty_cards_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_cards
    ADD CONSTRAINT loyalty_cards_customer_id_key UNIQUE (customer_id);


--
-- Name: loyalty_cards loyalty_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_cards
    ADD CONSTRAINT loyalty_cards_pkey PRIMARY KEY (id);


--
-- Name: medical_books medical_books_medical_record_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_books
    ADD CONSTRAINT medical_books_medical_record_number_key UNIQUE (medical_record_number);


--
-- Name: medical_books medical_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_books
    ADD CONSTRAINT medical_books_pkey PRIMARY KEY (id);


--
-- Name: price_history price_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_history
    ADD CONSTRAINT price_history_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_name_key UNIQUE (name);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: production_batches production_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_batches
    ADD CONSTRAINT production_pkey PRIMARY KEY (id);


--
-- Name: production_plans production_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_plans
    ADD CONSTRAINT production_plans_pkey PRIMARY KEY (id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: returns returns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_pkey PRIMARY KEY (id);


--
-- Name: salary_payments salary_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_payments
    ADD CONSTRAINT salary_payments_pkey PRIMARY KEY (id);


--
-- Name: sale_details sale_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_items_pkey PRIMARY KEY (id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- Name: supplier_ingredients supplier_ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_ingredients
    ADD CONSTRAINT supplier_ingredient_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_email_key UNIQUE (email);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_telephone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_telephone_number_key UNIQUE (telephone_number);


--
-- Name: suppliers suppliers_tin_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_tin_key UNIQUE (tin);


--
-- Name: suppliers suppliers_website_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_website_key UNIQUE (website);


--
-- Name: vacations vacations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vacations
    ADD CONSTRAINT vacations_pkey PRIMARY KEY (id);


--
-- Name: warehouse_access warehouse_access_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_access
    ADD CONSTRAINT warehouse_access_pkey PRIMARY KEY (id);


--
-- Name: warehouse_deliveries warehouse_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_deliveries
    ADD CONSTRAINT warehouse_deliveries_pkey PRIMARY KEY (id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: work_schedules work_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedules
    ADD CONSTRAINT work_schedules_pkey PRIMARY KEY (id);


--
-- Name: write_offs write_offs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.write_offs
    ADD CONSTRAINT write_offs_pkey PRIMARY KEY (id);


--
-- Name: cost_products_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cost_products_product_id ON public.cost_products USING btree (product_id);


--
-- Name: idx_audit_logs_changed_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_changed_by ON public.audit_logs USING btree (changed_by);


--
-- Name: idx_customer_complaints_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customer_complaints_bakery_id ON public.customer_complaints USING btree (bakery_id);


--
-- Name: idx_customer_complaints_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customer_complaints_customer_id ON public.customer_complaints USING btree (customer_id);


--
-- Name: idx_customer_complaints_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customer_complaints_sale_id ON public.customer_complaints USING btree (sale_id);


--
-- Name: idx_employees_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_employees_bakery_id ON public.employees USING btree (bakery_id);


--
-- Name: idx_equipment_maintenance_logs_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_maintenance_logs_bakery_id ON public.equipment_maintenance USING btree (bakery_id);


--
-- Name: idx_equipment_maintenance_logs_equipment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_maintenance_logs_equipment_id ON public.equipment_maintenance USING btree (equipment_id);


--
-- Name: idx_equipment_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_warehouse_id ON public.equipment_units USING btree (warehouse_id);


--
-- Name: idx_inventory_ingredient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inventory_ingredient_id ON public.inventory_ingredients USING btree (ingredient_id);


--
-- Name: idx_inventory_products_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inventory_products_product_id ON public.inventory_products USING btree (product_id);


--
-- Name: idx_inventory_products_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inventory_products_warehouse_id ON public.inventory_products USING btree (warehouse_id);


--
-- Name: idx_inventory_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inventory_warehouse_id ON public.inventory_ingredients USING btree (warehouse_id);


--
-- Name: idx_loyalty_cards_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_loyalty_cards_customer_id ON public.loyalty_cards USING btree (customer_id);


--
-- Name: idx_loyalty_cards_fav_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_loyalty_cards_fav_category_id ON public.loyalty_cards USING btree (favorite_category_id);


--
-- Name: idx_medical_books_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medical_books_employee_id ON public.medical_books USING btree (employee_id);


--
-- Name: idx_price_history_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_price_history_bakery_id ON public.price_history USING btree (bakery_id);


--
-- Name: idx_price_history_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_price_history_product_id ON public.price_history USING btree (bakery_id);


--
-- Name: idx_production_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_bakery_id ON public.production_batches USING btree (bakery_id);


--
-- Name: idx_production_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_employee_id ON public.production_batches USING btree (employee_id);


--
-- Name: idx_production_plans_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_plans_bakery_id ON public.production_plans USING btree (bakery_id);


--
-- Name: idx_production_plans_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_plans_employee_id ON public.production_plans USING btree (employee_id);


--
-- Name: idx_production_plans_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_plans_product_id ON public.production_plans USING btree (product_id);


--
-- Name: idx_production_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_product_id ON public.production_batches USING btree (product_id);


--
-- Name: idx_products_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);


--
-- Name: idx_recipes_ingredient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipes_ingredient_id ON public.recipes USING btree (ingredient_id);


--
-- Name: idx_recipes_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipes_product_id ON public.recipes USING btree (product_id);


--
-- Name: idx_returns_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_returns_customer_id ON public.returns USING btree (customer_id);


--
-- Name: idx_returns_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_returns_employee_id ON public.returns USING btree (employee_id);


--
-- Name: idx_returns_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_returns_product_id ON public.returns USING btree (product_id);


--
-- Name: idx_returns_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_returns_sale_id ON public.returns USING btree (sale_id);


--
-- Name: idx_returns_sale_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_returns_sale_item_id ON public.returns USING btree (sale_item_id);


--
-- Name: idx_salary_payments_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_salary_payments_bakery_id ON public.salary_payments USING btree (bakery_id);


--
-- Name: idx_salary_payments_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_salary_payments_employee_id ON public.salary_payments USING btree (employee_id);


--
-- Name: idx_sale_items_discount_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sale_items_discount_id ON public.sale_details USING btree (discount_id);


--
-- Name: idx_sale_items_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sale_items_product_id ON public.sale_details USING btree (product_id);


--
-- Name: idx_sale_items_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sale_items_sale_id ON public.sale_details USING btree (sale_id);


--
-- Name: idx_sales_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_bakery_id ON public.sales USING btree (bakery_id);


--
-- Name: idx_sales_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_customer_id ON public.sales USING btree (customer_id);


--
-- Name: idx_sales_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_employee_id ON public.sales USING btree (employee_id);


--
-- Name: idx_supplier_ingredient_ingredient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_supplier_ingredient_ingredient_id ON public.supplier_ingredients USING btree (ingredient_id);


--
-- Name: idx_supplier_ingredient_supplier_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_supplier_ingredient_supplier_id ON public.supplier_ingredients USING btree (supplier_id);


--
-- Name: idx_vacations_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vacations_employee_id ON public.vacations USING btree (employee_id);


--
-- Name: idx_warehouse_access_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_access_employee_id ON public.warehouse_access USING btree (employee_id);


--
-- Name: idx_warehouse_access_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_access_warehouse_id ON public.warehouse_access USING btree (warehouse_id);


--
-- Name: idx_warehouse_deliveries_ingredient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_deliveries_ingredient_id ON public.warehouse_deliveries USING btree (ingredient_id);


--
-- Name: idx_warehouse_deliveries_supplier_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_deliveries_supplier_id ON public.warehouse_deliveries USING btree (supplier_id);


--
-- Name: idx_warehouse_deliveries_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_deliveries_warehouse_id ON public.warehouse_deliveries USING btree (warehouse_id);


--
-- Name: idx_warehouses_bakery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouses_bakery_id ON public.warehouses USING btree (bakery_id);


--
-- Name: idx_work_schedules_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_work_schedules_employee_id ON public.work_schedules USING btree (employee_id);


--
-- Name: idx_write_offs_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_write_offs_employee_id ON public.write_offs USING btree (employee_id);


--
-- Name: idx_write_offs_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_write_offs_product_id ON public.write_offs USING btree (product_id);


--
-- Name: idx_write_offs_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_write_offs_warehouse_id ON public.write_offs USING btree (warehouse_id);


--
-- Name: audit_logs audit_logs_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.employees(id);


--
-- Name: audit_logs audit_logs_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: cost_products cost_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_products
    ADD CONSTRAINT cost_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: customer_complaints customer_complaints_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_complaints
    ADD CONSTRAINT customer_complaints_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id);


--
-- Name: customer_complaints customer_complaints_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_complaints
    ADD CONSTRAINT customer_complaints_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customer_complaints customer_complaints_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_complaints
    ADD CONSTRAINT customer_complaints_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- Name: delivery_defects delivery_defects_delivery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_defects
    ADD CONSTRAINT delivery_defects_delivery_id_fkey FOREIGN KEY (delivery_id) REFERENCES public.warehouse_deliveries(id) ON DELETE CASCADE;


--
-- Name: delivery_defects delivery_defects_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_defects
    ADD CONSTRAINT delivery_defects_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: delivery_defects delivery_defects_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_defects
    ADD CONSTRAINT delivery_defects_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: employees employees_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE SET NULL;


--
-- Name: equipment_maintenance equipment_maintenance_logs_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_maintenance
    ADD CONSTRAINT equipment_maintenance_logs_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE RESTRICT;


--
-- Name: equipment_maintenance equipment_maintenance_logs_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_maintenance
    ADD CONSTRAINT equipment_maintenance_logs_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment_units(id) ON DELETE CASCADE;


--
-- Name: equipment_units equipment_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_units
    ADD CONSTRAINT equipment_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE SET NULL;


--
-- Name: ingredient_price_history ingredients_price_history_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_price_history
    ADD CONSTRAINT ingredients_price_history_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: ingredient_price_history ingredients_price_history_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_price_history
    ADD CONSTRAINT ingredients_price_history_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: inventory_ingredients inventory_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_ingredients
    ADD CONSTRAINT inventory_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: inventory_products inventory_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_products
    ADD CONSTRAINT inventory_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: inventory_products inventory_products_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_products
    ADD CONSTRAINT inventory_products_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: inventory_ingredients inventory_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_ingredients
    ADD CONSTRAINT inventory_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: loyalty_cards loyalty_cards_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_cards
    ADD CONSTRAINT loyalty_cards_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: loyalty_cards loyalty_cards_favorite_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loyalty_cards
    ADD CONSTRAINT loyalty_cards_favorite_category_id_fkey FOREIGN KEY (favorite_category_id) REFERENCES public.product_categories(id) ON DELETE SET NULL;


--
-- Name: medical_books medical_books_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_books
    ADD CONSTRAINT medical_books_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: price_history price_history_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_history
    ADD CONSTRAINT price_history_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE SET NULL;


--
-- Name: price_history price_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_history
    ADD CONSTRAINT price_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: production_batches production_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_batches
    ADD CONSTRAINT production_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE RESTRICT;


--
-- Name: production_batches production_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_batches
    ADD CONSTRAINT production_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE RESTRICT;


--
-- Name: production_plans production_plans_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_plans
    ADD CONSTRAINT production_plans_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE CASCADE;


--
-- Name: production_plans production_plans_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_plans
    ADD CONSTRAINT production_plans_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: production_plans production_plans_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_plans
    ADD CONSTRAINT production_plans_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: production_batches production_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_batches
    ADD CONSTRAINT production_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_categories(id) ON DELETE SET NULL;


--
-- Name: recipes recipes_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: recipes recipes_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: returns returns_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: returns returns_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE RESTRICT;


--
-- Name: returns returns_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: returns returns_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE RESTRICT;


--
-- Name: returns returns_sale_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_sale_item_id_fkey FOREIGN KEY (sale_item_id) REFERENCES public.sale_details(id) ON DELETE SET NULL;


--
-- Name: salary_payments salary_payments_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_payments
    ADD CONSTRAINT salary_payments_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE RESTRICT;


--
-- Name: salary_payments salary_payments_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_payments
    ADD CONSTRAINT salary_payments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: sale_details sale_items_discount_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_items_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discounts(id) ON DELETE RESTRICT;


--
-- Name: sale_details sale_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: sale_details sale_items_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_details
    ADD CONSTRAINT sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE CASCADE;


--
-- Name: sales sales_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE RESTRICT;


--
-- Name: sales sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: sales sales_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE RESTRICT;


--
-- Name: supplier_ingredients supplier_ingredient_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_ingredients
    ADD CONSTRAINT supplier_ingredient_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: supplier_ingredients supplier_ingredient_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_ingredients
    ADD CONSTRAINT supplier_ingredient_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: vacations vacations_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vacations
    ADD CONSTRAINT vacations_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: warehouse_access warehouse_access_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_access
    ADD CONSTRAINT warehouse_access_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: warehouse_access warehouse_access_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_access
    ADD CONSTRAINT warehouse_access_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: warehouse_deliveries warehouse_deliveries_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_deliveries
    ADD CONSTRAINT warehouse_deliveries_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE RESTRICT;


--
-- Name: warehouse_deliveries warehouse_deliveries_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_deliveries
    ADD CONSTRAINT warehouse_deliveries_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE RESTRICT;


--
-- Name: warehouse_deliveries warehouse_deliveries_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_deliveries
    ADD CONSTRAINT warehouse_deliveries_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: warehouses warehouses_bakery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_bakery_id_fkey FOREIGN KEY (bakery_id) REFERENCES public.bakeries(id) ON DELETE RESTRICT;


--
-- Name: work_schedules work_schedules_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedules
    ADD CONSTRAINT work_schedules_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: write_offs write_offs_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.write_offs
    ADD CONSTRAINT write_offs_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: write_offs write_offs_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.write_offs
    ADD CONSTRAINT write_offs_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: write_offs write_offs_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.write_offs
    ADD CONSTRAINT write_offs_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict 2w8bkjGYgYMnBzoSfgjn5hKGpHLGCzqp34WO0tnaZefsd7Fu3KSJyAlLqo0M7mY

