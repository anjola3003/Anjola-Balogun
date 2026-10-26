CREATE TABLE superstore (
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    state VARCHAR(100),
    country VARCHAR(100),
    market VARCHAR(50),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales NUMERIC(12,2),
    quantity INTEGER,
    discount NUMERIC(5,2),
    profit NUMERIC(14,4),
    shipping_cost NUMERIC(12,2),
    order_priority VARCHAR(50),
    year INTEGER
);
ALTER TABLE superstore
ALTER COLUMN order_date TYPE TEXT,
ALTER COLUMN ship_date TYPE TEXT;
ALTER TABLE superstore
    ALTER COLUMN sales TYPE TEXT,
    ALTER COLUMN quantity TYPE TEXT,
    ALTER COLUMN discount TYPE TEXT,
    ALTER COLUMN profit TYPE TEXT,
    ALTER COLUMN shipping_cost TYPE TEXT,
    ALTER COLUMN year TYPE TEXT;
	SELECT COUNT(*) AS total_records
FROM superstore;
SELECT
    SUM(REPLACE(sales, ',', '')::NUMERIC) AS total_sales,
    SUM(REPLACE(profit, ',', '')::NUMERIC) AS total_profit,
    SUM(REPLACE(quantity, ',', '')::NUMERIC) AS total_quantity
FROM superstore;
SELECT
    ROUND(
        (
            SUM(REPLACE(profit, ',', '')::NUMERIC)
            /
            SUM(REPLACE(sales, ',', '')::NUMERIC)
        ) * 100,
        2
    ) AS profit_margin_percent
FROM superstore;
SELECT
    category,
    SUM(REPLACE(sales, ',', '')::NUMERIC) AS total_sales,
    SUM(REPLACE(profit, ',', '')::NUMERIC) AS total_profit,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent
FROM superstore
GROUP BY category
ORDER BY total_profit DESC;
SELECT
    sub_category,
    SUM(REPLACE(sales, ',', '')::NUMERIC) AS total_sales,
    SUM(REPLACE(profit, ',', '')::NUMERIC) AS total_profit
FROM superstore
GROUP BY sub_category
ORDER BY total_profit DESC;
SELECT
    discount,
    COUNT(*) AS order_records,
    SUM(REPLACE(sales, ',', '')::NUMERIC) AS total_sales,
    SUM(REPLACE(profit, ',', '')::NUMERIC) AS total_profit,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent
FROM superstore
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;
SELECT
    category,
    discount,
    COUNT(*) AS order_records,
    SUM(REPLACE(sales, ',', '')::NUMERIC) AS total_sales,
    SUM(REPLACE(profit, ',', '')::NUMERIC) AS total_profit,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent
FROM superstore
GROUP BY category, discount
ORDER BY category, discount;
SELECT
    category,
    discount,
    COUNT(*) AS order_records,
    ROUND(SUM(REPLACE(sales, ',', '')::NUMERIC), 2) AS total_sales,
    ROUND(SUM(REPLACE(profit, ',', '')::NUMERIC), 2) AS total_profit,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent
FROM superstore
GROUP BY category, discount
HAVING SUM(REPLACE(profit, ',', '')::NUMERIC) < 0
ORDER BY total_profit ASC;
SELECT
    category,
    discount,
    COUNT(*) AS order_records,
    ROUND(SUM(REPLACE(sales, ',', '')::NUMERIC), 2) AS total_sales,
    ROUND(SUM(REPLACE(profit, ',', '')::NUMERIC), 2) AS total_profit,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent
FROM superstore
GROUP BY category, discount
HAVING SUM(REPLACE(profit, ',', '')::NUMERIC) < 0
ORDER BY profit_margin_percent ASC
LIMIT 10;
SELECT
    discount,
    COUNT(*) AS record_count
FROM superstore
GROUP BY discount
ORDER BY discount;
SELECT DISTINCT
    discount,
    discount::NUMERIC AS discount_numeric
FROM superstore
WHERE discount::NUMERIC BETWEEN 0.59 AND 0.66
ORDER BY discount_numeric;
SELECT
    category,
    sub_category,
    COUNT(*) AS order_records,
    ROUND(SUM(REPLACE(sales, ',', '')::NUMERIC), 2) AS total_sales,
    ROUND(SUM(REPLACE(profit, ',', '')::NUMERIC), 2) AS total_profit
FROM superstore
WHERE discount::NUMERIC = 0.602
GROUP BY category, sub_category
ORDER BY total_profit ASC;
SELECT
    sub_category,
    ROUND(SUM(REPLACE(sales, ',', '')::NUMERIC), 2) AS total_sales,
    ROUND(SUM(REPLACE(profit, ',', '')::NUMERIC), 2) AS total_profit,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent
FROM superstore
GROUP BY sub_category
ORDER BY profit_margin_percent ASC;

SELECT
    COUNT(*) AS total_records,
    ROUND(SUM(REPLACE(sales, ',', '')::NUMERIC), 2) AS total_sales,
    ROUND(SUM(REPLACE(profit, ',', '')::NUMERIC), 2) AS total_profit,
    SUM(REPLACE(quantity, ',', '')::NUMERIC) AS total_quantity,
    ROUND(
        SUM(REPLACE(profit, ',', '')::NUMERIC)
        / NULLIF(SUM(REPLACE(sales, ',', '')::NUMERIC), 0) * 100,
        2
    ) AS profit_margin_percent,
    COUNT(*) FILTER (
        WHERE REPLACE(profit, ',', '')::NUMERIC = 0
    ) AS zero_profit_records
FROM superstore;