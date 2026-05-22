# This plugin is a helper to encode images as base64 strings for SVG creation.
# It takes the thumbnail background and favicon image files from the assets folder.

module Jekyll
  class ImageEncoder < Generator
    safe true
    priority :high

    def generate(site)
      # Only run in production mode (when generating thumbnails)
      return unless ENV['JEKYLL_ENV'] == 'production'
      
      # Encode the thumbnail image as base64
      thumb_path = File.join(site.source, 'assets', 'thumb.png')
      
      if File.exist?(thumb_path)
        # Read the image file
        image_data = File.binread(thumb_path)
        
        # Encode as base64
        base64_data = Base64.strict_encode64(image_data)
        
        # Store in site data for use by other plugins
        site.data['thumb_base64'] = "data:image/png;base64,#{base64_data}"
        
        Jekyll.logger.info "ImageEncoder:", "Encoded thumb.png as base64 (#{base64_data.length} characters)"
      else
        Jekyll.logger.warn "ImageEncoder:", "thumb.png not found at #{thumb_path}"
      end
      
      # Encode the favicon as base64 (convert ICO to PNG for better compatibility)
      favicon_path = File.join(site.source, 'assets', 'favicon.ico')
      
      if File.exist?(favicon_path)
        # Try to convert ICO to PNG first for better SVG compatibility
        png_favicon_path = File.join(site.source, 'assets', 'favicon.png')
        
        # Convert ICO to PNG using ImageMagick
        if system("which magick > /dev/null 2>&1")
          system("magick \"#{favicon_path}\" \"#{png_favicon_path}\"")
        elsif system("which convert > /dev/null 2>&1")
          system("convert \"#{favicon_path}\" \"#{png_favicon_path}\"")
        end
        
        # Use PNG version if conversion succeeded, otherwise use original ICO
        if File.exist?(png_favicon_path)
          favicon_data = File.binread(png_favicon_path)
          site.data['favicon_base64'] = "data:image/png;base64,#{Base64.strict_encode64(favicon_data)}"
          Jekyll.logger.info "ImageEncoder:", "Converted favicon.ico to PNG and encoded as base64"
        else
          # Fallback to original ICO
          favicon_data = File.binread(favicon_path)
          favicon_base64 = Base64.strict_encode64(favicon_data)
          site.data['favicon_base64'] = "data:image/x-icon;base64,#{favicon_base64}"
          Jekyll.logger.info "ImageEncoder:", "Encoded favicon.ico as base64 (#{favicon_base64.length} characters)"
        end
      else
        Jekyll.logger.warn "ImageEncoder:", "favicon.ico not found at #{favicon_path}"
      end
    end
  end
end
