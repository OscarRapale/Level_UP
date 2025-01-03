class User < ApplicationRecord
  # Include Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  # Associations
  has_many :habit_lists, dependent: :destroy
  has_many :custom_habits, dependent: :destroy

  # Default values for attributes
  after_initialize :set_defaults

  # Method to initialize default values
  def set_defaults
    self.is_admin ||= false
    self.level ||= 1
    self.current_xp ||= 0
    self.xp_to_next_level ||= 100
    self.habits_completed ||= 0
    self.max_hp ||= 50
    self.hp ||= 50
    self.strength ||= 5
    self.vitality ||= 5
    self.dexterity ||= 3
    self.intelligence ||= 3
    self.luck ||= 1
    self.streak ||= 0
    self.total_login_count ||= 0
    self.last_login ||= Time.current
  end

  # Custom methods for XP, leveling, and streak management
  def gain_xp(amount)
    self.current_xp += amount
    self.habits_completed += 1
    check_level_up
    save!
  end

  def check_level_up
    while current_xp >= xp_to_next_level
      level_up
    end
  end

  def level_up
    self.level += 1
    self.current_xp -= xp_to_next_level
    self.max_hp += 10
    self.strength += 5
    self.vitality += 4
    self.dexterity += 3
    self.intelligence += 2
    self.luck += 1
    self.xp_to_next_level = calculate_xp_to_next_level
    save!
  end

  def calculate_xp_to_next_level
    100 + (level - 1) * 50
  end

  def recover_hp(points = 15)
    self.hp = [hp + points, max_hp].min
    save!
  end

  def lose_hp(points = 25)
    self.hp = [hp - points, 0].max
    save!
  end

  def check_daily_streak
    today = Date.current
    if last_login.to_date == today - 1
      self.streak += 1
    elsif last_login.to_date < today - 1
      self.streak = 1
    end
    self.last_login = Time.current
    self.total_login_count += 1
    save!
  end
end
