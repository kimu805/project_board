class Project < ApplicationRecord
  enum :work_style, { full_onsite: 0, remote_1day: 1, remote_2days: 2, remote_3days: 3, remote_4days: 4, full_remote: 5 }, validate: true
  enum :status, { upcoming: 0, active: 1, completed: 2 }, validate: true

  validates :name, presence: true
  validates :client_name, presence: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :work_style, presence: true
  validates :start_date, presence: true
  validates :status, presence: true
end
