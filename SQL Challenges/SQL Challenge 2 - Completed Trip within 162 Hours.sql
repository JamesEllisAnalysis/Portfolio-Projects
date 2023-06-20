-- SQL Challenge 2

-- An event is logged in the events table with a timestamp each time a new rider attempts a signup (with an event name 'attempted_su') or successfully signs up (with an event name of 'su_success').

-- For each city and date, determine the percentage of signups in the first 7 days of 2022 that completed a trip within 168 hours of the signup date. HINT: driver id column corresponds to rider id column

-- Tables:

-- signup_events

-- rider_id:varchar
-- city_id:varchar
-- event_name:varchar
-- timestamp:datetime

-- trip_details
-- id:varchar
-- client_id:varchar
-- driver_id:varchar
-- city_id:varchar
-- client_rating:float
-- driver_rating:float
-- request_at:datetime
-- predicted_eta:datetime
-- actual_time_of_arrival:datetime
-- status:varchar


WITH signups AS
  (SELECT *,
          DATE(timestamp)
   FROM signup_events
   WHERE event_name LIKE 'su_success'
     AND DATE(timestamp) BETWEEN '2022-01-01' AND '2022-01-07'),
     first_trips_in_168_hours AS
  (SELECT DISTINCT driver_id
   FROM signup_events
   JOIN trip_details ON rider_id = driver_id
   WHERE status LIKE 'completed'
     AND EXTRACT(EPOCH
                 FROM actual_time_of_arrival - timestamp)/3600 <= 168)
SELECT city_id, date, CAST(COUNT(driver_id) AS FLOAT) / COUNT(rider_id) * 100.0 AS percentage
FROM signups
LEFT JOIN first_trips_in_168_hours ON rider_id = driver_id
GROUP BY city_id, date