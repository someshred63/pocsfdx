@isTest
private class SCM_Security_UT {

        static testMethod void SCM_SecurityUnitTest() {
            string test = SCM_Security.SCM_AuthenticateNonDefault();
            test = SCM_Security.getEnvironmentVariable('SCM_Username');
        }
}