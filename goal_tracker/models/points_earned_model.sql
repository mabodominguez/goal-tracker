{{ config(materialized='view') }}

WITH 
    goals as ( SELECT * FROM 
        {{ ref('clean_goals_raw_model') }}
        CROSS JOIN UNNEST(ARRAY['TOTAL', category]) as new_category
        )

SELECT 
    new_category category,
    due_date,
    SUM(lift) as total_points_available,
    SUM( CASE
            WHEN done THEN lift
            ELSE 0
         END
    ) as points_earned
FROM goals

GROUP BY new_category, due_date
ORDER BY category, due_date