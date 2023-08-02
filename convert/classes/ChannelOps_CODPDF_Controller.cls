public class ChannelOps_CODPDF_Controller {
	
    public ChannelOps_Spoilage_Request_COD__c spoilageRequestCOD {get;set;}
    public String subTitle {get;set;}
    public List<ChannelOps_Spoilage_Request_Product__c> spoilageRequestProducts {get;set;}

   public void ChannelOps_CODPDF_Controller(){
       
   }
   
    public void initPDF(){
        String spoilageRequestCODId = GCS_Util.decryptData(Apexpages.currentPage().getParameters().get('id'),GCS_Util.getCryptoKey());      
        System.debug('spoilageRequestCODId----------'+spoilageRequestCODId);
        ChannelOps_App_Property__c property = [SELECT Id, CS_subTitle__c, GSKey__c, GSite__c, GCKey__c FROM ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        subTitle =property.CS_subTitle__c;
        if(String.isNotBlank(spoilageRequestCODId)){
            List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = fetchSpoilageRequestCODById(spoilageRequestCODId);
            if(spoilageRequestCODList != null && !spoilageRequestCODList.isEmpty()){
                spoilageRequestProducts = fetchSpoilageRequestProducts(spoilageRequestCODList[0].ChannelOps_Spoilage_Request__c);
                spoilageRequestCOD = spoilageRequestCODList[0];              
            }
        }        
    }
    
    private List<ChannelOps_Spoilage_Request_Product__c> fetchSpoilageRequestProducts(Id spoilageRequestId){
		List<ChannelOps_Spoilage_Request_Product__c> spoilageRequestProductList = new List<ChannelOps_Spoilage_Request_Product__c>();        
        if(spoilageRequestId != null){
        	spoilageRequestProductList = [SELECT Id, brand__c,Indication__c,Lot_Number__c,MayEdit,Name,NDC__c,
                                          		 Other_Indication__c,Product_Name__c,Product__c,Quantity__c,Serial_Number__c,
                                          		 Spoilage_Request__c 
                                          FROM	 ChannelOps_Spoilage_Request_Product__c
                                          WHERE	 Spoilage_Request__c =: spoilageRequestId];
        }
        return spoilageRequestProductList;        
    }
    
    
    
    private List<ChannelOps_Spoilage_Request_COD__c> fetchSpoilageRequestCOD(String requestNumber, String sapQuotationId){
		List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = null;
        if(String.isNotBlank(requestNumber) && String.isNotBlank(sapQuotationId)){
            spoilageRequestCODList = [SELECT Id, ChannelOps_Spoilage_Request__c, ChannelOps_Spoilage_Request__r.Id, ChannelOps_Spoilage_Request__r.Name, 
                							ChannelOps_Spoilage_Request__r.Status__c, ChannelOps_Spoilage_Request__r.Submission_Date__c,
                                            City__c,Contact_Email__c,Contact_Name__c,Contact_Phone__c,Credentials__c,
                							DEA__c,HCP_Name__c,Name,Other_Credential__c,Quotation_Document_Date__c,
                							Quotation_Request_Date__c,SAP_Quotation_End_Date__c,SAP_Quotation_ID__c,
                							SAP_Ship_To_ID__c,Ship_To_Name__c,State_License__c,State__c,
                							Street_Address2__c,Street_Address__c,Title__c,Zip_Code__c,Facility_Name__c 
                					  FROM	ChannelOps_Spoilage_Request_COD__c
                                      WHERE ChannelOps_Spoilage_Request__r.Name =:requestNumber AND SAP_Quotation_ID__c=: sapQuotationId]; 
        }
        return spoilageRequestCODList;
    }
    
    private List<ChannelOps_Spoilage_Request_COD__c> fetchSpoilageRequestCODById(String spoilageRequestCODId){
		List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = null;
        if(String.isNotBlank(spoilageRequestCODId)){
            spoilageRequestCODList = [SELECT Id, ChannelOps_Spoilage_Request__c, ChannelOps_Spoilage_Request__r.Id, ChannelOps_Spoilage_Request__r.Name, 
                							ChannelOps_Spoilage_Request__r.Status__c, ChannelOps_Spoilage_Request__r.Submission_Date__c,
                                            City__c,Contact_Email__c,Contact_Name__c,Contact_Phone__c,Credentials__c,
                							DEA__c,HCP_Name__c,Name,Other_Credential__c,Quotation_Document_Date__c,
                							Quotation_Request_Date__c,SAP_Quotation_End_Date__c,SAP_Quotation_ID__c,
                							SAP_Ship_To_ID__c,Ship_To_Name__c,State_License__c,State__c,
                							Street_Address2__c,Street_Address__c,Title__c,Zip_Code__c,Facility_Name__c 
                					  FROM	ChannelOps_Spoilage_Request_COD__c
                                      WHERE Id =: spoilageRequestCODId]; 
        }
        return spoilageRequestCODList;
    }

}