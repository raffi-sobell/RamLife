from my_stuff.misc import init
from time_ import Range

class PeriodData: 
	@init
	def __init__(
		self, 
		room: str,
		id: int
	): pass

class Period: 
	@init
	def __init__(
		self, 
		data: PeriodData,
		time: Range, 
		period: str,
	): 
		self.room = data.room
		self.id = data.id

class Schedule: 
	@init 
	def __init__(self, periods: [Period]): pass
