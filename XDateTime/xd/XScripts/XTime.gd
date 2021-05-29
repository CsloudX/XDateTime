
class_name XTime

const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60

var hour = 0
var minute = 0
var second = 0
var ms = 0

func _init(_hour=0, _minute=0, _second=0, _ms=0):
	reset(_hour,_minute,_second,_ms)


func reset(_hour:int, _minute:int, _second:int, _ms=0):
	hour = _hour
	minute = _minute
	second = _second
	ms = _ms



static func current():
	var dt = OS.get_time()
	#GD4
#	return XTime.new(dt["hour"], dt["minute"], dt["second"],OS.get_system_time_msecs()%1000)
	return XTime.new(dt["hour"], dt["minute"], dt["second"],int(OS.get_unix_time()*1000)%1000)


func format(fmt = "hh:mm:ss"):
	if "hh".is_subsequence_of(fmt):
		fmt = fmt.replace("hh",str(hour).pad_zeros(2))
	if "mm".is_subsequence_of(fmt):
		fmt = fmt.replace("mm",str(minute).pad_zeros(2))
	if "ss".is_subsequence_of(fmt):
		fmt = fmt.replace("ss",str(second).pad_zeros(2))
	if "zzz".is_subsequence_of(fmt):
		fmt = fmt.replace("zzz",str(ms).pad_zeros(3))
	return fmt


func _to_string():
	return format()

func total_seconds():
	return hour*SECONDS_PER_HOUR + minute*SECONDS_PER_MINUTE + second

func from_total_seconds(seconds:int):
	hour = int(seconds / SECONDS_PER_HOUR)
	seconds -= hour * SECONDS_PER_HOUR
	minute = int(seconds / SECONDS_PER_MINUTE)
	seconds -= minute * SECONDS_PER_MINUTE
	second = seconds

func total_ms():
	return total_seconds()*1000+ms

func seconds_to(other: XTime)->int:
	return other.total_seconds()-total_seconds()

func ms_to(other: XTime)->int:
	return other.total_ms()-total_ms()

func elapsed_seconds():
	var cur_time = get_script().new()
	cur_time.reset()
	return seconds_to(cur_time)

func elapsed_ms():
	var cur_time = XTime.current()
	return ms_to(cur_time)

func add_seconds(seconds:int):
	from_total_seconds(total_seconds()+seconds)

func stamp()->int:
	return total_ms()

func is_equal_to(other:XTime)->bool:
	return total_ms()==other.total_ms()


func save():
	return {
		"hour":hour,
		"minute":minute,
		"second":second
	}


func restore(json):
	if typeof(json) != TYPE_DICTIONARY:
		return
	hour = int(json.get("hour",hour))
	minute = int(json.get("minute",minute))
	second = int(json.get("second",second))



static func compare(t1:XTime, t2:XTime):
	return XGlobal.compare_array([t1.hour,t1.minute,t1.second,t1.ms],
		[t2.hour,t2.minute,t2.second,t2.ms])
