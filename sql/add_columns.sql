-- добавили столбец "status" 
ALTER TABLE staging.user_order_log
ADD COLUMN status VARCHAR(30);

ALTER TABLE mart.f_sales
ADD COLUMN status VARCHAR(30) NOT NULL
DEFAULT 'shipping';