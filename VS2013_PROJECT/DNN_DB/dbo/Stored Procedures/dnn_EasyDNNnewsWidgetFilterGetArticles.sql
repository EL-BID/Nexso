CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsWidgetFilterGetArticles]
	@PortalID INT, -- current Portal
	@ModuleID INT, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID INT,
	@OrderBy NVARCHAR(20) = 'PublishDate DESC',
	@ItemsFrom INT = 1,
	@ItemsTo INT = 5,
	/* od tud ide filter */
	@Featured BIT = 0,
	@ShowAllAuthors BIT = 1, -- gleda se filtriranje autora po modulu ili portalu
	@EditOnlyAsOwner BIT = 0, -- news settings
	@UserCanApprove BIT = 0, -- news settings
	@LocaleCode NVARCHAR(20) = NULL,
	@FirstOrderBy NVARCHAR(20) = '',--'Featured DESC', -- featured articles on top	
	@Perm_ViewAllCategores BIT = 0, -- permission settings View all categories
	@Perm_EditAllCategores BIT = 0, -- permission settings Edit all categories
	@AdminOrSuperUser BIT = 0,
	@CategoryFilterType TINYINT = 1, -- 0 All categories, 1 - SELECTion, 2 - AutoAdd
	@PermissionSettingsSource BIT = 1, -- 1 portal, 0 module
	@FillterSettingsSource BIT = 1, -- 1 portal, 0 module
	@HideUnlocalizedItems BIT = 0,
	@NewsFilterCategories NVARCHAR(1000) = '',
	@NewsFilterAuthors NVARCHAR(1000) = '',
	@NewsFilterGroups NVARCHAR(1000) = '',
	@CategoriesAndOperator BIT = 1
AS
SET NOCOUNT ON;
SET DATEFIRST 1;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @EditPermission TINYINT;
SET @EditPermission = 0;

DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
INSERT INTO @UserViewCategories SELECT CategoryID FROM dbo.[dnn_EDS_ViewPermissions] (@PortalID,@ModuleID,@UserID,@AdminOrSuperUser,@Perm_ViewAllCategores,@PermissionSettingsSource,@CurrentDate)
DECLARE @UserEditCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can edit based on permissions
INSERT INTO @UserEditCategories SELECT CategoryID FROM dbo.[dnn_EDS_EditPermissions] (@PortalID,@ModuleID,@UserID,@AdminOrSuperUser,@Perm_EditAllCategores,@PermissionSettingsSource,@CurrentDate)
-- kategorije sa edit pravima
IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
BEGIN
	SET @EditPermission = 1;
END
ELSE
BEGIN
	IF EXISTS(SELECT * FROM @UserEditCategories) BEGIN SET @EditPermission = 2; END
END

DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions and Module filter
DECLARE @FiltredByCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories that are filtred by module or portal

IF @NewsFilterCategories <> ''
BEGIN
	INSERT INTO @FiltredByCategories SELECT fc.KeyID FROM dbo.[dnn_EDS_StringListToTable](@NewsFilterCategories) AS fc
	INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.[CategoryID] FROM @UserViewCategories as uvc INNER JOIN @FiltredByCategories as fbc ON uvc.CategoryID = fbc.CategoryID;
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

DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;

DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY);
IF @NewsFilterAuthors = '' AND @NewsFilterGroups = ''
BEGIN
-- ovaj dio odnosi se na filtriranje autora
	IF @ShowAllAuthors = 0 -- filter glavnog newsa
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
END
ELSE
BEGIN
-- treba selektirati sve autore ili grupe !!!
	SET @FilterAuthorOrAuthors = 1;
	IF @NewsFilterAuthors <> '' AND @NewsFilterGroups <> ''
	BEGIN
		INSERT INTO @TempAuthorsIDList
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterAuthors) AS af ON ap.AuthorProfileID = af.KeyID WHERE PortalID = @PortalID
		UNION
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterGroups) AS a ON a.KeyID = agi.GroupID	
		WHERE ap.PortalID = @PortalID
	END
	ELSE IF @NewsFilterAuthors <> ''
	BEGIN
		INSERT INTO @TempAuthorsIDList SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterAuthors) AS af ON ap.AuthorProfileID = af.KeyID WHERE PortalID = @PortalID 
	END
	ELSE IF @NewsFilterGroups <> ''
	BEGIN
		INSERT INTO @TempAuthorsIDList
		SELECT ap.[UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterGroups) AS a ON a.KeyID = agi.GroupID	
		WHERE ap.PortalID = @PortalID
	END
END

DECLARE @LocalizedCategories TABLE (ID INT NOT NULL PRIMARY KEY, Name NVARCHAR(200), Position INT, CategoryURL NVARCHAR(1500));
IF @LocaleCode IS NOT NULL
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

IF @LocaleCode IS NOT NULL
BEGIN
	;WITH MainFilters AS(
		SELECT DISTINCT [ArticleID] FROM (
			SELECT na.[ArticleID], ROW_NUMBER() OVER (PARTITION BY na.[ArticleID] ORDER BY na.[ArticleID] DESC ) AS Recency  FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
			WHERE na.PortalID=@PortalID
				AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
				AND (@Featured = 0 OR na.Featured = 1)
				AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
				AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
			) AS InAllCategories
		WHERE (@CategoriesAndOperator = 0 OR Recency >= (SELECT COUNT(*) FROM @FiltredByCategories))
	),
	AllContent AS(
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
			INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
		WHERE na.HasPermissions = 0
			AND na.HideDefaultLocale = 0
			AND na.EventArticle = 0
			AND (((na.Approved = 1 OR @UserCanApprove = 1) AND (na.Active = 1 OR na.UserID=@UserID)) OR @EditPermission = 1)
		UNION ALL
		SELECT ArticleID FROM (
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID	  		 
			WHERE na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.EventArticle = 0
				AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
				))
			UNION
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID	  		  
			WHERE na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.EventArticle = 0
				AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				))
		) AS HasPermissionsTrue
	),
	AllCount AS (
		SELECT COUNT(ArticleID) AS ContentCount FROM AllContent
	),
	FinalArticleIDsSet (ArticleID) AS(
		SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID
			FROM (
				SELECT *, ROW_NUMBER() OVER (ORDER BY
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
					CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC) AS Kulike
				FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN (SELECT ArticleID FROM AllContent)
			) AS Result
			WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
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
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC
	),
	FinalLocalizedArticleIDsSet (ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
	SELECT ArticleID,Title,SubTitle,Summary,Article,DetailTypeData,clTitleLink AS TitleLink ,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription
	FROM dbo.[dnn_EasyDNNNewsContentLocalization]
	WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet) AND LocaleCode = @LocaleCode
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
	 END AS 'Approve',
	 (SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
	 FROM (
		 SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
			  ,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
			  ,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
			  ,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
			  ,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
			  ,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],n.[CFGroupeID]
			   FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
		 UNION ALL
		 SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
			  ,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
			  ,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
			  ,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
			  ,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
			  ,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription],n.[CFGroupeID]
		  FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID) As Result
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
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC;
END
ELSE
BEGIN
	;WITH MainFilters AS(
		SELECT DISTINCT [ArticleID] FROM (
			SELECT na.[ArticleID], ROW_NUMBER() OVER (PARTITION BY na.[ArticleID] ORDER BY na.[ArticleID] DESC ) AS Recency  FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
				AND (@Featured = 0 OR na.Featured = 1)
				AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
			) AS InAllCategories
		WHERE (@CategoriesAndOperator = 0 OR Recency >= (SELECT COUNT(*) FROM @FiltredByCategories))
	),
	AllContent AS(
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
			INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
		WHERE na.HasPermissions = 0
			AND na.HideDefaultLocale = 0
			AND na.EventArticle = 0
			AND (((na.Approved = 1 OR @UserCanApprove = 1) AND (na.Active = 1 OR na.UserID=@UserID)) OR @EditPermission = 1)
		UNION ALL
		SELECT ArticleID FROM (
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID		  		 
			WHERE na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.EventArticle = 0
				AND ((@EditPermission = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
					AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active = 1 OR na.UserID=@UserID)
				))
			UNION
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
				INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID	  		  
			WHERE na.HasPermissions = 1
				AND na.HideDefaultLocale = 0
				AND na.EventArticle = 0
				AND ((@EditPermission = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
					AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				))
		) AS HasPermissionsTrue
	),
	AllCount AS (
		SELECT COUNT(ArticleID) AS ContentCount FROM AllContent
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
	END AS CanEdit,
	(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS CatToShow,
	CASE Result.Active
		WHEN 1 THEN 0
		WHEN 0 THEN 1
	END AS Published,
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
	END AS Approve,
	(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
	FROM (
	SELECT
		n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],n.[CFGroupeID],
		ROW_NUMBER() OVER (ORDER BY 
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
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC) AS Kulike
	FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID IN (SELECT ArticleID FROM AllContent)) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
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
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC;
END

