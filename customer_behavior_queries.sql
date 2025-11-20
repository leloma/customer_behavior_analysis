
select top 20 * from customer_data 

--Total revenue(Men vs women)
select gender, SUM(purchase_amount) AS revenue from customer_data
group by gender

--Which customers used a discount but still spent more than average purchase amount
select customer_id, purchase_amount, age, age_group from customer_data 
where discount_applied = 'Yes'
and purchase_amount > (select AVG(purchase_amount) from customer_data)

--Top 5 products with the highest average review rating
select top 5 item_purchased, ROUND(AVG(review_rating),2) as Avg_review_rating
from customer_data
group by item_purchased
order by Avg_review_rating DESC

--Compare the average purchase amounts between standard and express shipping
select shipping_type, ROUND(AVG(CAST(purchase_amount AS float)),2) as avg_purchase_amount
from customer_data
where shipping_type in ('Standard', 'Express')
group by shipping_type

--Compare average spend and total revenue between subscribers and non subscribers
select subscription_status, COUNT(customer_id) as total_customers ,round(AVG(CAST(purchase_amount AS float)),2) as avg_purchase_amount, sum(purchase_amount) as revenue
from customer_data
group by subscription_status

--Which 5 products have the highest percentage of purchases with discount applied
select top 5 item_purchased, 100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) as discount_rate
from customer_data
group by item_purchased
order by discount_rate DESC

--Segment customers into new, returning and loyal based on their total number of previous purchases 
-- and show the count of each segment
with customer_type as (
select customer_id, previous_purchases, 
	CASE WHEN previous_purchases = 1 THEN 'New' 
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal' END as customer_segment
from customer_data)

select customer_segment, COUNT(*) as no_of_custs
from customer_type 
GROUP BY customer_segment
order by no_of_custs DESC

 
--What are the top 3 most purchased product within each category
with item_counts as(
select category, item_purchased, COUNT(customer_id) as total_orders, 
ROW_NUMBER() over (partition by category order by COUNT(customer_id) DESC) as item_rank
from customer_data
group by category, item_purchased
)

select item_rank, item_purchased, category, total_orders
from item_counts
where item_rank <= 3

--Are customers who are repeat buyers (customers with more than 5 purchases) also likely to subscribe
select subscription_status,COUNT(customer_id) as repeat_customers, 
100 * COUNT(customer_id)/(select COUNT(customer_id) from customer_data where previous_purchases > 5) as percent_of_repeat_customers
from customer_data
where previous_purchases > 5
group by subscription_status

--What is the revenue contribution of each age group
select age_group, SUM(purchase_amount) as revenue
from customer_data
group by age_group
order by revenue DESC

