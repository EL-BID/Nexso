CREATE PROCEDURE [dbo].[dnn_Messaging_GetInbox]
	@PortalID int,
	@UserID int,
	@PageNumber int,
	@PageSize int
AS
	-- Set the page bounds
	DECLARE 
		@PageLowerBound INT, 
		@PageUpperBound INT, 
		@RowsToReturn int, 
		@PageIndex int

		/* this is 1-based rather than 0-based indexing. Accomodating so that we are consistent with paging */
		SET @PageIndex = @PageNumber - 1

		exec dbo.[dnn_CalculatePagingInformation] @PageIndex, @PageSize, @RowsToReturn output, @PageLowerBound output, @PageUpperBound output

		begin 
			with UserInbox as (
				select * , ROW_NUMBER() over (order by Date desc) as RowNumber
					from dbo.dnn_Messaging_Messages 
					where (ToUserID = @UserID AND Status IN (1,2) AND SkipPortal = '0') 
						OR (FromUserID = @UserID AND Status = 0)
			)
			select * from UserInbox
				where RowNumber > @PageLowerBound AND RowNumber < @PageUpperBound
				order by RowNumber
		end

