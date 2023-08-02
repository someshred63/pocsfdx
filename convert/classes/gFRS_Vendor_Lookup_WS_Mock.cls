@isTest
public class gFRS_Vendor_Lookup_WS_Mock implements WebServiceMock {
   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

             System.debug('WebServiceMock');
             GFRS_VendorLookupSAP.VendorLookup_element vle = (GFRS_VendorLookupSAP.VendorLookup_element)request;
             System.debug(vle);

             GFRS_VendorLookupSAP.VendorLookupResponse_element respElement = new GFRS_VendorLookupSAP.VendorLookupResponse_element();
             respElement.MessageType='S';
             GFRS_VendorLookupSAP.VendorDetails_element vendDetElement = new GFRS_VendorLookupSAP.VendorDetails_element();

             if (vle.Id == 'blockedId') {
               vendDetElement.DeletionFlagAllArea='X';
               vendDetElement.PostingBlockAllCompanyCode='X';
             } else if (vle.Id == 'notblockedId') {
               vendDetElement.DeletionFlagAllArea='';
               vendDetElement.PostingBlockAllCompanyCode='';
             } else if (vle.Id == 'throwExcepti'){
               throw new VendorLookupWSMockException('Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem');
             } else {
               respElement.MessageType='E';
               respElement.MessageText='Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem';
             }

             respElement.VendorDetails = new GFRS_VendorLookupSAP.VendorDetails_element[]{vendDetElement};

             response.put('response_x', respElement);
           }
public class VendorLookupWSMockException extends Exception {}
}