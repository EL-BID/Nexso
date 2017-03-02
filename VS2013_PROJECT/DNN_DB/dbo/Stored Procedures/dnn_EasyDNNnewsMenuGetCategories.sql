CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsMenuGetCategories]
	@PortalID INT,
	@UserID INT,
	@MenuModuleID INT,
	@DefaultTabID INT,
    @DefaultModuleID INT,
	@AdminOrSuperUser BIT  = 0,
	@CountItems BIT = 0,
	@CountArticles BIT = NULL,
	@CountEvents BIT = NULL,
	@CountEventsLimitByDays INT = NULL,
	@IsSocialInstance BIT = 0,
	@FilterByDNNUserID INT = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID INT = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@LocaleCode NVARCHAR(20) = NULL,	
	@ShowAllAuthors BIT = 1, -- filter postavka menija
	@CategoryFilterType TINYINT = 0, --0 All categories, 1 - SELECTion, 2 - AutoAdd
	@HideUnlocalizedItems BIT = 0,
	@PermissionSettingsSource TINYINT = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID INT = 0, -- NewsModuleID
	@UserCanApprove BIT = 0
AS
SET NOCOUNT ON;
DECLARE @sqlcommand NVARCHAR(max);

DECLARE @paramList NVARCHAR(2000);
SET @paramList = N'
	@PortalID INT,
	@UserID INT,
	@MenuModuleID INT,
	@DefaultTabID INT,
    @DefaultModuleID INT,
	@AdminOrSuperUser BIT,
	@CountItems BIT,
	@CountArticles BIT,
	@CountEvents BIT,
	@CountEventsLimitByDays INT,
	@IsSocialInstance BIT,
	@FilterByDNNUserID INT,
	@FilterByDNNGroupID INT,
	@LocaleCode NVARCHAR(20),	
	@ShowAllAuthors BIT,
	@CategoryFilterType TINYINT,
	@HideUnlocalizedItems BIT,
	@PermissionSettingsSource TINYINT,
	@PermissionsModuleID INT,
	@UserCanApprove BIT'
	
SET @sqlcommand = N'
SET NOCOUNT ON;
SET DATEFIRST 1;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @StartDate DATETIME;
IF @CountEventsLimitByDays IS NOT NULL
BEGIN
	SET @StartDate = DATEADD(DD, -@CountEventsLimitByDays, @CurrentDate);
	SET @CountEventsLimitByDays = 1;
END

DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate ) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);
DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY);

DECLARE @SettingsSource BIT; SET @SettingsSource = 1; '

IF @AdminOrSuperUser = 1 OR @PermissionSettingsSource = 0
SET @sqlcommand = @sqlcommand + N' INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		SET @sqlcommand = @sqlcommand + N' 
		IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		ELSE
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL; '
	END
	ELSE -- by module
	BEGIN
		SET @sqlcommand = @sqlcommand + N' 
		SELECT @SettingsSource = PermissionsPMSource FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID;
		IF @SettingsSource = 1
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL;
		END '
	END
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		SET @sqlcommand = @sqlcommand + N' 
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
		END '
	END
	ELSE -- by module
	BEGIN
		SET @sqlcommand = @sqlcommand + N' 
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
					WHERE rps.ModuleID = @PermissionsModuleID AND rps.ShowAllCategories = 1 -- MAKNUTO PORTALID
				UNION
				SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.ModuleID = @PermissionsModuleID AND ups.ShowAllCategories = 1  -- MAKNUTO PORTALID
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
				WHERE rps.ModuleID = @PermissionsModuleID GROUP BY rpsc.[CategoryID]  -- MAKNUTO PORTALID
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.ModuleID = @PermissionsModuleID GROUP BY upsc.[CategoryID];  -- MAKNUTO PORTALID
			END
		END'
	END
END

IF @CategoryFilterType = 0 -- 0 All categories
SET @sqlcommand = @sqlcommand + N' INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories; ';
ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
SET @sqlcommand = @sqlcommand + N' 
	INSERT INTO @UserViewCategoriesWithFilter 
	SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
	INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @MenuModuleID '
ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
SET @sqlcommand = @sqlcommand + N' 
	;WITH hierarchy AS(
		SELECT [CategoryID], [ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
		WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @MenuModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @MenuModuleID)) AND PortalID = @PortalID
		UNION ALL
		SELECT c.[CategoryID], c.[ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
		)
	INSERT INTO @UserViewCategoriesWithFilter SELECT DISTINCT uvc.CategoryID FROM hierarchy AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID; '

IF @IsSocialInstance = 0 AND @ShowAllAuthors = 0
SET @sqlcommand = @sqlcommand + N'
DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY);

INSERT INTO @TempAuthorsIDList
SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @MenuModuleID
UNION 
SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
	INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
	INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
	WHERE mgi.ModuleID = @MenuModuleID '

ELSE IF @IsSocialInstance = 1 AND @FilterByDNNGroupID <> 0
SET @sqlcommand = @sqlcommand + N'
DECLARE @FilterBySocialGroup BIT;
SET @FilterBySocialGroup = 1; ';

SET @sqlcommand = @sqlcommand + N' 
DECLARE @tempMenuCats TABLE(
	[CategoryID] INT NOT NULL PRIMARY KEY,
	[PortalID] INT,
	[CategoryName] NVARCHAR(200),
	[Position] INT,
	[ParentCategory] INT,
	[Level] INT,
	[CategoryURL] NVARCHAR(1500),
	[CategoryImage] NVARCHAR(1500),
	[CategoryText] ntext,[Show] BIT) '

IF @LocaleCode IS NOT NULL
SET @sqlcommand = @sqlcommand + N' 
	;WITH LocCategories([CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText]) AS 
	(
		SELECT Cat.[CategoryID],Cat.[PortalID],cl.[Title] AS CategoryName,Cat.[Position],Cat.[ParentCategory],Cat.[Level],Cat.[CategoryURL],Cat.[CategoryImage],cl.[CategoryText] FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategoriesWithFilter cwf ON cwf.CategoryID = Cat.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLocalization] AS cl ON cwf.CategoryID = cl.CategoryID WHERE Cat.PortalID = @PortalID AND cl.LocaleCode = @LocaleCode
	),
	NotLocCategories([CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText]) AS 
	(
		SELECT Cat.* FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategoriesWithFilter cwf ON cwf.CategoryID = Cat.CategoryID WHERE Cat.PortalID = @PortalID AND Cat.CategoryID NOT IN (SELECT CategoryID FROM LocCategories)
	)
	INSERT INTO @tempMenuCats SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],''1'' AS Show FROM (SELECT * FROM LocCategories UNION ALL SELECT * FROM NotLocCategories) AS result '
ELSE
SET @sqlcommand = @sqlcommand + N' 
	INSERT @tempMenuCats
	SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],''1'' AS Show
	FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cat WHERE cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter) AND PortalID = @PortalID; '

SET @sqlcommand = @sqlcommand + N'
INSERT @tempMenuCats
SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],''0'' AS Show
FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID AND CategoryID NOT IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter);
  
SELECT TOP 1 @DefaultTabID = TabID FROM dbo.[dnn_TabModules] WHERE ModuleID = @DefaultModuleID; '

IF @CountItems = 1 AND @CountArticles = 0 AND @CountEvents = 0
SET @CountItems = 0

IF @CountItems = 0
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	SELECT ncl.[CategoryID],ncl.[PortalID],ncl.[CategoryName],ncl.[Position],ncl.[ParentCategory],ncl.[Level],ncl.[CategoryURL],ncl.[CategoryImage],ncl.[CategoryText],ncl.Show,0 AS ''Count'',
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats AS ncl
		LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
		LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID
	ORDER BY Position ASC, ParentCategory ASC;'
END
ELSE
BEGIN
	IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
	BEGIN
		SET @sqlcommand = @sqlcommand + N'
		SELECT *,
		CASE Show
			WHEN 0 THEN 0
			WHEN 1 THEN	
				CASE @AdminOrSuperUser
				WHEN 1 THEN(
					SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID'
						IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
						IF @FilterByDNNGroupID <> 0 
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						ELSE IF @FilterByDNNUserID <> 0
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
					
					SET @sqlcommand = @sqlcommand + N' 
					WHERE n.PortalID = @PortalID
						AND n.EventArticle = 0
						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
						IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
						IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
						ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
				SET @sqlcommand = @sqlcommand + N'
				)
				WHEN 0 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID'
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						
						SET @sqlcommand = @sqlcommand + N' 
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 0
							AND n.EventArticle = 0
							AND (n.Active = 1 OR n.UserID = @UserID)
							AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
						SET @sqlcommand = @sqlcommand + N'
						)+(
						SELECT COUNT([ArticleID]) FROM (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID'
								IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
								
								IF @FilterByDNNGroupID <> 0 
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
								ELSE IF @FilterByDNNUserID <> 0
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
								AND (n.Active = 1 OR n.UserID = @UserID)
			 					AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
								IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '							
								IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
								IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
								ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
								IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
								ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'
							UNION
							SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID'
								IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
								IF @FilterByDNNGroupID <> 0 
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
								ELSE IF @FilterByDNNUserID <> 0
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
							WHERE n.PortalID = @PortalID
								AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
								AND (n.Active = 1 OR n.UserID = @UserID)
								AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
								IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
								IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
								IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
								ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'
						) AS UserAndRolePermissions
					))
				)
			END		
		END AS ''Count''
		FROM (
			SELECT ncl.[CategoryID],ncl.[PortalID],ncl.[CategoryName],ncl.[Position],ncl.[ParentCategory],ncl.[Level],ncl.[CategoryURL],ncl.[CategoryImage],ncl.[CategoryText],ncl.Show,
				CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
				CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID
		) AS Result
		ORDER BY Position ASC, ParentCategory ASC'
	END
	ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
	BEGIN
		SET @sqlcommand = @sqlcommand + N'
		SELECT *,
		CASE Show
			WHEN 0 THEN 0
			WHEN 1 THEN	
				CASE @AdminOrSuperUser
				WHEN 1 THEN(
				SELECT ((
					SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
						IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
						IF @FilterByDNNGroupID <> 0 
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						ELSE IF @FilterByDNNUserID <> 0
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						
						SET @sqlcommand = @sqlcommand + N' 
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
					WHERE n.PortalID = @PortalID
						AND n.EventArticle = 1
						AND ne.Recurring = 0
						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
						IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
						IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
						IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
						ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
						SET @sqlcommand = @sqlcommand + N'
					)+(
					SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
						IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
						IF @FilterByDNNGroupID <> 0 
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						ELSE IF @FilterByDNNUserID <> 0
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						
						SET @sqlcommand = @sqlcommand + N' 
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
						IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
						SET @sqlcommand = @sqlcommand + N' 
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END '
						ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
						SET @sqlcommand = @sqlcommand + N' 
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END '
					SET @sqlcommand = @sqlcommand + N' 
					WHERE n.PortalID = @PortalID
						AND n.EventArticle = 1
						AND ne.Recurring = 1
						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
						IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
						IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
						ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
						SET @sqlcommand = @sqlcommand + N'
					))
				)
				WHEN 0 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND (n.Active = 1 OR n.UserID = @UserID)
							AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
							IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
							SET @sqlcommand = @sqlcommand + N' 
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END '
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								SET @sqlcommand = @sqlcommand + N' 
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END '
						SET @sqlcommand = @sqlcommand + N' 
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND (n.Active = 1 OR n.UserID = @UserID)
							AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'
						)+(					
						SELECT COUNT(ArticleID) FROM (			
							SELECT ArticleID FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 0
									AND (n.Active = 1 OR n.UserID = @UserID)
			 						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
									ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'
								UNION ALL
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
									IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
									SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
										END '
									ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END '
									SET @sqlcommand = @sqlcommand + N' 
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 1
									AND (n.Active = 1 OR n.UserID = @UserID)
			 						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
									ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'		
							) AS PermissionsByUser
							UNION
							SELECT ArticleID FROM (
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 0
									AND (n.Active = 1 OR n.UserID = @UserID)
									AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'
								UNION ALL
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
									IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
									SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END '
									ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END '
								SET @sqlcommand = @sqlcommand + N' 
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 1
									AND (n.Active = 1 OR n.UserID = @UserID)
									AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'		
							) AS PermissionsByRoles
						) AS PermissionsByUserAndRole
						)
					)
				)
			END		
		END AS ''Count''
		FROM (
			SELECT	ncl.[CategoryID],ncl.[PortalID],ncl.[CategoryName],ncl.[Position],ncl.[ParentCategory],ncl.[Level],ncl.[CategoryURL],ncl.[CategoryImage],ncl.[CategoryText],ncl.Show,
				CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
				CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID
		) AS Result
		ORDER BY Position ASC, ParentCategory ASC'
	END
	ELSE -- articles and events
	BEGIN
		SET @sqlcommand = @sqlcommand + N'
		SELECT *,
		CASE Show
			WHEN 0 THEN 0
			WHEN 1 THEN	
				CASE @AdminOrSuperUser
				WHEN 1 THEN(
				SELECT ((
					SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
						IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
						IF @FilterByDNNGroupID <> 0 
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						ELSE IF @FilterByDNNUserID <> 0
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						
						SET @sqlcommand = @sqlcommand + N' 
					WHERE n.PortalID = @PortalID
						AND n.EventArticle = 0
						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
						IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
						IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
						ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
						SET @sqlcommand = @sqlcommand + N'	
					)+(
					SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
						IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
						IF @FilterByDNNGroupID <> 0 
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						ELSE IF @FilterByDNNUserID <> 0
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						
						SET @sqlcommand = @sqlcommand + N' 
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
					WHERE n.PortalID = @PortalID
						AND n.EventArticle = 1
						AND ne.Recurring = 0
						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
						IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
						IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
						IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
						ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
						SET @sqlcommand = @sqlcommand + N'	
					)+(
					SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
						IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
						IF @FilterByDNNGroupID <> 0 
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						ELSE IF @FilterByDNNUserID <> 0
							SET @sqlcommand = @sqlcommand + N'
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
						
						SET @sqlcommand = @sqlcommand + N' 
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
						IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
						SET @sqlcommand = @sqlcommand + N' 
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END '
						ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							SET @sqlcommand = @sqlcommand + N' 
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END '
					SET @sqlcommand = @sqlcommand + N' 
					WHERE n.PortalID = @PortalID
						AND n.EventArticle = 1
						AND ne.Recurring = 1
						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
						IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
						IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
						ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
						SET @sqlcommand = @sqlcommand + N'	
					))
				)
				WHEN 0 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 0
							AND n.EventArticle = 0 
							AND (n.Active = 1 OR n.UserID = @UserID)
							AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'	
						)+(
						SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND (n.Active = 1 OR n.UserID = @UserID)
							AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID '
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
							IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
							SET @sqlcommand = @sqlcommand + N' 
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END '
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								SET @sqlcommand = @sqlcommand + N' 
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END '
						SET @sqlcommand = @sqlcommand + N' 
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND (n.Active = 1 OR n.UserID = @UserID)
							AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'	
						)+(
						SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
							INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID '
							IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
							
							IF @FilterByDNNGroupID <> 0 
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							ELSE IF @FilterByDNNUserID <> 0
								SET @sqlcommand = @sqlcommand + N'
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
							
							SET @sqlcommand = @sqlcommand + N' 						
						WHERE n.PortalID = @PortalID
							AND n.HasPermissions = 1
							AND n.EventArticle = 0
							AND (n.Active = 1 OR n.UserID = @UserID)
			 				AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
							IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
							IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
							IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
							ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
							IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
							ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
							SET @sqlcommand = @sqlcommand + N'	
						)+(
						SELECT COUNT([ArticleID]) FROM (
							SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID '
								IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
								
								IF @FilterByDNNGroupID <> 0 
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
								ELSE IF @FilterByDNNUserID <> 0
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
								
								SET @sqlcommand = @sqlcommand + N' 
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
								AND (n.Active = 1 OR n.UserID = @UserID)
			 					AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
								IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
								IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
								IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
								ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
								IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
								ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
								SET @sqlcommand = @sqlcommand + N'	
							UNION
							SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID '
								IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
								
								IF @FilterByDNNGroupID <> 0 
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
								ELSE IF @FilterByDNNUserID <> 0
									SET @sqlcommand = @sqlcommand + N'
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
								
								SET @sqlcommand = @sqlcommand + N' 
							WHERE n.PortalID = @PortalID
								AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
								AND (n.Active = 1 OR n.UserID = @UserID)
								AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
								IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
								IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
								IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
								ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
								SET @sqlcommand = @sqlcommand + N'	
						) AS UserAndRolePermissions						
						)
						)+(
						SELECT COUNT(ArticleID) FROM (			
							SELECT ArticleID FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 0
									AND (n.Active = 1 OR n.UserID = @UserID)
			 						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
									ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'	
								UNION ALL
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
									IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
									SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END '
									ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END '
								SET @sqlcommand = @sqlcommand + N' 
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 1
									AND (n.Active = 1 OR n.UserID = @UserID)
			 						AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
									ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'						
							) AS PermissionsByUser
							UNION
							SELECT ArticleID FROM (
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 0
									AND (n.Active = 1 OR n.UserID = @UserID)
									AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @CountEventsLimitByDays IS NOT NULL SET @sqlcommand = @sqlcommand + N' AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'	
								UNION ALL
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID '
									IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = c.ArticleID AND ncl.LocaleCode = @LocaleCode '
									
									IF @FilterByDNNGroupID <> 0 
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									ELSE IF @FilterByDNNUserID <> 0
										SET @sqlcommand = @sqlcommand + N'
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
									
									SET @sqlcommand = @sqlcommand + N' 
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = '
									IF @CountEventsLimitByDays IS NOT NULL -- @StartDate min value
									SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END '
									ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										SET @sqlcommand = @sqlcommand + N' 
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END '
								SET @sqlcommand = @sqlcommand + N' 
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 1
									AND ne.Recurring = 1
									AND (n.Active = 1 OR n.UserID = @UserID)
									AND @CurrentDate BETWEEN n.PublishDate AND n.[ExpireDate] '
									IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand + N' AND n.HideDefaultLocale = 0 '
									IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand + N' AND n.Approved = 1 '
									IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID = @FilterByDNNUserID '
									ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand + N' AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
									SET @sqlcommand = @sqlcommand + N'			
							) AS PermissionsByRoles
						) AS PermissionsByUserAndRole
					)
				)
			END		
		END AS ''Count''
		FROM (
			SELECT	ncl.[CategoryID],ncl.[PortalID],ncl.[CategoryName],ncl.[Position],ncl.[ParentCategory],ncl.[Level],ncl.[CategoryURL],ncl.[CategoryImage],ncl.[CategoryText],ncl.Show,
				CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
				CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID
		) AS Result
		ORDER BY Position ASC, ParentCategory ASC'
	END
END

exec sp_executesql @statement = @sqlcommand
	,@paramList = @paramList
	,@PortalID = @PortalID
	,@UserID = @UserID
	,@MenuModuleID = @MenuModuleID
	,@DefaultTabID = @DefaultTabID
    ,@DefaultModuleID = @DefaultModuleID
	,@AdminOrSuperUser = @AdminOrSuperUser
	,@CountItems = @CountItems
	,@CountArticles = @CountArticles
	,@CountEvents = @CountEvents
	,@CountEventsLimitByDays = @CountEventsLimitByDays
	,@IsSocialInstance = @IsSocialInstance
	,@FilterByDNNUserID = @FilterByDNNUserID
	,@FilterByDNNGroupID = @FilterByDNNGroupID
	,@LocaleCode = @LocaleCode
	,@ShowAllAuthors = @ShowAllAuthors
	,@CategoryFilterType = @CategoryFilterType
	,@HideUnlocalizedItems = @HideUnlocalizedItems
	,@PermissionSettingsSource = @PermissionSettingsSource
	,@PermissionsModuleID = @PermissionsModuleID
	,@UserCanApprove = @UserCanApprove

