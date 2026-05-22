# This plugin processes the content of each post to handle attachment links and convert them to HTML img tags.
# It also processes markdown content within the post body.

module Jekyll
  module MicroblogContentFilter
    def microblog_content(content)
      # First, convert Obsidian-style attachment links to HTML img tags
      # Pattern: ![[anything.../attachments/filename.ext]] or ![[path|alt_text]]
      # Convert to: <img src="/assets/attachments/filename.ext" alt="alt_text or filename">
      content_with_images = content.gsub(/!\[\[([^\]]*\/attachments\/[^\]]+)\]\]/) do |match|
        full_path = $1
        
        # Handle pipe-separated syntax: path|alt_text
        if full_path.include?('|')
          path_part, alt_text = full_path.split('|', 2)
          filename = File.basename(path_part.strip)
          alt_text = alt_text.strip if alt_text
        else
          filename = File.basename(full_path)
          alt_text = filename
        end
        
        # Create proper HTML img tag
        "<img src=\"/assets/attachments/#{filename}\" alt=\"#{alt_text}\">"
      end
      
      # Extract all img tags and replace them with placeholders
      img_tags = []
      content_with_placeholders = content_with_images.gsub(/<img[^>]*\/?>/) do |img_tag|
        placeholder = "|||IMG_#{img_tags.length}|||"
        img_tags << img_tag
        placeholder
      end
      
      # Process markdown to HTML (this will handle blockquotes, links, etc.)
      markdown_converter = @context.registers[:site].find_converter_instance(Jekyll::Converters::Markdown)
      html_content = markdown_converter.convert(content_with_placeholders)
      
      # Restore the img tags
      img_tags.each_with_index do |img_tag, index|
        html_content = html_content.gsub("|||IMG_#{index}|||", img_tag)
      end
      
      html_content
    end
  end
end

Liquid::Template.register_filter(Jekyll::MicroblogContentFilter)
