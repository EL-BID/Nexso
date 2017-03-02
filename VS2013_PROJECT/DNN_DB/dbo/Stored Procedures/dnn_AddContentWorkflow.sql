CREATE PROCEDURE [dbo].[dnn_AddContentWorkflow]
@PortalID int,
@WorkflowName nvarchar(40),
@Description nvarchar(256),
@IsDeleted bit,
@StartAfterCreating bit,
@StartAfterEditing bit,
@DispositionEnabled bit
AS

INSERT INTO dbo.dnn_ContentWorkflows (
  [PortalID],
  [WorkflowName],
  [Description],
  [IsDeleted],
  [StartAfterCreating],
  [StartAfterEditing],
  [DispositionEnabled]
)
VALUES (
  @PortalID,
  @WorkflowName,
  @Description,
  @IsDeleted,
  @StartAfterCreating,
  @StartAfterEditing,
  @DispositionEnabled
)

SELECT SCOPE_IDENTITY()

