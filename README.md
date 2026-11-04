# Chicago_Taxi
Links:

[Chicago Taxi Trip dataset for 2024 to present](https://data.cityofchicago.org/Transportation/Taxi-Trips-2024-/ajtu-isnz/about_data)

[Chicago Community Area Dataset](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas/igwz-8jzy/about_data)

[Tableau Public interactive Viz](https://public.tableau.com/views/ChicagoTaxiData_17937646471460/GeographicActivity?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

# Project Overview
The stakeholder's at the Chicago Department of Business Affairs and Consumer Protection (BACP) want to follow trends in the Chicago Taxi industry as competition rises with ridesharing providers and the crash in medallion value. This industry is strictly regulated, and therefore its imperative to understand the trends that move through it. Stakeholders want to know "Where, When, and Who?"-- where demand is and when it is happening, who is performing well and where its all being earned. This Project has 2 deliverables, a set of professional dashboards and recommendations from an analysis that goes over chicago city taxi trip data spanning from August 8th- September 30, 2026, spanning about 1.05 million trips. This was performed with SQL (SSMS) and Tableau.

## Data Validation & Preparation. 
To prepare the Chicago taxi trip data for analysis, SQL Server (SSMS) was utilized to audit the table before building any dashboards. This was started by profiling the dataset and then checked for duplicate Trip IDs, missing values across 14 key fields, negative trip durations, and end timestamps earlier than start timestamps. Also compared the reported Trip Seconds against the duration calculated from the timestamps to confirm the column was free of calculation error, i.e. no negative time durations.

Fortunately, the data was largely clean, with no duplicate IDs, negative durations, or invalid timestamp orders. trips were  deliberately kept with missing census tract or community area values, since the Chigago Database stated that it masks some locations for privacy and the gaps reflect real trips, including some that leave the city. Looking next to extremes, there were some values to note, such as a 725-mile trip and a trip lasting nearly 24 hours. To judge how far out they were, median and 99th percentile were calculated for distance and duration (a median trip of 2.87 miles and 14 minutes, against a 99th percentile of 26.35 miles and 80 minutes). Rather than deleting these records, they were dispached with calculated fields in Tableau so trip counts and revenue still match to the source table, also to avoid touching the raw data. Finally, a SQL view was built that stacks pickups and dropoffs by community area and company, with additive measures (trips, fare, tips, revenue, miles, and seconds), so Tableau could calculate rates correctly when joined to the City’s community area boundaries.

The boundary data was saved as GeoJSON, since Tableau can connect natively, and make use of its MULTIPOLYGON value without too much effort on the servers' part. After importing that data and performing a Left inner join between the view and the community area file, the file is ready for visualization.

## Data Visualization Showcase & Initial Findings

 Dashboards were kept tidy by limiting each to a handful of KPIs and charts, with the headline numbers at the top, so a reader can get the main takeaway in seconds and use filters to dig deeper.

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/dad80773-ed98-4641-8b3f-7f7524defa9b" />


Transportation Demand tracks total trips and miles, trips by hour, a weekday-by-hour heatmap, average trip duration by week, and average trip distance by weekday. Demand is concentrated on weekdays between 7 AM and 7 PM, with peaks around 9 AM and 5 PM. Weekly average trip length holds steady at about 20 minutes and 6 miles. This matches the rhythm of the work day and suggests commuting drives much of the demand.

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/6260c13e-6dec-4a00-a77b-e43f3911b94d" />



Earnings Overview covers payment method mix, average trip value, total revenue, dollars per mile, revenue by company, average fare by distance, and a company performance table. Nearly half of riders pay by credit card. The average trip is worth about $30 and averages $3.83 per mile, which adds up to more than $31 million in revenue over the period. Flash Cab, Taxicab Insurance Agency LLC (TIA), and Transit Administrative Center Inc (TAC) are the top performers. Fare rises with trip length, as expected.

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/86949961-b18d-4f37-b1ef-f8ec4225e470" />


Geographic Activity maps trip volume across Chicago’s 77 community areas, with a metric selector that recolors the map by total trips, trips per square mile, average fare, fare per mile, or market share. KPI cards show the top pickup and dropoff areas, and supporting charts show the busiest areas, net flow (pickups minus dropoffs), and company share in a selected neighborhood. Near North Side ranks first for both pickups (243,063) and dropoffs (267,824), but it receives about 24,800 more riders than it sends out, meaning more trips end there than begin there. The Loop shows the same pattern. One possible explanation is that riders arrive by taxi and leave by other means, such as walking, transit, or rideshare, though this wasnt in the scope of information given. When adjusted for area, the Loop is the densest, at about 96,400 pickups per square mile versus about 88,400 for Near North Side.

Averages and per-mile rates exclude the roughly 1% of trips flagged as implausible, while trip counts and revenue include every trip so they reconcile to the source data. Footnotes on each dashboard document these choices, the City’s time rounding, and that 97.4% of trips have a known pickup area.

# Overall Findings and Recommendations

These recommendations are framed as follow-up questions for BACP, or instructions for further analysis to be performed on the full scale dataset for whatever timeframe is chosen. The data shows patterns, but not their causes.

1. Market concentration: three companies carry nearly half of trips

Flash Cab, Taxicab Insurance Agency LLC (TIA), and Transit Administrative Center Inc (TAC) together account for nearly half of all trips and are the top performers by revenue. When a few operators hold this much of the market, a compliance failure, financial problem, or service change at one of them affects a large share of riders. It also shapes how much room smaller operators have to compete.

BACP should track the combined share of Flash Cab, TIA, and TAC monthly or yearly to see whether concentration is growing or shrinking, since a single snapshot can’t show a trend. It should also check concentration by neighborhood using the Market Share view, because a company holding most of one area is a different situation than holding a third of the city. Finally, comparing per-mile and per-trip rates between large and small operators would speak directly to pricing, which is usually the core consumer protection question.

2. Demand follows the weekday work schedule

Weekday trips between 7 AM and 7 PM are the densest, peaking around 9 AM and 5 PM. Average trips run about 20 minutes and 6 miles, while the median trip is shorter (about 14 minutes and 2.9 miles), because long trips pull the average up. Predictable peaks show when the system is under the most strain, which is when wait times and fare disputes are most likely.

If the goal is to reach the most riders, BACP could align inspections and consumer outreach with the weekday peaks around 9 AM and 5 PM. It would also be worth reviewing late-night and weekend coverage to see whether service drops off outside the work-day pattern. The commuting explanation should be treated as a hypothesis, since the data shows when trips happen but not why.

3. Activity is concentrated downtown, and flow is uneven

Near North Side ranks first in both pickups (243,063) and dropoffs (267,824), followed by the Loop (160,283 pickups and 177,348 dropoffs).
Both areas receive more riders than they send out. Near North Side has about 24,800 more dropoffs than pickups and the Loop about 17,100 more. O’Hare shows the largest positive net flow, with more pickups than dropoffs, consistent with travelers leaving the airport by cab.
Adjusted for area, the Loop is the densest, at about 96,400 pickups per square mile versus about 88,400 for Near North Side. The third-highest area (about 21,700 per square mile) has under a quarter of the Loop’s density, and density keeps falling toward the city’s edges. Taxi activity clusters in a few areas, so BACP may want to know how much service reaches the rest of the city. Low volume could mean low demand or thin supply, and this data can’t tell which.

BACP should review the lowest-density community areas as a group and compare them with transit access and population, since low trip volume could reflect low demand or thin supply and this data can’t tell which. It should also ask why trips end downtown more often than they begin there. Riders may arrive by taxi and leave on foot, by transit, or by rideshare, but I did not test this. Comparing O’Hare’s operator mix with the citywide mix in the Market Share view would also show who serves the airport.

4. Fares are higher at the airport and the outer areas, mostly because trips are longer.

Average fare is highest at O’Hare, where it reaches about $46, and is generally higher toward the city’s edges, while central areas have the lowest averages (about $11 at the low end). Per mile, the pattern largely reverses. O’Hare is among the lowest-rate areas (the map’s range runs from about $3.21 to $5.59 per mile), and central areas are moderate to high. Higher outer-area fares therefore appear to reflect trip distance rather than higher rates. One southwest area (likely near Midway) is high on both measures and stands out. For consumer protection, the key question is whether riders pay more per mile in certain places. Here, the airport’s higher fares look like a distance effect.

The southwest area with the highest per-mile rate deserves a closer look, including its trip count and operator mix, to determine whether it reflects airport surcharges or just a small sample. Comparing per-mile rates for short and long trips would confirm the distance effect, since base fares dominate short trips and spread out over long ones. Airport trips should also be broken out separately to check for flat fees or surcharges.

5. Check Payment data for quality gaps

The payment pie charts shows share of fare dollars, and share of trips. Credit cards account for 46.08% of fare revenue even though they make up about 35% of trips, because card trips tend to be longer and pricier. By trip count, mobile (34.9%), credit card (34.7%), and private card (6.4%) account for about three in four trips, and cash accounts for roughly 22%.
About 1.8% of trips (19,011) have an unknown payment type, but nearly all carry a recorded charge. This is a data gap, not unpaid rides.
Trips labeled “No Charge” (0.25% of trips) carry about $51,000 in recorded fares, roughly 0.21% of fare revenue. Only 87 of those 2,663 trips show a zero total, so the label and the fare record often disagree.
About 0.2% of all trips (roughly 2,000) show a zero total, mostly cash. Disputed trips are the exception: about 22% of them show a zero total, a much higher rate than any other payment type. The amounts are small, but they affect how far payment fields can be trusted for revenue analysis and show where recording practices may be inconsistent.

BACP should ask the City’s data owners how the “Unknown” and “No Charge” labels are assigned and why labels and totals often disagree. It would also be useful to check whether unknown-payment or zero-total trips cluster in particular companies. Disputed trips deserve separate attention, since about 22% of them show a zero total, far above any other payment type, and reviewing how they are recorded could explain why

# Limitations & Assumptions

- The analysis covers August 8 to September 30, 2026 (1,048,575 trips). The original target window began August 1, but the source file starts on August 8. The row count matches Excel’s row limit, so the file was most likely truncated when it passed through a tool with that cap. Because the window is under two months, the results can’t capture seasonality, holidays, or longer-term trends, and they should be read as a proof of concept rather than a full picture of taxi activity.

- The City rounds trip timestamps to 15-minute intervals and durations to whole minutes, which was confirmed in the dataset provided by BACP. Durations were therefore taken from Trip Seconds rather than calculated from timestamps, and very short trips can legitimately show as 0 minutes. The City also generalizes locations for privacy, so 2.6% of pickups (27,128) and 8.2% of dropoffs (85,895) have no community area. They are excluded from the Geographic Activity dashboard but included in the other two, so totals differ slightly between dashboards.

- The thresholds for implausible trips (over 100 miles, over 4 hours, over 80 mph on trips of 3 minutes or longer, or zero seconds with zero miles) are judgment calls, set well above the 99th percentile. They flagged 11,334 trips (1.08%) for distance-based metrics and 11,723 trips (1.12%) for duration. Flagged trips are excluded only from averages and per-mile calculations, and remain in trip counts and revenue. A larger group, 54,336 trips (5.2%) with zero recorded miles but nonzero duration, was kept in the averages without further investigation, so average distance and $ per mile may be slightly understated. The fare-per-mile metric on the geographic map is also not outlier-cleaned, so values for low-volume areas can swing on a few records.

- Different measures use different fields. Total revenue and average trip value use Trip Total (fare plus tips, taxes, and extras), while $ per mile and the payment pie use Fare to eliminate tipping skew. The payment chart shows share of fare dollars, not share of trips, so it should not be read as the share of riders using each method. Market share figures are based on trip counts, not revenue
  
- On the map, each trip counts once in its pickup area and once in its dropoff area, so metrics like average fare blend inbound and outbound trips. The Company Share chart compares only the top 10 companies, so its percentages are not citywide shares. Trips per square mile depends on converting the boundary file’s shape area to square miles, which was checked against known values but is worth noting.

- About 1.8% of trips have an unknown payment type, and trips labeled “No Charge” often still carry a nonzero fare. Due to low magnitude this was not corrected, but they show that payment labels and fare records don’t always agree.

- The data shows when and where trips happen, not why. Explanations such as commuting driving weekday demand, riders arriving downtown by taxi and leaving by other means, or distance explaining higher outer-area fares are hypotheses supported by the patterns but not tested. The dataset covers taxis only, so it excludes rideshare and other for-hire services, and low taxi volume in an area doesn’t necessarily mean low transportation demand there.

# Next Steps

This was built as a proof of concept, so the next steps cover what would turn it into a tool BACP could use on an ongoing basis.
-  Complete and extend the data with a full year or more to showcase seasonality, MoM comparisons and make demand and concentration findings more credible
-  Look into the open data questions regarding 0 mile trips and $0 fares for cancellations, rounded short rides etc. As the data range expands, there should be measures to ensure overall data quality beyond the scope of what this report covers.
-  Broaden the scope to include information from encroaching competition. City rideshare trip data would give a good picture for how taxis fit into the wider market. Also community area population information, income information per community, public transit access etc. would give more room to drill through data and find trends.
-  Several follow-ups from the recommendations could become new views, such as a trend of the top three companies’ combined share over time, a comparison of fare per mile for short versus long trips to confirm the distance effect, and a separate look at airport trips for flat fees or surcharges. 
-  More data in general would allow for improvement on dashboard features, such as filters for date. If BACP wanted ongoing use, the dashboards could be published to Tableau Server or Tableau Cloud and connected to a scheduled data refresh, instead of a live connection to a local SQL Server, with a short data dictionary documenting each metric’s definition.
