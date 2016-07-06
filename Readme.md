# 伝説用ツール

## Densetu::Tools::PlayerInfo

### 使い方
` perl

my $info = Densetu::Tools::PlayerInfo->new(
  id => 'ID',
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

`
