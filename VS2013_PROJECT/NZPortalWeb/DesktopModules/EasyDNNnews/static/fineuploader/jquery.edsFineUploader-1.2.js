;(function ($, undefined) {
	var fileReaderPresent = window.FileReader != undefined && window.FileReader.prototype.readAsDataURL != undefined,
		isIe10 = false,

		localization = {},

		init = function ($uploadWrapper, settings) {
			var $uploadQueue = $('.uploadDetails > ol.fileUploadList', $uploadWrapper),
				$uploader,
				userAgent,
				browserNameIndex,
				runOnAllUploadsComplete = function () {
					if (typeof settings.onAllUploadsComplete == 'function')
						settings.onAllUploadsComplete();
				},
				allUploadsDone = function () {
					var pendingFiles = $uploader.fineUploader(
						'getUploads',
						{
							status: [
								qq.status.UPLOADING,
								qq.status.UPLOAD_RETRYING,
								qq.status.QUEUED,
								qq.status.SUBMITTED,
								qq.status.PAUSED,
								qq.status.UPLOAD_FAILED
							]
						}
					);

					return pendingFiles.length == 0;
				},
				someFilesUploaded = false,
				addFiles = function (files) {
					$uploader.fineUploader('addFiles', files);
				};

			if (settings.localization)
				localization = settings.localization;

			if (fileReaderPresent) {
				if (settings.allowPreviewThumbnails)
					$uploadWrapper.addClass('thumbnailsAllowed');

				userAgent = navigator.userAgent;

				if (userAgent) {
					browserNameIndex = userAgent.indexOf('MSIE');
					if (browserNameIndex != -1)
						isIe10 = parseInt(userAgent.substr(browserNameIndex + 4)) == 10;
				}
			}

			$uploader = $('> .uploader', $uploadWrapper)
				.fineUploader({
					uploaderType: 'basic',
					autoUpload: false,
					maxConnections: 1,
					request: {
						endpoint: settings.endpoint,
						inputName: 'Filedata',
						uuidName: 'uuid',
						totalFileSizeName: 'filesize',
						params: settings.params
					},
					validation: {
						allowedExtensions: settings.allowedExtensions,
						stopOnFirstInvalidFile: false
					}
				})
				.on('submit', function (e, fileId) {
					var fileInfo = $uploader.fineUploader('getFile', fileId),
						filename = $('<p />').text(fileInfo.name).html(),
						fileExtension = /(?:\.([^.]+))?$/.exec(fileInfo.name)[1],
						$li = $(generateFileHtml(
								fileId,
								filename,
								_('Queued') + ' (' + readableFileSize(fileInfo.size) + ')',
								true,
								false
							))
							.appendTo($uploadQueue)
							.data('fileId', fileId),
						$thumbnail,
						fileReader;

					if (
						!settings.allowPreviewThumbnails ||
						!fileReaderPresent ||
						(
							fileExtension != 'jpg' &&
							fileExtension != 'jpeg' &&
							fileExtension != 'gif' &&
							fileExtension != 'png' &&
							fileExtension != 'bmp'
						)
					)
						return;

					$thumbnail = $('<div class="thumbnail" />').appendTo($li);
					$li.addClass('hasThumb');

					if (fileInfo.size > 2097152 || (isIe10 && fileInfo.size > 524288)) {
						$thumbnail.addClass('noPreview');
						$thumbnail.append('<p>' + _('no preview avalible') + '</p>');

						return;
					}

					fileReader = new FileReader();

					fileReader.onload = function (e) {
						$thumbnail.prepend('<img src="' + e.target.result + '" alt="' + filename + '" />');
					};

					$li.data('imageReader', fileReader);
					fileReader.readAsDataURL(fileInfo);
				})
				.on('upload', function (e, fileId) {
					$('> li.file' + fileId + ' > .details > .progress', $uploadQueue).css('display', 'block');
				})
				.on('progress', function (e, fileId, fileName, bytesUploaded, bytesTotal) {
					var $liDetails = $('> li.file' + fileId + ' > .details', $uploadQueue),
						uploadedPercent = bytesUploaded / bytesTotal * 100;

					$('> .uploadInfo', $liDetails).text(Math.round(uploadedPercent) + '% (' + readableFileSize(bytesUploaded) + ' ' + _('of') + ' ' + readableFileSize(bytesTotal) + ')');
					$('> .progress > div', $liDetails).css('width', uploadedPercent + '%');
				})
				.on('complete', function (e, fileId, fileName, response) {
					var $li = $('> li.file' + fileId, $uploadQueue),
						$liDetails = $('> .details', $li),
						imageReader = $li.data('imageReader');

					if (response.success !== true) {
						$li.addClass('failed');
						$('> .uploadInfo', $liDetails).text(_('Upload failed'));
						$('> .progress', $liDetails).css('display', 'none');
						$('> .progress > div', $liDetails).css('width', '');
						$('> .actions > .retry', $liDetails).css('display', '');

						return;
					}

					someFilesUploaded = true;

					if (imageReader && imageReader.readyState === FileReader.LOADING)
						imageReader.abort();

					$li.fadeOut(200, function () {
						$li.remove();
					});

					if (typeof settings.onEachUploadComplete == 'function')
						settings.onEachUploadComplete(response);

					if (allUploadsDone())
						runOnAllUploadsComplete();
				})
				.on('error', function (e, id, filename, errorMsg) {
					if (id == null) {
						if (typeof filename == 'string' && filename != '') {
							$(generateFileHtml(
								'',
								filename,
								_('This file isn\'t of a valid format'),
								false,
								true
							))
								.addClass('failed')
								.appendTo($uploadQueue);
						}
					}
				});

			$('> .uploadControls > .actions > .action.fileSelection > .dnnInputFileWrapper > input', $uploadWrapper).on('change', function () {
				addFiles(this.files);
			});

			$uploadQueue
				.on('click', '> li > .details > .actions > .retry', function () {
					var $this = $(this),
						$li = $this.parents().eq(2),
						fileId = $li.data('fileId'),
						fileInfo = $uploader.fineUploader('getFile', fileId);

					$this.css('display', 'none');

					if (!$li.is(':last-child'))
						$li = $li.detach().appendTo($uploadQueue);

					$li.removeClass('failed');
					$('> .details > .uploadInfo', $li).text(_('Queued') + ' (' + readableFileSize(fileInfo.size) + ')');

					$uploader.fineUploader('retry', fileId);
				})
				.on('click', '> li > .details > .actions > .cancel', function () {
					var $li = $(this).parents().eq(2),
						fileId = $li.data('fileId'),
						imageReader = $li.data('imageReader');

					if ($li.data('deleted'))
						return;

					$li.data('deleted', true);

					if (imageReader && imageReader.readyState === FileReader.LOADING)
						imageReader.abort();

					$uploader.fineUploader('cancel', fileId);

					$li.fadeOut(200, function () {
						$li.remove();
					});

					if (someFilesUploaded && allUploadsDone())
						runOnAllUploadsComplete();
				})
				.on('click', '> li > .details > .actions > .ok', function () {
					var $li = $(this).parents().eq(2);

					$li.fadeOut(200, function () {
						$li.remove();
					});
				});

			$('> .uploadControls > .dndContainer', $uploadWrapper)
				.attr('qq-hide-dropzone', true)
				.fineUploaderDnd({
					classes: {
						dropActive: 'dragEntered'
					}
				})
				.on('processingDroppedFilesComplete', function (e, files) {
					addFiles(files);
				});

			$('> .uploadControls > .actions > .action.upload', $uploadWrapper).on('click', function () {
				var failedUploads = $uploader.fineUploader(
					'getUploads',
					{
						status: [
							qq.status.UPLOAD_FAILED
						]
					}
				);

				$.each(
					failedUploads,
					function (i, file) {
						$('> li.file' + file.id + ' > .details > .actions > .retry', $uploadQueue).click();
					}
				);

				$uploader.fineUploader('uploadStoredFiles');
			});
		},

		generateFileHtml = function (fileId, filename, uploadInfo, showCancel, showOk) {
			return '<li class="file' + fileId + '">' +
					'<div class="details">' +
						'<p class="filename">' + filename + '</p>' +
						'<p class="uploadInfo">' + uploadInfo + '</p>' +
						'<div class="progress"><div></div></div>' +
						'<div class="actions">' +
							'<span class="retry" style="display: none;">' + _('Retry') + '</span>' +
							'<span class="cancel"' + (showCancel ? '' : ' style="display: none;"') + '>' + _('Cancel') + '</span>' +
							'<span class="ok"' + (showOk ? '' : ' style="display: none;"') + '>' + _('OK') + '</span>' +
						'</div>' +
					'</div>' +
				'</li>';
		},

		readableFileSize = function (bytes) {
			var i = 0;

			bytes = parseInt(bytes, 10);

			while (bytes > 1023) {
				i += 1;
				bytes = bytes / 1024;
			}

			bytes = bytes.toFixed(2);

			switch (i) {
			case 1:
				return bytes + ' KB';

			case 2:
				return bytes + ' MB';

			case 3:
				return bytes + ' GB';

			case 4:
				return bytes + ' PB';

			default:
				return bytes + ' B';
			}
		},

		_ = function (s) {
			if (localization[s])
				return localization[s];

			return s;
		};

	$.fn.edsFineUploader_1_2 = function (settings) {
		var $this = $(this);

		return this.each(function () {
			if ($this.data('fineUploaderInitialized'))
				return;

			$this.data('fineUploaderInitialized', true);
			init($this, settings);
		});
	}
})(eds1_10);