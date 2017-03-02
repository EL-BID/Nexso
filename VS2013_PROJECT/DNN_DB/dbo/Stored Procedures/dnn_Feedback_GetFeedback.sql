/* Feedback_GetFeedback */

CREATE PROCEDURE [dbo].[dnn_Feedback_GetFeedback]
	@FeedbackID int

AS
	SELECT
		FeedbackID,
		f.ModuleID,
		f.PortalID,
		[Status],
		f.CategoryID,
		fc.Name As [CategoryName],
		fc.ListValue As [CategoryValue],
		CASE WHEN fs.ListID IS null THEN
		   f.[Subject]
		ELSE
		   fs.ListValue
		END As [Subject],
		[Message],
		SenderEmail,
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
		LastModifiedOnDate,
		LastModifiedByUserID,
		PublishedOnDate,
		ApprovedBy,
		TotalRecords = 1,
        Referrer,
        UserAgent,
        ContextKey
	FROM dbo.[dnn_Feedback] f
	     LEFT OUTER JOIN dbo.[dnn_FeedbackList] fs ON f.[Subject] = convert(nvarchar, fs.ListID)
		 LEFT OUTER JOIN dbo.[dnn_FeedbackList] fc ON f.[CategoryID] = convert(nvarchar, fc.ListID)
	WHERE  FeedbackID = @FeedbackID
