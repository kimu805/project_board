class Project < ApplicationRecord
  belongs_to :user

  enum :work_style, { full_onsite: 0, remote_1day: 1, remote_2days: 2, remote_3days: 3, remote_4days: 4, full_remote: 5 }, validate: true
  enum :status, { upcoming: 0, active: 1, completed: 2 }, validate: true
  enum :role, { member: 0, leader: 1 }, validate: true

  validates :name, presence: true
  validates :client_name, presence: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :work_style, presence: true
  validates :start_date, presence: true
  validates :status, presence: true
  validates :role, presence: true

  ROLE_RATE = { "member" => 0.65, "leader" => 0.70 }.freeze

  def monthly_salary
    return nil if unit_price.blank?
    (unit_price * ROLE_RATE[role]).round
  end

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

  def self.filter_by(filters)
    all
      .search_by_keyword(filters[:keyword])
      .filter_by_status(filters[:status])
      .filter_by_work_style(filters[:work_style])
      .filter_by_unit_price(min_price: filters[:min_price], max_price: filters[:max_price])
  end

  def tech_stack_list
    tech_stack.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
