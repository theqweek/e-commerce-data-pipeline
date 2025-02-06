-- avg check per category

with table_1 as (
	select 
		distinct o.check_id,
	 	c.category_name,
		o.order_discount_cost
	from orders o
	inner join order_details od on o.check_id = od.check_id
	inner join products p on p.product_uuid = od.product_uuid
	inner join categories c on c.category_id = p.category_id
)
select
	category_name,
	avg(order_discount_cost) as avg_check
from table_1
group by category_name