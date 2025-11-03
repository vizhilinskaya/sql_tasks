/*Используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей нашего сервиса.
Полученное среднее число заказов всех пользователей округлите до двух знаков после запятой. Колонку с этим значением назовите orders_avg.
Поле в результирующей таблице: orders_avg.*/

SELECT ROUND(avg(orders_count), 2) AS orders_avg
FROM   (SELECT user_id,
               count(order_id) AS orders_count
        FROM   user_actions
        WHERE  action = 'create_order'
        GROUP BY user_id) AS t1;

/*Повторите запрос из предыдущего задания, но теперь вместо подзапроса используйте оператор WITH и табличное выражение.
Условия задачи те же: используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей.
Полученное среднее число заказов округлите до двух знаков после запятой. Колонку с этим значением назовите orders_avg.
Поле в результирующей таблице: orders_avg.*/

WITH subquery AS (SELECT user_id,
                         COUNT(order_id) AS orders_count
                  FROM   user_actions
                  WHERE  action = 'create_order'
                  GROUP BY user_id)
SELECT ROUND(AVG(orders_count), 2) AS orders_avg
FROM subquery;

/*Выведите из таблицы products информацию о всех товарах кроме самого дешёвого.
Результат отсортируйте по убыванию id товара.
Поля в результирующей таблице: product_id, name, price.*/

SELECT product_id,
       name,
       price
FROM products
WHERE price > (SELECT min(price)
                FROM products)
ORDER BY product_id DESC;

/*Выведите информацию о товарах в таблице products, цена на которые превышает среднюю цену всех товаров на 20 рублей и более. Результат отсортируйте по убыванию id товара.
Поля в результирующей таблице: product_id, name, price.*/

SELECT *
FROM products
WHERE price > (SELECT avg(price)
                FROM products) + 20
ORDER BY product_id desc;












