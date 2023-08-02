/**
* @author ADMD Team
* @date 16/12/2013
* @description gFRS_SubmitGrantWS_Mock class - mock class for testin purposes.
*/
@isTest
global class gFRS_SubmitGrantWS_Mock implements WebServiceMock{

	global gFRS_SubmitGrantSAP.submitGrantResponse_element responseElement;

    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        response.put('response_x', responseElement);
    }
}