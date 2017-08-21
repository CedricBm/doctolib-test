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

  test "second simple test" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2017-08-21 09:30"), ends_at: DateTime.parse("2017-08-21 12:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-08-21 10:30"), ends_at: DateTime.parse("2017-08-21 11:30")

    availabilities = Event.availabilities DateTime.parse("2017-08-21")
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[0][:slots]
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

  test "can't have an appointment if no open slots" do
    assert_raise ActiveRecord::RecordInvalid do
      Event.create! kind: 'appointment', starts_at: DateTime.parse("2017-08-17 13:30"), ends_at: DateTime.parse("2017-08-17 14:00")
    end
  end

  test "the number of slots in an event is whole" do
    assert_raise ActiveRecord::RecordInvalid do
      starts_at = DateTime.parse("2014-08-04 14:30")
      ends_at = starts_at + (ENV['SLOT_DURATION'].to_i * 1.5).minutes

      Event.create! kind: 'opening', starts_at: starts_at, ends_at: ends_at
    end
  end

end
