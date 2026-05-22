# This plugin extracts tags from each document and generates topic pages for each tag.
# It then sorts the notes by date priority or date if no priority is set.
# The topic pages are generated in the topics directory.

module Jekyll
  class TopicGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Get all unique tags from writing
      all_tags = site.collections['writing'].docs.map { |doc| doc.data['tags'] }.flatten.compact.uniq.sort
      
      all_tags.each do |tag|
        # Find all writing with this tag
        notes_with_tag = site.collections['writing'].docs.select do |doc|
          doc.data['tags'] && doc.data['tags'].include?(tag)
        end.sort_by { |doc| 
          date = doc.data['date_priority'] || doc.date
          # Convert all dates to Time objects for consistent comparison
          case date
          when String
            Time.parse(date)
          when Date
            date.to_time
          when Time
            date
          else
            Time.now
          end
        }.reverse
        
        # Create topic page
        topic_page = TopicPage.new(site, site.source, 'topics', tag, notes_with_tag)
        site.pages << topic_page
      end
    end
  end

  class TopicPage < Page
    def initialize(site, base, dir, tag, notes)
      @site = site
      @base = base
      @dir = dir
      @name = "#{Jekyll::Utils.slugify(tag)}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'topic.html')
      
      self.data['title'] = tag
      self.data['notes'] = notes
      self.data['layout'] = 'topic'
      self.data['permalink'] = "/topics/#{Jekyll::Utils.slugify(tag)}/"
    end
  end
end
