"""
PT Andalas Manufaktur — Phase 1 Data Quality & Production Dashboard
======================================================================
Run with:
    streamlit run streamlit_app.py

Expects these files in the SAME folder as this script:
    - pt_andalas_db.db          (raw/messy database from Phase 1)
    - clean_tr_produksi.csv     (cleaned production data, from the notebook)
    - clean_tr_maintenance.csv (cleaned maintenance data, from the notebook)
"""

import sqlite3
from pathlib import Path

import pandas as pd
import plotly.express as px
import streamlit as st

st.set_page_config(
    page_title="PT Andalas Manufaktur — Phase 1 Dashboard",
    page_icon="\U0001F3ED",
    layout="wide",
)

DB_PATH = Path("pt_andalas_db.db")
CLEAN_PRODUKSI_PATH = Path("clean_tr_produksi.csv")
CLEAN_MAINT_PATH = Path("clean_tr_maintenance.csv")


# ----------------------------------------------------------------------------
# Data loading
# ----------------------------------------------------------------------------
@st.cache_data
def load_raw_produksi():
    """Raw (uncleaned) tr_produksi, read straight from the SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql("SELECT * FROM tr_produksi", conn)
    conn.close()
    return df


@st.cache_data
def load_clean_produksi():
    df = pd.read_csv(CLEAN_PRODUKSI_PATH, parse_dates=["tanggal"])
    return df


@st.cache_data
def load_clean_maintenance():
    df = pd.read_csv(CLEAN_MAINT_PATH, parse_dates=["tanggal"])
    return df


missing_files = [p.name for p in (DB_PATH, CLEAN_PRODUKSI_PATH, CLEAN_MAINT_PATH) if not p.exists()]
if missing_files:
    st.error(
        "Missing required file(s): "
        + ", ".join(missing_files)
        + ". Place this script in the same folder as the Phase 1 deliverables and rerun."
    )
    st.stop()

raw_produksi = load_raw_produksi()
df = load_clean_produksi()
df_maint = load_clean_maintenance()

# ----------------------------------------------------------------------------
# Header
# ----------------------------------------------------------------------------
st.title("\U0001F3ED PT Andalas Manufaktur — Phase 1 Dashboard")
st.caption("Operation Excellence 2026 — Data Acquisition & Cleaning results")

tab_overview, tab_quality, tab_production, tab_maintenance = st.tabs(
    ["Overview", "Data Quality (Before \u2192 After)", "Production", "Maintenance"]
)

# ----------------------------------------------------------------------------
# TAB 1: Overview
# ----------------------------------------------------------------------------
with tab_overview:
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Production records (cleaned)", f"{len(df):,}")
    c2.metric("Machines", df["id_mesin"].nunique())
    c3.metric("Operators", df["nama_operator"].nunique())
    c4.metric("Maintenance events", f"{len(df_maint):,}")

    st.markdown("##### Average reject rate by shift")
    shift_stats = (
        df.assign(reject_rate=df["reject_qty_ng"] / (df["output_qty_ok"] + df["reject_qty_ng"]))
        .groupby("grup_shift")["reject_rate"]
        .mean()
        .reset_index()
    )
    fig = px.bar(
        shift_stats, x="grup_shift", y="reject_rate",
        labels={"grup_shift": "Shift", "reject_rate": "Avg. reject rate"},
        text_auto=".1%",
    )
    fig.update_yaxes(tickformat=".0%")
    st.plotly_chart(fig, use_container_width=True)
    st.caption(
        "This view answers the original business question: does Shift B really show a "
        "higher reject rate than A and C?"
    )

# ----------------------------------------------------------------------------
# TAB 2: Data Quality Before -> After
# ----------------------------------------------------------------------------
with tab_quality:
    st.markdown("#### What Phase 1 cleaning actually fixed")

    raw_suhu = pd.to_numeric(raw_produksi["suhu_mesin"].replace("", pd.NA), errors="coerce")
    raw_output = pd.to_numeric(raw_produksi["output_qty_ok"].replace("", pd.NA), errors="coerce")

    qc1, qc2, qc3, qc4 = st.columns(4)
    qc1.metric("Raw rows (incl. duplicates)", len(raw_produksi))
    qc2.metric("Duplicate rows removed", int(raw_produksi.duplicated().sum()))
    qc3.metric(
        "Out-of-range temperature readings",
        int(((raw_suhu < 40) | (raw_suhu > 120)).sum()),
        help="Negative values or 999\u00b0C sensor-fault spikes in the raw data",
    )
    qc4.metric("Missing output_qty_ok (raw)", int(raw_output.isna().sum()))

    left, right = st.columns(2)
    with left:
        st.markdown("**Raw `suhu_mesin` distribution (before cleaning)**")
        fig_raw = px.histogram(raw_suhu.dropna(), nbins=40, labels={"value": "Temperature (\u00b0C)"})
        fig_raw.update_layout(showlegend=False)
        st.plotly_chart(fig_raw, use_container_width=True)
        st.caption("Notice the impossible spikes near 0\u00b0C, negative values, and ~999\u00b0C outliers.")
    with right:
        st.markdown("**Cleaned `suhu_mesin` distribution (after cleaning)**")
        fig_clean = px.histogram(df["suhu_mesin"], nbins=40, labels={"value": "Temperature (\u00b0C)"})
        fig_clean.update_layout(showlegend=False)
        st.plotly_chart(fig_clean, use_container_width=True)
        st.caption("Out-of-range readings were imputed using the per-machine median.")

    st.markdown("**Sample of raw anomalous rows (before cleaning)**")
    anomaly_mask = (
        (raw_suhu < 40) | (raw_suhu > 120) | raw_suhu.isna() | raw_output.isna()
    )
    st.dataframe(raw_produksi[anomaly_mask].head(10), use_container_width=True)

# ----------------------------------------------------------------------------
# TAB 3: Production
# ----------------------------------------------------------------------------
with tab_production:
    st.markdown("#### Daily output trend")
    daily = df.groupby("tanggal")[["output_qty_ok", "reject_qty_ng"]].sum().reset_index()
    fig_trend = px.line(
        daily, x="tanggal", y=["output_qty_ok", "reject_qty_ng"],
        labels={"value": "Quantity", "tanggal": "Date", "variable": "Metric"},
    )
    st.plotly_chart(fig_trend, use_container_width=True)

    st.markdown("#### Reject rate by machine")
    machine_stats = (
        df.assign(reject_rate=df["reject_qty_ng"] / (df["output_qty_ok"] + df["reject_qty_ng"]))
        .groupby("nama_mesin")["reject_rate"]
        .mean()
        .sort_values(ascending=False)
        .reset_index()
    )
    fig_machine = px.bar(
        machine_stats, x="nama_mesin", y="reject_rate",
        labels={"nama_mesin": "Machine", "reject_rate": "Avg. reject rate"},
        text_auto=".1%",
    )
    fig_machine.update_yaxes(tickformat=".0%")
    st.plotly_chart(fig_machine, use_container_width=True)

    with st.expander("Browse cleaned production data"):
        st.dataframe(df, use_container_width=True)

# ----------------------------------------------------------------------------
# TAB 4: Maintenance
# ----------------------------------------------------------------------------
with tab_maintenance:
    st.markdown("#### Repair cost by damage type")
    cost_by_type = (
        df_maint.groupby("tipe_kerusakan")["biaya_perbaikan"].sum().sort_values(ascending=False).reset_index()
    )
    fig_cost = px.bar(
        cost_by_type, x="tipe_kerusakan", y="biaya_perbaikan",
        labels={"tipe_kerusakan": "Damage type", "biaya_perbaikan": "Total repair cost (Rp)"},
    )
    st.plotly_chart(fig_cost, use_container_width=True)

    st.markdown("#### Downtime duration by machine")
    downtime_by_machine = (
        df_maint.groupby("nama_mesin")["durasi_downtime_menit"].sum().sort_values(ascending=False).reset_index()
    )
    fig_downtime = px.bar(
        downtime_by_machine, x="nama_mesin", y="durasi_downtime_menit",
        labels={"nama_mesin": "Machine", "durasi_downtime_menit": "Total downtime (minutes)"},
    )
    st.plotly_chart(fig_downtime, use_container_width=True)

    with st.expander("Browse cleaned maintenance data"):
        st.dataframe(df_maint, use_container_width=True)

st.divider()
st.caption(
    "Data source: pt_andalas_db.db (raw) and clean_tr_produksi.csv / clean_tr_maintenance.csv "
    "(cleaned, produced by Phase1_Data_Acquisition_and_Cleaning.ipynb)."
)
