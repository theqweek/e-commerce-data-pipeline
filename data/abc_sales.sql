-- abc_sales

with sales_by_products as (
	select
		od.product_uuid,
		sum(od.quantity) as amount
	from orders o
	inner join order_details od on o.check_id = od.check_id
	group by od.product_uuid
),
cumm_sales as (
	select
		product_uuid,
		amount,
		sum(amount) over(order by amount desc) / sum(amount) over() as cumulative_sales
	from sales_by_products
)
select
	p.title,
	case
		when cumulative_sales <= 0.8 then 'A'
		when cumulative_sales <= 0.95 then 'B'
		else 'C'
	end
from cumm_sales cs 
inner join products p on cs.product_uuid = p.product_uuid