-- LFL по продажам, заказам , выручке

with table_1 as (
	select
	    date_trunc('month', o.order_date) as month_,
	    100 * round(1 - sum(o.count_goods)::numeric / nullif(lag(sum(o.count_goods)) over(order by date_trunc('month', o.order_date)), 0), 3) as goods_growth_rate,
	    100 * round(1 - count(o.check_id)::numeric / nullif(lag(count(o.check_id)) over(order by date_trunc('month', o.order_date)), 0), 3) as orders_growth_rate,
	    100 * round(1 - (sum(o.order_discount_cost) / nullif(lag(sum(o.order_discount_cost)) over(order by date_trunc('month', o.order_date)), 0))::numeric, 3) as discount_growth_rate
	from orders o
	group by date_trunc('month', o.order_date)
	order by date_trunc('month', o.order_date)
)
select
	*
from table_1
where goods_growth_rate is not null