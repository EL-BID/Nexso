CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsModeratePublished]
	@PortalID INT,
	@UserID INT,
	@ArticleID INT,
	@NewsModuleID INT,
	@Perm_EditAllCategores BIT = 0,
	@AdminOrSuperUser BIT = 0,
	@EditOnlyAsOwner BIT = 0,
	@PermissionSettingsSource BIT = 1, -- 1 portal, 0 module
	@ForceState BIT = NULL
AS
SET NOCOUNT ON;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();
DECLARE @HasPassedEditOnlyAsOwner BIT;
SET @HasPassedEditOnlyAsOwner = 1;
DECLARE @HasEditAccess BIT;
SET @HasEditAccess = 0;

IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
	SET @HasEditAccess = 1;
ELSE IF @UserID = -1
BEGIN
	IF @EditOnlyAsOwner = 1
	BEGIN
		IF NOT EXISTS (SELECT ArticleID FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID AND (UserID = -1 OR UserID IS NULL))
			SET @HasPassedEditOnlyAsOwner = 0;
	END

	IF @HasPassedEditOnlyAsOwner = 1
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL
				)
			)
			SET @HasEditAccess = 1;
		END
		ELSE -- by module
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @NewsModuleID AND rps.RoleID IS NULL
				)
			)
			SET @HasEditAccess = 1;
		END		
		-- unreg user has no edit permissions per article		
	END
END
ELSE
BEGIN
	IF @EditOnlyAsOwner = 1
	BEGIN
		IF NOT EXISTS (SELECT ArticleID FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID AND UserID = @UserID)
			SET @HasPassedEditOnlyAsOwner = 0;
	END

	IF @HasPassedEditOnlyAsOwner = 1
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
				INNER JOIN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)) AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
				UNION ALL
				SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL
				)
			)
			SET @HasEditAccess = 1;
		END
		ELSE -- by module
		BEGIN
			IF EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = @ArticleID AND c.CategoryID IN (
				SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
				INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
				INNER JOIN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)) AS uir ON rps.RoleID = uir.RoleID
				WHERE rps.PortalID = @PortalID AND rps.ModuleID = @NewsModuleID
				UNION ALL
				SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
				INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
				WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @NewsModuleID
				)
			)
			SET @HasEditAccess = 1;
		END		
	END
	
	IF @HasEditAccess = 0 -- check permissions per article - ne gleda se @EditOnlyAsOwner
	BEGIN
		IF EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = @ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)))
			SET @HasEditAccess = 1;
		ELSE IF EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
			SET @HasEditAccess = 1;
	END
END

IF @HasEditAccess = 1
BEGIN
	DECLARE @ValueToCompare BIT;
	SELECT @ValueToCompare = [Active] FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID;
	
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
		UPDATE dbo.[dnn_EasyDNNNews] SET [Active] = (CASE WHEN @ForceState IS NULL THEN CASE WHEN Active = 1 THEN 0 ELSE 1 END ELSE CASE WHEN @ForceState = 1 THEN 1 ELSE 0 END END) WHERE ArticleID = @ArticleID
		IF @@ROWCOUNT = 0
			SELECT 0 AS ReturnValue; -- nothing updated
		ELSE
			SELECT 1 AS ReturnValue; -- updated
	END
END
ELSE
	SELECT 2 AS ReturnValue; -- no edit rights

