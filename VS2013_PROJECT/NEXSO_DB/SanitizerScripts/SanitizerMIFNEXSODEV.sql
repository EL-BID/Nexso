BEGIN TRAN T1;

BEGIN TRY
	
	update Documents
		set DocumentObject=0x111111
	
	update UserProperties
		set FirstName='Paco',
			LastName='Stanley'
	update PotentialUsers
		set Email='paco.stanley@dogy.com'
	
	update Messages
		set Message='Quat, purus odio aliquet nisl, et porttitor nisi libero at sem. Proin nec convallis leo. Ut nec dictum metus. Suspendisse nec ligula ut lacus scele.'		
	
	

	COMMIT TRAN T1;
END TRY
BEGIN CATCH
	ROLLBACK TRAN T1;
END CATCH