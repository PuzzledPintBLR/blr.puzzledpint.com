---
layout: badge
permalink: /badges/screen/
title: 1080p Puzzler
emoji: 🎦
description: Attended a Movie/TV themed puzzle
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN results r USING (slug)
      JOIN event_badges eb ON eb.date = r.date
      WHERE eb.badge_id = 'screen'
---
