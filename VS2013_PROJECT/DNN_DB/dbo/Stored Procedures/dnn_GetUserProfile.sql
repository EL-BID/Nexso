CREATE PROC [dbo].[dnn_GetUserProfile] 
	@UserID int
AS
	SELECT
		ProfileID,
		UserID,
		PropertyDefinitionID,
		CASE WHEN (PropertyValue Is Null) THEN PropertyText ELSE PropertyValue END AS 'PropertyValue',
		Visibility,
		ExtendedVisibility,
		LastUpdatedDate
	FROM	dbo.dnn_UserProfile
	WHERE   UserId = @UserID

