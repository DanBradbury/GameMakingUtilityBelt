# Utility Belt Helper

## PNG Color Analyzer (`png_color_analyzer.rb`)

Analyzes all pixel colors in a PNG file, providing detailed statistics and color frequency data.

### Features

- **Complete Color Analysis**: Identifies every unique color in a PNG file
- **Frequency Counting**: Shows how many pixels use each color
- **Multiple Output Formats**: Console display, CSV export, or programmatic access
- **Transparency Support**: Handles RGBA values including alpha channel
- **Statistical Insights**: Most/least common colors, transparency detection

### Usage

```bash
# Basic analysis (shows top 10 colors)
ruby png_color_analyzer.rb image.png

# Show all colors found in the image
ruby png_color_analyzer.rb image.png --all

# Limit results to top N colors
ruby png_color_analyzer.rb image.png --limit 20

# Export color data to CSV file
ruby png_color_analyzer.rb image.png --csv

# Display detailed statistics
ruby png_color_analyzer.rb image.png --stats

# Combine multiple options
ruby png_color_analyzer.rb image.png --limit 15 --csv --stats
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `--all` | Show all unique colors (default shows top 10) |
| `--limit N` | Show top N most common colors |
| `--csv` | Export results to `colors.csv` |
| `--stats` | Display detailed statistics including transparency info |

### Sample Output

```
Analyzing PNG: sample.png
Dimensions: 800x600
Total pixels: 480000
--------------------------------------------------
Found 1247 unique colors

Top 10 most common colors:
--------------------------------------------------
1. #ffffff (RGBA: 255,255,255,255) - 125000 pixels (26.04%)
2. #000000 (RGBA: 0,0,0,255) - 89000 pixels (18.54%)
3. #ff0000 (RGBA: 255,0,0,255) - 45000 pixels (9.38%)
...
```

### Programmatic Usage

```ruby
require_relative 'png_color_analyzer'

analyzer = PNGColorAnalyzer.new('image.png')
analyzer.analyze

# Get color palette data
palette = analyzer.get_color_palette(10)  # Top 10 colors
puts palette.first[:hex]  # "#ffffff"

# Check for transparency
puts analyzer.has_transparency?  # true/false

# Get statistics
stats = analyzer.color_stats
puts stats[:total_colors]  # 1247
```

---

## PNG Color Replacer (`png_color_replacer.rb`)

Replaces specific colors in PNG files with new colors, creating a modified copy with precise pixel-level control.

### Features

- **Exact Color Matching**: Replace specific hex colors with pixel-perfect precision
- **Batch Replacement**: Replace multiple colors in a single operation
- **Preview Mode**: See changes before applying them
- **Flexible Color Formats**: Supports #RGB, #RRGGBB, RGB, and RRGGBB formats
- **Safe Operation**: Creates new file, preserves original
- **Progress Reporting**: Shows exactly what changes were made

### Usage

```bash
# Replace single color (red to blue)
ruby png_color_replacer.rb image.png '#ff0000' '#0000ff'

# Replace multiple colors at once
ruby png_color_replacer.rb image.png '#ff0000,#00ff00,#0000ff' '#ffff00,#ff00ff,#00ffff'

# Preview changes without saving
ruby png_color_replacer.rb image.png '#f00,#0f0' '#000,#fff' --preview

# Various color format examples (all equivalent)
ruby png_color_replacer.rb image.png '#ff0000' '#0000ff'   # Standard hex
ruby png_color_replacer.rb image.png 'ff0000' '0000ff'     # Without # prefix
ruby png_color_replacer.rb image.png '#f00' '#00f'         # Short hex
ruby png_color_replacer.rb image.png 'f00' '00f'           # Short without #
```

### Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `png_file` | Path to input PNG file | `image.png` |
| `old_colors` | Comma-separated hex colors to replace | `'#ff0000,#00ff00'` |
| `new_colors` | Comma-separated replacement colors | `'#0000ff,#ffff00'` |
| `--preview` | Show preview without saving changes | Optional flag |

### Color Format Support

The script accepts multiple hex color formats:

- **Full hex with #**: `#ff0000`, `#00ff00`
- **Full hex without #**: `ff0000`, `00ff00`
- **Short hex with #**: `#f00`, `#0f0`
- **Short hex without #**: `f00`, `0f0`

### Sample Output

```
Processing PNG: sample.png
Image dimensions: 800x600

Preview of changes:
--------------------------------------------------
#ff0000 → #0000ff: 1250 pixels (2.60%)
#00ff00 → #ffff00: 890 pixels (1.85%)

Color replacements to be made:
  #ff0000 → #0000ff
  #00ff00 → #ffff00

Image saved as: sample_color_change.png
Total pixels replaced: 2140

✓ Color replacement completed successfully!
Original file: sample.png
New file: sample_color_change.png
```

### Error Handling

The script includes comprehensive error handling for:
- Missing or invalid files
- Mismatched color list lengths
- Invalid hex color formats
- PNG parsing errors

---

## Common Use Cases

### Design Iteration
```bash
# Analyze colors in a design mockup
ruby png_color_analyzer.rb mockup.png --limit 5

# Replace brand colors across multiple assets
ruby png_color_replacer.rb logo.png '#ff0000' '#0066cc'
```

### Asset Processing
```bash
# Export color palette for documentation
ruby png_color_analyzer.rb asset.png --csv

# Batch color replacement for theming
ruby png_color_replacer.rb ui_element.png '#333333,#ffffff,#ff5500' '#1a1a1a,#f8f8f8,#0099ff'
```

### Quality Assurance
```bash
# Check if image uses only approved brand colors
ruby png_color_analyzer.rb brand_asset.png --stats

# Preview color changes before applying
ruby png_color_replacer.rb prototype.png '#old_color' '#new_color' --preview
```

## Tips

1. **Use the analyzer first** to identify exact hex values of colors you want to replace
2. **Always preview** major color changes before applying them
3. **Keep backups** - while the original file isn't modified, having backups is always wise
4. **CSV export** is helpful for documenting color palettes and creating style guides
5. **Batch operations** are more efficient than multiple single-color replacements

## Spritesheet Template
```
ruby blank_template.rb 360 120 30 30
```
Will generate the following:
![](http://i.imgur.com/0QEua9l.png)
After applying your sprites its easy to see how things line up.
![](http://i.imgur.com/BoejzqL.png)
Simply remove the bottom layer and export the file to leave a transparent image.

Photoshop doesn't like to open with the proper mode so you may have to set the following to ensure pasting in layers uses a true color pallete.
![](http://i.imgur.com/hFppdwK.png)

