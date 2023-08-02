public class GNE_MCCO_FRM_View_GATCF_Cases {
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                String usr_profile = ApexPages.currentPage().getParameters().get('usr_prof');
                Id usr_id = ApexPages.currentPage().getParameters().get('usr_id');

                List<String> ter_list = new List<String>();
                List<UserTerritory2Association> usr_ter = new List<UserTerritory2Association>([select Territory2Id from UserTerritory2Association where UserId=:usr_id]);

                for (UserTerritory2Association u_x : usr_ter) {
                    ter_list.add(u_x.Territory2Id);
                }
               List<Group> grp_l = new List<Group>([select id, relatedId from Group where relatedId in :ter_list and type='Territory']);
               List<AccountShare> act_sh = new List<AccountShare>([select Id, UserorGroupId, AccountId from AccountShare where UserorGroupId in :grp_l]);
               Set<Id> AccountIds = new Set<Id>();
               for (AccountShare a : act_sh){
                    if (!AccountIds.contains(a.AccountId))
                        AccountIds.add(a.AccountId);
               }

               if (act_sh.size() > 0 ||usr_profile.contains('Manager')){
                    List<String> prod_list = new List<String>();
                    List<User_Group_Product_gne__c> ugp_list = new List<User_Group_Product_gne__c>([select Product_gne__c from User_Group_Product_gne__c where Profile_gne__c like :usr_profile]);

                    for (Integer i=0; i<ugp_list.size(); i++){
                        prod_list.add(ugp_list[i].Product_gne__c);
                    }

                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select CaseNumber, RecordType.Name, Product_gne__c, GATCF_Status_gne__c, Status, lastModifiedDate from Case where Product_gne__c in : prod_list and (Practice_gne__c in :AccountIds or Case_Treating_Physician_gne__c in :AccountIds or Facility_gne__c in :AccountIds) and (RecordType.Name='GATCF - Standard Case' or RecordType.Name='GATCF - Eligibility Screening') and PAN_Form_Signed_gne__c='Yes' order by lastModifiedDate desc limit 10000]));

               }//if

            }

            if (setCon != Null)
                return setCon;
            else
                return null;
        }
        set;
    }

    public List<Case> getCases() {
        if (setCon != Null){
            setCon.setPageSize(100);
            return (List<Case>) setCon.getRecords();
        }
        else
            return null;
    }

    public Integer getCase_Size(){
        if (setCon != Null)
            return setCon.getResultSize();
        else
            return 0;
    }

        // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }

    // returns the first page of records
    public void first() {
        setCon.first();
    }

    // returns the last page of records
    public void last() {
        setCon.last();
    }

    // returns the previous page of records
    public void previous() {
        setCon.previous();
    }

    // returns the next page of records
    public void next() {
        setCon.next();
    }
}