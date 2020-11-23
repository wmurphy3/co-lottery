class User < ApplicationRecord
  attr_accessor :first_name, :last_name, :prize_id, :remember_me

  has_many :user_prizes
  has_many :prizes, through: :user_prizes

  before_validation :set_name
  after_save :create_user_prize

  validate :validates_prize
  validate :validates_user_prize
  validate :validates_email
  validates :name, :email, :phone, :address, :presence => true

  private

  def set_name
    self.name = "#{first_name} #{last_name}"
  end

  def create_user_prize
    prize = UserPrize.create({
      user_id:  self.id,
      prize_id: prize_id
    })
    puts "prize: #{prize.errors.messages}"
  end

  def validates_user_prize
    return if self.id.blank?

    if UserPrize.where("user_id = ? AND created_at >= #{DateTime.now.beginning_of_day} AND created <= #{DateTime.now.end_of_day}", self.id)
      errors.add(:prize, "already selected today.")
    end
  end

  def validates_prize
    if prize_id.blank?
      errors.add(:prize, "not selected.")
    end
  end

  def validates_email
    if User.find_by(email: self.email)
      errors.add(:email, "already entered. Try logging in.")
    end
  end

end