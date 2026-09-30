import os
import pandas as pd


def load_monitoring_report():

    file_path = os.path.join(
        "output",
        "kpi_monitoring_report.csv"
    )

    if not os.path.exists(file_path):
        raise FileNotFoundError(
            f"Monitoring report not found: {file_path}"
        )

    return pd.read_csv(file_path)


def generate_alert_report(df):

    alerts = df[
        (df["status"] != "Green") |
        (df["anomaly"] == True)
    ].copy()

    alerts["alert_reason"] = alerts.apply(
        lambda row: (
            "KPI threshold breach + statistical anomaly"
            if row["status"] != "Green" and row["anomaly"]
            else "KPI threshold breach"
            if row["status"] != "Green"
            else "Statistical anomaly"
        ),
        axis=1
    )

    alerts = alerts[
        [
            "metric_date",
            "kpi_name",
            "actual_value",
            "target_value",
            "status",
            "severity",
            "anomaly",
            "alert_reason"
        ]
    ]

    return alerts.sort_values(
        ["metric_date", "kpi_name"]
    )


def main():

    print("Loading monitoring report...")

    df = load_monitoring_report()

    print(f"Loaded {len(df)} KPI records.")

    print("Generating alert report...")

    alerts = generate_alert_report(df)

    output_dir = "output"
    os.makedirs(output_dir, exist_ok=True)

    output_file = os.path.join(
        output_dir,
        "kpi_alert_report.csv"
    )

    alerts.to_csv(output_file, index=False)

    print(f"\nAlert report saved to: {output_file}")
    print(f"Total alerts: {len(alerts)}")

    print("\nAlerts by KPI:")

    print(
        alerts["kpi_name"]
        .value_counts()
    )

    print("\nAlerts by severity:")

    print(
        alerts["severity"]
        .value_counts()
    )


if __name__ == "__main__":
    main()