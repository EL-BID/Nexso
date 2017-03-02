CREATE PROCEDURE [dbo].[dnn_UpdateContentWorkflow]
@WorkflowID int,
@WorkflowName nvarchar(40),
@Description nvarchar(256),
@IsDeleted bit,
@StartAfterCreating bit,
@StartAfterEditing bit,
@DispositionEnabled bit
AS

UPDATE dbo.dnn_ContentWorkflows
SET    WorkflowName = @WorkflowName,
       Description = @Description,
       IsDeleted = @IsDeleted,
	   StartAfterCreating = @StartAfterCreating,
	   StartAfterEditing = @StartAfterEditing,
	   DispositionEnabled = @DispositionEnabled
WHERE  WorkflowID = @WorkflowID

