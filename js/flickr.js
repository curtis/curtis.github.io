(function (document, $) {
  "use strict";

  $.fn.flickrPhotoStream = function (options) {
    var url = 'https://api.flickr.com/services/feeds/photos_public.gne?id=76462859@N00&format=json&jsoncallback=?';
    var el  = this;

    return $.getJSON(url).done(function(data) {
      $.when(
        $.each(data.items, function (index, item) {
          var img  = $("<img />").attr("src", item.media.m).attr("alt", item.title);
          var a    = $("<a />").attr("href", item.media.m.replace('_m', '_b'))

          a.append(img);
          $(el).append(a);
        })
      ).done(function() {
        $(el).justifiedGallery({
          rowHeight: 160,
          lastRow: 'justify'
        }).on('jg.complete', function() {
          debugger
          $('#' + el.prop('id') + ' a').swipebox();
        });
      });
    });
  };
})(document, jQuery);
