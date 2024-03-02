-- Updating column `quantity_sold(after_promo)` for promo_type 'BOGOF' 
UPDATE fact_events
SET `quantity_sold(after_promo)` = 
    CASE 
        WHEN promo_type = 'BOGOF' THEN `quantity_sold(after_promo)` * 2 
        ELSE `quantity_sold(after_promo)`
    END;

-- Adding column named promo_price
ALTER TABLE fact_events
ADD COLUMN promo_price DECIMAL(10,2);

-- Update the 'promo_price' column based on the 'promo_type' values
UPDATE fact_events
SET promo_price = 
    CASE 
        WHEN promo_type = '25% OFF' THEN base_price * (1-0.25)
        WHEN promo_type = '33% OFF' THEN base_price * (1-0.33)
        WHEN promo_type = '50% OFF' THEN base_price * 0.50
        WHEN promo_type = 'BOGOF' THEN base_price * 0.50
        WHEN promo_type = '500 Cashback' THEN base_price - 500
        ELSE base_price
    END;

    
-- Add columns to store before and after revenue
ALTER TABLE fact_events
ADD COLUMN total_revenue_before_promo  DECIMAL(10,2),
ADD COLUMN total_revenue_after_promo  DECIMAL(10,2);

-- Update the new columns with calculated values
UPDATE fact_events
SET total_revenue_before_promo  = base_price * `quantity_sold(before_promo)`,
    total_revenue_after_promo  = promo_price * `quantity_sold(after_promo)`;