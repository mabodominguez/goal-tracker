{{ config(materialized='table') }}

WITH 
    raw_data as ( SELECT * FROM 
        {{ source('mydb', 'goals_raw') }}
        )

SELECT 
    id,
    goal_name,
    category,
    due_date,
    lift,
    done,
    0 as parent_id,
    NULL as subgoal_ids
FROM raw_data