-- добавляем для идемпотентности
DELETE FROM mart.f_sales WHERE EXISTS (SELECT 1 FROM mart.d_calendar WHERE mart.d_calendar.date_id = mart.f_sales.date_id AND mart.d_calendar.date_actual = '{{ds}}');


-- обновили столбец mart.f_sales
INSERT INTO mart.f_sales (date_id, item_id, customer_id, city_id, quantity, payment_amount, status)
SELECT dc.date_id,
       uol.item_id,
       uol.customer_id, 
       uol.city_id, 
       uol.quantity,
       CASE
           WHEN status = 'refunded' THEN payment_amount * -1 
           ELSE payment_amount
       END AS payment_amount,
       status
FROM staging.user_order_log AS uol
LEFT JOIN mart.d_calendar AS dc ON uol.date_time::DATE = dc.date_actual
WHERE uol.date_time::DATE = '{{ds}}';