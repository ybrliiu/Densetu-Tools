# 伝説用ツール

## 予定
結果表示、エラー表示をもう少しおしゃれに？  
テスト書く  
コード纏める(Mojo::に統一したりとかも)  
戦闘ログ解析にスキル解析機能追加  
やる気あったらシュミレータ作ってもいいかもね  

## Densetu::Tools::Web
ツールをWEB上から利用できるアプリ  
  
※管理パスワード、セッションパスワード,ftp host,user,passはherokuの環境変数で設定する  
  
`heroku config`  環境変数一覧  
`heroku config:add`  環境変数追加  
`heroku config:remove`  環境変数削除  

### 設定必要な環境変数一覧
```
ADMIN_PASSWORD
SESSION_PASSWORD
FTP_HOST
FTP_PASSWORD
FTP_USER
```

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
