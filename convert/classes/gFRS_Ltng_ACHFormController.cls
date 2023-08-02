public class gFRS_Ltng_ACHFormController {
    
    public gFRS_Ltng_Application__c reqRecord { get; set; }
    public gFRS_Ltng_Vendor_Detail__c vendorDetailRec { get; set; }
    public gFRS_Ltng_ACH_Details__c vdObj { get; set; }
    public gFRS_Ltng_ACH_Details__c vendorRec { get; set; }
    public Decimal bankRoutingId { get; set; }
    public Decimal bankAccountNbr { get; set; }
    public string IBANnumber { get; set; }
    public Decimal interBankRoutingId { get; set; }
    public Decimal interBankAccountNbr { get; set; }
    public String myDateTime {get {return date.today().format();}}
    
    public gFRS_Ltng_ACHFormController(ApexPages.Standardcontroller std) {
        vendorRec = (gFRS_Ltng_ACH_Details__c) std.getRecord();
        Id requestId = apexpages.currentpage().getparameters().get('reqId');
        
        try{
            
        	vendorRec = [
                SELECT  Id,gFRS_Vendor_Detail__c,Account_Type__c,Payment_Method_UI__c,Bank_Routing_ID__c,Bank_Name__c,
                    		Bank_Account_Number__c,IBAN__c,Account_Holder_Name__c,Payment_Information_Approver_Name__c,Createdby.Name,
                    		Title__c,Do_you_require_intermediary_bank__c,Intermediary_Bank_Name__c,Intermediary_Bank_Country__c,
                    		Intermediary_Bank_Account_Number__c,Intermediary_Bank_Swift_Code__c,Intermediary_Bank_Routing_ID__c 
                    		FROM gFRS_Ltng_ACH_Details__c WHERE ID = :this.vendorRec.id 
                LIMIT 1
            ];
            
            vdObj = new  gFRS_Ltng_ACH_Details__c();
            
            vdObj.Bank_Routing_ID__c 					= decryptACH(vendorRec.Bank_Routing_ID__c);
            bankRoutingId								= decimal.valueof(vdObj.Bank_Routing_ID__c);
            vdObj.Bank_Name__c 						= decryptACH(vendorRec.Bank_Name__c);
            vdObj.Bank_Account_Number__c 				= decryptACH(vendorRec.Bank_Account_Number__c);
            bankAccountNbr				 				= decimal.valueof(vdObj.Bank_Account_Number__c);
            vdObj.IBAN__c 							= decryptACH(vendorRec.IBAN__c);
            
            if(vdObj.IBAN__c != '' && vdObj.IBAN__c != null){
                IBANnumber	 							= vdObj.IBAN__c;
            }
            
            vdObj.Account_Holder_Name__c 				= decryptACH(vendorRec.Account_Holder_Name__c);
            vdObj.Account_Type__c			 			= vendorRec.Account_Type__c;
            vdObj.Payment_Method_UI__c			 	= vendorRec.Payment_Method_UI__c;
            vdObj.Title__c			 				= decryptACH(vendorRec.Title__c);
            vdObj.Do_you_require_intermediary_bank__c	= vendorRec.Do_you_require_intermediary_bank__c;
            
            if(vendorRec.Do_you_require_intermediary_bank__c == 'Yes'){
                vdObj.Intermediary_Bank_Name__c 			= decryptACH(vendorRec.Intermediary_Bank_Name__c);
                vdObj.Intermediary_Bank_Country__c 		= decryptACH(vendorRec.Intermediary_Bank_Country__c);
                vdObj.Intermediary_Bank_Account_Number__c = decryptACH(vendorRec.Intermediary_Bank_Account_Number__c);
                vdObj.Intermediary_Bank_Swift_Code__c 	= decryptACH(vendorRec.Intermediary_Bank_Swift_Code__c);
                vdObj.Intermediary_Bank_Routing_ID__c 	= decryptACH(vendorRec.Intermediary_Bank_Routing_ID__c);
                interBankAccountNbr				 				= decimal.valueof(vdObj.Intermediary_Bank_Account_Number__c);
                interBankRoutingId								= decimal.valueof(vdObj.Intermediary_Bank_Routing_ID__c);
            }
            
            vendorDetailRec = new gFRS_Ltng_Vendor_Detail__c();
            vendorDetailRec = [SELECT Id, Name, Organization_Tax_ID__c, Address__c, Address2__c, State__c, City__c, Zip__c,
                               Department_Chapter_Country__c, Province__c, Telephone_Number__c, gFRS_Application__r.Attention_To__c,
                               gFRS_Application__r.Person_To_Whom_Payment_should_addressed__c
                               FROM gFRS_Ltng_Vendor_Detail__c WHERE Id =: vendorRec.gFRS_Vendor_Detail__c];
            reqRecord = new gFRS_Ltng_Application__c();
            reqRecord = [SELECT Id, Name, Attention_To__c, Person_To_Whom_Payment_should_addressed__c FROM gFRS_Ltng_Application__c WHERE Id =: requestId];
                
        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
            return;
        }
    }

    public static string decryptACH(string stringToDecrypt){
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        Blob aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        Blob decoder = EncodingUtil.base64Decode(stringToDecrypt);
        Blob decryptor = Crypto.decryptWithManagedIV('AES256', aesKey, decoder);
        string decryptedStr = decryptor.toString();
        return decryptedStr;
    }       

}