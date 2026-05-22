# Obsidian-style quote callout processor, based on the Typomagical Obsidian theme.

module Jekyll
  class QuoteCalloutProcessor < Generator
    safe true
    priority :high

    def generate(site)
      # Process all markdown files to convert [!quote] callouts
      site.collections.each do |name, collection|
        collection.docs.each do |doc|
          if doc.extname == '.md'
            doc.content = process_quote_callouts(doc.content)
          end
        end
      end

      # Also process standalone markdown files
      site.pages.each do |page|
        if page.extname == '.md'
          page.content = process_quote_callouts(page.content)
        end
      end
    end

    private

    def process_quote_callouts(content)
      lines = content.split("\n")
      result_lines = []
      i = 0
      
      while i < lines.length
        line = lines[i]
        
        # Check if this line starts a quote callout
        if line =~ /^> \[!quote\](.*)$/
          author_part = $1
          
          # Extract the author information
          author_text = nil
          author_url = nil
          plain_text = nil

          # Only process if there's actually an author (non-empty and no newlines)
          if !author_part.empty? && !author_part.include?("\n")
            # Check if it's a [text](url) format
            if author_part =~ /^\s*\[([^\]]+)\]\(([^)]+)\)$/
              author_text = $1
              author_url = $2
            else
              plain_text = author_part.strip
            end
          end

          # Collect all the blockquote content
          blockquote_content = []
          i += 1
          
          # Continue reading lines until we hit a non-blockquote line or another callout
          while i < lines.length
            current_line = lines[i]
            
            # Stop if we hit a non-blockquote line (but allow empty lines)
            if !current_line.strip.empty? && !current_line.start_with?('>')
              break
            end
            
            # Stop if we hit another callout (like [!tip], [!note], etc.)
            if current_line.start_with?('>') && current_line.match(/^> \[![^\]]+\]/)
              break
            end
            
            # Remove the '> ' prefix and add to content
            if current_line.start_with?('>')
              blockquote_content << current_line[2..-1]
            elsif current_line.strip.empty?
              blockquote_content << ""
            end
            
            i += 1
          end
          
          # Generate the HTML structure
          content_text = blockquote_content.join("\n").strip
          html_replacement = generate_quote_callout_html(author_text, author_url, plain_text, content_text)
          
          # Add the HTML replacement
          result_lines << html_replacement
          
          # Don't increment i here since we already processed the blockquote block
        else
          # Regular line, just add it
          result_lines << line
          i += 1
        end
      end
      
      result_lines.join("\n")
    end


    def generate_quote_callout_html(author_text, author_url, plain_text, content)
      # Determine the author/url
      if author_text && author_url
        author_html = %Q{<a data-tooltip-position="top" aria-label="#{author_url}" rel="noopener nofollow" class="external-link" href="#{author_url}" target="_blank">#{author_text}</a>}
      elsif plain_text && !plain_text.empty?
        author_html = plain_text.strip
      else
        author_html = ""
      end

      # Process the content with markdown
      processed_content = process_markdown_content(content)

      # Generate the complete HTML structure
      if author_html.empty?
        # No author, simpler structure
        %Q{<div data-quote-callout-metadata="" data-quote-callout-fold="" data-quote-callout="quote" class="quote-callout">
  <div class="quote-callout-title" dir="auto">
    <div class="quote-callout-icon">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="svg-icon lucide-quote">
        <path d="M16 3a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2 1 1 0 0 1 1 1v1a2 2 0 0 1-2 2 1 1 0 0 0-1 1v2a1 1 0 0 0 1 1 6 6 0 0 0 6-6V5a2 2 0 0 0-2-2z"></path>
        <path d="M5 3a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2 1 1 0 0 1 1 1v1a2 2 0 0 1-2 2 1 1 0 0 0-1 1v2a1 1 0 0 0 1 1 6 6 0 0 0 6-6V5a2 2 0 0 0-2-2z"></path>
      </svg>
    </div>
  </div>
  <div class="quote-callout-content">
#{processed_content}
  </div>
</div>}
      else
        # With author
        %Q{<div data-quote-callout-metadata="" data-quote-callout-fold="" data-quote-callout="quote" class="quote-callout">
  <div class="quote-callout-title" dir="auto">
    <div class="quote-callout-icon">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="svg-icon lucide-quote">
        <path d="M16 3a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2 1 1 0 0 1 1 1v1a2 2 0 0 1-2 2 1 1 0 0 0-1 1v2a1 1 0 0 0 1 1 6 6 0 0 0 6-6V5a2 2 0 0 0-2-2z"></path>
        <path d="M5 3a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2 1 1 0 0 1 1 1v1a2 2 0 0 1-2 2 1 1 0 0 0-1 1v2a1 1 0 0 0 1 1 6 6 0 0 0 6-6V5a2 2 0 0 0-2-2z"></path>
      </svg>
    </div>
  </div>
  <div class="quote-callout-content">
#{processed_content}
  </div>
  <div class="quote-callout-author">— #{author_html}</div>
</div>}
      end
    end

    def process_markdown_content(content)
      return "" if content.nil? || content.strip.empty?
      
      # Use Jekyll's markdown converter to process the content
      # This will handle headers, paragraphs, links, etc.
      converter = Jekyll::Converters::Markdown.new(Jekyll.configuration)
      html = converter.convert(content)
      
      # Clean up the HTML and ensure proper formatting
      html.strip
    rescue => e
      # Fallback to simple text processing if markdown conversion fails
      content.gsub(/\n/, '<br>')
    end
  end
end
