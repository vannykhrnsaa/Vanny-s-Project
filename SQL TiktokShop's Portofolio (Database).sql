CREATE TABLE sellers (seller_id INT PRIMARY KEY, sellers_shop VARCHAR(100)UNIQUE,
sellers_name VARCHAR(100), region VARCHAR(50), join_date DATE, is_mall BIT);

CREATE TABLE categories (category_id INT PRIMARY KEY, category_name VARCHAR(100));

CREATE TABLE products (product_id INT PRIMARY KEY, seller_id INT, 
category_id INT, product_name VARCHAR(100), price INT, stock INT,
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
FOREIGN KEY (category_id) REFERENCES categories (category_id));

CREATE TABLE orders(order_id INT PRIMARY KEY, order_date DATETIME, 
order_value INT, order_status VARCHAR(50));

CREATE TABLE order_sales(order_sale_id INT PRIMARY KEY,
order_id INT, product_id INT, quantity INT, price_at_order DECIMAL (18,2),
FOREIGN KEY (product_id) REFERENCES products(product_id),
FOREIGN KEY (order_id) REFERENCES orders(order_id));

CREATE TABLE product_engagement (view_id INT PRIMARY KEY,
product_id INT, view_date DATETIME, impressions INT, clicks INT, 
FOREIGN KEY (product_id) REFERENCES products(product_id));

CREATE TABLE campaigns (campaign_id INT PRIMARY KEY, campaign_name VARCHAR(100),
campaign_type VARCHAR(50), product_id INT, seller_id INT, category_id INT,
start_date DATE, end_date DATE, disc_percentage DECIMAL(4,2), disc_unit INT,
disc_unit_sold INT DEFAULT 0,
FOREIGN KEY (product_id) REFERENCES products(product_id),
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
FOREIGN KEY (category_id) REFERENCES categories(category_id));

BULK INSERT categories
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\categories.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

BULK INSERT sellers
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\sellers.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

BULK INSERT products
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\products.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

BULK INSERT orders
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\orders.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

BULK INSERT order_sales
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\order_sales.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

BULK INSERT product_engagement
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\product_engagement.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

BULK INSERT campaigns
FROM 'C:\Users\vanny\Documents\UI\magang\SQL\campaign.csv'
WITH(FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0d0a', FIRSTROW = 2, 
CODEPAGE = '65001');

SELECT*FROM orders;