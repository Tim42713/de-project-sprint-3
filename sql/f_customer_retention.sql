-- добавляем для идемпотентности
DELETE FROM mart.f_customer_retention WHERE period_id = EXTRACT('week' FROM current_date);
DELETE FROM mart.f_customer_retention WHERE period_id = EXTRACT('week' FROM current_date)-1;

-- заполняем таблицу f_customer_retention
INSERT INTO mart.f_customer_retention (new_customers_count, returning_customers_count, refunded_customer_count, period_name, period_id, item_id,
                                      new_customers_revenue, returning_customers_revenue, customers_refunded)
SELECT COUNT(DISTINCT CASE WHEN status = 'new'
			               THEN customer_id
			          END) AS new_customers_count,
	   COUNT(DISTINCT CASE WHEN status <> 'new'
			               THEN customer_id
			          END) AS returning_customers_count,
	   COUNT(DISTINCT CASE WHEN status = 'refunded'
			               THEN customer_id
			          END) AS refunded_customer_count,
	   'weekly' AS period_name,
	   weekly AS period_id,
	   item_id,
	   SUM(CASE WHEN status = 'new'
		        THEN payment_amount
		   END) AS new_customers_revenue,
	   SUM(CASE WHEN status <> 'new'
		        THEN payment_amount
		   END) AS returning_customers_revenue,
	   SUM(CASE WHEN status = 'refunded' 
                THEN quantity 
           END) AS customers_refunded
FROM (
  SELECT DATE_PART('week', date_time) AS weekly,
         customer_id,
	     quantity,
	     payment_amount,
	     CASE WHEN COUNT(customer_id) OVER(PARTITION BY customer_id, date_part('week', date_time)) = 1
	          THEN 'new' ELSE status
	     END AS status,
         item_id
  FROM staging.user_order_log) AS prep
GROUP BY weekly, item_id;