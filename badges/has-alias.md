---
layout: badge
permalink: /badges/has-alias/
title: Secret Identity
emoji: 🦸
description: Participated with a different team name
sqlite:
  - data: teams
    file: _data/results.db
    query: |
      SELECT DISTINCT t.slug, t.name, t.color_index
      FROM teams t JOIN aliases USING (slug)
---
