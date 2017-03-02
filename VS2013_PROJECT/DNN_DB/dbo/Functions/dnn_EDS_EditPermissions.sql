
CREATE FUNCTION [dbo].[dnn_EDS_EditPermissions]
(	
	@PortalID INT,
	@ModuleID INT,
	@UserID INT,
	@AdminOrSuperUser BIT,
	@Perm_EditAllCategores BIT,
	@PermissionSettingsSource BIT,
	@CurrentDate DATETIME
)
RETURNS @UserEditCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY)
AS
BEGIN
	IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
	BEGIN
		INSERT INTO @UserEditCategories SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE IF @UserID = -1
	BEGIN	
		IF @PermissionSettingsSource = 1
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			WHERE rpatc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] IS NULL AND [RoleID] IS NULL)
		END
		ELSE
		BEGIN
		INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			WHERE rpatc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] = @ModuleID AND [RoleID] IS NULL)
		END
	END
	ELSE
	BEGIN
		IF @PermissionSettingsSource = 1
		BEGIN
			INSERT INTO @UserEditCategories
				SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
				WHERE rpatc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [PortalID] = @PortalID AND [ModuleID] IS NULL AND RoleID IN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)))
				UNION
				SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
				WHERE upatc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] WHERE [PortalID] = @PortalID AND [UserID] = @UserID AND [ModuleID] IS NULL)
		END
		ELSE
		BEGIN
			INSERT INTO @UserEditCategories
				SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
				WHERE rpatc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] WHERE [ModuleID] = @ModuleID AND RoleID IN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate)))
				UNION
				SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
				WHERE upatc.[PremissionSettingsID] IN (SELECT [PremissionSettingsID] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] WHERE [UserID] = @UserID AND [PortalID] = @PortalID AND [ModuleID] = @ModuleID)
		END
	END
RETURN
END

