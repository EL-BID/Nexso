CREATE PROCEDURE [dbo].[dnn_SaveUserRelationship]
    @UserRelationshipID INT,
	@UserID INT,
	@RelatedUserID INT,
	@RelationshipID INT,
	@Status INT,
	@CreateUpdateUserID INT
    
AS 
    IF ( @UserRelationshipID = -1 ) 
        BEGIN
            INSERT  dbo.dnn_UserRelationships
                    ( UserID,
					  RelatedUserID,					
					  RelationshipID,
					  Status,
                      CreatedByUserID ,
                      CreatedOnDate ,
                      LastModifiedByUserID ,
                      LastModifiedOnDate
			        
                    )
            VALUES  ( @UserID , -- @UserID int
					  @RelatedUserID , -- @RelatedUserlID int
					  @RelationshipID, -- @RelationshipID int
					  @Status , -- @Status int
                      @CreateUpdateUserID , -- CreatedBy - int
                      GETDATE() , -- CreatedOn - datetime
                      @CreateUpdateUserID , -- LastModifiedBy - int
                      GETDATE() -- LastModifiedOn - datetime
			        
                    )
                    
            SELECT  @UserRelationshipID = SCOPE_IDENTITY()
        END
    ELSE 
        BEGIN
            UPDATE  dbo.dnn_UserRelationships
            SET     UserID = @UserID,
					RelatedUserID = @RelatedUserID,
					RelationshipID = @RelationshipID,
					Status = @Status,
                    LastModifiedByUserID = @CreateUpdateUserID,
                    LastModifiedOnDate = GETDATE()
            WHERE   UserRelationshipID = @UserRelationshipID
        END
        
    SELECT  @UserRelationshipID

