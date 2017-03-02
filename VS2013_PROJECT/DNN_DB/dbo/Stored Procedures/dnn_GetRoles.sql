CREATE PROCEDURE [dbo].[dnn_GetRoles]
AS
BEGIN
    SELECT R.*,
          (SELECT COUNT(*) FROM dbo.[dnn_UserRoles] U WHERE U.RoleID = R.RoleID) AS UserCount
     FROM dbo.[dnn_Roles] AS R
     WHERE RoleID >= 0 -- ignore virtual roles. Note: might be removed, after controller has been adjusted
END

