/**********************************************************************
Purpose: ChannelOps_SpoilageRequest_ControllerExt class is bind with 
         ChannelOps_SpoilageRequest_PDF page. It is used generate the 
		 spoilage request pdf file.
=======================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      					        INITIAL DEVELOPMENT 
1.1      Vijay      09/05/2019      Added logic to toggle the attestation
									section in pdf for draft and submitted
                                    spoilage request.
1.2      Vijay      12/09/2020      Updated class support guest user
                                    security policies
***********************************************************************/
public class ChannelOps_SpoilageRequest_ControllerExt {
    public final ChannelOps_Spoilage_Request__c request {set;get;}
    private List<ChannelOps_Spoilage_Reason_Code_Master__c> reasonCodeMaster;
    private ID requestId;
    public String licenseNumLabel {set; get;}
    public String DEANumLabel {set; get;}
    public String facilityNameLabel {set; get;}
    public String PhysicianFirstName{set; get;}
    public String PhysicianLastName{set; get;}
    public String SectionName{set; get;}
    
    public Boolean noUseOfProduct {set; get;}
    Public Boolean noClaimOfProduct {set; get;}
    Public Boolean PatientOrPayer {set; get;}
    Public Boolean notBilledPatient {set; get;}
    Public Boolean notBilledPayer {set; get;}
    Public Boolean productDisposed {set; get;}
    Public Boolean beyondControl {set; get;}
    Public Boolean displayFormType{set; get;}
    
    public List<ChannelOps_Spoilage_Request_Product__c> requestProducts;
    String reasonDetailAreaLabel;
    public Boolean reasonDetailRequired {set; get;}
    public String CSSubTitle {set; get;}
    private String LyticsFormTitle, ColdStorageFailureFormTitle, SelfAdministeredProductFormTitle, UniversalFormTitle;
    public static Boolean isDraftRequest {get;set;}
    
    public String getGATAStr(){
        if(request.GATCF_Product__c == true) return 'Yes';
        else return 'No';
    }
    
    public String getDepleteInventoryStr(){
        if(request.Depleted_Inventory__c == true) return 'Yes';
        else return 'No';
    }
    
    public String getReasonDetailAreaLabel(){
        return reasonDetailAreaLabel;
    }
    
    private void getReasonCodeInfor() {
        reasonDetailAreaLabel='';
        for(ChannelOps_Spoilage_Reason_Code_Master__c rcm:reasonCodeMaster){
            if(request.Reason__c==rcm.id) {
                reasonDetailAreaLabel= rcm.Reason_Detail_Question_Label__c;   
                reasonDetailRequired =rcm.Explanation_Required__c;
             }         
        }
    }

    public ChannelOps_SpoilageRequest_ControllerExt (){ 
           PageReference curPage=ApexPages.currentPage(); 
       
           if(curPage.getParameters()!=null) {
               requestId=GCS_Util.decryptData(curPage.getParameters().get('id'),GCS_Util.getCryptoKey());
           }
           //else requestId=controller.getRecord().id;
           
           //List<ChannelOps_Spoilage_Request__c > requestList=[select Street_2__c,Spoilage_Type__c, Reason__c,Physician_First_Name__c,Physician_Last_Name__c,Pharmacy_Reference_Num__c,GATCF_Product__c,Adverse_Event__c,Depleted_Inventory__c, Status__c  from ChannelOps_Spoilage_Request__c where id=:requestId];

           List<ChannelOps_Spoilage_Request__c > requestList= [SELECT  Adverse_Event__c,Assigned_To__c,AutoDenial_Excused__c,Auto_Denail_late__c,
                                                                        Auto_Denial_Excuse_Justification__c,Auto_Denial_off_label_use__c,
                                                                        CatastrophicEvent__c,ChannelOps_user_comment__c,City__c,Confirmation_Email_Sent__c,
                                                                        Conformation_email_sent_at__c,Contact_Email__c,Contact_Fax__c,Contact_First_Name__c,Contact_Last_Name__c,
                                                                        Contact_Middle_Name__c,Contact_Name__c,Contact_Phone__c,
                                                                        CreatedById,CreatedDate,Date_of_Spoilage__c,Depleted_Inventory__c,
                                                                        Do_Not_Deliver_On__c,Duplicate_Warning__c,Ending_Time__c,Facility_DEA__c,
                                                                        Facility_Name__c,GATCF_Product__c,HCP_Name__c,Human_Error_Excused_Date__c,
                                                                        Human_Error_Excused__c,Human_Error_Excuse_Justification__c,Human_Error__c,Id,                                           
                                                                        License_Num__c,License_Type__c,Name,No_Redundant_System_Excused_Date__c,
                                                                        No_Redundant_System_Excused_Request__c,No_Redundant_System_Excused__c,No_Redundant_System_excuse_justification__c,
                                                                        Other_Title__c,OwnerId,Page_Visited__c,PDF_Attachment_ID__c,
                                                                        Pharmacy_Reference_Num__c,Physician_First_Name__c,Physician_Last_Name__c,
                                                                        Possible_Duplicate_Request_ID__c,Quality_Issue__c,Reason_Code__c,
                                                                        Reason_Detail_2__c,Reason_Detail__c,Reason__c,request_IP__c,
                                                                        Return_Method_Detail__c,Return_Method__c,Reviewed_Date__c,SAP_Reason_Code__c,
                                                                        Signature_Signed__c,Spoilage_Type__c,Starting_Time__c,State__c,Status__c,
                                                                        Street_2__c,Street_Name__c,Submission_Date__c,Title_credential__c,
                                                                        Title_String__c,Zip__c,Reason__r.Spoilage_Reason__c,Tracking_of_original_order__c,Tracking_of_replacement_shipment__c,
                                                                        Case_ID__c,Replacement_Unit_Shipped__c
                                                             FROM       ChannelOps_Spoilage_Request__c 
                                                             WHERE      id=:requestId];
           if(requestList!=null && requestList.size()>0) request=requestList[0];
           if(request.Spoilage_Type__c=='Lytics Spoilage'){
               licenseNumLabel = 'Facility State License #:';
               facilityNameLabel='Facility Name :';
               DEANumLabel='Facility DEA #:';
               SectionName ='Physician Information';
           }else if(request.Spoilage_Type__c=='Cold Storage Failure') {
               licenseNumLabel = 'Physician License #:';
               facilityNameLabel='Facility Name :';
               DEANumLabel='Physician DEA #:';
               PhysicianFirstName='Physician First Name:';
               PhysicianLastName='Physician Last Name:';
               SectionName ='Physician Information';
           }else if(request.Spoilage_Type__c=='Self-Administered Product Spoilage') {
               licenseNumLabel = 'Pharmacy License #:';
               facilityNameLabel='Pharmacy Name:';
               DEANumLabel='Pharmacy DEA #:';
               PhysicianFirstName='Prescribing Physician First Name:';
               PhysicianLastName='Prescribing Physician Last Name:';
               SectionName ='Pharmacy Information';
           }else {
               licenseNumLabel = 'Physician License #:';
               facilityNameLabel='Facility Name:';
               DEANumLabel='Physician DEA #:';
               PhysicianFirstName='Physician First Name:';
               PhysicianLastName='Physician Last Name:';
               SectionName ='Physician Information';
           }
           //for attestation language 
                noUseOfProduct = true ;
                noClaimOfProduct = true ;
                PatientOrPayer = true ;
                notBilledPatient = true ;
                notBilledPayer = true ;
                productDisposed = true ;
                beyondControl = true ;
                displayFormType= true ;
                  //load application properties
       ChannelOps_App_Property__c property=[select ColdStorageFailureFormTitle__c,  LyticsFormTitle__c, SelfAdministeredProductFormTitle__c, UniversalFormTitle__c,CS_subTitle__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
       LyticsFormTitle = property.LyticsFormTitle__c;
       ColdStorageFailureFormTitle=property.ColdStorageFailureFormTitle__c;
       SelfAdministeredProductFormTitle=property.SelfAdministeredProductFormTitle__c;
       UniversalFormTitle=property.UniversalFormTitle__c;
       CSSubTitle =property.CS_subTitle__c;
           
           reasonCodeMaster=[select Brand__c, Spoilage_Reason__c, SAP_Reason_Code__c, Active__c, Explanation_Required__c, Reason_Detail_Question_Label__c from ChannelOps_Spoilage_Reason_Code_Master__c where Active__c=true order by Spoilage_Reason__c];          
           getReasonCodeInfor();
        if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_DRAFT){
            isDraftRequest = true;
        }else{
            isDraftRequest = false;
        }
    }
    
    /*Static String LyticsFormTitle = 'Genentech Spoilage Program Online Submission Form for Activase (alteplase) and/or TNKase (tenecteplase)';
    Static String ColdStorageFailureFormTitle = 'Cold Storage Failure Spoilage Online Submission Form';
    Static String SelfAdministeredProductFormTitle = 'Genentech Spoilage Program Online Submission Form for Self-Administered Product';
    Static String UniversalFormTitle = 'Genentech Spoilage Program Online Submission Form';
    */
    
    public string getFormTitle(){
        if(request.Spoilage_Type__c=='Lytics Spoilage') return LyticsFormTitle;
        else if(request.Spoilage_Type__c=='Cold Storage Failure') return ColdStorageFailureFormTitle ;
        else if (request.Spoilage_Type__c=='Self-Administered Product Spoilage') return SelfAdministeredProductFormTitle;
        return UniversalFormTitle;
    }
    
    public List<ChannelOps_Spoilage_Request_Product__c> getRequestProducts(){
        requestProducts=[select brand__c,Product_Name__c,NDC__c,Lot_Number__c,Serial_Number__c,Quantity__c,Indication__c,Other_Indication__c from ChannelOps_Spoilage_Request_Product__c where Spoilage_Request__c =:request.id];
        return requestProducts;
    }
    
    public void setRequestProducts (List<ChannelOps_Spoilage_Request_Product__c> l){
        requestProducts=l;
    }
    
        
    public List<SelectOption> getReasonCodeSelections(){
        
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        
        //no spoilage reason selection should be displayed when no product is included in the spoilage request
        if(requestProducts==null || requestProducts.size()<=0) {                
           // clearReasonCodeSelection();
            return optionsToReturn;
        }
        
            
        for(ChannelOps_Spoilage_Reason_Code_Master__c rcm:reasonCodeMaster){
            Boolean includeIt=true;
            
            for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                if(rcm.Brand__c.containsIgnoreCase(rp.brand__c)==false) {
                    includeIt=false;
                    break;
                }
            }
            
            if(includeIt){
                SelectOption op=new SelectOption(rcm.id, rcm.Spoilage_Reason__c);
                optionsToReturn.add(op);       
            }
        }

      
        return optionsToReturn;
    }

}