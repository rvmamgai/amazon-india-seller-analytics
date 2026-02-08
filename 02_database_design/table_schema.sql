-- Amazon India Seller Analytics
-- Database Schema

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100),
    seller_type VARCHAR(20),
    registration_date DATE,
    seller_city VARCHAR(50),
    seller_state VARCHAR(50),
    seller_zone VARCHAR(10),
    account_status VARCHAR(20),
    gst_registered BOOLEAN,
    gst_number VARCHAR(20)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    seller_id INT,
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    brand VARCHAR(50),
    mrp DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    launch_date DATE,
    fulfillment_type VARCHAR(10),
    product_status VARCHAR(20),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(20),
    signup_date DATE,
    customer_type VARCHAR(20)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(20),
    payment_method VARCHAR(20),
    order_value DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    seller_id INT,
    quantity INT,
    item_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    net_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);
