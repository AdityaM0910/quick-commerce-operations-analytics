import pandas as pd
from db_connection import get_connection


def load_kpi_data():
    """
    Load KPI monitoring data from PostgreSQL.
    """
    conn = get_connection()

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

    df = pd.read_sql(query, conn)

    conn.close()

    return df


def detect_iqr_anomalies(df):
    """
    Detect anomalies using the IQR method.
    """

    results = []

    for kpi in df["kpi_name"].unique():

        kpi_data = df[df["kpi_name"] == kpi].copy()

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


def main():

    print("Loading KPI monitoring data...")

    df = load_kpi_data()

    print(f"Loaded {len(df)} KPI records.")

    print("\nRunning IQR anomaly detection...")

    results = detect_iqr_anomalies(df)

    print("\nAnomaly Detection Summary:")

    print(
        results.groupby("kpi_name")["anomaly"]
        .agg(
            total_records="count",
            anomalies="sum"
        )
    )

    print("\nDetected Anomalies:")

    anomalies = results[results["anomaly"] == True]

    if anomalies.empty:
        print("No anomalies detected.")
    else:
        print(
            anomalies[
                [
                    "metric_date",
                    "kpi_name",
                    "actual_value",
                    "lower_bound",
                    "upper_bound",
                    "status",
                    "severity"
                ]
            ].to_string(index=False)
        )


if __name__ == "__main__":
    main()