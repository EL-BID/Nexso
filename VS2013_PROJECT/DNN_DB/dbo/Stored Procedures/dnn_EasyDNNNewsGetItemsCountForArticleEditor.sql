CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetItemsCountForArticleEditor]
	@PortalID int, -- current Portal
	@ModuleID int, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID int,
	@ItemsFrom int = 1,
	@ItemsTo int = 5,
	@OnlyOneCategory int = 0, -- used for category menu or vhen need to filter by one category
	@FilterByAuthor int = 0, -- ako se selektiran jedan autor
	@FilterByGroupID int = 0, -- ako je selektirana grupa
	@EditOnlyAsOwner bit = 0, -- news settings
	@UserCanApprove bit = 0, -- news settings
	@Perm_ViewAllCategores bit = 0, -- permission settings View all categories
	@Perm_EditAllCategores bit = 0, -- permission settings Edit all categories
	@AdminOrSuperUser bit = 0,
	@PermissionSettingsSource bit = 1, -- 1 portal, 0 module
	@OrderBy nvarchar(20) = 'PublishDate DESC',
	@OrderBy2 nvarchar(20) = '',
	
	@Featured tinyint = 0,
	@Published tinyint = 0,
	@Approved tinyint = 0,
	@ArticleType tinyint = 0,
	@PermissionsByArticle tinyint = 0	
AS
SET NOCOUNT ON;
DECLARE @EditPermission tinyint;
SET @EditPermission = 0;
DECLARE @UserInRoles TABLE (RoleID int);
INSERT INTO @UserInRoles SELECT DISTINCT ur.[RoleID] FROM dbo.[dnn_UserRoles] AS ur INNER JOIN dbo.[dnn_Roles] AS r ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > GETUTCDATE()) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < GETUTCDATE());
DECLARE @UserEditCategories TABLE (CategoryID int NOT NULL PRIMARY KEY); -- all categories which user can edit based on permissions

DECLARE @FilterAuthorOrAuthors bit;
SET @FilterAuthorOrAuthors = 0;
DECLARE @TempAuthorsIDList TABLE (UserID int NOT NULL PRIMARY KEY);
IF @FilterByAuthor <> 0
BEGIN
	SET @FilterAuthorOrAuthors = 1;
	INSERT INTO @TempAuthorsIDList SELECT @FilterByAuthor;
END
ELSE IF @FilterByGroupID <> 0
BEGIN
	SET @FilterAuthorOrAuthors = 1;
	INSERT INTO @TempAuthorsIDList
	SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
		INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID	
		WHERE agi.GroupID = @FilterByGroupID
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
	IF EXISTS(SELECT TOP (1) * FROM @UserEditCategories) BEGIN SET @EditPermission = 2; END
END

IF @OnlyOneCategory <> 0 -- filtrira se po jednoj kategoriji
BEGIN
	 DELETE uec FROM @UserEditCategories AS uec WHERE uec.CategoryID NOT IN (SELECT @OnlyOneCategory);
END

DECLARE @ArticlesInCategories int;
SET @ArticlesInCategories = 0;
DECLARE @ArticlesInRolesAndUsers int;
SET @ArticlesInRolesAndUsers = 0;


SELECT @ArticlesInCategories = Count(ArticleID) FROM (SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
	INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
	INNER JOIN @UserEditCategories AS uec ON uec.CategoryID = cat.CategoryID
WHERE na.PortalID=@PortalID
	AND na.HasPermissions = 0
	AND ((@Approved = 0) OR ((@Approved = 1 AND na.Approved = 1) OR (@Approved = 2 AND na.Approved = 0)))
	AND ((@ArticleType = 0) OR ((@ArticleType = 1 AND na.EventArticle = 0) OR (@ArticleType = 2 AND na.EventArticle = 1)))
	AND ((@PermissionsByArticle = 0) OR ((@PermissionsByArticle = 1 AND na.HasPermissions = 1) OR (@PermissionsByArticle = 2 AND na.HasPermissions = 0)))
	AND ((@Published = 0) OR ((@Published = 1 AND na.Active = 1) OR (@Published = 2 AND na.Active = 0)))
	AND ((@Featured = 0) OR ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 2 AND na.Featured = 0)))
	AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
GROUP BY na.ArticleID) AS CountTable;

SELECT @ArticlesInRolesAndUsers = Count(ArticleID) FROM (
	SELECT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
	WHERE na.PortalID=@PortalID
		AND ((@EditPermission = 1) OR ((aup.Edit = 1) AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))))
		AND na.HasPermissions = 1
		AND ((@Approved = 0) OR ((@Approved = 1 AND na.Approved = 1) OR (@Approved = 2 AND na.Approved = 0)))
		AND ((@ArticleType = 0) OR ((@ArticleType = 1 AND na.EventArticle = 0) OR (@ArticleType = 2 AND na.EventArticle = 1)))
	    AND ((@PermissionsByArticle = 0) OR ((@PermissionsByArticle = 1 AND na.HasPermissions = 1) OR (@PermissionsByArticle = 2 AND na.HasPermissions = 0)))
		AND ((@Published = 0) OR ((@Published = 1 AND na.Active = 1) OR (@Published = 2 AND na.Active = 0)))
		AND ((@Featured = 0) OR ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 2 AND na.Featured = 0)))
		AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
		AND ((@OnlyOneCategory <> 0 AND cat.CategoryID IN (SELECT @OnlyOneCategory)) OR (@OnlyOneCategory = 0))
	GROUP BY na.ArticleID
	UNION
	SELECT na.[ArticleID] from dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
	WHERE na.PortalID=@PortalID
		AND na.HasPermissions = 1
		AND ((@EditPermission = 1) OR ((arp.Edit = 1) AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)))
		AND ((@Approved = 0) OR ((@Approved = 1 AND na.Approved = 1) OR (@Approved = 2 AND na.Approved = 0)))
		AND ((@ArticleType = 0) OR ((@ArticleType = 1 AND na.EventArticle = 0) OR (@ArticleType = 2 AND na.EventArticle = 1)))
	    AND ((@PermissionsByArticle = 0) OR ((@PermissionsByArticle = 1 AND na.HasPermissions = 1) OR (@PermissionsByArticle = 2 AND na.HasPermissions = 0)))
		AND ((@Published = 0) OR ((@Published = 1 AND na.Active = 1) OR (@Published = 2 AND na.Active = 0)))
		AND ((@Featured = 0) OR ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 2 AND na.Featured = 0)))
		AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
		AND ((@OnlyOneCategory <> 0 AND cat.CategoryID IN (SELECT @OnlyOneCategory)) OR (@OnlyOneCategory = 0))
	GROUP BY na.ArticleID
) AS final

SELECT @ArticlesInRolesAndUsers + @ArticlesInCategories
     
     

