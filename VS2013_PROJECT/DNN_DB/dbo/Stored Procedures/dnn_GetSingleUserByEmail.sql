CREATE PROCEDURE [dbo].[dnn_GetSingleUserByEmail]
    @PortalId INT,
	@Email nvarchar(255)
AS 
	SELECT ISNULL((SELECT TOP 1 U.UserId from dbo.[dnn_Users] U Inner Join dbo.[dnn_UserPortals] UP on UP.[UserId] = U.[UserId] Where U.Email = @Email and UP.[PortalId] = @PortalId), -1)

