---
layout: badge
permalink: /badges/diwali/
title: Diwali
emoji: 🪔
description: Attended a puzzle on the Diwali week
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN results r USING (slug)
      JOIN event_badges eb ON eb.date = r.date
      WHERE eb.badge_id = 'diwali'
---
