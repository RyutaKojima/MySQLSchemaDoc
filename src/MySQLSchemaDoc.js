"use strict";

(function() {
	/**
	 * メニューリストの表示を管理するクラス
	 */
	var menuList = new function(){
		let prev_filter_text = "";

		/**
		 * テーブル一覧のリストをフィルタ
		 * @param filter_text
		 */
		this.filter = function (filter_text) {
			if (prev_filter_text === filter_text) {
				return;
			}

			prev_filter_text = filter_text;

			$('#left_navigation').find('li').each(function(){
				let target_table_name = $(this).children('.nav_link').data('targetid');

				let isMatched = target_table_name.match(new RegExp(filter_text, "i"));
				if (isMatched) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		};
	}();

	/**
	 * テーブル絞り込みの入力枠用の処理
	 */
	var inputFilter = new function() {
		// 非ascii文字判定の正規表現
		const noSbcRegex = /[^\x20-\x7E]+/g;

		//変換リスト
		const replaceList = {
			'あ':'a', 'ｂ':'b', 'ｃ':'c', 'ｄ':'d', 'え':'e', 'ｆ':'f', 'ｇ':'g', 'ｈ':'h',
			'い':'i', 'ｊ':'j', 'ｋ':'k', 'ｌ':'l', 'ｍ':'m', 'ｎ':'n', 'お':'o',
			'ｐ':'p', 'ｑ':'q', 'ｒ':'r', 'ｓ':'s','ｔ':'t', 'う':'u', 'ｖ':'v', 'ｗ':'w', 'ｘ':'x', 'ｙ':'y', 'ｚ':'z',
			'＿':'_', '＄':'$'
		};

		/**
		 * マルチバイト入力を半角に変換する
		 */
		let replaceMultiToSingle = function (str) {
			let baseStr = str.replace(noSbcRegex, '');

			if (str !== baseStr) {
				Object.keys(replaceList).forEach(function(key){
					str = str.replace(key, replaceList[key]);
				});
			}

			return str;
		};

		/**
		 * 全角で入力されたものをすべて半角に変換する。
		 */
		this.convertMultiInput = function ($target) {
			let filter_text = $target.val().trim();
			let cur = $target.get(0).selectionStart;
			let replaced = replaceMultiToSingle(filter_text).replace(noSbcRegex, '');
			if (replaced != filter_text) {
				filter_text = replaced;
				$target.val(filter_text);
				$target.get(0).setSelectionRange(cur+1, cur+1);		//カーソル位置を設定
			}

			return filter_text;
		};
	}();

	/**
	 * jQuery ready
	 */
	$(function(){
		$(document).on('click', '.nav_link', function(){
			$('.each_table_structure').hide();
			$('#'+$(this).data('targetid')).show();

			$('.selected').removeClass('selected');
			$(this).addClass('selected');

			return false;
		});

		$(document).on('click', '#filter_clear', function(){
			$('#filter_table_name').val('').trigger('keydown');
		});

		$(document).on('keydown', '#filter_table_name', function(e){
			if ('originalEvent' in e && e.originalEvent.repeat) {
				if (-1 == $.inArray(e.keyCode, [8, 46])) {
					//BackSpace, Delete以外のリピートは受け付けない
					return false;
				}
			}

			//setTimeoutを挟まないと、$(this).val()の値がこのタイミングではまだ変わっていない。
			setTimeout(function($target){
				menuList.filter(inputFilter.convertMultiInput($target));
			}, 1, $(this));
		});
	});
})();