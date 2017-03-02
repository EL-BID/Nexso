CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsCanAddEditArticles]
    @UserID INT,
    @PortalID INT,
    @ModuleID INT,
    @IsAdminOrSuperUser BIT,
    @AddArticleToAll BIT,
    @UserCanEditOnlyTheirArticles BIT
AS 
SET NOCOUNT ON;
DECLARE @HasEditCategories BIT;
SET @HasEditCategories = 0;
DECLARE @ExistsEventWithRegistration BIT;
SET @ExistsEventWithRegistration = 0;

DECLARE @CheckModuleID bit;
IF @ModuleID IS NULL
	SET @CheckModuleID = 1;
ELSE
	SET @CheckModuleID = 0;


IF @IsAdminOrSuperUser = 1 OR @AddArticleToAll = 1
BEGIN
	SET @HasEditCategories = 1;
	IF EXISTS(
			SELECT 1 FROM dbo.[dnn_EasyDNNNews] AS n
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ed ON n.ArticleID = ed.ArticleID
			WHERE c.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID)
				AND n.PortalID=@PortalID
				AND ed.EventType IS NOT NULL
				AND n.EventArticle = 1
				AND (@UserCanEditOnlyTheirArticles = 0 OR n.UserID = @UserID)
		)
		SET @ExistsEventWithRegistration = 1;
END
ELSE
BEGIN
	DECLARE @EditCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
	IF @UserID = -1
	BEGIN
		INSERT INTO @EditCategories
		SELECT DISTINCT cat.CategoryID FROM dbo.[dnn_EasyDNNNewsCategoryList] as cat INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpac ON cat.CategoryID = rpac.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rpac.PremissionSettingsID = rps.PremissionSettingsID
		WHERE rps.RoleID IS NULL AND ((@CheckModuleID = 1 AND (rps.ModuleID IS NULL)) OR (@CheckModuleID = 0 AND (rps.ModuleID = @ModuleID))) AND rps.PortalID = @PortalID;
	END
	ELSE
	BEGIN
		INSERT INTO @EditCategories
		SELECT DISTINCT cat.CategoryID
		FROM dbo.[dnn_EasyDNNNewsCategoryList] as cat INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpac ON cat.CategoryID = rpac.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rpac.PremissionSettingsID = rps.PremissionSettingsID
			INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = rps.RoleID
		WHERE ur.UserID = @UserID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > GETUTCDATE()) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < GETUTCDATE()) AND ((@CheckModuleID = 1 AND (rps.ModuleID IS NULL)) OR (@CheckModuleID = 0 AND (rps.ModuleID = @ModuleID))) AND rps.PortalID = @PortalID
		UNION
		SELECT DISTINCT cat.CategoryID
		FROM dbo.[dnn_EasyDNNNewsCategoryList] as cat INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upac ON cat.CategoryID = upac.CategoryID
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON upac.PremissionSettingsID = ups.PremissionSettingsID
		WHERE ups.UserID = @UserID AND ((@CheckModuleID = 1 AND (ups.ModuleID IS NULL)) OR (@CheckModuleID = 0 AND (ups.ModuleID = @ModuleID))) AND ups.PortalID = @PortalID;
	END

	IF EXISTS (SELECT 1 FROM @EditCategories)
	BEGIN
		SET @HasEditCategories = 1;
		IF EXISTS(
			SELECT 1 FROM dbo.[dnn_EasyDNNNews] AS n
			INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ed ON n.ArticleID = ed.ArticleID
			WHERE c.CategoryID IN (SELECT CategoryID FROM @EditCategories)
				AND n.PortalID=@PortalID
				AND ed.EventType IS NOT NULL
				AND n.EventArticle = 1
				AND (@UserCanEditOnlyTheirArticles = 0 OR n.UserID = @UserID)
		)
		SET @ExistsEventWithRegistration = 1;
	END
END

SELECT @HasEditCategories AS HasEditCategories, @ExistsEventWithRegistration AS ExistsEventWithRegistration;

