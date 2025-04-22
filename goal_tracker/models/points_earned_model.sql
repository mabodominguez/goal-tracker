{{ config(materialized='view') }}

WITH 
    goals as ( SELECT * FROM 
        {{ ref('clean_goals_raw_model') }}
        )

SELECT 
    new_category,
    due_date,
    SUM(CAST(lift as INTEGER)) as total_points_available,
    SUM( CASE
            WHEN CAST(done AS BOOLEAN) THEN CAST(lift as INTEGER)
            ELSE 0
         END
    ) as points_earned

FROM goals
CROSS JOIN UNNEST(ARRAY['TOTAL', category]) as new_category
GROUP BY new_category, due_date
ORDER BY new_category, due_date