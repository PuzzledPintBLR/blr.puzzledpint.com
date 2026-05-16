---
layout: badge
permalink: /badges/anniversary-15/
title: 15th Anniversary
emoji: 🎉
description: Attended the 15th Anniversary puzzle (July 2025)
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN results r USING (slug)
      JOIN event_badges eb ON eb.date = r.date
      WHERE eb.badge_id = 'anniversary-15'
---
