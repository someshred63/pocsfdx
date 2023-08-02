public class GNE_MCCO_FRM_Cases_wo_PAN {

    public List<Case> case_list = new List<Case>();

    public GNE_MCCO_FRM_Cases_wo_PAN (ApexPages.StandardSetController controller) {

        String usr_profile = ApexPages.currentPage().getParameters().get('usr_prof');
        Id usr_id = ApexPages.currentPage().getParameters().get('usr_id');
        Id account_id = ApexPages.currentPage().getParameters().get('act_id');
        List<String> ter_list = new List<String>();


        List<UserTerritory2Association> usr_ter = new List<UserTerritory2Association>([select Territory2Id from UserTerritory2Association where UserId=:usr_id]);
        system.debug('Terr list size: '+usr_ter.size());

        for (UserTerritory2Association u_x : usr_ter) {
        	ter_list.add(u_x.Territory2Id);
        }

        List<Group> grp_l = new List<Group>([select id, relatedId from Group where relatedId in :ter_list and type='Territory']);
        system.debug('Groups: '+grp_l);
        List<AccountShare> act_sh = new List<AccountShare>([select Id, UserorGroupId, AccountId from AccountShare where AccountId =:account_id and UserorGroupId in :grp_l]);
        system.debug('AccountShare: '+act_sh);
        if (act_sh.size() > 0 || usr_profile.contains('Manager')) {

    system.debug('did we make it?');

            List<String> prod_list = new List<String>();
            List<User_Group_Product_gne__c> ugp_list = new List<User_Group_Product_gne__c>([select Product_gne__c from User_Group_Product_gne__c where Profile_gne__c like :usr_profile]);
                for (Integer i=0; i<ugp_list.size(); i++) {
                    prod_list.add(ugp_list[i].Product_gne__c);
                }

            case_list = [select CaseNumber, RecordType.Name, Case_Manager__c, PAN_Form_Signed_gne__c, Product_gne__c, Case_Treating_Physician_gne__c, Practice_gne__c, CreatedDate, Status, lastModifiedDate from Case where PAN_Form_Signed_gne__c='No' and Product_gne__c in : prod_list and (RecordType.Name='C&R - Continuous Care Case' or RecordType.Name='C&R - Standard Case') and (Practice_gne__c =:account_id or Case_Treating_Physician_gne__c =:account_id or Facility_gne__c =:account_id)  order by lastModifiedDate desc limit 500];
        }

    }

    public List<Case> getCases () {

        return case_list;
    }

    public Integer getCase_Size() {

        return case_list.size();
        }


}