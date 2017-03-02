CREATE PROCEDURE [dbo].[dnn_UnRegisterAssembly]
	@PackageID     INT,
	@AssemblyName   NVARCHAR(250)
AS
	DECLARE @ReturnCode BIT
	SET @ReturnCode = 1 -- 1 = Can Delete Assembly, 0 = Cannot Delete Assembly

	-- First remove the Assembly Reference for this Package
	DELETE FROM dbo.dnn_Assemblies
		WHERE PackageID = @PackageID
			AND AssemblyName = @AssemblyName

	IF EXISTS(SELECT TOP 1 PackageID FROM dbo.dnn_Assemblies WHERE AssemblyName = @AssemblyName)
		-- Set ReturnCode = 0, so assembly is not deleted
		SET @ReturnCode = 0

	SELECT @ReturnCode

