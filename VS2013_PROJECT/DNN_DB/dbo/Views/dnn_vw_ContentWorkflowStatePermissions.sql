CREATE VIEW [dbo].[dnn_vw_ContentWorkflowStatePermissions]
AS
    SELECT     
	    WSP.WorkflowStatePermissionID, 
	    WSP.StateID, 
	    P.PermissionID, 
	    WSP.RoleID,
	    CASE WSP.RoleID
		    when -1 then 'All Users'
		    when -2 then 'Superuser'
		    when -3 then 'Unauthenticated Users'
		    else 	R.RoleName
	    END AS 'RoleName',
	    WSP.AllowAccess, 
	    WSP.UserID,
	    U.Username,
	    U.DisplayName, 
	    P.PermissionCode, 
	    P.ModuleDefID, 
	    P.PermissionKey, 
	    P.PermissionName, 
        WSP.CreatedByUserID, 
        WSP.CreatedOnDate, 
        WSP.LastModifiedByUserID, 
        WSP.LastModifiedOnDate    
    FROM dbo.dnn_ContentWorkflowStatePermission AS WSP 
	    LEFT OUTER JOIN dbo.dnn_Permission AS P ON WSP.PermissionID = P.PermissionID 
	    LEFT OUTER JOIN dbo.dnn_Roles AS R ON WSP.RoleID = R.RoleID
	    LEFT OUTER JOIN dbo.dnn_Users AS U ON WSP.UserID = U.UserID

