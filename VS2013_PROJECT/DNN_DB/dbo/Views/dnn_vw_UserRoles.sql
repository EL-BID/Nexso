CREATE VIEW [dbo].[dnn_vw_UserRoles]
AS
	SELECT     
		UR.UserRoleID, 
		R.RoleID, 
		U.UserID, 
		R.PortalID, 
		R.RoleName, 
		U.Username, 
		R.Description, 
		U.DisplayName, 
		U.Email,
		UR.Status, 
		UR.IsOwner,
		R.SecurityMode,
		R.ServiceFee, 
		R.BillingFrequency, 
		R.TrialPeriod, 
        R.TrialFrequency, 
		R.BillingPeriod, 
		R.TrialFee, 
		R.IsPublic, 
		R.AutoAssignment, 
		R.RoleGroupID, 
		R.RSVPCode, 
		R.IconFile, 
		UR.EffectiveDate, 
		UR.ExpiryDate, 
        UR.IsTrialUsed, 
		UR.CreatedByUserID, 
		UR.CreatedOnDate, 
		UR.LastModifiedByUserID, 
		UR.LastModifiedOnDate 
	FROM dbo.dnn_UserRoles AS UR 
		INNER JOIN dbo.dnn_Users AS U ON UR.UserID = U.UserID 
		INNER JOIN dbo.dnn_Roles AS R ON UR.RoleID = R.RoleID
	WHERE R.Status = 1

