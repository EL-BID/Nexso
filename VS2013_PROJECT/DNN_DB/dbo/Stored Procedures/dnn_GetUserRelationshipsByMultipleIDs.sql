CREATE PROCEDURE [dbo].[dnn_GetUserRelationshipsByMultipleIDs] 
	@UserID INT,
	@RelatedUserID INT,
	@RelationshipID INT,
	@Direction INT
AS 
	IF ( @Direction = 1 ) --OneWay
	  BEGIN
		SELECT  UserRelationshipID,
				UserID,
				RelatedUserID,
				RelationshipID,            
				Status,            
				CreatedByUserID ,
				CreatedOnDate ,
				LastModifiedByUserID ,
				LastModifiedOnDate
		FROM    dbo.dnn_UserRelationships    
		WHERE UserID = @UserID
		AND   RelatedUserID = @RelatedUserID
		AND   RelationshipID = @RelationshipID
		ORDER BY UserRelationshipID ASC    
	  END
	  ELSE IF ( @Direction = 2 ) --TwoWay
	  BEGIN
		SELECT  UserRelationshipID,
				UserID,
				RelatedUserID,
				RelationshipID,            
				Status,            
				CreatedByUserID ,
				CreatedOnDate ,
				LastModifiedByUserID ,
				LastModifiedOnDate
		FROM    dbo.dnn_UserRelationships    		
		WHERE (  (UserID = @UserID AND RelatedUserID = @RelatedUserID) 
			  OR (RelatedUserID = @UserID AND UserID = @RelatedUserID) --swap userids and check
			  )
		AND   RelationshipID = @RelationshipID
		ORDER BY UserRelationshipID ASC    
	  END

