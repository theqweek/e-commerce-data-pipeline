-- Среднее время (количество дней) между заказами с разбивкой по категориям

with unique_categories_per_check as (
    select distinct
        o.check_id,
        c.category_name,
        o.customer_id,
        o.order_date
    from orders o
    inner join order_details od on o.check_id = od.check_id
    inner join products p on od.product_uuid = p.product_uuid
    inner join categories c on p.category_id = c.category_id
),
order_deltas as (
    select
        customer_id,
        category_name,
        order_date,
        order_date - lag(order_date) over(partition by customer_id, category_name order by order_date) as delta
    from unique_categories_per_check
)
select
    category_name,
    avg(delta) as avg_delta
from order_deltas
group by category_name