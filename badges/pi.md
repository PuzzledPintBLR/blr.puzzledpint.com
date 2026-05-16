---
layout: badge
permalink: /badges/pi/
title: Pi
emoji: π
description: Attended a math-themed puzzle
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN results r USING (slug)
      JOIN event_badges eb ON eb.date = r.date
      WHERE eb.badge_id = 'pi'
---
