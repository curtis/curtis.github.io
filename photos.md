---
description: I'm by no means a great photographer, but I enjoy it!
layout: page
nav: true
title: Photos
---

{% if site.data.instagram and site.data.instagram.size > 0 %}
<div class="photo-grid">
  {% for photo in site.data.instagram %}
    <a href="{{ photo.permalink }}" target="_blank" rel="noopener" class="photo-grid-item">
      <img src="{{ photo.url }}" alt="{{ photo.caption | strip_html | truncate: 100 }}" loading="lazy" />
    </a>
  {% endfor %}
</div>
{% else %}
<p>Photos coming soon.</p>
{% endif %}
