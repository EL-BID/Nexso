CREATE PROCEDURE [dbo].[dnn_AddContentWorkflowSource]
	@WorkflowID INT,
    @SourceName NVARCHAR(20),
    @SourceType NVARCHAR(250)
AS
    INSERT INTO  dbo.dnn_ContentWorkflowSources(
		[WorkflowID],
		[SourceName],
		[SourceType])
    VALUES(
        @WorkflowID,
        @SourceName,
        @SourceType
    )

    SELECT SCOPE_IDENTITY()

