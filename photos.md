---
description: I'm by no means a great photographer, but I enjoy it!
layout: page
nav: true
title: Photos
---

{% if site.data.instagram and site.data.instagram.size > 0 %}
<div class="photo-grid">
  {% for photo in site.data.instagram limit: 15 %}
    <a href="{{ photo.url }}" data-permalink="{{ photo.permalink }}" data-caption="{{ photo.caption | strip_html | truncate: 200 }}" class="photo-grid-item">
      <img src="{{ photo.thumb | default: photo.url }}" alt="{{ photo.caption | strip_html | truncate: 100 }}" loading="lazy" />
      <div class="photo-overlay">
        <span>{% include icons/heart.svg %} {{ photo.likes }}</span>
        <span>{% include icons/comment.svg %} {{ photo.comments }}</span>
      </div>
    </a>
  {% endfor %}
</div>

{% if site.instagram_username %}
  <a href="https://www.instagram.com/{{ site.instagram_username }}/" class="photo-see-all" target="_blank" rel="noopener">View more on Instagram &rarr;</a>
{% endif %}

<div class="lightbox" id="lightbox" aria-hidden="true" role="dialog" aria-label="Photo viewer">
  <button class="lightbox-close" aria-label="Close">&times;</button>
  <button class="lightbox-prev" aria-label="Previous photo">&larr;</button>
  <button class="lightbox-next" aria-label="Next photo">&rarr;</button>
  <div class="lightbox-content">
    <img class="lightbox-img" src="" alt="" />
    <div class="lightbox-caption"></div>
    <a class="lightbox-instagram" href="" target="_blank" rel="noopener">View on Instagram</a>
  </div>
</div>
{% else %}
<p>Photos coming soon. Set the <code>INSTAGRAM_TOKEN</code> environment variable and rebuild.</p>
{% endif %}
