# to have a datetime with timezone you should use a library called 'pytz'.

from datetime import datetime
import pytz

berlin_timezone = pytz.timezone('Europe/Berlin')
tehran_timezone = pytz.timezone('Asia/Tehran')

# getting the current datetime with timezone.
now_with_timezone = datetime.now(tz=berlin_timezone)

# creating a datetime with timezone.
# it will give you the exact same datetime (with the same time) but with timezone added to it.
my_berlin_datetime = datetime(year=2020, month=2, day=3, hour=14, minute=20, second=10)
my_berlin_datetime_with_timezone = berlin_timezone.localize(my_berlin_datetime)

# converting a datetime with timezone to another timezone.
# it wil give you the same moment but in tehran timezone.
my_tehran_datetime_with_timezone = tehran_timezone.normalize(my_berlin_datetime_with_timezone)

# you can also use this approach to convert a datetime with timezone to a different timezone.
# this does not need 'pytz' but is not recommended.

my_tehran_datetime_with_timezone_2 = my_berlin_datetime_with_timezone.astimezone(tehran_timezone)

# IMPORTANT NOTE 1:
# never use this approach to create a datetime with timezone:

# it will create a datetime with timezone which has an incorrect UTC offset.
my_wrong_berlin_datetime_with_timezone = datetime(year=2020, month=2, day=3,
                                                  hour=14, minute=20, second=10,
                                                  tzinfo=berlin_timezone)

# IMPORTANT NOTE 2:
# there are differences between the three methods which have been used above:

# pytz.localize:
# this method should be called on a 'pytz.timezone' instance and provided with a naive
# datetime as an input. it will get the same datetime but with timezone added to it.

# pytz.normalize:
# this method should be called on a 'pytz.timezone' instance and provided with a timezone
# aware datetime as an input. it will get the same moment but in different timezone.

# datetime.astimezone:
# this method should be called on a 'datetime' instance and provided with destination timezone
# as an input. it will return the same moment but in destination timezone. this method is
# actually similar to 'pytz.normalize' but it can work with both naive and timezone
# aware date times. if the datetime is naive, it will implicitly consider its timezone
# the same as local system timezone.
