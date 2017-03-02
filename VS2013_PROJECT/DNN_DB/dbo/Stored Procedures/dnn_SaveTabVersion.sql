CREATE PROCEDURE [dbo].[dnn_SaveTabVersion]
    @Id INT,
    @TabId INT,
    @TimeStamp DATETIME,
    @Version INT,
	@IsPublished BIT,
    @CreatedByUserID [INT] = -1,
	@LastModifiedByUserID [INT] = -1
AS
BEGIN
    IF ISNULL(@Id, 0) = 0
    BEGIN
        INSERT INTO dbo.[dnn_TabVersions](            
            [TabId],
            [TimeStamp],
            [Version],
			[IsPublished],
            [CreatedByUserID],
            [CreatedOnDate],
            [LastModifiedByUserID],
            [LastModifiedOnDate]
        ) VALUES (
            @TabId,
            @TimeStamp,
            @Version,      
			@IsPublished,      
            @CreatedByUserID,
            GETDATE(),
            @LastModifiedByUserID,
            GETDATE()
        )

        SELECT @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE dbo.[dnn_TabVersions] SET            
            [TabId] = @TabId,
            [Version] = @Version,
            [TimeStamp] = @TimeStamp,
			[IsPublished] = @IsPublished,
            [LastModifiedByUserID] = @LastModifiedByUserID,
            [LastModifiedOnDate] = GETDATE()
        WHERE TabVersionId = @Id
    END
	SELECT @Id
END

