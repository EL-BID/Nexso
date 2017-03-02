CREATE PROCEDURE [dbo].[dnn_GetAvailableUsersForIndex]
    @PortalId INT ,
    @StartDate DATETIME ,
    @startUserId INT = 0,
    @numberOfUsers INT = 500
AS
    BEGIN
		DECLARE @PivotSql NVARCHAR(MAX)

		SELECT @PivotSql = COALESCE(@PivotSql + ',','') + '[' + PropertyName + ']'
		 FROM dbo.[dnn_ProfilePropertyDefinition] pd
		 INNER JOIN dbo.[dnn_Lists] l ON ListName = 'DataType' AND SystemList = 1 AND Value IN ( 'Text', 'RichText' ) AND l.EntryID = pd.DataType
		 WHERE ISNULL(pd.PortalID, -1) = ISNULL(@PortalId, -1)
		   AND Deleted = 0
		ORDER BY ViewOrder

		DECLARE @Sql NVARCHAR(MAX)

		SELECT @Sql = '
        WITH    ValidDataType
                  AS ( SELECT   EntryID
                       FROM     dbo.[dnn_Lists]
                       WHERE    ListName = ''DataType''
                                AND SystemList = 1
                                AND Value IN ( ''Text'', ''RichText'' )
                     ),
                  ValidUsers AS
                  (
                                      SELECT UserId FROM ( SELECT   UserId, ROW_NUMBER() OVER(ORDER BY UserId ASC) AS rownumber
                         FROM ( SELECT DISTINCT
                                            ( u.UserID )
                                  FROM      dbo.[dnn_Users] u
                                            INNER JOIN dbo.[dnn_UserPortals] up ON up.UserId = u.UserID
                                            INNER JOIN dbo.[dnn_vw_Profile] p ON p.UserID = u.UserID
                                            INNER JOIN dbo.[dnn_ProfilePropertyDefinition] pd ON pd.PropertyDefinitionID = p.PropertyDefinitionID AND pd.Visible = 1 AND pd.PortalID = @PortalId
                                            INNER JOIN ValidDataType dt ON dt.EntryID = pd.DataType
                                  WHERE     (up.PortalId = @PortalId OR up.PortalId IS NULL)
                                            AND (u.LastModifiedOnDate > @StartDate OR (p.LastUpdatedDate IS NOT NULL AND (p.LastUpdatedDate > @StartDate OR pd.LastModifiedOnDate > @StartDate)))
                                            AND ((p.PropertyValue IS NOT NULL AND p.PropertyValue <> '''') OR u.LastModifiedOnDate > @StartDate OR p.LastUpdatedDate IS NULL OR p.LastUpdatedDate > @StartDate)
                                ) AS T WHERE UserID > @startUserId) AS T
                                WHERE rownumber <= @numberOfUsers
                     )

		SELECT * FROM (
        SELECT u.UserID ,
               u.DisplayName,
               u.LastModifiedOnDate,
			   u.Username,
			   u.IsSuperUser,
			   u.Email,
			   u.CreatedOnDate,
			   p.PropertyName,
			   REPLACE(p.PropertyValue, ''$$$'', ''[$][$][$]'') + ''$$$'' +
			   CAST(CASE WHEN (p.Visibility IS NULL) THEN 0 ELSE p.Visibility END AS VARCHAR(10)) + ''$$$'' +
			   p.ExtendedVisibility + ''$$$'' +
			   CONVERT(VARCHAR(20), CASE WHEN u.LastModifiedOnDate > p.LastUpdatedDate OR p.LastUpdatedDate IS NULL THEN u.LastModifiedOnDate ELSE p.LastUpdatedDate END, 20) AS [PropertyValue]
		FROM
			dbo.[dnn_Users] u
			INNER JOIN ValidUsers vu on vu.UserId = u.UserID
			INNER JOIN dbo.[dnn_vw_Profile] p ON p.UserID = u.UserID
			INNER JOIN dbo.[dnn_ProfilePropertyDefinition] pd ON pd.PropertyDefinitionID = p.PropertyDefinitionID AND pd.Visible = 1 AND pd.PortalID = @PortalID
			INNER JOIN ValidDataType dt ON dt.EntryID = pd.DataType) AS T
		PIVOT (MAX(PropertyValue) for PropertyName in (' + @PivotSql + ')) AS T
		ORDER BY UserId
		'
		EXECUTE sp_executesql @Sql,
                              N'@PortalId INT ,
                                @StartDate DATETIME ,
                                @startUserId INT,
                                @numberOfUsers INT',
                              @PortalId, @StartDate, @startUserId, @numberOfUsers
    END
