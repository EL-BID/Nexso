CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsGetContentByPermissions]
	@PortalID INT, -- current Portal
	@ModuleID INT, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID INT,
	@ArticleID INT,
	@Perm_ViewAllCategores BIT = 0,
	@Perm_EditAllCategores BIT = 0,
	@AdminOrSuperUser BIT = 0,
	@EditOnlyAsOwner BIT = 0,
	@UserCanApprove BIT = 0,
	@LocaleCode NVARCHAR(20) = NULL,
	@PermissionSettingsSource BIT = 1 -- 1 portal, 0 module
AS
SET NOCOUNT ON;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate ) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
DECLARE @UserEditCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can edit based on permissions

-- kategorije sa view pravima
IF @AdminOrSuperUser = 1 OR @Perm_ViewAllCategores = 1
BEGIN
	INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
	ELSE -- by module
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID AND rps.RoleID IS NULL;
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
		GROUP BY rpsc.[CategoryID]
		UNION
		SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
		INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
		WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL
		GROUP BY upsc.[CategoryID];
	ELSE -- by module
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID
		GROUP BY rpsc.[CategoryID]
		UNION
		SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
		INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
		WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID
		GROUP BY upsc.[CategoryID];
END

-- kategorije sa edit pravima
IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
BEGIN	
	INSERT INTO @UserEditCategories SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE
BEGIN
	IF @UserID = -1
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		ELSE -- by module
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.RoleID IS NULL AND rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID;
	END
	ELSE -- registrirani korisnik
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
			GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL
			GROUP BY upatc.[CategoryID];
		ELSE -- by module
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID
			GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID
			GROUP BY upatc.[CategoryID];
	END
END

DECLARE @CanView BIT;
SET @CanView = 0;
DECLARE @CanEdit BIT;
SET @CanEdit = 0;

-- mozda bi bilo dobro utvrditi da li ima posebne dozvole

IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
BEGIN
	SET @CanView = 1;
	SET @CanEdit = 1;
END
ELSE
BEGIN
-- prvo pogledaj dal moze edit !!! ako moze edit onda moze i view !!!
	IF @EditOnlyAsOwner = 0
	BEGIN
		IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
			SET @CanEdit = 1;
		ELSE
			IF EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = @ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT [RoleID] FROM @UserInRoles))
				SET @CanEdit = 1;
			ELSE
				IF EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
					SET @CanEdit = 1;
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT ArticleID FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID AND UserID = @UserID)
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
				SET @CanEdit = 1;
		END
		
		IF @CanEdit = 0 -- ovako je bilo prije, ako nije proslo ovo iznad onda se islo na posebne dozvole, mozda to nije ispravno
		BEGIN
			IF EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = @ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT [RoleID] FROM @UserInRoles))
				SET @CanEdit = 1;
			ELSE
				IF EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
					SET @CanEdit = 1;
		END
	END
	
	IF @CanEdit = 1
		SET @CanView = 1;
	ELSE
	BEGIN
		IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID
			INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = c.CategoryID
			WHERE n.ArticleID=@ArticleID
				AND n.HasPermissions = 0
				AND (n.Approved = 1 OR @UserCanApprove = 1)
				AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
			)
			SET @CanView = 1;
		ELSE -- posebne dozvole
		BEGIN
			IF @UserID = -1 -- neregistirani korisnik ne moze BITi u roli
			BEGIN
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n 
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
					WHERE aup.ArticleID = @ArticleID
						AND aup.UserID IS NULL
						AND n.HasPermissions = 1
						AND (n.Approved = 1 OR @UserCanApprove = 1)
						AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
					)
					SET @CanView = 1;
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n 
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
					WHERE aup.ArticleID = @ArticleID
						AND n.HasPermissions = 1
						AND aup.UserID = @UserID
						AND aup.Show = 1
						AND (n.Approved = 1 OR @UserCanApprove = 1)
						AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
					)
					SET @CanView = 1;
				ELSE
				BEGIN 
					IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n 
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
						WHERE arp.ArticleID = @ArticleID
							AND n.HasPermissions = 1
							AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							AND arp.Show = 1
							AND (n.Approved = 1 OR @UserCanApprove = 1)
							AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
						)
						SET @CanView = 1;
				END
			 END
		END
	END
END
-- ovo se odnosi za lokalizaciju tablice kategorija u posebnu tablicu koja se direktno spaja
DECLARE @localize BIT;
SET @localize = 0;
DECLARE @LocalizedCategories TABLE (ID INT NOT NULL PRIMARY KEY, Name NVARCHAR(200), Position INT, CategoryURL NVARCHAR(1500));
IF @LocaleCode IS NOT NULL
BEGIN
	IF EXISTS (SELECT ArticleID FROM dbo.[dnn_EasyDNNNewsContentLocalization] WHERE ArticleID = @ArticleID AND LocaleCode = @LocaleCode)
	BEGIN
		SET @localize = 1;
	END;

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
--
IF @CanView = 1
BEGIN
	IF @localize = 1
	BEGIN
	SELECT *,
		CASE WHEN @CanEdit = 1 THEN 1 ELSE 0 END AS CanEdit,
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = @ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS CatToShow,
		CASE WHEN Article.Active = 1 THEN 0 ELSE 1 END AS Published,
		CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Article.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Article.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS Approve
		 FROM (
		  SELECT ln.[ArticleID],ln.[PortalID],ln.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],ln.[ArticleImage],ln.[DateAdded],ln.[LastModified],ln.[PublishDate]
			  ,ln.[ExpireDate],ln.[Approved],ln.[Featured],ln.[NumberOfViews],ln.[RatingValue],ln.[RatingCount],ln.[AllowComments],ln.[Active]
			  ,fla.[clTitleLink] AS TitleLink,ln.[DetailType],fla.[DetailTypeData],ln.[DetailsTemplate],ln.[DetailsTheme],ln.[GalleryPosition],ln.[GalleryDisplayType]
			  ,ln.[ShowMainImage],ln.[ShowMainImageFront],ln.[CommentsTheme],ln.[ArticleImageFolder],ln.[NumberOfComments]
			  ,ln.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],ln.[DisplayStyle],ln.[DetailTarget]
			  ,ln.[ArticleFromRSS],ln.[HasPermissions],ln.[EventArticle],ln.[DetailMediaType],ln.[DetailMediaData],ln.[AuthorAliasName],ln.[ShowGallery],ln.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription],ln.[CFGroupeID]
			  ,ln.[DetailsDocumentsTemplate],ln.[DetailsLinksTemplate],ln.[DetailsRelatedArticlesTemplate]
			FROM dbo.[dnn_EasyDNNNews] AS ln INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS fla ON fla.ArticleID = ln.ArticleID AND fla.LocaleCode = @LocaleCode WHERE ln.ArticleID = @ArticleID
		 ) AS Article;
	END
	ELSE
	BEGIN
	SELECT *,
		CASE WHEN @CanEdit = 1 THEN 1 ELSE 0 END AS CanEdit,
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = @ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS CatToShow,
		CASE WHEN Article.Active = 1 THEN 0 ELSE 1 END AS Published,
		CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Article.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Article.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS Approve
		 FROM (
		  SELECT n.[ArticleID],n.[PortalID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
			  ,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
			  ,n.TitleLink,n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
			  ,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
			  ,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
			  ,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],n.[CFGroupeID]
			  ,n.[DetailsDocumentsTemplate],n.[DetailsLinksTemplate],n.[DetailsRelatedArticlesTemplate]
			 FROM dbo.[dnn_EasyDNNNews] AS n WHERE n.ArticleID = @ArticleID) AS Article;	 
	END
END

