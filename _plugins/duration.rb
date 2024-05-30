module Jekyll
  module Duration
    def duration_to_string(seconds)
      if seconds < 3600
        Time.at(seconds, in: '+00:00').strftime("%-Mm")
      else
        Time.at(seconds, in: '+00:00').strftime("%-Hh%-Mm")
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Duration)