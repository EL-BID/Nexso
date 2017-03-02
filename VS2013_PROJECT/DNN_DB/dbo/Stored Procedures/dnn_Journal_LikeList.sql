CREATE PROCEDURE [dbo].[dnn_Journal_LikeList]
@PortalId int,
@JournalId int
AS
DECLARE @xdoc xml
set @xdoc = (SELECT journalxml.query('//likes') 
				from dbo.[dnn_Journal_Data] as jd
				INNER JOIN dbo.[dnn_Journal] as j ON j.JournalId = jd.JournalId
				 WHERE j.JournalId = @JournalId AND j.PortalId = @PortalId)
Select u.UserId, u.DisplayName,u.FirstName,u.LastName,u.Email,u.Username 
	FROM @xdoc.nodes('/likes//u') as e(x) 
CROSS APPLY dbo.[dnn_Users] as u
WHERE u.UserID = x.value('@uid[1]','int')

