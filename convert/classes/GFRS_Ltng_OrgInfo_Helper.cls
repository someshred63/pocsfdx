public with sharing class GFRS_Ltng_OrgInfo_Helper {
    /*
Method Name:getTinChkStatus
Description: This will help in getting response from TIN CHECK system.
*/
    @AuraEnabled
    public static String getTinChkStatus(String recId,String orgName){
        String strResp;
        String strTinCode;
        try{
            if(recId != null && recId != ''){
                gFRS_Ltng_TincheckWebservice.PVSServiceSoap TinCheck = new gFRS_Ltng_TincheckWebservice.PVSServiceSoap();
                gFRS_Ltng_TincheckWebservice.TinNameClass TinNameClass = new gFRS_Ltng_TincheckWebservice.TinNameClass();
                TinNameClass.TIN = recId;
                if(orgName != null && orgName != ''){
                    TinNameClass.LName = orgName;    
                }else{
                    TinNameClass.LName = '';
                }                
                TinNameClass.Encryption = '';
                TinNameClass.FName = '';
                TinNameClass.Giin = '';
                
                gFRS_Ltng_TincheckWebservice.UserClass UserClass = new gFRS_Ltng_TincheckWebservice.UserClass();
                UserClass.UserID = '';
                UserClass.UserLogin = 'ylam@gene.com';
                UserClass.UserPassword = 'vendormaster';
                UserClass.UserEncryption = '';
                
                gFRS_Ltng_TincheckWebservice.TINNAME_RESPONSE Response = TinCheck.ValidateTinName(TinNameClass, UserClass);
                system.debug('Tin Name Code is : '+Response.TINNAME_CODE);
                system.debug('Tin Name Details are : '+Response.TINNAME_DETAILS);
                
                strTinCode = Response.TINNAME_CODE;
                if(strTinCode == '1' ||strTinCode == '6' ||strTinCode == '7' ||strTinCode == '8'){
                    strResp = 'Verified';
                }else{
                    strResp = 'Not Verified';
                }
            }
        }Catch(Exception ex){
            system.debug('@@@@ Ex:::'+ex.getMessage());
            strResp = 'Error';
        }
        return strResp;
    }
}