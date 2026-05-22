# This plugin converts markdown style links into clickable <a> links.

module Jekyll
  module AutoLinkFilter
    def auto_link(content)
      # Regular expression to match URLs (http, https, ftp, and www)
      url_pattern = /(https?:\/\/[^\s<>"{}|\\^`\[\]]+|www\.[^\s<>"{}|\\^`\[\]]+)/i
      
      # Replace URLs with clickable links
      content.gsub(url_pattern) do |url|
        # Add protocol if missing (for www. links)
        href = url.start_with?('www.') ? "http://#{url}" : url
        
        # Create the link
        "<a href=\"#{href}\" target=\"_blank\" rel=\"noopener noreferrer\">#{url}</a>"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::AutoLinkFilter)
