CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsCalendarArchive]
	@PortalID INT,
	@UserID INT,
	@CalendarModuleID INT,
	@AdminOrSuperUser BIT  = 0,
	@LocaleCode NVARCHAR(20) = NULL,
	@IsSocialInstance BIT = 0,
	@FilterByDNNUserID INT = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID INT = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@ShowAllAuthors BIT = 1, -- filter postavka menija
	@CategoryFilterType TINYINT = 0, --0 All categories, 1 - Selection, 2 - AutoAdd
	@PermissionSettingsSource TINYINT = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID INT = 0, -- NewsModuleID
	@HideUnlocalizedItems BIT = 0,
	@DateTimeOffset INT,
	@OnlyArticles BIT = 0,
	@OnlyEvents BIT = 0,
	@FilterCategoryID INT = NULL
AS
SET NOCOUNT ON;
DECLARE @sqlcommand NVARCHAR(max);
DECLARE @paramList NVARCHAR(1000);
SET @paramList = N'
	@PortalID INT,
	@UserID INT,
	@CalendarModuleID INT,
	@LocaleCode NVARCHAR(20),
	@FilterByDNNUserID INT,
	@FilterByDNNGroupID INT,
	@PermissionsModuleID INT,
	@DateTimeOffset INT,
	@FilterCategoryID INT'

SET @sqlcommand = N'
SET NOCOUNT ON;
SET DATEFIRST 1;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate ) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @FiltredByCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); '

IF @AdminOrSuperUser = 1 OR @PermissionSettingsSource = 0
BEGIN
	SET @sqlcommand = @sqlcommand + N'INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
END
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
		BEGIN
			SET @sqlcommand = @sqlcommand + N'INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
		END
		ELSE
		BEGIN
			SET @sqlcommand = @sqlcommand + N'
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL; '
		END
	END
	ELSE -- by module
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID AND PermissionsPMSource = 0)
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				SET @sqlcommand = @sqlcommand + N'INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
			END
			ELSE
			BEGIN
				SET @sqlcommand = @sqlcommand + N'
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL; '
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL AND rps.ShowAllCategories = 1)
			BEGIN
				SET @sqlcommand = @sqlcommand + N'INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
			END
			ELSE
			BEGIN
				SET @sqlcommand = @sqlcommand + N'
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL; '
			END
		END
	END
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		SET @sqlcommand = @sqlcommand + N'
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
		) OR EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
		)
			INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		ELSE
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL; '
	END
	ELSE -- by module
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @PermissionsModuleID AND PermissionsPMSource = 0)
		BEGIN
			SET @sqlcommand = @sqlcommand + N'
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.ShowAllCategories = 1
			) OR EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID AND ups.ShowAllCategories = 1
			)
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @PermissionsModuleID; '
		END
		ELSE
		BEGIN
			SET @sqlcommand = @sqlcommand + N'
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.ShowAllCategories = 1
			) OR EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL AND ups.ShowAllCategories = 1
			)
				INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
			ELSE
				INSERT INTO @UserViewCategories
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
				UNION
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL '
		END
	END
END

IF @FilterCategoryID IS NOT NULL -- filtrira se po jednoj kategoriji
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories WHERE CategoryID = @FilterCategoryID;
	INSERT INTO @FiltredByCategories SELECT @FilterCategoryID; '
END
ELSE IF @CategoryFilterType = 0 -- 0 All categories
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
	INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
END
ELSE IF @CategoryFilterType = 1 -- 1 - Selection
BEGIN
	SET @sqlcommand = @sqlcommand + N'	
	INSERT INTO @UserViewCategoriesWithFilter 
	SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
	INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @CalendarModuleID
	
	INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @CalendarModuleID; '
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
	INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
	INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID; '
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


IF @OnlyArticles = 1 AND @OnlyEvents = 0 -- only articles
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	SELECT MONTH(final.PublishDate) AS [Month], YEAR(final.PublishDate) AS [Year], COUNT(*) AS [Count] FROM (
	SELECT DISTINCT na.[ArticleID],DATEADD(hh, @DateTimeOffset, na.[PublishDate]) AS [PublishDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 0
		AND na.EventArticle = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '		
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) AS [PublishDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0
		BEGIN
			SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
			ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
		END
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) AS [PublishDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID '
	IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
SET @sqlcommand = @sqlcommand + N'
) AS final
GROUP BY MONTH(PublishDate), YEAR(PublishDate) ORDER BY [Year] DESC, [Month] DESC '
END
ELSE IF @OnlyEvents = 1 AND @OnlyArticles = 0 -- only events
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	SELECT MONTH(final.StartDate) AS [Month], YEAR(final.StartDate) AS [Year], COUNT(*) AS [Count] FROM (
	SELECT DISTINCT na.[ArticleID],DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [StartDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
	IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 0
		AND na.EventArticle = 1
		AND ne.Recurring = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
		AND ne.EndDate < @CurrentDate '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID],DATEADD(hh, @DateTimeOffset, nerd.[StartDateTime]) AS [StartDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = CASE WHEN nerd.EndDateTime < @CurrentDate THEN 1 ELSE 0 END '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 0
		AND na.EventArticle = 1
		AND ne.Recurring = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [StartDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
		AND ne.EndDate < @CurrentDate '
		IF @AdminOrSuperUser = 0
		BEGIN
			SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
			ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
		END
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
			
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [StartDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = CASE WHEN nerd.EndDateTime < @CurrentDate THEN 1 ELSE 0 END '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0
		BEGIN
			SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
			ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
		END
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
			
	SET @sqlcommand = @sqlcommand + N'
	UNION
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [StartDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
		AND ne.EndDate < @CurrentDate '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '

	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [StartDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = CASE WHEN nerd.EndDateTime < @CurrentDate THEN 1 ELSE 0 END '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '

	SET @sqlcommand = @sqlcommand + N'
) AS final
GROUP BY MONTH(StartDate), YEAR(StartDate) ORDER BY [Year] DESC, [Month] DESC '
END
ELSE -- articles and events
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	SELECT MONTH(final.CombinedDate) AS [Month], YEAR(final.CombinedDate) AS [Year], COUNT(*) AS [Count] FROM (
	SELECT DISTINCT na.[ArticleID],DATEADD(hh, @DateTimeOffset, na.[PublishDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 0
		AND na.EventArticle = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0
		BEGIN
			SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
			ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
		END
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, na.[PublishDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '

	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID],DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 0
		AND na.EventArticle = 1
		AND ne.Recurring = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
		AND ne.EndDate < @CurrentDate '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID],DATEADD(hh, @DateTimeOffset, nerd.[StartDateTime]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = CASE WHEN nerd.EndDateTime < @CurrentDate THEN 1 ELSE 0 END '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 0
		AND na.EventArticle = 1
		AND ne.Recurring = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
		AND ne.EndDate < @CurrentDate '
		IF @AdminOrSuperUser = 0
		BEGIN
			SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
			ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
		END
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = CASE WHEN nerd.EndDateTime < @CurrentDate THEN 1 ELSE 0 END '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0
		BEGIN
			SET @sqlcommand = @sqlcommand + N' AND aup.Show = 1 AND na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) '
			IF @UserID = -1 SET @sqlcommand = @sqlcommand + N' AND aup.UserID IS NULL '
			ELSE SET @sqlcommand = @sqlcommand + N' AND aup.UserID = @UserID '
		END
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
		
	SET @sqlcommand = @sqlcommand + N'
	UNION
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0 '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 0
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
		AND ne.EndDate < @CurrentDate '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '

	SET @sqlcommand = @sqlcommand + N'
	UNION ALL
	SELECT DISTINCT na.[ArticleID], DATEADD(hh, @DateTimeOffset, ne.[StartDate]) AS [CombinedDate] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 = CASE WHEN nerd.EndDateTime < @CurrentDate THEN 1 ELSE 0 END '
		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
	
	IF @FilterByDNNGroupID <> 0 
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	ELSE IF @FilterByDNNUserID <> 0
		SET @sqlcommand = @sqlcommand + N'
		INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
		INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
	
	SET @sqlcommand = @sqlcommand + N'
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND na.EventArticle = 1
		AND ne.Recurring = 1
		AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		IF @AdminOrSuperUser = 0 SET @sqlcommand = @sqlcommand + N' AND (na.Approved = 1 AND (na.Active = 1 OR na.UserID = @UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)) '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '

	SET @sqlcommand = @sqlcommand + N'
) AS final
GROUP BY MONTH(CombinedDate), YEAR(CombinedDate) ORDER BY [Year] DESC, [Month] DESC '
END

EXEC sp_executesql @statement = @sqlcommand
	,@paramList = @paramList
	,@PortalID = @PortalID
	,@UserID = @UserID
	,@CalendarModuleID = @CalendarModuleID
	,@LocaleCode = @LocaleCode
	,@FilterByDNNUserID = @FilterByDNNUserID
	,@FilterByDNNGroupID = @FilterByDNNGroupID
	,@PermissionsModuleID = @PermissionsModuleID
	,@DateTimeOffset = @DateTimeOffset
	,@FilterCategoryID = @FilterCategoryID


