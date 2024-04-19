with cte1 as
(
select 
    CustomerID,
    DATEDIFF(day,MAX(OrderDate), '2014-01-01') AS Recency,
    COUNT(distinct OrderDate) AS Frequency,
    SUM(SubTotal) AS Monetary
from Sales.SalesOrderHeader
group by CustomerID
having DATEDIFF(YEAR,MAX(OrderDate), '2014-01-01') = 1
)

, cte2 as
(
select 
    CustomerID,
    Recency,
    percent_rank() over (order by Frequency desc) as Frequency_Rank,
    percent_rank() over (order by Monetary desc) as Monetary_Rank
from cte1
)
, cte3 as
(
select
    CustomerID,
    (
        case 
        when Recency BETWEEN 0 and 120 then 3
        when Recency BETWEEN 121 and 240 then 2
        when Recency BETWEEN 240 and 370 then 1
        end
    ) Score_Recency,
    (
        case 
        when Frequency_Rank BETWEEN 0 and 0.2 then 3
        when Frequency_Rank BETWEEN 0.2 and 0.5 then 2
        when Frequency_Rank BETWEEN 0.5 and 1 then 1
        end
    ) Score_Frequency,
    (
        case 
        when Monetary_Rank BETWEEN 0 and 0.2 then 3
        when Monetary_Rank BETWEEN 0.2 and 0.5 then 2
        when Monetary_Rank BETWEEN 0.5 and 1 then 1
        end
    ) Score_Monetary
from cte2
)

, cte4 as
(
select 
    CustomerID,
    CONCAT(Score_Recency, Score_Frequency, Score_Monetary) as RFM
from cte3
)

select 
    CustomerID,
    RFM,
    (
        case 
        when RFM like '333' or RFM like '323' then 'VIP' 
        when RFM like '%%3' then 'Big Spenders'
        when RFM like '%3%' then 'Frequent Customers'
        when RFM like '3%%' then 'Recent Customers'
        when RFM like '2%%' then 'At risk'
        when RFM like '111' then 'Lost Inconsequential Customers'
        when RFM like '1%%' and RFM not like '111' then 'High risk'
        end
    ) as Customer_Segment
from cte4
order by RFM