CREATE PROCEDURE [dbo].[dnn_GetPortalSpaceUsed]
	@PortalId INT     -- Null|-1: Host files
AS
	BEGIN
		SELECT SUM(CAST(Size as bigint)) AS SpaceUsed
		FROM dbo.dnn_Files
		WHERE (IsNull(PortalID, -1) = IsNull(@PortalId, -1))
	END

