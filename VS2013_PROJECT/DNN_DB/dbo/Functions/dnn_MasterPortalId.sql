-- new helper function
CREATE FUNCTION [dbo].[dnn_MasterPortalId]
(
    @PortalId Int  -- ID of the portal or Null for Host
) 
	RETURNS   Int
AS
	BEGIN
		DECLARE @MasterPortalId  Int = Null
		IF IsNull(@PortalId, -1) >= 0
			SELECT @MasterPortalId = MasterPortalId FROM dbo.[dnn_vw_MasterPortals] WHERE PortalId = @PortalId
		RETURN @MasterPortalId
	END

