-- Сегментация новичков и отточных

with intervals as (
	select
		o.customer_id,
		o.order_date,
		date_trunc('month', o.order_date) as month_,
		coalesce(o.order_date - lag(o.order_date) over(partition by o.customer_id order by o.order_date), -1) as delta
	from orders o
	where 1=1
	--and o.order_date between '2022-05-01' and '2022-05-31'
    --and o.customer_id = 69452
)
select
	customer_id,
	month_,
	case
		when min(delta) = -1 and count(order_date) = 1 then 'новичок'
		when min(delta) = -1 and count(order_date) > 1 then 'активный новичок'
		when min(delta) != -1 and count(order_date) = 2 then 'активный'
		when min(delta) != -1 and count(order_date) >= 3 then 'супер-активный'
		when min(delta) != -1 and count(order_date) = 1 and max(delta) < 60 then 'потенциальный отток' 
		when min(delta) != -1 and count(order_date) = 1 and max(delta) >= 60 then 'критический отток'
	end as segment
from intervals
group by customer_id, month_