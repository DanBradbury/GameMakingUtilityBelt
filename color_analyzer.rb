#!/usr/bin/env ruby

require 'chunky_png'

class PNGColorAnalyzer
  def initialize(file_path)
    @file_path = file_path
    @image = ChunkyPNG::Image.from_file(file_path)
    @colors = Hash.new(0)
  end

  def analyze
    puts "Analyzing PNG: #{@file_path}"
    puts "Dimensions: #{@image.width}x#{@image.height}"
    puts "Total pixels: #{@image.width * @image.height}"
    puts "-" * 50

    # Iterate through each pixel and count colors
    @image.height.times do |y|
      @image.width.times do |x|
        pixel = @image[x, y]
        @colors[pixel] += 1
      end
    end

    puts "Found #{@colors.size} unique colors"
    puts
  end

  def print_color_summary(limit = 10)
    puts "Top #{limit} most common colors:"
    puts "-" * 50

    sorted_colors = @colors.sort_by { |color, count| -count }

    sorted_colors.first(limit).each_with_index do |(color, count), index|
      r, g, b, a = extract_rgba(color)
      percentage = (count.to_f / total_pixels * 100).round(2)
      hex_color = "#%02x%02x%02x" % [r, g, b]

      puts "#{index + 1}. #{hex_color} (RGBA: #{r},#{g},#{b},#{a}) - #{count} pixels (#{percentage}%)"
    end
  end

  def print_all_colors
    puts "All colors found:"
    puts "-" * 50

    sorted_colors = @colors.sort_by { |color, count| -count }

    sorted_colors.each_with_index do |(color, count), index|
      r, g, b, a = extract_rgba(color)
      percentage = (count.to_f / total_pixels * 100).round(2)
      hex_color = "#%02x%02x%02x" % [r, g, b]

      puts "#{index + 1}. #{hex_color} (RGBA: #{r},#{g},#{b},#{a}) - #{count} pixels (#{percentage}%)"
    end
  end

  def export_colors_to_csv(filename = "colors.csv")
    require 'csv'

    CSV.open(filename, 'w') do |csv|
      csv << ['Rank', 'Hex', 'Red', 'Green', 'Blue', 'Alpha', 'Pixel Count', 'Percentage']

      sorted_colors = @colors.sort_by { |color, count| -count }

      sorted_colors.each_with_index do |(color, count), index|
        r, g, b, a = extract_rgba(color)
        percentage = (count.to_f / total_pixels * 100).round(2)
        hex_color = "#%02x%02x%02x" % [r, g, b]

        csv << [index + 1, hex_color, r, g, b, a, count, percentage]
      end
    end

    puts "Colors exported to #{filename}"
  end

  def get_color_palette(max_colors = nil)
    sorted_colors = @colors.sort_by { |color, count| -count }
    colors = max_colors ? sorted_colors.first(max_colors) : sorted_colors

    colors.map do |color, count|
      r, g, b, a = extract_rgba(color)
      {
        hex: "#%02x%02x%02x" % [r, g, b],
        rgba: { r: r, g: g, b: b, a: a },
        count: count,
        percentage: (count.to_f / total_pixels * 100).round(2)
      }
    end
  end

  def has_transparency?
    @colors.any? { |color, _| extract_rgba(color)[3] < 255 }
  end

  def color_stats
    {
      total_colors: @colors.size,
      total_pixels: total_pixels,
      has_transparency: has_transparency?,
      most_common_color: get_most_common_color,
      least_common_colors: get_least_common_colors
    }
  end

  private

  def extract_rgba(pixel)
    [
      (pixel >> 24) & 0xff,  # Red
      (pixel >> 16) & 0xff,  # Green
      (pixel >> 8) & 0xff,   # Blue
      pixel & 0xff           # Alpha
    ]
  end

  def total_pixels
    @image.width * @image.height
  end

  def get_most_common_color
    return nil if @colors.empty?

    most_common = @colors.max_by { |color, count| count }
    color, count = most_common
    r, g, b, a = extract_rgba(color)

    {
      hex: "#%02x%02x%02x" % [r, g, b],
      rgba: { r: r, g: g, b: b, a: a },
      count: count,
      percentage: (count.to_f / total_pixels * 100).round(2)
    }
  end

  def get_least_common_colors(limit = 5)
    sorted_colors = @colors.sort_by { |color, count| count }

    sorted_colors.first(limit).map do |color, count|
      r, g, b, a = extract_rgba(color)
      {
        hex: "#%02x%02x%02x" % [r, g, b],
        rgba: { r: r, g: g, b: b, a: a },
        count: count,
        percentage: (count.to_f / total_pixels * 100).round(2)
      }
    end
  end
end

# Main execution
if __FILE__ == $0
  if ARGV.length == 0
    puts "Usage: #{$0} <png_file_path> [options]"
    puts "Options:"
    puts "  --all          Show all colors (default: top 10)"
    puts "  --csv          Export colors to CSV file"
    puts "  --limit N      Show top N colors (default: 10)"
    puts "  --stats        Show detailed statistics"
    exit
  end

  file_path = ARGV[0]

  unless File.exist?(file_path)
    puts "Error: File '#{file_path}' not found!"
    exit 1
  end

  begin
    analyzer = PNGColorAnalyzer.new(file_path)
    analyzer.analyze

    # Parse options
    show_all = ARGV.include?('--all')
    export_csv = ARGV.include?('--csv')
    show_stats = ARGV.include?('--stats')

    limit = 10
    if limit_index = ARGV.index('--limit')
      limit = ARGV[limit_index + 1].to_i if ARGV[limit_index + 1]
    end

    if show_all
      analyzer.print_all_colors
    else
      analyzer.print_color_summary(limit)
    end

    if show_stats
      puts "\nDetailed Statistics:"
      puts "-" * 50
      stats = analyzer.color_stats
      puts "Total unique colors: #{stats[:total_colors]}"
      puts "Total pixels: #{stats[:total_pixels]}"
      puts "Has transparency: #{stats[:has_transparency]}"

      most_common = stats[:most_common_color]
      if most_common
        puts "Most common color: #{most_common[:hex]} (#{most_common[:count]} pixels, #{most_common[:percentage]}%)"
      end
    end

    analyzer.export_colors_to_csv if export_csv

  rescue ChunkyPNG::Exception => e
    puts "Error reading PNG file: #{e.message}"
    exit 1
  rescue => e
    puts "Unexpected error: #{e.message}"
    exit 1
  end
end
