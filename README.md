# Chicago_Taxi
Links:

[Chicago Taxi Trip dataset for 2024 to present](https://data.cityofchicago.org/Transportation/Taxi-Trips-2024-/ajtu-isnz/about_data)

[Chicago Community Area Dataset](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas/igwz-8jzy/about_data)

[Tableau Public interactive Viz]()

# Project Overview
The stakeholder's at the BCBP want to follow trends in the Chicago Taxi industry as competition rises with ridesharing providers and the crash in medallion value. This industry is strictly regulated, and therefore its imperative to understand the trends that move through it. Stakeholders want to know "Where, When, and Who?"-- where demand is and when it is happening, who is performing well and where its all being earned. This Project has 2 deliverables, a set of professional dashboards and recommendations from an analysis that goes over chicago city taxi trip data spanning from August 8th- September 30, 2026, spanning about 1.05 million trips. This was performed with SQL (SSMS) and Tableau.

## Data Validation & Preparation. 
To prepare the Chicago taxi trip data for analysis, SQL Server (SSMS) was utilized to audit the table before building any dashboards. This was started by profiling the dataset and then checked for duplicate Trip IDs, missing values across 14 key fields, negative trip durations, and end timestamps earlier than start timestamps. Also compared the reported Trip Seconds against the duration calculated from the timestamps to confirm the column was free of calculation error, i.e. no negative time durations.

Fortunately, the data was largely clean, with no duplicate IDs, negative durations, or invalid timestamp orders. trips were  deliberately kept with missing census tract or community area values, since the Chigago Database stated that it masks some locations for privacy and the gaps reflect real trips, including some that leave the city. Looking next to extremes, there were some values to note, such as a 725-mile trip and a trip lasting nearly 24 hours. To judge how far out they were, median and 99th percentile were calculated for distance and duration (a median trip of 2.87 miles and 14 minutes, against a 99th percentile of 26.35 miles and 80 minutes). Rather than deleting these records, they were dispached with calculated fields in Tableau so trip counts and revenue still match to the source table, also to avoid touching the raw data. Finally, a SQL view was built that stacks pickups and dropoffs by community area and company, with additive measures (trips, fare, tips, revenue, miles, and seconds), so Tableau could calculate rates correctly when joined to the City’s community area boundaries.

The boundary data was saved as GeoJSON, since Tableau can connect natively, and make use of its MULTIPOLYGON value without too much effort on the servers' part. After importing that data and performing a Left inner join between the view and the community area file, the file is ready for visualization.

## Data Visualization Showcase & Findings

 Dashboards were kept tidy by limiting each to a handful of KPIs and charts, with the headline numbers at the top, so a reader can get the main takeaway in seconds and use filters to dig deeper.

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/dad80773-ed98-4641-8b3f-7f7524defa9b" />


Transportation Demand tracks total trips and miles, trips by hour, a weekday-by-hour heatmap, average trip duration by week, and average trip distance by weekday. Demand is concentrated on weekdays between 7 AM and 7 PM, with peaks around 9 AM and 5 PM. Weekly average trip length holds steady at about 20 minutes and 6 miles. This matches the rhythm of the work day and suggests commuting drives much of the demand.

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/5c9b670f-75a6-4873-baf8-63b640251417" />


Earnings Overview covers payment method mix, average trip value, total revenue, dollars per mile, revenue by company, average fare by distance, and a company performance table. Nearly half of riders pay by credit card. The average trip is worth about $30 and averages $3.13 per mile, which adds up to more than $31 million in revenue over the period. Flash Cab, Taxicab Insurance Agency LLC (TIA), and Transit Administrative Center Inc (TAC) are the top performers. Fare rises with trip length, as expected.

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/86949961-b18d-4f37-b1ef-f8ec4225e470" />


Geographic Activity maps trip volume across Chicago’s 77 community areas, with a metric selector that recolors the map by total trips, trips per square mile, average fare, fare per mile, or market share. KPI cards show the top pickup and dropoff areas, and supporting charts show the busiest areas, net flow (pickups minus dropoffs), and company share in a selected neighborhood. Near North Side ranks first for both pickups and dropoffs, but it has roughly 20,000 more pickups than dropoffs, meaning more riders leave the area by taxi than arrive. One possible explanation is tourism, since visitors may arrive by other means and leave by cab, though there is no way to test this given the scope of the data. O’Hare Airport shows the largest net positive flow, consistent with travelers landing and taking a cab into the city. Flash Cab, TIA, and TAC together account for nearly half of all trips.

Averages and per-mile rates exclude the roughly 1% of trips flagged as implausible, while trip counts and revenue include every trip so they reconcile to the source data. Footnotes on each dashboard document these choices, the City’s time rounding, and that 97.4% of trips have a known pickup area.

# Recommendations
- Three companies carry nearly half of trips, which is worth monitoring for market concentration.
When a few operators hold a large share, a compliance problem, financial failure, or service change at one of them affects a large part of riders. It also affects how much leverage smaller operators have, and in the current market of ridesharing apps and services, there isn't much room for error.
Recommend tracking the top-three share over time (monthly or yearly) to see whether concentration is growing or shrinking. Also check and see if this concentration varies geographically in the community. A company holding 70% of one neighborhood is a different situation than 30% citywide, and the Market Share map already surfaces this.
- Demand is concentrated in weekday commute windows, which matters for enforcement or service planning.
Weekday trips between 7 AM and 7 PM are the densest, peaking around 9 AM and 5 PM, which matches a typical work schedule. Predictable peaks tell the city when service is under the most strain, which is when wait times, refusals, and fare disputes are most likely.
Reccomend Schedule inspections or consumer-protection outreach around peak windows if the goal is to reach the most riders. Also pay attention to off-peak hours, especially late nights and weekends, to see whether service coverage drops there. Note that "commuting" times is also a hypothesis, treat and test it as such, correlation != causation.
 
- Airport and downtown areas dominate net flow, so coverage in lower-volume community areas may deserve a closer look.


