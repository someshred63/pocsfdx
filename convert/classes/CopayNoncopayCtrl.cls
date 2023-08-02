public class CopayNoncopayCtrl{
public boolean applicationReadonly{get;set;}
public boolean orgEditable{get;set;}
public boolean orgEditableCopay{get;set;}

    public CopayNoncopayCtrl(ApexPages.StandardController controller) {
    string userid = userinfo.getuserId();
    list<GFRS_CopayUser__c> lstcopayuser = new list<GFRS_CopayUser__c>();
    lstcopayuser = [select User__c from GFRS_CopayUser__c where User__c=: userid ];
    
    if(lstcopayuser.size()>0){
    
     List<GFRS_Funding_Request__c> listOfTempRequests=new List<GFRS_Funding_Request__c>( [
            select Funding_Sub_Type__c,Id, Name, CreatedDate, Event_Program_Title__c, Date_Submitted__c, Evaluation_submitted_date__c , Requested_Amount__c, Sub_Status__c, External_Sub_status__c, Status__c, Record_Type_Name__c, Organization__c,LOA_Signed__c,Location__c,LOA_PDF__c,Authorized_Signer__c
            from GFRS_Funding_Request__c
            where Authorized_Signer__c = :userId or OwnerId = :userId
            order by Date_Submitted__c desc,CreatedDate desc
        ]);
     if(listOfTempRequests.size()>0){
     orgEditable = false;
     }
     else{
     orgEditable = true;
     }   
    
     List<GFRS_copay_Funding_Request__c> listOfTempRequestscopay=new List<GFRS_copay_Funding_Request__c>( [
            select Funding_Sub_Type__c,Id, Name, CreatedDate, Event_Program_Title__c, Date_Submitted__c, Evaluation_submitted_date__c , Requested_Amount__c, Requested_Amount1__c,  Sub_Status__c, External_Sub_status__c, Status__c, Record_Type_Name__c, Organization__c,LOA_Signed__c, Locationcopay__c,LOA_PDF__c,Authorized_Signer__c
            from GFRS_copay_Funding_Request__c
            where Authorized_Signer__c = :userId or OwnerId = :userId
            order by Date_Submitted__c desc,CreatedDate desc
        ]);
      if(listOfTempRequestscopay.size()>0){
     orgEditableCopay = false;
     }
     else{
     orgEditableCopay = true;
     } 
     
     
      string copayrequestid = ApexPages.currentPage().getParameters().get('id');
     
     
      if(copayrequestid != null){
       Id sampleid = copayrequestid;
      if(sampleid.getsobjecttype() == Schema.GFRS_copay_Funding_Request__c.SObjectType){
      if(copayrequestid != null){
      GFRS_copay_Funding_Request__c copayrequest = [select Information_Needed__c from GFRS_copay_Funding_Request__c where id =: copayrequestid]; 
      if(copayrequest.Information_Needed__c != null){
      orgEditableCopay = gFRS_Util.multiSelectHasItem( copayrequest.Information_Needed__c, 'Organization' );
      }
      }
      }
      }
        
    
    }
    }


}