CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsCalendarGetUpcomingEvents]
	@PortalID INT,
	@UserID INT,
	@CalendarModuleID INT,
	@RowCount INT,
	@AdminOrSuperUser BIT  = 0,
	@LocaleCode NVARCHAR(20) = NULL,
	@IsSocialInstance BIT = 0,
	@FilterByDNNUserID INT = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID INT = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@ShowAllAuthors BIT = 1, -- filter postavka menija
	@CategoryFilterType TINYINT = 0, --0 All categories, 1 - SELECTion, 2 - AutoAdd
	@PermissionSettingsSource TINYINT = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID INT = 0, -- NewsModuleID
	@HideUnlocalizedItems BIT = 0,
	@FilterCategoryID INT = NULL
AS
SET NOCOUNT ON;
DECLARE @sqlcommand NVARCHAR(max);
DECLARE @paramList NVARCHAR(1000);
SET @paramList = N'
	@PortalID INT,
	@UserID INT,
	@CalendarModuleID INT,
	@RowCount INT,
	@LocaleCode NVARCHAR(20),
	@FilterByDNNUserID INT,
	@FilterByDNNGroupID INT,
	@PermissionsModuleID INT,
	@FilterCategoryID INT = NULL'

SET @sqlcommand = N'
SET NOCOUNT ON;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @EventsLocaleCode NVARCHAR(20);

IF @LocaleCode IS NULL
SET @EventsLocaleCode = ''Default'';
ELSE
SET @EventsLocaleCode = (SELECT @LocaleCode)

IF OBJECT_ID(''tempdb..#UserInRoles'') IS NOT NULL
	DROP TABLE #UserInRoles;
	
CREATE TABLE #UserInRoles (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO #UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate ) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

IF OBJECT_ID(''tempdb..#UserViewCategories'') IS NOT NULL
	DROP TABLE #UserViewCategories;
CREATE TABLE #UserViewCategories (CategoryID INT NOT NULL PRIMARY KEY);

IF OBJECT_ID(''tempdb..#UserViewCategoriesWithFilter'') IS NOT NULL
	DROP TABLE #UserViewCategoriesWithFilter;	
CREATE TABLE #UserViewCategoriesWithFilter (CategoryID INT NOT NULL PRIMARY KEY);

IF OBJECT_ID(''tempdb..#FiltredByCategories'') IS NOT NULL
	DROP TABLE #FiltredByCategories;	
CREATE TABLE #FiltredByCategories (CategoryID INT NOT NULL PRIMARY KEY); '

IF @AdminOrSuperUser = 1 OR @PermissionSettingsSource = 0
	SET @sqlcommand = @sqlcommand + N'INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		SET @sqlcommand = @sqlcommand  + N'
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		ELSE
			INSERT INTO #UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			WHERE rpsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] IS NULL AND [RoleID] IS NULL) '
	END
	ELSE -- by module
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID AND PermissionsPMSource = 0)
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
				INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
			INSERT INTO #UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			WHERE rpsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] = @PermissionsModuleID AND [RoleID] IS NULL) '
		END
		ELSE
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
				INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
			INSERT INTO #UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			WHERE rpsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] IS NULL AND [RoleID] IS NULL) '
		END
	END
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		SET @sqlcommand = @sqlcommand  + N'
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
				WHERE rps.RoleID IN (SELECT RoleID FROM #UserInRoles) AND rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
		) OR EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
		)
			INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		ELSE
			INSERT INTO #UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			WHERE rpsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] IS NULL AND RoleID IN (SELECT RoleID FROM #UserInRoles))
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
			WHERE upsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] WHERE [PortalID] = @PortalID AND [UserID] = @UserID AND [ModuleID] IS NULL) '
	END
	ELSE -- by module
	BEGIN	
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID AND PermissionsPMSource = 0)
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.RoleID IN (SELECT RoleID FROM #UserInRoles) AND rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.ShowAllCategories = 1
			) OR EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID AND ups.ShowAllCategories = 1
			)
				INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
				INSERT INTO #UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				WHERE rpsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] = @PermissionsModuleID AND RoleID IN (SELECT RoleID FROM #UserInRoles))
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				WHERE upsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] WHERE [PortalID] = @PortalID AND [UserID] = @UserID AND [ModuleID] = @PermissionsModuleID) '
		END
		ELSE
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.RoleID IN (SELECT RoleID FROM #UserInRoles) AND rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
			) OR EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
			)
				INSERT INTO #UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
				INSERT INTO #UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				WHERE rpsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] IS NULL AND RoleID IN (SELECT RoleID FROM #UserInRoles))
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				WHERE upsc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] WHERE [PortalID] = @PortalID AND [UserID] = @UserID AND [ModuleID] IS NULL) '
		END
	END
END


IF @FilterCategoryID IS NOT NULL -- filtrira se po jednoj kategoriji
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	INSERT INTO #UserViewCategoriesWithFilter SELECT [CategoryID] FROM #UserViewCategories WHERE CategoryID = @FilterCategoryID;
	INSERT INTO #FiltredByCategories SELECT @FilterCategoryID; '
END
ELSE IF @CategoryFilterType = 0 -- 0 All categories
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	INSERT INTO #UserViewCategoriesWithFilter SELECT [CategoryID] FROM #UserViewCategories;
	INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
END
ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	INSERT INTO #UserViewCategoriesWithFilter 
	SELECT cl.[CategoryID] FROM #UserViewCategories AS cl
	INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @CalendarModuleID
	
	INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID; '
END
ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	WITH hierarchy AS(
		SELECT [CategoryID], [ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
		WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID)) AND PortalID = @PortalID
		UNION ALL
		SELECT c.[CategoryID], c.[ParentCategory]
		FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
		)
		INSERT INTO #FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
		INSERT INTO #UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM #FiltredByCategories AS nfc INNER JOIN #UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID; '
END

DECLARE @FilterBySocialGroup BIT;
SET @FilterBySocialGroup = 0;
DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;

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
		SET @sqlcommand = @sqlcommand + N'
		DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY);
		INSERT INTO @TempAuthorsIDList
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @CalendarModuleID
		UNION 
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
		INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
		INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
		WHERE mgi.ModuleID = @CalendarModuleID '
	END
END
SET @sqlcommand = @sqlcommand + N'
IF @RowCount = 0 OR @RowCount > 100
BEGIN
	SET @RowCount = 100;
END '

SET @sqlcommand = @sqlcommand  + N'
;WITH MainFilters AS(
	SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #FiltredByCategories) '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand  + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
		IF @FilterByDNNGroupID <> 0 
			SET @sqlcommand = @sqlcommand  + N'
			INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
			INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
		ELSE IF @FilterByDNNUserID <> 0
			SET @sqlcommand = @sqlcommand  + N'
			INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
			INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	SET @sqlcommand = @sqlcommand  + N'
	WHERE na.PortalID=@PortalID
		AND na.EventArticle = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand  + N' AND na.HideDefaultLocale = 0 '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand  + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @ShowAllAuthors = 0 SET @sqlcommand = @sqlcommand  + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
	SET @sqlcommand = @sqlcommand  + N'
)'

IF @LocaleCode IS NOT NULL
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	, FinalArticleIDsSet (ArticleID) AS (
		SELECT ArticleID FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN(
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategoriesWithFilter)	
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0 '
				IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
			
			SET @sqlcommand = @sqlcommand + N'
			WHERE na.HasPermissions = 0
				AND ne.Recurring = 0
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
				AND ((ne.StartDate >= @CurrentDate) OR (ne.StartDate <= @CurrentDate AND ne.EndDate >= @CurrentDate)) '
				IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			SET @sqlcommand = @sqlcommand + N'
			UNION ALL
			SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategoriesWithFilter)	
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 
					((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
							(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime))) '
				IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
			
			SET @sqlcommand = @sqlcommand + N'
			WHERE na.HasPermissions = 0
				AND ne.Recurring = 1
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters) '
				IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			SET @sqlcommand = @sqlcommand + N'
			UNION ALL
			SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0 '
				IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
			SET @sqlcommand = @sqlcommand + N'
			WHERE na.HasPermissions = 1
				AND ne.Recurring = 0
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
				AND ((ne.StartDate >= @CurrentDate) OR (ne.StartDate <= @CurrentDate AND ne.EndDate >= @CurrentDate)) '
				IF @AdminOrSuperUser = 0
				BEGIN
					SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
					IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
					ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
				END
			SET @sqlcommand = @sqlcommand + N'
			UNION ALL
			SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #FiltredByCategories)
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = 
					CASE WHEN ((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
							(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime)))
						THEN 1
						ELSE 0
					END '
				IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
			SET @sqlcommand = @sqlcommand + N'
			WHERE na.HasPermissions = 1
				AND ne.Recurring = 1
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters) '
				IF @AdminOrSuperUser = 0
				BEGIN
					SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
					IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
					ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
				END
			SET @sqlcommand = @sqlcommand + N'
			UNION
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #FiltredByCategories)
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 0 '
				IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
			SET @sqlcommand = @sqlcommand + N'
			WHERE na.HasPermissions = 1
				AND ne.Recurring = 0
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
				AND ((ne.StartDate >= @CurrentDate) OR (ne.StartDate <= @CurrentDate AND ne.EndDate >= @CurrentDate)) '
				IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)) '
			SET @sqlcommand = @sqlcommand + N'
			UNION ALL
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #FiltredByCategories)
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne on na.ArticleID = ne.ArticleID AND ne.Recurring = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = 
					CASE WHEN ((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
							(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime)))
						THEN 1
						ELSE 0
					END '
				IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
						
			SET @sqlcommand = @sqlcommand + N'
			WHERE na.HasPermissions = 1
				AND ne.Recurring = 1
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters) '
				IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)) '
		SET @sqlcommand = @sqlcommand + N'
		)
	),
	FinalLocalizedArticleIDsSet (ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords) AS (
		SELECT ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,clTitleLink AS TitleLink ,MetaDecription,MetaKeywords FROM dbo.[dnn_EasyDNNNewsContentLocalization] WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet) AND LocaleCode = @LocaleCode
	)
	SELECT TOP (@RowCount)
		ResultFinal.ArticleID, ResultFinal.UserID, ResultFinal.PublishDate, ResultFinal.Title, ResultFinal.TitleLink,ResultFinal.DetailType,ResultFinal.DetailTypeData, ResultFinal.ArticleImage,
		ResultFinal.Summary,
		CASE WHEN ResultFinal.RecurringID IS NULL
		THEN
			NULL
		ELSE
			(SELECT [Summary] FROM dbo.[dnn_EasyDNNNewsEventsRecurringContent] WHERE ArticleID = ResultFinal.ArticleID AND RecurringID = ResultFinal.RecurringID AND LocaleCode = @EventsLocaleCode)
		END AS CustomSummary,
		ResultFinal.Article, ResultFinal.AuthorAliasName,ResultFinal.[DetailTarget],
		ResultFinal.StartDate,
		ResultFinal.EndDate,
		ResultFinal.RecurringID,
		ResultFinal.WhloeDay,
		ResultFinal.ShowEndDate,
		ResultFinal.GoogleMapData,
		ResultFinal.CssCategoryClasses
		
	FROM (
	SELECT Result.*,
		CASE WHEN ne.Recurring = 1 THEN nerd.StartDateTime ELSE ne.StartDate END AS StartDate,
		CASE WHEN ne.Recurring = 1 THEN nerd.EndDateTime ELSE ne.EndDate END AS EndDate,
		CASE WHEN ne.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS RecurringID,
		ne.WhloeDay,ne.ShowEndDate,
	(SELECT PointData FROM dbo.[dnn_EasyDNNnewsGoogleMapsData] AS md INNER JOIN dbo.[dnn_EasyDNNNewsArticleGoogleMapConnection]  AS mc ON md.GoogleMapID = mc.GoogleMapID WHERE mc.ArticleID =  Result.ArticleID)
	AS GoogleMapData,
	(SELECT c.CategoryID, c.CategoryName FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN #UserViewCategories AS uvc ON c.CategoryID = uvc.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cl ON uvc.CategoryID = cl.CategoryID WHERE cl.ArticleID = Result.ArticleID ORDER BY c.Position FOR XML AUTO, ROOT(''root''))
	AS CssCategoryClasses,ne.Recurring
	FROM (
		SELECT na.ArticleID,na.UserID,na.PublishDate,na.Title,na.TitleLink,na.DetailType,na.DetailTypeData,na.ArticleImage,na.Summary,na.Article,na.AuthorAliasName,na.[DetailTarget]
			FROM dbo.[dnn_EasyDNNNews] AS na WHERE na.ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
		UNION ALL
		SELECT na.ArticleID,na.UserID,na.PublishDate,fla.Title,fla.TitleLink,na.DetailType,fla.DetailTypeData,na.ArticleImage,fla.Summary,fla.Article,na.AuthorAliasName,na.[DetailTarget]
			FROM dbo.[dnn_EasyDNNNews] AS na INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = na.ArticleID
	) As Result
	INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON Result.ArticleID = ne.ArticleID
	LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON (ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
		CASE WHEN ((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
				(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime)))
			THEN 1
			ELSE 0
		END 
	)) AS ResultFinal
	 ORDER BY StartDate; '
END
ELSE
BEGIN
SET @sqlcommand = @sqlcommand + N'
SELECT TOP (@RowCount)
Result.ArticleID, Result.UserID, Result.PublishDate, Result.Title, Result.TitleLink,Result.DetailType,Result.DetailTypeData, Result.ArticleImage,
Result.Summary,
CASE WHEN Result.RecurringID IS NULL
THEN
	NULL
ELSE
	(SELECT [Summary] FROM dbo.[dnn_EasyDNNNewsEventsRecurringContent] WHERE ArticleID = Result.ArticleID AND RecurringID = Result.RecurringID AND LocaleCode = @EventsLocaleCode)
END AS CustomSummary,
Result.Article, Result.AuthorAliasName,Result.[DetailTarget],
Result.StartDate,
Result.EndDate,
Result.RecurringID,
Result.WhloeDay,
Result.ShowEndDate,

(SELECT PointData FROM dbo.[dnn_EasyDNNnewsGoogleMapsData] AS md INNER JOIN  dbo.[dnn_EasyDNNNewsArticleGoogleMapConnection]  AS mc ON md.GoogleMapID = mc.GoogleMapID WHERE mc.ArticleID =  Result.ArticleID)
AS GoogleMapData,
(SELECT c.CategoryID, c.CategoryName FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN #UserViewCategories AS uvc ON c.CategoryID = uvc.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cl ON uvc.CategoryID = cl.CategoryID WHERE cl.ArticleID = Result.ArticleID ORDER BY c.Position FOR XML AUTO, ROOT(''root''))
AS CssCategoryClasses
FROM (
	SELECT na.ArticleID, na.UserID, na.PublishDate, na.Title, na.TitleLink,na.DetailType,na.DetailTypeData, na.ArticleImage, na.Summary, na.Article, na.AuthorAliasName,na.[DetailTarget],
	CASE WHEN ne.Recurring = 1 THEN nerd.StartDateTime ELSE ne.StartDate END AS StartDate,
	CASE WHEN ne.Recurring = 1 THEN nerd.EndDateTime ELSE ne.EndDate END AS EndDate,
	CASE WHEN ne.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS RecurringID,
	  ne.WhloeDay,ne.ShowEndDate FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON na.ArticleID = ne.ArticleID
		LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND
			((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
					(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime)))
	WHERE na.ArticleID IN (
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategoriesWithFilter)
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
		WHERE na.HasPermissions = 0
			AND ne.Recurring = 0
			AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
			AND ((ne.StartDate >= @CurrentDate) OR (ne.StartDate <= @CurrentDate AND ne.EndDate >= @CurrentDate)) '
			IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		SET @sqlcommand = @sqlcommand + N'
		UNION ALL
		SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategoriesWithFilter)
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND
				((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
							(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime))) '		
		SET @sqlcommand = @sqlcommand + N'
		WHERE na.HasPermissions = 0
			AND ne.Recurring = 1
			AND na.ArticleID IN (SELECT ArticleID FROM MainFilters) '
			IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		SET @sqlcommand = @sqlcommand + N'
		GROUP BY na.ArticleID
		UNION ALL
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
		WHERE na.HasPermissions = 1
			AND ne.Recurring = 0
			AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
			AND ((ne.StartDate >= @CurrentDate) OR (ne.StartDate <= @CurrentDate AND ne.EndDate >= @CurrentDate)) '
			IF @AdminOrSuperUser = 0
			BEGIN
				SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
				IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
				ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
			END
		SET @sqlcommand = @sqlcommand + N'
		UNION ALL
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND
				((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
							(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime)))
		WHERE na.HasPermissions = 1
			AND ne.Recurring = 1
			AND na.ArticleID IN (SELECT ArticleID FROM MainFilters) '
			IF @AdminOrSuperUser = 0
			BEGIN
				SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
				IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
				ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
			END			
		SET @sqlcommand = @sqlcommand + N'
		UNION
		SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #FiltredByCategories)
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
	
		SET @sqlcommand = @sqlcommand + N'
		WHERE na.HasPermissions = 1
			AND ne.Recurring = 0
			AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
			AND ((ne.StartDate >= @CurrentDate) OR (ne.StartDate <= @CurrentDate AND ne.EndDate >= @CurrentDate)) '
			IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)) '
		SET @sqlcommand = @sqlcommand + N'
		GROUP BY na.ArticleID
		UNION ALL
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND
				((ne.StartDate >= @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID ORDER BY erd.StartDateTime)) OR
							(ne.StartDate < @CurrentDate AND nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime >= @CurrentDate ORDER BY erd.StartDateTime))) '		
		SET @sqlcommand = @sqlcommand + N'
		WHERE na.HasPermissions = 1
			AND ne.Recurring = 1
			AND na.ArticleID IN (SELECT ArticleID FROM MainFilters) '
			IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)) '
		SET @sqlcommand = @sqlcommand + N'
	)
) AS Result ORDER BY StartDate; '
END

SET @sqlcommand = @sqlcommand  + N'

IF OBJECT_ID(''tempdb..#UserInRoles'') IS NOT NULL
	DROP TABLE #UserInRoles;
IF OBJECT_ID(''tempdb..#UserViewCategories'') IS NOT NULL
	DROP TABLE #UserViewCategories;
IF OBJECT_ID(''tempdb..#UserViewCategoriesWithFilter'') IS NOT NULL
	DROP TABLE #UserViewCategoriesWithFilter;
IF OBJECT_ID(''tempdb..#FiltredByCategories'') IS NOT NULL
	DROP TABLE #FiltredByCategories; '

EXEC sp_executesql @statement = @sqlcommand
	,@paramList = @paramList
	,@PortalID = @PortalID
	,@UserID  = @UserID
	,@CalendarModuleID = @CalendarModuleID
	,@RowCount = @RowCount
	,@LocaleCode = @LocaleCode
	,@FilterByDNNUserID = @FilterByDNNUserID
	,@FilterByDNNGroupID = @FilterByDNNGroupID
	,@PermissionsModuleID = @PermissionsModuleID
	,@FilterCategoryID = @FilterCategoryID

