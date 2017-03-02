CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsShowCategoriesByPermissions]
    @UserID int,
    @PortalID int,
    @ModuleID int
AS 
SET NOCOUNT ON;
DECLARE @CheckModuleID bit;
IF @ModuleID IS NULL
BEGIN
	SET @CheckModuleID = 1;
END
ELSE
BEGIN
	SET @CheckModuleID = 0;
END
IF @UserID = -1
BEGIN
	SELECT DISTINCT CategoryID
	 FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
	  INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.RoleID IS NULL AND ((@CheckModuleID = 1 AND (rps.ModuleID IS NULL)) OR (@CheckModuleID = 0 AND (rps.ModuleID = @ModuleID))) AND rps.PortalID = @PortalID
END
ELSE
BEGIN
	SELECT DISTINCT CategoryID
	 FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
	  INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
	   INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = rps.RoleID
		WHERE ur.UserID = @UserID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > GETUTCDATE()) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < GETUTCDATE()) AND ((@CheckModuleID = 1 AND (rps.ModuleID IS NULL)) OR (@CheckModuleID = 0 AND (rps.ModuleID = @ModuleID))) AND rps.PortalID = @PortalID
	UNION
	SELECT CategoryID
	 FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
	  INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON upsc.PremissionSettingsID = ups.PremissionSettingsID
	   WHERE ups.UserID = @UserID AND ((@CheckModuleID = 1 AND (ups.ModuleID IS NULL)) OR (@CheckModuleID = 0 AND (ups.ModuleID = @ModuleID))) AND ups.PortalID = @PortalID
END

