CREATE PROCEDURE [dbo].[dnn_AddContentWorkflowLog]
	@Action nvarchar(40),
	@Comment nvarchar(256),
	@User int,
	@WorkflowID int,
	@ContentItemID int
AS
    INSERT INTO dbo.[dnn_ContentWorkflowLogs] (
		[Action],
		[Comment],
		[Date],
		[User],
		[WorkflowID],
		[ContentItemID]
	) VALUES (
		@Action,
		@Comment,
		getdate(),
		@User,
		@WorkflowID,
		@ContentItemID
	)

	SELECT SCOPE_IDENTITY()

