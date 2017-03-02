function align_fixed_table_row ($selected_row) {
	var height = $selected_row.height(),
		p_max_height = height - 6,
		$equivalent_row = $selected_row.parents('.first_coll_fixed_table:first').find('.fixed_table tr:eq(' + $selected_row.index() + ')');

	$('> td >p', $equivalent_row).css('maxHeight', p_max_height);

	$equivalent_row.height(height);
}

eds1_8(document).ready(function ($) {
	var $edn_admin = $('#EDNadmin'),
		$body = $('body'),
		$form = $('> form', $body),
		$gridview_content_manager = $edn_admin.find('div.gridview_content_manager'),
		$module_settings = $edn_admin.find('.module_settings'),
		$first_coll_fixed_table = $module_settings.find('.first_coll_fixed_table'),

		localization = $.extend(true, {
			image_token_editor_title: 'Customize gallery item token',
			image_token_editor_close: 'Close',

			gmaps_token_editor_add_map: 'Add as article map',
			gmaps_token_editor_close: 'Close',
			gmaps_token_editor_title: 'Add Google Maps location',
			gmaps_token_editor_edit_marker: 'Edit',
			gmaps_token_editor_edit_marker_editor_title: 'Add map marker',
			gmaps_token_editor_edit_marker_latitude: 'Latitude:',
			gmaps_token_editor_edit_marker_langitude: 'Longitude:',
			gmaps_token_editor_edit_marker_center: 'Center on map',
			gmaps_token_editor_edit_marker_title_required_warning: 'A title is required',
			gmaps_token_editor_edit_marker_marker_title: 'Title:',
			gmaps_token_editor_edit_marker_marker_html: 'HTML: (optional)',
			gmaps_token_editor_edit_marker_button_confirm: 'Confirm',
			gmaps_token_editor_edit_marker_button_cancel: 'Cancel'
		}, typeof edn_admin_localization == 'undefined' ? {} : edn_admin_localization),

		google_map_settings = {
			map_type: 'HYBRID',
			latitude: 48.965794,
			longitude: 14.765625,
			zoom: 4,
			scrollwheel: true,
			width: 400,
			height: 300
		},

		google_maps_token = function (token) {
			var $window = $(window),
				$google_maps = $('.content_token_generator.google_maps'),
				$dialog_wrapper = $google_maps.find('> .dialog_wrapper'),
				$pages_container = $dialog_wrapper.find('> .pages_container'),
				$pages = $pages_container.find('> .page'),
				$location_search = $pages.find('> .location_search'),
				$map_container = $pages.find('> .map_container'),
				$token_settings = $pages.find('> .token_settings'),
				$settings_wrapper = $token_settings.find('> .settings_wrapper'),
				$settings_pages = $settings_wrapper.find('> .page'),
				$the_map = $('<div class="the_map" />'),

				unique_marker_id = 0,

				map_markers = [],

				askForLocation = typeof window.edn_geolocation_request == 'boolean' ? window.edn_geolocation_request : true,

				map_marker_editor = function (edit_marker) {
					var $add_marker_page,
						page_content = '<div class="page add_marker" style="width: ' + token_settings_dimensions.width + 'px; height: ' + token_settings_dimensions.height + 'px;">' +
							'<h1>' + localization.gmaps_token_editor_edit_marker_editor_title + '</h1>' +
							'<p class="option"><label for="edn_maps_token_marker_latitude">' + localization.gmaps_token_editor_edit_marker_latitude + '</label> <input type="text" value="" id="edn_maps_token_marker_latitude" name="latitude"></p>' +
							'<p class="option"><label for="edn_maps_token_marker_longitude">' + localization.gmaps_token_editor_edit_marker_langitude + '</label> <input type="text" value="" id="edn_maps_token_marker_longitude" name="longitude"></p>' +
							'<p class="option"><button type="button" class="center_on_map ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" name="center_on_map">' + localization.gmaps_token_editor_edit_marker_center + '</button></p>' +
							'<p class="option margin_3 required_field">' + localization.gmaps_token_editor_edit_marker_title_required_warning + '</p>' +
							'<p class="option"><label for="edn_maps_token_marker_title">' + localization.gmaps_token_editor_edit_marker_marker_title + '</label> <input type="text" value="" id="edn_maps_token_marker_title" name="title"></p>' +
							'<p class="option no_margin"><label for="edn_maps_token_marker_html">' + localization.gmaps_token_editor_edit_marker_marker_html + '</label></p>' +
							'<p class="option"><textarea class="html" name="html" id="edn_maps_token_marker_html" rows="20" cols="30"></textarea></p>' +
							'<p class="option actions"><button type="button" class="confirm ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only">' + localization.gmaps_token_editor_edit_marker_button_confirm + '</button>' +
							'<button type="button" class="cancel ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only">' + localization.gmaps_token_editor_edit_marker_button_cancel + '</button></p>' +
							'</div>',
						the_marker,

						$cancel,
						$confirm,

						$marker_latitude,
						$marker_longitude,
						$marker_center_on_map,
						$marker_title,
						$marker_title_required,
						$marker_html,

						marker_settings,
						marker_settings_backup,

						close_page = function () {
							google.maps.event.clearListeners(the_marker, 'position_changed');

							$settings_wrapper
								.stop()
								.animate({
									left: 0
								}, 300, function () {
									$add_marker_page.remove();
									$settings_wrapper.width(token_settings_dimensions.width);
									$token_settings.data('second_page_active', false);
								});
						};

					if ($token_settings.data('second_page_active'))
						return false;

					$token_settings.data('second_page_active', true);

					if (edit_marker) {
						marker_settings = edit_marker._meta;
						marker_settings_backup = $.extend({}, marker_settings);
						the_marker = edit_marker.marker;

						if (edit_marker.info) {
							edit_marker.info.close();
							edit_marker.info = null;
						}

						google.maps.event.clearListeners(the_marker, 'click');

						the_marker.setDraggable(true);
					} else {
						marker_settings = {
							latitude: google_map_settings.latitude,
							longitude: google_map_settings.longitude,
							title: '',
							html: ''
						};

						the_marker = new google.maps.Marker({
							position: new google.maps.LatLng(marker_settings.latitude, marker_settings.longitude),
							map: window.edn_map_token_obj,
							draggable: true
						});
					}

					the_marker.setIcon(window.edn_module_root + 'images/icons/marker_animirani.gif');

					$add_marker_page = $(page_content);

					$settings_wrapper
						.append($add_marker_page)
						.width(2 * token_settings_dimensions.width)
						.animate({
							left: -token_settings_dimensions.width
						}, 300);

					$settings_pages = $settings_wrapper.find('> .page');

					$marker_latitude = $add_marker_page.find('input[name="latitude"]');
					$marker_longitude = $add_marker_page.find('input[name="longitude"]');
					$marker_center_on_map = $add_marker_page.find('button[name="center_on_map"]');
					$marker_title = $add_marker_page.find('input[name="title"]');
					$marker_title_required = $add_marker_page.find('p.option.required_field');
					$marker_html = $add_marker_page.find('textarea[name="html"]');

					if (edit_marker) {
						$marker_title.val(marker_settings.title);
						$marker_html.val(marker_settings.html);
					}

					google.maps.event.addListener(the_marker, 'position_changed', function () {
						var position = the_marker.getPosition();

						marker_settings.latitude = position.lat();
						marker_settings.longitude = position.lng();

						$marker_latitude.val(marker_settings.latitude);
						$marker_longitude.val(marker_settings.longitude);
					});

					$marker_latitude
						.val(marker_settings.latitude)
						.bind('keyup', function () { $marker_latitude.trigger('change'); })
						.bind('change', function () {
							var new_val = parseFloat(this.value);

							if (!new_val || isNaN(new_val))
								return false;

							the_marker.setPosition(new google.maps.LatLng(new_val, marker_settings.longitude));

							return false;
						});

					$marker_longitude
						.val(marker_settings.longitude)
						.bind('keyup', function () { $marker_longitude.trigger('change'); })
						.bind('change', function () {
							var new_val = parseFloat(this.value);

							if (!new_val || isNaN(new_val))
								return false;

							the_marker.setPosition(new google.maps.LatLng(marker_settings.latitude, new_val));

							return false;
						});

					$marker_center_on_map.click(function () {
						the_marker.setPosition(window.edn_map_token_obj.getCenter());

						return false;
					});


					$confirm = $add_marker_page.find('> .option.actions > .confirm');
					$cancel = $add_marker_page.find('> .option.actions > .cancel');

					$confirm.click(function () {
						var info,
							title = $marker_title.val().replace(/^\s\s*/, '').replace(/\s\s*$/, '');

						if (!title) {
							$marker_title_required.fadeIn(300);
							$marker_title.focus();

							return false;
						}

						marker_settings.title = $('<div />').text(title).html();
						marker_settings.html = $marker_html.val();

						the_marker.setDraggable(false);
						the_marker.setTitle(marker_settings.title);

						if (marker_settings.html) {
							info = new google.maps.InfoWindow({
								content: marker_settings.html
							});

							google.maps.event.addListener(the_marker, 'click', function() {
								info.open(window.edn_map_token_obj, the_marker);
							});
						}

						if (edit_marker) {
							edit_marker = {
								marker: the_marker,
								'info': info,
								_meta: marker_settings
							};
						} else {
							google.maps.event.addListener(the_marker, 'mouseover', function () {
								for (var i = 0, l = map_markers.length; i < l; i++) {
									if (map_markers[i].marker.get('id') == this.get('id')) {
										$map_markers.find('.marker').eq(m).addClass('hover');

										return;
									}
								}
							});

							google.maps.event.addListener(the_marker, 'mouseout', function () {
								for (var i = 0, l = map_markers.length; i < l; i++) {
									if (map_markers[i].marker.get('id') == this.get('id')) {
										$map_markers.find('.marker').eq(m).removeClass('hover');

										return;
									}
								}
							});

							the_marker.setValues({id: unique_marker_id++});

							map_markers.push({
								marker: the_marker,
								'info': info,
								_meta: marker_settings
							});
						}

						the_marker.setIcon(null);

						update_markers_list();

						close_page();

						return false;
					});

					$cancel.click(function () {
						if (edit_marker) {
							var info;

							the_marker.setDraggable(false);
							the_marker.setPosition(new google.maps.LatLng(marker_settings_backup.latitude, marker_settings_backup.longitude));

							if (marker_settings_backup.html) {
								info = new google.maps.InfoWindow({
									content: marker_settings_backup.html
								});

								google.maps.event.addListener(the_marker, 'click', function() {
									info.open(window.edn_map_token_obj, the_marker);
								});
							}

							the_marker.setIcon(null);
						} else
							the_marker.setMap(null);

						close_page();

						return false;
					});

					return false;
				},

				generate_map_object = function () {
					var marker,
						info,
						$place_search_input = $('#map_location_search');
						location_search = new google.maps.places.Autocomplete($place_search_input[0]);

					window.edn_map_token_obj = new google.maps.Map($the_map[0], {
							center: new google.maps.LatLng(google_map_settings.latitude, google_map_settings.longitude),
							scrollwheel: google_map_settings.scrollwheel,
							zoom: google_map_settings.zoom,
							panControl: true,
							zoomControl: true,
							mapTypeControl: false,
							scaleControl: true,
							streetViewControl: false,
							overviewMapControl: true,
							mapTypeId: google.maps.MapTypeId[google_map_settings.map_type]
						});

					if (editing_mode) {
						for (var i = 0, l = map_markers.length; i < l; i++) {
							marker = new google.maps.Marker({
								position: new google.maps.LatLng(map_markers[i]._meta.latitude, map_markers[i]._meta.longitude),
								map: window.edn_map_token_obj,
								draggable: false,
								title: map_markers[i]._meta.title
							});

							marker.setValues({id: unique_marker_id++});

							if (map_markers[i]._meta.html) {
								info = new google.maps.InfoWindow({
									content: map_markers[i]._meta.html
								});

								google.maps.event.addListener(marker, 'click', function() {
									info.open(window.edn_map_token_obj, marker);
								});
							}

							google.maps.event.addListener(marker, 'mouseover', function () {
								for (var j = 0, l = map_markers.length; j < l; j++) {
									if (map_markers[j].marker.get('id') == this.get('id')) {
										$map_markers.find('.marker').eq(m).addClass('hover');

										return;
									}
								}
							});

							google.maps.event.addListener(marker, 'mouseout', function () {
								for (var j = 0, l = map_markers.length; j < l; j++) {
									if (map_markers[j].marker.get('id') == this.get('id')) {
										$map_markers.find('.marker').eq(m).removeClass('hover');

										return;
									}
								}
							});

							map_markers[i].marker = marker;
							map_markers[i].info = info;
						}
					}

					google.maps.event.addListener(window.edn_map_token_obj, 'zoom_changed', function() {
						google_map_settings.zoom = window.edn_map_token_obj.getZoom();
						$map_zoom.val(google_map_settings.zoom);
					});

					google.maps.event.addListener(window.edn_map_token_obj, 'center_changed', function() {
						var map_center = window.edn_map_token_obj.getCenter();
						google_map_settings.latitude = map_center.lat();
						google_map_settings.longitude = map_center.lng();

						$map_latitude.val(google_map_settings.latitude);
						$map_longitude.val(google_map_settings.longitude);
					});

					$map_type_select.val(google_map_settings.map_type.toLowerCase());

					$map_zoom.val(google_map_settings.zoom);

					google_map_settings.latitude = window.edn_map_token_obj.getCenter().lat();
					$map_latitude.val(google_map_settings.latitude);

					google_map_settings.longitude = window.edn_map_token_obj.getCenter().lng();
					$map_longitude.val(google_map_settings.longitude);

					$map_scrollwheel[0].checked = google_map_settings.scrollwheel;

					$map_width.val(google_map_settings.width);
					$map_height.val(google_map_settings.height);

					if (!$google_maps.data('initialized')) {
						$google_maps.data('initialized', true);

						$map_type_select
							.bind('change', function () {
								google_map_settings.map_type = $map_type_select.val().toUpperCase();
								window.edn_map_token_obj.setMapTypeId(google.maps.MapTypeId[google_map_settings.map_type]);

								return true;
							});

						$map_zoom
							.bind('keyup', function () { $map_zoom.trigger('change'); })
							.bind('change', function () {
								var new_val = parseInt(this.value);

								if (!new_val)
									return true;

								if (isNaN(new_val) || new_val < 0)
									new_val = 0

								window.edn_map_token_obj.setZoom(new_val);

								return true;
							});

						$map_latitude
							.bind('keyup', function () { $map_latitude.trigger('change'); })
							.bind('change', function () {
								var new_val = parseFloat(this.value);

								if (!new_val || isNaN(new_val))
									return false;

								window.edn_map_token_obj.setCenter(new google.maps.LatLng(new_val, google_map_settings.longitude));

								return false;
							});

						$map_longitude
							.bind('keyup', function () { $map_longitude.trigger('change'); })
							.bind('change', function () {
								var new_val = parseFloat(this.value);

								if (!new_val || isNaN(new_val))
									return false;

								window.edn_map_token_obj.setCenter(new google.maps.LatLng(google_map_settings.latitude, new_val));

								return false;
							});

						$map_scrollwheel.bind('change', function () {
							google_map_settings.scrollwheel = this.checked;
						});

						$map_width
							.bind('keyup', function () { $map_width.trigger('change'); })
							.bind('change', function () {
								var new_val = parseInt(this.value);

								if (!new_val || isNaN(new_val))
									return false;

								google_map_settings.width = new_val;
							});

						$map_height
							.bind('keyup', function () { $map_height.trigger('change'); })
							.bind('change', function () {
								var new_val = parseInt(this.value);

								if (!new_val || isNaN(new_val))
									return false;

								google_map_settings.height = new_val;
							});
					}

					$add_marker_trigger.click(function () { map_marker_editor(); });

					location_search.bindTo('bounds', window.edn_map_token_obj);

					$place_search_input.focus(function () {
						$('body > .pac-container').css('z-index', 1003);
					});

					google.maps.event.addListener(location_search, 'place_changed', function() {
						var place = location_search.getPlace();

						if (!place.geometry)
							return;

						if (place.geometry.viewport)
							window.edn_map_token_obj.fitBounds(place.geometry.viewport);
						else {
							window.edn_map_token_obj.setCenter(place.geometry.location);
							window.edn_map_token_obj.setZoom(17);
						}
					});
				},
				dialog_height = Math.round(.8 * $window.height()),
				dialog_width = Math.round(.8 * $window.width()),
				close_dialog = function () {
					if ($token_settings.data('second_page_active')) {
						$token_settings.data('second_page_active', false);
						$settings_pages.eq(1).remove();
						$settings_pages = $settings_wrapper.find('> .page');
						$settings_wrapper.css({
							width: token_settings_dimensions.width,
							left: 0
						});
					}

					$add_marker_trigger.unbind('click');
					$map_delete_selected_marker.unbind('click');
					$generate_token.unbind('click');
					$back_to_editor.unbind('click');

					$map_markers.undelegate();

					$map_markers.html('');
					$map_marker_container.css({
						display: 'none'
					});

					$google_maps.dialog('destroy');
					$the_map.remove();
					google.maps.event.clearInstanceListeners(window.edn_map_token_obj);
					window.edn_map_token_obj = null;

					if ($google_maps.data('token_area_active'))
						reset_token_area();

					$body.css({
						overflow: '',
						position: ''
					});

					$form.removeClass('removeTopMargin');
				},
				dimensions,
				token_settings_dimensions,

				$map_type_select = $token_settings.find('select[name="map_type"]'),
				$map_zoom = $token_settings.find('input[name="zoom"]'),
				$map_latitude = $token_settings.find('input[name="latitude"]'),
				$map_longitude = $token_settings.find('input[name="longitude"]'),
				$map_scrollwheel = $token_settings.find('input[name="scrollwheel"]'),
				$map_width = $token_settings.find('input[name="width"]'),
				$map_height = $token_settings.find('input[name="height"]'),

				$add_marker_trigger = $token_settings.find('.add_marker_trigger'),
				$map_marker_container = $token_settings.find('.map_marker_container'),
				$map_delete_selected_marker = $map_marker_container.find('> .delete_selected'),
				$map_markers = $map_marker_container.find('> .marker_list'),

				update_markers_list = function () {
					var markers_html = '';

					if (map_markers.length) {
						$map_marker_container.css({
							display: 'block'
						});

						for (var i = 0, l = map_markers.length; i < l; i++) {
							markers_html += '<div class="marker">'+
								'<input type="checkbox" name="check_marker" value="1" /><a href="#" class="marker_title">' + map_markers[i]._meta.title + '</a> - <a href="#" class="edit">' + localization.gmaps_token_editor_edit_marker + '</a>'+
								'</div>';
						};

						$map_markers.html(markers_html);
					} else {
						$map_marker_container.hide(200);
					}
				},

				$generate_token = $token_settings.find('button.generate_token'),
				$token_area = $dialog_wrapper.find('.token_area'),
				$the_token = $token_area.find('textarea.the_token'),
				$back_to_editor = $token_area.find('button.back_to_editor'),

				encode_for_token = function (s) {
					s = s
						.replace('&', '&#38;')
						.replace('[', '&#91;')
						.replace(']', '&#93;')
						.replace('|', '&#124;')
						.replace('(', '&#40;')
						.replace(')', '&#41;')
						.replace('*', '&#42;');

					return s;
				}

				decode_from_token = function (s) {
					s = s
						.replace('&#38;', '&')
						.replace('&#91;', '[')
						.replace('&#93;', ']')
						.replace('&#124;', '|')
						.replace('&#40;', '(')
						.replace('&#41;', ')')
						.replace('&#42;', '*');

					return s;
				}

				generate_token = function () {
					var token = '[GoogleMap|',
						m,
						meta;

					token += google_map_settings.latitude + ':' + google_map_settings.longitude + '|';
					token += 'type:' + google_map_settings.map_type + '|';
					token += 'zoom:' + google_map_settings.zoom + '|';
					token += 'scrollwheel:' + google_map_settings.scrollwheel + '|';
					token += 'width:' + google_map_settings.width + '|';
					token += 'height:' + google_map_settings.height + '|';

					for (var i = 0, l = map_markers.length; i < l; i++) {
						meta = map_markers[i]._meta;

						token += '(' + meta.latitude + ':' + meta.longitude + '*' + encode_for_token(meta.title) + '*' + encode_for_token(meta.html) + ')';
					}

					return token + ']';
				},

				show_token_area = function () {
					var tokenString = generate_token();

					$google_maps.data('token_area_active', true);

					$the_token.text(tokenString);

					$token_area
						.fadeTo(0, 1)
						.animate({
							top: 0,
							right: 0
						}, 300);
				},

				reset_token_area = function (animate) {
					$google_maps.data('token_area_active', false);

					var reset_area = function () {
							$token_area.css({
								top: '-100%',
								right: '-100%'
							});
							$the_token.html('');
						};

					if (animate) {
						$token_area.fadeTo(500, 0, reset_area);
					} else
						reset_area();
				},

				editing_mode = token && token != '' ? true : false;

			if (editing_mode) {
				(function () {
					var token_parts,
						lat_lng,
						markers_string,
						markers,
						value_pairs,
						marker_settings,
						p;

					if (token.substring(0, 11) != '[GoogleMap|' || token.substring(token.length - 1) != ']')
						return;

					token_parts = token.substring(0, token.length - 1).substring(11).split('|');

					lat_lng = token_parts.splice(0, 1)[0].split(':');
					markers_string = token_parts.splice(token_parts.length - 1, 1)[0];

					google_map_settings.latitude = parseFloat(lat_lng[0]);
					google_map_settings.longitude = parseFloat(lat_lng[1]);

					for (var i = 0, l = token_parts.length; i < l; i++) {
						p = token_parts[i].split(':');

						if (p[0] == 'zoom' || p[0] == 'width' || p[0] == 'height')
							google_map_settings[p[0]] = parseInt(p[1]);
						else if (p[0] == 'scrollwheel')
							google_map_settings[p[0]] = p[1] == 'true' ? true : false;
						else if (p[0] == 'type')
							google_map_settings['map_type'] = p[1];
						else
							google_map_settings[p[0]] = p[1];
					}

					if (markers_string != '') {
						map_markers = [];

						markers = markers_string.split(')');

						for (var i = 0, l = markers.length; i < l; i++) {
							value_pairs = markers[i].substring(1).split('*');

							if (value_pairs.length == 1)
								break;

							lat_lng = value_pairs[0].split(':');

							marker_settings = {
								latitude: lat_lng[0],
								longitude: lat_lng[1],
								title: decode_from_token(value_pairs[1]),
								html: decode_from_token(value_pairs[2])
							};

							map_markers.push({
								marker: null,
								info: null,
								_meta: marker_settings
							});
						}
					}
				})();
				update_markers_list();
			}

			$body.css({
				overflow: 'hidden',
				position: 'relative'
			});

			$form.addClass('removeTopMargin');

			dialog_width = dialog_width < 500 ? 500 : dialog_width;
			dialog_width = dialog_width > 1200 ? 1200 : dialog_width;

			dialog_height = dialog_height < 300 ? 300 : dialog_height;
			dialog_height = dialog_height > 700 ? 700 : dialog_height;

			$google_maps.dialog({
				buttons: [
					{
						text: localization.gmaps_token_editor_add_map,
						click: function () {
							var $container = $('#EDNadmin .google_maps_main > .content.google_maps');

							$('> input[type="hidden"]', $container).val(generate_token());

							$('> div.no_map', $container).hide(0);
							$('> div.map_set', $container).show(0);

							close_dialog();
						}
					},
					{
						text: localization.gmaps_token_editor_close,
						click: close_dialog
					}
				],
				close: close_dialog,
				height: dialog_height,
				width: dialog_width,
				modal: true,
				resizable: false,
				title: localization.gmaps_token_editor_title
			});

			$map_markers
				.delegate('input[type="checkbox"]', 'click', function () {
					var $checked_markers = $map_markers.find('input[type="checkbox"]:checked');

					if ($checked_markers.length)
						$map_delete_selected_marker.stop().fadeTo(200, 1);
					else
						$map_delete_selected_marker.stop().fadeTo(200, 0);
				})
				.delegate('a.marker_title', 'click', function () {
					window.edn_map_token_obj.setCenter(map_markers[$(this).parent().index()].marker.getPosition());

					return false;
				})
				.delegate('a.edit', 'click', function () {
					map_marker_editor(map_markers[$(this).parent().index()]);

					return false;
				})
				.delegate('.marker', 'mouseenter', function () {
					var icon = new google.maps.MarkerImage(window.edn_module_root + 'images/icons/marker_select.png',
						new google.maps.Size(20, 32),
						new google.maps.Point(0,0),
						new google.maps.Point(10, 34));
					map_markers[$(this).index()].marker.setIcon(icon);
				})
				.delegate('.marker', 'mouseleave', function () {
					map_markers[$(this).index()].marker.setIcon(null);
				});

			$map_delete_selected_marker.click(function () {
				var $checked_markers = $map_markers.find('input[type="checkbox"]:checked');

				$checked_markers.each(function (i) {
					var $current = $checked_markers.eq(i).parent(),
						index = $current.index();

					map_markers[index].marker.setMap(null);

					if (map_markers[index].info)
						map_markers[index].info.close();

					$current.remove();

					map_markers.splice(index, 1);
				});

				update_markers_list();

				return false;
			});

			dimensions = {
				width: Math.floor($google_maps.width()),
				height: Math.floor($google_maps.height())
			};

			$dialog_wrapper.css(dimensions);

			$pages_container
				.width($pages.length * dimensions.width)
				.height(dimensions.height);

			$pages.css(dimensions);

			$map_container
				.css({
					width: dimensions.width - $token_settings.outerWidth(true),
					height: dimensions.height - $location_search.height()
				})
				.append($the_map);

			token_settings_dimensions = {
				width: $settings_wrapper.width(),
				height: dimensions.height
			};

			$token_settings.height(token_settings_dimensions.height);

			$settings_pages.width(token_settings_dimensions.width);

			if (askForLocation && navigator.geolocation && !editing_mode) {
				navigator.geolocation.getCurrentPosition(function(p) {
					google_map_settings.latitude = p.coords.latitude;
					google_map_settings.longitude = p.coords.longitude;
					google_map_settings.zoom = 14;
					generate_map_object();
				}, function () {
					generate_map_object();
				});
			} else
				generate_map_object();

			$generate_token
				.click(function () {
					show_token_area();
				});

			$back_to_editor
				.click(function () {
					reset_token_area(true);
				});
		};

	$gridview_content_manager.delegate('.content_filter_toggle > .filter_toggle', 'click', function () {
		var $toggle = $(this),
			$filter_settings = $toggle.parent().siblings('.content_filter_settings'),
			$filter_settings_state = $filter_settings.find('> input[type="hidden"]');

		if ($toggle.hasClass('open')) {
			$toggle.removeClass('open');
			$filter_settings.slideUp(200);
			$filter_settings_state.val('closed');
		} else {
			$toggle.addClass('open');
			$filter_settings.slideDown(200);
			$filter_settings_state.val('open');
		}

		return false;
	});

	$module_settings
		.delegate('.category_toggle > table', 'click', function (e) {
			e.stopImmediatePropagation();
		})
		.delegate('.category_toggle', 'click', function () {
			var $clicked = $(this),
				$parent = $clicked.parent(),
				$category_content = $clicked.siblings('.category_content')
			$category_state = $clicked.siblings('input[type="hidden"]');

			if ($category_content.is(':visible')) {
				$category_state.val('collapsed');
				$category_content.slideUp(200, function () {
					$parent.addClass('collapsed');
				});
			} else {
				$category_state.val('');
				$parent.addClass('opening');
				$category_content.slideDown(200, function () {
					$parent.removeClass('opening collapsed');
				});

				$first_coll_fixed_table.find('.second_table_viewport .settings_table tr')
					.each(function (i) {
						align_fixed_table_row($(this));
					});
			}
		})
		.delegate('.expand_collapse_buttons a', 'click', function () {
			var $clicked = $(this),
				$all_cats = $clicked.parent().parent().siblings('.settings_category_container'),
				$all_cats_content = $all_cats.find('> .category_content'),
				$all_cats_state = $all_cats.find('> input[type="hidden"]');

			if ($clicked.hasClass('collapse')) {
				$all_cats.addClass('collapsed');
				$all_cats_state.val('collapsed');
				$all_cats_content.css('display', '');
			} else {
				$all_cats.removeClass('collapsed');
				$all_cats_state.val('');
				$all_cats_content.css('display', 'block');

				$first_coll_fixed_table.find('.second_table_viewport .settings_table tr')
					.each(function (i) {
						align_fixed_table_row($(this));
					});
			}

			return false;
		});

	setTimeout(function () {
		$first_coll_fixed_table.find('.second_table_viewport .settings_table tr')
			.each(function (i) {
				align_fixed_table_row($(this));
			});
	}, 500);

	$edn_admin
		.delegate('a.open_map_editor', 'click', function () {
			var $this = $(this);

			$('#EDNadmin').trigger('token_editor_initialized');

			if ($this.hasClass('has_key'))
				if ($this.hasClass('edit'))
					google_maps_token($('#EDNadmin .google_maps_main > .content.google_maps > input[type="hidden"]').val());
				else
					google_maps_token();
			else {
				$body.css({
					overflow: 'hidden',
					position: 'relative'
				});

				$form.addClass('removeTopMargin');

				$('<div><p>To enable Google Maps integration, please set your Google API Key in the settings.</p></div>').dialog({
					autoOpen: true,
					resizable: false,
					modal: true,
					close: function () {
						$body.css({
							overflow: '',
							position: ''
						});

						$form.removeClass('removeTopMargin');
					}
				});
			}

			return false;
		})
		.delegate('a.remove_article_map', 'click', function () {
			var $map_set_container = $(this).parent()
				$no_map_container = $map_set_container.siblings('.info_box.no_map');

			$map_set_container.siblings('input[type="hidden"]').val('');

			$map_set_container.slideUp(200);
			$no_map_container.slideDown(200);

			return false;
		});

	$('.article_maps').delegate('a.edit_map', 'click', function () {
		google_maps_token($(this).siblings('textarea').val());

		return false;
	});

	$edn_admin.delegate('.gallery_items_table .start_token_generator', 'click', function () {
		var $clicked = $(this);

		$('#EDNadmin').trigger('token_editor_initialized');

		!function () {
			var original_token = $clicked.siblings('input.token_box').val(),

				$window = $(window),
				$item_token_dialog = $body.find('.content_token_generator.gallery_item'),
				$dialog_wrapper = $item_token_dialog.find('.dialog_wrapper'),

				close_dialog = function () {
					$item_token_dialog.dialog('destroy');

					$body.css({
						overflow: '',
						position: ''
					});

					$form.removeClass('removeTopMargin');
				},

				token_params,

				parse_token = function (token) {
					var peaces = token.split('|'),
						params = {
							id: peaces[1],
							width: peaces[3] ? parseInt(peaces[3]) : 0,
							height: peaces[5] ? parseInt(peaces[5]) : 0,
							position: peaces[7],
							resizecrop: peaces[9] == 'False' ? false : true,
							lightbox: peaces[11] == 'False' ? false : true,
							title: peaces[13] == 'False' ? false : true,
							description: peaces[15] == 'False' ? false : true,
							redirection: peaces[17] == 'False' ? false : true,
							linktext: peaces[19]
						};

					return params;
				},

				generate_token = function () {
					var token = '[EasyDNNGallery|' + token_params['id'] +
						'|Width|' + token_params['width'] +
						'|Height|' + token_params['height'] +
						'|position|' + token_params['position'] +
						'|resizecrop|' + (token_params['resizecrop'] ? 'True' : 'False') +
						'|lightbox|' + (token_params['lightbox'] ? 'True' : 'False') +
						'|title|' + (token_params['title'] ? 'True' : 'False') +
						'|description|' + (token_params['description'] ? 'True' : 'False') +
						'|redirection|' + (token_params['lightbox'] ? 'False' : (token_params['redirection'] ? 'True' : 'False')) +
						'|LinkText|' + token_params['linktext'];

					return token + '|]';
				},

				filter_integer_field = function (field) {
					var new_val = parseInt(field.value);

					if (!new_val || isNaN(new_val) || new_val < 0) {
						new_val = field.value = 0
					} else if (field.value[0] == '0')
						new_val = field.value = parseInt(field.value.substring(1));
					else if (field.value != new_val)
						field.value = new_val;

					return new_val;
				},

				$the_token = $dialog_wrapper.find('.the_token'),

				$token_width = $('#gallery_item_token_width'),
				$token_height = $('#gallery_item_token_height'),
				$token_position_left_clear = $('#gallery_item_token_position_left_clear'),
				$token_position_left = $('#gallery_item_token_position_left'),
				$token_position_right = $('#gallery_item_token_position_right'),
				$token_sizing_proportional = $('#gallery_item_token_sizing_proportional'),
				$token_sizing_crop = $('#gallery_item_token_sizing_crop'),
				$token_onclick_lightbox = $('#gallery_item_token_onclick_lightbox'),
				$token_onclick_redirect = $('#gallery_item_token_onclick_redirect'),
				$token_onclick_nothing = $('#gallery_item_token_onclick_nothing'),
				$token_title = $('#gallery_item_token_title'),
				$token_description = $('#gallery_item_token_description'),
				$token_as_text_link = $('#gallery_item_token_as_text_link'),
				$token_link_text = $('#gallery_item_token_link_text');

			token_params = parse_token(original_token);

			if (!token_params.lightbox) {
				token_params.linktext = '';
				$token_as_text_link.parent().css('display', 'none');
				$token_link_text
					.val('')
					.parent().parent()
						.css('display', 'none');
			}

			if (token_params.linktext == '') {
				$token_as_text_link[0].checked = false;
				$token_link_text
					.val('')
					.parent().parent()
						.css('display', 'none');
			} else {
				$token_as_text_link[0].checked = true;
				$token_link_text
					.val(token_params.linktext)
					.parent().parent()
						.css('display', 'block');
			}

			$the_token.html(generate_token());

			$token_as_text_link
				.unbind()
				.change(function () {
					if ($token_as_text_link[0].checked) {
						$token_link_text.parent().parent().slideDown(200);
						$token_link_text.focus();
					} else {
						$token_link_text.parent().parent().slideUp(200);
						token_params.linktext = '';

						$the_token.html(generate_token());
					}
				});

			$token_link_text
				.unbind()
				.keyup(function () { $(this).trigger('change'); })
				.change(function () {
					token_params.linktext = $('<p />')
						.text(this.value.replace('[', '&#91;').replace(']', '&#93;').replace('|', '&#124;'))
						.html();

					$the_token.html(generate_token());
				});

			$body.css({
				overflow: 'hidden',
				position: 'relative'
			});

			$form.addClass('removeTopMargin');

			$item_token_dialog.dialog({
				buttons: [
					{
						text: localization.image_token_editor_close,
						click: close_dialog
					}
				],
				close: close_dialog,
				height: 450,
				width: 700,
				modal: true,
				resizable: false,
				title: localization.image_token_editor_title
			});

			$token_width
				.val(token_params['width'])
				.unbind()
				.keyup(function () { $(this).trigger('change'); })
				.change(function () {
					token_params['width'] = filter_integer_field(this);

					$the_token.html(generate_token());
				});

			$token_height
				.val(token_params['height'])
				.unbind()
				.keyup(function () { $(this).trigger('change'); })
				.change(function () {
					token_params['height'] = filter_integer_field(this);

					$the_token.html(generate_token());
				});

			$token_position_left_clear[0].checked = token_params.position == '';
			$token_position_left[0].checked = token_params.position == 'left';
			$token_position_right[0].checked = token_params.position == 'right';

			$token_position_left_clear
				.unbind()
				.change(function () {
					if (this.checked) 
						token_params['position'] = '';

					$the_token.html(generate_token());
				});

			$token_position_left
				.unbind()
				.change(function () {
					if (this.checked) 
						token_params['position'] = 'left';

					$the_token.html(generate_token());
				});

			$token_position_right
				.unbind()
				.change(function () {
					if (this.checked) 
						token_params['position'] = 'right';

					$the_token.html(generate_token());
				});

			$token_sizing_proportional[0].checked = !token_params.resizecrop;
			$token_sizing_crop[0].checked = token_params.resizecrop;

			$token_sizing_proportional
				.unbind()
				.change(function () {
					if (this.checked)
						token_params['resizecrop'] = false;

					$the_token.html(generate_token());
				});

			$token_sizing_crop
				.unbind()
				.change(function () {
					if (this.checked)
						token_params['resizecrop'] = true;

					$the_token.html(generate_token());
				});

			$token_onclick_lightbox[0].checked = token_params.lightbox;
			$token_onclick_redirect[0].checked = !token_params.lightbox && token_params.redirection;
			$token_onclick_nothing[0].checked = !token_params.resizecrop && !token_params.resizecrop;

			$token_onclick_lightbox
				.unbind()
				.change(function () {
					if (this.checked) {
						token_params['lightbox'] = true;
						token_params['redirection'] = false;

						$token_as_text_link.parent().css('display', 'block');

						$token_as_text_link[0].checked = false;
					}

					$the_token.html(generate_token());
				});

			$token_onclick_redirect
				.unbind()
				.change(function () {
					if (this.checked) {
						token_params['lightbox'] = false;
						token_params['redirection'] = true;

						token_params.linktext = '';
						$token_as_text_link.parent().css('display', 'none');
						$token_link_text
							.val('')
							.parent().parent()
								.css('display', 'none');
					}

					$the_token.html(generate_token());
				});

			$token_onclick_nothing
				.unbind()
				.change(function () {
					if (this.checked) {
						token_params['lightbox'] = false;
						token_params['redirection'] = false;

						token_params.linktext = '';
						$token_as_text_link.parent().css('display', 'none');
						$token_link_text
							.val('')
							.parent().parent()
								.css('display', 'none');
					}

					$the_token.html(generate_token());
				});

			$token_title[0].checked = token_params.title;
			$token_description[0].checked = token_params.description;

			$token_title
				.unbind()
				.change(function () {
					token_params.title = this.checked;

					$the_token.html(generate_token());
				});

			$token_description
				.unbind()
				.change(function () {
					token_params.description = this.checked;

					$the_token.html(generate_token());
				});
		}();
	});
});
