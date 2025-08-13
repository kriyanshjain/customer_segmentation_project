SELECT * FROM customer_segmentation.customers;
use customer_segmentation;
SET SQL_SAFE_UPDATES = 1;
SHOW VARIABLES LIKE 'secure_file_priv';


-- loading different datasets from csv file in customer_segmentation database --
LOAD DATA INFILE 'olist_customers_dataset.csv' INTO TABLE customers
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
select * from customers;

SELECT customer_id, ROW_NUMBER() OVER(ORDER BY customer_id) AS rn FROM customers;

LOAD DATA INFILE 'olist_orders_dataset.csv' INTO TABLE orders
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

select * from orders;

select count(order_id) from orders;
select order_id,order_approved_at, row_number() over(order by order_id ) AS rn from orders;

CREATE TABLE product (
    product_id VARCHAR(50) PRIMARY KEY,  
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2),
    
    INDEX idx_product_category (product_category_name)
);

LOAD DATA INFILE 'olist_products_dataset.csv' INTO TABLE product
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

CREATE TABLE seller_data (
    seller_id VARCHAR(50) PRIMARY KEY,  
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(5),
    
    INDEX idx_seller_location (seller_state, seller_city)
);

ALTER TABLE seller_data MODIFY seller_state VARCHAR(50);


LOAD DATA INFILE 'olist_sellers_dataset.csv' INTO TABLE seller_data
FIELDS TERMINATED BY ','
IGNORE 1 LINES;



CREATE TABLE order_items (
    order_id VARCHAR(50),              -- FK: References orders.order_id
    order_item_id INT,                 -- Sequential item number within order
    product_id VARCHAR(50) NOT NULL,   -- FK: References product.product_id
    seller_id VARCHAR(50) NOT NULL,    -- FK: References seller_data.seller_id
    shipping_limit_date DATETIME,
    price DECIMAL(10,3) NOT NULL,
    freight_value DECIMAL(10,3) NOT NULL,
    
    -- Composite Primary Key
    PRIMARY KEY (order_id, order_item_id),
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES seller_data(seller_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_product_items (product_id),
    INDEX idx_seller_items (seller_id),
    INDEX idx_order_items_price (price)
);

LOAD DATA INFILE 'olist_sellers_dataset.csv' INTO TABLE seller_data
FIELDS TERMINATED BY ','
IGNORE 1 LINES;


CREATE TABLE order_payment (
    -- Composite Primary Key
    order_id VARCHAR(50),              -- FK: References orders.order_id
    payment_sequential INT,            -- Sequential payment number for the order
    payment_type VARCHAR(20) NOT NULL,
    payment_installments INT NOT NULL DEFAULT 1,
    payment_value DECIMAL(10,3) NOT NULL,
    
    -- Composite Primary Key
    PRIMARY KEY (order_id, payment_sequential),
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_payment_type (payment_type),
    INDEX idx_payment_value (payment_value)
);

LOAD DATA INFILE 'olist_order_payments_dataset.csv' INTO TABLE order_payment
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

CREATE TABLE name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,  -- PK
    product_category_name_english VARCHAR(100),
    
    INDEX idx_category_english (product_category_name_english)
);
LOAD DATA INFILE 'product_category_name_translation.csv' INTO TABLE name_translation
FIELDS TERMINATED BY ','
IGNORE 1 LINES;


LOAD DATA INFILE 'olist_order_items_dataset.csv' INTO TABLE order_items
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SET FOREIGN_KEY_CHECKS = 0; 
SET FOREIGN_KEY_CHECKS = 1; 