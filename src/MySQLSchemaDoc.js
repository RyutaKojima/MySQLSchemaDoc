/**
 * Created by r-kojima on 2017/01/24.
 */

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