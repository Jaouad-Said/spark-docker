-- Enhanced database initialization with realistic e-commerce data
-- This runs automatically the first time Postgres starts

CREATE DATABASE demo;
\connect demo;

-- Enable extensions for better data generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════════════════
-- CORE TABLES
-- ═══════════════════════════════════════════════════════════════════════════════

-- Customers table with demographic data
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    customer_uuid UUID DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(20) CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer not to say')),
    registration_date TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    customer_tier VARCHAR(20) DEFAULT 'Bronze' CHECK (customer_tier IN ('Bronze', 'Silver', 'Gold', 'Platinum')),
    total_lifetime_value NUMERIC(12,2) DEFAULT 0.00
);

-- Customer addresses (1-to-many relationship)
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id) ON DELETE CASCADE,
    address_type VARCHAR(20) DEFAULT 'shipping' CHECK (address_type IN ('shipping', 'billing')),
    street_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'United States',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Product categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT REFERENCES categories(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Products with inventory tracking
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
    dimensions_cm VARCHAR(50), -- "L x W x H"
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders with comprehensive tracking
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_uuid UUID DEFAULT uuid_generate_v4(),
    customer_id INT REFERENCES customers(id),
    order_date TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned')),
    shipping_address_id INT REFERENCES addresses(id),
    billing_address_id INT REFERENCES addresses(id),
    subtotal NUMERIC(12,2) NOT NULL,
    tax_amount NUMERIC(12,2) DEFAULT 0.00,
    shipping_cost NUMERIC(8,2) DEFAULT 0.00,
    discount_amount NUMERIC(12,2) DEFAULT 0.00,
    total_amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    notes TEXT,
    shipped_date TIMESTAMPTZ,
    delivered_date TIMESTAMPTZ
);

-- Order line items
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT REFERENCES products(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL,
    discount_percent NUMERIC(5,2) DEFAULT 0.00,
    line_total NUMERIC(12,2) NOT NULL
);

-- Customer reviews and ratings
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    product_id INT REFERENCES products(id),
    order_id INT REFERENCES orders(id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_votes INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory movements for tracking stock changes
CREATE TABLE inventory_movements (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    movement_type VARCHAR(20) CHECK (movement_type IN ('purchase', 'sale', 'adjustment', 'return')),
    quantity_change INT NOT NULL, -- positive for inbound, negative for outbound
    reference_id INT, -- could reference order_id, purchase_order_id, etc.
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- INDEXES FOR PERFORMANCE
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_registration_date ON customers(registration_date);
CREATE INDEX idx_customers_tier ON customers(customer_tier);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_active ON products(is_active);

CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SAMPLE DATA GENERATION
-- ═══════════════════════════════════════════════════════════════════════════════

-- Insert product categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Computers', 'Laptops, desktops, and computer accessories'),
('Smartphones', 'Mobile phones and accessories'),
('Home & Garden', 'Home improvement and gardening supplies'),
('Clothing', 'Apparel and fashion accessories'),
('Books', 'Physical and digital books'),
('Sports & Outdoors', 'Sports equipment and outdoor gear'),
('Health & Beauty', 'Health, wellness, and beauty products'),
('Toys & Games', 'Toys, games, and entertainment'),
('Automotive', 'Car parts and automotive accessories');

-- Add subcategories
INSERT INTO categories (name, description, parent_category_id) VALUES
('Laptops', 'Portable computers', 2),
('Desktop Computers', 'Desktop PCs and workstations', 2),
('Monitors', 'Computer displays and screens', 2),
('Keyboards & Mice', 'Input devices', 2),
('iPhone', 'Apple smartphones', 3),
('Android Phones', 'Android-based smartphones', 3),
('Phone Cases', 'Protective cases for phones', 3);

-- Generate realistic customer data (5,000 customers)
INSERT INTO customers (
    email, first_name, last_name, phone, date_of_birth, gender, 
    registration_date, last_login, customer_tier
)
SELECT 
    'customer' || gs || '@email' || (gs % 10 + 1) || '.com',
    (ARRAY['John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Emily', 'William', 'Ashley', 'James', 'Jessica', 'Christopher', 'Amanda', 'Daniel', 'Stephanie', 'Matthew', 'Michelle', 'Anthony', 'Jennifer'])[1 + (gs % 20)],
    (ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'])[1 + (gs % 20)],
    '+1-555-' || LPAD((gs % 9000 + 1000)::TEXT, 4, '0'),
    DATE '1950-01-01' + (INTERVAL '1 day' * (gs % (365 * 60))), -- Ages 15-75
    (ARRAY['Male', 'Female', 'Other', 'Prefer not to say'])[1 + (gs % 4)],
    TIMESTAMP '2020-01-01' + (INTERVAL '1 day' * (gs % 1800)), -- Registered over ~5 years
    TIMESTAMP '2024-01-01' + (INTERVAL '1 hour' * (gs % 8760)), -- Last login within past year
    (ARRAY['Bronze', 'Silver', 'Gold', 'Platinum'])[1 + (gs % 4)]
FROM generate_series(1, 5000) gs;

-- Generate addresses for customers (most have 1-2 addresses)
INSERT INTO addresses (customer_id, address_type, street_address, city, state_province, postal_code)
SELECT 
    c.id,
    CASE WHEN random() < 0.7 THEN 'shipping' ELSE 'billing' END,
    (gs * 123 + c.id) || ' ' || (ARRAY['Main St', 'Oak Ave', 'First St', 'Second Ave', 'Park Blvd', 'Elm St', 'Maple Dr', 'Cedar Ln'])[1 + ((gs + c.id) % 8)],
    (ARRAY['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte'])[1 + (c.id % 15)],
    (ARRAY['NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA', 'TX', 'FL', 'TX', 'OH', 'NC'])[1 + (c.id % 15)],
    LPAD((10000 + (c.id * 7 + gs) % 90000)::TEXT, 5, '0')
FROM customers c
CROSS JOIN generate_series(1, 2) gs
WHERE random() < (CASE WHEN gs = 1 THEN 1.0 ELSE 0.3 END); -- Most customers have 1 address, some have 2

-- Generate products (2,000 products)
INSERT INTO products (
    sku, name, description, category_id, brand, price, cost, weight_kg, 
    stock_quantity, reorder_level
)
SELECT 
    'SKU-' || LPAD(gs::TEXT, 6, '0'),
    (ARRAY['MacBook Pro', 'Dell XPS', 'iPhone 15', 'Samsung Galaxy', 'iPad Air', 'Surface Pro', 'ThinkPad X1', 'iMac', 'AirPods Pro', 'Magic Mouse', 'Kindle Oasis', 'Echo Dot', 'Fire TV Stick', 'Ring Doorbell', 'Nest Thermostat'])[1 + (gs % 15)] || ' ' || 
    (ARRAY['Standard', 'Pro', 'Max', 'Plus', 'Mini', 'Ultra', 'SE', 'Air'])[1 + (gs % 8)],
    'High-quality product with advanced features and reliable performance.',
    1 + (gs % 10), -- Random category
    (ARRAY['Apple', 'Samsung', 'Dell', 'HP', 'Lenovo', 'Microsoft', 'Google', 'Amazon', 'Sony', 'LG'])[1 + (gs % 10)],
    (50 + (gs % 2000))::NUMERIC(10,2), -- Price between $50-$2050
    (25 + (gs % 1000))::NUMERIC(10,2), -- Cost between $25-$1025
    (0.1 + (gs % 50) * 0.1)::NUMERIC(8,3), -- Weight 0.1-5.0 kg
    gs % 500 + 10, -- Stock 10-510
    (gs % 50) + 5 -- Reorder level 5-55
FROM generate_series(1, 2000) gs;

-- Generate orders (25,000 orders over the past 3 years)
INSERT INTO orders (
    customer_id, order_date, status, subtotal, tax_amount, shipping_cost, 
    discount_amount, total_amount, payment_method, payment_status, 
    shipped_date, delivered_date
)
SELECT 
    1 + (gs % 5000), -- Random customer
    TIMESTAMP '2022-01-01' + (INTERVAL '1 day' * (gs % 1095)), -- Random date in past 3 years
    (ARRAY['delivered', 'delivered', 'delivered', 'delivered', 'shipped', 'processing', 'cancelled'])[1 + (gs % 7)], -- Mostly delivered
    subtotal_calc,
    ROUND(subtotal_calc * 0.08, 2), -- 8% tax
    CASE WHEN subtotal_calc > 50 THEN 0 ELSE 9.99 END, -- Free shipping over $50
    CASE WHEN random() < 0.1 THEN ROUND(subtotal_calc * 0.1, 2) ELSE 0 END, -- 10% discount 10% of time
    subtotal_calc + ROUND(subtotal_calc * 0.08, 2) + 
    CASE WHEN subtotal_calc > 50 THEN 0 ELSE 9.99 END -
    CASE WHEN random() < 0.1 THEN ROUND(subtotal_calc * 0.1, 2) ELSE 0 END,
    (ARRAY['Credit Card', 'PayPal', 'Debit Card', 'Apple Pay', 'Google Pay'])[1 + (gs % 5)],
    CASE WHEN random() < 0.95 THEN 'paid' ELSE 'failed' END,
    TIMESTAMP '2022-01-01' + (INTERVAL '1 day' * (gs % 1095)) + INTERVAL '2 days',
    TIMESTAMP '2022-01-01' + (INTERVAL '1 day' * (gs % 1095)) + INTERVAL '5 days'
FROM (
    SELECT gs, (25 + (gs % 500))::NUMERIC(12,2) as subtotal_calc
    FROM generate_series(1, 25000) gs
) sub;

-- Generate order items (average 2.5 items per order)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
SELECT 
    o.id,
    1 + ((o.id * item_num + 7) % 2000), -- Semi-random product
    1 + (o.id % 3), -- 1-3 quantity
    p.price * (0.9 + random() * 0.2), -- Price with some variation
    (1 + (o.id % 3)) * p.price * (0.9 + random() * 0.2)
FROM orders o
CROSS JOIN generate_series(1, 3) item_num
JOIN products p ON p.id = 1 + ((o.id * item_num + 7) % 2000)
WHERE random() < (CASE WHEN item_num = 1 THEN 1.0 WHEN item_num = 2 THEN 0.8 ELSE 0.4 END);

-- Generate customer reviews (30% of delivered orders get reviewed)
INSERT INTO reviews (customer_id, product_id, order_id, rating, title, comment, is_verified_purchase)
SELECT 
    o.customer_id,
    oi.product_id,
    o.id,
    CASE 
        WHEN random() < 0.6 THEN 5
        WHEN random() < 0.8 THEN 4
        WHEN random() < 0.9 THEN 3
        WHEN random() < 0.95 THEN 2
        ELSE 1
    END,
    (ARRAY['Great product!', 'Excellent quality', 'Good value', 'Fast shipping', 'Highly recommended', 'Perfect!', 'Love it!', 'Amazing!', 'Solid product', 'Works great'])[1 + ((o.id + oi.product_id) % 10)],
    'This product exceeded my expectations. The quality is excellent and delivery was fast. Would definitely recommend to others!',
    TRUE
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
WHERE o.status = 'delivered' 
AND random() < 0.3; -- 30% review rate

-- Update customer lifetime values based on their orders
UPDATE customers SET total_lifetime_value = (
    SELECT COALESCE(SUM(total_amount), 0)
    FROM orders 
    WHERE customer_id = customers.id
    AND payment_status = 'paid'
);

-- Generate some inventory movements
INSERT INTO inventory_movements (product_id, movement_type, quantity_change, notes)
SELECT 
    p.id,
    'purchase',
    100 + (p.id % 200),
    'Initial stock purchase'
FROM products p
WHERE random() < 0.8;

-- ═══════════════════════════════════════════════════════════════════════════════
-- VIEWS FOR COMMON ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Customer summary view
CREATE VIEW customer_summary AS
SELECT 
    c.id,
    c.first_name || ' ' || c.last_name as full_name,
    c.email,
    c.customer_tier,
    c.registration_date,
    c.total_lifetime_value,
    COUNT(o.id) as total_orders,
    MAX(o.order_date) as last_order_date,
    AVG(o.total_amount) as avg_order_value
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.payment_status = 'paid'
GROUP BY c.id, c.first_name, c.last_name, c.email, c.customer_tier, 
         c.registration_date, c.total_lifetime_value;

-- Product performance view
CREATE VIEW product_performance AS
SELECT 
    p.id,
    p.name,
    p.sku,
    c.name as category_name,
    p.price,
    p.stock_quantity,
    COUNT(oi.id) as total_sold,
    SUM(oi.quantity) as units_sold,
    SUM(oi.line_total) as total_revenue,
    AVG(r.rating) as avg_rating,
    COUNT(r.id) as review_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.payment_status = 'paid'
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.sku, c.name, p.price, p.stock_quantity;

-- Monthly sales summary
CREATE VIEW monthly_sales AS
SELECT 
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as total_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_orders
FROM orders
WHERE payment_status = 'paid'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUMMARY STATISTICS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Display database statistics
SELECT 'Database created successfully!' as status;

SELECT 
    'customers' as table_name, 
    COUNT(*) as record_count 
FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders  
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'categories', COUNT(*) FROM categories;

-- Show sample of key business metrics
SELECT 
    'Total Revenue' as metric,
    '$' || TO_CHAR(SUM(total_amount), 'FM999,999,999.00') as value
FROM orders WHERE payment_status = 'paid'
UNION ALL
SELECT 
    'Active Customers',
    COUNT(DISTINCT customer_id)::TEXT
FROM orders WHERE order_date > NOW() - INTERVAL '1 year'
UNION ALL
SELECT 
    'Average Order Value',
    '$' || TO_CHAR(AVG(total_amount), 'FM999.00')
FROM orders WHERE payment_status = 'paid';