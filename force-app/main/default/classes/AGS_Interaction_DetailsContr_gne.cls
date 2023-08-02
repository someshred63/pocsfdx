public with sharing class AGS_Interaction_DetailsContr_gne {

    ApexPages.StandardController c {get; set;}
    Call2_vod__c parentCall {get; set;}
    
    public List<Call2_vod__c> listAttendees;
    public List<Call2_Discussion_vod__c> listCallDiscussions;
    public List<Call2_Sample_vod__c> lstCallSamples;
    public Boolean hasChilds {get; set;}
    public Boolean hasBrands {get; set;}
    public Boolean hasCallSamples {get; set;}
    public Boolean stylesheet {get; set;}
    
    public AGS_Interaction_DetailsContr_gne(final ApexPages.StandardController controller) {
        parentCall = (Call2_vod__c) (c = controller).getRecord();
        stylesheet = true;
        if (parentCall.Id != null) {
            getListCallDiscussions();
            getListAttendees();
            getLstCallSamples();
        }
    }
    
    public List <Call2_vod__c> getListAttendees() {
        listAttendees = [
            SELECT Name, Account_vod__r.Name, Contact_vod__r.Name, User_vod__r.Name, Attendee_Type_vod__c
            FROM Call2_vod__c WHERE Parent_Call_vod__c = :parentCall.Id
        ];
        if (listAttendees.isEmpty()) {
            List<Call2_vod__c> lst = [SELECT Parent_Call_vod__c FROM Call2_vod__c WHERE Id = :parentCall.Id LIMIT 1];
            listAttendees.addAll(lst.isEmpty() ? new Call2_vod__c[]{ } : [
                SELECT Name, Account_vod__r.Name, Contact_vod__r.Name, User_vod__r.Name, Attendee_Type_vod__c
                FROM Call2_vod__c WHERE Id = :lst[0].Parent_Call_vod__c LIMIT 1
            ]);
        }
        hasChilds = !listAttendees.isEmpty();
        return listAttendees;
    }
    
    public List<Call2_Discussion_vod__c> getListCallDiscussions() {
        listCallDiscussions = [
            SELECT Product_vod__r.Name FROM Call2_Discussion_vod__c WHERE Call2_vod__r.Id = :parentCall.Id
        ];
        hasBrands = !listCallDiscussions.isEmpty();
        return listCallDiscussions;
    }
    
    public List<Call2_Sample_vod__c> getLstCallSamples() {
        lstCallSamples = [
            SELECT Account_vod__r.Name, Call_Date_vod__c, Name, Product_vod__r.Name, Product_Name_gne__c, Quantity_vod__c
            FROM Call2_Sample_vod__c WHERE Call2_vod__r.Id = :parentCall.Id
        ];
        for (Call2_Sample_vod__c cs : lstCallSamples) {
            // AGGSSUP-711: When current user has no access to product
           if (cs.Product_vod__c != null && cs.Product_vod__r == null) {
                cs.Product_vod__r = new Product_vod__c(
                    Name = cs.Product_Name_gne__c,
                    Id = cs.Product_vod__c
                );
            }
        }
        hasCallSamples = !lstCallSamples.isEmpty();
        return lstCallSamples;
    }
}