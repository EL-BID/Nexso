CREATE PROCEDURE [dbo].[dnn_UpdateFileHashCode]
	@FileId				  Int, 		-- Not Null
	@HashCode VARCHAR(40)  -- Not NULL
AS
BEGIN
    UPDATE dbo.[dnn_Files]
    SET    SHA1Hash = @HashCode
    WHERE  FileId = @FileId
END

