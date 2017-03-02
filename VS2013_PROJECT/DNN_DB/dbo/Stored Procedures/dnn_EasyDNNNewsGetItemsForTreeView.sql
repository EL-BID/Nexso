CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetItemsForTreeView]
	@PortalID int,
	@UserID int,
	@MenuModuleID int,
	@DefaultTabID int,
    @DefaultModuleID int,
	@CurrentDate DateTime,
	@AdminOrSuperUser bit  = 0,
	@CountItems bit = 0,
	@IsSocialInstance bit = 0,
	@FilterByDNNUserID int = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID int = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@LocaleCode nvarchar(20) = '',	
	@ShowAllAuthors bit = 1, -- filter postavka menija
	@CategoryFilterType tinyint = 0, --0 All categories, 1 - Selection, 2 - AutoAdd
	@HideUnlocalizedItems bit = 0,
	@PermissionSettingsSource tinyint = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID int = 0 -- NewsModuleID
AS
SET NOCOUNT ON;
DECLARE @UserCanApprove bit;
SET @UserCanApprove = 0;
DECLARE @UserInRoles table (RoleID int NOT NULL PRIMARY KEY);
INSERT INTO @UserInRoles SELECT DISTINCT ur.[RoleID] FROM dbo.[dnn_UserRoles] AS ur INNER JOIN dbo.[dnn_Roles] AS r ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > GETUTCDATE()) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < GETUTCDATE());
DECLARE @UserViewCategories table (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
DECLARE @UserViewCategoriesWithFilter table (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions and Module filter

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
END
ELSE IF @CategoryFilterType = 1 -- 1 - Selection
BEGIN
		INSERT INTO @UserViewCategoriesWithFilter 
		SELECT cl.[CategoryID] FROM @UserViewCategories as cl
		INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @MenuModuleID
END
ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
BEGIN
	WITH hierarchy AS(
		SELECT [CategoryID], [ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
		WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @MenuModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @MenuModuleID)) AND PortalID = @PortalID
		UNION ALL
		SELECT c.[CategoryID], c.[ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
		)
	INSERT INTO @UserViewCategoriesWithFilter SELECT DISTINCT uvc.CategoryID FROM hierarchy as nfc INNER JOIN @UserViewCategories as uvc ON uvc.CategoryID = nfc.CategoryID;
END

DECLARE @FilterBySocialGroup bit;
SET @FilterBySocialGroup = 0;
DECLARE @FilterAuthorOrAuthors bit;
SET @FilterAuthorOrAuthors = 0;

DECLARE @TempAuthorsIDList table (UserID int NOT NULL PRIMARY KEY);
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
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @MenuModuleID
		UNION 
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
			WHERE mgi.ModuleID = @MenuModuleID
	END
END

DECLARE @tempMenuCats TABLE(
	[CategoryID] int NOT NULL PRIMARY KEY,
	[PortalID] int,
	[CategoryName] nvarchar(200),
	[Position] int,
	[ParentCategory] int,
	[Level] int,
	[CategoryURL] nvarchar(1500),
	[CategoryImage] nvarchar(1500),
	[CategoryText] ntext,[Show] bit)

IF @LocaleCode <> ''
BEGIN
	WITH LocCategories([CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText]) AS 
	(
		SELECT Cat.[CategoryID],Cat.[PortalID],cl.[Title] AS CategoryName,Cat.[Position],Cat.[ParentCategory],Cat.[Level],Cat.[CategoryURL],Cat.[CategoryImage],cl.[CategoryText] FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategoriesWithFilter cwf ON cwf.CategoryID = Cat.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLocalization] AS cl ON cwf.CategoryID = cl.CategoryID WHERE Cat.PortalID = @PortalID AND cl.LocaleCode = @LocaleCode
	),
	NotLocCategories([CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText]) AS 
	(
		SELECT Cat.* FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategoriesWithFilter cwf ON cwf.CategoryID = Cat.CategoryID WHERE Cat.PortalID = @PortalID AND Cat.CategoryID NOT IN (SELECT lctemp.CategoryID FROM LocCategories as lctemp)
	)
	INSERT INTO @tempMenuCats SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],'1' AS Show FROM (SELECT * FROM LocCategories UNION ALL SELECT * FROM NotLocCategories) as result
END
ELSE
BEGIN
	
INSERT @tempMenuCats SELECT
 [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],'1' AS Show
 FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cat WHERE cat.CategoryID in (SELECT CategoryID FROM @UserViewCategoriesWithFilter) AND PortalID = @PortalID;

END

INSERT @tempMenuCats SELECT
 [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],'0' AS Show
  FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID AND CategoryID not in (SELECT CategoryID FROM @UserViewCategoriesWithFilter);
  
SELECT TOP 1 @DefaultTabID = TabID FROM dbo.[dnn_TabModules] WHERE ModuleID = @DefaultModuleID;

IF @CountItems = 0
BEGIN 
	SELECT ncl.[CategoryID],ncl.[PortalID],ncl.[CategoryName],ncl.[Position],ncl.[ParentCategory],ncl.[Level],ncl.[CategoryURL],ncl.[CategoryImage],ncl.[CategoryText],ncl.Show,
	0 AS 'Count',
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID
	ORDER BY Position ASC, ParentCategory ASC;
END
ELSE
BEGIN

IF @HideUnlocalizedItems = 0
BEGIN

IF @IsSocialInstance = 0
BEGIN
SELECT *,
	CASE Show
	 WHEN 0 THEN 0
	 WHEN 1 THEN	
		CASE @AdminOrSuperUser
		WHEN 1 THEN
		(
		 SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
			 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
			 WHERE n.PublishDate <= @CurrentDate
			 AND n.ExpireDate >= @CurrentDate
			 AND n.PortalID = @PortalID
			 AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))			 
		)
		WHEN 0 THEN
		(
		SELECT (
					(
						SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						 WHERE n.PublishDate <= @CurrentDate
							 AND n.ExpireDate >= @CurrentDate
							 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							 AND n.HasPermissions = 0
							 AND n.PortalID = @PortalID
							 AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					 )
					 +
					(
						SELECT count(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
						 WHERE ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					 		AND n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
							AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					 )	 
					+ 
					(
						CASE @UserID
						WHEN -1 THEN 0
						ELSE			
					(
						SELECT count(PerRoles.[ArticleID]) FROM 
						
						(SELECT DISTINCT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
						 WHERE arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
						  AND arp.ArticleID NOT IN (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
								WHERE aup.UserID = @UserID
					 				AND n.PublishDate <= @CurrentDate
									AND n.ExpireDate >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved = 1))
									AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
									AND n.HasPermissions = 1
									AND n.PortalID = @PortalID
									AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							)
						 ) as PerRoles 
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = PerRoles.ArticleID
						 WHERE n.PublishDate <= @CurrentDate
						 AND n.ExpireDate >= @CurrentDate
						 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
						 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
						 AND n.HasPermissions = 1
						 AND n.PortalID = @PortalID
						 AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						 )
			END
					)
				)
		)
		END		
	 END AS 'Count'
	FROM 
	(SELECT 
	ncl.[CategoryID],
	ncl.[PortalID],
	ncl.[CategoryName],
	ncl.[Position],
	ncl.[ParentCategory],
	ncl.[Level],
	ncl.[CategoryURL],
	ncl.[CategoryImage],
	ncl.[CategoryText],
	ncl.Show,
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) as Result
	ORDER BY Position ASC, ParentCategory ASC	
END
ELSE IF @FilterBySocialGroup = 1
BEGIN
SELECT *,
	CASE Show
	 WHEN 0 THEN 0
	 WHEN 1 THEN	
		CASE @AdminOrSuperUser
		WHEN 1 THEN
		(
		 SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
			 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
			 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
			 INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
			 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			 WHERE  n.PublishDate <= @CurrentDate
				AND n.ExpireDate >= @CurrentDate
				AND n.PortalID = @PortalID
		)
		WHEN 0 THEN
		(
		SELECT (
					(
						SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 WHERE n.PublishDate <= @CurrentDate
							 AND n.ExpireDate >= @CurrentDate
							 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							 AND n.HasPermissions = 0
							 AND n.PortalID = @PortalID
					 )
					 +
					(
						SELECT count(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 WHERE ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					 		AND n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
					 )	 
					+ 
					(
						CASE @UserID
						WHEN -1 THEN 0
						ELSE			
					(
						SELECT count(PerRoles.[ArticleID]) FROM 
						
						(SELECT DISTINCT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
						 WHERE arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
						  AND arp.ArticleID NOT IN (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								WHERE aup.UserID = @UserID
					 				AND n.PublishDate <= @CurrentDate
									AND n.ExpireDate >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved = 1))
									AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
									AND n.HasPermissions = 1
									AND n.PortalID = @PortalID
							)
						 ) as PerRoles 
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = PerRoles.ArticleID
						 WHERE n.PublishDate <= @CurrentDate
						 AND n.ExpireDate >= @CurrentDate
						 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
						 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
						 AND n.HasPermissions = 1
						 AND n.PortalID = @PortalID
						 )
			END
					)
				)
		)
		END		
	 END AS 'Count'
	FROM 
	(SELECT 
	ncl.[CategoryID],
	ncl.[PortalID],
	ncl.[CategoryName],
	ncl.[Position],
	ncl.[ParentCategory],
	ncl.[Level],
	ncl.[CategoryURL],
	ncl.[CategoryImage],
	ncl.[CategoryText],
	ncl.Show,
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) as Result
	ORDER BY Position ASC, ParentCategory ASC	
END
ELSE IF @FilterByDNNUserID <> 0
BEGIN
SELECT *,
	CASE Show
	 WHEN 0 THEN 0
	 WHEN 1 THEN	
		CASE @AdminOrSuperUser
		WHEN 1 THEN
		(
		 SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
		 
			 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID
			 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
			 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			 WHERE  n.PublishDate <= @CurrentDate
				AND n.ExpireDate >= @CurrentDate
				AND n.PortalID = @PortalID
				AND n.UserID = @FilterByDNNUserID 
		)
		WHEN 0 THEN
		(
		SELECT (
					(
						SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 WHERE n.PublishDate <= @CurrentDate
							 AND n.ExpireDate >= @CurrentDate
							 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							 AND n.HasPermissions = 0
							 AND n.PortalID = @PortalID
							 AND n.UserID = @FilterByDNNUserID
					)
					 +
					(
						SELECT count(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 WHERE ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					 		AND n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
							AND n.UserID = @FilterByDNNUserID 					 )	 
					+ 
					(
						CASE @UserID
						WHEN -1 THEN 0
						ELSE			
					(
						SELECT count(PerRoles.[ArticleID]) FROM 
						
						(SELECT DISTINCT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
						 WHERE arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
						  AND arp.ArticleID NOT IN (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								WHERE aup.UserID = @UserID
					 				AND n.PublishDate <= @CurrentDate
									AND n.ExpireDate >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved = 1))
									AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
									AND n.HasPermissions = 1
									AND n.PortalID = @PortalID
									AND n.UserID = @FilterByDNNUserID 
			  				)
						 ) as PerRoles 
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = PerRoles.ArticleID
						 WHERE n.PublishDate <= @CurrentDate
						 AND n.ExpireDate >= @CurrentDate
						 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
						 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
						 AND n.HasPermissions = 1
						 AND n.PortalID = @PortalID
						 AND n.UserID = @FilterByDNNUserID 						 )
			END
					)
				)
		)
		END		
	 END AS 'Count'
	FROM 
	(SELECT 
	ncl.[CategoryID],
	ncl.[PortalID],
	ncl.[CategoryName],
	ncl.[Position],
	ncl.[ParentCategory],
	ncl.[Level],
	ncl.[CategoryURL],
	ncl.[CategoryImage],
	ncl.[CategoryText],
	ncl.Show,
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) as Result
	ORDER BY Position ASC, ParentCategory ASC
END
END

ELSE
BEGIN

IF @IsSocialInstance = 0
BEGIN
SELECT *,
	CASE Show
	 WHEN 0 THEN 0
	 WHEN 1 THEN	
		CASE @AdminOrSuperUser
		WHEN 1 THEN
		(
		 SELECT count(c.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
			 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
			 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
			 WHERE n.PublishDate <= @CurrentDate
				AND n.ExpireDate >= @CurrentDate
				AND n.PortalID = @PortalID
				AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))		 
		)
		WHEN 0 THEN
		(
		SELECT (
					(
						SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE n.PublishDate <= @CurrentDate
							 AND n.ExpireDate >= @CurrentDate
							 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							 AND n.HasPermissions = 0
							 AND n.PortalID = @PortalID
							 AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					 )
					 +
					(
						SELECT count(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					 		AND n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
							AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					 )	 
					+ 
					(
						CASE @UserID
						WHEN -1 THEN 0
						ELSE			
					(
						SELECT count(PerRoles.[ArticleID]) FROM 
						
						(SELECT DISTINCT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = arp.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
						  AND arp.ArticleID NOT IN (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
								WHERE aup.UserID = @UserID
					 				AND n.PublishDate <= @CurrentDate
									AND n.ExpireDate >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved = 1))
									AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
									AND n.HasPermissions = 1
									AND n.PortalID = @PortalID
									AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							)
						 ) as PerRoles 
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = PerRoles.ArticleID
						 WHERE n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
							AND((@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						 )
			END
					)
				)
		)
		END		
	 END AS 'Count'
	FROM 
	(SELECT 
	ncl.[CategoryID],
	ncl.[PortalID],
	ncl.[CategoryName],
	ncl.[Position],
	ncl.[ParentCategory],
	ncl.[Level],
	ncl.[CategoryURL],
	ncl.[CategoryImage],
	ncl.[CategoryText],
	ncl.Show,
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) as Result
	ORDER BY Position ASC, ParentCategory ASC
END
ELSE IF @FilterBySocialGroup = 1
BEGIN
SELECT *,
	CASE Show
	 WHEN 0 THEN 0
	 WHEN 1 THEN	
		CASE @AdminOrSuperUser
		WHEN 1 THEN
		(
		 SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
			 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
			 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
			 INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
			 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
			 WHERE n.PublishDate <= @CurrentDate
				AND n.ExpireDate >= @CurrentDate
				AND n.PortalID = @PortalID
		)
		WHEN 0 THEN
		(
		SELECT (
					(
						SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE n.PublishDate <= @CurrentDate
							 AND n.ExpireDate >= @CurrentDate
							 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							 AND n.HasPermissions = 0
							 AND n.PortalID = @PortalID
					 )
					 +
					(
						SELECT count(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					 		AND n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
					 )	 
					+ 
					(
						CASE @UserID
						WHEN -1 THEN 0
						ELSE			
					(
						SELECT count(PerRoles.[ArticleID]) FROM 
						
						(SELECT DISTINCT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = arp.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
						  AND arp.ArticleID NOT IN (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
								WHERE aup.UserID = @UserID
					 				AND n.PublishDate <= @CurrentDate
									AND n.ExpireDate >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved = 1))
									AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
									AND n.HasPermissions = 1
									AND n.PortalID = @PortalID
							)
						 ) as PerRoles 
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = PerRoles.ArticleID
						 WHERE n.PublishDate <= @CurrentDate
						 AND n.ExpireDate >= @CurrentDate
						 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
						 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
						 AND n.HasPermissions = 1
						 AND n.PortalID = @PortalID
						 )
			END
					)
				)
		)
		END		
	 END AS 'Count'
	FROM 
	(SELECT 
	ncl.[CategoryID],
	ncl.[PortalID],
	ncl.[CategoryName],
	ncl.[Position],
	ncl.[ParentCategory],
	ncl.[Level],
	ncl.[CategoryURL],
	ncl.[CategoryImage],
	ncl.[CategoryText],
	ncl.Show,
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) as Result
	ORDER BY Position ASC, ParentCategory ASC	
END
ELSE IF @FilterByDNNUserID <> 0
BEGIN
SELECT *,
	CASE Show
	 WHEN 0 THEN 0
	 WHEN 1 THEN	
		CASE @AdminOrSuperUser
		WHEN 1 THEN
		(
		 SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n	 
			 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
			 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
			 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
			 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
			 WHERE n.PublishDate <= @CurrentDate
			 AND n.ExpireDate >= @CurrentDate
			 AND n.PortalID = @PortalID
			 AND n.UserID = @FilterByDNNUserID 
		)
		WHEN 0 THEN
		(
		SELECT (
					(
						SELECT count(n.[ArticleID]) as cnt FROM dbo.[dnn_EasyDNNNews] AS n
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE n.PublishDate <= @CurrentDate
							 AND n.ExpireDate >= @CurrentDate
							 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							 AND n.HasPermissions = 0
							 AND n.PortalID = @PortalID
							 AND n.UserID = @FilterByDNNUserID
					)
					 +
					(
						SELECT count(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
						 INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						 INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					 		AND n.PublishDate <= @CurrentDate
							AND n.ExpireDate >= @CurrentDate
							AND ((@UserCanApprove = 1) OR (n.Approved = 1))
							AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
							AND n.HasPermissions = 1
							AND n.PortalID = @PortalID
							AND n.UserID = @FilterByDNNUserID 					 )	 
					+ 
					(
						CASE @UserID
						WHEN -1 THEN 0
						ELSE			
					(
						SELECT count(PerRoles.[ArticleID]) FROM 
						
						(SELECT DISTINCT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] as arp
						 INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
						 INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = arp.ArticleID AND ncl.LocaleCode = @LocaleCode
						 WHERE arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
						  AND arp.ArticleID NOT IN (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID AND ncl.LocaleCode = @LocaleCode
								WHERE aup.UserID = @UserID
					 				AND n.PublishDate <= @CurrentDate
									AND n.ExpireDate >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved = 1))
									AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
									AND n.HasPermissions = 1
									AND n.PortalID = @PortalID
									AND n.UserID = @FilterByDNNUserID 
			  				)
						 ) as PerRoles 
						 INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = PerRoles.ArticleID
						 WHERE n.PublishDate <= @CurrentDate
						 AND n.ExpireDate >= @CurrentDate
						 AND ((@UserCanApprove = 1) OR (n.Approved = 1))
						 AND ((@AdminOrSuperUser = 1) OR (n.Active = 1 OR n.UserID=@UserID))
						 AND n.HasPermissions = 1
						 AND n.PortalID = @PortalID
						 AND n.UserID = @FilterByDNNUserID 						 )
			END
					)
				)
		)
		END		
	 END AS 'Count'
	FROM 
	(SELECT 
	ncl.[CategoryID],
	ncl.[PortalID],
	ncl.[CategoryName],
	ncl.[Position],
	ncl.[ParentCategory],
	ncl.[Level],
	ncl.[CategoryURL],
	ncl.[CategoryImage],
	ncl.[CategoryText],
	ncl.Show,
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats as ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] as cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) as Result
	ORDER BY Position ASC, ParentCategory ASC
END

END

END

