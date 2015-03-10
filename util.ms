fn stringToPoint3 str =
(
	local pa = filterString str "[],"
	point3 (pa[1] as float) (pa[2] as float) (pa[3] as float)
)