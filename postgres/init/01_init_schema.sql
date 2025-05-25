CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO categories (name) VALUES
('Electronics'), ('Toys'), ('Books'), ('Home'), ('Clothing');

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_uuid UUID DEFAULT uuid_generate_v4(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT REFERENCES categories(id),
    brand VARCHAR(100),
    price NUMERIC(10,2) NOT NULL,
    cost NUMERIC(10,2),
    weight_kg NUMERIC(8,3),
    dimensions_cm VARCHAR(50),
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);