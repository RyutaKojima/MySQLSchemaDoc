<?xml version="1.0" encoding="utf8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="http://sqlfairy.sourceforge.net/sqlfairy.xml">
    <xsl:output method="html" encoding="utf8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

    <xsl:template match="database">
        <html lang="ja">
            <head>
                <meta charset="utf-8"/>
                <title>テーブル定義書 - <xsl:value-of select="@name"/></title>
                <link type="text/css" rel="stylesheet" href="http://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" />
                <link type="text/css" rel="stylesheet" href="./split-pane.css" />
                <link type="text/css" rel="stylesheet" href="MySQLSchemaDoc.css" />
                <script src="http://code.jquery.com/jquery-3.1.1.min.js" />
                <script src="http://code.jquery.com/ui/1.12.1/jquery-ui.min.js" integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=" crossorigin="anonymous" />
                <script src="./split-pane.js" />
                <script src="./MySQLSchemaDoc.js" />
            </head>
            <body>
                <div class="container split-pane fixed-left">

                    <nav id="left_navigation" class="border_radius split-pane-component">
                        <h1>テーブル定義 (<xsl:value-of select="@name"/>)</h1>
                        <div class="nav_filter_block">
                            <input type="url" id="filter_table_name" name="filter_table_name" style="ime-mode: disabled;" 
                                                       placeholder="テーブル名で絞り込み" title="・正規表現OK・スペース区切りでAND絞り込み" />
                            <button type="button" id="filter_clear">×</button>
                            <span id="filtered_item_count">0</span>
                        </div>
                        <div class="nav_list_block">
                            <ul>
                                <xsl:for-each select="//database/table_structure">
                                    <li class="nav_link" data-targetid="{@name}">
                                        <span><xsl:value-of select="@name"/></span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </nav>

                    <div class="split-pane-divider" id="divider"></div>

                    <div id="content" class="border_radius split-pane-component">
                        <div class="each_table_structure">
                            <span>◆</span>更新方法
                            <pre>
                                mysqldump --no-data --xml -u {user_name} -p -h {host_name} {database_name} > mysqldump_create.xml
                                xsltproc -o index.html MySQLSchemaDoc.xslt mysqldump_create.xml
                            </pre>
                        </div>
                        <xsl:apply-templates select="table_structure"/>
                    </div>

                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="table_structure">
        <section id="{@name}" class="resource each_table_structure" style="display: none;">
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
