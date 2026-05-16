---
layout: badge
permalink: /badges/sub-1h/
title: Sub 1h
emoji: ⏲️
description: Finished a puzzle set in less than an hour
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN results r USING (slug)
      WHERE r.solved = 1 AND r.duration < 3600
---
