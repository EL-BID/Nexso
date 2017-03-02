CREATE PROCEDURE [dbo].[dnn_GetTabPaths] 
	@PortalID		int,
	@CultureCode	nvarchar(10)
AS
	SELECT
		TabID, 
		PortalID, 
		TabPath
	FROM dbo.dnn_vw_Tabs
	WHERE (PortalID = @PortalID AND (CultureCode = @CultureCode OR CultureCode Is Null))
		OR @PortalID Is NULL

