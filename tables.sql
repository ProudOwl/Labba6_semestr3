DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    email VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE restaurants (
    name VARCHAR(100),
    address TEXT,
    cuisine_type VARCHAR(50),
    phone VARCHAR(20),
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5.00),
    delivery_fee DECIMAL(10,2),
    PRIMARY KEY (name, address)
);

CREATE TABLE menu_items (
    restaurant_name VARCHAR(100),
    restaurant_address TEXT,
    item_name VARCHAR(100),
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    PRIMARY KEY (restaurant_name, restaurant_address, item_name),
    FOREIGN KEY (restaurant_name, restaurant_address) 
        REFERENCES restaurants(name, address) ON DELETE CASCADE
);

CREATE TABLE orders (
    customer_email VARCHAR(100),
    restaurant_name VARCHAR(100),
    restaurant_address TEXT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    delivery_address TEXT,
    PRIMARY KEY (customer_email, order_date),
    FOREIGN KEY (customer_email) REFERENCES customers(email) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_name, restaurant_address) 
        REFERENCES restaurants(name, address) ON DELETE CASCADE
);

CREATE TABLE order_items (
    customer_email VARCHAR(100),
    order_date TIMESTAMP,
    restaurant_name VARCHAR(100),
    restaurant_address TEXT,
    item_name VARCHAR(100),
    quantity INT NOT NULL DEFAULT 1,
    item_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (customer_email, order_date, restaurant_name, restaurant_address, item_name),
    FOREIGN KEY (customer_email, order_date) 
        REFERENCES orders(customer_email, order_date) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_name, restaurant_address, item_name) 
        REFERENCES menu_items(restaurant_name, restaurant_address, item_name) ON DELETE CASCADE
);

INSERT INTO customers (email, name, phone, address) VALUES 
('john@email.com', 'John Smith', '555-0101', '123 Oak Ave'),
('maria@email.com', 'Maria Garcia', '555-0102', '456 Pine St'),
('david@email.com', 'David Wilson', '555-0103', '789 Elm Blvd');

INSERT INTO restaurants (name, address, cuisine_type, phone, rating, delivery_fee) VALUES 
('Bella Italia', '321 Pasta Lane', 'Italian', '555-0201', 4.7, 3.99),
('Sushi Palace', '654 Fish Road', 'Japanese', '555-0202', 4.9, 4.99),
('Burger Heaven', '987 Grill Street', 'American', '555-0203', 4.3, 2.99);

INSERT INTO menu_items (restaurant_name, restaurant_address, item_name, description, price, category) VALUES 
('Bella Italia', '321 Pasta Lane', 'Margherita Pizza', 'Classic tomato and mozzarella', 14.99, 'Main Course'),
('Bella Italia', '321 Pasta Lane', 'Spaghetti Carbonara', 'Pasta with creamy sauce', 16.99, 'Main Course'),
('Sushi Palace', '654 Fish Road', 'Salmon Roll', 'Fresh salmon sushi', 12.99, 'Appetizer'),
('Sushi Palace', '654 Fish Road', 'Dragon Roll', 'Eel and avocado combo', 18.99, 'Main Course'),
('Burger Heaven', '987 Grill Street', 'Classic Cheeseburger', 'Beef patty with cheese', 11.99, 'Main Course'),
('Burger Heaven', '987 Grill Street', 'French Fries', 'Crisky potato fries', 4.99, 'Side');

INSERT INTO orders (customer_email, restaurant_name, restaurant_address, order_date, total_amount, status, delivery_address) VALUES 
('john@email.com', 'Bella Italia', '321 Pasta Lane', '2024-01-15 10:30:00', 31.98, 'delivered', '123 Oak Ave'),
('maria@email.com', 'Sushi Palace', '654 Fish Road', '2024-01-15 11:45:00', 31.98, 'in_transit', '456 Pine St'),
('david@email.com', 'Burger Heaven', '987 Grill Street', '2024-01-15 12:15:00', 16.98, 'pending', '789 Elm Blvd');

INSERT INTO order_items (customer_email, order_date, restaurant_name, restaurant_address, item_name, quantity, item_price) VALUES 
('john@email.com', (SELECT order_date FROM orders WHERE customer_email = 'john@email.com' LIMIT 1), 
 'Bella Italia', '321 Pasta Lane', 'Margherita Pizza', 1, 14.99),
('john@email.com', (SELECT order_date FROM orders WHERE customer_email = 'john@email.com' LIMIT 1),
 'Bella Italia', '321 Pasta Lane', 'Spaghetti Carbonara', 1, 16.99),
('maria@email.com', (SELECT order_date FROM orders WHERE customer_email = 'maria@email.com' LIMIT 1),
 'Sushi Palace', '654 Fish Road', 'Salmon Roll', 2, 12.99),
('david@email.com', (SELECT order_date FROM orders WHERE customer_email = 'david@email.com' LIMIT 1),
 'Burger Heaven', '987 Grill Street', 'Classic Cheeseburger', 1, 11.99),
('david@email.com', (SELECT order_date FROM orders WHERE customer_email = 'david@email.com' LIMIT 1),
 'Burger Heaven', '987 Grill Street', 'French Fries', 1, 4.99);
