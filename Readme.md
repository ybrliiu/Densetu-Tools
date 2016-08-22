# 伝説用ツール

## 予定
更新表、放置削除の人のデータ、無所属言った人のデータは消すように頑張ってみる(無理なら手動)  
結果表示、エラー表示をもう少しおしゃれに？  
コード纏める  

## Densetu::Tools::Web
ツールをWEB上から利用できるアプリ  
※管理パスワード、セッションパスワードはherokuの環境変数で設定する
`heroku config`  環境変数一覧  
`heroku config:add`  環境変数追加  
`heroku config:remove`  環境変数削除  

## Densetu::Tools::PlayerInfo

### 概要
過去ログから対戦相手の情報を引っ張り出してきて表示

### 使い方
```perl

my $info = Densetu::Tools::PlayerInfo->new(
  id   => 'ID',
  pass => 'パスワード',
);
$info->output;

# or

my $log;
while ( chomp(my $line = <STDIN>) ) {
  last if $line eq '';
  $log .= "\n$line";
}
$log = Encode::decode('utf8', $log);
Densetu::Tools::PlayerInfo->output($log);

```
