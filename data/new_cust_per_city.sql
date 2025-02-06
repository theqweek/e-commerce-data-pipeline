-- Количество новичков от месяца к месяцу в разбивке по городам

with rn_table as (
	select
		--o.check_id,
		o.customer_id,
		o.store_uuid,
		--s.city,
		--s."class",
		o.order_date,
		row_number() over(partition by o.customer_id order by o.order_date) as rn
	from orders o
	--inner join stores s on o.store_uuid = s.store_uuid
	--group by o.customer_id, o.store_uuid
)
select
	--customer_id,
	city,
	--"class",
	date_trunc('month', order_date) as month_,
	count(customer_id)
from rn_table rnt
inner join stores s on rnt.store_uuid = s.store_uuid
where rn = 1
group by city, date_trunc('month', order_date)