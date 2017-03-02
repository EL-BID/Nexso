CREATE PROCEDURE [dbo].[dnn_SavePackageDependency]
	@PackageDependencyID INT,
	@PackageID INT,
	@PackageName NVARCHAR(128),
	@Version NVARCHAR(50)
AS
	IF EXISTS (SELECT PackageDependencyID FROM dnn_PackageDependencies WHERE PackageID = @PackageID AND PackageName = @PackageName AND Version = @Version)
		BEGIN
			UPDATE dbo.[dnn_PackageDependencies]
			   SET [PackageID] = @PackageID,
					[PackageName] = @PackageName,
					[Version] = @Version
			 WHERE PackageDependencyID = @PackageDependencyID
		END
	ELSE
		BEGIN
			INSERT INTO dbo.[dnn_PackageDependencies] (
				[PackageID],
				[PackageName],
				[Version]
			)
			VALUES (
				@PackageID,
				@PackageName,
				@Version
			)
			SET @PackageDependencyID = (SELECT @@IDENTITY)
		END

	SELECT @PackageDependencyID
