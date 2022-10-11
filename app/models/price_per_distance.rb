class PricePerDistance < ApplicationRecord
  belongs_to :mode_of_transport
  validates_with ValidateMinimumDistance
  validates_with ValidateMaximumDistance
  validates :minimum_distance, :maximum_distance, presence: true
  validates :rate, comparison: { greater_than_or_equal_to: 0 }

  def ==(other)
    "#{self.minimum_distance}"  == "#{other[:minimum_distance]}" && 
    "#{self.maximum_distance}"  == "#{other[:maximum_distance]}" && 
    "#{self.rate}"  == "#{other[:rate]}"
  end
end
