## Technical Test @ Doctolib

The goal is to write an algorithm that checks the availabilities of an agenda depending of the events attached to it.
The main method has a start date for input and is looking for the availabilities of the next 7 days.

They are two kinds of events:

 - 'opening', are the openings for a specific day and they can be reccuring week by week.
 - 'appointment', times when the doctor is already booked.

To init the project:

``` sh
rails new doctolib-test
rails g model event starts_at:datetime ends_at:datetime kind:string weekly_recurring:boolean
```

The mission :
 - in rails 4.2
 - sqlite compatible
 - to make the following unit test pass
 - to add tests for the edge cases

``` ruby
# test/models/event_test.rb

require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

end
```

Exemple de retour :

``` ruby
[{"date":"2014/08/04","slots":["12:00","13:30"]},{"date":"2014/08/05","slots":["09:00", "09:30"]},
{"date":"2014/08/06","slots":[]},{"date":"2014/08/07","slots":["15:30","16:30","17:00"]},
{"date":"2014/08/08","slots":[]},{"date":"2014/08/09","slots":["14:00", "14:30"],"substitution":null},
{"date":"2015/08/10","slots":[]}]
```