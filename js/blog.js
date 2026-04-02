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

});

