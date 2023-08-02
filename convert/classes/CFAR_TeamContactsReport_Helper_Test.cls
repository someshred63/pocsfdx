@IsTest
private class CFAR_TeamContactsReport_Helper_Test {

    @IsTest
    private static void shouldSecureParam() {
        System.assertEquals('\\\'Hello Prams\\\'', CFAR_TeamContactsReport_Helper.secureParam('\'Hello Prams\''));
        System.assertEquals('', CFAR_TeamContactsReport_Helper.secureParam(''));
        System.assertEquals(null, CFAR_TeamContactsReport_Helper.secureParam(null));
    }

}