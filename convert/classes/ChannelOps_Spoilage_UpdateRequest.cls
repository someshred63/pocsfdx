/**********************************************************************
Purpose: ChannelOps_Spoilage_UpdateRequest class is used to update 
the spoilage request.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      					     	INITIAL DEVELOPMENT
1.1		Vijay		08/08/2019		added business loigc to valdiate and update the 
                                    spoilage request status. Refer US# COEXP-269	
                                    Request assigning history(assigning_history__c) field is 
                                    no longer in use, deleted from object and commented the references
1.2		Vijay       10/15/2019      Added business logic to allow edit rejected email sent
									and rejected email not sent spoilage requests
1.3		Vijay 		10/24/2019		Processing in SAP no longer available.updated the validation
									message.
1.4		Vijay		02/18/2020		added the logic to allow user to update 'SAP Quotation Creation
									Failed' to 'Manually Created In SAP'
***********************************************************************/
public class ChannelOps_Spoilage_UpdateRequest {
    
    public String errorMsg {set; get;}
    
    public ChannelOps_Spoilage_Request__c request {get; set;}
    
    public Boolean noRedundantSystemError {set; get;}
    
    //holds the status on page load
    public String previousStatus {get;set;}
    
    //holds the selected status picklist value
    public String selectedStatus {get;set;}
    
    //signifies whether spoilage req is updatable or not
    public Boolean isSpoilageRequpdatable {get;set;}
    
    //private Boolean allowHumanErrorExcuse;
    
    //It checks whether SAP Integration is Active or Not
    private Boolean isSAPIntegration; 
    
    //toggles to readonly mode
    public Boolean displaySection {get;set;}
    
    public String getHumanErrorExcuseLimitation(){
        System.debug('getHumanErrorExcuseLimitation---'+request.License_Type__c);
        System.debug('getHumanErrorExcuseLimitation---'+request.State__c);
        System.debug('getHumanErrorExcuseLimitation---'+request.License_Num__c);
        Date d=(System.TODAY()-365);
        List<ChannelOps_Spoilage_Request__c> excusedRequests=[select id,Human_Error_excused__c,State__c,License_Num__c,License_Type__c,Human_Error_Excused_Date__c,Date_of_Spoilage__c from ChannelOps_Spoilage_Request__c 
                                                              where License_Type__c=:request.License_Type__c and License_Num__c=:request.License_Num__c and State__c=:request.State__c and Human_Error__c=true and Human_Error_excused__c=true and Date_of_Spoilage__c >=: d and id!=:request.id];
        System.debug('excusedRequests---'+excusedRequests);
        if(excusedRequests!=null && excusedRequests.size()>=3) return 'Yes';
        else return 'No';
    }
    
    //This method prepares the spoilage request status picklist with applicable values
    public List<SelectOption> getSpoilageStatusList(){
        List<SelectOption> options = new List<SelectOption>();
        if(request != null && (request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_SAP_COD_RESP_NOT_RECEIVED ||
                              request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_SAP_FAILED_TO_PROCESS_COD)){
        	options.add(new SelectOption(request.Status__c,request.Status__c));                         
            options.add(new SelectOption(ChannelOps_Constants.SPOILAGE_STATUS_COD_RECEIVED_BY_SAP,ChannelOps_Constants.SPOILAGE_STATUS_COD_RECEIVED_BY_SAP));                         
        }else if(request != null && (request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_SAP_QUOTATION_CREATION_FAILED)){
        	options.add(new SelectOption(request.Status__c,request.Status__c));                         
            options.add(new SelectOption(ChannelOps_Constants.SPOILAGE_STATUS_MANUALLY_CRE_IN_SAP,ChannelOps_Constants.SPOILAGE_STATUS_MANUALLY_CRE_IN_SAP));                         
        }else{
            List<String> statuses = (!isSAPIntegration) ? ChannelOps_Constants.spoilagestatusList1 : ChannelOps_Constants.spoilagestatusList2;  
            for(String statusVal: statuses){
                options.add(new SelectOption(statusVal,statusVal));
            }
        }
        return options;
    } 
    
    public PageReference showCODInfoMessage(){
        System.debug('Status-----'+ selectedStatus);
        if(request != null && selectedStatus == ChannelOps_Constants.SPOILAGE_STATUS_COD_RECEIVED_BY_SAP){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.ChannelOps_COD_Received_Info_Msg));
        }
        return null;
    }
    
    public ChannelOps_Spoilage_UpdateRequest(ApexPages.StandardController stdCtrl) {
        string id = stdCtrl.getRecord().id;
        request = [select id, name, Adverse_Event__c, Depleted_Inventory__c, GATCF_Product__c,Quality_Issue__c, Duplicate_Warning__c,Possible_Duplicate_Request_ID__c,Status__c, Human_error__c,Human_Error_excused__c,Human_error_excuse_Justification__c,
                   Assigned_To__c, ChannelOps_user_comment__c, Auto_denial_off_label_use__c, Auto_Denail_late__c,License_Type__c,License_Num__c,Human_Error_Excused_Date__c, AutoDenial_Excused__c, Auto_Denial_Excuse_Justification__c, No_Redundant_System_Excused_Request__c,
                   No_Redundant_System_Excused__c, No_Redundant_System_excuse_justification__c,CatastrophicEvent__c,State__c, Reason_Code__c, Spoilage_Type__c, Return_Method_Exception__c from ChannelOps_Spoilage_Request__c where id=: id];
        
        if(request.Reason_Code__c=='Redundant system not in place') noRedundantSystemError=true;
        else noRedundantSystemError=false;
        
        selectedStatus = previousStatus = request.Status__c;
        isSpoilageRequpdatable = true;
        
        List<ChannelOps_App_Property__c> propertyList = [SELECT Id, SAP_Integration__c FROM ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        isSAPIntegration = (propertyList != null && !propertyList.isEmpty()) ? propertyList[0].SAP_Integration__c : false;
        
        validateSpoilageStatus();
        if(request != null && (request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_SAP_QUOTATION_CREATION_FAILED)){
            displaySection = false;
        }else{
        	displaySection = true;
        }
    }
    
    //This method validates whether spoilage request is updatable or not and set the flag 
    private void validateSpoilageStatus(){
        Set<String> allowedStatuses = (!isSAPIntegration) ? ChannelOps_Constants.STATUS_UPDATE_NOT_ALLOWED_SET1: ChannelOps_Constants.STATUS_UPDATE_NOT_ALLOWED_SET2;
        if(request != null && allowedStatuses.contains(request.Status__c)){
            errorMsg = 'Cannot update the spoilage request in \'' + request.Status__c + '\' status';
            isSpoilageRequpdatable = false;
        }
    }
    
    private Boolean completeAutoDenialExcuse(){
        if(request.AutoDenial_Excused__c==true && (request.Auto_Denial_Excuse_Justification__c==null ||request.Auto_Denial_Excuse_Justification__c.trim()=='')) {
            errorMsg ='Please provide justification for auto denial excuse';
            return false;
        }
        
        return true;
    }
    
    private Boolean completeHumanErrorExcuse(){
        if(request.Human_Error_Excused__c==true && (request.Human_Error_Excuse_Justification__c==null ||request.Human_Error_Excuse_Justification__c.trim()=='')) {
            errorMsg ='Please provide justification for human error excuse';
            return false;
        }
        
        return true;
    }
    
    private Boolean completeNoRedundantSystemErrorExcuse(){
        if(request.No_Redundant_System_Excused__c==true && (request.No_Redundant_System_excuse_justification__c==null ||request.No_Redundant_System_excuse_justification__c.trim()=='')) {
            errorMsg ='Please provide justification for giving excuse to this no redundant system in place caused spoilage';
            return false;
        }
        
        return true;
    }
    
    private void updateStatus(){
        errorMsg ='';
        if(request.Assigned_To__c == null){
            request.Status__c = ChannelOps_Constants.SPOILAGE_STATUS_NEW;
        }else {
            if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_NEW){
                request.Status__c = ChannelOps_Constants.SPOILAGE_STATUS_ASSIGNED; 
            }			
            if(request.Duplicate_Warning__c){
                if((!request.Status__c.containsIgnoreCase(ChannelOps_Constants.SPOILAGE_STATUS_REJECTED)) && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                    errorMsg = 'Please investigate to determine if this is a duplicate request. If this is a duplicate, set Spoilage request status to Rejected. Alternatively set Spoilage request status to Pending Investigation if you need more time to work on this request';
                }
            }else { 
                if(request.GATCF_Product__c) {                  
                    if(request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_FTGPF && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){ 
                        errorMsg = 'Please set Spoilage request status to Forwarded to Genentech Patient Foundation because the product was received from the Genentech Patient Foundation. Alternatively set Spoilage request status to Pending Investigation if you need more time to work on this request';
                    }
                }else {
                    if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_FTGPF){
                        errorMsg ='Can not set spoilage request status to Forwarded to Genentech Patient Foundation when product was not get from the Genentech Patient Foundation';
                    }
                    if(request.Auto_Denail_late__c || request.Auto_Denial_off_label_use__c){
                        if(!request.AutoDenial_Excused__c && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_REJECTED_EMAIL_SENT && request.Status__c!= ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){ 
                            errorMsg = 'Please set Spoilage request status to Rejected-email sent because no excuse was given to its autodenial condition. Alternatively set Spoilage request status to Pending Investigation if you need more time to work on this request';
                        }
                        if(!isSAPIntegration && request.AutoDenial_Excused__c && request.Status__c!='Processing in SAP' && request.Status__c!='Pending Investigation'){
                          errorMsg = 'Please set Spoilage request status to Processing in SAP or Pending Investigation if you need more time to work on this request';
                        }
                        if(isSAPIntegration && request.AutoDenial_Excused__c && request.Status__c!= ChannelOps_Constants.SPOILAGE_STATUS_ASSIGNED && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                        	errorMsg = 'Auto-Denial excuse has been provided. Please set Spoilage request status to Assigned if you would like to send to SAP after saving.  Alternatively, you may set status to Pending Investigation if you need more time to work on this request';
                        }
                    }
                    if(String.isBlank(errorMsg)){						
                        if(request.Quality_Issue__c){
                            if(request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_FTQUAILITY && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                                errorMsg = 'Please set Spoilage request status to Forwarded to Quality because you identified this spoilage was caused by quality issue. Alternatively set Spoilage request status to Pending Investigation if you need more time to work on this request';
                            }
                        }else{
                            if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_FTQUAILITY){
                                errorMsg ='Cannot set spoilage request status to Forwarded to Quality when it is not quality issue';
                            }
                            if(String.isBlank(errorMsg) && request.Human_Error__c){
                                if(!request.Human_Error_Excused__c && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_REJECTED_EMAIL_SENT && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                                    errorMsg = 'Please set Spoilage request status to Rejected-email sent because you identified this spoilage was caused by human error which is not excused. Alternatively set Spoilage request status to Pending Investigation if you need more time to work on this request';
                                }
                                if(!isSAPIntegration && request.Human_Error_Excused__c && request.Status__c!='Processing in SAP' && request.Status__c!='Pending Investigation'){
                                    errorMsg = 'Please set Spoilage request status to Processing in SAP or Pending Investigation if you need more time to work on this request';
                                }
                                if(isSAPIntegration && request.Human_Error_Excused__c && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_ASSIGNED && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                                    errorMsg = 'Human Error excuse has been provided. Please set Spoilage request status to Assigned if you would like to send to SAP after saving. Alternatively, you may set status to Pending Investigation if you need more time to work on this request';
                                }
                            }else{
                            	if(noRedundantSystemError){
                                    if(!request.No_Redundant_System_Excused__c && request.Status__c!= ChannelOps_Constants.SPOILAGE_STATUS_REJECTED_EMAIL_SENT && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                                        errorMsg = 'Please set Spoilage request status to Rejected-email sent because this spoilage was caused by redundant system not in place which is not excused. Alternatively set Spoilage request status to Pending Investigation if you need more time to work on this request';
                                    }
                                    if(!isSAPIntegration && request.No_Redundant_System_Excused__c && request.Status__c!= ChannelOps_Constants.SPOILAGE_STATUS_PROCESSING_IN_SAP && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                                        errorMsg = 'Please set Spoilage request status to Processing in SAP or Pending Investigation if you need more time to work on this request';   
                                    }
                                    if(isSAPIntegration && request.No_Redundant_System_Excused__c && request.Status__c!= ChannelOps_Constants.SPOILAGE_STATUS_ASSIGNED && request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION){
                                        errorMsg = 'Excuse has been provided for Redundant System not in Place. Please set Spoilage request status to Assigned if you would like to send to SAP after saving. Alternatively, you may set status to Pending Investigation if you need more time to work on this request';   
                                    }
                             	}    
                        	}
                    	}
                	}
            	}
        	}
    	}
    }
    
    public PageReference UpdateIt(){
        errorMsg ='';
        if( request.Assigned_To__c !=null && request.Assigned_To__c !=UserInfo.getUserId()){
            errorMsg ='You are not allowed to update a request that is assigned to others.  Assign this request to yourself if you need to make a change.  Alternatively, use the record detail Notes & Attachments section to add a note or attach a file to this record.';
            return null;
        }
        /*if(request.Assigned_To__c!=null){
        request.Reviewed_Date__c= System.now();             
        }*/
        request.Status__c = selectedStatus;
        if(completeAutoDenialExcuse() && completeHumanErrorExcuse() && completeNoRedundantSystemErrorExcuse()){
            updateStatus();
            if(errorMsg!='') return null;
            
            //assigning_history__c is no longer in use
            /*if(request.Assigned_To__c !=null) {
            if(request.assigning_history__c ==null || request.assigning_history__c.trim() =='') request.assigning_history__c='Assigned to '+UserInfo.getName()+'@'+System.now();
            	else request.assigning_history__c+=' | Assigned to '+UserInfo.getName()+' @ '+System.now();
            }else {
            if(request.assigning_history__c ==null || request.assigning_history__c.trim() =='') request.assigning_history__c='Updated by '+UserInfo.getName()+'@'+System.now();
            	else request.assigning_history__c+=' | Updated by '+UserInfo.getName()+'@'+System.now();
            }*/
            upsert request;
            return new Pagereference('/' + request.Id);
        } 
        return null;
    }
    
    public PageReference excuseForHumanError(){  
        errorMsg ='';
        //allowHumanErrorExcuse=true;
        System.debug('--------'+request);
        if(request.Human_error__c==false && request.Human_Error_excused__c==true){
            errorMsg ='Can not give excuse to spoilage request not caused by human error.';
            request.Human_Error_excused__c=false;
            request.Human_Error_Excuse_Justification__c=null;
            request.Human_Error_Excused_Date__c=null;
            return null;
        }
        else if(request.Human_error__c==true && request.Human_Error_excused__c==true){
            
            if(getHumanErrorExcuseLimitation()=='Yes') {
                errorMsg ='Should not give excuse to this request. The customer has been given 3 excuses for human error caused spoilage within 365 days.  Please see Human Error Tracking detail of this request for details.';
                request.Human_Error_excused__c=false;
                //allowHumanErrorExcuse=false;
                request.Human_Error_Excused_Date__c=null;
                request.Human_Error_Excuse_Justification__c=null;
            }else{
                request.Human_Error_Excused_Date__c=System.today();
            }
        }
        
        return null;
    }
    
    public PageReference excuseForNoRedundantSystem(){
        errorMsg ='';
        if(noRedundantSystemError==false && request.No_Redundant_System_Excused__c){
            errorMsg ='No need to give excuse to spoilage request not caused by redundant system not in place.';
            request.No_Redundant_System_excuse_justification__c=null;
            request.No_Redundant_System_Excused__c=false; 
            request.No_Redundant_System_Excused_Date__c=null;               
        }else {
            if(request.No_Redundant_System_Excused_Request__c!=null) {
                errorMsg ='Should not give excuse to this request. This customer has previously been given the limit of one allowed excuse for spoilage caused by Redundant system not in place.';
                request.No_Redundant_System_excuse_justification__c=null;
                request.No_Redundant_System_Excused__c=false; 
                request.No_Redundant_System_Excused_Date__c=null;
            }else request.No_Redundant_System_Excused_Date__c=System.today();
        }
        return null;
    }
    
    public PageReference excuseForAutoDenial(){  
        errorMsg ='';
        if(request.Auto_Denail_late__c==false && request.Auto_Denial_off_label_use__c==false && request.AutoDenial_Excused__c==true){
            errorMsg ='This spoilage request has not been auto denied. No need to give excuse.';
            request.AutoDenial_Excused__c=false;               
        }
        return null;
    }
    
    public PageReference initPage(){  
        if(request.Assigned_To__c ==null && String.isNotBlank(request.Status__c)) {
            request.Assigned_To__c =UserInfo.getUserId();
            request.Reviewed_Date__c= System.now(); 
            
            //upsert request;
        }
        return null;
    }
}