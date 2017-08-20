require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["09:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "kind attribute has a correct value" do
    assert_raise ArgumentError do
      Event.create kind: 'booked', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    end
  end

  test "kind, starts_at and ends_at attributes are present" do
    assert_raise ActiveRecord::RecordInvalid do
      Event.create! starts_at: DateTime.parse("2017-08-17 09:30"), ends_at: DateTime.parse("2017-08-17 12:30")
    end

    assert_raise ActiveRecord::RecordInvalid do
      Event.create! kind: 'opening', ends_at: DateTime.parse("2017-08-17 12:30")
    end

    assert_raise ActiveRecord::RecordInvalid do
      Event.create! kind: 'opening', starts_at: DateTime.parse("2017-08-17 09:30")
    end
  end

  test "starts_at and ends_at are the same day" do
    assert_raise ActiveRecord::RecordInvalid do
      Event.create! kind: 'opening', starts_at: DateTime.parse("2017-08-17 09:30"), ends_at: DateTime.parse("2017-08-18 12:30")
    end
  end

  test "ends_at is after starts_at" do
    assert_raise ActiveRecord::RecordInvalid do
      Event.create! kind: 'opening', starts_at: DateTime.parse("2017-08-17 09:30"), ends_at: DateTime.parse("2017-08-17 09:00")
    end
  end

end
