CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsWidgetsGetTreeViewContent]
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
	@Perm_ViewAllCategores BIT = 1, -- ako je permsource 0 onda je ovo default 1
	@ShowAllAuthors BIT = 1, -- filter postavka menija
	@CategoryFilterType TINYINT = 0, --0 All categories, 1 - Selection, 2 - AutoAdd
	@HideUnlocalizedItems BIT = 0,
	@EditOnlyAsOwner BIT = 0, -- news settings
	@PermissionSettingsSource TINYINT = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID INT = 0 -- NewsModuleID
AS
SET NOCOUNT ON;
DECLARE @OrderBy NVARCHAR(20);
SET @OrderBy = 'PublishDate DESC';
SET DATEFIRST 1;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @StartDate DATETIME;
DECLARE @DateRangeType TINYINT;
SET @DateRangeType = 0;
IF @CountEventsLimitByDays IS NOT NULL
BEGIN
	SET @StartDate = DATEADD(DD, -@CountEventsLimitByDays, @CurrentDate);
	SET @DateRangeType = 2;
END

DECLARE @UserCanApprove BIT;
SET @UserCanApprove = 0;
DECLARE @Perm_EditAllCategores BIT;
SET @Perm_EditAllCategores = 0;
DECLARE @ModuleID INT;
SET @ModuleID = @MenuModuleID;
DECLARE @EditPermission TINYINT;
SET @EditPermission = 0;

DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
INSERT INTO @UserInRoles SELECT DISTINCT ur.[RoleID] FROM dbo.[dnn_UserRoles] AS ur INNER JOIN dbo.[dnn_Roles] AS r ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);
DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions and Module filter

DECLARE @SettingsSource BIT; SET @SettingsSource = 1;
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
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT ShowAllCategories FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			END
			ELSE
			BEGIN
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL;
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
		END
	END
END

IF @CategoryFilterType = 0 -- 0 All categories
BEGIN
	INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
END
ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
BEGIN
		INSERT INTO @UserViewCategoriesWithFilter 
		SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
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
	INSERT INTO @UserViewCategoriesWithFilter SELECT DISTINCT uvc.CategoryID FROM hierarchy AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;
END

DECLARE @FilterBySocialGroup BIT;
SET @FilterBySocialGroup = 0;
DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;

DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY);
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
	[CategoryID] INT NOT NULL PRIMARY KEY,
	[PortalID] INT,
	[CategoryName] NVARCHAR(200),
	[Position] INT,
	[ParentCategory] INT,
	[Level] INT,
	[CategoryURL] NVARCHAR(1500),
	[CategoryImage] NVARCHAR(1500),
	[CategoryText] ntext,[Show] BIT)

IF @LocaleCode IS NOT NULL
BEGIN
	WITH LocCategories([CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText]) AS 
	(
		SELECT Cat.[CategoryID],Cat.[PortalID],cl.[Title] AS CategoryName,Cat.[Position],Cat.[ParentCategory],Cat.[Level],Cat.[CategoryURL],Cat.[CategoryImage],cl.[CategoryText] FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategoriesWithFilter cwf ON cwf.CategoryID = Cat.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLocalization] AS cl ON cwf.CategoryID = cl.CategoryID WHERE Cat.PortalID = @PortalID AND cl.LocaleCode = @LocaleCode
	),
	NotLocCategories([CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText]) AS 
	(
		SELECT Cat.* FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategoriesWithFilter cwf ON cwf.CategoryID = Cat.CategoryID WHERE Cat.PortalID = @PortalID AND Cat.CategoryID NOT IN (SELECT CategoryID FROM LocCategories)
	)
	INSERT INTO @tempMenuCats SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],'1' AS Show FROM (SELECT * FROM LocCategories UNION ALL SELECT * FROM NotLocCategories) AS result
END
ELSE
BEGIN
	INSERT @tempMenuCats
	SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],'1' AS Show
	FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cat WHERE cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter) AND PortalID = @PortalID;
END

--INSERT @tempMenuCats
--SELECT [CategoryID],[PortalID],[CategoryName],[Position],[ParentCategory],[Level],[CategoryURL],[CategoryImage],[CategoryText],'0' AS Show
--FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID AND CategoryID NOT IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter);
  
SELECT TOP 1 @DefaultTabID = TabID FROM dbo.[dnn_TabModules] WHERE ModuleID = @DefaultModuleID;
DECLARE @TempCategoryIDAndCount table (CategoryID INT NOT NULL PRIMARY KEY, Position INT, ParentCategory INT, Count INT not null, NewsModuleID INT ,TabID INT);

IF @CountItems = 1 AND @CountArticles = 0 AND @CountEvents = 0
SET @CountItems = 0

IF @CountItems = 0
BEGIN 
	SELECT ncl.[CategoryID],ncl.[PortalID],ncl.[CategoryName],ncl.[Position],ncl.[ParentCategory],ncl.[Level],ncl.[CategoryURL],ncl.[CategoryImage],ncl.[CategoryText],ncl.Show,
	0 AS 'Count',
		CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
		CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
	FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
	ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
	LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID
	ORDER BY Position ASC, ParentCategory ASC;
END
ELSE
BEGIN

IF @LocaleCode IS NULL
BEGIN
	IF @IsSocialInstance = 0
	BEGIN
		IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			 
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							) AS UserAndRolePermissions
						))
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result

			SELECT n.ArticleID, NULL AS 'RecurringID', n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1	 	 
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1 				  
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
			) 
			ORDER BY ncl.Position, n.PublishDate;		
		END
		ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(					
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
							)
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ned.UpcomingOccurrences > 1
						THEN
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						ELSE
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
			WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID	
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					) AS NotRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
							END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					) AS Recurring
				) AS HasPermissionsTrue
			)
			ORDER BY ncl.Position, n.PublishDate;	
		END
		ELSE -- articles and events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0
				 				AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)	
								AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							) AS UserAndRolePermissions						
							)
							)+(
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN n.[EventArticle] = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ned.UpcomingOccurrences > 1
					THEN
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					ELSE
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END	
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL -- simple event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL -- recurring event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END 		
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0		 
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1		 
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
			) 
			ORDER BY ncl.Position, n.PublishDate;

		END
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			 
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							) AS UserAndRolePermissions
						))
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result

			SELECT n.ArticleID, NULL AS 'RecurringID', n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1 
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
			) 
			ORDER BY ncl.Position, n.PublishDate;		
		END
		ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(					
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
							)
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ned.UpcomingOccurrences > 1
						THEN
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						ELSE
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
			WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID	
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					) AS NotRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					) AS Recurring
				) AS HasPermissionsTrue
			)
			ORDER BY ncl.Position, n.PublishDate;	
		END
		ELSE -- articles and events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0
				 				AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)	
								AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							) AS UserAndRolePermissions						
							)
							)+(
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN n.[EventArticle] = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ned.UpcomingOccurrences > 1
					THEN
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					ELSE
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END	
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL -- simple event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL -- recurring event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END 		
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID				
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0		 
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1		 
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
			) 
			ORDER BY ncl.Position, n.PublishDate;

		END
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			 
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID 
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID 
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							) AS UserAndRolePermissions
						))
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result

			SELECT n.ArticleID, NULL AS 'RecurringID', n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey				
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND n.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
			) 
			ORDER BY ncl.Position, n.PublishDate;		
		END
		ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(					
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
										CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
							)
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ned.UpcomingOccurrences > 1
						THEN
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						ELSE
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
			WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey	
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND n.UserID = @FilterByDNNUserID 
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND n.UserID = @FilterByDNNUserID 
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID	
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					) AS NotRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					) AS Recurring
				) AS HasPermissionsTrue
			)
			ORDER BY ncl.Position, n.PublishDate;	
		END
		ELSE -- articles and events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
						WHERE n.PortalID = @PortalID
							AND n.HideDefaultLocale = 0
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.HideDefaultLocale = 0
								AND n.EventArticle = 0
								AND n.UserID = @FilterByDNNUserID 
				 				AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)	
								AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID 
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.HideDefaultLocale = 0
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							) AS UserAndRolePermissions						
							)
							)+(
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.HideDefaultLocale = 0
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))			
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN n.[EventArticle] = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',n.Title,n.TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ned.UpcomingOccurrences > 1
					THEN
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					ELSE
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END	
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1			
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL -- simple event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL -- recurring event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END 		
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0		 
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1		 
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
			) 
			ORDER BY ncl.Position, n.PublishDate;

		END
	END
END
ELSE
BEGIN
	IF @IsSocialInstance = 0
	BEGIN
		IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							) AS UserAndRolePermissions
						))
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result

			SELECT n.ArticleID, NULL AS 'RecurringID', CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))						
			) 
			ORDER BY ncl.Position, n.PublishDate;		
		END
		ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(					
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))											
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
							)
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ned.UpcomingOccurrences > 1
						THEN
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						ELSE
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
			WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0	
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))								
					) AS NotRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					) AS Recurring
				) AS HasPermissionsTrue
			)
			ORDER BY ncl.Position, n.PublishDate;	
		END
		ELSE -- articles and events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
				 				AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)	
								AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							) AS UserAndRolePermissions						
							)
							)+(
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN n.[EventArticle] = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ned.UpcomingOccurrences > 1
					THEN
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					ELSE
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END	
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL -- simple event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL -- recurring event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1		 
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
			) 
			ORDER BY ncl.Position, n.PublishDate;

		END
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							) AS UserAndRolePermissions
						))
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result

			SELECT n.ArticleID, NULL AS 'RecurringID', CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1 
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
			) 
			ORDER BY ncl.Position, n.PublishDate;		
		END
		ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(					
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))											
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
							)
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ned.UpcomingOccurrences > 1
						THEN
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						ELSE
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
			WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					) AS NotRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					) AS Recurring
				) AS HasPermissionsTrue
			)
			ORDER BY ncl.Position, n.PublishDate;	
		END
		ELSE -- articles and events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 0 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
				 				AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)	
								AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							) AS UserAndRolePermissions						
							)
							)+(
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))											
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN n.[EventArticle] = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ned.UpcomingOccurrences > 1
					THEN
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					ELSE
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END	
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL -- simple event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL -- recurring event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID				
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1		 
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
			) 
			ORDER BY ncl.Position, n.PublishDate;

		END
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		IF @CountArticles = 1 AND @CountEvents = 0 -- only articles
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID 
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID 
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							) AS UserAndRolePermissions
						))
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result

			SELECT n.ArticleID, NULL AS 'RecurringID', CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
			) 
			ORDER BY ncl.Position, n.PublishDate;		
		END
		ELSE IF @CountEvents = 1 AND @CountArticles = 0 -- only events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(					
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))											
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
							)
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ned.UpcomingOccurrences > 1
						THEN
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						ELSE
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
								THEN 1
								ELSE 0
							END
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
			WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey	
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND n.UserID = @FilterByDNNUserID 
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND n.UserID = @FilterByDNNUserID 
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
						AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID	
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					) AS NotRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
					) AS Recurring
				) AS HasPermissionsTrue
			)
			ORDER BY ncl.Position, n.PublishDate;	
		END
		ELSE -- articles and events
		BEGIN
			INSERT INTO @TempCategoryIDAndCount
			SELECT CategoryID, Position, ParentCategory,
			CASE Show
				WHEN 0 THEN 0
				WHEN 1 THEN	
					CASE @AdminOrSuperUser
					WHEN 1 THEN(
					SELECT ((
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 0
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						)+(
						SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
								CASE WHEN ne.UpcomingOccurrences > 1
								THEN
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								ELSE
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
										THEN 1
										ELSE 0
									END
								END
							ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
									THEN 1
									ELSE 0
								END
							END	
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
						WHERE n.PortalID = @PortalID
							AND n.EventArticle = 1
							AND ne.Recurring = 1
							AND n.UserID = @FilterByDNNUserID 
							AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
							AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
							AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
						))
					)
					WHEN 0 THEN(
						SELECT ((
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) AS cnt FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 0
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 0
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(n.[ArticleID]) FROM dbo.[dnn_EasyDNNNews] AS n
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = n.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
									CASE WHEN ne.UpcomingOccurrences > 1
									THEN
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									ELSE
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
											THEN 1
											ELSE 0
										END
									END
								ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
										THEN 1
										ELSE 0
									END
								END	
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 0
								AND n.EventArticle = 1
								AND ne.Recurring = 1
								AND n.UserID = @FilterByDNNUserID 
								AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT(aup.[ArticleID]) FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNews] AS n ON n.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
							WHERE n.PortalID = @PortalID
								AND n.HasPermissions = 1
								AND n.EventArticle = 0
								AND n.UserID = @FilterByDNNUserID 
				 				AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
								AND ((@UserCanApprove = 1) OR (n.Approved=1))
								AND (n.Active=1 OR n.UserID=@UserID)	
								AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
								AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							)+(
							SELECT COUNT([ArticleID]) FROM (
								SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID 
				 					AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)	
									AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
								UNION
								SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
								WHERE n.PortalID = @PortalID
									AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
									AND n.HasPermissions = 1
									AND n.EventArticle = 0
									AND n.UserID = @FilterByDNNUserID
									AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
									AND ((@UserCanApprove = 1) OR (n.Approved=1))
									AND (n.Active=1 OR n.UserID=@UserID)
									AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
									AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
							) AS UserAndRolePermissions						
							)
							)+(
							SELECT COUNT(ArticleID) FROM (			
								SELECT ArticleID FROM (
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
				 						AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT aup.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = aup.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = aup.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
				 						AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)	
										AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									
								) AS PermissionsByUser
								UNION
								SELECT ArticleID FROM (
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 0
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
									UNION ALL
									SELECT arp.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS n
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.ArticleID = arp.ArticleID AND c.CategoryID = Result.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = arp.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE WHEN @CountEventsLimitByDays IS NOT NULL THEN -- @StartDate min value
											CASE WHEN ne.UpcomingOccurrences > 1
											THEN
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											ELSE
												CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
												 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
													THEN 1
													ELSE 0
												END
											END
										ELSE -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
												THEN 1
												ELSE 0
											END
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
									WHERE n.PortalID = @PortalID
										AND arp.RoleID IN (SELECT RoleID FROM @UserInRoles)
										AND n.HasPermissions = 1
										AND n.EventArticle = 1
										AND ne.Recurring = 1
										AND n.UserID = @FilterByDNNUserID 
										AND n.PublishDate <= @CurrentDate AND n.[ExpireDate] >= @CurrentDate
										AND ((@UserCanApprove = 1) OR (n.Approved=1))
										AND (n.Active=1 OR n.UserID=@UserID)
										AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND n.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
										AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))											
								) AS PermissionsByRoles
							) AS PermissionsByUserAndRole
						)
					)
				END		
			END AS 'Count',NewsModuleID,TabID
			FROM (
			SELECT	ncl.[CategoryID],
					ncl.[Position],
					ncl.[ParentCategory],
					ncl.Show,
			CASE WHEN cl.[NewsModuleID] IS NULL THEN @DefaultModuleID ELSE cl.[NewsModuleID] END AS NewsModuleID,
			CASE WHEN tm.[TabID] IS NULL THEN @DefaultTabID ELSE tm.[TabID] END AS TabID
			FROM @tempMenuCats AS ncl LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsCategoryLink] AS cl
			ON ncl.CategoryID = cl.CategoryID AND cl.[SourceModuleID] = @MenuModuleID
			LEFT OUTER JOIN dbo.[dnn_TabModules] AS tm ON cl.NewsModuleID = tm.ModuleID) AS Result
			
			SELECT n.ArticleID, CASE WHEN n.[EventArticle] = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID',CASE WHEN loc.Title IS NULL THEN n.Title ELSE loc.Title END AS Title, CASE WHEN loc.clTitleLink IS NULL THEN n.TitleLink ELSE loc.clTitleLink END AS TitleLink,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,
				n.HasPermissions, n.Active, n.Approved, n.NumberOfComments,n.UserID, c.[CategoryID], ncl.[Position], ncl.Count, ncl.NewsModuleID,ncl.TabID, n.DetailType, n.DetailTypeData
			FROM dbo.[dnn_EasyDNNNews] as n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] c ON n.ArticleID = c.ArticleID 
				INNER JOIN @TempCategoryIDAndCount as ncl ON ncl.CategoryID = c.CategoryID
				INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = c.CategoryID AND cidl.Show = 1
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS loc ON loc.ArticleID = n.ArticleID AND loc.LocaleCode = @LocaleCode
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ned.UpcomingOccurrences > 1
					THEN
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(ned.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					ELSE
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
							THEN 1
							ELSE 0
						END
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END	
			WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1			
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL -- simple event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL -- recurring event
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END 	
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active = 1 OR na.UserID=@UserID)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0		
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID					
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION ALL
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1		 
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 0
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND (@CountEventsLimitByDays IS NULL OR ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
				UNION All
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @tempMenuCats AS cidl ON cidl.CategoryID = cat.CategoryID AND cidl.Show = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) as t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								 OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.RecurringID)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY RecurringID)
								THEN 1
								ELSE 0
							END
						ELSE 0
					END
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = n.ArticleID
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.EventArticle = 1
					AND ne.Recurring = 1
					AND n.UserID = @FilterByDNNUserID 
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))	 
					AND ((@HideUnlocalizedItems = 0) OR (@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))	
			) 
			ORDER BY ncl.Position, n.PublishDate;

		END
	END
END
END


