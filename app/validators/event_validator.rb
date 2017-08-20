class EventValidator < ActiveModel::Validator
  def validate(event)
    validates_starts_and_ends_the_same_day(event)
    validates_ends_after_the_start(event)
    validates_appointment_has_open_slots(event) if event.kind == Event.kinds[:appointment]
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
      availability = Event::Availability.new(appointment.starts_at.to_date, Event.compute_events_by_kind)
      already_booked_slots = appointment.extract_slots - availability.slots

      if already_booked_slots.present?
        appointment.errors[:starts_at] << "one or all slots are already booked in that period"
      end
    end
end