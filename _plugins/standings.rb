require 'jekyll'
require 'jekyll/utils'
require 'digest/sha1'

Jekyll::Hooks.register :site, :post_read do |site|
    team_times = Hash.new { |hash, key| hash[key] = [] }
    site.data['teams'] = {}

    site.data['results'].each do |row|
        row['duration'] = ""
        row['slug'] = Jekyll::Utils.slugify row['Team Name']
        
        row['color_index'] = Digest::SHA1.hexdigest(row['slug']).to_i % site.data['colors'].size

        site.data['teams'][row['slug']] ||= {
            'results' => [],
            'slug' => row['slug'],
            'color_index'=> row['color_index'],
            'name' => row['Team Name']
        }

        if row['End Time']
            row['d'] = d = Time.parse(row['End Time']).to_i - Time.parse(row['Start Time']).to_i
            if d>3600
                row['duration'] = "#{d/3600.floor}h"
            end
            minutes = (d/60) % 60
            if minutes > 5
                row['duration'] += "#{minutes}m"
            end
            site.data['teams'][row['slug']]['results'] << {
                'duration' => row['duration'],
                'event' => row['Date'],
            }
        else
            site.data['teams'][row['slug']]['results'] << {
                'duration' => '',
                'players' => row['Team Size'],
                'event' => row['Date'],
            }
        end
    end
    site.data['results'].sort_by! { |s| [s['d'].nil? ? 0 : 1, s['d']] }
    site.data['teams'] = site.data['teams'].values
    site.data['teams'].sort_by! {|r| -r['results'].size }
end