-- Conversion

with first_orders as (
	select
		o.customer_id
		, s."class"
		, min(o.order_date) as first_order_date
	from orders o
	inner join stores s on o.store_uuid = s.store_uuid
	group by o.customer_id, s."class"
),
first_orders_plus_60_days as (
	select
		fo.customer_id,
		fo."class",
		count(o.check_id) as cnt_orders
	from orders o
	inner join stores s on o.store_uuid = s.store_uuid
	inner join first_orders fo on o.customer_id = fo.customer_id
		and s."class" = fo."class"
		and o.order_date >= fo.first_order_date
		and o.order_date <= fo.first_order_date + 60
	group by fo.customer_id, fo."class"
)
select 
	"class",
	round(count(distinct case
		when cnt_orders >= 2 then customer_id
	end) / cast(count(distinct customer_id) as decimal) * 100, 2) as conversion_to_second,
	round(count(distinct case
		when cnt_orders >= 3 then customer_id
	end) / cast(count(distinct customer_id) as decimal) * 100, 2) as conversion_to_third,
	round(count(distinct case
		when cnt_orders >= 4 then customer_id
	end) / cast(count(distinct customer_id) as decimal) * 100, 2) as conversion_to_fourth
from first_orders_plus_60_days
group by "class"