CREATE PROCEDURE [dbo].[dnn_AddFileVersion] 
	@FileId					int,
	@UniqueId				uniqueidentifier,
	@VersionGuid			uniqueidentifier,
	@FileName				nvarchar(246),
	@Extension				nvarchar(100),
	@Size					int,
	@Width					int,
	@Height					int,
	@ContentType			nvarchar(200),
	@Folder					nvarchar(246),
	@FolderID				int,
	@UserID					int,
	@Hash					varchar(40),
	@LastModificationTime	datetime, 
	@Title					nvarchar(256),
	@EnablePublishPeriod	bit,
	@StartDate				datetime,
	@EndDate				datetime,
	@ContentItemID			int,
	@IsPublished			bit,
	@Content				image = NULL
AS
BEGIN

	DECLARE @Version INT

	--	Calculate the new version = Max(Files.PublishedVersion, FileVersions.Versions) + 1
	SELECT @Version = MAX([Version]) + 1
	FROM (SELECT [Version]
			FROM dbo.[dnn_FileVersions]
			WHERE FileId = @FileId
			UNION
			SELECT PublishedVersion [Version]
			FROM dbo.dnn_Files
			WHERE FileId = @FileId) v

	IF  @IsPublished = 1
		BEGIN
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

			-- Change PublishedVersion
			UPDATE dbo.[dnn_Files]
			SET	 [PublishedVersion] = @Version
			WHERE FileId = @FileId
		END
	ELSE
		BEGIN
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
			VALUES (@FileId
					,@Version
					,CONVERT(nvarchar, @FileId) + '_' + CONVERT(nvarchar, @Version) +'.v.resources'
					,@Extension
					,@Size
					,@Width
					,@Height
					,@ContentType
					,@Content
					,@UserID
					,GETDATE()
					,@UserID
					,GETDATE()
					,@Hash)
		END

	SELECT @Version
END

