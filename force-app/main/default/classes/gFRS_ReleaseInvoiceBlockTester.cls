@isTest
public with sharing class gFRS_ReleaseInvoiceBlockTester {

	static testMethod void testReleaseInvoiceBlock() {
		gFRS_ReleaseInvoiceBlockWS.GneCOMM_Grants_SFDC_O_1Port0 sapReleaseInvoice = new gFRS_ReleaseInvoiceBlockWS.GneCOMM_Grants_SFDC_O_1Port0();
		gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlock_element sap = new gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlock_element();
		gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element sapRes = new gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element();
		try{
			gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element response =  sapReleaseInvoice.releaseInvoiceBlock('12344', '2011');                        
		} catch(Exception e){
			system.debug(e.getMessage());
		}
		
	}
	
	static testmethod void testInternalClasses(){
		//-- the classes do not contain logic but use internal SFDC functionality for usign the calls.
		gFRS_ReleaseInvoiceBlockGFRS.ReleaseInvoiceBlockRequest request = new gFRS_ReleaseInvoiceBlockGFRS.ReleaseInvoiceBlockRequest();
		gFRS_ReleaseInvoiceBlockGFRS.ReleaseInvoiceBlockResponse response = new gFRS_ReleaseInvoiceBlockGFRS.ReleaseInvoiceBlockResponse();
		
	}
}