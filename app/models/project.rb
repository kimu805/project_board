class Project < ApplicationRecord
  belongs_to :user

  enum :work_style, { full_onsite: 0, remote_1day: 1, remote_2days: 2, remote_3days: 3, remote_4days: 4, full_remote: 5 }, validate: true
  enum :status, { upcoming: 0, active: 1, completed: 2 }, validate: true

  validates :name, presence: true
  validates :client_name, presence: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :work_style, presence: true
  validates :start_date, presence: true
  validates :status, presence: true

  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("name LIKE ? OR client_name LIKE ?", "%#{keyword}%", "%#{keyword}%")
  }

  scope :filter_by_status, ->(status) {
    return all if status.blank?
    where(status: status)
  }

  scope :filter_by_work_style, ->(work_style) {
    return all if work_style.blank?
    where(work_style: work_style)
  }

  scope :filter_by_unit_price, ->(min_price:, max_price:) {
    result = all
    result = result.where("unit_price >= ?", min_price) if min_price.present?
    result = result.where("unit_price <= ?", max_price) if max_price.present?
    result
  }
end
