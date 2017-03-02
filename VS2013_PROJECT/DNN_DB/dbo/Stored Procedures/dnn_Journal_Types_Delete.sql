CREATE PROCEDURE [dbo].[dnn_Journal_Types_Delete]
@JournalTypeId int,
@PortalId int
AS
IF @JournalTypeId > 200
	BEGIN
		DELETE FROM dbo.[dnn_Journal_Security]
		WHERE JournalId IN (SELECT JournalId FROM dbo.[dnn_Journal] WHERE JournalTypeId=@JournalTypeId AND PortalId=@PortalId)
		DELETE FROM dbo.[dnn_Journal]
		WHERE 
			JournalTypeId = @JournalTypeId 
			AND 
			PortalId = @PortalId
		DELETE FROM dbo.[dnn_Journal_TypeFilters]
		WHERE
			JournalTypeId = @JournalTypeId
			AND 
			PortalId = @PortalId
		DELETE FROM dbo.[dnn_Journal_Types]
		WHERE 
			JournalTypeId = @JournalTypeId
			AND
			PortalId = @PortalId
	END

