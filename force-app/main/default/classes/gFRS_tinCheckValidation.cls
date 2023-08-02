public class gFRS_tinCheckValidation {
/*
    Method Name:checkTinStatus
    Description: This method will help to check tax id is valid or not in Tin check service. 
    */
    @AuraEnabled
    public static wrapperTinCheck checkTinStatus(String recId){
		wrapperTinCheck wrapTin = new wrapperTinCheck();
		
		gFRS_Ltng_Pre_Application__c rec =[Select id,Status__c,	Organization_Tax_ID__c,Organization_Name__c,Tin_Check_Status__c from gFRS_Ltng_Pre_Application__c where Id=:recId];
		String orgTaxID = rec.Organization_Tax_ID__c;
		if(String.isNotBlank(orgTaxID)){
			orgTaxID = orgTaxID.replaceAll('[^0-9s+]', '');
			System.debug('strText ======> '+orgTaxID);
			}
		if(String.isNotBlank(orgTaxID)  && rec.Tin_Check_Status__c == 'Not Verified'){		
			gFRS_Ltng_TincheckWebservice.PVSServiceSoap TinCheck = new gFRS_Ltng_TincheckWebservice.PVSServiceSoap();
			gFRS_Ltng_TincheckWebservice.TinNameClass TinNameClass = new gFRS_Ltng_TincheckWebservice.TinNameClass();
			TinNameClass.TIN = orgTaxID;
			TinNameClass.LName = rec.Organization_Name__c;
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

			wrapTin.tinCode = Response.TINNAME_CODE;
            //wrapTin.tinCode = '6';
			wrapTin.tinDetails = Response.TINNAME_DETAILS;
            if(wrapTin.tinCode == '1'){
                rec.Tin_Check_Status__c = 'Verified';
            }else if(wrapTin.tinCode == '6'){
                rec.Tin_Check_Status__c = 'Verified';
            }
            else if(wrapTin.tinCode == '7'){
                rec.Tin_Check_Status__c ='Verified';
            }
            else if(wrapTin.tinCode == '8'){
                rec.Tin_Check_Status__c = 'Verified';
            }
            else{
                rec.Tin_Check_Status__c = 'Not Verified';
                wrapTin.tinStatus= 'Not Verified';
            }
            if(rec.Tin_Check_Status__c == 'Verified'){
            try{                
                update rec;
               wrapTin.recStatus=true;
            }
            catch (exception e){
                wrapTin.recStatus=false;
            }
            }
			//wrapTin.recStatus=false;
		}else{		
			wrapTin.tinStatus =rec.Tin_Check_Status__c;
		}
  		return wrapTin;
	
	}
    public class wrapperTinCheck{
        @AuraEnabled public String tinCode{get;set;}
        @AuraEnabled public String tinDetails{get;set;}
        @AuraEnabled public boolean recStatus{get;set;}
		@AuraEnabled public String  tinStatus{get;set;}        
        
    }
}