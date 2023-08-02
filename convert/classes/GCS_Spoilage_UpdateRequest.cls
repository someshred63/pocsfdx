/**********************************************************************
Purpose: GCS_Spoilage_UpdateRequest class is used to update 
the spoilage request in Lighting Experience .
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       11/09/2020      INITIAL DEVELOPMENT

***********************************************************************/
public class GCS_Spoilage_UpdateRequest {
    
    /***Description: get existing Spoilage_Request record details  
    * param: reqId=Spoilage_Request ID
    **/ 
    @AuraEnabled
    public static List<ChannelOps_Spoilage_Request__c> getSpoilageRequestRecord(string reqId){       
        
        List<ChannelOps_Spoilage_Request__c> request = [select id, name,Date_of_Spoilage__c, Adverse_Event__c, Depleted_Inventory__c, GATCF_Product__c,Quality_Issue__c, Duplicate_Warning__c,Possible_Duplicate_Request_ID__c,Status__c, Human_error__c,Human_Error_excused__c,Human_error_excuse_Justification__c,
                                                        Assigned_To__c,Assigned_To__r.Name, ChannelOps_user_comment__c, Auto_denial_off_label_use__c, Auto_Denail_late__c,License_Type__c,License_Num__c,Human_Error_Excused_Date__c, AutoDenial_Excused__c, Auto_Denial_Excuse_Justification__c, No_Redundant_System_Excused_Request__c,
                                                        No_Redundant_System_Excused__c, No_Redundant_System_excuse_justification__c,CatastrophicEvent__c,State__c,PDF_Attachment_ID__c,COD__r.Name,COD__c,
                                                        Reason_Code__c, Spoilage_Type__c, Return_Method_Exception__c,No_Redundant_System_Excused_Request__r.Name,SAP_Quotation_ID__c from ChannelOps_Spoilage_Request__c where id=: reqId];
        
        return request;
    }

    /***Description: get status picklist values for Spoilage_Request  
    * param: reqStatus= current spoilage request status 
    **/ 
    @AuraEnabled
    public static List<String> getStatusOptions(string reqStatus){
        Boolean isSAPIntegration; 
        List<ChannelOps_App_Property__c> propertyList = [SELECT Id, SAP_Integration__c FROM ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        isSAPIntegration = (propertyList != null && !propertyList.isEmpty()) ? propertyList[0].SAP_Integration__c : false;
        
        List<String> statuses = (!isSAPIntegration) ? ChannelOps_Constants.spoilagestatusList1 : ChannelOps_Constants.spoilagestatusList2;  
        
        List<String> pickListValuesList = new List<String>();

          if((reqStatus == ChannelOps_Constants.SPOILAGE_STATUS_SAP_COD_RESP_NOT_RECEIVED ||
              reqStatus == ChannelOps_Constants.SPOILAGE_STATUS_SAP_FAILED_TO_PROCESS_COD)){
                pickListValuesList.add(reqStatus);                      
                pickListValuesList.add(ChannelOps_Constants.SPOILAGE_STATUS_COD_RECEIVED_BY_SAP);
              }else if(reqStatus == ChannelOps_Constants.SPOILAGE_STATUS_SAP_QUOTATION_CREATION_FAILED){ 
                pickListValuesList.add(reqStatus);    
                pickListValuesList.add(ChannelOps_Constants.SPOILAGE_STATUS_MANUALLY_CRE_IN_SAP);
              }else{
                for(String statusVal: statuses){
                    pickListValuesList.add(statusVal);
                }
              }
        return pickListValuesList;
    }

    /***Description: get HumanErrorExcuseLimitation values for Spoilage_Request  
    * param: reqId=Spoilage_Request ID,licenseType=Spoilage_Request License_Type__c,
    state=Spoilage_Request State__c,licenseNum=Spoilage_Request License_Num__c
    **/ 
    @AuraEnabled
    public static String getHumanErrorExcuseLimitation(string reqId,string licenseType,string state,string licenseNum){
        
        Date d=(System.TODAY()-365);
        List<ChannelOps_Spoilage_Request__c> excusedRequests=[select id,Human_Error_excused__c,State__c,License_Num__c,License_Type__c,Human_Error_Excused_Date__c,Date_of_Spoilage__c from ChannelOps_Spoilage_Request__c 
                                                              where License_Type__c=:licenseType and License_Num__c=:licenseNum and State__c=:state and Human_Error__c=true and Human_Error_excused__c=true and Date_of_Spoilage__c >=: d and id!=:reqId];
        System.debug('excusedRequests---'+excusedRequests);
        if(excusedRequests!=null && excusedRequests.size()>=3) return 'Yes';
        else return 'No';
    }

     /***Description: get ChannelOpsAppProperty values for Spoilage_Request**/ 
    @AuraEnabled
    public static Boolean getChannelOpsAppProperty(){
        
         Boolean isSAPIntegration;    
        List<ChannelOps_App_Property__c> propertyList = [SELECT Id, SAP_Integration__c FROM ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        isSAPIntegration = (propertyList != null && !propertyList.isEmpty()) ? propertyList[0].SAP_Integration__c : false;
        
        return isSAPIntegration;
        
    }

    /***Description: updateSpoilageRequest is used to update Spoilage_Request  
    * param: spoilageReqDetails=spoilage request object values to update, spoilageReqId=current spoilage request id
    **/ 
    @AuraEnabled
    public static string updateSpoilageRequest(string spoilageReqDetails,string spoilageReqId){
        string result;
        map<String, Object> mapOfSpoilageReq= (Map<String, Object>)JSON.deserializeUntyped(spoilageReqDetails);
        system.debug('mapOfSpoilageReq'+mapOfSpoilageReq);
       
        List<ChannelOps_Spoilage_Request__c> spoilageRequests = [select id, name,Date_of_Spoilage__c, Adverse_Event__c, Depleted_Inventory__c, GATCF_Product__c,Quality_Issue__c, Duplicate_Warning__c,Possible_Duplicate_Request_ID__c,Status__c, Human_error__c,Human_Error_excused__c,Human_error_excuse_Justification__c,
                                                                 Assigned_To__c,Assigned_To__r.Name, ChannelOps_user_comment__c, Auto_denial_off_label_use__c, Auto_Denail_late__c,License_Type__c,License_Num__c,Human_Error_Excused_Date__c, AutoDenial_Excused__c, Auto_Denial_Excuse_Justification__c, No_Redundant_System_Excused_Request__c,
                                                                 No_Redundant_System_Excused__c, No_Redundant_System_excuse_justification__c,CatastrophicEvent__c,State__c,
                                                                 Reason_Code__c, Spoilage_Type__c, Return_Method_Exception__c,No_Redundant_System_Excused_Request__r.Name,
                                                                 No_Redundant_System_Excused_Date__c, Reviewed_Date__c From ChannelOps_Spoilage_Request__c where id=: spoilageReqId];
        
        if(spoilageRequests.size() > 0){
            
            for(ChannelOps_Spoilage_Request__c spr :spoilageRequests){
                
                if(String.valueOf(mapOfSpoilageReq.get('assignTo')) == null){
                    spr.Status__c= ChannelOps_Constants.SPOILAGE_STATUS_NEW;
                }else{
                    if(String.valueOf(mapOfSpoilageReq.get('reqStatus')) ==ChannelOps_Constants.SPOILAGE_STATUS_NEW){
                        spr.Status__c= ChannelOps_Constants.SPOILAGE_STATUS_ASSIGNED;    
                    }else{
                        spr.Status__c=String.valueOf(mapOfSpoilageReq.get('reqStatus'));
                    }
                }
                
                spr.Assigned_To__c=String.valueOf(mapOfSpoilageReq.get('assignTo'));
                spr.Adverse_Event__c=boolean.valueOf(mapOfSpoilageReq.get('adverseEvent'));
                spr.Quality_Issue__c=boolean.valueOf(mapOfSpoilageReq.get('quality'));
                spr.AutoDenial_Excused__c=boolean.valueOf(mapOfSpoilageReq.get('excuseAutoDenial'));
                spr.Auto_Denial_Excuse_Justification__c=String.valueOf(mapOfSpoilageReq.get('autoDenialExcuseJustification'));
                spr.Human_Error__c=boolean.valueOf(mapOfSpoilageReq.get('humanErrorCheck'));
                spr.Human_Error_excused__c=boolean.valueOf(mapOfSpoilageReq.get('humanErrorExcuse'));
                spr.Human_Error_Excuse_Justification__c=String.valueOf(mapOfSpoilageReq.get('humanErrorExcuseJustification'));
                spr.Duplicate_Warning__c=boolean.valueOf(mapOfSpoilageReq.get('duplicateWarnCheck'));
                spr.Return_Method_Exception__c=boolean.valueOf(mapOfSpoilageReq.get('returnMethodExp'));
                spr.No_Redundant_System_Excused__c=boolean.valueOf(mapOfSpoilageReq.get('redundantSystemExcuse'));
                spr.No_Redundant_System_excuse_justification__c=String.valueOf(mapOfSpoilageReq.get('justificationforExcusing'));
                spr.ChannelOps_user_comment__c=String.valueOf(mapOfSpoilageReq.get('comments'));
                
                if(mapOfSpoilageReq.get('noRedundantSystemExcusedDate') != null && mapOfSpoilageReq.get('noRedundantSystemExcusedDate') instanceOf String 
                    && String.valueOf(mapOfSpoilageReq.get('noRedundantSystemExcusedDate')) == 'todayDate'){
                    spr.No_Redundant_System_Excused_Date__c =  System.today();
                }else if(!spr.No_Redundant_System_Excused__c){
                    spr.No_Redundant_System_Excused_Date__c = null;
                }
                
                if(mapOfSpoilageReq.get('humanErrorExcusedDate') != null && mapOfSpoilageReq.get('humanErrorExcusedDate') instanceOf String 
                    && String.valueOf(mapOfSpoilageReq.get('humanErrorExcusedDate')) == 'todayDate'){
                    spr.Human_Error_Excused_Date__c =  System.today();
                }else if(!spr.Human_Error_excused__c){
                    spr.Human_Error_Excused_Date__c = null;
                }
                
                if(mapOfSpoilageReq.get('reviewedDate') != null && mapOfSpoilageReq.get('reviewedDate') instanceOf String 
                    && String.valueOf(mapOfSpoilageReq.get('reviewedDate')) == 'todayDate'){
                    spr.Reviewed_Date__c =  System.now();
                }             
            }
            try{
                upsert spoilageRequests;               
            }catch(exception e){
                system.debug('exception'+e);
              throw new AuraHandledException('Failure, Error Occured While Updating Spoilage Request. \nEXCEPTION: '+e.getMessage());
            }
        }
        
        return result;
    }

}