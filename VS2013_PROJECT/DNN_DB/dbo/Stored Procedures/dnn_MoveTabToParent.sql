CREATE PROCEDURE [dbo].[dnn_MoveTabToParent] 
	@TabId					int,
	@NewParentId			int,
	@LastModifiedByUserID	int
AS
	BEGIN
		DECLARE @PortalId int
		SET @PortalId = (SELECT PortalId FROM dbo.dnn_Tabs WHERE TabID = @TabId)

		DECLARE @OldParentId int
		SET @OldParentId = (SELECT ParentId FROM dbo.dnn_Tabs WHERE TabID = @TabId)
		
		DECLARE @TabOrder int
		SET @TabOrder = (SELECT TabOrder FROM dbo.dnn_Tabs WHERE TabID = @TabId)
		
		-- Get New TabOrder
		DECLARE @NewTabOrder int
		SET @NewTabOrder = (SELECT MAX(TabOrder) FROM dbo.dnn_Tabs 
						 WHERE (PortalId = @PortalID OR (PortalId IS NULL AND @PortalID IS NULL)) AND
							   (ParentId = @NewParentId OR (ParentId IS NULL AND @NewParentId IS NULL))
						)
		IF @NewTabOrder IS NULL 
			SET @NewTabOrder = 1
		ELSE
			SET @NewTabOrder = @NewTabOrder + 2			
				
		BEGIN
			-- update TabOrder of Tabs with same original Parent
			UPDATE dbo.dnn_Tabs
				SET TabOrder = TabOrder - 2
				WHERE (ParentId = @OldParentId OR (ParentId IS NULL AND @OldParentId IS NULL)) 
					AND TabOrder > @TabOrder
					AND (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))

			-- Update Tab with new TabOrder
			UPDATE dbo.dnn_Tabs
				SET 
					ParentId				= @NewParentId,
					TabOrder				= @NewTabOrder,
					LastModifiedByUserID	= @LastModifiedByUserID,
					LastModifiedOnDate		= GETDATE()					
				WHERE TabID = @TabId
		END
		IF (@OldParentId <> @NewParentId) OR (@OldParentId IS NULL AND @NewParentId IS NOT NULL) OR (@OldParentId IS NOT NULL AND @NewParentId IS NULL)
			BEGIN
				EXEC dbo.dnn_BuildTabLevelAndPath @TabId, 1
			END
		ELSE
			BEGIN
				EXEC dbo.dnn_BuildTabLevelAndPath @TabId
			END
	END

