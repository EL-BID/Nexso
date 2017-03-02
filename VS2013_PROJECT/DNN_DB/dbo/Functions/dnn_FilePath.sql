CREATE FUNCTION [dbo].[dnn_FilePath]
(
    @StrMayContainFileId nVarChar(255)
)
	RETURNS 			 nVarChar(500)
AS
	BEGIN
		DECLARE @Path AS nVarChar(500);

		IF ISNULL(@StrMayContainFileId,'') = ''
			SET @Path = ''
		 ELSE IF Lower(@StrMayContainFileId) LIKE 'fileid=%'
			SELECT @Path = IsNull(Folder, '') + FileName FROM dbo.[dnn_vw_Files]
			 WHERE fileid = CAST(SUBSTRING(@StrMayContainFileId, 8, 10) AS Int)
		 ELSE
			SET @Path = @StrMayContainFileId
		RETURN @Path -- never Null!
	END

