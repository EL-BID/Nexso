-- new helper function
CREATE FUNCTION [dbo].[dnn_UserIsInRole]
(
	@UserId Int,
	@RoleId Int
)
RETURNS 	Bit
AS
	BEGIN
		RETURN CASE WHEN EXISTS (SELECT * FROM dbo.[dnn_UserRoles] WHERE UserID = @UserId AND RoleID = @RoleId 
														   AND IsNull(EffectiveDate, GetDate()) >= GetDate() 
														   AND IsNull(ExpiryDate, GetDate())    <= GetDate()) THEN 1 ELSE 0 END
	END

