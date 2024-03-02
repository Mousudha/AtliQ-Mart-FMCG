--										Business Requests
-- 1. Provide a list of products with a base price greater than 500 and that are featured in promo type of 
--  'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently
--   being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.

SELECT DISTINCT
    dp.product_code,
    dp.product_name,
    dp.category,
    fe.base_price,
    fe.promo_type
FROM 
    fact_events fe
JOIN dim_products dp ON fe.product_code = dp.product_code
WHERE 
    fe.base_price > 500
    AND fe.promo_type = 'BOGOF'
ORDER BY
	dp.product_code;
    
-- 2. Generate a report that provides an overview of the number of stores in each city. The results will be sorted
--  in descending order of store counts, allowing us to identify the cities with the highest store presence. The report
--  includes two essential fields: city and store count, which will assist in optimizing our retail operations.

SELECT 
    s.city,
    COUNT(s.store_id) AS store_count
FROM 
    dim_stores s
GROUP BY 
    s.city
ORDER BY 
    store_count DESC;
    
-- 3. Generate a report that displays each campaign along with the total revenue generated before and after the 
-- campaign? The report includes three key fields: campaign _name, total revenue(before_promotion), 
-- total revenue(after_promotion). This report should help in evaluating the financial impact of our promotional 
-- campaigns. (Display the values in millions)

SELECT 
    dc.campaign_name,
    round(SUM(fe.`quantity_sold(before_promo)` * fe.base_price) / 1000000,2) AS total_revenue_before_promo,
	round(SUM(fe.`quantity_sold(after_promo)` * fe.promo_price) / 1000000,2) AS total_revenue_after_promo
FROM 
    dim_campaigns dc
JOIN fact_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY 
    dc.campaign_name
ORDER BY dc.campaign_name;

-- 4. Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali 
-- campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key
-- fields: category, isu%, and rank order. This information will assist in assessing the category-wise success and 
-- impact of the Diwali campaign on incremental sales.

-- Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in quantity 
-- sold (after promo) compared to quantity sold (before promo)

SELECT 
    dp.category,
    round((SUM(fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`) / SUM(fe.`quantity_sold(before_promo)`) * 100),2) AS ISU_percentage,
    RANK() OVER (ORDER BY (SUM(fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`) / SUM(fe.`quantity_sold(before_promo)`) * 100) DESC) AS ISU_rnk
FROM 
    dim_products dp
JOIN fact_events fe ON dp.product_code = fe.product_code
JOIN dim_campaigns dc ON fe.campaign_id = dc.campaign_id
WHERE 
    dc.campaign_name = 'Diwali'
GROUP BY 
    dp.category
ORDER BY 
    ISU_percentage DESC;

-- 5. Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns.
-- The report will provide essential information including product name, category, and ir%. This analysis helps identify
-- the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

SELECT 
    dp.product_name,
    dp.category,
    round((SUM(fe.total_revenue_after_promo) - SUM(fe.total_revenue_before_promo)) / SUM(fe.total_revenue_before_promo) * 100,2) AS ir_percentage
FROM 
    dim_products dp
JOIN fact_events fe ON dp.product_code = fe.product_code
GROUP BY 
    dp.product_name, dp.category
ORDER BY 
    ir_percentage DESC
LIMIT 5;
