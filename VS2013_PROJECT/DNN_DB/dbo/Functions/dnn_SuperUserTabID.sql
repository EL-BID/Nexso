CREATE FUNCTION [dbo].[dnn_SuperUserTabID]
() 
	RETURNS Int
AS
BEGIN
    DECLARE @HostTabId Int = Null
    SELECT  TOP (1) @HostTabId = TabID
		FROM  dbo.dnn_Tabs
		WHERE (PortalID IS NULL) AND (ParentId IS NULL)
		ORDER BY TabID
    RETURN @HostTabId
END

