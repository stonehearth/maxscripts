function hash_create = (
	return #()
)

function hash_add hash key v = (
	append hash #(key, v)
)

function hash_get arr k = (
	local i
	for i = 1 to arr.count do (	
		local key
		local v

		key = arr[i][1]
		v = arr[i][2]
		
		if(key == k) then (
			return v;
		)
	)
	
	return 0
)

function test_hash = (
	local h
	
	h = hash_create()
	
	hash_add h "two" 2
	hash_add h "one" 1
	hash_add h "three" 3
	
	a = hash_get h "one"
	b = hash_get h "two"
	c = hash_get h "three"
	
	if (a == 1 and b == 2 and c == 3) then (
		print "hash test passed"
	) else (
		print "hash test FAILED!!!"
	)
	
	return ""
	
)

--test()