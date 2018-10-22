CREATE DATABASE sample_schema_doc;

use sample_schema_doc;

CREATE TABLE Users (
    user_id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ユーザーID',
    name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '名前',
    PRIMARY KEY (user_id)
) CHARACTER SET = utf8 ENGINE=INNODB comment = 'ユーザーテーブル';

CREATE TABLE Favorites (
       favorite_id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '	お気に入りID',
       user_id INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'ユーザーID',
       content VARCHAR(64) NOT NULL DEFAULT '' COMMENT '好きなこと',
       PRIMARY KEY (favorite_id)
) CHARACTER SET = utf8 ENGINE=INNODB comment = 'お気に入りテーブル';
