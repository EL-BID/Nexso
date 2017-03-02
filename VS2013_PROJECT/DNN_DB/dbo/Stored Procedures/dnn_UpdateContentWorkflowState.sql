CREATE PROCEDURE [dbo].[dnn_UpdateContentWorkflowState]
	@StateID int,
	@StateName nvarchar(40),
	@Order int,
	@IsActive bit,
	@SendEmail bit,
	@SendMessage bit,
	@IsDisposalState bit,
	@OnCompleteMessageSubject nvarchar(256),
	@OnCompleteMessageBody nvarchar(1024),
	@OnDiscardMessageSubject nvarchar(256),
	@OnDiscardMessageBody nvarchar(1024)
AS

UPDATE dbo.dnn_ContentWorkflowStates
SET [StateName] = @StateName,
	[Order] = @Order,
	[IsActive] = @IsActive,
	[SendEmail] = @SendEmail,
	[SendMessage] = @SendMessage,
	[IsDisposalState] = @IsDisposalState,
	[OnCompleteMessageSubject] = @OnCompleteMessageSubject,
	[OnCompleteMessageBody] = @OnCompleteMessageBody,
	[OnDiscardMessageSubject] = @OnDiscardMessageSubject,
	[OnDiscardMessageBody] = @OnDiscardMessageBody
WHERE  [StateID] = @StateID

