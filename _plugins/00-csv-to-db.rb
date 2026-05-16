require 'jekyll'
require 'jekyll/utils'
require 'csv'
require 'yaml'
require 'sqlite3'
require 'digest/sha1'
require 'time'

Jekyll::Hooks.register :site, :after_init do |site|
  data_dir = File.join(site.source, '_data')
  db_path  = File.join(data_dir, 'results.db')
  File.delete(db_path) if File.exist?(db_path)
  db = SQLite3::Database.new(db_path)

  load_yaml = ->(path) { YAML.load_file(path, permitted_classes: [Date]) }
  colors  = load_yaml.call(File.join(data_dir, 'colors.yml'))
  events  = load_yaml.call(File.join(data_dir, 'events.yaml'))
  badges  = load_yaml.call(File.join(data_dir, 'badges.yml'))
  aliases = CSV.read(File.join(data_dir, 'aliases.csv'), headers: true).map(&:to_h)
  results = CSV.read(File.join(data_dir, 'results.csv'), headers: true).map(&:to_h)

  slugify = ->(team_name) {
    Jekyll::Utils.slugify(team_name.gsub('β', 'beta').gsub('²', 'squared'))
  }

  resolve_slug = ->(team_name) {
    slug = slugify.call(team_name)
    aliases.find { |a| a['name'] == slug }&.[]('slug') || slug
  }

  db.execute_batch <<~SQL
    CREATE TABLE aliases     (name TEXT, slug TEXT, event TEXT);
    CREATE TABLE events      (date TEXT PRIMARY KEY, theme TEXT, sheet_url TEXT);
    CREATE TABLE event_badges(date TEXT, badge_id TEXT);
    CREATE TABLE badges      (id TEXT PRIMARY KEY, name TEXT, description TEXT, emoji TEXT);
    CREATE TABLE results (
      date TEXT, team_name TEXT, team_size INTEGER,
      start_time TEXT, end_time TEXT,
      slug TEXT, color_index INTEGER,
      duration INTEGER, solved INTEGER, rank INTEGER
    );
    CREATE TABLE teams (
      slug TEXT PRIMARY KEY, name TEXT, color_index INTEGER, appearances INTEGER
    );
  SQL

  db.transaction do
    ins = db.prepare("INSERT INTO aliases VALUES (?,?,?)")
    aliases.each { |a| ins.execute(a['name'], a['slug'], a['event']) }
    ins.close

    ins = db.prepare("INSERT INTO events VALUES (?,?,?)")
    ins_eb = db.prepare("INSERT INTO event_badges VALUES (?,?)")
    events.each do |e|
      date = e['date'].to_s
      ins.execute(date, e['theme'], e['sheetURL'])
      (e['badges'] || []).each { |b| ins_eb.execute(date, b) }
    end
    ins.close
    ins_eb.close

    ins = db.prepare("INSERT INTO badges VALUES (?,?,?,?)")
    badges.each { |b| ins.execute(b['id'], b['name'], b['description'], b['emoji']) }
    ins.close

    ins = db.prepare("INSERT INTO results VALUES (?,?,?,?,?,?,?,?,?,?)")
    enriched = results.reject { |r| r['Team Name'].to_s.empty? }.map do |r|
      slug = resolve_slug.call(r['Team Name'])
      duration = r['End Time'] && !r['End Time'].empty? ?
        Time.parse(r['End Time']).to_i - Time.parse(r['Start Time']).to_i : nil
      {
        date: r['Date'], team_name: r['Team Name'], team_size: r['Team Size'].to_i,
        start_time: r['Start Time'], end_time: r['End Time'], slug: slug,
        color_index: Digest::SHA1.hexdigest(slug).to_i(16) % colors.size,
        duration: duration, solved: duration ? 1 : 0,
      }
    end

    enriched.group_by { |r| r[:date] }.each_value do |rows|
      rows.sort_by! { |r| [r[:solved] == 1 ? 0 : 1, r[:duration] || 999_999, r[:start_time]] }
      rows.each_with_index { |r, i| r[:rank] = i + 1 }
    end

    enriched.each do |r|
      ins.execute(r[:date], r[:team_name], r[:team_size], r[:start_time], r[:end_time],
                  r[:slug], r[:color_index], r[:duration], r[:solved], r[:rank])
    end
    ins.close

    ins = db.prepare("INSERT INTO teams VALUES (?,?,?,?)")
    enriched.group_by { |r| r[:slug] }.each do |slug, rows|
      canonical = rows.find { |r| slugify.call(r[:team_name]) == slug }
      name = (canonical || rows.first)[:team_name]
      ins.execute(slug, name, rows.first[:color_index], rows.size)
    end
    ins.close
  end

  db.close
end
