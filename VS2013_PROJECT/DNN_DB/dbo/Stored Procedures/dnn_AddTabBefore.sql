CREATE PROCEDURE [dbo].[dnn_AddTabBefore] 
	@BeforeTabID			int,
	@ContentItemID			int,
    @PortalID				int,
    @UniqueId				uniqueidentifier,
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
    @CreatedByUserID		int,
    @CultureCode			nvarchar(50),
	@IsSystem				bit

AS

	BEGIN
		DECLARE @TabId int
		DECLARE @TabOrder INT 
		SELECT @TabOrder = TabOrder FROM dbo.dnn_Tabs WHERE TabID = @BeforeTabID
		
		-- Update TabOrders for all Tabs higher than @TabOrder
		UPDATE dbo.dnn_Tabs
			SET TabOrder = TabOrder + 2
			WHERE (ParentId = @ParentId OR (ParentId IS NULL AND @ParentID IS NULL))
				AND TabOrder >= @TabOrder
				AND (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))
		
		-- Create Tab
		EXECUTE @TabId = dbo.dnn_AddTab 
							@ContentItemID,
							@PortalID,
							@TabOrder,
							@UniqueId,
							@VersionGuid,
							@DefaultLanguageGuid,
							@LocalizedVersionGuid,
							@TabName,
							@IsVisible,
							@DisableLink,
							@ParentId,
							@IconFile,
							@IconFileLarge,
							@Title,
							@Description,
							@KeyWords,
							@Url,
							@SkinSrc,
							@ContainerSrc,
							@StartDate,
							@EndDate,
							@RefreshInterval,
							@PageHeadText,
							@IsSecure,
							@PermanentRedirect,
							@SiteMapPriority,
							@CreatedByUserID,
							@CultureCode,
							@IsSystem;
		
		-- Update Content Item
		UPDATE dbo.dnn_ContentItems
			SET TabID = @TabId
			WHERE ContentItemID = @ContentItemID

		SELECT @TabId
	END

