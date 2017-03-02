CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetItemsByMonthlyArchive]
	@PortalID int,
	@UserID int,
	@CalendarModuleID int,
	@AdminOrSuperUser bit  = 0,
	@CurrentDate DateTime,
	@LocaleCode nvarchar(20) = '',
	@IsSocialInstance bit = 0,
	@FilterByDNNUserID int = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID int = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@ShowAllAuthors bit = 1, -- filter postavka menija
	@CategoryFilterType tinyint = 0, --0 All categories, 1 - Selection, 2 - AutoAdd
	@HideUnlocalizedItems bit = 0,
	@PermissionSettingsSource tinyint = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID int = 0, -- NewsModuleID
	@DateTimeOffset int
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
		IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
		BEGIN
			INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		END
		ELSE
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] as rpsc 
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
	END
	ELSE -- by module
	BEGIN
		SELECT @SettingsSource = PermissionsPMSource FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID;
		IF @SettingsSource = 1
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] as rpsc 
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] as rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
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
				SELECT TOP (1) ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps
					INNER JOIN @UserInRoles as uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] as ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
		)
		BEGIN
			INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		END
		ELSE
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] as rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			INNER JOIN @UserInRoles as uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpsc.[CategoryID]
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] as upsc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] as ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upsc.[CategoryID];
		END
	END
	ELSE -- by module
	BEGIN
		SELECT @SettingsSource = PermissionsPMSource FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID;
		IF @SettingsSource = 1
		BEGIN
			IF EXISTS (
				SELECT TOP (1) ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps
					INNER JOIN @UserInRoles as uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] as ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
			)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] as rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN @UserInRoles as uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpsc.[CategoryID]
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] as upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] as ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upsc.[CategoryID];
			END
		END
		ELSE
		BEGIN
			IF EXISTS (
				SELECT TOP (1) ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps
					INNER JOIN @UserInRoles as uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.ShowAllCategories = 1
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] as ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID AND ups.ShowAllCategories = 1
			)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] as rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] as rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN @UserInRoles as uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID GROUP BY rpsc.[CategoryID]
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] as upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] as ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID GROUP BY upsc.[CategoryID];
			END
		END
	END
END

IF @CategoryFilterType = 0 -- 0 All categories
BEGIN
	INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
	INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE IF @CategoryFilterType = 1 -- 1 - Selection
BEGIN
		INSERT INTO @UserViewCategoriesWithFilter 
		SELECT cl.[CategoryID] FROM @UserViewCategories as cl
		INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @CalendarModuleID
		
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID;
END
ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
BEGIN
	WITH hierarchy AS(
		SELECT [CategoryID], [ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
		WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID)) AND PortalID = @PortalID
		UNION ALL
		SELECT c.[CategoryID], c.[ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
		)
		INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
		INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories as nfc INNER JOIN @UserViewCategories as uvc ON uvc.CategoryID = nfc.CategoryID;
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
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @CalendarModuleID
		UNION 
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
			WHERE mgi.ModuleID = @CalendarModuleID
	END
END

IF @LocaleCode = ''
BEGIN
	IF @IsSocialInstance = 0
	BEGIN
		SELECT MONTH(final.PublishDate) AS Month, YEAR(final.PublishDate) AS Year, COUNT(*) AS Count FROM (
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] FROM dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter as uvcwf ON uvcwf.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION ALL
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] as aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (
					((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID))
					)
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
		) as final
		GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY Year DESC, Month DESC;
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		SELECT MONTH(final.PublishDate) AS Month, YEAR(final.PublishDate) AS Year, COUNT(*) AS Count FROM (
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] FROM dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter as uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION ALL
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] as aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
		) as final
		GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY Year DESC, Month DESC;
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		SELECT MONTH(final.PublishDate) AS Month, YEAR(final.PublishDate) AS Year, COUNT(*) AS Count FROM (
			SELECT na.[ArticleID],DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] FROM dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter as uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION ALL
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] as aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
		) as final
		GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY Year DESC, Month DESC;
	END
END
ELSE
BEGIN
	IF @IsSocialInstance = 0
	BEGIN
		SELECT MONTH(final.PublishDate) AS Month, YEAR(final.PublishDate) AS Year, COUNT(*) AS Count FROM (
			SELECT na.[ArticleID],DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] FROM dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter as uvcwf ON uvcwf.CategoryID = cat.CategoryID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION ALL
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] as aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				AND na.HasPermissions = 1
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
		) as final
		GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY Year DESC, Month DESC;
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		SELECT MONTH(final.PublishDate) AS Month, YEAR(final.PublishDate) AS Year, COUNT(*) AS Count FROM (
			SELECT na.[ArticleID],DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] FROM dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter as uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION ALL
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] as aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				AND na.HasPermissions = 1
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
		) as final
		GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY Year DESC, Month DESC;
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		SELECT MONTH(final.PublishDate) AS Month, YEAR(final.PublishDate) AS Year, COUNT(*) AS Count FROM (
			SELECT na.[ArticleID],DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] FROM dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter as uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION ALL
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] as aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				AND na.HasPermissions = 1
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
			UNION
			SELECT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) as [PublishDate] from dbo.[dnn_EasyDNNNews] as na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] as cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND DATEADD(hh, @DateTimeOffset, na.PublishDate) <= @CurrentDate
				AND DATEADD(hh, @DateTimeOffset, na.ExpireDate) >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
				AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
			GROUP BY na.ArticleID, DATEADD(hh, @DateTimeOffset, na.[PublishDate])
		) as final
		GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY Year DESC, Month DESC;
	END
END


