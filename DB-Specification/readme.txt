
//[Step.1] DBのテーブル構造をXML形式でダンプ
// format> mysqldump --no-data --xml [対象DB名] > [出力ファイル名(xml)]
mysqldump --no-data --xml db_schema > mysqldump_schema.xml

//[Step.2] HTML形式でDB仕様書を作成
// format> xsltproc -o [成果物ファイル名(html)] template.xslt [出力ファイル名(xml)]
xsltproc -o db-document.html template.xslt mysqldump_schema.xml
