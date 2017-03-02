CREATE PROCEDURE [dbo].[dnn_DeleteTabVersion]
    @Id INT
AS
BEGIN
    DELETE FROM dbo.[dnn_TabVersions] WHERE TabVersionId = @Id
END

