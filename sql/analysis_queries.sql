USE credit_card_analysis;

-- ─────────────────────────────────────────
-- Q1: Total Revenue & GMV Overview
-- ─────────────────────────────────────────
SELECT 
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_gmv,
    ROUND(SUM(t.interest_charged), 2) AS total_interest_income,
    ROUND(SUM(t.amount) * 0.015, 2) AS estimated_interchange_fee,
    ROUND(SUM(t.amount) + SUM(t.interest_charged), 2) AS total_revenue
FROM transactions t;

-- ─────────────────────────────────────────
-- Q2: Revenue by Card Tier
-- ─────────────────────────────────────────
SELECT 
    card_tier,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    ROUND(AVG(amount), 2) AS avg_transaction_value,
    ROUND(SUM(interest_charged), 2) AS interest_income
FROM transactions
GROUP BY card_tier
ORDER BY total_spend DESC;

-- ─────────────────────────────────────────
-- Q3: Spend by Category
-- ─────────────────────────────────────────
SELECT 
    category,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (), 2) AS spend_percentage
FROM transactions
GROUP BY category
ORDER BY total_spend DESC;

-- ─────────────────────────────────────────
-- Q4: Channel Mix Analysis
-- ─────────────────────────────────────────
SELECT 
    channel,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    ROUND(COUNT(transaction_id) * 100.0 / SUM(COUNT(transaction_id)) OVER (), 2) AS txn_percentage
FROM transactions
GROUP BY channel
ORDER BY total_transactions DESC;

-- ─────────────────────────────────────────
-- Q5: City Wise Revenue Breakdown
-- ─────────────────────────────────────────
SELECT 
    city,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    ROUND(AVG(amount), 2) AS avg_spend_per_txn,
    ROUND(SUM(interest_charged), 2) AS interest_income
FROM transactions
GROUP BY city
ORDER BY total_spend DESC;


-- ─────────────────────────────────────────
-- Q6: Customer Segmentation by Spend
-- ─────────────────────────────────────────
SELECT 
    customer_id,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    CASE 
        WHEN SUM(amount) >= 500000 THEN 'High Value'
        WHEN SUM(amount) >= 100000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM transactions
GROUP BY customer_id
ORDER BY total_spend DESC;

-- ─────────────────────────────────────────
-- Q7: Monthly Revenue Trend
-- ─────────────────────────────────────────
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    ROUND(SUM(interest_charged), 2) AS interest_income
FROM transactions
GROUP BY month
ORDER BY month ASC;

-- ─────────────────────────────────────────
-- Q8: Top 10 Highest Spending Customers
-- ─────────────────────────────────────────
SELECT 
    t.customer_id,
    c.name,
    c.city,
    c.card_tier,
    c.occupation,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_spend,
    ROUND(SUM(t.interest_charged), 2) AS interest_paid
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.name, c.city, c.card_tier, c.occupation
ORDER BY total_spend DESC
LIMIT 10;

-- ─────────────────────────────────────────
-- Q9: Default Rate by Card Tier
-- ─────────────────────────────────────────
SELECT 
    card_tier,
    COUNT(transaction_id) AS total_transactions,
    SUM(is_defaulted) AS total_defaults,
    ROUND(SUM(is_defaulted) * 100.0 / COUNT(transaction_id), 2) AS default_rate_percentage
FROM transactions
GROUP BY card_tier
ORDER BY default_rate_percentage DESC;

-- ─────────────────────────────────────────
-- Q10: Occupation wise Spend & Revenue
-- ─────────────────────────────────────────
SELECT 
    c.occupation,
    COUNT(DISTINCT t.customer_id) AS total_customers,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_spend,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value,
    ROUND(SUM(t.interest_charged), 2) AS interest_income
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.occupation
ORDER BY total_spend DESC;