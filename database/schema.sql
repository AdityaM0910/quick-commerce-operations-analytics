-- Cities: master list of cities we operate in
CREATE TABLE cities (
    city_id     SERIAL PRIMARY KEY,
    city_name   VARCHAR(100) NOT NULL,
    state_name  VARCHAR(100) NOT NULL,
    tier        VARCHAR(20)   -- e.g. 'Tier 1', 'Tier 2' — used for regional analysis
);

-- Categories: product categories (Grocery, Snacks, Dairy, etc.)
CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL UNIQUE
);

-- Calendar: a date dimension table — one row per calendar date
-- Why this exists: makes "weekly/monthly growth" SQL much easier
-- (JOIN to this table instead of using EXTRACT() everywhere)
CREATE TABLE calendar (
    calendar_date   DATE PRIMARY KEY,
    day_name        VARCHAR(10),
    week_number     INT,
    month_name      VARCHAR(10),
    month_number    INT,
    quarter         INT,
    year            INT,
    is_weekend      BOOLEAN
);


-- Customers: each customer belongs to a city
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    phone_number    VARCHAR(15) UNIQUE NOT NULL,
    city_id         INT NOT NULL REFERENCES cities(city_id),
    signup_date     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Stores: dark stores, each located in a city
CREATE TABLE stores (
    store_id        SERIAL PRIMARY KEY,
    store_name      VARCHAR(150) NOT NULL,
    city_id         INT NOT NULL REFERENCES cities(city_id),
    store_manager   VARCHAR(150),
    opening_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

-- Products: each product belongs to a category
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(200) NOT NULL,
    category_id     INT NOT NULL REFERENCES categories(category_id),
    price           NUMERIC(10,2) NOT NULL CHECK (price > 0),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

-- Delivery Partners: the riders
CREATE TABLE delivery_partners (
    partner_id      SERIAL PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    phone_number    VARCHAR(15) UNIQUE NOT NULL,
    city_id         INT NOT NULL REFERENCES cities(city_id),
    joining_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

-- Custom type: restricts order_status to exactly these values
CREATE TYPE order_status_enum AS ENUM (
    'Placed',
    'Confirmed',
    'Packed',
    'Partner_Assigned',
    'Out_for_Delivery',
    'Delivered',
    'Cancelled'
);

CREATE TABLE orders (
    order_id                    SERIAL PRIMARY KEY,
    customer_id                 INT NOT NULL REFERENCES customers(customer_id),
    store_id                    INT NOT NULL REFERENCES stores(store_id),
    order_status                order_status_enum NOT NULL DEFAULT 'Placed',

    order_placed_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_confirmed_at          TIMESTAMP,
    order_packed_at             TIMESTAMP,
    partner_assigned_at         TIMESTAMP,
    out_for_delivery_at         TIMESTAMP,
    delivered_at                TIMESTAMP,
    cancelled_at                TIMESTAMP,

    total_amount                NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE inventory (
    inventory_id        SERIAL PRIMARY KEY,
    store_id             INT NOT NULL REFERENCES stores(store_id),
    product_id           INT NOT NULL REFERENCES products(product_id),
    quantity_available    INT NOT NULL DEFAULT 0 CHECK (quantity_available >= 0),
    last_restocked_at    TIMESTAMP,
    UNIQUE (store_id, product_id)   -- one inventory row per store-product pair
);

-- Order Items: bridge table solving orders <-> products many-to-many
CREATE TABLE order_items (
    order_item_id     SERIAL PRIMARY KEY,
    order_id           INT NOT NULL REFERENCES orders(order_id),
    product_id         INT NOT NULL REFERENCES products(product_id),
    quantity           INT NOT NULL CHECK (quantity > 0),
    price_at_order     NUMERIC(10,2) NOT NULL CHECK (price_at_order > 0)
);

-- Deliveries: one row per order's delivery attempt
CREATE TABLE deliveries (
    delivery_id         SERIAL PRIMARY KEY,
    order_id             INT NOT NULL UNIQUE REFERENCES orders(order_id),
    partner_id           INT NOT NULL REFERENCES delivery_partners(partner_id),
    delivery_rating      NUMERIC(2,1) CHECK (delivery_rating BETWEEN 1 AND 5),
    is_late              BOOLEAN DEFAULT FALSE
);

-- Payments: one row per order's payment
CREATE TABLE payments (
    payment_id           SERIAL PRIMARY KEY,
    order_id               INT NOT NULL UNIQUE REFERENCES orders(order_id),
    payment_method        VARCHAR(30) NOT NULL,
    payment_status        VARCHAR(20) NOT NULL DEFAULT 'Success',
    amount_paid            NUMERIC(10,2) NOT NULL CHECK (amount_paid >= 0)
);