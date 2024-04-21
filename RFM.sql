DECLARE @today_date as date = '2014-01-01';
with cte1 as
(
select 
    CustomerID,
    DATEDIFF(day,MAX(OrderDate), @today_date) AS Recency,
    COUNT(distinct OrderDate) AS Frequency,
    SUM(SubTotal) AS Monetary
from Sales.SalesOrderHeader
group by CustomerID
having DATEDIFF(year, MAX(OrderDate), @today_date) = 1
)

, cte2 as
(
select 
    CustomerID,
    Monetary as SubTotal,
    percent_rank() over (order by Recency) as Recency_Rank,
    percent_rank() over (order by Frequency desc) as Frequency_Rank,
    percent_rank() over (order by Monetary desc) as Monetary_Rank
from cte1
)

, cte3 as
(
select
    CustomerID,
    SubTotal,
    (
        case 
        when Recency_Rank >= 0 and Recency_Rank <= 0.2 then 5
        when Recency_Rank > 0.2 and Recency_Rank <= 0.4 then 4
        when Recency_Rank > 0.4 and Recency_Rank <= 0.6 then 3
        when Recency_Rank > 0.6 and Recency_Rank <= 0.8 then 2
        else 1
        end
    ) Score_Recency,
    (
        case 
        when Frequency_Rank >= 0 and Frequency_Rank <= 0.2 then 5
        when Frequency_Rank > 0.2 and Frequency_Rank <= 0.4 then 4
        when Frequency_Rank > 0.4 and Frequency_Rank <= 0.6 then 3
        when Frequency_Rank > 0.6 and Frequency_Rank <= 0.8 then 2
        else 1
        end
    ) Score_Frequency,
    (
        case 
        when Monetary_Rank >= 0 and Monetary_Rank <= 0.2 then 5
        when Monetary_Rank > 0.2 and Monetary_Rank <= 0.4 then 4
        when Monetary_Rank > 0.4 and Monetary_Rank <= 0.6 then 3
        when Monetary_Rank > 0.6 and Monetary_Rank <= 0.8 then 2
        else 1
        end
    ) Score_Monetary
from cte2
)

, cte4 as
(
select 
    *,
    CONCAT(Score_Recency, Score_Frequency, Score_Monetary) as RFM
from cte3
)


select 
    *,
    (
        case 
        when RFM in ('555','554','544','545','454','455','445') then 'Champions' 
        when RFM in ('543','444','435','355','354','345','344','335') then 'Loyal Customers'
        when RFM in ('553', '551', '552', '541', '542', '533', '532', 
                    '531', '452', '451', '442', '441', '431', '453', 
                    '433', '432', '423', '353', '352', '351', '342', 
                    '341', '333', '323') then 'Potential Loyalist'
        when RFM in ('512', '511', '422', '421', '412', '411', '311') then 'Recent Customers'
        when RFM in ('525', '524', '523', '522', '521', '515', '514', 
                    '513', '425', '424', '413', '414', '415', '315', 
                    '314', '313') then 'Promising'
        when RFM in ('535', '534', '443', '434', '343', '334', '325', 
                    '324') then 'Customers Needing Attention'
        when RFM in ('331', '321', '312', '221', '213') then 'About To Sleep'
        when RFM in ('255', '254', '245', '244', '253', '252', '243', 
                    '242', '235', '234', '225', '224', '153', '152', 
                    '145', '143', '142', '135', '134', '133', '125', 
                    '124') then 'At Risk'
        when RFM in ('155', '154', '144', '214', '215', '115', '114', 
                    '113') then 'Can’t Lose Them'
        when RFM in ('332', '322', '231', '241', '251', '233', '232', 
                    '223', '222', '132', '123', '122', '212', '211') then 'Hibernating'
        when RFM in ('111', '112', '121', '131', '141', '151') then 'Lost'
        end
    ) as Customer_Segment
from cte4