class EventValidator < ActiveModel::Validator
  def validate(record)
    validates_starts_and_ends_the_same_day(record)
    validates_ends_after_the_start(record)
  end

  private

    def validates_starts_and_ends_the_same_day(record)
      unless record.starts_at.to_date == record.ends_at.to_date
        record.errors[:ends_at] << "must be the same day as starts_at"
      end
    end

    def validates_ends_after_the_start(record)
      if record.ends_at <= record.starts_at
        record.errors[:ends_at] << "must be after starts_at"
      end
    end
end