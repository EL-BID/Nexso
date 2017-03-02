CREATE PROCEDURE [dbo].[dnn_AddFile]
	@PortalId   int,
	@UniqueId   uniqueidentifier,
	@VersionGuid  uniqueidentifier,
	@FileName   nvarchar(246),
	@Extension   nvarchar(100),
	@Size    int,
	@Width    int,
	@Height    int,
	@ContentType  nvarchar(200),
	@Folder    nvarchar(246),
	@FolderID   int,
	@CreatedByUserID   int,
	@Hash     varchar(40),
	@LastModificationTime	datetime, 
	@Title					nvarchar(256),
	@EnablePublishPeriod	bit,
	@StartDate				datetime,
	@EndDate				datetime,
	@ContentItemID			int
AS
BEGIN
	DECLARE @FileID int

	UPDATE dbo.[dnn_Files]
	SET
		/* retrieves FileId from table */
		@FileID = FileId,
		FileName = @FileName,
		VersionGuid = @VersionGuid,
		Extension = @Extension,
		Size = @Size,
		Width = @Width,
		Height = @Height,
		ContentType = @ContentType,
		FolderID = @FolderID,
		LastModifiedByUserID = @CreatedByUserID,
		LastModifiedOnDate = getdate(),
		SHA1Hash = @Hash,
		LastModificationTime = @LastModificationTime, 
		Title = @Title,
		EnablePublishPeriod = @EnablePublishPeriod,
		StartDate = @StartDate,
		EndDate = @EndDate,
		ContentItemID = @ContentItemID
	WHERE
		FolderID = @FolderID AND FileName = @FileName

	IF @@ROWCOUNT = 0
	BEGIN
	INSERT INTO dbo.[dnn_Files] (
		PortalId,
		UniqueId,
		VersionGuid,
		FileName,
		Extension,
		Size,
		Width,
		Height,
		ContentType,
		FolderID,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate,
		SHA1Hash,
		LastModificationTime, 
		Title,
		EnablePublishPeriod,
		StartDate,
		EndDate,
		ContentItemID
	)
	VALUES (
		@PortalId,
		@UniqueId,
		@VersionGuid,
		@FileName,
		@Extension,
		@Size,
		@Width,
		@Height,
		@ContentType,
		@FolderID,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate(),
		@Hash,
		@LastModificationTime, 
		@Title,
		@EnablePublishPeriod,
		@StartDate,
		@EndDate,
		@ContentItemID
	)

	SELECT @FileID = SCOPE_IDENTITY()
	END

	SELECT @FileID
END

