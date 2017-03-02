CREATE PROCEDURE [dbo].[dnn_UpdateFileLastModificationTime]
	@FileId				  Int, 		-- Not Null
	@LastModificationTime DateTime  -- Null: Now
AS
BEGIN
    UPDATE dbo.[dnn_Files]
    SET    LastModificationTime = IsNull(@LastModificationTime, GetDate())
    WHERE  FileId = @FileId
END

