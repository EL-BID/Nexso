CREATE PROCEDURE [dbo].[dnn_SaveTabVersionDetail]
    @Id INT,
    @TabVersionId INT,
    @ModuleId INT,
    @ModuleVersion INT,
	@PaneName NVARCHAR(50),
	@ModuleOrder INT,
	@Action INT,
    @CreatedByUserID [INT] = -1,
	@LastModifiedByUserID [INT] = -1
AS
BEGIN
    IF ISNULL(@Id, 0) = 0
    BEGIN
        INSERT INTO dbo.[dnn_TabVersionDetails](
            [TabVersionId],
            [ModuleId],
            [ModuleVersion],
			[PaneName],
            [ModuleOrder],
			[Action],
            [CreatedByUserID],
            [CreatedOnDate],
            [LastModifiedByUserID],
            [LastModifiedOnDate]
        ) VALUES (
            @TabVersionId,
			@ModuleId,            
            @ModuleVersion,            
			@PaneName,
			@ModuleOrder,
			@Action,
            @CreatedByUserID,
            GETDATE(),
            @LastModifiedByUserID,
            GETDATE()
        )

        SELECT @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE dbo.[dnn_TabVersionDetails] SET            
            [TabVersionId] = @TabVersionId,
			[ModuleId] = @ModuleId,
            [ModuleVersion] = @ModuleVersion,            
            [PaneName] = @PaneName,
			[ModuleOrder] = @ModuleOrder,
			[Action] = @Action,
            [LastModifiedByUserID] = @LastModifiedByUserID,
            [LastModifiedOnDate] = GETDATE()
        WHERE TabVersionDetailId = @Id
    END
	SELECT @Id
END

