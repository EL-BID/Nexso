/* Feedback_GetFeedbackByCategory */

CREATE PROCEDURE [dbo].[dnn_Feedback_GetFeedbackByCategory]		
    	@PortalID int,
    	@ModuleID int,
	@CategoryID nvarchar(256),
	@Status int,
	@CurrentPage int,
	@PageSize int,
	@OrderBy nvarchar(25)
 
AS

BEGIN

    DECLARE	
	@FirstRow int,
	@LastRow int,
	@TotalRecords int

    SELECT	
	@FirstRow = (@CurrentPage - 1) * @PageSize + 1,
	@LastRow = (@CurrentPage - 1) * @PageSize + @PageSize;
	
    WITH CategoryFeedback AS (

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
	ROW_NUMBER() OVER (ORDER BY
	        CASE @OrderBy WHEN N'CreatedOnDate DESC' THEN CreatedOnDate END DESC
	       ,CASE @OrderBy WHEN N'CreatedOnDate' THEN CreatedOnDate END) AS RowNumber,
    Referrer,
    UserAgent,
    ContextKey
	FROM dbo.dnn_Feedback f
	     LEFT OUTER JOIN dbo.[dnn_FeedbackList] fs ON f.[Subject] = convert(nvarchar, fs.ListID)
	     LEFT OUTER JOIN dbo.[dnn_FeedbackList] fc ON f.[CategoryID] = convert(nvarchar, fc.ListID)
	WHERE (f.PortalID = @PortalID) and ((@ModuleID is null) or (f.ModuleID = @ModuleID))
	          and ((@CategoryID='') or (charindex(rtrim(CategoryID),@CategoryID,1) > 0)) and (Status = @Status) 
)

SELECT
   *,
   (select count(*) from CategoryFeedback) as TotalRecords
   FROM CategoryFeedback
   WHERE RowNumber Between @FirstRow and @LastRow
END
