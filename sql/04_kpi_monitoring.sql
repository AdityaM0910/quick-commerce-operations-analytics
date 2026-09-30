-- ============================================================
-- KPI MONITORING LAYER
-- Converts operational metrics into:
-- Actual Value -> Target -> Status -> Severity
-- ============================================================

-- ============================================================
-- 01. DAILY SLA COMPLIANCE MONITORING
-- Target: >= 90%
-- ============================================================

SELECT
    o.order_placed_at::date AS metric_date,

    'SLA Compliance' AS kpi_name,

    ROUND(
    100.0 * COUNT(*) FILTER (WHERE d.is_late = FALSE) / NULLIF(COUNT(*), 0),2) AS actual_value,
     90.00 AS target_value,
    CASE
        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = FALSE
            ) / NULLIF(COUNT(*), 0) >= 90
            THEN 'Green'

        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = FALSE
            ) / NULLIF(COUNT(*), 0) >= 85
            THEN 'Amber'

        ELSE 'Red'
    END AS status,

    CASE
        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = FALSE
            ) / NULLIF(COUNT(*), 0) >= 90
            THEN 'Normal'

        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = FALSE
            ) / NULLIF(COUNT(*), 0) >= 85
            THEN 'Warning'

        ELSE 'Critical'
    END AS severity

FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.order_placed_at::date
ORDER BY metric_date;

-- ============================================================
-- 02. DAILY LATE DELIVERY RATE MONITORING
-- Target: <= 5%
-- ============================================================

SELECT
    o.order_placed_at::date AS metric_date,

    'Late Delivery Rate' AS kpi_name,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE d.is_late = TRUE
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS actual_value,

    5.00 AS target_value,

    CASE
        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = TRUE
            ) / NULLIF(COUNT(*), 0) <= 5
            THEN 'Green'

        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = TRUE
            ) / NULLIF(COUNT(*), 0) <= 7
            THEN 'Amber'

        ELSE 'Red'
    END AS status,

    CASE
        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = TRUE
            ) / NULLIF(COUNT(*), 0) <= 5
            THEN 'Normal'

        WHEN
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = TRUE
            ) / NULLIF(COUNT(*), 0) <= 7
            THEN 'Warning'

        ELSE 'Critical'
    END AS severity

FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.order_placed_at::date

ORDER BY metric_date;

-- ============================================================
-- 03. DAILY AVERAGE END-TO-END DELIVERY TIME MONITORING
-- Target: <= 35 minutes
-- ============================================================

SELECT
    o.order_placed_at::date AS metric_date,

    'Average Delivery Time' AS kpi_name,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (o.delivered_at - o.order_placed_at)
            ) / 60
        ),
        2
    ) AS actual_value,

    35.00 AS target_value,

    CASE
        WHEN
            AVG(
                EXTRACT(
                    EPOCH FROM (o.delivered_at - o.order_placed_at)
                ) / 60
            ) <= 35
            THEN 'Green'

        WHEN
            AVG(
                EXTRACT(
                    EPOCH FROM (o.delivered_at - o.order_placed_at)
                ) / 60
            ) <= 40
            THEN 'Amber'

        ELSE 'Red'
    END AS status,

    CASE
        WHEN
            AVG(
                EXTRACT(
                    EPOCH FROM (o.delivered_at - o.order_placed_at)
                ) / 60
            ) <= 35
            THEN 'Normal'

        WHEN
            AVG(
                EXTRACT(
                    EPOCH FROM (o.delivered_at - o.order_placed_at)
                ) / 60
            ) <= 40
            THEN 'Warning'

        ELSE 'Critical'
    END AS severity

FROM orders o

WHERE o.order_status = 'Delivered'
  AND o.delivered_at IS NOT NULL

GROUP BY o.order_placed_at::date

ORDER BY metric_date;


-- ============================================================
-- 04. UNIFIED KPI MONITORING DATASET
-- Combines all operational KPIs into one result set.
-- ============================================================

SELECT
    metric_date,
    kpi_name,
    actual_value,
    target_value,
    status,
    severity
FROM (

    -- --------------------------------------------------------
    -- KPI 1: SLA Compliance
    -- Target: >= 90%
    -- --------------------------------------------------------

    SELECT
        o.order_placed_at::date AS metric_date,

        'SLA Compliance' AS kpi_name,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = FALSE
            ) / NULLIF(COUNT(*), 0),
            2
        ) AS actual_value,

        90.00 AS target_value,

        CASE
            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = FALSE
                ) / NULLIF(COUNT(*), 0) >= 90
                THEN 'Green'

            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = FALSE
                ) / NULLIF(COUNT(*), 0) >= 85
                THEN 'Amber'

            ELSE 'Red'
        END AS status,

        CASE
            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = FALSE
                ) / NULLIF(COUNT(*), 0) >= 90
                THEN 'Normal'

            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = FALSE
                ) / NULLIF(COUNT(*), 0) >= 85
                THEN 'Warning'

            ELSE 'Critical'
        END AS severity

    FROM deliveries d
    JOIN orders o
        ON d.order_id = o.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY o.order_placed_at::date


    UNION ALL


    -- --------------------------------------------------------
    -- KPI 2: Late Delivery Rate
    -- Target: <= 5%
    -- --------------------------------------------------------

    SELECT
        o.order_placed_at::date AS metric_date,

        'Late Delivery Rate' AS kpi_name,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE d.is_late = TRUE
            ) / NULLIF(COUNT(*), 0),
            2
        ) AS actual_value,

        5.00 AS target_value,

        CASE
            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = TRUE
                ) / NULLIF(COUNT(*), 0) <= 5
                THEN 'Green'

            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = TRUE
                ) / NULLIF(COUNT(*), 0) <= 7
                THEN 'Amber'

            ELSE 'Red'
        END AS status,

        CASE
            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = TRUE
                ) / NULLIF(COUNT(*), 0) <= 5
                THEN 'Normal'

            WHEN
                100.0 * COUNT(*) FILTER (
                    WHERE d.is_late = TRUE
                ) / NULLIF(COUNT(*), 0) <= 7
                THEN 'Warning'

            ELSE 'Critical'
        END AS severity

    FROM deliveries d
    JOIN orders o
        ON d.order_id = o.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY o.order_placed_at::date


    UNION ALL


    -- --------------------------------------------------------
    -- KPI 3: Average Delivery Time
    -- Target: <= 35 minutes
    -- --------------------------------------------------------

    SELECT
        o.order_placed_at::date AS metric_date,

        'Average Delivery Time' AS kpi_name,

        ROUND(
            AVG(
                EXTRACT(
                    EPOCH FROM (o.delivered_at - o.order_placed_at)
                ) / 60
            ),
            2
        ) AS actual_value,

        35.00 AS target_value,

        CASE
            WHEN
                AVG(
                    EXTRACT(
                        EPOCH FROM (o.delivered_at - o.order_placed_at)
                    ) / 60
                ) <= 35
                THEN 'Green'

            WHEN
                AVG(
                    EXTRACT(
                        EPOCH FROM (o.delivered_at - o.order_placed_at)
                    ) / 60
                ) <= 40
                THEN 'Amber'

            ELSE 'Red'
        END AS status,

        CASE
            WHEN
                AVG(
                    EXTRACT(
                        EPOCH FROM (o.delivered_at - o.order_placed_at)
                    ) / 60
                ) <= 35
                THEN 'Normal'

            WHEN
                AVG(
                    EXTRACT(
                        EPOCH FROM (o.delivered_at - o.order_placed_at)
                    ) / 60
                ) <= 40
                THEN 'Warning'

            ELSE 'Critical'
        END AS severity

    FROM orders o

    WHERE o.order_status = 'Delivered'
      AND o.delivered_at IS NOT NULL

    GROUP BY o.order_placed_at::date

) AS kpi_monitoring

ORDER BY
    metric_date,
    kpi_name;