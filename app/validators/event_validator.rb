class EventValidator < ActiveModel::Validator
  def validate(event)
    validates_starts_and_ends_the_same_day(event)
    validates_ends_after_the_start(event)
    validates_appointment_has_open_slots(event) if event.kind == Event.kinds[:appointment]
    validates_whole_number_of_slots(event)
  end

  private

    def validates_starts_and_ends_the_same_day(event)
      unless event.starts_at.to_date == event.ends_at.to_date
        event.errors[:ends_at] << "must be the same day as starts_at"
      end
    end

    def validates_ends_after_the_start(event)
      if event.ends_at <= event.starts_at
        event.errors[:ends_at] << "must be after starts_at"
      end
    end

    def validates_appointment_has_open_slots(appointment)
      availabilities = Event.availabilities(appointment.starts_at.to_date)
      already_booked_slots = appointment.extract_slots - availabilities[0][:slots]

      if already_booked_slots.present?
        appointment.errors[:starts_at] << "there are no open slot in that period"
      end
    end

    def validates_whole_number_of_slots(event)
      difference_in_minutes = (event.ends_at - event.starts_at) / ENV['NUMBER_OF_SECONDS_IN_A_MINUTE'].to_i

      unless difference_in_minutes % 30 == 0
        event.errors[:ends_at] << "must have a whole number of slots in the event"
      end
    end
end