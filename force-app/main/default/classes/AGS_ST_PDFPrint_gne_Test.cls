/** @date 3/26/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track PDF Print Controller
*/
@isTest
private class AGS_ST_PDFPrint_gne_Test {
	/** @date 3/26/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for AGS_ST_PDFPrint_gne class constructor
    */
    @isTest static void shouldCreatePDFPrintClassInstanceFaq() {
        // GIVEN
        Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

        // WHEN
        ApexPages.currentPage().getParameters().put('content', 'faq');
        ApexPages.currentPage().getParameters().put('pdfprint', '1');
        AGS_ST_PDFPrint_gne util = new AGS_ST_PDFPrint_gne();

        // THEN
        System.assert( util.showFAQ );
        System.assert( util.pdfPrint );
        System.assertEquals( 'pdf', util.renderAs );
        System.assertEquals( 1, util.faqList.size() );
    }

    /** @date 3/26/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for AGS_ST_PDFPrint_gne class constructor
    */
    @isTest static void shouldCreatePDFPrintClassInstanceAboutSunshineAct() {
        // GIVEN
        Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

        // WHEN
        ApexPages.currentPage().getParameters().put('content', 'about');
        AGS_ST_PDFPrint_gne util = new AGS_ST_PDFPrint_gne();

        // THEN
        System.assert( util.showAboutContent );
        System.assertEquals( 1, util.faqList.size() );
        System.assertEquals( 'Description', util.aboutText );
    }
}