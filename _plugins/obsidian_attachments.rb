# This plugin processes obsidian-style attachment links in each post to HTML img tags.

module Jekyll
  class ObsidianAttachmentsConverter < Converter
    safe true
    priority :high

    def matches(ext)
      ext =~ /^\.md$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      # Convert Obsidian-style attachment links to HTML img tags
      # Handle both original syntax and preprocessed syntax
      
      # First, handle preprocessed syntax: ![[path]]<!-- alt: alt_text -->
      content = content.gsub(/!\[\[([^\]]*\/attachments\/[^\]]+)\]\]<!-- alt: ([^>]+) -->/) do |match|
        full_path = $1
        alt_text = $2.strip
        filename = File.basename(full_path)
        baseurl = @config['baseurl'].to_s
        src = File.join(baseurl, "assets", "attachments", filename).gsub(%r{/+}, "/")
        src = "/#{src}" unless src.start_with?("/")
        alt_text = alt_text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;")
        
        # Create proper HTML img tag
        "<img src=\"#{src}\" alt=\"#{alt_text}\">"
      end
      
      # Then, handle simple syntax: ![[path]]
      content = content.gsub(/!\[\[([^\]]*\/attachments\/[^\]]+)\]\]/) do |match|
        full_path = $1
        filename = File.basename(full_path)
        baseurl = @config['baseurl'].to_s
        src = File.join(baseurl, "assets", "attachments", filename).gsub(%r{/+}, "/")
        src = "/#{src}" unless src.start_with?("/")
        alt_text = filename.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;")
        
        # Create proper HTML img tag
        "<img src=\"#{src}\" alt=\"#{alt_text}\">"
      end
      
      content
    end
  end
end
