CREATE PROCEDURE [dbo].[dnn_DeleteTabSettings]
	@TabID      	INT

AS

	DELETE	FROM dbo.dnn_TabSettings 
	WHERE	TabID = @TabID

