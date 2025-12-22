
--Информация о клиентах
CREATE TABLE customers (
    id SERIAL PRIMARY KEY, --идентификатор клиента
    name VARCHAR(100) NOT NULL, --имя клиента
    email VARCHAR(100) UNIQUE, --эл. почта
    phone VARCHAR(20), --тел. номер
    address TEXT, --адрес доставки
    registration_date DATE DEFAULT CURRENT_DATE --дата регистрации
);

--Информация о ресторанах
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY, --идентификатор ресторана
    name VARCHAR(100) NOT NULL, --название ресторана
    cuisine_type VARCHAR(50), --тип кухни
    address TEXT, --адрес ресторана
    phone VARCHAR(20), --тел. ресторана
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5.00), --рейтинг ресторана
    delivery_fee DECIMAL(10,2) --стоимость доставки
);

--Информация о меню
CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY, --идентификатор блюда
    name VARCHAR(100) NOT NULL, --название блюда
    description TEXT, --описание блюда
    price DECIMAL(10,2) NOT NULL, --цена блюда
    category VARCHAR(50), --категория
    restaurant_id INT REFERENCES restaurants(id) ON DELETE CASCADE --ресторан
);

--Заказы клиентов
CREATE TABLE orders (
    id SERIAL PRIMARY KEY, --идентификатор заказа
    customer_id INT REFERENCES customers(id) ON DELETE CASCADE, --клиент
    restaurant_id INT REFERENCES restaurants(id) ON DELETE CASCADE, --ресторан
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, --датаи время заказа
    total_amount DECIMAL(10,2) NOT NULL, --общая сумма заказа
    status VARCHAR(20) DEFAULT 'pending', --статус заказа
    delivery_address TEXT --адрес доставки
);

--Информация о заказах
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY, --идентификатор заказа
    order_id INT REFERENCES orders(id) ON DELETE CASCADE, --заказ
    menu_item_id INT REFERENCES menu_items(id) ON DELETE CASCADE, --блюдо из меню
    quantity INT NOT NULL DEFAULT 1, --единиц блюда
    item_price DECIMAL(10,2) NOT NULL --цена блюда на момент заказа
);

INSERT INTO customers (name, email, phone, address) VALUES 
('John Smith', 'john@email.com', '555-0101', '123 Oak Ave'),
('Maria Garcia', 'maria@email.com', '555-0102', '456 Pine St'),
('David Wilson', 'david@email.com', '555-0103', '789 Elm Blvd');

INSERT INTO restaurants (name, cuisine_type, address, phone, rating, delivery_fee) VALUES 
('Bella Italia', 'Italian', '321 Pasta Lane', '555-0201', 4.7, 3.99),
('Sushi Palace', 'Japanese', '654 Fish Road', '555-0202', 4.9, 4.99),
('Burger Heaven', 'American', '987 Grill Street', '555-0203', 4.3, 2.99);

INSERT INTO menu_items (name, description, price, category, restaurant_id) VALUES 
('Margherita Pizza', 'Classic tomato and mozzarella', 14.99, 'Main Course', 1),
('Spaghetti Carbonara', 'Pasta with creamy sauce', 16.99, 'Main Course', 1),
('Salmon Roll', 'Fresh salmon sushi', 12.99, 'Appetizer', 2),
('Dragon Roll', 'Eel and avocado combo', 18.99, 'Main Course', 2),
('Classic Cheeseburger', 'Beef patty with cheese', 11.99, 'Main Course', 3),
('French Fries', 'Crispy potato fries', 4.99, 'Side', 3);

INSERT INTO orders (customer_id, restaurant_id, total_amount, status, delivery_address) VALUES 
(1, 1, 31.98, 'delivered', '123 Oak Ave'),
(2, 2, 31.98, 'in_transit', '456 Pine St'),
(3, 3, 16.98, 'pending', '789 Elm Blvd');

INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES 
(1, 1, 1, 14.99),
(1, 2, 1, 16.99),
(2, 3, 2, 12.99),
(3, 5, 1, 11.99),
(3, 6, 1, 4.99);
