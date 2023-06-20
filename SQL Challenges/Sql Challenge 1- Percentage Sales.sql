
-- The sales department has given you the sales figures for the first two months of 2023.


-- You've been tasked with determining the percentage of weekly sales on the first and last day of every week.


-- In your output, include the week number, percentage sales for the first day of the week, and percentage sales for the last day of the week. Both proportions should be rounded to the nearest whole number.

-- Table: early_sales
-- invoiceno:int
-- stockcode:varchar
-- quantity:int
-- invoicedate:datetime
-- unitprice:float



WITH first_week_day AS
  (SELECT DATE(TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI')) AS first_day,
          SUM(quantity * unitprice) AS first_day_sales
   FROM early_sales
   WHERE DATE(TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI')) = DATE(DATE_TRUNC('week', TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI')))
   GROUP BY 1),

     last_week_day AS
  (SELECT DATE(TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI')) AS last_day,
          SUM(quantity * unitprice) AS last_day_sales
   FROM early_sales
   WHERE DATE(TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI')) = DATE(DATE_TRUNC('week', TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI'))) + interval '1 week' - interval '1 day'
   GROUP BY 1),
     full_week AS
  (SELECT EXTRACT(WEEK
                  FROM TO_TIMESTAMP(invoicedate, 'DD/MM/YYYY HH24:MI')) AS week_no,
          SUM(quantity * unitprice) AS week_sales
   FROM early_sales
   GROUP BY 1)
SELECT week_no,
       COALESCE(ROUND(100 * (first_day_sales / week_sales)), 0) AS start_week_pc,
       COALESCE(ROUND(100 * (last_day_sales / week_sales)), 0) AS end_week_pc
FROM first_week_day f
FULL JOIN last_week_day l ON CAST(first_day AS DATE) = CAST(last_day AS DATE) - 6
JOIN full_week fw ON fw.week_no = EXTRACT(WEEK
                                          FROM first_day)
OR fw.week_no = EXTRACT(WEEK
                        FROM last_day)
ORDER BY 1;
