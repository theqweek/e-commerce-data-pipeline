-- Retention Rate

with ranked_orders as (
    select
        o.customer_id,
        date_trunc('month', o.order_date) as month_,
        rank() over (partition by o.customer_id order by date_trunc('month', o.order_date)) as rank_,
        lag(date_trunc('month', o.order_date)) over (partition by customer_id order by date_trunc('month', o.order_date)) as prev_month
    from sales.orders o
    group by date_trunc('month', o.order_date), o.customer_id
),
retention_table as (
	select
    	rank_,
    	min(
        	case
	            when rank_ = 1 then 1  -- Первый месяц всегда 1
	            when prev_month is not null and month_ = prev_month + interval '1 month' then 1  -- Если месяц идет подряд
	            else 0  -- В других случаях (если пропуск был)
        	end
        ) over (partition by customer_id order by month_ rows between unbounded preceding and current row) as final_retained,
        first_value(month_) over(partition by customer_id order by month_) as initial_month
    from ranked_orders
)
select
	initial_month,
    sum(case when rank_ = 1 then final_retained else 0 end) as "0 months",
    sum(case when rank_ = 2 then final_retained else 0 end) as "1 month",
    sum(case when rank_ = 3 then final_retained else 0 end) as "2 months",
    sum(case when rank_ = 4 then final_retained else 0 end) as "3 months"
from retention_table
where final_retained = 1
group by initial_month