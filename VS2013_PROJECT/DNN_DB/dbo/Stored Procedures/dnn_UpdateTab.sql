CREATE PROCEDURE [dbo].[dnn_UpdateTab] 
    @TabId					int,
    @ContentItemID			int,
    @PortalId				int,
    @VersionGuid			uniqueidentifier,
    @DefaultLanguageGuid	uniqueidentifier,
    @LocalizedVersionGuid	uniqueidentifier,
    @TabName				nvarchar(200),
    @IsVisible				bit,
    @DisableLink			bit,
    @ParentId				int,
    @IconFile				nvarchar(100),
    @IconFileLarge			nvarchar(100),
    @Title					nvarchar(200),
    @Description			nvarchar(500),
    @KeyWords				nvarchar(500),
    @IsDeleted				bit,
    @Url					nvarchar(255),
    @SkinSrc				nvarchar(200),
    @ContainerSrc			nvarchar(200),
    @StartDate				datetime,
    @EndDate				datetime,
    @RefreshInterval		int,
    @PageHeadText			nvarchar(max),
    @IsSecure				bit,
    @PermanentRedirect		bit,
    @SiteMapPriority		float,
    @LastModifiedByUserID	int,
    @CultureCode			nvarchar(50),
	@IsSystem				bit
AS
	BEGIN
		DECLARE @OldParentId int
		SET @OldParentId = (SELECT ParentId FROM dbo.[dnn_Tabs] WHERE TabID = @TabId)

		DECLARE @TabOrder int
		SET @TabOrder = (SELECT TabOrder FROM dbo.[dnn_Tabs] WHERE TabID = @TabId)
				
		-- Get New TabOrder
		DECLARE @NewTabOrder int
		SET @NewTabOrder = (SELECT MAX(TabOrder) FROM dbo.[dnn_Tabs] WHERE (ParentId = @ParentId OR (ParentId IS NULL AND @ParentId IS NULL)))
		IF @NewTabOrder IS NULL 
			SET @NewTabOrder = 1
		ELSE
			SET @NewTabOrder = @NewTabOrder + 2
		
		UPDATE dbo.[dnn_Tabs]
			SET
				ContentItemID			= @ContentItemID,
				PortalId				= @PortalId,
				VersionGuid				= @VersionGuid,
				DefaultLanguageGuid		= @DefaultLanguageGuid,
				LocalizedVersionGuid	= @LocalizedVersionGuid,
				TabName					= @TabName,
				IsVisible				= @IsVisible,
				DisableLink				= @DisableLink,
				ParentId				= @ParentId,
				IconFile				= @IconFile,
				IconFileLarge			= @IconFileLarge,
				Title					= @Title,
				Description				= @Description,
				KeyWords				= @KeyWords,
				IsDeleted				= @IsDeleted,
				Url						= @Url,
				SkinSrc					= @SkinSrc,
				ContainerSrc			= @ContainerSrc,
				StartDate				= @StartDate,
				EndDate					= @EndDate,
				RefreshInterval			= @RefreshInterval,
				PageHeadText			= @PageHeadText,
				IsSecure				= @IsSecure,
				PermanentRedirect		= @PermanentRedirect,
				SiteMapPriority			= @SiteMapPriority,
				LastModifiedByUserID	= @LastModifiedByUserID,
				LastModifiedOnDate		= getdate(),
				CultureCode				= @CultureCode,
				IsSystem				= @IsSystem
		WHERE  TabId = @TabId
		
		IF (@OldParentId <> @ParentId)
			BEGIN
				-- update TabOrder of Tabs with same original Parent
				UPDATE dbo.[dnn_Tabs]
					SET TabOrder = TabOrder - 2
					WHERE (ParentId = @OldParentId) 
						AND TabOrder > @TabOrder

				-- Update Tab with new TabOrder
				UPDATE dbo.[dnn_Tabs]
					SET 
						TabOrder = @NewTabOrder
					WHERE TabID = @TabId
			END
		
		EXEC dbo.dnn_BuildTabLevelAndPath @TabId, 1
    END

