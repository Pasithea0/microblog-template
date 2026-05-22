# This plugin helps preprocess obsidian-style attachment links in each post to HTML img tags.

module Jekyll
  class ObsidianPreprocessor < Generator
    safe true
    priority :high

    def generate(site)
      # Process all markdown files to convert Obsidian syntax before markdown processing
      site.collections.each do |name, collection|
        collection.docs.each do |doc|
          if doc.extname == '.md'
            # Convert Obsidian-style attachment links with pipe syntax to a format that won't be interpreted as tables
            # Pattern: ![[path|alt_text]] -> ![[path]]<!-- alt: alt_text -->
            doc.content = doc.content.gsub(/!\[\[([^\]]*\/attachments\/[^\]]+)\|([^\]]+)\]\]/) do |match|
              path_part = $1
              alt_text = $2
              "![[#{path_part}]]<!-- alt: #{alt_text} -->"
            end
          end
        end
      end
    end
  end
end
