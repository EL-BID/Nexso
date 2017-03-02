-- new helper function, returning Displayname for a userid
CREATE FUNCTION [dbo].[dnn_UserDisplayName]
(
	@userId Int
)
RETURNS 
	nVarChar(255)
AS
	BEGIN
		DECLARE @DisplayName AS nVarChar(255)

		SELECT  @DisplayName = DisplayName FROM dbo.[dnn_Users] WHERE UserID = @UserId
		RETURN  @DisplayName
	END

