CREATE PROCEDURE [dbo].[dnn_GetUserCountByPortal]
 @PortalId int
AS
begin
 SELECT count(*)
 FROM dbo.dnn_UserPortals AS UP
 WHERE UP.IsDeleted = 0 AND UP.PortalID = @PortalID
end

