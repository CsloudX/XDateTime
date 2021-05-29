
class_name XDateTime

const SECONDS_PER_DAY = XTime.SECONDS_PER_HOUR * 24

var date = XDate.new()
var time = XTime.new()

func _init(year=0, month=0, day=0, hour=0, minute=0, second=0, ms=0):
	reset(year, month, day, hour, minute, second,ms)


func reset(year, month, day, hour, minute, second,ms=0):
	date.set_date(year, month, day)
	time.reset(hour, minute, second, ms)

func set_to_current():
	date.set_to_current()
	time.set_to_current()


func format(fmt = "yyyy/MM/dd hh:mm:ss.zzz"):
	var ret = date.format(fmt)
	ret = time.format(ret)
	return ret


func _to_string():
	return "%s %s"%[date,time]

func total_seconds():
	return date.total_days()*SECONDS_PER_DAY + time.total_seconds()

func from_total_seconds(seconds):
	date.from_total_days(seconds/SECONDS_PER_DAY)
	seconds -= date.to_total_days() * SECONDS_PER_DAY
	time.from_total_seconds(seconds)

func seconds_to(other: XDateTime)->int:
	return other.total_seconds()-total_seconds()

func elapsed_seconds():
	var cur_datetime = get_script().new()
	cur_datetime.reset()
	return seconds_to(cur_datetime)

func add_years(years: int):
	date = date.add_years(years)

func add_months(months:int):
	date = date.add_months(months)

func add_days(days:int):
	date = date.add_days(days)

func from_unix_time(unix_time_val: int):
	var dt = OS.get_datetime_from_unix_time(unix_time_val)
	date.year = dt["year"]
	date.month = dt["month"]
	date.day = dt["day"]
	time.hour = dt["hour"]
	time.minute = dt["minute"]
	time.second = dt["second"]


func save():
	return {
		"date":date.save(),
		"time":time.save()
	}

func restore(json):
	if typeof(json)!=TYPE_DICTIONARY:
		return
	date.restore(json.get("date"))
	time.restore(json.get("time"))


static func current():
	var ret = XDateTime.new()
	ret.date = XDate.current()
	ret.time = XTime.current()
	return ret


static func compare(d1:XDateTime, d2:XDateTime):
	return XGlobal.compare_array([d1.date,d1.time],[d2.date,d2.time])

