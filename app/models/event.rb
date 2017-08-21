class Event < ActiveRecord::Base
  enum kind: {opening: "opening", appointment: "appointment"}

  validates :kind, :starts_at, :ends_at, presence: true
  validates_with EventValidator, if: Proc.new {|e| e.kind.present? && e.starts_at.present? && e.ends_at.present?}

  class Availability
    attr_accessor :date, :slots

    def initialize(date, events_by_kind)
      @date = date
      @slots = compute_slots(events_by_kind)
    end

    def to_hash
      {date: @date, slots: @slots}
    end

    private

      def compute_slots(events_by_kind)
        booked_slots = extract_slots_of_events(events_by_kind[Event.kinds[:appointment]])
        open_slots = extract_slots_of_events(events_by_kind[Event.kinds[:opening]])

        open_slots - booked_slots
      end

      def extract_slots_of_events(events)
        slots = []

        events&.each do |event|
          slots += event.extract_slots if event.is_date_corresponding?(@date)
        end

        slots
      end

  end

  def self.availabilities(begin_date)
    availabilities = []
    events_by_kind = compute_events_by_kind

    # for the next 7 days beginning at the begin_date
    (0..6).each do |offset|
      availabilities << Availability.new(begin_date.to_date + offset.days, events_by_kind)
    end

    availabilities.map(&:to_hash)
  end

  # I'll assume that an event starts and ends the same day
  def is_date_corresponding?(date)
    if self.starts_at.to_date == date
      true
    elsif self.kind == Event.kinds[:opening] && self.weekly_recurring
      days_count_between_dates = self.starts_at.to_date.upto(date).count
      days_count_between_dates % ENV['DAYS_IN_WEEK'].to_i == 1 # the recurring event reoccurs at the same day
    else
      false
    end
  end

  def extract_slots
    slots = []
    begin_time = self.starts_at

    while begin_time < self.ends_at do
      slots << begin_time.strftime('%-H:%M')
      begin_time += ENV['SLOT_DURATION'].to_i.minutes
    end

    slots
  end

  # We could fetch only the relevant events that match the following assertions :
  # 1) if an event is an opening and it is weekly recurrent.
  # 2) if an event is an opening and it is not weekly recurrent but the slots are in the week period requested.
  # 3) if an event is an appointment and the slots are in the week period requested.
  # But that would be overengineering and would be necessary only if there are a lot of data.
  def self.compute_events_by_kind
    Event.order(starts_at: :asc).group_by(&:kind)
  end

end
