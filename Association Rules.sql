with cte as
(
select 
	OrderID,
	ProductID
from [Order Details]
)

, cte1 as
(
select 
	left_table.ProductID as product_A,
	right_table.ProductID as product_B,
	count(left_table.OrderID)*1.0 as total_order_product_A_and_B
from cte as left_table join cte as right_table
	on left_table.OrderID = right_table.OrderID
where left_table.ProductID <> right_table.ProductID
group by
	left_table.ProductID,
	right_table.ProductID
)

, cte2 as
(
select 
	ProductID,
	count(OrderID) as sum_each_product
from cte
group by ProductID
)

, cte3 as
(
select 
	main.product_A,
	product_a.ProductName as Name_product_A,
	main.product_B,
	product_b.ProductName as Name_Product_B,
	total_order_product_A_and_B,
	left_table.sum_each_product*1.0 as Total_order_product_A,
	right_table.sum_each_product*1.0 as Total_order_product_B,
	(select 
		count(distinct OrderID) 
	from cte)*1.0 as Total_order
from cte1 as main 
	left join cte2 as left_table
		on main.product_A = left_table.ProductID
	left join cte2 as right_table
		on main.product_B = right_table.ProductID
	left join Products as product_a
		on main.product_A = product_a.ProductID
	left join Products as product_b
		on main.product_B = product_b.ProductID
)

select 
	Name_product_A,
	Name_Product_B,
	Total_order_product_A_and_B,
	Total_order,
	Total_order_product_A,
	Total_order_product_B,
	round(Total_order_product_A/Total_order, 4) as Suport,
	round(total_order_product_A_and_B/Total_order_product_A, 4) as Confident,
	round((total_order_product_A_and_B/Total_order_product_A)/(Total_order_product_B/Total_order), 2) as Lift
from cte3
order by Lift desc