# This plugin calculates the reading time for each post based on the word count.

module Jekyll
  module ReadingTimeFilter
    def reading_time(content)
      return "0 minute read" if content.nil? || content.empty?
      
      # Remove HTML tags and count words
      text = content.gsub(/<[^>]*>/, ' ')
      words = text.split(/\s+/).reject(&:empty?).length
      
      # Average reading speed is 200-250 words per minute
      # Using 225 as a middle ground
      minutes = (words / 225.0).ceil
      
      "#{minutes} minute read"
    end
  end
end

Liquid::Template.register_filter(Jekyll::ReadingTimeFilter)
