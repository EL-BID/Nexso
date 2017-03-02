CREATE PROCEDURE [dbo].[dnn_DeleteFileVersion] 
	@FileId int,
	@Version int
AS
BEGIN
	DECLARE @PublishedVersion int

	-- Check there is at least one version
	IF NOT EXISTS(SELECT FileID FROM dnn_FileVersions WHERE FileId = @FileId)
	BEGIN
		SELECT NULL
		RETURN
	END
		
	SELECT @PublishedVersion = PublishedVersion
	FROM dbo.dnn_Files
	WHERE FileId = @FileId

	IF @PublishedVersion = @Version 
	BEGIN
		-- Get the previous version
		SELECT @PublishedVersion = MAX(Version)
		FROM dbo.dnn_FileVersions 
		WHERE FileId = @FileId
			AND Version < @Version

		-- If there is no previous version, get the min exsisting version
		IF @PublishedVersion IS NULL 
			SELECT @PublishedVersion = MIN(Version)
			FROM dbo.dnn_FileVersions 
			WHERE FileId = @FileId

		-- Update the published version
		IF @PublishedVersion IS NOT NULL 
		BEGIN
			UPDATE dbo.dnn_Files
			SET [PublishedVersion] = @PublishedVersion,
				[Extension] = v.[Extension],
				[Size] = v.[Size],
				[Width] = v.Width,		
				[Height] = v.Height,
				[ContentType] = v.ContentType,
				[Content] = v.Content,
				[LastModifiedByUserID] = v.LastModifiedByUserID,
				[LastModifiedOnDate] = v.LastModifiedOnDate,
				[SHA1Hash] = v.SHA1Hash
			FROM dbo.dnn_files AS f
				INNER JOIN dbo.dnn_FileVersions AS v
				ON ( f.FileId = v.FileId AND v.Version = @PublishedVersion)		
			WHERE f.FileId = @FileId

			DELETE FROM dbo.dnn_FileVersions
			WHERE FileId = @FileId 
			AND Version = @PublishedVersion
		END
	END

	DELETE FROM dbo.dnn_FileVersions
	WHERE FileId = @FileId 
	  AND Version = @Version

	SELECT @PublishedVersion
END

