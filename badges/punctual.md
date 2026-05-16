---
layout: badge
permalink: /badges/punctual/
title: Punctual
description: First team to start the set
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN results r USING (slug)
      JOIN (SELECT date, MIN(start_time) AS m FROM results GROUP BY date) x
        ON x.date = r.date AND x.m = r.start_time
---
