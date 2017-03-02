/***  Feedback_CreateFeedback  ***/

CREATE PROCEDURE [dbo].[dnn_Feedback_CreateFeedback]
	@PortalID int,
	@ModuleID int, 
	@CategoryID nvarchar(100), 
	@SenderEmail nvarchar(256), 
	@Status int,
	@Message nvarchar(MAX),
	@Subject nvarchar(200),
	@SenderName nvarchar(200),
	@SenderStreet nvarchar(50),
	@SenderCity nvarchar(50),
	@SenderRegion nvarchar(50),
	@SenderCountry nvarchar(50),
	@SenderPostalCode nvarchar(50),
	@SenderTelephone nvarchar(20),
	@SenderRemoteAddr nvarchar(50),
	@UserId int,
    @Referrer nvarchar(255),
    @UserAgent nvarchar(255),
    @ContextKey nvarchar(200)
AS

DECLARE @PublishedOnDate datetime

IF (@Status = 2) SET @PublishedOnDate = getutcdate()
 

INSERT INTO dbo.[dnn_Feedback] (
	PortalID,
	ModuleID,
	CategoryID, 
	SenderEmail,
	PublishedOnDate,
	[Status],
	[Message],
	[Subject],
	SenderName,
	SenderStreet,
	SenderCity,
	SenderRegion,
	SenderCountry,
	SenderPostalCode,
	SenderTelephone,
	SenderRemoteAddr,
	CreatedOnDate,
	CreatedByUserID,
    Referrer,
    UserAgent,
    ContextKey
) 
VALUES (
	@PortalID,
	@ModuleID,
	@CategoryID, 
	@SenderEmail, 
	@PublishedOnDate,
	@Status,
	@Message,
	@Subject,
	@SenderName,
	@SenderStreet,
	@SenderCity,
	@SenderRegion,
	@SenderCountry,
	@SenderPostalCode,
	@SenderTelephone,
	@SenderRemoteAddr,
	getutcdate(),
	@UserId,
    @Referrer,
    @UserAgent,
    @ContextKey
)

SELECT SCOPE_IDENTITY()
