CREATE PROCEDURE [dbo].[dnn_MoveTabAfter] 
	@TabId					int,
	@AfterTabId				int,
	@LastModifiedByUserID	int
AS
	BEGIN
		DECLARE @OldParentId int
		DECLARE @NewParentId int
		DECLARE @PortalId int
		
		SET @OldParentId = (SELECT ParentId FROM dbo.dnn_Tabs WHERE TabID = @TabId)
		SET @NewParentId = (SELECT ParentId FROM dbo.dnn_Tabs WHERE TabID = @AfterTabId)
		SET @PortalId = (SELECT PortalId FROM dbo.dnn_Tabs WHERE TabID = @TabId)

		DECLARE @TabOrder int
		SET @TabOrder = (SELECT TabOrder FROM dbo.dnn_Tabs WHERE TabID = @TabId)
		
		IF (@OldParentId <> @NewParentId OR NOT (@OldParentId IS NULL AND @NewParentId IS NULL))
			-- Parent has changed
			BEGIN
				-- update TabOrder of Tabs with same original Parent
				UPDATE dbo.dnn_Tabs
					SET TabOrder = TabOrder - 2
					WHERE (ParentId = @OldParentId OR (ParentId IS NULL AND @OldParentId IS NULL)) 
						AND TabOrder > @TabOrder
						AND (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))

				-- Get TabOrder of AfterTab
				SET @TabOrder = (SELECT TabOrder FROM dbo.dnn_Tabs WHERE TabID = @AfterTabId)
						
				-- update TabOrder of Tabs with same new Parent
				UPDATE dbo.dnn_Tabs
					SET TabOrder = TabOrder + 2
					WHERE (ParentId = @NewParentId OR (ParentId IS NULL AND @NewParentId IS NULL)) 
						AND TabOrder > @TabOrder
						AND (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))

				-- Update Tab with new TabOrder
				UPDATE dbo.dnn_Tabs
					SET 
						ParentId				= @NewParentId,
						TabOrder				= @TabOrder + 2,
						LastModifiedByUserID	= @LastModifiedByUserID,
						LastModifiedOnDate		= GETDATE()					
					WHERE TabID = @TabId
				EXEC dbo.dnn_BuildTabLevelAndPath @TabId, 1
			END
		ELSE
			-- Parent has not changed
			BEGIN
				-- Remove Tab from TabOrder
				UPDATE dbo.dnn_Tabs
					SET TabOrder = -1
					WHERE TabID = @TabId
					
				-- Reorder
				UPDATE dbo.dnn_Tabs
					SET TabOrder = TabOrder - 2
					WHERE (ParentId = @OldParentId OR (ParentId IS NULL AND @OldParentId IS NULL)) 
						AND TabOrder > @TabOrder
						AND TabId <> @TabId
						AND (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))
						
				-- Get TabOrder of AfterTab
				SET @TabOrder = (SELECT TabOrder FROM dbo.dnn_Tabs WHERE TabID = @AfterTabId)
										
				-- Reorder					
				UPDATE dbo.dnn_Tabs
					SET TabOrder = TabOrder + 2
					WHERE (ParentId = @OldParentId OR (ParentId IS NULL AND @OldParentId IS NULL)) 
						AND TabOrder > @TabOrder
						AND (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))

				-- Update Tab with new TabOrder
				UPDATE dbo.dnn_Tabs
					SET 
						TabOrder				= @TabOrder + 2,
						LastModifiedByUserID	= @LastModifiedByUserID,
						LastModifiedOnDate		= GETDATE()					
					WHERE TabID = @TabId
				EXEC dbo.dnn_BuildTabLevelAndPath @TabId
			END
	END

