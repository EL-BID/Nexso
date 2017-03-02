CREATE PROCEDURE [dbo].[dnn_MoveTabModule]
	@FromTabId				int,
	@ModuleId				int,
	@ToTabId				int,
	@PaneName				nvarchar(50),
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_TabModules
		SET 
			TabId = @ToTabId,   
			ModuleOrder = -1,
			PaneName = @PaneName,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate()
		WHERE  TabId = @FromTabId
		AND    ModuleId = @ModuleId

