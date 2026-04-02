/*!
 * Developer Mono -- blog.js
 * Vanilla JS: tooltip init, responsive images/tables/embeds, dark mode toggle
 */

document.addEventListener('DOMContentLoaded', function() {

  // Dead link tooltips + accessibility
  document.querySelectorAll('.dead-link[title]').forEach(function(el) {
    var url = el.getAttribute('title');
    var text = el.textContent.trim();
    // Keyboard accessible
    el.setAttribute('tabindex', '0');
    el.setAttribute('role', 'link');
    el.setAttribute('aria-disabled', 'true');
    el.setAttribute('aria-label', text + ' (broken link, original URL: ' + url + ')');
    // Tooltip
    el.setAttribute('data-bs-toggle', 'tooltip');
    el.setAttribute('data-bs-placement', 'top');
    el.setAttribute('data-bs-html', 'true');
    el.setAttribute('title', 'This link no longer works<br><code>' + url + '</code>');
  });

  // Bootstrap 5 Tooltip Init
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function(el) {
    return new bootstrap.Tooltip(el);
  });

  // Email obfuscation
  document.querySelectorAll('.obfuscated-email').forEach(function(el) {
    var parts = atob(el.getAttribute('data-e')).split('@');
    var user = parts[0].split('').reverse().join('');
    var domain = parts[1].split('.');
    var tld = domain.pop();
    var email = user + '@' + domain.map(function(p) { return p.split('').reverse().join(''); }).concat(tld).join('.');
    el.href = 'mailto:' + email;
    if (!el.textContent.trim()) el.textContent = email;
  });

  // Make all images responsive
  document.querySelectorAll('.post-content img').forEach(function(img) {
    img.classList.add('img-responsive');
  });

  // Responsive tables (skip tables inside gists)
  document.querySelectorAll('.post-content table').forEach(function(table) {
    if (table.closest('.gist')) return;
    if (!table.parentElement.classList.contains('table-responsive')) {
      var wrapper = document.createElement('div');
      wrapper.className = 'table-responsive';
      table.parentNode.insertBefore(wrapper, table);
      wrapper.appendChild(table);
    }
  });

  // Responsive embed videos
  document.querySelectorAll('.post-content iframe').forEach(function(iframe) {
    var src = iframe.getAttribute('src') || '';
    if (src.indexOf('youtube.com') !== -1 || src.indexOf('vimeo.com') !== -1) {
      if (!iframe.parentElement.classList.contains('embed-responsive')) {
        var wrapper = document.createElement('div');
        wrapper.className = 'embed-responsive embed-responsive-16by9';
        iframe.parentNode.insertBefore(wrapper, iframe);
        wrapper.appendChild(iframe);
        iframe.classList.add('embed-responsive-item');
      }
    }
  });

  // Lightbox
  var lightbox = document.getElementById('lightbox');
  if (lightbox) {
    var items = document.querySelectorAll('.photo-grid-item');
    var img = lightbox.querySelector('.lightbox-img');
    var caption = lightbox.querySelector('.lightbox-caption');
    var permalink = lightbox.querySelector('.lightbox-instagram');
    var current = 0;

    function showPhoto(index) {
      if (index < 0) index = items.length - 1;
      if (index >= items.length) index = 0;
      current = index;
      var item = items[current];
      img.src = item.href;
      img.alt = item.querySelector('img').alt;
      caption.textContent = item.getAttribute('data-caption') || '';
      permalink.href = item.getAttribute('data-permalink') || '';
    }

    function openLightbox(index) {
      showPhoto(index);
      lightbox.classList.add('is-open');
      lightbox.setAttribute('aria-hidden', 'false');
      document.body.style.overflow = 'hidden';
    }

    function closeLightbox() {
      lightbox.classList.remove('is-open');
      lightbox.setAttribute('aria-hidden', 'true');
      document.body.style.overflow = '';
    }

    items.forEach(function(item, i) {
      item.addEventListener('click', function(e) {
        e.preventDefault();
        openLightbox(i);
      });
    });

    lightbox.querySelector('.lightbox-close').addEventListener('click', closeLightbox);
    lightbox.querySelector('.lightbox-prev').addEventListener('click', function() { showPhoto(current - 1); });
    lightbox.querySelector('.lightbox-next').addEventListener('click', function() { showPhoto(current + 1); });

    lightbox.addEventListener('click', function(e) {
      if (e.target === lightbox) closeLightbox();
    });

    document.addEventListener('keydown', function(e) {
      if (!lightbox.classList.contains('is-open')) return;
      if (e.key === 'Escape') closeLightbox();
      if (e.key === 'ArrowLeft') showPhoto(current - 1);
      if (e.key === 'ArrowRight') showPhoto(current + 1);
    });
  }

});
