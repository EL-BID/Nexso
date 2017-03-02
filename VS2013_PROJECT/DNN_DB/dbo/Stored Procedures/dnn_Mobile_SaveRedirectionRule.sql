CREATE PROC [dbo].[dnn_Mobile_SaveRedirectionRule]
    @Id INT ,
    @RedirectionId INT ,
    @Capbility NVARCHAR(50) ,
    @Expression NVARCHAR(50)
AS 
    IF @Id = -1 
        BEGIN
            INSERT  INTO dbo.dnn_Mobile_RedirectionRules
                    ( RedirectionId ,
                      Capability ,
                      Expression
		        )
            VALUES  ( @RedirectionId , -- RedirectionId - int
                      @Capbility , -- Capability - nvarchar(50)
                      @Expression  -- Expression - nvarchar(50)
		        )
        END
    ELSE 
        BEGIN
            UPDATE  dbo.dnn_Mobile_RedirectionRules
            SET     Capability = @Capbility ,
                    Expression = @Expression
            WHERE   Id = @Id
        END

