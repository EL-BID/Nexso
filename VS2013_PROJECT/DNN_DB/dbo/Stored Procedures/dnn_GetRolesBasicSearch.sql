CREATE PROCEDURE [dbo].[dnn_GetRolesBasicSearch]
    @PortalID           Int,                    -- might be null for all portals
    @PageIndex          Int,                    -- page number starting at 0
    @PageSize           Int,                    -- number of items per page
    @FilterBy           nVarChar(100)           -- pattern for role name, do not use preceding or trailing wildcards
AS
BEGIN
    IF IsNull(@FilterBy, '') <> '' BEGIN
        IF Substring(@FilterBy, 1, 1) = '%'
            SET @FilterBy = Substring(@FilterBy, 2, Len(@FilterBy) - 1)
        IF Substring(@FilterBy, Len(@FilterBy), 1) = '%'
            SET @FilterBy = Substring(@FilterBy, 1, Len(@FilterBy) - 1)
     END;

	IF IsNull(@PageIndex,-1) >= 0 AND IsNull(@PageSize, 0) > 0 AND IsNull(@PageSize, 0) < Cast(0x7fffffff AS Int)
		WITH OrderedRoles AS (
			SELECT RoleID, PortalID, RoleName, [Description], ServiceFee, BillingFrequency, TrialPeriod, TrialFrequency, BillingPeriod, TrialFee,
				   IsPublic, AutoAssignment, RoleGroupID, RSVPCode, dbo.dnn_FilePath(IconFile) AS IconFile, Status, SecurityMode,
				   CreatedByUserID,CreatedOnDate,LastModifiedByUserID,LastModifiedOnDate,
				   ROW_NUMBER() OVER (ORDER BY RoleName ASC, PortalID DESC) AS RowNum
			 FROM dbo.[dnn_Roles]
			 WHERE (RoleName LIKE '%' + @FilterBy + '%' OR IsNull(@FilterBy,'') = '')
			   AND (PortalID = @PortalID OR IsNull(@PortalID, -1)  = -1)
			   AND (RoleId  >= 0) -- DNN-4288: ignore virtual roles
			)
		SELECT * FROM OrderedRoles WHERE RowNum >= dbo.dnn_PageLowerBound(@PageIndex, @Pagesize)
									 AND RowNum <= dbo.dnn_PageUpperBound(@PageIndex, @Pagesize) ORDER BY RowNum
		 OPTION (OPTIMIZE FOR (@PortalId UNKNOWN));
	ELSE -- no paging
        SELECT RoleID, PortalID, RoleName, [Description], ServiceFee, BillingFrequency, TrialPeriod, TrialFrequency, BillingPeriod, TrialFee,
               IsPublic, AutoAssignment, RoleGroupID, RSVPCode, dbo.dnn_FilePath(IconFile) AS IconFile, Status, SecurityMode,
               CreatedByUserID,CreatedOnDate,LastModifiedByUserID,LastModifiedOnDate,
               ROW_NUMBER() OVER (ORDER BY RoleName ASC, PortalID DESC) AS RowNum
         FROM dbo.[dnn_Roles]
         WHERE (RoleName LIKE '%' + @FilterBy + '%' OR IsNull(@FilterBy,'') = '')
           AND (PortalID = @PortalID OR IsNull(@PortalID, -1)  = -1)
           AND (RoleId  >= 0) -- DNN-4288: ignore virtual roles
		 OPTION (OPTIMIZE FOR (@PortalId UNKNOWN))
END
