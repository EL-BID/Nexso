CREATE PROCEDURE [dbo].[dnn_DeleteUserRelationshipPreference]
	@PreferenceID INT	
AS 
	BEGIN
		DELETE FROM dbo.dnn_UserRelationshipPreferences  
		WHERE PreferenceID = @PreferenceID

	END

