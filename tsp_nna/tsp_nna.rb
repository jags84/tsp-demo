class City
  attr_reader :cities,:quantity
  RAD_PER_DEG = Math::PI/180 # PI / 180
  RKM = 6371 # Earth radius in kilometers

  def initialize
    @cities = []
    @quantity = 0
    # Read Cities File
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

  #calculate distances using Haversine Formula
  def self.distance(city_1,city_2)
    dlat_rad = (city_2[:lat] - city_1[:lat]) * RAD_PER_DEG  # Delta, converted to rad
    dlon_rad = (city_2[:lon] - city_1[:lon]) * RAD_PER_DEG  # Delta, converted to rad
    lat1_rad = city_1[:lat] * RAD_PER_DEG
    lon1_rad = city_1[:lon] * RAD_PER_DEG
    lat2_rad = city_2[:lat] * RAD_PER_DEG
    lon2_rad = city_2[:lon] * RAD_PER_DEG

    a = Math.sin(dlat_rad/2)**2 + (Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2)
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    RKM * c # Delta in meters
  end

  # Get city name
  def get_city_name position
    @cities[position][:name]
  end
end

class Graph
  attr_reader :graph
  def initialize
    @graph = []
  end

  # Build Graph Matrix with Distances
  def build_graph(cities)
    cities.each do |c1|
      line = []
      cities.each do |c2|
        line.push (City.distance(c1,c2))
      end
      @graph.push line
    end
  end
end

class Tsp
  def initialize
    # Array of visited cities
    @visited_cities = []
    # Import Cities
    @c = City.new()
    # Create Graph
    g = Graph.new()
    g.build_graph(@c.cities)
    # Build Flight Plan
    flight_plan(g.graph)
  end

  # Build Flight Plan
  def flight_plan(graph,start_city = 0)
    @visited_cities.push 0
    graph.length.times do
      latest_city = @visited_cities.last
      near_city latest_city, graph[latest_city]
    end
    @visited_cities.each do |city_index|
      puts @c.get_city_name city_index
    end
  end

  # Near City
  def near_city (current_city, cities)
    city_position = 1 #position 0 have value of 0
    begin
      near = cities.sort[city_position] #position 0 have value of 0
      position = cities.find_index(near) #Find position of city inside array
      city_position += 1
    end while @visited_cities.include?(position)
    @visited_cities.push position unless position.nil?
  end
end

# Initialize TSP
Tsp.new()
