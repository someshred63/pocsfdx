public without sharing class SPLOA_Req_Stage_Controller {

    public void updatemainreq(List<C_Ops_IAP_Requests_Stage__c> oldList , List<C_Ops_IAP_Requests_Stage__c> newList){
        List<C_Ops_SPLOA_Request__c> mainreqlist = new List<C_Ops_SPLOA_Request__c>();
        for(C_Ops_IAP_Requests_Stage__c reqstage : newList){
            if(reqstage.SPLOA_Parent_Process_Request__c!= null &&  reqstage.Main_Req__c != null && reqstage.Renew_Request_Submitted__c == true && reqstage.Type_of_action__c == 'Renew' ){
                C_Ops_SPLOA_Request__c mainreq = new C_Ops_SPLOA_Request__c();
                mainreq.Id = reqstage.Main_Req__c;
               // mainreq.SPLOA_Parent_Process_Request__c = reqstage.SPLOA_Parent_Process_Request__c;
                mainreq.Processed_Request__c = reqstage.SPLOA_Parent_Process_Request__c;
                mainreq.Renew_Request_Submitted__c  = true  ;
                mainreqlist.add(mainreq);
            }
            else if(reqstage.Added_New_Site_s__c  == true && reqstage.Type_of_action__c == 'Site'){
                C_Ops_SPLOA_Request__c mainreq = new C_Ops_SPLOA_Request__c();
                mainreq.Id = reqstage.Main_Req__c;
                mainreq.Added_New_Site_s__c  = true  ;
                mainreqlist.add(mainreq);
            }
            //Updating the correction Request
            else if(reqstage.Added_New_Site_s__c  == false && reqstage.Renew_Request_Submitted__c == false && reqstage.Type_of_action__c == 'Correction'){
              	C_Ops_SPLOA_Request__c mainreq = new C_Ops_SPLOA_Request__c();
                mainreq.Id = reqstage.Main_Req__c;
                mainreq.Submission_Date__c   = reqstage.Submission_Date__c   ;
                mainreq.Signee_First_Name__c = reqstage.Signee_First_Name__c;
                mainreq.Signee_Last_Name__c = reqstage.Signee_Last_Name__c;
                mainreq.Signee_Title__c = reqstage.Signee_Title__c;
                mainreq.Submission_Date_Time__c = reqstage.Submission_Date_Time__c;
                mainreq.C_Ops_SPLOA_First_Name__c= reqstage.C_Ops_SPLOA_First_Name__c;
                mainreq.C_Ops_SPLOA_Last_Name__c= reqstage.C_Ops_SPLOA_Last_Name__c;
                mainreq.C_Ops_SPLOA_Phone__c= reqstage.C_Ops_SPLOA_Phone__c;
                mainreq.C_Ops_SPLOA_Extension__c =  reqstage.C_Ops_SPLOA_Extension__c ;
                mainreq.C_Ops_SPLOA_Fax__c = reqstage.C_Ops_SPLOA_Fax__c ;
                mainreq.C_Ops_SPLOA_Email__c  = reqstage.C_Ops_SPLOA_Email__c  ;
                mainreq.C_Ops_SPLOA_Primary_Distributor__c = reqstage.C_Ops_SPLOA_Primary_Distributor__c ;
                mainreq.C_Ops_SPLOA_Pharmacy_Name__c = reqstage.C_Ops_SPLOA_Pharmacy_Name__c ;
                mainreq.C_Ops_SPLOA_DEA_Number__c = reqstage.C_Ops_SPLOA_DEA_Number__c ;
                mainreq.C_Ops_SPLOA_Street_Address__c = reqstage.C_Ops_SPLOA_Street_Address__c ;
                mainreq.C_Ops_SPLOA_Street_Address_2__c = reqstage.C_Ops_SPLOA_Street_Address_2__c ;
                mainreq.C_Ops_SPLOA_City__c = reqstage.C_Ops_SPLOA_City__c ;
                mainreq.State__c = reqstage.State__c ;
                mainreq.C_Ops_SPLOA_Zip__c = reqstage.C_Ops_SPLOA_Zip__c ;
                mainreq.Website_URL__c = reqstage.Website_URL__c ;
                mainreqlist.add(mainreq);
            }
        }
        
        if(mainreqlist != null && mainreqlist.size()>0){
            Update mainreqlist;
        }
    }
}