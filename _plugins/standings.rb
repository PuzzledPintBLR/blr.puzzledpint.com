require 'jekyll'
require 'jekyll/utils'
require 'digest/sha1'

Jekyll::Hooks.register :site, :post_read do |site|
    site.data['results'].each do |row|
        row['duration'] = ""
        row['slug'] = Jekyll::Utils.slugify row['Team Name']
        
        row['color_index'] = Digest::SHA1.hexdigest(row['slug']).to_i % site.data['colors'].size

        if row['End Time']
            row['d'] = d = Time.parse(row['End Time']).to_i - Time.parse(row['Start Time']).to_i
            if d>3600
                row['duration'] = "#{d/3600.floor}h"
            end
            minutes = (d/60) % 60
            if minutes > 5
                row['duration'] += "#{minutes}m"
            end
        end
    end
    site.data['results'].sort_by! { |s| [s['d'].nil? ? 0 : 1, s['d']] }
end