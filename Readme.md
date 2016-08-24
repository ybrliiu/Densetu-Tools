# 伝説用ツール

## 予定
トップのデザイン  
給料計算  
結果表示、エラー表示をもう少しおしゃれに？  
コード纏める(Mojo::に統一したりとかも)  

## Densetu::Tools::Web
ツールをWEB上から利用できるアプリ  
※管理パスワード、セッションパスワードはherokuの環境変数で設定する  
`heroku config`  環境変数一覧  
`heroku config:add`  環境変数追加  
`heroku config:remove`  環境変数削除  

## Densetu::Tools::ParseBattleLog

### 概要
過去ログから対戦相手の情報を引っ張り出してきて表示

### 使い方
```perl

my $parse = Densetu::Tools::ParseBattleLog->new(
  id   => 'ID',
  pass => 'パスワード',
);
$parse->output;

# or

my $log;
while ( chomp(my $line = <STDIN>) ) {
  last if $line eq '';
  $log .= "\n$line";
}
$log = Encode::decode('utf8', $log);
Densetu::Tools::ParseBattleLog->output($log);

```
