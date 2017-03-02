-- new function to return RoleID for Administrators of the Portal passed in as parameter
CREATE FUNCTION [dbo].[dnn_AdministratorRoleId](
    @PortalId	 		 Int -- Needs to be >= 0, otherwise false is returned
) 
	RETURNS 			 int
AS
	BEGIN
		DECLARE @adminRoleId int = 0
		SELECT  @adminRoleId = AdministratorRoleId FROM dbo.[dnn_Portals] WHERE PortalID = @PortalId
		RETURN  @adminRoleId
	END

