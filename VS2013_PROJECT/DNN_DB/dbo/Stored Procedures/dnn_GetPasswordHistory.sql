CREATE PROCEDURE [dbo].[dnn_GetPasswordHistory]
    @UserID			int
AS
        SELECT * from dbo.dnn_PasswordHistory where UserID=@UserID

