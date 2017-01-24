# MySQLSchemaDoc
MySQLのデータベースの構造ドキュメントを、mysqldumpのデータを使って、HTMLで出力します。

# 利用方法
1. `mysqldump`を利用して、DBのテーブル構造をXML形式で出力
> format> `mysqldump --no-data --xml [対象DB名] > [出力ファイル名(xml)]`  
> `mysqldump --no-data --xml db_schema > mysqldump_schema.xml`  

2. HTML形式でDB仕様書を出力
> format> `xsltproc -o [成果物ファイル名(html)] template.xslt [出力ファイル名(xml)]`  
> `xsltproc -o db-document.html template.xslt mysqldump_schema.xml`  
