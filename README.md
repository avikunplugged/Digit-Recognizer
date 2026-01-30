# Digit-Recognizer
Data Introduction

The data files train.csv and test.csv contain gray-scale images of hand-drawn digits, from zero through nine.

Each image is 28 pixels in height and 28 pixels in width, for a total of 784 pixels in total. Each pixel has a single pixel-value associated with it, indicating the lightness or darkness of that pixel, with higher numbers meaning darker. This pixel-value is an integer between 0 and 255, inclusive.

The training data set, (train.csv), has 785 columns. The first column, called "label", is the digit that was drawn by the user. The rest of the columns contain the pixel-values of the associated image.

Each pixel column in the training set has a name like pixelx, where x is an integer between 0 and 783, inclusive. To locate this pixel on the image, suppose that we have decomposed x as x = i * 28 + j, where i and j are integers between 0 and 27, inclusive. Then pixelx is located on row i and column j of a 28 x 28 matrix, (indexing by zero).

For example, pixel31 indicates the pixel that is in the fourth column from the left, and the second row from the top, as in the ascii-diagram below.

Visually, if we omit the "pixel" prefix, the pixels make up the image like this:

000 001 002 003 ... 026 027
028 029 030 031 ... 054 055
056 057 058 059 ... 082 083
 |   |   |   |  ...  |   |
728 729 730 731 ... 754 755
756 757 758 759 ... 782 783 

The test data set, (test.csv), is the same as the training set, except that it does not contain the "label" column.

Your submission file should be in the following format: For each of the 28000 images in the test set, output a single line containing the ImageId and the digit you predict. For example, if you predict that the first image is of a 3, the second image is of a 7, and the third image is of a 8, then your submission file would look like:

ImageId,Label
1,3




Build a clickable, production‑style **Pricing Intelligence** web app for the **Automobile sector** focused on **Lease Price Prediction** and **payment positioning**. This is a **prototype for live demos** using **real Excel uploads**. The app must include:

# 0) Global Behavior
- **Top navigation with tabs** (left→right):
  1. Solution Overview
  2. Portfolio Overview
  3. Price Distribution (Pricing Manager)
  4. Data Ingestion
  5. Data Cleaning
  6. Feature Engineering
  7. EDA
  8. AIML Modelling (mega‑tab with sub‑tabs)
  9. Backend Code (view‑only)
- **Global filters toolbar** (persist across pages, with local overrides per page):
  - Date Range (Week/Month selector)
  - Business Center (multi‑select)
  - OEM / Make / Nameplate (Model)
  - Trim
  - Model Year
  - Sales Type (Lease, Finance, Retail)
  - Term (e.g., 24/36/48 months)
  - Competitor (multi‑select)
  - Segment (if applicable)
- Each analytic page should support **click‑to‑filter/drill** (selecting chart elements syncs all visuals).
- Light/dark theme toggle, responsive layout, sticky header.
- **Export** buttons on all grids/charts (CSV + PNG).
- Use **Indian Rupee (₹)** by default; allow currency override (₹/$/€) in settings.

# 1) Data Ingestion (Excel)
- Page sections:
  - **Upload Excel** (.xlsx) → multi‑sheet support.
  - **Sheet detection + mapping wizard** (user maps their sheet names to required logical tables).
  - **Schema validation**: show required columns, types, missingness; show sample preview (first 50 rows).
  - **Run Ingestion** button → creates in‑memory dataset and shows record counts and validations.
- **Logical tables & required fields** (enable flexible column mapping):
  - **internal_sales** (Snowflake view analog of `vw_primo_internal_sales`):
    - Date, US_SALES_CAL_WEEK, RANGE_START_DATE, RANGE_END_DATE,
      OEM, MAKE, MODEL, TRIM, MODEL_YEAR, BUSINESS_CENTER,
      INTERNAL_SALES, RETAIL_SALES, LEASE_SALES
  - **comp_sales** (like `vw_primo_comp_sales`):
    - Date, US_SALES_CAL_WEEK, RANGE_START_DATE, RANGE_END_DATE,
      OEM, MAKE, MODEL, TRIM, MODEL_YEAR, BUSINESS_CENTER,
      ADVERTISED_INVENTORY, ADVERTISED_SALES
  - **comp_payments** (like `vw_primo_comp_payments`):
    - Date, US_SALES_CAL_WEEK, MODE (Lease/Finance), TERM,
      MAKE, MODEL, TRIM, MODEL_YEAR, BUSINESS_CENTER,
      VHCL_CNT, MIN_PAYMENT, MAX_PAYMENT
  - **sales_profit_fact** & **vehicle_dim**:
    - MAKE, NAMEPLATE, TRIM, SALES_TYPE, MODEL_YEAR, BUSINESS_CENTER,
      SOLD_DATE, VHCL_MSRP (sum), NET_MARGN_GCR (sum), GROSS_MARGN_GCR (sum), VIN_COUNT
  - **lease_split**:
    - Date, Segment, Brand, Nameplate, Region, Cash%, Finance%, Lease%
  - **macro_calc**:
    - Daily_Date, N_code, Variable_Value  (used for inflation/CPI etc.)
  - **nameplate_mapping**:
    - Make, Model, Nameplate
  - **industry_gold_standard**:
    - Mfg_recode, Make_recode, Model_recode, Segment_recode, Market_basket, Trim
  - **profit_table** (for margin lookups; add if not present):
    - Nameplate, Model_Year, Business_Center, Avg_Margin_per_Unit, Term, Residual_Factor (optional), Money_Factor (optional)
- Show **Data Quality KPIs** post‑ingestion:
  - Rows ingested/table, % missing critical fields, date coverage (min/max), # unique Nameplates, # Business Centers mapped, % competitor matches, CPI freshness days.

# 2) Data Cleaning
- Controls:
  - Missing value strategy (drop/impute median/forward‑fill)
  - Outlier handling (winsorize at 1%/99% toggle)
  - Currency normalization
  - CPI adjustment toggle (enable CPI factor from `macro_calc`)
  - Date frequency harmonization (weekly buckets)
  - Deduplication (VIN/Date)
- Show **before/after summaries**:
  - Missingness by column, outlier counts, ranges, # rows kept/dropped.
- Buttons: **Run Cleaning** → refresh downstream datasets.

# 3) Feature Engineering
- Compute features aligned to Payment Spectrum / ADS approach:
  - Adjusted payment (CPI‑adjusted): `adjusted_Nameplate_AVG_PAYMENT`
  - External weighted average payment (competitor): `external_weighted_avg_payment`
  - Average payment (own & competitor), lagged (t‑1, t‑2, t‑4 weeks)
  - Trend features: `trend_sales` (normalized prior MY sales), seasonal components
  - Ratios: `sales_inventory_ratio`, `sales_payment_ratio`
  - Month difference, model year age buckets (e.g., 0–6, 7–12, 13+ months since launch)
  - Advertised inventory and sales aggregates
  - Lease penetration = Lease_Sales / (Lease + Finance + Retail)
  - Competitor Price Index (CPIx) = Our_Net_Payment / Competitor_Payment
- Show **Feature Store** table with column descriptions and data types.
- KPIs: # features, % rows with full feature set, correlation heatmap, top predictors by variance.

# 4) EDA (Exploratory Data Analysis)
- Visuals (interactive, filterable):
  - Time series: Lease Sales, Average Payment (own vs competitor), Inventory
  - Distribution: Lease Payment histogram/violin by Business Center and Nameplate
  - Scatter: Payment vs Lease Sales (colored by Business Center)
  - Heatmap: Correlations among engineered features
  - Matrix: Nameplate × Business Center → Lease Penetration, CPIx
- KPIs:
  - Total Lease Sales, Avg Lease Payment, Avg Term, Market Share (vs competitor sales),
  - Price dispersion within Business Center (stdev/median), Inventory Days of Supply,
  - CPIx in‑band %, % weeks with competitor data.

# 5) Solution Overview (Story page)
- Narrative cards explaining:
  - Business goal: Optimize lease payment positioning for profit + share.
  - Data: internal sales, competitor sales/payments, profit, macro, mappings.
  - Method: Fixed‑Effects OLS (for lease volume), simulation across price bands,
    trade‑off scoring with weights (Share=0.515, Profit=0.485).
  - Guardrails: margin floors, CPIx bands, step‑change limits, dispersion caps.
- Callouts: **“Jeep Gladiator”** and **“Grand Cherokee”** as demo‑ready examples.
- Big KPIs: Expected Profit Uplift %, Market Share Uplift %, Price Consolidation %, Override Rate (target).

# 6) Portfolio Overview
- Grid + small multiples charts by Nameplate/Model Year/Business Center:
  - KPIs per tile: Lease Sales, Avg Payment, Avg Margin/Unit, Profit, Lease Penetration,
    CPIx, Elasticity label (Low/Med/High), Price dispersion, Predicted Uplift (if optimized).
- Click a tile → deep link to **Price Distribution** and **Scenario Simulation** for that selection.
- Include **map** (if Business Centers are regional) with choropleth by Profit or Share.

# 7) Price Distribution (Pricing Manager)
- Controls: Nameplate, Business Center, Model Year, Term.
- Visuals:
  - Current price distribution (histogram/violin)
  - Recommended band (Min/Target/Max) overlay
  - Competitor band overlay (min/max from comp_payments)
- KPIs:
  - Current vs Recommended Payment, Δ%
  - Profit per Unit (current vs target)
  - Expected Volume change (units/%)
  - Market Share delta
  - CPIx posture (below/within/above band)
- Buttons: **Approve for Pilot**, **Send to Output**, **Download Price File**.

# 8) AIML Modelling (mega‑tab with sub‑tabs)
Provide sub‑tab navigation inside this tab:

## 8.1) Micro Segmentation Module
- Simulate simple K‑means on dealer/customer/BC behavior (no heavy compute):
  - Features: discount tendency, price sensitivity proxy, lease penetration, average order size, promo responsiveness.
  - Slider: **#Segments (K)**; Recompute button.
- Output:
  - Segment cards: (e.g., Price‑Sensitive, Value‑Loyal, Strategic, Opportunistic) with sizes and KPIs.
  - Table: segment membership by Business Center / Nameplate.

## 8.2) Pricing Elasticity Computation
- Show **own‑price elasticity** per Nameplate × Business Center × Model Year using a **log‑log OLS proxy** (or fixed‑effects OLS when multiple nameplates exist).
- Visuals:
  - Elasticity distribution bar/box plot (label Low/Med/High)
  - Sensitivity curves (predicted volume vs price)
- KPIs:
  - Median elasticity, % high‑sensitivity cohorts, # cohorts with stable CI,
  - Buffer price band (±X%) per cohort.

## 8.3) Scenario Simulation – What‑If Analysis
- Controls:
  - Select: Nameplate (default **Jeep Gladiator**), Business Center, Model Year, Term.
  - Price slider: −20% to +20% around current; step = 0.5%.
  - Toggle guardrails: Margin floor, CPIx band, Step‑change cap (e.g., 7%).
  - Objective weight slider **λ** for Trade‑off (Profit vs Market Share).
- Live outputs (update as slider moves):
  - Predicted Volume, Profit, Market Share
  - Trade‑off score = 0.515×Normalized Share + 0.485×Normalized Profit
  - Signal badges: “Margin Safe”, “CPIx Aligned”, “In Dispersion Band”
  - Efficient frontier chart (Profit vs Share; highlight optimal)
- Buttons: **Apply Target Price**, **Add to Output**, **Download Scenario CSV**.

## 8.4) Trade‑off Analysis
- Multi‑point comparison table and scatter of candidate price points with:
  - Price, Volume, Profit, Share, Trade‑off score, CPIx, Margin/Unit, Guardrails triggered.
- KPI: **Optimal Trade‑off Price** and **Expected Uplift** vs current.

## 8.5) Override Analysis
- Capture manual overrides:
  - Input price, Reason code (Competitive Pressure, Strategic Account, One‑time Deal, Inventory Clear, Other notes).
- Show:
  - Override rate %, Avg override magnitude, Bias vs recommendation.
  - Impact: Profit Δ, Share Δ post‑override.
- Downloadable **override log**.

## 8.6) Output Dashboard (Offered Price)
- Final **Offered Price file** by Business Center × Nameplate (e.g., **Jeep Gladiator**):
  - Columns: Date, Business_Center, Nameplate, Model_Year, Term,
    p_min, p_target, p_max, Expected_Units, Expected_Profit, CPIx, Guardrails, Confidence.
- KPIs: Coverage % (eligible cohorts with price), Avg uplift, Total profit impact.
- Buttons: **Export CSV**, **Export JSON**.

# 9) Backend Code (view‑only, collapsible)
- Show **annotated code panes** with syntax highlighting and “Copy” buttons:
  - **SQL (CPIx & aggregation)**:
    - Create weekly aggregates for internal + competitor sales/payments.
    - CPIx = our_net_payment / competitor_payment.
  - **Python – Data Cleaning & Feature Engineering**:
    - CPI adjustment, lag features, ratios, age buckets.
  - **Python – Fixed Effects OLS for Lease Sales**:
    - y = Nameplate_LEASE_SALES; X = adjusted_Nameplate_AVG_PAYMENT, external_weighted_avg_payment, trend_sales, sales_inventory_ratio, competitor_sales; fixed effects: Nameplate, Business_Center, Model_Year.
    - Train/Test split; metrics: R², Adj‑R², MAPE.
  - **Python – Elasticity & Sensitivity Curves**:
    - log‑log OLS elasticity by cohort; buffer bands.
  - **Python – Scenario Simulation (grid)**:
    - Isoelastic demand proxy, profit = (price – cost) × demand, share proxy; guardrails; trade‑off score.
- A **Run Demo** button that executes a **lightweight, in‑memory version** on the uploaded Excel (or uses mock data if not provided) and pushes results to the **Scenario Simulation** and **Output Dashboard**.

# 10) KPIs (make them plentiful & realistic)
- Financial: Total Profit, Profit/Unit, Revenue, Contribution Margin, Expected Profit Uplift.
- Commercial: Lease Sales, Lease Penetration %, Win‑rate proxy/Share %, New vs Returning Mix.
- Competitive: CPIx in‑band %, Avg CPIx, % above/below competitor, Competitor price coverage %.
- Pricing Quality: Price dispersion (stdev/median) by BC & Segment, % within recommended band, Step‑change compliance %.
- Modeling: Median elasticity, Stability %, R²/Adj‑R², MAPE, Coverage % of cohorts with recommendations.
- Operations: Override rate %, Avg override magnitude, Adoption rate %, Data freshness (days), Guardrail breaches count.

# 11) Defaults & Demo Presets
- Pre‑select **Nameplate: Jeep Gladiator**, **Term 36 months**, and one **Business Center** to populate charts immediately.
- Provide two competitor placeholders (Comp‑A, Comp‑B) if user hasn’t mapped competitors.
- If no Excel uploaded, auto‑load a **small mock dataset** to keep UI alive for demo.

# 12) UX & Interactions
- Every chart supports hover tooltips with key fields (BC, Nameplate, MY, Term, Price, Profit, Share, CPIx, Elasticity).
- Cards are clickable to drill into the most relevant tab (e.g., click “CPIx in‑band %” → Price Distribution).
- Provide **toast notifications** after actions (ingest complete, cleaning done, outputs exported).
- Include **Confidence badge** (High/Medium/Low) next to recommendations (based on data volume and stability proxy).

# 13) Security/Privacy (prototype level)
- All data **in‑browser session** only for demo; no external persistence required.
- Include a **Reset Demo** button to clear data.

Build all of the above with a polished, enterprise dashboard look suitable for a client demo. Ensure **maximum number of clickable options** while keeping performance snappy. 

2,7
3,8 
(27997 more lines)

The evaluation metric for this contest is the categorization accuracy, or the proportion of test images that are correctly classified. For example, a categorization accuracy of 0.97 indicates that you have correctly classified all but 3% of the images.
