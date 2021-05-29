class_name XDate

#const DAYS_PER_MONTH = 30
#const DAYS_PER_YEAR = DAYS_PER_MONTH * 12

var _year = 0 
var _month = 0
var _day = 0
var _jd = 0

var year: int : 
	set(value):
		_year = value
		update_julian_day()
	get:
		return _year

var month: int : 
	set(value):
		_month = value
		update_julian_day()
	get:
		return _month

var day: int : 
	set(value):
		_day = value
		update_julian_day()
	get:
		return _day

var julian_day: int : 
	set(value):
		_jd = value
		update_date()
	get:
		return _jd

func _init(y=0, m=0, d=0):
	set_date(y,m,d)


func set_date(y, m, d):
	_year = y
	_month = m
	_day = d
	update_julian_day()


static func current():
	var dt = OS.get_date()
	return XDate.new(dt["year"], dt["month"], dt["day"])


static func compare(d1:XDate, d2:XDate):
	return d1._jd - d2._jd


static func is_leap_year(year):
	return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)


func get_days_in_year()->int:
	return 366 if is_leap_year(year) else 365


func get_days_in_month(m)->int:
	match m:
		2:
			return 29 if is_leap_year(year) else 28
		4,6,9,11:
			return 30
		_:
			return 31

# returns the day of year(1 to 365 or 366 on leap year)
func get_day_of_year():
	var ret = 0
	for i in range(1,month):
		ret += get_days_in_month(i)
	ret += day
	return ret


func get_day_of_week()->int:
	var t : Array = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var y = year
	if(month < 3):
		y -= 1
	return (y + y/4 - y/100 + y/400 + t[month - 1] + day-1) % 7


func _to_string():
	return format()


func format(fmt = "YYYY/MM/DD"):
	if "DD".is_subsequence_of(fmt):
		fmt = fmt.replace("DD",str(day).pad_zeros(2))
	if "MM".is_subsequence_of(fmt):
		fmt = fmt.replace("MM",str(month).pad_zeros(2))
	if "YYYY".is_subsequence_of(fmt):
		fmt = fmt.replace("YYYY",str(year).pad_zeros(4))
	return fmt


func add_years(n):
	return XDate.new(year+n,month,day)


func add_months(n):
	var m = (month-1)+n
	var y = year + m/12
	m = m%12
	if m<0:
		y -= 1
		m += 12
	return XDate.new(y,m+1,day)


func add_days(n):
	var ret = XDate.new(_year, _month,_day)
	ret.julian_day += n
	return ret


func get_months_to(other: XDate):
	if compare(self, other) > 0:
		return -other.get_months_to(self)
	if year == other.year:
		return other.month - month
	
	return (12-month) + (other.year-1-year)*12 + other.month


func get_days_to(other:XDate):
	if compare(self,other) > 0:
		return -other.get_days_to(self)
	if year==other.year:
		return other.get_day_of_year()-get_day_of_year()
	
	var d1 = get_days_in_year()-get_day_of_year()
	
	var d2 = 0
	for i in range(year+1,other.year):
		d2 += 366 if is_leap_year(i) else 365
	var d3 = other.get_day_of_year()
	
	return d1 + d2 + d3


func save():
	return {
		"year":_year,
		"month":_month,
		"day":_day
	}

func restore(json):
	if typeof(json) != TYPE_DICTIONARY:
		return
	_year = int(json.get("year",_year))
	_month = int(json.get("month",_month))
	_day = int(json.get("day",_day))
	update_julian_day()

#func get_julian_day():
#	var a = (14-month)/12
#	var y = year + 4800 - a
#	var m = month + 12*a - 3
#	return day + (153*m+2)/5 + 365*y + y/4 -y/100 + y/400 - 32045


static func from_julian_day(jd):
	var date = XDate.new()
	date.julian_day = jd
	return date


func update_julian_day():
	var a = (14-month)/12
	var y = year + 4800 - a
	var m = month + 12*a - 3
	_jd = day + (153*m+2)/5 + 365*y + y/4 -y/100 + y/400 - 32045


func update_date():
	var a = _jd + 32044
	var b = (4*a+3)/146097
	var c = a - (146097*b)/4
	
	var d = (4*c+3)/1461
	var e = c - 1461*d/4
	var m = (5*e+2)/153
	_day = e-(153*m+2)/5 + 1
	_month = m + 3 - 12 * (m/10)
	_year = 100*b + d - 4800 + m/10

#func total_days():
#	return year*DAYS_PER_YEAR + month*DAYS_PER_MONTH + day
#
#func from_total_days(days:int):
#	year = int(days / DAYS_PER_YEAR)
#	days -= year * DAYS_PER_YEAR
#	month = int(days / DAYS_PER_MONTH)
#	days -= month * DAYS_PER_MONTH
#	day = days 
#
#func days_to(other: XDate)->int:
#	return other.total_days()-total_days()
#
#func elapsed_days():
#	var cur_date = get_script().new()
#	cur_date.reset()
#	return days_to(cur_date)
#
#func add_days(days:int):
#	from_total_days(total_days()+days)
#
#func stamp()->int:
#	return total_days()
#
#func is_equal_to(other:XDate)->bool:
#	return total_days()==other.total_days()
