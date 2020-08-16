Feature: client.api: Signup with No info
	
	@notAllowedForProd
	@after-removeDeviceIdFromDynamoDB
	Scenario: Do Signup with No info
		Given I launch application
		Given I clean extra tables data
		Given I do alternative login for active user
		When I do call "POST" request to "/appuser/signup" for login with body:
			"""
			{
			"productID": ${user.productID},
			"deviceID": ${user.deviceID},
			"appUserID": ${user.appUserID},
			"registrationType": 4,
			"email":"fiatlux@gmail.com"
			}
			"""
		Then I receives status code "200"
		And The response should contain:
			"""
			{
			"productID": "disneystorytime-pt",
			"deviceID": ${user.deviceID},
			"appUserID": ${user.appUserID},
			"isSucceeded": 1,
			"userType": 4
			}
			"""
