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
WHERE price > (SELECT MIN(price)
                FROM products)
ORDER BY product_id DESC;

/*Выведите информацию о товарах в таблице products, цена на которые превышает среднюю цену всех товаров на 20 рублей и более. Результат отсортируйте по убыванию id товара.
Поля в результирующей таблице: product_id, name, price.*/

SELECT *
FROM products
WHERE price > (SELECT AVG(price)
                FROM products) + 20
ORDER BY product_id DESC;

/*Посчитайте количество уникальных клиентов в таблице user_actions, сделавших за последнюю неделю хотя бы один заказ.
Полученную колонку с числом клиентов назовите users_count. В качестве текущей даты, от которой откладывать неделю, используйте последнюю дату в той же таблице user_actions.
Поле в результирующей таблице: users_count.*/

WITH t1 AS (SELECT MAX(time) - INTERVAL '1 week'
            FROM user_actions)
SELECT COUNT(distinct user_id) AS users_count
FROM user_actions
WHERE action = 'create_order'
  AND time >= (SELECT *
               FROM t1);

/*С помощью функции AGE и агрегирующей функции снова определите возраст самого молодого курьера мужского пола в таблице couriers, но в этот раз при расчётах в качестве первой даты используйте последнюю дату из таблицы courier_actions.
Чтобы получить именно дату, перед применением функции AGE переведите последнюю дату из таблицы courier_actions в формат DATE, как мы делали в этом задании.
Возраст курьера измерьте количеством лет, месяцев и дней и переведите его в тип VARCHAR. Полученную колонку со значением возраста назовите min_age.
Поле в результирующей таблице: min_age*/

WITH t1 AS (SELECT MAX(time)::date
            FROM courier_actions)
SELECT MIN(AGE((SELECT *
                FROM t1), birth_date))::varchar AS min_age
FROM couriers
WHERE sex = 'male';

/*Из таблицы user_actions с помощью подзапроса или табличного выражения отберите все заказы, которые не были отменены пользователями.
Выведите колонку с id этих заказов. Результат запроса отсортируйте по возрастанию id заказа.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поле в результирующей таблице: order_id.*/

SELECT order_id
FROM user_actions
WHERE order_id NOT IN (SELECT order_id
                        FROM user_actions
                        WHERE action = 'cancel_order')
ORDER BY order_id LIMIT 1000;

/*Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и отразите это в столбце orders_count.
В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей, округлив его до двух знаков после запятой.
Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения. Отклонение считайте так: число заказов «минус» округлённое среднее значение. Колонку с отклонением назовите orders_diff.
Результат отсортируйте по возрастанию id пользователя. Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: user_id, orders_count, orders_avg, orders_diff.*/

WITH t1 AS (SELECT user_id,
                   COUNT(order_id) AS orders_count
            FROM   user_actions
            WHERE  action = 'create_order'
            GROUP BY user_id)
SELECT user_id,
       orders_count,
       ROUND((SELECT AVG(orders_count)
       FROM   t1), 2) AS orders_avg, orders_count - ROUND((SELECT AVG(orders_count)
                                                    FROM   t1), 2) AS orders_diff
FROM   t1
ORDER BY user_id limit 1000;

/*Назначьте скидку 15% на товары, цена которых превышает среднюю цену на все товары на 50 и более рублей, а также скидку 10% на товары, цена которых ниже средней на 50 и более рублей. Цену остальных товаров внутри диапазона (среднее - 50; среднее + 50) оставьте без изменений. При расчёте средней цены, округлите её до двух знаков после запятой.
Выведите информацию о всех товарах с указанием старой и новой цены. Колонку с новой ценой назовите new_price.
Результат отсортируйте сначала по убыванию прежней цены в колонке price, затем по возрастанию id товара.
Поля в результирующей таблице: product_id, name, price, new_price

WITH avg_price AS (SELECT round(avg(price), 2) AS average_price
                   FROM products)
SELECT product_id,
       name,
       price,
       CASE WHEN price >= (SELECT *
                    FROM avg_price) + 50 THEN price * (1 - 0.15) WHEN price <= (SELECT *
                                                              FROM avg_price) - 50 THEN price * (1 - 0.1) ELSE price END AS new_price
FROM products
ORDER BY price DESC, product_id;

/*Выясните, есть ли в таблице courier_actions такие заказы, которые были приняты курьерами, но не были созданы пользователями. Посчитайте количество таких заказов.
Колонку с числом заказов назовите orders_count.
Поле в результирующей таблице: orders_count.*/

WITH created_orders AS (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'create_order')
SELECT COUNT(order_id) AS orders_count
FROM courier_actions
WHERE order_id NOT IN (SELECT *
                        FROM   created_orders);






