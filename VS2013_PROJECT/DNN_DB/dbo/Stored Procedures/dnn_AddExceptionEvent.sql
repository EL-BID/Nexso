CREATE PROCEDURE [dbo].[dnn_AddExceptionEvent]
  @LogEventID bigint,
  @AssemblyVersion varchar(20),
  @PortalId int,
  @UserId int,
  @TabId int,
  @RawUrl nvarchar(260),
  @Referrer nvarchar(260),
  @UserAgent nvarchar(260)
AS

INSERT INTO dbo.[dnn_ExceptionEvents]
	(LogEventID,
	AssemblyVersion,
	PortalId,
	UserId,
	TabId,
	RawUrl,
 Referrer,
 UserAgent)
VALUES
	(@LogEventID,
	@AssemblyVersion,
	@PortalId,
	@UserId,
	@TabId,
	@RawUrl,
 @Referrer,
 @UserAgent)

