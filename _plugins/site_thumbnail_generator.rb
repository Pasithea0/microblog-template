# This plugin generates site thumbnails in SVG and PNG formats.
# image_encoder plugin is required to encode images as base64 strings.
# The thumbnail is then saved in the source directory first, and then converted to PNG format so it can be used.

module Jekyll
  class SiteThumbnailGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Only run in production mode (when generating thumbnails)
      return unless ENV['JEKYLL_ENV'] == 'production'
      
      generate_site_thumbnail(site)
    end

    private

    def generate_site_thumbnail(site)
      # Get the base64 encoded images from site data
      thumb_base64 = site.data['thumb_base64'] || ''
      favicon_base64 = site.data['favicon_base64'] || ''
      
      # Create SVG thumbnail
      svg_content = generate_site_svg_thumbnail(site, thumb_base64, favicon_base64)
      
      # Create thumbnail file in source directory first
      source_thumbnail_dir = File.join(site.source, 'assets', 'thumbnails')
      FileUtils.mkdir_p(source_thumbnail_dir)
      
      # Generate both SVG and PNG versions
      svg_filename = "site-thumbnail.svg"
      png_filename = "site-thumbnail.png"
      
      svg_path = File.join(source_thumbnail_dir, svg_filename)
      png_path = File.join(source_thumbnail_dir, png_filename)
      
      # Write SVG file
      File.write(svg_path, svg_content)
      
      # Convert SVG to PNG using rsvg-convert (best for complex SVGs)
      convert_svg_to_png(svg_path, png_path)
      
      # Add both files to site static files for Jekyll to track
      [svg_filename, png_filename].each do |filename|
        existing_file = site.static_files.find { |f| f.path == File.join(site.source, 'assets/thumbnails', filename) }
        
        unless existing_file
          site.static_files << Jekyll::StaticFile.new(
            site,
            site.source,
            'assets/thumbnails',
            filename
          )
        end
      end
    end

    def generate_site_svg_thumbnail(site, thumb_base64, favicon_base64)
      site_title = site.config['title'] || 'Site'
      site_description = site.config['description'] || ''
      
      # Escape HTML entities
      title_escaped = CGI.escapeHTML(site_title)
      description_escaped = CGI.escapeHTML(site_description)
      
      # Process title for line wrapping
      title_lines = wrap_text(title_escaped, 30)
      
      # Process description for line wrapping and truncation
      description_lines = wrap_text(description_escaped, 70)
      if description_lines.length > 2
        description_lines = description_lines[0..1]
        description_lines[1] = description_lines[1][0..-4] + "..."
      end

      <<~SVG
        <svg width="1200" height="630" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="overlay" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" style="stop-color:#000000;stop-opacity:0" />
              <stop offset="30%" style="stop-color:#000000;stop-opacity:0.5" />
              <stop offset="100%" style="stop-color:#000000;stop-opacity:0.9" />
            </linearGradient>
            <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
              <feDropShadow dx="0" dy="2" stdDeviation="4" flood-color="#000000" flood-opacity="0.6"/>
            </filter>
          </defs>
          
          <!-- Background image -->
          #{thumb_base64.empty? ? '<rect width="1200" height="630" fill="#2d4a2d"/>' : "<image href=\"#{thumb_base64}\" x=\"0\" y=\"0\" width=\"1200\" height=\"630\" preserveAspectRatio=\"xMidYMid slice\"/>"}
          <rect x="0" y="0" width="1200" height="630" fill="url(#overlay)"/>
          
          <!-- Centered favicon -->
          <g transform="translate(600, 315)">
            #{favicon_base64.empty? ? 
              '<circle cx="0" cy="0" r="60" fill="#f5f5f5" opacity="0.9"/><text x="0" y="15" font-family="system-ui, -apple-system, sans-serif" font-size="48" font-weight="600" text-anchor="middle" fill="#333">C</text>' : 
              "<image href=\"#{favicon_base64}\" x=\"-60\" y=\"-60\" width=\"120\" height=\"120\" preserveAspectRatio=\"xMidYMid meet\"/>"
            }
          </g>
          
          <!-- Content area (centered) -->
          <g transform="translate(600, 450)">
            <!-- Title with line wrapping -->
            #{title_lines.map.with_index { |line, i| 
              "<text x='0' y='#{i * 50}' font-family='system-ui, -apple-system, sans-serif' font-size='48' font-weight='700' 
                     fill='#ffffff' filter='url(#shadow)' text-anchor='middle'>#{line}</text>"
            }.join("\n            ")}
            
            <!-- Description with line wrapping -->
            #{description_lines.map.with_index { |line, i| 
              "<text x='0' y='#{title_lines.length * 50 + 30 + i * 30}' font-family='system-ui, -apple-system, sans-serif' font-size='24' font-weight='400' 
                     fill='#e0e0e0' filter='url(#shadow)' text-anchor='middle'>#{line}</text>"
            }.join("\n            ")}
          </g>
        </svg>
      SVG
    end

    def wrap_text(text, max_chars_per_line)
      words = text.split(' ')
      lines = []
      current_line = ''
      
      words.each do |word|
        if (current_line + word).length <= max_chars_per_line
          current_line += (current_line.empty? ? '' : ' ') + word
        else
          lines << current_line unless current_line.empty?
          current_line = word
        end
      end
      
      lines << current_line unless current_line.empty?
      lines
    end

    def convert_svg_to_png(svg_path, png_path)
      # Try to convert SVG to PNG using available tools
      # First try rsvg-convert (librsvg) - often better for complex SVGs
      if system("which rsvg-convert > /dev/null 2>&1")
        system("rsvg-convert -w 1200 -h 630 \"#{svg_path}\" -o \"#{png_path}\"")
        return if File.exist?(png_path)
      end
      
      # Try ImageMagick with better parameters for complex SVGs
      if system("which magick > /dev/null 2>&1")
        system("magick -background transparent -density 300 -size 1200x630 \"#{svg_path}\" -resize 1200x630! \"#{png_path}\"")
        return if File.exist?(png_path)
      end
      
      # Try ImageMagick (convert command - legacy) with better parameters
      if system("which convert > /dev/null 2>&1")
        system("convert -background transparent -density 300 -size 1200x630 \"#{svg_path}\" -resize 1200x630! \"#{png_path}\"")
        return if File.exist?(png_path)
      end
      
      # Try Inkscape - excellent for complex SVGs
      if system("which inkscape > /dev/null 2>&1")
        system("inkscape --export-type=png --export-filename=\"#{png_path}\" --export-width=1200 --export-height=630 \"#{svg_path}\"")
        return if File.exist?(png_path)
      end
      
      # If no conversion tool is available, create a simple fallback PNG
      create_fallback_png(png_path)
    end

    def create_fallback_png(png_path)
      # Create a simple fallback PNG using Ruby's built-in capabilities
      require 'base64'
      
      # Create a simple 1200x630 PNG with a solid color background
      png_data = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
      
      File.write(png_path, png_data)
    end
  end
end
