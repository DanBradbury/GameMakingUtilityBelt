require 'chunky_png'

class PNGColorReplacer
  def initialize(file_path)
    @file_path = file_path
    @image = ChunkyPNG::Image.from_file(file_path)
    @replacements = 0
  end

  def replace_colors(old_colors, new_colors)
    unless old_colors.length == new_colors.length
      raise ArgumentError, "Number of old colors (#{old_colors.length}) must match number of new colors (#{new_colors.length})"
    end

    # Convert hex colors to ChunkyPNG pixel format
    color_map = {}
    old_colors.each_with_index do |old_hex, index|
      old_pixel = hex_to_pixel(old_hex)
      new_pixel = hex_to_pixel(new_colors[index])
      color_map[old_pixel] = new_pixel
    end

    puts "Color replacements to be made:"
    color_map.each do |old_pixel, new_pixel|
      old_hex = pixel_to_hex(old_pixel)
      new_hex = pixel_to_hex(new_pixel)
      puts "  #{old_hex} → #{new_hex}"
    end
    puts

    # Create a copy of the image for modification
    new_image = @image.dup

    # Replace colors pixel by pixel
    @image.height.times do |y|
      @image.width.times do |x|
        current_pixel = @image[x, y]

        if color_map.key?(current_pixel)
          new_image[x, y] = color_map[current_pixel]
          @replacements += 1
        end
      end
    end

    @new_image = new_image
  end

  def save_image
    # Generate output filename
    file_extension = File.extname(@file_path)
    file_basename = File.basename(@file_path, file_extension)
    file_directory = File.dirname(@file_path)

    output_filename = File.join(file_directory, "#{file_basename}_color_change#{file_extension}")

    @new_image.save(output_filename)

    puts "Image saved as: #{output_filename}"
    puts "Total pixels replaced: #{@replacements}"

    output_filename
  end

  def preview_changes(old_colors, new_colors)
    # Count how many pixels of each target color exist
    color_counts = Hash.new(0)

    old_colors.each do |hex_color|
      pixel = hex_to_pixel(hex_color)

      @image.height.times do |y|
        @image.width.times do |x|
          color_counts[pixel] += 1 if @image[x, y] == pixel
        end
      end
    end

    puts "Preview of changes:"
    puts "-" * 50

    old_colors.each_with_index do |old_hex, index|
      old_pixel = hex_to_pixel(old_hex)
      count = color_counts[old_pixel]
      percentage = count > 0 ? (count.to_f / total_pixels * 100).round(2) : 0

      puts "#{old_hex} → #{new_colors[index]}: #{count} pixels (#{percentage}%)"
    end
    puts
  end

  private

  def hex_to_pixel(hex_color)
    # Remove # if present
    hex_color = hex_color.gsub('#', '')

    # Handle 3-digit hex (expand to 6-digit)
    if hex_color.length == 3
      hex_color = hex_color.chars.map { |c| c + c }.join
    end

    unless hex_color.length == 6
      raise ArgumentError, "Invalid hex color format: ##{hex_color}. Expected format: #RRGGBB or #RGB"
    end

    r = hex_color[0..1].to_i(16)
    g = hex_color[2..3].to_i(16)
    b = hex_color[4..5].to_i(16)
    a = 255  # Full opacity by default

    ChunkyPNG::Color.rgba(r, g, b, a)
  end

  def pixel_to_hex(pixel)
    r = (pixel >> 24) & 0xff
    g = (pixel >> 16) & 0xff
    b = (pixel >> 8) & 0xff

    "#%02x%02x%02x" % [r, g, b]
  end

  def total_pixels
    @image.width * @image.height
  end
end

def parse_color_list(color_string)
  colors = color_string.split(',').map(&:strip)

  # Validate each color
  colors.each do |color|
    color = color.gsub('#', '')
    unless color.match?(/^[0-9a-fA-F]{3}$/) || color.match?(/^[0-9a-fA-F]{6}$/)
      raise ArgumentError, "Invalid hex color: #{color}. Use format #RRGGBB or #RGB"
    end
  end

  # Ensure colors start with #
  colors.map { |color| color.start_with?('#') ? color : "##{color}" }
end

# Main execution
if __FILE__ == $0
  if ARGV.length < 3
    puts "Usage: #{$0} <png_file> <old_colors> <new_colors> [options]"
    puts
    puts "Arguments:"
    puts "  png_file    Path to the PNG file"
    puts "  old_colors  Comma-separated list of hex colors to replace (e.g., '#ff0000,#00ff00')"
    puts "  new_colors  Comma-separated list of hex colors to replace with (e.g., '#0000ff,#ffff00')"
    puts
    puts "Options:"
    puts "  --preview   Show preview of changes without saving"
    puts
    puts "Color formats supported:"
    puts "  #RRGGBB (e.g., #ff0000 for red)"
    puts "  #RGB (e.g., #f00 for red)"
    puts "  RRGGBB (without # prefix)"
    puts "  RGB (without # prefix)"
    puts
    puts "Examples:"
    puts "  #{$0} image.png '#ff0000' '#0000ff'"
    puts "  #{$0} image.png 'ff0000,00ff00' '0000ff,ffff00'"
    puts "  #{$0} image.png '#f00,#0f0,#00f' '#000,#fff,#888' --preview"
    exit
  end

  file_path = ARGV[0]
  old_colors_str = ARGV[1]
  new_colors_str = ARGV[2]
  preview_only = ARGV.include?('--preview')

  # Validate file exists
  unless File.exist?(file_path)
    puts "Error: File '#{file_path}' not found!"
    exit 1
  end

  begin
    # Parse color lists
    old_colors = parse_color_list(old_colors_str)
    new_colors = parse_color_list(new_colors_str)

    puts "Processing PNG: #{file_path}"
    puts "Image dimensions: Loading..."

    replacer = PNGColorReplacer.new(file_path)
    puts "Image dimensions: #{replacer.instance_variable_get(:@image).width}x#{replacer.instance_variable_get(:@image).height}"
    puts

    # Show preview
    replacer.preview_changes(old_colors, new_colors)

    if preview_only
      puts "Preview mode - no changes saved."
    else
      # Perform the replacement
      puts "Performing color replacement..."
      replacer.replace_colors(old_colors, new_colors)

      # Save the modified image
      output_file = replacer.save_image
      puts
      puts "✓ Color replacement completed successfully!"
      puts "Original file: #{file_path}"
      puts "New file: #{output_file}"
    end

  rescue ChunkyPNG::Exception => e
    puts "Error reading PNG file: #{e.message}"
    exit 1
  rescue ArgumentError => e
    puts "Error: #{e.message}"
    exit 1
  rescue => e
    puts "Unexpected error: #{e.message}"
    puts "Backtrace: #{e.backtrace.join("\n")}"
    exit 1
  end
end
