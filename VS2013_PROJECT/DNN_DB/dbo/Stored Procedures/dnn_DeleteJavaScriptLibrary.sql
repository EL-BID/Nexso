CREATE PROCEDURE [dbo].[dnn_DeleteJavaScriptLibrary]
	@JavaScriptLibraryID INT
AS
	DELETE FROM dbo.[dnn_JavaScriptLibraries]
	WHERE JavaScriptLibraryID = @JavaScriptLibraryID

