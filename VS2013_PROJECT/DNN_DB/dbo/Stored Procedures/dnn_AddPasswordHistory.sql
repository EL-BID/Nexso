CREATE PROCEDURE [dbo].[dnn_AddPasswordHistory]
    @UserId			int,
    @Password			nvarchar(128),
    @PasswordSalt		nvarchar(128),
	@Retained			int,
    @CreatedByUserID  	int
AS

        BEGIN
		
          INSERT INTO dbo.dnn_PasswordHistory (
            UserId,
            [Password],
            PasswordSalt,
			CreatedByUserID,
			CreatedOnDate,
			LastModifiedByUserID,
			LastModifiedOnDate
          )
          VALUES (
            @UserId,
            @Password,
            @PasswordSalt,
            
			@CreatedByUserID,
			getdate(),
			@CreatedByUserID,
			getdate()
          )

		  DELETE FROM dbo.dnn_PasswordHistory where UserID=@UserId and PasswordHistoryID NOT IN (
					SELECT TOP (@Retained) PasswordHistoryID from dbo.dnn_PasswordHistory
					WHERE UserID=@UserId order by CreatedOnDate desc
					)

        END

