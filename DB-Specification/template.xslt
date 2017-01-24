<?xml version="1.0" encoding="utf8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="http://sqlfairy.sourceforge.net/sqlfairy.xml">
    <xsl:output method="html" encoding="utf8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

    <xsl:template match="database">
        <html lang="ja">
            <head>
                <meta charset="utf-8"/>
                <title>テーブル定義書 - <xsl:value-of select="@name"/></title>
                <script src="https://unpkg.com/jquery@3.1.0/dist/jquery.min.js"></script>
                <style>
                    header {
                        text-align: center;
                    }
                    footer {
                        text-align: center;
                        padding: 0.5em;
                    }

                    /** 表示対象テーブルの選択ナビゲーション */
                    nav {
                        position: fixed;
                        width: 300px;
                        height: 96%;
                        min-height: 600px;
                        top: 8px;
                        left: 8px;
                        overflow-y: auto;

                        background-color: white;
                        border: 1px solid #d9d9d9;
                        border-radius: 6px;
                    }
                    nav div.nav_list_block {
                        margin-top: 20px;
                        height: 82%;
                        overflow-y: scroll;
                    }
                    nav ul {
                        list-style-type: none;
                        padding-left: 0;
                    }
                    nav ul a {
                        display: block;
                        font-size: 13px;
                        color: rgba(0,0,0,0.7);
                        padding: 8px 12px;
                        border-top: 1px solid #d9d9d9;
                        border-left: 2px solid transparent;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        text-decoration: none;
                        white-space: nowrap;
                    }
                    nav ul a:hover {
                        text-decoration: none;
                        background-color: bad-color;
                        border: 2px solid black;
                    }

                    nav ul a.selected {
                        background-color: #f7f7cc;
                    }

                    /** 定義書本体 */
                    div#content {
                        position: fixed;
                        width: 80%;
                        min-width: 800px;
                        height: 96%;
                        min-height: 600px;
                        overflow-y: auto;
                        top:  8px;
                        left: 315px;

                        background-color: white;
                        border: 1px solid #d9d9d9;
                        border-radius: 6px;
                    }

                    /** テーブルの共通スタイル */
                    table {
                        border: 2px solid #000000;
                        border-collapse: collapse;
                    }
                    table th {
                        background-color: #adadad;
                    }
                    table td {
                        border-top: 1px solid #d9d9d9;
                    }

                    /** テーブル概要 */
                    table.my-table-spec {
                        margin-top: 8px;
                        margin-left: 10px;
                    }
                    table.my-table-spec th {
                        width: 150px;
                        border-top: 1px solid #d9d9d9;
                    }
                    table.my-table-spec td {
                        min-width: 400px;
                    }

                    /** カラム詳細 */
                    table.my-table-detail {
                        table-layout: fixed;
                        margin-left: 10px;
                        margin-top: 2px;
                        text-align: left;
                    }
                    table.my-table-detail thead {
                        display: block;
                        width: 1380px;
                    }
                    table.my-table-detail tbody {
                        display: block;
                        width: 1380px;
                        height: 600px;
                        overflow-y: scroll;
                        -ms-overflow-y: scroll;
                    }
                    table.my-table-detail tr {
                        height: 40px;
                    }
                    table.my-table-detail .cell_no     { width:  30px; }
                    table.my-table-detail .cell_column { width: 300px; }
                    table.my-table-detail .cell_type   { width: 130px; }
                    table.my-table-detail .cell_null   { width:  60px; }
                    table.my-table-detail .cell_default{ width: 100px; }
                    table.my-table-detail .cell_pri    { width:  70px; }
                    table.my-table-detail .cell_uni    { width:  70px; }
                    table.my-table-detail .cell_other  { width: 200px; }
                    table.my-table-detail .cell_comment{ width: 385px; }

                    /** インデックス情報 */
                    table.my-table-keys {
                        border: 2px solid #ffbd70;
                        margin-top: 2px;
                        margin-left: 10px;
                    }
                    table.my-table-keys thead {
                        display: block;
                        width: 1380px;
                    }
                    table.my-table-keys tbody {
                        display: block;
                        width: 1380px;
                        height: 140px;
                        overflow-y: scroll;
                        -ms-overflow-y: scroll;
                    }
                    table.my-table-keys th {
                        background-color: #ffbd70;
                        text-align: left;
                        width: 120px;
                    }
                    table.my-table-keys td {
                      border-top: 1px solid #ffbd70;
                    }
                    table.my-table-keys .cell_key_name    { width:  100px; }
                    table.my-table-keys .cell_unique      { width:  100px; }
                    table.my-table-keys .cell_column_name { width:  300px; }
                    table.my-table-keys .cell_seq_in_index{ width:  120px; }
                    table.my-table-keys .cell_cardinality { width:  100px; }
                    table.my-table-keys .cell_comment     { width:  630px; }
                </style>
                <script type="text/javascript">
                (function() {
                    "use strict";
                    var prev_filter_table_name = "";
                    // 非ascii
                    var noSbcRegex = /[^\x20-\x7E]+/g;

                    //変換リスト
                    var replaceList = {
                        'あ':'a', 'ｂ':'b', 'ｃ':'c', 'ｄ':'d', 'え':'e', 'ｆ':'f', 'ｇ':'g', 'ｈ':'h', 
                        'い':'i', 'ｊ':'j', 'ｋ':'k', 'ｌ':'l', 'ｍ':'m', 'ｎ':'n', 'お':'o',
                        'ｐ':'p', 'ｑ':'q', 'ｒ':'r', 'ｓ':'s','ｔ':'t', 'う':'u', 'ｖ':'v', 'ｗ':'w', 'ｘ':'x', 'ｙ':'y', 'ｚ':'z',
                        '＿':'_', '＄':'$'
                    };
                    
                    /**
                     * マルチバイト入力を半角に変換する
                     */
                    var replaceMultiToSingle = function(str) {
                        var baseStr = str.replace(noSbcRegex, '');
                    
                        if (str != baseStr) {
                            Object.keys(replaceList).forEach(function(key){
                                str = str.replace(key, replaceList[key]);
                            });
                        }

                        return str;
                    };
                    
                    /**
                     * 全角で入力されたものをすべて半角に変換する。
                     */
                    var convertMultiInput = function(target) {
                        var filter_text = target.val().trim();
                        var cur = target.get(0).selectionStart;
    
                        var replaced = replaceMultiToSingle(filter_text).replace(noSbcRegex, '');
                        if (replaced != filter_text) {
                            filter_text = replaced;
                            //カーソル位置に文字を挿入
                            target.val(filter_text);
                            //カーソル位置を設定
                            target.get(0).setSelectionRange(cur+1, cur+1);
                        }

                        if (prev_filter_table_name != filter_text) {
                            prev_filter_table_name = filter_text;
                            listFilter(filter_text);
                        }
                    
                        return filter_text;
                    };

                    /**
                     * テーブル一覧のリストをフィルタ
                     */
                    var listFilter = function (filter_text) {
                        var $nav_li_list = $('#left_navigation').find('li');

                        $nav_li_list.each(function(){
                            var target_table_name = $(this).children('.nav_link').data('targetid');

                            if (-1 != target_table_name.indexOf(filter_text)) {
                                $(this).show();
                            } else {
                                $(this).hide();
                            }
                        });
                    };

                    $(function(){
                        $(document).on('click', '.nav_link', function(){
                            $('.init_table_name').hide();
                            $('#'+$(this).data('targetid')).show();

                            $('.nav_link').removeClass('selected');
                            $(this).addClass('selected');

                            return false;
                        });

                        $(document).on('click', '#filter_clear', function(){
                            $('#filter_table_name').val('').trigger('keyup');
                        });

                        $(document).on('keydown', '#filter_table_name', function(e){
                            var target = $(this);

                            if (e.originalEvent.repeat) {
                                if (-1 == $.inArray(e.keyCode, [8, 46])) {
                                   //BackSpace, Delete以外のリピートは受け付けない
                                    return false;
                                }
                            }

                            setInterval(convertMultiInput, 1, $(this));
                        });
                    });
                })();
                </script>
            </head>
            <body>
                <header>
                </header>
                <div class="container">
                    <nav id="left_navigation">
                        <h1>テーブル定義 (<xsl:value-of select="@name"/>)</h1>
                        <div class="nav_filter_block">
                            filter:<input type="url" id="filter_table_name" name="filter_table_name" style="ime-mode: disabled;" />
                            <button type="button" id="filter_clear">×</button>
                        </div>
                        <div class="nav_list_block">
                            <ul>
                                <xsl:for-each select="//database/table_structure">
                                    <li>
                                        <a class="nav_link" href="#{@name}" data-targetid="{@name}">
                                            <span class="badge post"><i class="fa fa-plus"></i></span><xsl:value-of select="@name"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </nav>

                    <div id="content">
                        <div class="init_table_name">
                            <span>◆</span>更新方法
                            <pre>
                                mysqldump --no-data --xml -u r-kojima -p -h mysql5-ssd newkima5 > mysqldump.create.xml

                                xsltproc -o db_schema_doc.html template.xslt mysqldump.create.xml

                                cp db_schema_doc.html /home/webroot/apidoc/htdocs/db.html
                            </pre>
                        </div>
                        <xsl:apply-templates select="table_structure"/>
                    </div>
                </div>
                <footer class="text-center">
                </footer>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="table_structure">
        <section id="{@name}" class="resource init_table_name" style="display: none;">
            <table class="table table-bordered htable my-table-spec">
                <tbody>
                    <tr class="active">
                        <th>テーブル名</th>
                        <td class="table_name_list"><xsl:value-of select="@name"/></td>
                    </tr>
                    <tr class="active">
                        <th>コメント</th>
                        <td><xsl:value-of select="options/@Comment"/></td>
                    </tr>
                    <tr class="active">
                        <th>文字コード</th>
                        <td><xsl:value-of select="options/@Collation"/></td>
                    </tr>
                    <tr class="active">
                        <th>エンジン</th>
                        <td><xsl:value-of select="options/@Engine"/></td>
                    </tr>
                    <tr class="active">
                        <th>作成日</th>
                        <td><xsl:value-of select="options/@Create_time"/></td>
                    </tr>
                </tbody>
            </table>

            <table class="table table-condensed my-table-detail">
                <thead>
                    <tr>
                        <th class="cell_no">#</th>
                        <th class="cell_column">カラム名</th>
                        <th class="cell_type">型</th>
                        <th class="cell_null">NULL</th>
                        <th class="cell_default">デフォルト</th>
                        <th class="cell_pri">主キー</th>
                        <th class="cell_uni">ユニーク</th>
                        <th class="cell_other">その他</th>
                        <th class="cell_comment">コメント</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="field">
                        <tr>
                            <td class="cell_no"><xsl:value-of select="position()"/></td>
                            <td class="cell_column"><xsl:value-of select="@Field"/></td>
                            <td class="cell_type"><xsl:value-of select="@Type"/></td>
                            <td class="cell_null"><xsl:if test="@Null='YES'">〇</xsl:if></td>
                            <td class="cell_default"><xsl:value-of select="@Default"/></td>
                            <td class="cell_pri"><xsl:if test="@Key='PRI'"><xsl:value-of select="@Key"/></xsl:if></td>
                            <td class="cell_uni"><xsl:if test="@Key='UNI'"><xsl:value-of select="@Key"/></xsl:if></td>
                            <td class="cell_other"><xsl:value-of select="@Extra"/></td>
                            <td class="cell_comment"><xsl:value-of select="@Comment"/></td>
                        </tr>
                    </xsl:for-each>

                </tbody>
            </table>

            <table class="table my-table-keys">
                <thead>
                    <tr>
                        <th class="cell_key_name">キー名</th>
                        <th class="cell_unique">ユニーク</th>
                        <th class="cell_column_name">対象カラム</th>
                        <th class="cell_seq_in_index">シーケンス番号</th>
                        <th class="cell_cardinality">カーディナリ</th>
                        <th class="cell_comment">コメント</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="key">
                    <tr>
                        <td class="cell_key_name"><xsl:value-of select="@Key_name"/></td>
                        <td class="cell_unique"><xsl:if test="@Non_unique='0'">〇</xsl:if></td>
                        <td class="cell_column_name"><xsl:value-of select="@Column_name"/></td>
                        <td class="cell_seq_in_index"><xsl:value-of select="@Seq_in_index"/></td>
                        <td class="cell_cardinality"><xsl:value-of select="@Cardinality"/></td>
                        <td class="cell_comment"><xsl:value-of select="@Comment"/></td>
                    </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </section>
    </xsl:template>

</xsl:stylesheet>
