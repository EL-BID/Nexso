CREATE VIEW [dbo].[dnn_vw_Profile]
AS
	SELECT     
		UP.UserID, 
		PD.PortalID, 
		PD.PropertyName, 
		CASE WHEN PropertyText IS NULL THEN PropertyValue ELSE PropertyText END AS PropertyValue, 
		UP.Visibility,
		UP.ExtendedVisibility,
		UP.LastUpdatedDate,
		PD.PropertyDefinitionID
	FROM dbo.[dnn_UserProfile] AS UP 
		INNER JOIN dbo.[dnn_ProfilePropertyDefinition] AS PD ON PD.PropertyDefinitionID = UP.PropertyDefinitionID

