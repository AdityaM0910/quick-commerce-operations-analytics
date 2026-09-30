import os
import pandas as pd

from db_connection import get_connection


def load_kpi_data():
    query = """
        SELECT
            metric_date,
            kpi_name,
            actual_value,
            target_value,
            status,
            severity
        FROM vw_kpi_monitoring
        ORDER BY metric_date, kpi_name;
    """

    conn = get_connection()

    try:
        df = pd.read_sql(query, conn)
    finally:
        conn.close()

    return df


def detect_iqr_anomalies(df):
    results = []

    for kpi_name in df["kpi_name"].unique():

        kpi_data = df[df["kpi_name"] == kpi_name].copy()

        q1 = kpi_data["actual_value"].quantile(0.25)
        q3 = kpi_data["actual_value"].quantile(0.75)

        iqr = q3 - q1

        lower_bound = q1 - (1.5 * iqr)
        upper_bound = q3 + (1.5 * iqr)

        kpi_data["q1"] = round(q1, 2)
        kpi_data["q3"] = round(q3, 2)
        kpi_data["lower_bound"] = round(lower_bound, 2)
        kpi_data["upper_bound"] = round(upper_bound, 2)

        kpi_data["anomaly"] = (
            (kpi_data["actual_value"] < lower_bound)
            |
            (kpi_data["actual_value"] > upper_bound)
        )

        results.append(kpi_data)

    return pd.concat(results, ignore_index=True)


def generate_report():

    print("Loading KPI monitoring data...")

    df = load_kpi_data()

    print(f"Loaded {len(df)} KPI records.")

    print("Running anomaly detection...")

    results = detect_iqr_anomalies(df)

    output_dir = "output"
    os.makedirs(output_dir, exist_ok=True)

    output_file = os.path.join(
        output_dir,
        "kpi_monitoring_report.csv"
    )

    results.to_csv(output_file, index=False)

    print(f"\nMonitoring report saved to: {output_file}")

    return results


def main():

    results = generate_report()

    print("\nMonitoring Summary:")

    summary = (
        results
        .groupby("kpi_name")
        .agg(
            total_records=("kpi_name", "count"),
            anomalies=("anomaly", "sum")
        )
    )

    print(summary)

    print("\nStatus Summary:")

    status_summary = (
        results
        .groupby(["kpi_name", "status"])
        .size()
        .unstack(fill_value=0)
    )

    print(status_summary)


if __name__ == "__main__":
    main()