use v5.14;
use warnings;
use utf8;
use Test::More;
use Test::Exception;

use_ok 'Densetu::Tools::UpdateTimeTable::Player';

subtest 'parse log establish country' => sub {
  ok( my $player = Densetu::Tools::UpdateTimeTable::Player->new );
  ok $player->parse("・【建国】[175年00月]新しくハゲ率いるハゲの国が蜂起しました。(1日0時10分39秒) ");
  is $player->name, 'ハゲ';
  is $player->country, 'ハゲの国';
  is $player->show_time, '10:39';
};

subtest 'parse log join to country' => sub {
  ok( my $player = Densetu::Tools::UpdateTimeTable::Player->new );
  ok $player->parse("・[仕官]新しく睦月がnew_countryに仕官しました。(29日10時45分45秒) ");
  is $player->name, '睦月';
  is $player->country, 'new_country';
  is $player->show_time, '45:45';
};

subtest 'parse log attack' => sub {
  ok( my $player = Densetu::Tools::UpdateTimeTable::Player->new );
  ok $player->parse("</s></i></u></a></b><br>・ドイツアフリカ軍団のはんぺん【軍師】は汝南（亡国？）へ攻め込みました！(20日3時44分8秒) ");
  is $player->name, 'はんぺん';
  is $player->country, 'ドイツアフリカ軍団';
  is $player->show_time, '44:08';
};

subtest 'parse irregular attack log' => sub {
  my $country_name = 'ドイツのアフリカ象の軍団';
  ok( my $player = Densetu::Tools::UpdateTimeTable::Player->new );
  ok $player->parse("・ドイツのアフリカ象の軍団の君の名は、君の名は。は汝南（亡国？）へ攻め込みました！(19日22時35分35秒) ");
  ok $player->reparse($country_name);
  is $player->name, '君の名は、君の名は。';
  is $player->country, $country_name;
  is $player->show_time, '35:35';
};

###

subtest 'parse irregular attack log 2' => sub {
  my $country_name = '風邪の谷';
  ok( my $player = Densetu::Tools::UpdateTimeTable::Player->new );
  ok $player->parse("・風邪の谷のユハ様【軍師】は武都（☆ちぇるちぇるらんど☆）へ攻め込みました！(12日15時37分24秒)");
  ok $player->reparse($country_name);
  is $player->name, 'ユハ様';
  is $player->country, $country_name;
  is $player->show_time, '37:24';
};

done_testing;
