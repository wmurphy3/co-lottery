class User < ApplicationRecord
  attr_accessor :first_name, :last_name, :prize_id

  has_many :user_prizes
  has_many :prizes, through: :user_prizes

  before_validation :set_name
  after_create :create_user_prize

  validate :validates_prize
  validate :validates_email
  validates :name, :email, :phone, :address, :presence => true

  private

  def set_name
    self.name = "#{first_name} #{last_name}"
  end

  def create_user_prize
    UserPrize.create({
      user_id:  self.id,
      prize_id: self.prize_id
    })
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