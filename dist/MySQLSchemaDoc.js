"use strict";

(function() {
	let optionsDataTable = {
		forDefault: {
			language: {
				url: "https://cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Japanese.json"
			},
			displayLength: 5000,		// 表示件数
			lengthChange: false,		// 件数切替機能
			searching:    true,			// 検索機能
			ordering:     true,			// ソート機能
			info:         false,		// 左下の情報表示
			paging:       false,		// ページング機能 無効
		},
		forDetail: {
			// scrollY: "580px",			// 縦スクロールバーを有効にする (scrollYは200, "200px"など「最大の高さ」を指定します)
			// 列設定
			columnDefs: [
				{targets: "cell_no",      width: 30},
				{targets: "cell_column",  width: 300},
				{targets: "cell_type",    width: 170},
				{targets: "cell_null",    width: 50},
				{targets: "cell_default", width: 90},
				{targets: "cell_pri",     width: 50},
				{targets: "cell_uni",     width: 50},
				{targets: "cell_other",   width: 170},
				{targets: "cell_comment", width: 300},
			]
		},
		forKeys: {
			// scrollY: "140px",			// 縦スクロールバーを有効にする (scrollYは200, "200px"など「最大の高さ」を指定します)
			lengthChange: false,		// 件数切替機能
			searching:    true,			// 検索機能
			ordering:     false,		// ソート機能
			info:         false,		// 左下の情報表示
			paging:       false,		// ページング機能 無効
			columnDefs: [
				{targets: "cell_key_name",     width: 100},
				{targets: "cell_unique",       width: 60},
				{targets: "cell_column_name",  width: 300},
				{targets: "cell_seq_in_index", width: 120},
				{targets: "cell_cardinality",  width: 100},
				{targets: "cell_comment",      width: 600},
			]
		},
	};

	/**
	 * メニューリストの表示を管理するクラス
	 */
	let menuList = new function(){
		let prev_filter_text = null;

		/**
		 * テーブル一覧のリストをフィルタ
		 * 
		 * @param filter_text
		 * @returns {null|Array} 一覧に表示している項目の配列。前回と変更がない場合はnull
		 */
		this.filterList = function (filter_text) {
			if (prev_filter_text === filter_text) {
				return null;
			}
			prev_filter_text = filter_text;

			let displayed_items = [];
			$('#left_navigation').find('li.nav_link').each(function(){
				let target_table_name = $(this).text();

				let isMatched = true;
				for (let filter_split of filter_text.split(' ')) {
					if ( ! target_table_name.match(new RegExp(filter_split, "i"))) {
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
			$('#filtered_item_count').text(count);
		}
	}();

	/**
	 * jQuery ready
	 */
	$(function(){
		// DataTablesのデフォルト設定を変更
		$.extend( $.fn.dataTable.defaults, optionsDataTable.forDefault);

		$(document).on('click', '.nav_link', function(){
			let target_table_name = $(this).text();
			let $section = $('#'+target_table_name);

			$('.each_table_structure').hide();
			$section.show();

			$section.children('.my-table-detail').children('table').dataTable(optionsDataTable.forDetail);
			$section.children('.my-table-keys').children('table').dataTable(optionsDataTable.forKeys);

			$('.selected').removeClass('selected');
			$(this).addClass('selected');
		});

		$(document).on('click', '#filter_clear', function(){
			$('#filter_table_name').val('').trigger('keydown').focus();
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
				let displayed_items = menuList.filterList(inputFilter.convertMultiInput($target));
				if (displayed_items !== null) {
					let displayed_count = displayed_items.length;
					inputFilter.setDisplayedItemsCount(displayed_count);

					//絞り込みの結果、１件ならばその項目を自動で選択する
					if (displayed_count === 1) {
						displayed_items[0].trigger('click');
					}
				}
			}, 1, $(this));
		});

		$(document).tooltip({
			position: { my: "left center", at: "right center"},
			show: { effect: "blind", duration: 100 },
			hide: { effect: "blind", duration: 100 },
			close: function( event, ui ) {
				$('div.ui-helper-hidden-accessible').empty();
			}
		});

		$('div.split-pane').splitPane();

		$('#all_item_count').text( $('.nav_link').length );

		// chrome, firefoxの再起動、firefoxのリロード時などフォーム情報が残った状態でページが開く状況でも
		// 正常動作させるために、トリガー起動
		$('#filter_table_name').trigger('keydown');
	});
})();