CREATE PROCEDURE [dbo].[dnn_Mobile_SavePreviewProfile]
    @Id INT ,
    @PortalId INT ,
    @Name NVARCHAR(50) ,
    @Width INT ,
    @Height INT ,
	@UserAgent NVARCHAR(260) ,
	@SortOrder INT ,
    @UserId INT
AS 
    IF ( @Id = -1 ) 
        BEGIN
            INSERT  dbo.dnn_Mobile_PreviewProfiles
                    ( PortalId ,
                      Name ,
                      Width ,
                      Height ,
					  UserAgent ,
					  SortOrder ,
                      CreatedByUserID ,
                      CreatedOnDate ,
                      LastModifiedByUserID ,
                      LastModifiedOnDate
			        
                    )
            VALUES  ( @PortalId , -- PortalId - int
                      @Name , -- Name - nvarchar(50)
                      @Width , -- Width - int
                      @Height , -- Height - int
					  @UserAgent ,
					  @SortOrder ,
                      @UserId , -- CreatedBy - int
                      GETDATE() , -- CreatedOn - datetime
                      @UserId , -- LastModifiedBy - int
                      GETDATE() -- LastModifiedOn - datetime
			        
                    )
                    
            SELECT  @Id = SCOPE_IDENTITY()
        END
    ELSE 
        BEGIN
            UPDATE  dbo.dnn_Mobile_PreviewProfiles
            SET     Name = @Name ,
                    Width = @Width ,
                    Height = @Height ,
					UserAgent = @UserAgent ,
					SortOrder = @SortOrder ,
                    LastModifiedByUserID = @UserId ,
                    LastModifiedOnDate = GETDATE()
            WHERE   Id = @Id
        END
        
    SELECT  @Id

