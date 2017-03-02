CREATE PROCEDURE [dbo].[dnn_SaveJavaScriptLibrary]
	@JavaScriptLibraryID INT,
	@PackageID INT,
	@LibraryName NVARCHAR(200),
	@Version NVARCHAR(50),
	@FileName NVARCHAR(100),
	@ObjectName NVARCHAR(100),
	@PreferredScriptLocation int,
	@CDNPath NVARCHAR(250)
AS

	IF EXISTS (SELECT JavaScriptLibraryID FROM dnn_JavaScriptLibraries WHERE JavaScriptLibraryID = @JavaScriptLibraryID)
		BEGIN
			UPDATE dbo.[dnn_JavaScriptLibraries]
			   SET [PackageID] = @PackageID,
					[LibraryName] = @LibraryName,
					[Version] = @Version,
					[FileName] = @FileName,
					[ObjectName] = @ObjectName,
					[PreferredScriptLocation] = @PreferredScriptLocation,
					[CDNPath] = @CDNPath
			 WHERE JavaScriptLibraryID = @JavaScriptLibraryID
	 	END
	ELSE
		BEGIN
			INSERT INTO dbo.[dnn_JavaScriptLibraries] (
				[PackageID],
				[LibraryName],
				[Version],
				[FileName],
				[ObjectName],
				[PreferredScriptLocation],
				[CDNPath]
			)
			VALUES (
				@PackageID,
				@LibraryName,
				@Version,
				@FileName,
				@ObjectName,
				@PreferredScriptLocation,
				@CDNPath
			)
			SET @JavaScriptLibraryID = (SELECT @@IDENTITY)
		END

	SELECT @JavaScriptLibraryID
