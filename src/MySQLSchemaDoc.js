"use strict";

(function() {
	/**
	 * メニューリストの表示を管理するクラス
	 */
	let menuList = new function(){
		let prev_filter_text = "";

		/**
		 * テーブル一覧のリストをフィルタ
		 * 
		 * @param filter_text
		 * @returns {null|Array} 一覧に表示している項目の配列。前回と変更がない場合はnull
		 */
		this.filter = function (filter_text) {
			if (prev_filter_text === filter_text) {
				return null;
			}
			prev_filter_text = filter_text;

			let displayed_items = [];
			$('#left_navigation').find('li').each(function(){
				let target_table_name = $(this).children('.nav_link').data('targetid');

				let isMatched = true;
				for (let filter of filter_text.split(' ')) {
					if ( ! target_table_name.match(new RegExp(filter, "i"))) {
						isMatched = false;
						break;
					}
				}

				if (isMatched) {
					$(this).show();
					displayed_items.push($(this));
				} else {
					$(this).hide();
				}
			});

			return displayed_items;
		};
	}();

	/**
	 * テーブル絞り込みの入力枠用の処理
	 */
	let inputFilter = new function() {
		// 非ascii文字判定の正規表現
		const noSbcRegex = /[^\x20-\x7E]+/g;

		//変換リスト
		const replaceList = {
			'あ':'a', 'ｂ':'b', 'ｃ':'c', 'ｄ':'d', 'え':'e', 'ｆ':'f', 'ｇ':'g', 'ｈ':'h',
			'い':'i', 'ｊ':'j', 'ｋ':'k', 'ｌ':'l', 'ｍ':'m', 'ｎ':'n', 'お':'o',
			'ｐ':'p', 'ｑ':'q', 'ｒ':'r', 'ｓ':'s','ｔ':'t', 'う':'u', 'ｖ':'v', 'ｗ':'w', 'ｘ':'x', 'ｙ':'y', 'ｚ':'z',
			'＿':'_', '＄':'$', '　':' '
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
		/**
		 * 表示中の項目数を設定する
		 * @param count
		 */
		this.setDisplayedItemsCount = function (count) {
			$('#filtered_item_count').text(count + '件');
		}
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
				let displayed_items = menuList.filter(inputFilter.convertMultiInput($target));
				if (displayed_items !== null) {
					let displayed_count = displayed_items.length;
					inputFilter.setDisplayedItemsCount(displayed_count);

					//絞り込みの結果、１件ならばその項目を自動で選択する
					if (displayed_count === 1) {
						displayed_items[0].find('.nav_link').trigger('click');
					}
				}
			}, 1, $(this));
		});

		$(document).tooltip({
			position: { my: "center bottom", at: "center top"},
			show: { effect: "blind", duration: 100 },
			hide: { effect: "blind", duration: 100 },
			close: function( event, ui ) {
				$('div.ui-helper-hidden-accessible').empty();
			}
		});

		// chrome, firefoxの再起動、firefoxのリロード時などフォーム情報が残った状態でページが開く状況でも
		// 正常動作させるために、トリガー起動
		$('#filter_table_name').trigger('keydown');
	});
})();