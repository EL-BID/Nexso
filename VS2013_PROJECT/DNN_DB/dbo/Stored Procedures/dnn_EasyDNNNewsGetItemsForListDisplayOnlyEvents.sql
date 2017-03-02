CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetItemsForListDisplayOnlyEvents]
	@ViewType tinyint = 0, -- 0 - View, 1 - Editor
	@PortalID int, -- current Portal
	@ModuleID int, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID int,
	@CurrentDate Datetime, -- = GetUTCDate,
	@OrderBy nvarchar(20) = 'PublishDate DESC',
	@ItemsFrom int = 1,
	@ItemsTo int = 5,
	@DateRange bit = 0,
	@FromDate DateTime = '2012-01-01 00:00:00', -- ovo ne treba za only events
	@ToDate DateTime = '2012-01-01 00:00:00', -- ovo ne treba za only events
	/* od tud ide filter */
	@Featured bit = 0,
	@ShowAllAuthors bit = 1, -- gleda se filtriranje autora po modulu ili portalu
	@FilterByAuthor int = 0,
	@FilterByGroupID int = 0,
	@FilterByTags bit = 0,
	/*@FilterByArticles bit = 0,*/ -- ovoga nema tu !!
	@FilterByDNNUserID int = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID int = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@EditOnlyAsOwner bit = 0, -- news settings
	@UserCanApprove bit = 0, -- news settings
	@LocaleCode nvarchar(20) = '',
	@IsSocialInstance bit = 0,	
	@FirstOrderBy nvarchar(20) = '',--'Featured DESC', -- featured articles on top	
	@Perm_ViewAllCategores bit = 0, -- permission settings View all categories
	@Perm_EditAllCategores bit = 0, -- permission settings Edit all categories
	@AdminOrSuperUser bit = 0,
	@CategoryFilterType tinyint = 1, -- 0 All categories, 1 - SELECTion, 2 - AutoAdd
	@PermissionSettingsSource bit = 0, -- 0 portal, 1 module
	@FillterSettingsSource bit = 0, -- 0 portal, 1 module
	@StartDate DateTime = '2012-01-01 00:00:00',
	@OuterModuleID int = 0,
	@HideUnlocalizedItems bit = 0
AS
SET NOCOUNT ON;
DECLARE @EditPermission tinyint;
SET @EditPermission = 0;
IF @OuterModuleID = 0 AND @FilterByTags = 1
BEGIN
	DECLARE @FilterTagsTable TABLE (TagID int NOT NULL PRIMARY KEY);
	IF @FillterSettingsSource = 1 -- portal settings
		BEGIN
			INSERT INTO @FilterTagsTable SELECT TagID FROM dbo.[dnn_EasyDNNNewsPortalFilterByTagID] WHERE FilterPortalID = @PortalID;
		END
	ELSE
		BEGIN
			INSERT INTO @FilterTagsTable SELECT TagID FROM dbo.[dnn_EasyDNNNewsFilterByTagID] WHERE FilterModuleID = @ModuleID;
		END
END
DECLARE @UserInRoles TABLE (RoleID int NOT NULL PRIMARY KEY);
INSERT INTO @UserInRoles SELECT DISTINCT ur.[RoleID] FROM dbo.[dnn_UserRoles] AS ur INNER JOIN dbo.[dnn_Roles] AS r ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > GETUTCDATE()) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < GETUTCDATE());

DECLARE @UserViewCategories TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
DECLARE @UserEditCategories TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can edit based on permissions
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions and Module filter
DECLARE @FiltredByCategories TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories that are filtred by module or portal

IF @UserID = -1
BEGIN	
	IF @Perm_ViewAllCategores = 1
	BEGIN
		INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE -- SELECTion by permission
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
		ELSE -- by module
		BEGIN
		INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID AND rps.RoleID IS NULL;
		END
	END
END
ELSE IF @AdminOrSuperUser = 1
BEGIN
	INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE -- registrirani korisnik
BEGIN
	IF @Perm_ViewAllCategores = 1
	BEGIN
		INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
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
		ELSE -- by module
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID GROUP BY rpsc.[CategoryID]
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID GROUP BY upsc.[CategoryID];
		END
	END
END

IF @OuterModuleID <> 0
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
		INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @OuterModuleID
			
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID;
	END
	ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
	BEGIN
		WITH hierarchy AS(
			SELECT [CategoryID], [ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID)) AND PortalID = @PortalID
			UNION ALL
			SELECT c.[CategoryID], c.[ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
		INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
		INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;
	END
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
			IF @FilterByAuthor <> 0
			BEGIN
				SET @FilterAuthorOrAuthors = 1;
				SELECT @FilterByAuthor = UserID FROM dbo.[dnn_EasyDNNNewsAuthorProfile] WHERE [AuthorProfileID] = @FilterByAuthor;
			END
		END
	END
ELSE
BEGIN
-- ovaj dio odnosi se na filtriranje autora
	IF @OuterModuleID <> 0 AND @ShowAllAuthors = 0 -- filter iu other modula
	BEGIN
		SET @FilterAuthorOrAuthors = 1;
		INSERT INTO @TempAuthorsIDList
			SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @OuterModuleID
			UNION 
			SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
				INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
				INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
			WHERE mgi.ModuleID = @OuterModuleID
	END
	ELSE
	BEGIN
		IF @FilterByAuthor = 0 AND @FilterByGroupID = 0 AND @ShowAllAuthors = 0 -- filter glavnog newsa
		BEGIN
			SET @FilterAuthorOrAuthors = 1;
			IF @FillterSettingsSource = 1 -- by portal
			BEGIN
				INSERT INTO @TempAuthorsIDList
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsPortalAuthorsItems] AS pai WHERE pai.PortalID = @PortalID
				UNION 
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
					INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
					INNER JOIN dbo.[dnn_EasyDNNNewsPortalGroupItems] AS pgi ON pgi.GroupID = agi.GroupID
					WHERE pgi.PortalID = @PortalID
			END
			ELSE -- by modul
			BEGIN
				INSERT INTO @TempAuthorsIDList
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @ModuleID
				UNION 
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
					INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
					INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
					WHERE mgi.ModuleID = @ModuleID
			END
		END
		ELSE IF @FilterByAuthor <> 0
		BEGIN
			SET @FilterAuthorOrAuthors = 1;
			INSERT INTO @TempAuthorsIDList SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] WHERE [AuthorProfileID] = @FilterByAuthor;
		END
		ELSE IF @FilterByGroupID <> 0
		BEGIN
			SET @FilterAuthorOrAuthors = 1;
			INSERT INTO @TempAuthorsIDList
			SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
				INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID	
				WHERE agi.GroupID = @FilterByGroupID
		END
	END
END
-- kategorije sa edit pravima
IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
BEGIN	
	INSERT INTO @UserEditCategories SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	SET @EditPermission = 1;
END
ELSE
BEGIN
	IF @UserID = -1
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
		ELSE -- by module
		BEGIN
		INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.RoleID IS NULL AND rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID;
		END
	END
	ELSE -- registrirani korisnik
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upatc.[CategoryID];
		END
		ELSE -- by module
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID GROUP BY upatc.[CategoryID];
		END	
	END
	IF EXISTS(SELECT * FROM @UserEditCategories) BEGIN SET @EditPermission = 2; END
END

DECLARE @LocalizedCategories TABLE (ID int NOT NULL PRIMARY KEY, Name nvarchar(200), Position int, CategoryURL nvarchar(1500));
IF @LocaleCode <> ''
BEGIN
	WITH LocCategories(ID, Name, Position, CategoryURL) AS (
		SELECT Cat.CategoryID AS ID, cl.Title AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = Cat.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLocalization] AS cl ON uvc.CategoryID = cl.CategoryID WHERE Cat.PortalID = @PortalID AND cl.LocaleCode = @LocaleCode
	),
	NotLocCategories(ID, Name, Position, CategoryURL) AS (
		SELECT Cat.CategoryID AS ID, Cat.CategoryName AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = Cat.CategoryID WHERE Cat.PortalID = @PortalID AND Cat.CategoryID NOT IN (SELECT ID FROM LocCategories)
	)
	INSERT INTO @LocalizedCategories SELECT ID, Name, Position, CategoryURL FROM (SELECT ID, Name, Position, CategoryURL FROM LocCategories UNION ALL SELECT ID, Name, Position, CategoryURL FROM NotLocCategories) AS ArticleCategories
END
ELSE
BEGIN
	INSERT INTO @LocalizedCategories SELECT Cat.CategoryID AS ID, Cat.CategoryName AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = cat.CategoryID WHERE Cat.PortalID = @PortalID
END

IF @IsSocialInstance = 0
BEGIN
	IF @LocaleCode <> ''
	BEGIN
		WITH FinalArticleIDsSet (ArticleID,StartDate) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID, StartDate FROM (SELECT n.*, ned.[StartDate], ROW_NUMBER() OVER (ORDER BY 
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN ned.[StartDate] END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN ned.[StartDate] END DESC) AS Kulike
			FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter  AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
					LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
				WHERE na.PortalID=@PortalID
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
					AND na.HasPermissions = 0
					AND (
						(@DateRange = 0 AND ne.StartDate >= @StartDate) OR -- kada nije zadan date range, odnosi se na main news
						(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate)) -- odnosi se na date range zadanao iz outer modula	   
						) 
					AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
					AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION ALL
				SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
					LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
				WHERE na.PortalID=@PortalID
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND na.HasPermissions = 1
					AND (
					  (@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					  (@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					  ) 
					AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
					AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
					AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
					LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
				WHERE na.PortalID=@PortalID
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND na.HasPermissions = 1
					AND (
					  (@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					  (@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					  ) 
					AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
					AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))	 
					AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					)
			) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC
		),
		FinalLocalizedArticleIDsSet (ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
			SELECT ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,clTitleLink AS TitleLink ,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription FROM dbo.[dnn_EasyDNNNewsContentLocalization] WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet) AND LocaleCode = @LocaleCode
		)
		SELECT *,
			CASE @EditPermission 
				WHEN 0 THEN 0
				WHEN 1 THEN 1
				WHEN 2 THEN
				CASE @EditOnlyAsOwner
					WHEN 0 THEN			
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END
						END  			
					WHEN 1 THEN
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END 
						END
				END
				WHEN 3 THEN
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
						THEN 1
						ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
							END
						END 
			END AS 'CanEdit',
			(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
			 CASE Result.Active
				WHEN 1 THEN 0
				WHEN 0 THEN 1
			 END AS 'Published',
			 CASE @UserCanApprove
				WHEN 0 THEN 0
				WHEN 1 THEN
					CASE Result.Approved
					 WHEN 1 THEN 0
					 WHEN 0 THEN
						 CASE Result.Active
							WHEN 1 THEN 1
							WHEN 0 THEN 0
						END
					END
			 END AS 'Approve'
			 FROM (
				SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription], ned.[StartDate],n.[CFGroupeID]
					FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
				UNION ALL
				SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription], ned.[StartDate],n.[CFGroupeID]
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON fla.ArticleID = ned.ArticleID) As Result		 
			ORDER BY
			 CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
			 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			 CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			 CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
	ELSE
	BEGIN
		SELECT *,
		CASE @EditPermission 
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN
			CASE @EditOnlyAsOwner
				WHEN 0 THEN			
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END
					END  			
				WHEN 1 THEN
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END 
					END
			END
			WHEN 3 THEN
				CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
					THEN 1
					ELSE
					CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
						THEN 1
						ELSE 0
						END
					END 
		END AS 'CanEdit',
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
		 CASE Result.Active
			WHEN 1 THEN 0
			WHEN 0 THEN 1
		 END AS 'Published',
		 CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Result.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Result.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS 'Approve'
		 FROM (SELECT
		 n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ned.[StartDate],n.[CFGroupeID], ROW_NUMBER() OVER (ORDER BY 
		 CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC, 
		 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
		 CASE WHEN @OrderBy ='StartDate ASC' THEN ned.[StartDate] END,
		 CASE WHEN @OrderBy ='StartDate DESC' THEN ned.[StartDate] END DESC) AS Kulike
		 FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN(
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter  AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			UNION ALL
			SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			UNION
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND((@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)) OR (@FilterAuthorOrAuthors = 0))	 
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			)
		 ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
			CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
END
ELSE IF @FilterBySocialGroup = 1
BEGIN
	IF @LocaleCode <> ''
	BEGIN
		WITH FinalArticleIDsSet (ArticleID,StartDate) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID, StartDate FROM (SELECT n.*, ned.[StartDate], ROW_NUMBER() OVER (ORDER BY 
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN ned.[StartDate] END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN ned.[StartDate] END DESC) AS Kulike
			FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN(
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter  AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
					LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
				WHERE na.PortalID=@PortalID
					AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
					AND na.HasPermissions = 0
					AND ne.StartDate >= @StartDate
					AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
					AND((@DateRange = 0 AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate) OR (@DateRange = 1 AND ((PublishDate >= @FromDate AND PublishDate <= @ToDate) AND (ExpireDate >= @CurrentDate))))
					AND((@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor) OR (@FilterAuthorOrAuthors = 0))
					AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION ALL
				SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
					LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
				WHERE na.PortalID=@PortalID
					AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND na.HasPermissions = 1
					AND (
						(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
						(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
						) 
					AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
					AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor) OR (@FilterAuthorOrAuthors = 0))
					AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
					LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
					LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
				WHERE na.PortalID=@PortalID
					AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
					AND na.HasPermissions = 1
					AND (
						(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
						(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
						) 
					AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
					AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
					AND ((@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor) OR (@FilterAuthorOrAuthors = 0))
					AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
					AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					)
			) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC
			),
			FinalLocalizedArticleIDsSet (ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
				SELECT ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,clTitleLink AS TitleLink ,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription FROM dbo.[dnn_EasyDNNNewsContentLocalization] WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet) AND LocaleCode = @LocaleCode
			)
			SELECT *,
				CASE @EditPermission 
					WHEN 0 THEN 0
					WHEN 1 THEN 1
					WHEN 2 THEN
					CASE @EditOnlyAsOwner
						WHEN 0 THEN			
							CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
								THEN 1
								ELSE
									CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
									THEN 1
									ELSE
										CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
											THEN 1
											ELSE 0
										END
									END
							END  			
						WHEN 1 THEN
							CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
								THEN 1
								ELSE
									CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
									THEN 1
									ELSE
										CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
											THEN 1
											ELSE 0
										END
									END 
							END
					END
					WHEN 3 THEN
						CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
							CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
								THEN 1
								ELSE 0
								END
							END 
				END AS 'CanEdit',
				(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
				 CASE Result.Active
					WHEN 1 THEN 0
					WHEN 0 THEN 1
				 END AS 'Published',
				 CASE @UserCanApprove
					WHEN 0 THEN 0
					WHEN 1 THEN
						CASE Result.Approved
						 WHEN 1 THEN 0
						 WHEN 0 THEN
							 CASE Result.Active
								WHEN 1 THEN 1
								WHEN 0 THEN 0
							END
						END
				 END AS 'Approve'
				 FROM (
					SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
						,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
						,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
						,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
						,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
						,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription], ned.[StartDate],n.[CFGroupeID]
						FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
					UNION ALL
					SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
						,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
						,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
						,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
						,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
						,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription], ned.[StartDate],n.[CFGroupeID]
					FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON fla.ArticleID = ned.ArticleID) As Result		 
				ORDER BY
					CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
					CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
					CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
					CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
					CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
					CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
					CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
					CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
					CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
					CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
					CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
					CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
					CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
					CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
					CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
					CASE WHEN @OrderBy ='Title ASC' THEN Title END,
					CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
					CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
					CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
	ELSE
	BEGIN
		SELECT *,
		CASE @EditPermission 
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN
			CASE @EditOnlyAsOwner
				WHEN 0 THEN			
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END
					END  			
				WHEN 1 THEN
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END 
					END
			END
			WHEN 3 THEN
				CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
					THEN 1
					ELSE
					CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
						THEN 1
						ELSE 0
						END
					END 
		END AS 'CanEdit',
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
		 CASE Result.Active
			WHEN 1 THEN 0
			WHEN 0 THEN 1
		 END AS 'Published',
		 CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Result.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Result.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS 'Approve'
		FROM (SELECT
		n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ned.[StartDate],n.[CFGroupeID], ROW_NUMBER() OVER (ORDER BY 
		CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
		CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
		CASE WHEN @OrderBy ='StartDate ASC' THEN ned.[StartDate] END,
		CASE WHEN @OrderBy ='StartDate DESC' THEN ned.[StartDate] END DESC) AS Kulike
		FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN(
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter  AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
				) 
				AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor) OR (@FilterAuthorOrAuthors = 0))
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			UNION ALL
			SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor) OR (@FilterAuthorOrAuthors = 0))
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			UNION
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND ((@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor) OR (@FilterAuthorOrAuthors = 0))
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			)
		 ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
		 CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
		 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
		 CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
		 CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
END
ELSE IF @FilterByDNNUserID <> 0
BEGIN
	IF @LocaleCode <> ''
	BEGIN
		WITH FinalArticleIDsSet (ArticleID,StartDate) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID, StartDate FROM (SELECT n.*, ned.[StartDate], ROW_NUMBER() OVER (ORDER BY 
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN ned.[StartDate] END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN ned.[StartDate] END DESC) AS Kulike
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN(
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter  AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
						LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
					WHERE na.PortalID=@PortalID
						AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
						AND na.HasPermissions = 0
						AND (
							(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
							(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
							) 
						AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
						AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
						AND na.UserID = @FilterByDNNUserID
						AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION ALL
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
						LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
					WHERE na.PortalID=@PortalID
						AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1  AND ((@UserCanApprove = 1) OR (na.Approved=1))AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND na.HasPermissions = 1
						AND (
							(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
							(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
							) 
						AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
						AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
						AND na.UserID = @FilterByDNNUserID
						AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
						LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID
						LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 	
					WHERE na.PortalID=@PortalID
						AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
						AND na.HasPermissions = 1
						AND (
							(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
							(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
							) 
						AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
						AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
						AND na.UserID = @FilterByDNNUserID
						AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
						AND ((@HideUnlocalizedItems = 1 AND ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode) OR (@HideUnlocalizedItems = 0))
				)
			 ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC
		),
		FinalLocalizedArticleIDsSet (ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
			SELECT ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,clTitleLink AS TitleLink ,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription FROM dbo.[dnn_EasyDNNNewsContentLocalization] WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet) AND LocaleCode = @LocaleCode
		)
		SELECT *,
			CASE @EditPermission 
				WHEN 0 THEN 0
				WHEN 1 THEN 1
				WHEN 2 THEN
				CASE @EditOnlyAsOwner
					WHEN 0 THEN			
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END
						END  			
					WHEN 1 THEN
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END 
						END
				END
				WHEN 3 THEN
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
						THEN 1
						ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
							END
						END 
			END AS 'CanEdit',
			(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
			 CASE Result.Active
				WHEN 1 THEN 0
				WHEN 0 THEN 1
			 END AS 'Published',
			 CASE @UserCanApprove
				WHEN 0 THEN 0
				WHEN 1 THEN
					CASE Result.Approved
					 WHEN 1 THEN 0
					 WHEN 0 THEN
						 CASE Result.Active
							WHEN 1 THEN 1
							WHEN 0 THEN 0
						END
					END
			 END AS 'Approve'
			 FROM (
				SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription], ned.[StartDate],n.[CFGroupeID]
					FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
				UNION ALL
				SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription], ned.[StartDate],n.[CFGroupeID]
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON fla.ArticleID = ned.ArticleID) As Result		 
			ORDER BY
				CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
	ELSE
	BEGIN
		SELECT *,
		CASE @EditPermission 
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN
			CASE @EditOnlyAsOwner
				WHEN 0 THEN			
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END
					END  			
				WHEN 1 THEN
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END 
					END
			END
			WHEN 3 THEN
				CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
					THEN 1
					ELSE
					CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
						THEN 1
						ELSE 0
						END
					END 
		END AS 'CanEdit',
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
		 CASE Result.Active
			WHEN 1 THEN 0
			WHEN 0 THEN 1
		 END AS 'Published',
		 CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Result.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Result.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS 'Approve'
		FROM (SELECT
		n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ned.[StartDate],n.[CFGroupeID], ROW_NUMBER() OVER (ORDER BY 
		CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
		CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
		CASE WHEN @OrderBy ='StartDate ASC' THEN ned.[StartDate] END,
		CASE WHEN @OrderBy ='StartDate DESC' THEN ned.[StartDate] END DESC) AS Kulike
		FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID WHERE n.ArticleID IN(
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @UserViewCategoriesWithFilter  AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR ((@UserCanApprove = 1 OR na.Approved=1) AND (na.Active=1 OR na.UserID=@UserID)))
				AND na.HasPermissions = 0
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			UNION ALL
			SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			UNION
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
				INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID
				LEFT OUTER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID 	
			WHERE na.PortalID=@PortalID
				AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				))
				AND na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND (
					(@DateRange = 0 AND ne.StartDate >= @StartDate) OR
					(@DateRange = 1 AND (ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate))  
					) 
				AND((@Featured = 1 AND na.Featured = 1) OR (@Featured = 0))
				AND na.PublishDate <= @CurrentDate AND na.ExpireDate >= @CurrentDate
				AND na.UserID = @FilterByDNNUserID
				AND ((@FilterByTags = 1 AND fbt.TagID IS NOT NULL) OR (@FilterByTags = 0))
			)
		 ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
			 CASE WHEN @FirstOrderBy ='Featured DESC' THEN Featured END DESC,
			 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			 CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			 CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
END

