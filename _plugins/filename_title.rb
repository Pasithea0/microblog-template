
# This plugin sets the title of each document to the filename (minus the extension).

module Jekyll
  class FilenameTitleGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site.collections['writing'].docs.each do |doc|
        # Extract title from filename (remove .md extension)
        filename = File.basename(doc.basename, File.extname(doc.basename))
        
        # Set the title in the document's data
        doc.data['title'] = filename
        
        # Also set a slugified version for URLs if needed
        doc.data['slug'] = Jekyll::Utils.slugify(filename)
        
        # Set date priority: updated > created > published
        date_priority = nil
        
        if doc.data['updated']
          date_priority = doc.data['updated']
        elsif doc.data['created']
          date_priority = doc.data['created']
        elsif doc.data['published']
          date_priority = doc.data['published']
        end
        
        # Set the date_priority field for sorting
        doc.data['date_priority'] = date_priority
        
        # Also set a fallback 'published' field for compatibility
        if !doc.data['published'] && date_priority
          doc.data['published'] = date_priority
        end
      end
    end
  end
end
