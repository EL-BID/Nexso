CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsModerateApproved]
	@PortalID INT,
	@UserID INT,
	@ArticleID INT,
	@NewsModuleID INT,
	@Perm_ViewAllCategores BIT = 0,
	@AdminOrSuperUser BIT = 0,
	@UserCanApprove BIT = 0,
	@PermissionSettingsSource BIT = 1, -- 1 portal, 0 module
	@ForceState BIT = NULL
AS
SET NOCOUNT ON;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @HasViewAccess BIT;
SET @HasViewAccess = 0;
IF @UserCanApprove = 1
BEGIN
	IF @AdminOrSuperUser = 1 OR @Perm_ViewAllCategores = 1
		SET @HasViewAccess = 1;
	ELSE IF @UserID = -1
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL
				)
			)
			SET @HasViewAccess = 1;
		END
		ELSE -- by module
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @NewsModuleID AND rps.RoleID IS NULL
				)
			)
			SET @HasViewAccess = 1;
		END
				
		IF @HasViewAccess = 0 -- check permissions per article
		BEGIN
			IF EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.Show = 1 AND aup.UserID IS NULL)
				SET @HasViewAccess = 1;
		END
	END
	ELSE
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)) AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
				UNION ALL
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL
				)
			)
			SET @HasViewAccess = 1;
		END
		ELSE -- by module
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
				INNER JOIN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)) AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @NewsModuleID
				UNION ALL
				SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @NewsModuleID
				)
			)
			SET @HasViewAccess = 1;
		END
		
		IF @HasViewAccess = 0 -- check permissions per article
		BEGIN
			IF EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = @ArticleID AND arp.Show = 1 AND arp.RoleID IN(SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)))
				SET @HasViewAccess = 1;
			ELSE IF EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.Show = 1 AND aup.UserID = @UserID)
				SET @HasViewAccess = 1;
		END
	END
END

IF @HasViewAccess = 1
BEGIN
	DECLARE @ValueToCompare BIT;
	SELECT @ValueToCompare = [Approved] FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID;
	
	IF @ValueToCompare IS NULL
		SELECT 3; -- article doesn't exist
	ELSE IF @ForceState = 1 AND @ValueToCompare = 1
	BEGIN
		SELECT 4; -- doesn't need to update
	END
	ELSE IF @ForceState = 0 AND @ValueToCompare = 0
	BEGIN
		SELECT 4; -- doesn't need to update
	END
	ELSE
	BEGIN
		UPDATE dbo.[dnn_EasyDNNNews] SET [Approved] = (CASE WHEN @ForceState IS NULL THEN CASE WHEN Active = 1 THEN 0 ELSE 1 END ELSE CASE WHEN @ForceState = 1 THEN 1 ELSE 0 END END) WHERE ArticleID = @ArticleID
		IF @@ROWCOUNT = 0
			SELECT 0 AS ReturnValue; -- nothing updated
		ELSE
			SELECT 1 AS ReturnValue; -- updated
	END
END
ELSE
BEGIN
	SELECT 2 AS ReturnValue; -- no edit rights
END

