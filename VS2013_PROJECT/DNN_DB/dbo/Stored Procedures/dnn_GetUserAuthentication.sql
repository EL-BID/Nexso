CREATE PROCEDURE [dbo].[dnn_GetUserAuthentication]
  @UserID          int

AS
  select * from dbo.dnn_UserAuthentication
     where UserId = @UserID

