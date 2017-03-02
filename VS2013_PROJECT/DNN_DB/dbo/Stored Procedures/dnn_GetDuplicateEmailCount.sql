CREATE PROCEDURE [dbo].[dnn_GetDuplicateEmailCount]
    @PortalId INT
AS 
	SELECT ISNULL((SELECT COUNT(*) TotalCount FROM dbo.[dnn_Users] U Inner Join dbo.[dnn_UserPortals] UP on UP.[UserId] = U.[UserId] WHERE UP.PortalId = @PortalId  GROUP BY U.[Email] HAVING COUNT(*) > 1), 0)

