CREATE PROCEDURE [dbo].[dnn_UpdateFile]
    @FileId					INT,
    @VersionGuid			UNIQUEIDENTIFIER,	
    @FileName				NVARCHAR(246),
    @Extension				NVARCHAR(100),
    @Size					INT,
    @Width					INT,
    @Height					INT,
    @ContentType			NVARCHAR(200),	
    @FolderID				INT,
    @LastModifiedByUserID  	INT,
    @Hash					VARCHAR(40),
    @LastModificationTime	DATETIME,
    @Title					NVARCHAR(256),
    @EnablePublishPeriod	BIT,
    @StartDate				DATETIME,
    @EndDate				DATETIME,	
    @ContentItemID			INT
AS
    UPDATE dbo.dnn_Files
        SET    FileName = @FileName,
               VersionGuid = @VersionGuid,
               Extension = @Extension,
               Size = @Size,
               Width = @Width,
               Height = @Height,
               ContentType = @ContentType,
               FolderID = @FolderID,
               LastModifiedByUserID = @LastModifiedByUserID,
               LastModifiedOnDate = getdate(),
			   SHA1Hash = @Hash,
			   LastModificationTime = @LastModificationTime,
			   Title = @Title,
			   EnablePublishPeriod = @EnablePublishPeriod,
			   StartDate = @StartDate,
			   EndDate = @EndDate,
			   ContentItemID = @ContentItemID
    WHERE  FileId = @FileId

