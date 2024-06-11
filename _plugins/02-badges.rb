require 'jekyll'
require 'jekyll/utils'
require 'digest/sha1'

Jekyll::Hooks.register :site, :post_read do |site|
    def event_badges(site, result)
        date = result['event']
        site.data['event_mapping'][date]['badges']
    end

    site.data['teams'].each do |team|
        team['results'].each do |result|
            b = event_badges(site,result)
            team['badges'] << b if b
        end
    end
end