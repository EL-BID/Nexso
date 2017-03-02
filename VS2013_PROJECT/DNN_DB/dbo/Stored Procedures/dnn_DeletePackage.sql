CREATE PROCEDURE [dbo].[dnn_DeletePackage]
	@PackageID		int
AS
	DELETE 
		FROM   dbo.dnn_Packages
		WHERE  [PackageID] = @PackageID

