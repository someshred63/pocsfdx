@IsTest
private class gFRS_XmlErrorMessageReaderTest {

    private static final String PATH = 'https://genentech--gfrs.cs21.my.salesforce.com/';
    private static final String ENTITY_ID = '01I70000000Bi1S';
    private static final String ERROR_CODE = '404';
    private static final String ERROR_MESSAGE = 'Error test message';
    private static final String MESSAGE = ENTITY_ID + ': ' + ERROR_MESSAGE;
    private static final String XML_ERROR = '<errors>' +
            '<pathName>' + PATH + ENTITY_ID + '</pathName>' +
            '<errorCode>' + ERROR_CODE + '</errorCode>' +
            '<errorMessage>' + ERROR_MESSAGE + '</errorMessage>' +
            '</errors>';

    @IsTest
    static void testParseError() {
        gFRS_XmlErrorMessageReader reader = new gFRS_XmlErrorMessageReader();
        XmlStreamReader streamReader = new XmlStreamReader(XML_ERROR);
        gFRS_XmlErrorMessageReader.Error[] errors = reader.parseErrors(streamReader);

        System.assertEquals(1, errors.size());
        for (Integer i = 0; i < errors.size(); i++) {
            System.assertEquals(MESSAGE, errors[i].getMessage());
            System.assertEquals(PATH + ENTITY_ID, errors[i].pathName);
            System.assertEquals(ERROR_CODE, errors[i].errorCode);
            System.assertEquals(ERROR_MESSAGE, errors[i].errorMessage);
        }
    }
}