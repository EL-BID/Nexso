CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetItemsForArticleEditor]
	@PortalID INT, -- current Portal
	@ModuleID INT, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID INT,
	@ItemsFrom INT = 1,
	@ItemsTo INT = 5,
	@OnlyOneCategory INT = 0, -- used for category menu or when need to filter by one category
	@FilterByAuthor INT = 0, -- ako se selektiran jedan autor
	@FilterByGroupID INT = 0, -- ako je selektirana grupa
	@EditOnlyAsOwner BIT = 0, -- news settings
	@UserCanApprove BIT = 0, -- news settings
	@Perm_ViewAllCategores BIT = 0, -- permission settings View all categories
	@Perm_EditAllCategores BIT = 0, -- permission settings Edit all categories
	@AdminOrSuperUser BIT = 0,
	@PermissionSettingsSource BIT = 1, -- 1 portal, 0 module
	@OrderBy NVARCHAR(20) = 'PublishDate DESC',
	@OrderBy2 NVARCHAR(20) = '',
	
	@Featured TINYINT = 0,
	@Published TINYINT = 0,
	@Approved TINYINT = 0,
	@ArticleType TINYINT = 0,
	@PermissionsByArticle TINYINT = 0	
AS
SET NOCOUNT ON;
DECLARE @EditPermission TINYINT;
SET @EditPermission = 0;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();
DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);
DECLARE @UserEditCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can edit based on permissions

DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;
DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY);
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

SELECT Result.*,CASE WHEN u.DisplayName IS NULL THEN 'Anonym' ELSE u.DisplayName END AS DisplayName,
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
	 CASE WHEN Result.EventArticle = 1 AND EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = Result.ArticleID)
	   THEN 1 ELSE 0 END
	 AS IsRecurring		
	FROM (SELECT n.*, ed.StartDate AS EventStartDate, ROW_NUMBER() OVER (ORDER BY 
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

	CASE WHEN @OrderBy2 ='PublishDate ASC' THEN PublishDate END,
	CASE WHEN @OrderBy2 ='PublishDate DESC' THEN PublishDate END DESC,
	CASE WHEN @OrderBy2 ='NumberOfViews ASC' THEN NumberOfViews END,
	CASE WHEN @OrderBy2 ='NumberOfViews DESC' THEN NumberOfViews END DESC,
	CASE WHEN @OrderBy2 ='RatingValue ASC' THEN RatingValue END,
	CASE WHEN @OrderBy2 ='RatingValue DESC' THEN RatingValue END DESC,
	CASE WHEN @OrderBy2 ='DateAdded ASC' THEN DateAdded END,
	CASE WHEN @OrderBy2 ='DateAdded DESC' THEN DateAdded END DESC,
	CASE WHEN @OrderBy2 ='ExpireDate ASC' THEN ExpireDate END,
	CASE WHEN @OrderBy2 ='ExpireDate DESC' THEN ExpireDate END DESC,
	CASE WHEN @OrderBy2 ='LastModified ASC' THEN LastModified END,
	CASE WHEN @OrderBy2 ='LastModified DESC' THEN LastModified END DESC,
	CASE WHEN @OrderBy2 ='NumberOfComments ASC' THEN NumberOfComments END,
	CASE WHEN @OrderBy2 ='NumberOfComments DESC' THEN NumberOfComments END DESC,
	CASE WHEN @OrderBy2 ='Title ASC' THEN Title END,
	CASE WHEN @OrderBy2 ='Title DESC' THEN Title END DESC) AS Kulike
	FROM dbo.[dnn_EasyDNNNews] AS n
	LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ed ON ed.ArticleID = n.ArticleID
	WHERE n.ArticleID IN(
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM @UserEditCategories)
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 0
			AND ((@Approved = 0) OR ((@Approved = 1 AND na.Approved = 1) OR (@Approved = 2 AND na.Approved = 0)))		   
			AND ((@ArticleType = 0) OR ((@ArticleType = 1 AND na.EventArticle = 0) OR (@ArticleType = 2 AND na.EventArticle = 1)))
			AND ((@PermissionsByArticle = 0) OR ((@PermissionsByArticle = 1 AND na.HasPermissions = 1) OR (@PermissionsByArticle = 2 AND na.HasPermissions = 0)))		   
			AND ((@Published = 0) OR ((@Published = 1 AND na.Active = 1) OR (@Published = 2 AND na.Active = 0)))
			AND ((@Featured = 0) OR ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 2 AND na.Featured = 0)))
			AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
		UNION ALL
		SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
			INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
		WHERE na.PortalID=@PortalID
			AND na.HasPermissions = 1
			AND ((@EditPermission = 1) OR ((aup.Edit = 1) AND ((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))))
			AND ((@Approved = 0) OR ((@Approved = 1 AND na.Approved = 1) OR (@Approved = 2 AND na.Approved = 0)))
			AND ((@ArticleType = 0) OR ((@ArticleType = 1 AND na.EventArticle = 0) OR (@ArticleType = 2 AND na.EventArticle = 1)))
			AND ((@PermissionsByArticle = 0) OR ((@PermissionsByArticle = 1 AND na.HasPermissions = 1) OR (@PermissionsByArticle = 2 AND na.HasPermissions = 0)))
			AND ((@Published = 0) OR ((@Published = 1 AND na.Active = 1) OR (@Published = 2 AND na.Active = 0)))
			AND ((@Featured = 0) OR ((@Featured = 1 AND na.Featured = 1) OR (@Featured = 2 AND na.Featured = 0)))
			AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList)))
			AND ((@OnlyOneCategory <> 0 AND cat.CategoryID IN (SELECT @OnlyOneCategory)) OR (@OnlyOneCategory = 0))
		UNION
		SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
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
		)
	 ) AS Result LEFT OUTER JOIN dbo.[dnn_Users] AS u ON Result.UserID = u.UserID WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
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
	 CASE WHEN @OrderBy2 ='PublishDate ASC' THEN PublishDate END,
	 CASE WHEN @OrderBy2 ='PublishDate DESC' THEN PublishDate END DESC,
	 CASE WHEN @OrderBy2 ='NumberOfViews ASC' THEN NumberOfViews END,
	 CASE WHEN @OrderBy2 ='NumberOfViews DESC' THEN NumberOfViews END DESC,
	 CASE WHEN @OrderBy2 ='RatingValue ASC' THEN RatingValue END,
	 CASE WHEN @OrderBy2 ='RatingValue DESC' THEN RatingValue END DESC,
	 CASE WHEN @OrderBy2 ='DateAdded ASC' THEN DateAdded END,
	 CASE WHEN @OrderBy2 ='DateAdded DESC' THEN DateAdded END DESC,
	 CASE WHEN @OrderBy2 ='ExpireDate ASC' THEN ExpireDate END,
	 CASE WHEN @OrderBy2 ='ExpireDate DESC' THEN ExpireDate END DESC,
	 CASE WHEN @OrderBy2 ='LastModified ASC' THEN LastModified END,
	 CASE WHEN @OrderBy2 ='LastModified DESC' THEN LastModified END DESC,
	 CASE WHEN @OrderBy2 ='NumberOfComments ASC' THEN NumberOfComments END,
	 CASE WHEN @OrderBy2 ='NumberOfComments DESC' THEN NumberOfComments END DESC,
	 CASE WHEN @OrderBy2 ='Title ASC' THEN Title END,
	 CASE WHEN @OrderBy2 ='Title DESC' THEN Title END DESC;

