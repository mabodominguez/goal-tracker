{{ config(materialized='view') }}

WITH 
    raw_data as ( SELECT * FROM 
        {{ source('mydb', 'goals_raw') }}
    ),
    parents as (
        SELECT
        id,
        goal_name,
        parent_item
        FROM raw_data
        WHERE ARRAY_LENGTH(sub_item, 1) > 0 OR sub_item IS NOT NULL
    ),
    subtasks as (
        SELECT
        id,
        goal_name,
        sub_item
        FROM raw_data
    ),
    map_parents as (
        SELECT
        raw_data.id,
        parents.goal_name as parent_goal,
        parents.id as parent_id
        FROM raw_data
        INNER JOIN parents ON position(parents.goal_name in raw_data.parent_item) > 0
    ),
    map_subtasks as (
        SELECT
        raw_data.id,
        ARRAY_AGG(all_subtasks.id) as subgoal_ids
        FROM raw_data
        JOIN (
            SELECT * FROM subtasks CROSS JOIN UNNEST(sub_item) sub_item_name
        ) all_subtasks
        ON position(raw_data.goal_name in all_subtasks.sub_item_name) > 0
        GROUP BY raw_data.id
    )

SELECT 
    raw_data.id,
    goal_name,
    due_date,
    lift,
    done,
    parent_goal,
    parent_id,
    NULL as subgoal_ids
FROM raw_data
LEFT JOIN map_parents
ON map_parents.id = raw_data.id