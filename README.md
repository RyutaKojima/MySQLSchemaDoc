# MySQLSchemaDoc
MySQLのデータベースの構造ドキュメントを、mysqldumpのデータを使って、HTMLで出力します。

# 利用方法

1. GitHubからclone  
`git clone https://github.com/RyutaKojima/MySQLSchemaDoc.git`

2. `mysqldump`で、DBのテーブル構造をXML形式で出力  
> format> `mysqldump --no-data --xml [対象DB名] > [出力ファイル名(xml)]`  
`mysqldump --no-data --xml SampleTable > mysqldump.xml`  

3. `xsltproc`でHTMLを出力  
> format> `xsltproc -o [成果物ファイル名(html)] template.xslt [出力ファイル名(xml)]`  
`xsltproc -o MySQLSchemaDoc/dist/index.html MySQLSchemaDoc/src/style.xslt mysqldump.xml`  

4. MySQLSchemaDoc/dist にHTML/JS/CSS 一式が揃っている状態が出来ます。
