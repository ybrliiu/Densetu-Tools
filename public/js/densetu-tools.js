/* root namespace */

'use strict';

var DensetuTools = DensetuTools || {};

// なぜかnameSpaceだと上手く行かない...(予約語？)
DensetuTools.namespace = function(pkgName) {

  // 名前空間を.で区切った配列
  var parts = pkgName.split('.');
  // グローバルオブジェクトの変数
  var parent = DensetuTools;

  if (parts[0] === 'DensetuTools') {
    parts = parts.slice(1);
  }

  for (var i = 0; i < parts.length; i++) {
    // プロパティが存在しなければ作成する
    if (typeof parent[parts[i]] === "undefined") {
      // モジュールオブジェクト作成
      parent[parts[i]] = {};
    }
    parent = parent[parts[i]];
  }

};
