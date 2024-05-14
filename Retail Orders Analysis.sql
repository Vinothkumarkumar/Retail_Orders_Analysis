	Select * from df_orders;

	1.find top 10 highst revenu genarating product

	select product_id, sum(sale_price) as revenue from df_orders
	group by product_id
	order by revenue desc
	limit 10

	2.find top 5 highst selling product each region
	with ranked_products as(
	select 
		region,
		product_id,
		sum(sale_price) as revenue, 
		row_number() over(partition by region order by sum(sale_price) desc) as rank
		from df_orders
		group by
		region, product_id
	)
	select region,
		product_id,
		revenue,
		RANK
	from
		ranked_products
	where
		rank <=5

	3. Find month over month growth comparsion for 2022 and 203 sales ed : jan 2022 vs jan 2023

	with cte as (
	select 
		extract (year from order_date) as order_year,
		extract (month from order_date) as order_month,
		sum(sale_price) as sales
	from 
		df_orders
	group by 
		order_year , order_month
		)
	select 
		order_month,
		sum (case when order_year = 2022 then sales else 0 end ) as sales_2022,
		sum (case when order_year = 2023 then sales else 0 end ) as sales_2023
	from
		cte
	group by
		order_month
	order by
		order_month

	for each category which month had highest sales 
	WITH cte AS (
		SELECT 
			category,
			TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
			SUM(sale_price) AS sales
		FROM 
			df_orders
		GROUP BY 
			category,
			TO_CHAR(order_date, 'YYYYMM')
	)
	SELECT 
		category,
		order_year_month,
		sales
	FROM (
		SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
		FROM 
			cte
	) a
	WHERE 
		rn = 1;

	--which sub category had highest growth by profit in 2023 compare to 2022

	WITH cte AS (
		SELECT 
			sub_category,
			EXTRACT(YEAR FROM order_date) AS order_year,
			SUM(sale_price) AS sales
		FROM 
			df_orders
		GROUP BY 
			sub_category,
			EXTRACT(YEAR FROM order_date)
	),
	cte2 AS (
		SELECT 
			sub_category,
			SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
			SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
		FROM 
			cte 
		GROUP BY 
			sub_category
	)
	SELECT 
		*,
		(sales_2023 - sales_2022)*100/sales_2022 AS sales_growth
	FROM  
		cte2
	ORDER BY 
		sales_growth DESC
	LIMIT 1;

