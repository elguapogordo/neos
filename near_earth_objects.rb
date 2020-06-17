require 'faraday'
require 'figaro'
require 'pry'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects
  def self.find_neos_by_date(date)
    parsed_asteroids_data = asteroids_list_data(date)
    {
      asteroid_list: formatted_asteroid_data(parsed_asteroids_data),
      biggest_asteroid: largest_asteroid_diameter(parsed_asteroids_data),
      total_number_of_asteroids: parsed_asteroids_data.count
    }
  end

  def self.formatted_asteroid_data(parsed_asteroids_data)
    parsed_asteroids_data.map do |asteroid|
      binding.pry
      {
        name: asteroid[:name],
        diameter: "#{asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
        miss_distance: "#{asteroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
      }
    end
  end

  def self.largest_asteroid_diameter(parsed_asteroids_data)
    parsed_asteroids_data.map do |asteroid|
      asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
  end

  def self.asteroids_list_data(date)
    response = conn.get('neo/rest/v1/feed') { |c| c.params[:start_date] = date }
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.conn
    Faraday.new('https://api.nasa.gov') do |f|
      f.params[:api_key] = ENV['nasa_api_key']
    end
  end
end
