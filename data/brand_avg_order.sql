-- В каком по счету заказе в среднем появляется товар определенного бренда

with rnt as (
	select
		distinct o.check_id,
		dense_rank() over(partition by o.customer_id order by o.order_date, o.check_id) as rn_order,
		o.customer_id,
		o.order_date,
		b.brand_name
	from orders o 
	inner join order_details od on o.check_id = od.check_id
	inner join products p on od.product_uuid = p.product_uuid
	inner join brands b on p.brand_id = b.brand_id
)
select
	brand_name,
	avg(rn_order) as avg_
from rnt
group by brand_name