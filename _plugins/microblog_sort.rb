# This plugin injects file creation timestamps into microblog documents
# and provides a composite sort filter that sorts by created date first,
# then falls back to file creation time for same-date posts.
#
# This supports the YYYY-MM-DD.md naming scheme from Obsidian — if two
# posts share the same date in the filename/frontmatter, they're ordered
# by when the file was actually created on disk.

module Jekyll
  module MicroblogSortFilter
    def sort_microblog(posts)
      return posts unless posts.respond_to?(:sort)

      posts.sort do |a, b|
        # Primary sort: created date descending
        a_created = a.data['created']
        b_created = b.data['created']

        cmp = nil
        if a_created && b_created
          begin
            a_date = a_created.is_a?(Date) || a_created.is_a?(Time) ? a_created : Date.parse(a_created.to_s)
            b_date = b_created.is_a?(Date) || b_created.is_a?(Time) ? b_created : Date.parse(b_created.to_s)
            cmp = b_date <=> a_date
          rescue ArgumentError, TypeError
            cmp = nil
          end
        elsif a_created.nil? && b_created.nil?
          cmp = 0
        elsif a_created.nil?
          cmp = 1
        else
          cmp = -1
        end

        # Secondary sort: file birthtime descending (within same-date groups)
        if cmp == 0
          a_ctime = a.data['file_birthtime']
          b_ctime = b.data['file_birthtime']

          if a_ctime && b_ctime
            cmp = b_ctime <=> a_ctime
          elsif a_ctime.nil? && b_ctime.nil?
            cmp = 0
          elsif a_ctime.nil?
            cmp = 1
          else
            cmp = -1
          end
        end

        cmp || 0
      end
    end
  end

  class MicroblogTimestamps < Jekyll::Generator
    priority :lowest

    def generate(site)
      microblog = site.collections['microblog']
      return unless microblog

      microblog.docs.each do |doc|
        path = doc.path
        next unless File.exist?(path)

        # Use birthtime (creation time) on systems that support it,
        # fall back to ctime, then mtime
        begin
          doc.data['file_birthtime'] = File.birthtime(path)
        rescue NotImplementedError
          begin
            doc.data['file_birthtime'] = File.ctime(path)
          rescue
            doc.data['file_birthtime'] = File.mtime(path)
          end
        end
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::MicroblogSortFilter)
