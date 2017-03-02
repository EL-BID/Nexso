BEGIN TRAN T1;

BEGIN TRY

	update dnn_Users 
		set FirstName ='Paco',
			LastName='Stanley',
			DisplayName='Paco Stanley'

	update aspnet_Membership
		set [Password]='/BnPNyPOtDFM1C58IaC/SkjyIEpUws9k/M50ooBawLj7CoMY+2Fjxg==',
			PasswordSalt='mfZuXWZJtSFzk96VyubN3A==',
			PasswordFormat=2

	COMMIT TRAN T1;
END TRY

BEGIN CATCH
	ROLLBACK TRAN T1;
END CATCH

