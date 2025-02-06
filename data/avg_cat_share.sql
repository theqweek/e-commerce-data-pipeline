-- Средняя доля категорий и брендов в корзине

with table_1 as (
	select 
		o.check_id,
		c.category_name,
		--b.brand_name,
		sum(od.quantity) as category_count,
		sum(sum(od.quantity)) over (partition by o.check_id) as total_count,
		round(sum(od.quantity)::numeric / sum(sum(od.quantity)) over (partition by o.check_id), 2) as category_share
	from orders o
	inner join order_details od on o.check_id = od.check_id
	inner join products p on od.product_uuid = p.product_uuid
	inner join categories c on p.category_id = c.category_id
	inner join brands b on p.brand_id = b.brand_id
	group by o.check_id, c.category_name --b.brand_name
)
select
	category_name,
	--brand_name,
	avg(category_share) as avg_share
from table_1
group by category_name -- brand_name