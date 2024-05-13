require 'jekyll'
require 'jekyll/utils'
require 'digest/sha1'

Jekyll::Hooks.register :site, :post_read do |site|

    def find_alias_or_slug(site, team_name)
        tn = team_name.sub('β', 'beta')
        slug = Jekyll::Utils.slugify tn
        aliased = site.data['aliases'].find { |row| row['name'] == slug }
        if aliased
            return aliased['slug']
        else
            return slug
        end
    end
    team_times = Hash.new { |hash, key| hash[key] = [] }
    site.data['teams'] = {}

    site.data['results'].each do |row|
        row['duration'] = ""
        row['slug'] = find_alias_or_slug(site, row['Team Name'])
        row['color_index'] = Digest::SHA1.hexdigest(row['slug']).to_i % site.data['colors'].size

        site.data['teams'][row['slug']] ||= {
            'results' => [],
            'slug' => row['slug'],
            'color_index'=> row['color_index'],
            'name' => row['Team Name']
        }

        if row['End Time']
            row['d'] = d = (Time.parse(row['End Time']).to_i - Time.parse(row['Start Time']).to_i)
            if d>=3600
                row['duration'] = "#{d/3600.floor}h"
            end
            minutes = (d/60) % 60
            if minutes > 5
                row['duration'] += "#{minutes}m"
            end
            site.data['teams'][row['slug']]['results'] << {
                'd' => d/60,
                'duration' => row['duration'],
                'event' => row['Date'],
                'players' => row['Team Size'],
            }
        else
            site.data['teams'][row['slug']]['results'] << {
                'd' => nil,
                'duration' => '',
                'players' => row['Team Size'],
                'event' => row['Date'],
            }
        end
    end
    site.data['results'].sort_by! do |r|
        [r['d'].nil? ? 1 : 0, r['d'], r['Start Time']]
    end
    site.data['teams'] = site.data['teams'].values
    site.data['teams'].sort_by! {|r| -r['results'].size }

    site.data['event_theme_mapping'] = {}
    site.data['events'].each do |event|
        site.data['event_theme_mapping'][event['date'].to_s] = event['theme']
    end
end