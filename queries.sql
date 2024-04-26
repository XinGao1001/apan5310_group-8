-- Queries
-- 1. Show store has the maximum overall profit
WITH store_profit AS (
    SELECT store_id, SUM(sale_total) AS total_profit
    FROM (
        SELECT s.store_id, SUM(pl.unit_price * r.quantity) AS sale_total
        FROM sale s
        JOIN receipt r ON s.transaction_id = r.transaction_id
        JOIN product_lookup pl ON r.product_id = pl.product_id
        GROUP BY s.store_id, r.transaction_id
    ) AS store_sales
    GROUP BY store_id
)
SELECT si.store_id, ai.address_city, ai.address_state, sp.total_profit
FROM store_profit sp
JOIN store_info si ON sp.store_id = si.store_id
JOIN address_info ai ON si.address_id = ai.address_id
WHERE sp.total_profit = (SELECT MAX(total_profit) FROM store_profit);


-- 2. Identify which product has the highest sales and restock more related products
SELECT pl.product_id, pl.product_name, SUM(r.quantity) AS total_sales
FROM receipt r
JOIN product_lookup pl ON r.product_id = pl.product_id
GROUP BY pl.product_id, pl.product_name
ORDER BY total_sales DESC
LIMIT 1;

-- 3. Identify in which area we spend the most to reduce potential cost
SELECT ai.address_city, ai.address_state, SUM(oe.rent) AS total_expense
FROM other_expense oe
JOIN store_info si ON oe.store_id = si.store_id
JOIN address_info ai ON si.address_id = ai.address_id
GROUP BY ai.address_city, ai.address_state
ORDER BY total_expense DESC
LIMIT 1;

-- 4. Identify customer segments to make informed marketing campaigns
SELECT 
    CASE 
        WHEN DATE_PART('year', age(current_date, birth_date)) BETWEEN 18 AND 30 THEN '18-30'
        WHEN DATE_PART('year', age(current_date, birth_date)) BETWEEN 31 AND 45 THEN '31-45'
        WHEN DATE_PART('year', age(current_date, birth_date)) BETWEEN 46 AND 60 THEN '46-60'
        ELSE 'Above 60' 
    END AS age_group,
    gender,
    occupation,
    COUNT(*) AS customer_count
FROM customer_info 
GROUP BY age_group, gender, occupation
ORDER BY age_group, gender, occupation;

-- 5. Identify products that are going to expire and add them to the discount table (optimize profit)
INSERT INTO Discount_info (product_id, store_id, discount_rate, start_date, end_date)
SELECT pl.product_id, si.store_id, 0.1, current_date, pl.expire_date
FROM product_lookup pl
JOIN store_inventory si ON pl.product_id = si.product_id
WHERE pl.expire_date <= current_date + INTERVAL '30 days';

-- 6. Which region has the highest sales, explore potential reason (beneficial to store expansion)
WITH region_sales AS (
    SELECT ai.region_name, SUM(pl.unit_price * r.quantity) AS total_sales
    FROM sale s
    JOIN receipt r ON s.transaction_id = r.transaction_id
    JOIN product_lookup pl ON r.product_id = pl.product_id
    JOIN store_info si ON s.store_id = si.store_id
    JOIN address_info ai ON si.address_id = ai.address_id
    GROUP BY ai.region_name
)
SELECT region_name, total_sales
FROM region_sales
WHERE total_sales = (SELECT MAX(total_sales) FROM region_sales);

-- 7. Identify during which period we got the highest passenger flow (by sale time) and accommodate more employees to help with advertising or selling
WITH sales_per_hour AS (
    SELECT 
        DATE_TRUNC('hour', s.date) AS sale_hour,
        COUNT(*) AS sales_count
    FROM sale s
    GROUP BY DATE_TRUNC('hour', s.date)
)
SELECT 
    sale_hour,
    sales_count,
    RANK() OVER (ORDER BY sales_count DESC) AS sales_rank
FROM sales_per_hour
ORDER BY sales_rank;

-- 8. Identify which cashier has made the most transactions or the largest amount of profit to give a certain bonus (to stimulate employees to work harder)
WITH cashier_transactions AS (
    SELECT 
        ec.employee_id,
        ec.first_name || ' ' || ec.last_name AS cashier_name,
        COUNT(*) AS transaction_count,
        SUM(pl.unit_price * r.quantity) AS total_profit
    FROM employee_contact ec
    JOIN sale s ON ec.employee_id = s.employee_id
    JOIN receipt r ON s.transaction_id = r.transaction_id
    JOIN product_lookup pl ON r.product_id = pl.product_id
    GROUP BY ec.employee_id, cashier_name
)
SELECT 
    cashier_name,
    transaction_count,
    total_profit,
    RANK() OVER (ORDER BY transaction_count DESC) AS transaction_rank,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM cashier_transactions
ORDER BY transaction_rank;

-- 9. Calculate the salary of each employee in December 2022
SELECT 
    ec.employee_id,
    ec.first_name || ' ' || ec.last_name AS employee_name,
    SUM(EXTRACT(HOUR FROM ss.end_time - ss.start_time)) AS total_hours_worked,
    SUM(EXTRACT(HOUR FROM ss.end_time - ss.start_time)) * si.hourly_wage AS total_salary
FROM employee_contact ec
JOIN staffing_shift ss ON ec.employee_id = ss.employee_id
JOIN salary_info si ON ec.employee_id = si.employee_id
WHERE EXTRACT(YEAR FROM ss.start_time) = 2022
    AND EXTRACT(MONTH FROM ss.start_time) = 12
GROUP BY ec.employee_id, employee_name, si.hourly_wage;

-- 10. Identify the 10 sellers with the lowest volumes and give warmings
WITH seller_transactions AS (
    SELECT 
        ec.employee_id,
        ec.first_name || ' ' || ec.last_name AS seller_name,
        COUNT(*) AS transaction_count
    FROM employee_contact ec
    JOIN sale s ON ec.employee_id = s.employee_id
    GROUP BY ec.employee_id, seller_name
)
SELECT 
    seller_name,
    transaction_count
FROM seller_transactions
ORDER BY transaction_count
LIMIT 10;
