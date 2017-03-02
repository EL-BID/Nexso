CREATE PROCEDURE [dbo].[dnn_SetPublishedVersion] 
	@FileId					int,
	@NewPublishedVersion	int
AS
BEGIN

	-- Insert a new record in the FileVersions table for the old published version
	INSERT dbo.[dnn_FileVersions]
				([FileId]
				,[Version]
				,[FileName]
				,[Extension]
				,[Size]
				,[Width]
				,[Height]
				,[ContentType]
				,[Content]
				,[CreatedByUserID]
				,[CreatedOnDate]
				,[LastModifiedByUserID]
				,[LastModifiedOnDate]
				,[SHA1Hash])
	SELECT		[FileId]
				,[PublishedVersion]  [Version]				
				,CONVERT(nvarchar, [FileId]) + '_' + CONVERT(nvarchar, [PublishedVersion]) +'.v.resources' 
				,[Extension]
				,[Size]
				,[Width]
				,[Height]
				,[ContentType]
				,[Content]
				,[CreatedByUserID]
				,[CreatedOnDate]
				,[LastModifiedByUserID]
				,[LastModifiedOnDate]
				,[SHA1Hash]					
	FROM dnn_Files
	WHERE FileId = @FileId

	-- Change Files.PublishedVersion to the new version number
	UPDATE dbo.[dnn_Files]
	SET	 [PublishedVersion] = @NewPublishedVersion		
		,[Extension] =v.[Extension]
		,[Size] = v.[Size]
		,[Width] = v.[Width]
		,[Height] = v.[Height]
		,[ContentType] = v.[ContentType]
		,[Content] = v.[Content]
		,[CreatedByUserID] = v.[CreatedByUserID]
		,[CreatedOnDate] = v.[CreatedOnDate]
		,[LastModifiedByUserID] = v.[LastModifiedByUserID]
		,[LastModifiedOnDate] = v.[LastModifiedOnDate]
		,[SHA1Hash] = v.[SHA1Hash]
	FROM dbo.[dnn_Files] f
		JOIN dbo.[dnn_FileVersions] v ON f.FileId = v.FileId
	WHERE f.FileId = @FileId
		AND v.Version = @NewPublishedVersion

    -- Delete the FileVersions entry of the version being published
	DELETE dbo.[dnn_FileVersions]
	WHERE FileId = @FileId AND Version = @NewPublishedVersion
END

