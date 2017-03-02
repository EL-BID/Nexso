CREATE PROCEDURE [dbo].[dnn_GetEventLog]
    @PortalID   Int,            -- Might be Null for all sites
    @LogTypeKey nVarChar(35),   -- Key of log type or Null for all
    @PageSize   Int,            -- Number of items per page
    @PageIndex  Int             -- Page number starting with 0
AS
BEGIN
     WITH [eLog] AS (
         SELECT ROW_NUMBER() OVER (ORDER BY E.LogCreateDate Desc) AS RowNumber, e.*
          FROM dbo.dnn_vw_EventLog e
          WHERE (e.LogPortalID = @PortalID     OR IsNull(@PortalID,   -1) = -1)
            AND (e.LogTypeKey LIKE @LogTypeKey OR IsNull(@LogTypeKey, '') = '')
     )
     SELECT * FROM [eLog]
      WHERE RowNumber >= dbo.dnn_PageLowerBound(@PageIndex, @PageSize)
        AND RowNumber <= dbo.dnn_PageUpperBound(@PageIndex, @PageSize)
      ORDER BY RowNumber

    SELECT COUNT(1) AS TotalRecords
     FROM dbo.dnn_vw_EventLog e
     WHERE (e.LogPortalID = @PortalID     OR IsNull(@PortalID,   -1) = -1)
       AND (e.LogTypeKey Like @LogTypeKey OR IsNull(@LogTypeKey, '') = '')

END

