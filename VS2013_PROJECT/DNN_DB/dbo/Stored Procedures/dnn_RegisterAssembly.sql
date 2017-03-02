CREATE procedure [dbo].[dnn_RegisterAssembly]
	@PackageID      int,
	@AssemblyName   nvarchar(250),
	@Version		nvarchar(20)
As
	DECLARE @AssemblyID int
	DECLARE @CurrentVersion nvarchar(20)
	/*	@ReturnCode Values
		0 - Assembly Does not Exist
		1 - Older Version of Assembly Exists
		2 - Assembly Already Registered - Version = CurrentVersion
		3 - Assembly Already Registered - Version < CurrentVersion
	*/
	DECLARE @CompareVersion int

	-- First check if this assembly is registered to this package
	SET @AssemblyID = (SELECT AssemblyID 
							FROM dbo.dnn_Assemblies
							WHERE PackageID = @PAckageID
								AND AssemblyName = @AssemblyName)

	IF @AssemblyID IS NULL
		BEGIN
			-- AssemblyID is null (not registered) 
			-- but assembly may be registerd by other packages so check for Max unstalled version
			SET @CurrentVersion  = (SELECT Max(Version )
										FROM dbo.dnn_Assemblies
										WHERE AssemblyName = @AssemblyName)

			SET @CompareVersion = dbo.dnn_fn_CompareVersion(@Version, @CurrentVersion)
			
			-- Add an assembly regsitration for this package
			INSERT INTO dbo.dnn_Assemblies (
				PackageID,
				AssemblyName,
				Version
			)
			VALUES (
				@PackageID,
				@AssemblyName,
				@Version
			)
		END
	ELSE
		BEGIN
			-- AssemblyID is not null - Assembly is registered - test for version
			SET @CurrentVersion  = (SELECT Version 
										FROM dbo.dnn_Assemblies
										WHERE AssemblyID = @AssemblyID)
			
			SET @CompareVersion = dbo.dnn_fn_CompareVersion(@Version, @CurrentVersion)
			
			IF @CompareVersion = 1
				BEGIN
					-- Newer version - Update Assembly registration
					UPDATE dbo.dnn_Assemblies
					SET    Version = @Version
					WHERE  AssemblyID = @AssemblyID
				END
		END

	SELECT @CompareVersion

