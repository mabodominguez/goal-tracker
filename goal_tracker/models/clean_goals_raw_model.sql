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
    CAST(lift as INTEGER),
    CAST(done as BOOLEAN),
    parent_item,
    sub_item as sub_items
FROM raw_data