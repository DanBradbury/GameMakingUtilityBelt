# TO GET STARTED
# brew install imagemagick
# sudo gem install rmagick
# ruby blank_template.rb 200 200 50 50
# For more information on ImageMagick: http://ruby.bastardsbook.com/chapters/image-manipulation/

require 'rubygems'
require 'rmagick'

if ARGV.length != 4
  abort "\nUsage: blank_template file_width, file_height, tile_width, tile_height"
end
FILE_WIDTH  = ARGV[0].to_i
FILE_HEIGHT = ARGV[1].to_i
TILE_WIDTH  = ARGV[2].to_i
if(FILE_WIDTH % TILE_WIDTH != 0)
  abort "\nError: Must specify a valid tile width with File_width = #{FILE_WIDTH}"
end
HOR_TILES = FILE_WIDTH/TILE_WIDTH
TILE_HEIGHT = ARGV[3].to_i
if(FILE_HEIGHT % TILE_HEIGHT != 0)
  abort "\nError: Must specify a valid tile height with File_height = #{FILE_HEIGHT}"
end
VERT_TILES = FILE_HEIGHT/TILE_HEIGHT

fill_color = 'green'
def swap_colors(color)
  if color == 'green'
    'red'
  else
    'green'
  end
end

img = Magick::ImageList.new
img.new_image(FILE_WIDTH, FILE_HEIGHT)
rect = Magick::Draw.new
HOR_TILES.times do |i|
  VERT_TILES.times do |j|
    rect.fill(fill_color)
    rect.rectangle(0+TILE_WIDTH*i, j*TILE_HEIGHT, TILE_WIDTH+TILE_WIDTH*i, TILE_HEIGHT+j*TILE_HEIGHT)
    rect.draw(img)
    fill_color = swap_colors(fill_color)
  end
  fill_color = swap_colors(fill_color)
end

img.write("sprite_template.png")

