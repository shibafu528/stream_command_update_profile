# stream_command_update_profile

## なにこれ
stream_commandのプラグインです。  
各種プロフィールの変更を行うコマンドを使えるようにします。

## 必要なもの
* stream_commandプラグイン
* 利用者のモラル

## コマンド
#### update_name name
名前を変更します。

#### update_prefix prefix
#### update_suffix suffix
名前の接頭辞または接尾辞を変更します。ベースとなる名前がset_base_nameコマンドによって設定されている必要があります。

このコマンドが呼ばれると、接頭辞+ベース名+接尾辞で結合を行い先頭から50文字を切り出して使用します。  
50文字を超えていた場合、改名自体は行いますが超過している旨を改名者に通知します。

#### set_base_name base_name
名前の一部を変更するコマンドにおいて、ベースとなる名前を設定します。

#### get_prefix
#### get_suffix
#### get_base_name
名前の各パーツに設定されている値を照会します。

#### update_location location
#### update_locate location
現在地の情報を変更します。
