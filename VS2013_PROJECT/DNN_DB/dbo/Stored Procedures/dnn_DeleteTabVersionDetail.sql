CREATE PROCEDURE [dbo].[dnn_DeleteTabVersionDetail]
    @Id INT
AS
BEGIN
    DELETE FROM dbo.[dnn_TabVersionDetails] WHERE TabVersionDetailId = @Id
END

