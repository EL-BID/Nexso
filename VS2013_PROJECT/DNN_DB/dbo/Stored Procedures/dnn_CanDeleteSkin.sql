CREATE PROCEDURE [dbo].[dnn_CanDeleteSkin]
	@SkinType char(1),
	@SkinFolderName nvarchar(200) 
AS
	BEGIN
		IF exists(SELECT * FROM dbo.dnn_Tabs WHERE (SkinSrc like '%![' + @SkinType + '!]' + @SkinFolderName + '%' ESCAPE '!') 
					OR (ContainerSrc like '%![' + @SkinType + '!]' + @SkinFolderName + '%' ESCAPE '!'))
			SELECT 0
		ELSE
			BEGIN
				IF exists(SELECT * FROM dbo.dnn_TabModules WHERE ContainerSrc like '%![' + @SkinType + '!]' + @SkinFolderName + '%' ESCAPE '!')
					SELECT 0
				ELSE
					SELECT 1
			END
	END

