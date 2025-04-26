{{ config(materialized='view') }}

WITH 
    goal_points as ( 
        SELECT 
        SUM(total_points_available) total_points_available,
        SUM(points_earned) points_earned
        FROM 
        {{ ref('points_earned_model') }}
        WHERE category = 'TOTAL'
    ),
    rewards_purchased as (
        SELECT SUM(CAST(points_spent AS INTEGER)) points_spent FROM 
        {{ source ('mydb', 'rewards_purchased') }}
    )

SELECT 
    *
FROM 
goal_points CROSS JOIN rewards_purchased 
