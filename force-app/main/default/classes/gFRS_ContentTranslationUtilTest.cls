@isTest
private with sharing class gFRS_ContentTranslationUtilTest {

    public static final String CONTENT_TYPE = 'Homepage';

    @testSetup
    public static void init() {
        GFRS_Content__c content = gFRS_TestCreationUtils.createContent('IMED', '', CONTENT_TYPE);
        insert content;
        GFRS_Content_Translation__c translation = gFRS_TestCreationUtils.createContentTranslation(content, 'tBlock', 'legacy2', 'lang');
        insert translation;
    }

    @isTest
    private static void fetchContentTranslationsByFilterIsEmptyTest() {
        String lang = 'lang';
        Map<String, String> results = new Map<String, String>();
        Test.startTest();
        results = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, lang);
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(results.get('IMED')));
    }

    @isTest
    private static void fetchContentTranslationsByFilterIsNotEmptyTest() {
        String lang = 'eu';
        Map<String, String> results = new Map<String, String>();
        Test.startTest();
        results = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, lang);
        Test.stopTest();
        System.assertEquals(true, String.isEmpty(results.get('Welcome_Internal')));
    }
}