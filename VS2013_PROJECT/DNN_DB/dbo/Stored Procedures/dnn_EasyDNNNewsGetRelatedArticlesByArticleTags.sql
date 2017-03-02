CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetRelatedArticlesByArticleTags]
	@PortalID INT, -- current Portal
	@ModuleID INT, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID INT,
	@ArticleID INT,
	@NumberOfItems INT = 5,
	@OrderBy NVARCHAR(30) = 'PublishDate DESC',	
	@UserCanApprove BIT = 0, -- news settings
	@LocaleCode NVARCHAR(20) = NULL,
	@Perm_ViewAllCategores BIT = 0, -- permission settings View all categories
	@AdminOrSuperUser BIT = 0,
	@PermissionSettingsSource BIT = 1, -- 1 portal, 0 module
	@FillterSettingsSource BIT = 1, -- 1 portal, 0 module	
	@CategoryFilterType TINYINT = 1, -- 0 All categories, 1 - SELECTion, 2 - AutoAdd
	@HideUnlocalizedItems BIT = 0
AS
SET NOCOUNT ON;
IF EXISTS (SELECT TOP (1) [ArticleID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID)
BEGIN
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @UserInRoles TABLE (RoleID int NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @FiltredByCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);

IF @AdminOrSuperUser = 1 OR @Perm_ViewAllCategores = 1
BEGIN
	INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
	END
	ELSE -- by module
	BEGIN
	INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID AND rps.RoleID IS NULL;
	END
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		INSERT INTO @UserViewCategories
		SELECT DISTINCT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
		UNION
		SELECT DISTINCT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
		INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
		WHERE ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.UserID = @UserID;
	END
	ELSE -- by module
	BEGIN
		INSERT INTO @UserViewCategories
		SELECT DISTINCT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID
		UNION
		SELECT DISTINCT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
		INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
		WHERE ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID AND ups.UserID = @UserID;
	END
END

IF @CategoryFilterType = 0 -- 0 All categories
BEGIN
	INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
	INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
BEGIN
	IF @FillterSettingsSource = 1 -- portal
	BEGIN
		INSERT INTO @UserViewCategoriesWithFilter 
		SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
		INNER JOIN dbo.[dnn_EasyDNNNewsPortalCategoryItems] AS pci ON pci.CategoryID = cl.CategoryID AND pci.PortalID = @PortalID
		
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID;
	END
	ELSE -- module
	BEGIN
		INSERT INTO @UserViewCategoriesWithFilter 
		SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
		INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @ModuleID
		
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID;
	END
END
ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
BEGIN
	IF @FillterSettingsSource = 1 -- portal
	BEGIN
		WITH hierarchy AS(
			SELECT [CategoryID], [ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID)) AND PortalID = @PortalID
			UNION ALL
			SELECT c.[CategoryID], c.[ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
		INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
		INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;			
	END
	ELSE -- module
	BEGIN
		WITH hierarchy AS(
			SELECT [CategoryID], [ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID)) AND PortalID = @PortalID
			UNION ALL
			SELECT c.[CategoryID], c.[ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
		INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
		INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;
	END
END

IF @LocaleCode IS NULL
BEGIN
	SELECT TOP (@NumberOfItems) n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[PublishDate],n.[TitleLink],n.[AuthorAliasName],n.[DetailType],n.[DetailTypeData],
	CASE WHEN @CategoryFilterType = 0 THEN NULL
	ELSE
		CASE WHEN @FillterSettingsSource = 1 THEN
		 (SELECT TOP 1 CONVERT(varchar(10), clink.NewsModuleID) + ':' + CONVERT(varchar(10), tm.[TabID])
			FROM dbo.[dnn_EasyDNNNewsCategories] as c
			INNER JOIN @UserViewCategories AS uvc ON c.CategoryID = uvc.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategoryList] as cl ON c.CategoryID = cl.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsPortalCategoryLink] as clink ON clink.CategoryID = cl.CategoryID AND clink.SourcePortalID = @PortalID
			INNER JOIN dbo.[dnn_TabModules] AS tm ON clink.NewsModuleID = tm.ModuleID
			WHERE c.ArticleID = n.[ArticleID] AND cl.PortalID = @PortalID ORDER BY cl.Position)
		ELSE
		(SELECT TOP 1 CONVERT(varchar(10), clink.NewsModuleID) + ':' + CONVERT(varchar(10), tm.[TabID]) AS WhereToOpen
			FROM dbo.[dnn_EasyDNNNewsCategories] as c
			INNER JOIN @UserViewCategories AS uvc ON c.CategoryID = uvc.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategoryList] as cl ON c.CategoryID = cl.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as clink ON clink.CategoryID = cl.CategoryID AND clink.SourceModuleID = @ModuleID
			INNER JOIN dbo.[dnn_TabModules] AS tm ON clink.NewsModuleID = tm.ModuleID
			WHERE c.ArticleID = n.[ArticleID] AND cl.PortalID = @PortalID ORDER BY cl.Position)
		END		
	END AS WhereToOpenLink
	FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN(
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
			INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID AND (ti.TagID IN (SELECT [TagID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID))		
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 0
			AND na.HideDefaultLocale = 0
			AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
			AND na.ArticleID <> @ArticleID
			AND (@UserCanApprove = 1 OR na.Approved = 1)
			AND (na.Active = 1 OR na.UserID = @UserID)	
		UNION ALL
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
			INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID AND (ti.TagID IN (SELECT [TagID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID))		
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 1
			AND na.HideDefaultLocale = 0
			AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
			AND na.ArticleID <> @ArticleID
			AND aup.Show = 1
			AND (@UserCanApprove = 1 OR na.Approved = 1)
			AND (na.Active = 1 OR na.UserID = @UserID)
			AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
		UNION
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
			INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID AND (ti.TagID IN (SELECT [TagID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID))		
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 1
			AND na.HideDefaultLocale = 0
			AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
			AND na.ArticleID <> @ArticleID
			AND arp.Show = 1
			AND (@UserCanApprove = 1 OR na.Approved = 1)
			AND (na.Active = 1 OR na.UserID = @UserID)
			AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
		)
	ORDER BY
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC;

END
ELSE
BEGIN
	WITH FinalArticleIDsSet (ArticleID) AS(
	SELECT TOP (@NumberOfItems) n.[ArticleID]
	FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN(
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
			INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID AND (ti.TagID IN (SELECT [TagID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID))		
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 0
			AND na.HideDefaultLocale = 0
			AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
			AND na.ArticleID <> @ArticleID
			AND (@UserCanApprove = 1 OR na.Approved = 1)
			AND (na.Active = 1 OR na.UserID = @UserID)
		UNION ALL
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
			INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID AND (ti.TagID IN (SELECT [TagID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID))		
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 1
			AND na.HideDefaultLocale = 0
			AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
			AND na.ArticleID <> @ArticleID
			AND aup.Show = 1
			AND (@UserCanApprove = 1 OR na.Approved = 1)
			AND (na.Active = 1 OR na.UserID=@UserID)
			AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
		UNION
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
			INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID AND (ti.TagID IN (SELECT [TagID] FROM dbo.[dnn_EasyDNNNewsTagsItems] WHERE ArticleID = @ArticleID))		
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 1
			AND na.HideDefaultLocale = 0
			AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
			AND na.ArticleID <> @ArticleID
			AND arp.Show = 1
			AND (@UserCanApprove = 1 OR na.Approved = 1)
			AND (na.Active = 1 OR na.UserID=@UserID)
			AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
		)
	ORDER BY
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC
),
FinalLocalizedArticleIDsSet (ArticleID,Title,SubTitle,Summary,Article,TitleLink) AS(
	SELECT ArticleID,Title,SubTitle,Summary,Article,clTitleLink AS TitleLink FROM dbo.[dnn_EasyDNNNewsContentLocalization] WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet) AND LocaleCode = @LocaleCode
)
SELECT *,
	CASE WHEN @CategoryFilterType = 0 THEN NULL
	ELSE
		CASE WHEN @FillterSettingsSource = 1 THEN
		 (SELECT TOP 1 CONVERT(varchar(10), clink.NewsModuleID) + ':' + CONVERT(varchar(10), tm.[TabID])
			FROM dbo.[dnn_EasyDNNNewsCategories] as c
			INNER JOIN @UserViewCategories AS uvc ON c.CategoryID = uvc.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategoryList] as cl ON c.CategoryID = cl.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsPortalCategoryLink] as clink ON clink.CategoryID = cl.CategoryID AND clink.SourcePortalID = @PortalID
			INNER JOIN dbo.[dnn_TabModules] AS tm ON clink.NewsModuleID = tm.ModuleID
			WHERE c.ArticleID = Result.[ArticleID] AND cl.PortalID = @PortalID ORDER BY cl.Position)
		ELSE
		(SELECT TOP 1 CONVERT(varchar(10), clink.NewsModuleID) + ':' + CONVERT(varchar(10), tm.[TabID]) AS WhereToOpen
			FROM dbo.[dnn_EasyDNNNewsCategories] as c
			INNER JOIN @UserViewCategories AS uvc ON c.CategoryID = uvc.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategoryList] as cl ON c.CategoryID = cl.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as clink ON clink.CategoryID = cl.CategoryID AND clink.SourceModuleID = @ModuleID
			INNER JOIN dbo.[dnn_TabModules] AS tm ON clink.NewsModuleID = tm.ModuleID
			WHERE c.ArticleID = Result.[ArticleID] AND cl.PortalID = @PortalID ORDER BY cl.Position)
		END		
	END AS WhereToOpenLink
	 FROM (
		 SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[PublishDate],n.[TitleLink],n.[NumberOfViews],n.[AuthorAliasName],n.[DetailType],n.[DetailTypeData]
			FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
		 UNION ALL
		 SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[PublishDate],fla.[TitleLink],n.[NumberOfViews],n.[AuthorAliasName],n.[DetailType],n.[DetailTypeData]
			FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID) As Result
	ORDER BY
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC
END
END
ELSE
BEGIN
	SELECT TOP(1) n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[PublishDate],n.[TitleLink],n.[NumberOfViews],n.[AuthorAliasName],n.[DetailType],n.[DetailTypeData] FROM dbo.[dnn_EasyDNNNews] as n WHERE n.[ArticleID] = -1
END


