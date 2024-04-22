with possible_route as
(select
    khoi_hanh,
	dich_den,
	CAST (khoi_hanh + '->' + dich_den as nvarchar(255) ) as route,
	cast (khoang_cach as decimal(10,2)) as khoang_cach
from lab_3 

union all

select
    a.khoi_hanh,
	b.dich_den,
	cast (a.route + '->' + b.dich_den as nvarchar(255)) as route,
	cast (a.khoang_cach + b.khoang_cach as decimal(10,2) ) as khoang_cach
from possible_route as A inner join lab_3 as b on a.dich_den = b.khoi_hanh)

select
    khoi_hanh as 'Start',
    dich_den as 'End',
	Route,
	khoang_cach as Distance
from possible_route
order by khoang_cach
