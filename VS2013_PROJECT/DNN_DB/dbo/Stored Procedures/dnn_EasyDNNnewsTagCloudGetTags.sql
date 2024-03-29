﻿CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsTagCloudGetTags]
	@PortalID INT,
	@UserID INT,
	@TagModuleID INT,
	@OrderBy NVARCHAR(20) = 'Size DESC',
	@AdminOrSuperUser BIT  = 0,
	@RowCount INT = 0,
	@LocaleCode NVARCHAR(20) = NULL,
	@IsSocialInstance BIT = 0,
	@FilterByDNNUserID INT = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID INT = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@ShowAllAuthors BIT = 1, -- filter postavka menija
	@CategoryFilterType TINYINT = 0, --0 All categories, 1 - SELECTion, 2 - AutoAdd
	@OnlyOneCategory INT = 0, -- used for gererating tags by only one category need to filter by one category
	@HideUnlocalizedItems BIT = 0,
	@PermissionSettingsSource TINYINT = 0, -- None, 1 - portal, 2 - module
	@PermissionsModuleID INT = 0, -- NewsModuleID
	@FilterByArticles BIT = 1,
	@FilterByEvents BIT = 0
AS
SET NOCOUNT ON;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();
DECLARE @UserCanApprove BIT;
SET @UserCanApprove = 0;

IF OBJECT_ID('tempdb..#UserInRoles') IS NOT NULL
	DROP TABLE #UserInRoles;

CREATE TABLE #UserInRoles (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO #UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate ) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY);
DECLARE @FiltredByCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);

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
			WHERE rpsc.PremissionSettingsID IN (SELECT PremissionSettingsID FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL);
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
				WHERE rpsc.PremissionSettingsID IN (SELECT PremissionSettingsID FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL);
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
				WHERE rpsc.PremissionSettingsID IN (SELECT PremissionSettingsID FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.PortalID = @PortalID AND rps.ModuleID = @PermissionsModuleID AND rps.RoleID IS NULL);
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
					INNER JOIN #UserInRoles AS uir ON rps.RoleID = uir.RoleID
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
			INNER JOIN #UserInRoles AS uir ON rps.RoleID = uir.RoleID
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
					INNER JOIN #UserInRoles AS uir ON rps.RoleID = uir.RoleID
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
				INNER JOIN #UserInRoles AS uir ON rps.RoleID = uir.RoleID
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
					INNER JOIN #UserInRoles AS uir ON rps.RoleID = uir.RoleID
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
				INNER JOIN #UserInRoles AS uir ON rps.RoleID = uir.RoleID
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
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @TagModuleID
		UNION 
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
			WHERE mgi.ModuleID = @TagModuleID
	END
END

IF @RowCount = 0
BEGIN
	SET @RowCount = 500;
END;

IF @LocaleCode IS NULL
BEGIN
	IF @IsSocialInstance = 0
	BEGIN
		IF @FilterByArticles = 1 AND @FilterByEvents = 0 -- only articles
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE IF @FilterByArticles = 0 AND @FilterByEvents = 1 -- only events
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE -- articles and events
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		IF @FilterByArticles = 1 AND @FilterByEvents = 0 -- only articles
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE IF @FilterByArticles = 0 AND @FilterByEvents = 1 -- only events
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE -- articles and events
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		IF @FilterByArticles = 1 AND @FilterByEvents = 0 -- only articles
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1  AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE IF @FilterByArticles = 0 AND @FilterByEvents = 1 -- only events
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1  AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE -- articles and events
		BEGIN
			SELECT TOP(@RowCount) * FROM (
				SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID
					AND ti.ArticleID IN (
					SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1  AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND na.UserID = @FilterByDNNUserID
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
					) AS FinalContentIDs
			)
			GROUP BY ti.TagID, nt.Name) AS FinalContent ORDER BY 
			CASE WHEN @OrderBy ='Name ASC' THEN Name END,
			CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
			CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
			CASE WHEN @OrderBy ='Size ASC' THEN Size END;	
		END
	END
END
ELSE
BEGIN
	IF @IsSocialInstance = 0
	BEGIN
		IF @FilterByArticles = 1 AND @FilterByEvents = 0 -- only articles
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
				SELECT TOP(@RowCount) * FROM (
					SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
					WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 0
							AND na.HasPermissions = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						) AS final
					)
					GROUP BY ti.TagID, nt.Name) AS Result ORDER BY 
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE IF @FilterByArticles = 0 AND @FilterByEvents = 1 -- only events
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
				SELECT TOP(@RowCount) * FROM (
					SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
					WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.EventArticle = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.EventArticle = 1
							AND na.HasPermissions = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						) AS final
					)
					GROUP BY ti.TagID, nt.Name) AS Result ORDER BY 
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END;	
		END
		ELSE -- articles and events
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
				SELECT TOP(@RowCount) * FROM (
					SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name] FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
					WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						UNION ALL
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						UNION
						SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
							LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
							))
							AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
							AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
						) AS final
					)
					GROUP BY ti.TagID, nt.Name) AS Result ORDER BY 
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END;	
		END
	END
	ELSE IF @FilterBySocialGroup = 1
	BEGIN
		IF @FilterByArticles = 1 AND @FilterByEvents = 0 -- only articles
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
			SELECT TOP(@RowCount) * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name]
				FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 0
						AND na.HasPermissions = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 0
						AND na.HasPermissions = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 0
						AND na.HasPermissions = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
						))
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE IF @FilterByArticles = 0 AND @FilterByEvents = 1 -- only events
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
			SELECT TOP(@RowCount) * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name]
				FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 1
						AND na.HasPermissions = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 1
						AND na.HasPermissions = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 1
						AND na.HasPermissions = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
						))
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END;		
		END
		ELSE -- articles and events
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
			SELECT TOP(@RowCount) * FROM (SELECT nt.TagID, COUNT(*) AS 'Size', nt.[Name]
				FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID 
						AND na.HasPermissions = 0
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
						))
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
				CASE WHEN @OrderBy ='Name ASC' THEN Name END,
				CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
				CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
				CASE WHEN @OrderBy ='Size ASC' THEN Size END;		
		END
	END
	ELSE IF @FilterByDNNUserID <> 0
	BEGIN
		IF @FilterByArticles = 1 AND @FilterByEvents = 0 -- only articles
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
			SELECT TOP(@RowCount) * FROM (SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name]
				FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 0
						AND na.HasPermissions = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 0
						AND na.HasPermissions = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 0
						AND na.HasPermissions = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					) AS final
				)
				GROUP BY ti.TagID, nt.Name) AS Result ORDER BY 
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
					CASE WHEN @OrderBy ='Name ASC' THEN Name END,
					CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
					CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
					CASE WHEN @OrderBy ='Size ASC' THEN Size END;
		END
		ELSE IF @FilterByArticles = 0 AND @FilterByEvents = 1 -- only events
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
			SELECT TOP(@RowCount) * FROM (SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name]
				FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 1
						AND na.HasPermissions = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 1
						AND na.HasPermissions = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.EventArticle = 1
						AND na.HasPermissions = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					) AS final
				)
				GROUP BY ti.TagID, nt.Name) AS Result ORDER BY 
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
					CASE WHEN @OrderBy ='Name ASC' THEN Name END,
					CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
					CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
					CASE WHEN @OrderBy ='Size ASC' THEN Size END;		
		END
		ELSE -- articles and events
		BEGIN
			WITH AllTags(TagID, Size, Name) AS (
			SELECT TOP(@RowCount) * FROM (SELECT ti.TagID, COUNT(ti.TagID) AS 'Size', nt.[Name]
				FROM dbo.[dnn_EasyDNNNewsTagsItems] AS ti
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS nt ON nt.TagID = ti.TagID
				WHERE nt.PortalID = @PortalID AND ti.ArticleID IN (SELECT DISTINCT [ArticleID] FROM(	
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserViewCategoriesWithFilter)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID 
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @FiltredByCategories)
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles)
						))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					) AS final
				)
				GROUP BY ti.TagID, nt.Name) AS Result ORDER BY 
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
			SELECT TagID, Size, Name FROM (SELECT TagID, Size, Name FROM LocalizedTags UNION SELECT TagID, Size, Name FROM NotLocalizedTags) AS FinalContent ORDER BY 
					CASE WHEN @OrderBy ='Name ASC' THEN Name END,
					CASE WHEN @OrderBy ='Size DESC' THEN Size END DESC,
					CASE WHEN @OrderBy ='Name DESC' THEN Name END DESC,
					CASE WHEN @OrderBy ='Size ASC' THEN Size END;	
		END
	END
END

IF OBJECT_ID('tempdb..#UserInRoles') IS NOT NULL
	DROP TABLE #UserInRoles;

