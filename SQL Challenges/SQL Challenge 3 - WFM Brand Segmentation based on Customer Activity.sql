
-- WFM would like to segment the customers in each of their store brands into Low, Medium, and High segmentation. The segments are to be based on a customer's average basket size which is defined as (total sales / count of transactions), per customer.

-- The segment thresholds are as follows:

-- If average basket size is more than $30, then Segment is “High”.

-- If average basket size is between $20 and $30, then Segment is “Medium”.

-- If average basket size is less than $20, then Segment is “Low”.

-- Summarize the number of unique customers, the total number of transactions, total sales, and average basket size, grouped by store brand and segment for 2017.


-- Tables

-- wfm_transactions

-- customer_id:int
-- store_id:int
-- transaction_date:datetime
-- transaction_id:int
-- product_id:int
-- sales:int

-- wfm_stores

-- store_id:int
-- store_brand:varchar
-- location:varchar


SELECT store_brand as brand,
     segment,
     count(distinct customer_id) AS number_customers,
     sum(trans_count) AS total_transactions,
     sum(sal_sum) AS total_sales, 
     (sum(sal_sum)/sum(trans_count)) as avg_basket_size
FROM
(SELECT store_brand, customer_id,
        count(distinct transaction_id) AS trans_count,
        sum(sales) AS sal_sum,
        (sum(sales)/count(transaction_id)) AS avg_basket_size,
        (CASE
          WHEN (sum(sales)/count(transaction_id)) > 30 THEN 'High'
          WHEN (sum(sales)/count(transaction_id)) BETWEEN 20 AND 30 THEN 'Medium'
          ELSE 'Low'
      END) AS segment
 FROM wfm_stores AS st
 LEFT OUTER JOIN wfm_transactions AS tr ON st.store_id = tr.store_id
 WHERE extract(YEAR
               FROM transaction_date) = 2017
 GROUP BY store_brand,
          customer_id) tmp
GROUP BY 1,2