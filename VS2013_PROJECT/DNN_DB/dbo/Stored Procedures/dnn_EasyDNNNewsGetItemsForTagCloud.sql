CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetItemsForTagCloud]
	@PortalID int,
	@UserID int,
	@TagModuleID int,
	@AdminOrSuperUser bit  = 0,
	@CurrentDate DateTime,
	@OrderBy nvarchar(20) = 'Size DESC',
	@RowCount int = 0,
	@LocaleCode nvarchar(20) = '',
	@IsSocialInstance bit = 0,
	@FilterByDNNUserID int = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID int = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@ShowAllAuthors bit = 1, -- filter postavka menija
	@CategoryFilterType tinyint = 0, --0 All categories, 1 - SELECTion, 2 - AutoAdd
	@OnlyOneCategory int = 0, -- used for gererating tags by only one category need to filter by one category
	@HideUnlocalizedItems bit = 0,
	@PermissionSettingsSource tinyint = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID int = 0 -- NewsModuleID
AS
SET NOCOUNT ON;
DECLARE @UserCanApprove bit;
SET @UserCanApprove = 0;
DECLARE @UserInRoles TABLE (RoleID int NOT NULL PRIMARY KEY);
INSERT INTO @UserInRoles SELECT DISTINCT ur.[RoleID] FROM dbo.[dnn_UserRoles] AS ur INNER JOIN dbo.[dnn_Roles] AS r ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > GETUTCDATE()) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < GETUTCDATE());
DECLARE @UserViewCategories TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions and Module filter
DECLARE @FiltredByCategories TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories that are filtred by module or portal

DECLARE @SettingsSource bit; SET @SettingsSource = 1;
IF @AdminOrSuperUser = 1 OR @PermissionSettingsSource = 0
BEGIN
	INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
		BEGIN
			INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		END
		ELSE
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
	END
	ELSE -- by module
	BEGIN
		SELECT @SettingsSource = PermissionsPMSource FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID;
		IF @SettingsSource = 1
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL;
			END
		END
	END
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		IF EXISTS (
				SELECT TOP (1) ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
		)
		BEGIN
			INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		END
		ELSE
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpsc.[CategoryID]
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upsc.[CategoryID];
		END
	END
	ELSE -- by module
	BEGIN
		SELECT @SettingsSource = PermissionsPMSource FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID;
		IF @SettingsSource = 1
		BEGIN
			IF EXISTS (
				SELECT TOP (1) ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
			)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpsc.[CategoryID]
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upsc.[CategoryID];
			END
		END
		ELSE
		BEGIN
			IF EXISTS (
				SELECT TOP (1) ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.ShowAllCategories = 1
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID AND ups.ShowAllCategories = 1
			)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID GROUP BY rpsc.[CategoryID]
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID GROUP BY upsc.[CategoryID];
			END
		END
	END
END

IF @OnlyOneCategory <> 0 -- filtrira se po jednoj kategoriji
BEGIN
	INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories WHERE CategoryID = @OnlyOneCategory;
	INSERT INTO @FiltredByCategories SELECT @OnlyOneCategory;
END
ELSE
BEGIN
	IF @CategoryFilterType = 0 -- 0 All categories
	BEGIN
		INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
	BEGIN
			INSERT INTO @UserViewCategoriesWithFilter 
			SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @TagModuleID
			
			INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @TagModuleID;
	END
	ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
	BEGIN
		WITH hierarchy AS(
			SELECT [CategoryID], [ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @TagModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @TagModuleID)) AND PortalID = @PortalID
			UNION ALL
			SELECT c.[CategoryID], c.[ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
			INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
			INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;
	END
END
DECLARE @FilterBySocialGroup bit;
SET @FilterBySocialGroup = 0;
DECLARE @FilterAuthorOrAuthors bit;
SET @FilterAuthorOrAuthors = 0;

DECLARE @TempAuthorsIDList TABLE (UserID int NOT NULL PRIMARY KEY);
IF @IsSocialInstance = 1
	BEGIN
		IF @FilterByDNNGroupID <> 0
		BEGIN	
			SET @FilterBySocialGroup = 1;
		END
	END
ELSE
BEGIN
	IF @ShowAllAuthors = 0
	BEGIN
		SET @FilterAuthorOrAuthors = 1;
		INSERT INTO @TempAuthorsIDList
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @TagModuleID
		UNION 
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
			WHERE mgi.ModuleID = @TagModuleID
	END
END

IF @LocaleCode = ''
BEGIN
	IF @RowCount <> 0
	BEGIN
		SET ROWCOUNT @RowCount;
	END
	
	IF @IsSocialInstance = 0
	BEGIN
		SELECT * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
			INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
		WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
			UNION ALL
			SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
			UNION
			SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
			) as final
		)
		GROUP BY ti.TagID, nt.TagID, nt.Name) AS Result ORDER BY 
		CASE WHEN @OrderBy ='Name ASC' THEN Name END,
		CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
		CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
		CASE WHEN @OrderBy ='Size ASC' THEN Size END
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		SELECT * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
			INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
		WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
			UNION ALL
			SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
			UNION
			SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
			)as final
		)
		GROUP BY ti.TagID, nt.TagID, nt.Name) AS Result ORDER BY 
		CASE WHEN @OrderBy ='Name ASC' THEN Name END,
		CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
		CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
		CASE WHEN @OrderBy ='Size ASC' THEN Size END
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		SELECT * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
			INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
		WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
			UNION ALL
			SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1  AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
			UNION
			SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.PublishDate <= @CurrentDate
				AND na.ExpireDate >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
			)as final
		)
		GROUP BY ti.TagID, nt.TagID, nt.Name) AS Result ORDER BY 
		CASE WHEN @OrderBy ='Name ASC' THEN Name END,
		CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
		CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
		CASE WHEN @OrderBy ='Size ASC' THEN Size END
	END
  
	IF @RowCount <> 0
	BEGIN
		SET ROWCOUNT 0;
	END
END
ELSE
BEGIN
	IF @RowCount = 0
	BEGIN
		SET @RowCount = 500;
	END;
	
	IF @IsSocialInstance = 0
	BEGIN	
		WITH AllTags(TagID, Size, Name) AS (
		SELECT TOP(@RowCount) * FROM (
			SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
				INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
			WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
					AND na.HasPermissions = 0
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND na.HasPermissions = 1
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION
				SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND na.HasPermissions = 1
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				) AS final
			)
			GROUP BY ti.TagID, nt.TagID, nt.Name) AS Result ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END
	),
	LocalizedTags(TagID, Size, Name) AS (
		SELECT t.[TagID],t.[Size],ntl.[Name] FROM dbo.[dnn_EasyDNNNewsTagsLocalization] AS ntl INNER JOIN AllTags AS t on ntl.TagID = t.TagID WHERE ntl.LocaleCode = @LocaleCode
	),
	NotLocalizedTags(TagID, Size, Name) AS(
		SELECT [TagID],[Size],[Name] FROM AllTags WHERE TagID NOT IN (SELECT TagID FROM LocalizedTags)
	)
	SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS result ORDER BY 
		CASE WHEN @OrderBy ='Name ASC' THEN Name END,
		CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
		CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
		CASE WHEN @OrderBy ='Size ASC' THEN Size END;
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		WITH AllTags(TagID, Size, Name) AS (
		SELECT TOP(@RowCount) * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name]
			FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
				INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
			WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID 
					AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
					AND na.HasPermissions = 0
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND na.HasPermissions = 1
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION
				SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND na.HasPermissions = 1
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				) AS final
			)
			GROUP BY ti.TagID, nt.TagID, nt.Name) AS Result ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END
	),
	LocalizedTags(TagID, Size, Name) AS (
		SELECT t.[TagID],t.[Size],ntl.[Name] FROM dbo.[dnn_EasyDNNNewsTagsLocalization] AS ntl INNER JOIN AllTags AS t on ntl.TagID = t.TagID WHERE ntl.LocaleCode = @LocaleCode
	),
	NotLocalizedTags(TagID, Size, Name) AS(
		SELECT [TagID],[Size],[Name] FROM AllTags WHERE TagID NOT IN (SELECT TagID FROM LocalizedTags)
	)
	SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS result ORDER BY 
		CASE WHEN @OrderBy ='Name ASC' THEN Name END,
		CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
		CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
		CASE WHEN @OrderBy ='Size ASC' THEN Size END;
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		WITH AllTags(TagID, Size, Name) AS (
		SELECT TOP(@RowCount) * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name]
			FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
				INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
			WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
					AND na.HasPermissions = 0
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND na.UserID = @FilterByDNNUserID
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND na.HasPermissions = 1
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND na.UserID = @FilterByDNNUserID
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION
				SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
				WHERE na.PortalID=@PortalID
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND na.HasPermissions = 1
					AND na.PublishDate <= @CurrentDate
					AND na.ExpireDate >= @CurrentDate
					AND na.UserID = @FilterByDNNUserID
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				) AS final
			)
			GROUP BY ti.TagID, nt.TagID, nt.Name) AS Result ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END
	),
	LocalizedTags(TagID, Size, Name) AS (
		SELECT t.[TagID],t.[Size],ntl.[Name] FROM dbo.[dnn_EasyDNNNewsTagsLocalization] AS ntl INNER JOIN AllTags AS t on ntl.TagID = t.TagID WHERE ntl.LocaleCode = @LocaleCode
	),
	NotLocalizedTags(TagID, Size, Name) AS(
		SELECT [TagID],[Size],[Name] FROM AllTags WHERE TagID NOT IN (SELECT TagID FROM LocalizedTags)
	)
	SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS result ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
	END
	
	IF @RowCount <> 0
	BEGIN
		SET ROWCOUNT 0;
	END

END

