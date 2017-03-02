CREATE VIEW [dbo].[dnn_vw_MessagesForDispatch]
AS
	SELECT CMR.RecipientID
	,CMR.MessageID
	,CMR.UserID
	,CMR.[Read]
	,CMR.Archived
	,CMR.EmailSent
	,CMR.EmailSentDate
	,CMR.EmailSchedulerInstance
	,CMR.CreatedByUserID
	,CMR.CreatedOnDate
	,CMR.LastModifiedByUserID
	,CMR.LastModifiedOnDate
	,CMR.SendToast
	,CM.NotificationTypeID	
    ,CASE 
		WHEN CM.NotificationTypeID IS NULL		
		THEN				
			ISNULL ((SELECT UP.[MessagesEmailFrequency] AS Expr1
					FROM          dbo.dnn_CoreMessaging_UserPreferences UP
					WHERE      (UP.UserId = CMR.UserID) AND (UP.PortalId = CM.PortalID)), 0)
		ELSE			
			ISNULL ((SELECT UP.[NotificationsEmailFrequency] AS Expr1
					FROM          dbo.dnn_CoreMessaging_UserPreferences UP
					WHERE      (UP.UserId = CMR.UserID) AND (UP.PortalId = CM.PortalID)), 2)
	END EmailFrequency
FROM dbo.dnn_CoreMessaging_MessageRecipients AS CMR 
	INNER JOIN
    dbo.dnn_CoreMessaging_Messages AS CM 
		ON CMR.MessageID = CM.MessageID

