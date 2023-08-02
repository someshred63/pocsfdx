@isTest
private class gFRS_UpdateUserWebServiceTester {
    static testMethod void testUpdateUserWebService() {
        gFRS_UpdateUserWebService ws = new gFRS_UpdateUserWebService();
        gFRS_UpdateUserWebService.gFRS_updateUserResult result = gFRS_UpdateUserWebService.updateUser('qwertyasdfghzxccvv@modelmetrics.com','qwertyasdfghzxccvv', 'qwertyasdfghzxccvv', 'Director of Operations', 'qwertyasdfghzxccvv@modelmetrics.com', '555777444', '33333');
        User[] users = [select Id, ContactId from user where username = 'qwertyasdfghzxccvv@modelmetrics.com'];

        result = gFRS_UpdateUserWebService.UpdateUser('qwertyasdfghzxccvv@modelmetrics.com','qwertyasdfghzxccvv', 'qwertyasdfghzxccvv', 'Director of Operations', 'qwertyasdfghzxccvv@modelmetrics.com', '555777444', '2345');
        users = [select Id, ContactId from user where username = 'qwertyasdfghzxccvv@modelmetrics.com'];

        gFRS_updateUserSchema schema = new gFRS_updateUserSchema();
        gFRS_updateUserSchema.logInfo logInfo = new gFRS_updateUserSchema.logInfo();
        gFRS_updateUserSchema.AllowFieldTruncationHeader_element trunk = new gFRS_updateUserSchema.AllowFieldTruncationHeader_element();
        gFRS_updateUserSchema.DebuggingHeader_element debug = new gFRS_updateUserSchema.DebuggingHeader_element();
        gFRS_updateUserSchema.CallOptions_element call = new gFRS_updateUserSchema.CallOptions_element();
        gFRS_updateUserSchema.DebuggingInfo_element debugInfo = new gFRS_updateUserSchema.DebuggingInfo_element();
    }
}