# Calculate aggregate information from data
require "csv"

module RvgGraph
  class Agg
    attr_accessor :maxval, :minval, :count, :capture_min, :capture_max
    include GraphHelpers
    
    def initialize(data, name, no_data_value)
      name = name.split(",").first
      date ||= data["date"]
      self.capture_max = data["date"][-1]
      self.capture_min = data["date"][0]

      cnt = 0
      data[name].each_with_index do |value, index|
        unless check_no_data(value, no_data_value)
          self.maxval = value if self.maxval.nil? || value > self.maxval
          self.minval = value if self.minval.nil? || value < self.minval
          cnt = index
        end
      end
      self.count = cnt
    end
  end
end
