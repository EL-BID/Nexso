CREATE VIEW [dbo].[dnn_vw_Users]
AS
	SELECT  U.UserId,
        UP.PortalId,
        U.Username,
        U.FirstName,
        U.LastName,
        U.DisplayName,
        U.IsSuperUser,
        U.Email,
        UP.VanityUrl,
        U.AffiliateId,
        IsNull(UP.IsDeleted, U.IsDeleted) AS IsDeleted,
        UP.RefreshRoles,
        U.LastIPAddress,
        U.UpdatePassword,
        U.PasswordResetToken,
        U.PasswordResetExpiration,
        UP.Authorised,
        U.CreatedByUserId,
        U.CreatedOnDate,
        U.LastModifiedByUserId,
        U.LastModifiedOnDate
	FROM       dbo.[dnn_Users]       AS U
		LEFT JOIN dbo.[dnn_UserPortals] AS UP 
			ON CASE WHEN U.IsSuperuser = 1 THEN 0 ELSE U.UserId END = UP.UserId

