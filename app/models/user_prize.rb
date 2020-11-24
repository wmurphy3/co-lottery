class UserPrize < ApplicationRecord
  belongs_to :prize
  belongs_to :user, optional: true

  attr_accessor :email

  validates :prize_id, :presence => true
  validate :validates_user
  validate :validates_user_prize

  before_validation :set_user_id

  private

  def validates_user
    return true if email.blank?
    unless User.where(email: email).exists?
      errors.add(:email, "doesn't exist")
    end
  end

  def set_user_id
    if user_id.blank?
      user_id = User.find_by(email: email).try(:id)
      self.user_id = user_id
    end
  end

  def validates_user_prize
    return true if self.user_id.blank?

    if UserPrize.where(user_id: self.user_id)
      .where("created_at >= '#{DateTime.now.beginning_of_day}' AND created_at <= '#{DateTime.now.end_of_day}'").exists?
      errors.add(:prize, "already selected today.")
    end
  end
end