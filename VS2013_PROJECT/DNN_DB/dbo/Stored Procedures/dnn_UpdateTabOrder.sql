CREATE PROCEDURE [dbo].[dnn_UpdateTabOrder] 
	@TabId					int,
	@TabOrder				int,
	@ParentId				int,
	@LastModifiedByUserID	int
AS
	DECLARE @OldParentId INT
	SELECT @OldParentId = ParentId FROM dbo.dnn_Tabs WHERE TabID = @TabId
	UPDATE dnn_Tabs
		SET
			TabOrder				= @TabOrder,
			ParentId				= @ParentId,
			LastModifiedByUserID	= @LastModifiedByUserID,
			LastModifiedOnDate		= GETDATE()
	WHERE  TabId = @TabId
	IF @OldParentId <> @ParentId
		BEGIN
			EXEC dbo.dnn_BuildTabLevelAndPath @TabId, 1
		END
	ELSE
		BEGIN
			EXEC dbo.dnn_BuildTabLevelAndPath @TabId
		END

