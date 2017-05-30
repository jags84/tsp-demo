require 'thread'

class City
  attr_reader :cities,:quantity
  RAD_PER_DEG = Math::PI/180 # PI / 180
  RKM = 6371 # Earth radius in kilometers
  RM = RKM * 1000 # Radius in meters

  def initialize
    @cities = []
    @quantity = 0
    read_file
  end

  # Read File
  def read_file
    File.open("cities.txt", "r") do |f|
      f.each_line do |line|
        city = Hash.new(0)
        city[:name] = line.split("\t")[0]
        city[:lat] = line.split("\t")[1].to_f
        city[:lon] = line.split("\t")[2].delete("\n").to_f
        @cities.push city
        @quantity += 1
      end
    end
  end

  #calculate distances
  def self.distance(city_1,city_2)
    dlat_rad = (city_2[:lat] - city_1[:lat]) * RAD_PER_DEG  # Delta, converted to rad
    dlon_rad = (city_2[:lon] - city_1[:lon]) * RAD_PER_DEG
    lat1_rad = city_1[:lat] * RAD_PER_DEG
    lon1_rad = city_1[:lon] * RAD_PER_DEG
    lat2_rad = city_2[:lat] * RAD_PER_DEG
    lon2_rad = city_2[:lon] * RAD_PER_DEG

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    RM * c # Delta in meters
  end

  def get_city_name position
    @cities[position][:name]
  end
end

class Tsp
    def initialize
    # Array of visited cities
    @cost = []
    # Import Cities
    @c = City.new()
    # Build Flight Plan
    flight_plan
  end

  def flight_plan
    cities = (0..@c.quantity-1).to_a
    combinations = cities.permutation(@c.quantity).select{|k| k.first == 0}
    combinations.each do |line|
      calculate_cost line
    end
    cost = @cost.map{|k|k[:cost]}.min
    line = @cost.select{|k| k[:cost] == cost }.first[:line]
    line.each do |city_index|
      puts @c.get_city_name city_index
    end
  end

  def calculate_cost line
    distance = 0
    (0..@c.quantity-2).to_a.each do |index|
      distance = distance + City.distance(@c.cities[line[index]], @c.cities[line[index+1]])
    end
    @cost.push({line: line, cost: distance})
  end
end

# Start Flight Planner
Tsp.new
