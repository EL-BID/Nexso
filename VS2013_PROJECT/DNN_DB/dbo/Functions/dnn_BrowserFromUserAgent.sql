CREATE FUNCTION [dbo].[dnn_BrowserFromUserAgent]
	(@UserAgent nVarChar(2000))
RETURNS nVarChar(2000)
AS
BEGIN
	DECLARE @ident1		 nVarChar( 20) = '';
	DECLARE @ident2		 nVarChar( 20) = '';
	DECLARE @Browser     nVarChar(100) = '';
	DECLARE @Version	 nVarChar( 10) = '';
	DECLARE @Pos         Smallint = -1;
	DECLARE @End		 Smallint =  0;
	
	-- Detect Browser family (Name|Version Prefix):
	SET @Browser =	CASE
		WHEN @UserAgent LIKE '%Opera Mini/%'	THEN 'Opera Mini|Opera Mini/|Version/'
		WHEN @UserAgent LIKE '%Opera Mobi/%'	THEN 'Opera Mobile|Version/|Opera Mobi/'
		WHEN @UserAgent LIKE '%Opera/%'			THEN 'Opera|Version/|Opera/'
		WHEN @UserAgent LIKE '%Opera %'			THEN 'Opera|Opera '
		WHEN @UserAgent LIKE '%Opera'			THEN 'Opera|Opera'
		WHEN @UserAgent LIKE '%Firefox/%'		THEN 'Mozilla Firefox|Firefox/'
		WHEN @UserAgent LIKE '%Firebird/%'		THEN 'Mozilla Firebird|Firebird/'
		WHEN @UserAgent LIKE '%SeaMonkey/%'		THEN 'Mozilla SeaMonkey|SeaMonkey/'
		WHEN @UserAgent LIKE '%Kindle/%'		THEN 'Amazon Kindle|Kindle/'
		WHEN @UserAgent LIKE '%Kindle %'		THEN 'Amazon Kindle|Version/'
		WHEN @UserAgent LIKE '%Silk/%'			THEN 'Amazon Kindle|Version/'
		WHEN @UserAgent LIKE '%Chrome/%'		THEN 'Google Chrome|Chrome/'
		WHEN @UserAgent Like '%Blackberry'		THEN 'Blackberry|Mobile Safari/'
		WHEN @UserAgent LIKE '%Android%' 		THEN 'Android|Mobile Safari/'
		WHEN @UserAgent LIKE '%Safari/%'		THEN 'Apple Safari|Safari/'
		WHEN @UserAgent LIKE '%ChromePlus/%'	THEN 'ChromePlus|ChromePlus/'
		WHEN @UserAgent LIKE '%AOL %'			THEN 'AOL Browser|AOL '
		WHEN @USerAgent LIKE '%Crazy Browser %' THEN 'Crazy Browser|Crazy Browser '
		WHEN @USerAgent LIKE '%Maxthon/%'		THEN 'Maxthon|Maxthon/'
		WHEN @USerAgent LIKE '%IEMobile %'		THEN 'IE Mobile|IEMobile '
		WHEN @USerAgent LIKE '%IEMobile/%'		THEN 'IE Mobile|IEMobile/'
		WHEN @UserAgent LIKE '%MSIE %'      	THEN 'Internet Explorer|MSIE '
		WHEN @UserAgent LIKE '%(IE %'      		THEN 'Internet Explorer|(IE '
		WHEN @UserAgent LIKE '%Netscape/%' 		THEN 'Netscape Navigator|Netscape/'
		WHEN @UserAgent LIKE '%Navigator/%'		THEN 'Netscape Navigator|Navigator/'
		WHEN @UserAgent LIKE '%PLAYSTATION %' 	THEN 'Sony Playstation|PLAYSTATION '
		WHEN @UserAgent LIKE '%WGet/%'			THEN 'WGet|WGet/'
	END
	IF @Browser <> '' -- separate elements:
		SET @Pos = CharIndex('|', @Browser)
		IF @Pos > 0 BEGIN	
			SET @ident1  = SubString(@Browser, @Pos + 1, 100)
			SET @Browser = Left(@Browser, @Pos - 1)
			SET @Pos     = CharIndex('|', @ident1)
			IF  @Pos > 0 BEGIN
				SET @Ident2 = SubString(@Ident1, @Pos + 1, 100)
				SET @Ident1 = Left(@Ident1, @Pos - 1)
			END 
			-- get major version number from UserAgent string:
			SET @Pos = CharIndex(@ident1, @UserAgent) + Len(@ident1 + '|') - 1 -- correct to catch trailing space
			IF @Pos = 0 SET @Pos = CharIndex(@ident2, @UserAgent) + Len(@ident2 + '|') - 1 -- again
			IF @Pos > 0 BEGIN
				WHILE SubString(@UserAgent, @Pos + @End, 1) >= '0' AND SubString(@UserAgent, @Pos + @End, 1) <= 9
					SET @End = @End + 1
				IF @End > 0 SET @Version = SubString(@UserAgent, @Pos, @End)
			END
		END
	ELSE -- Search bots, ignore version
		SET @Browser = CASE 
		WHEN @UserAgent LIKE '%GoogleBot%'		THEN 'Google Bot'
		WHEN @UserAgent LIKE 'BingBot%'			THEN 'Bing Bot'
		WHEN @UserAgent LIKE 'MSNBot%'			THEN 'MSN Bot'
		WHEN @UserAgent LIKE '%BaiduSpider%'	THEN 'Baidu Spider'
		WHEN @UserAgent LIKE '%Arachmo%'		THEN 'Arachmo Bot'
		WHEN @UserAgent LIKE '%NewsGator%'		THEN 'NewsGator Bot'
		WHEN @UserAgent LIKE '%Seekbot%'		THEN 'SeekPort Bot'
		WHEN @UserAgent LIKE '%Yahoo%'			THEN 'Yahoo Bot'
		WHEN @UserAgent LIKE '%Yandex%'			THEN 'Yandex Bot'
		WHEN @UserAgent LIKE '%Bot%'			THEN 'Other Bot'
		ELSE 'Other'
	END
	RETURN RTRIM(@Browser + ' ' + @Version)
END

