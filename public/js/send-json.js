/* need jQuelly */

"use strict";

function sendJson(json, url) {
  $.ajax({
    url         : url,
    type        : 'POST',
    cache       : false,
    data        : JSON.stringify(json),
    contentType : 'application/JSON',
    beforeSend  : function() {
      document.getElementById('result').innerHTML = '情報取得中...';
    },
  }).done(function(data, textStatus, jqXHR) {
    document.getElementById('result').innerHTML = data;
  }).fail(function(jqXHR, textStatus, errorThrown) {
    alert("ajax通信失敗" + "jqXHR:" + jqXHR + " textStatus:" + textStatus + " errorThrown:" + errorThrown);
  });
}

