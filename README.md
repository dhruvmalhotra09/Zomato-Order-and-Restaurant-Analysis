# Zomato-Order-and-Restaurant-Analysis Using Power BI
This project analyzes Zomato’s restaurant and order data across five major Indian cities using Power BI, SQL, and Excel.
The goal is to uncover city-level demand, restaurant performance, customer behavior, and revenue trends to help drive data-driven business decisions.

# Project Objective

To perform a multi-angle analysis covering:

- City-wise restaurant availability

- Order demand distribution

- Monthly revenue trends

- Restaurant rating behavior

- High-value restaurant identification

- Area-wise revenue contribution

- KPI-level business performance

- Restaurant-level sales summaries

This project combines SQL data cleaning, ETL preparation, and Power BI visualization to deliver actionable insights.

# Tech Stack

- <b>Power BI</b> — Interactive dashboards & visual analysis

- <b>SQL(MySQL)</b> — Data cleaning, standardization & validation

- <b>Excel</b> — Raw dataset handling

- <b>PowerPoint</b> — Final business presentation

# Dataset Overview

The project uses two datasets:
<table>
  <tr>
    <th>File</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Zomato_Orders.csv</td>
    <td>Contains order details: order_id, restaurant_id, date, time, delivery time, total cost, rating, payment method</td>
  </tr>
  <tr>
    <td>Zomato_Restaurants.csv</td>
    <td>	Contains restaurant attributes: city, area, cuisine, price range, rating, delivery availability</td>
  </tr>
</table>

SQL cleaning involved removing duplicates, normalizing text, fixing date-time fields, and validating rating/order ranges.
[SQL Queries](SQL/zomato_sql_queries.sql)

# Data Cleaning & Preparation (SQL)

- Handled nulls, malformed IDs, blank text
- Combined order date + time into order_ts
- Removed duplicate order IDs & restaurant IDs
- Normalized text fields (city, price_range, payment_method)
- Validated ratings (1–5), item counts, and monetary values
- Ensured consistent restaurant master data

SQL reference file:
[SQL Queries](SQL/zomato_sql_queries.sql)

# Key Tasks & Insights (Power BI)

<table>
  <tr>
    <th>Task</th>
    <th>Objective</th>
    <th>Key Insight</th>
  </tr>
  <tr>
    <td><b>1. Restaurants per City</b></td>
    <td>Identify restaurant supply</td>
    <td>Mumbai (115) & Bangalore (109) lead; metros dominate restaurant availability.</td>
  </tr>
  <tr>
    <td><b>2. Orders by City</b></td>
    <td>Understand demand spread</td>
    <td>Mumbai + Bangalore = ~45% of orders; all 5 cities show balanced demand.</td>
  </tr>
  <tr>
    <td><b>3. Monthly Revenue Trend</b></td>
    <td>Detect seasonal patterns</td>
    <td>Peak in April (1.38M), dip in June (1.26M).</td>
  </tr>
  <tr>
    <td><b>4. Rating Correlation	</b></td>
    <td>Understand factors affecting ratings</td>
    <td>Slight uplift for premium restaurants; delivery time not strongly correlated.</td>
  </tr>
  <tr>
    <td><b>5. Top 5 Restaurants by Sales</b></td>
    <td>Identify high-value partners</td>
    <td>Restaurant_116 leads (~₹50.9K); mix of premium & volume-driven players.</td>
  </tr>
  <tr>
    <td><b>6. Revenue by Area (Tree Map)</b></td>
    <td>Area performance</td>
    <td>Area A contributes highest (22% of revenue).</td>
  </tr>
  <tr>
    <td><b>7. Order Density (Heat Map)</b></td>
    <td>Demand hotspots</td>
    <td>Mumbai (3384) & Bangalore (3300) dominant; cities otherwise balanced.</td>
  </tr>
  <tr>
    <td><b>8. KPI Cards</b></td>
    <td>High-level performance</td>
    <td>Revenue = ₹15.57M, Orders = 15K, AOV ≈ ₹1,040.</td>
  </tr>
  <tr>
    <td><b>9. Restaurant Sales Summary</b></td>
    <td>Compare restaurant performance</td>
    <td>AOV stable across restaurants (~₹1,000–1,100).</td>
  </tr>
</table>
Power BI reference PPT:
[Power BI Dashboard File] (PowerBI/Zomato Analysis.pbix)

# Strategic Insights

- Metro cities dominate both restaurant supply and customer demand.

- Top restaurants drive a disproportionate share of revenue → priority partnership targets.

- AOV is stable across cities, indicating consistent spending behavior.

- Balanced area contributions suggest diversified operational potential.

- Opportunities in Tier-2 & Tier-3 cities for future expansion.

# Project Structure

Zomato-Order-and-Restaurant-Analysis/<br>
│── Data/<br>
│     ├── Zomato_Orders.csv<br>
│     ├── Zomato_Restaurants.csv<br>
│<br>
│── SQL/<br>
│     ├── zomato_sql_queries.sql<br>
│<br>
│── PowerBI/<br>
│     ├── Zomato Analysis.pbix<br>
│<br>
│── Presentation/<br>
│     ├── Zomato Order & Restaurant Analysis Using Power BI.pptx<br>
│<br>
└── README.md<br>

# Conclusion

- This project delivers strong visibility into:

- City-level demand distribution

- Restaurant performance and revenue contribution

- Rating drivers & service factors

- High-value restaurant identification

- Opportunities for expansion and optimization

The combined SQL + Power BI workflow provides a powerful framework for ongoing food delivery analytics.
