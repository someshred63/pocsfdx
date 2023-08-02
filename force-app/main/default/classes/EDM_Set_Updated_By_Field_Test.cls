@isTest
public class EDM_Set_Updated_By_Field_Test {

    @isTest
    public static void updateClassificationRequest() {

        initData();

        List<EDM_Classification_Request_gne__c> crList = [
                SELECT Id, Name, EDM_Action_Comments_gne__c, EDM_Commented_By_gne__c
                FROM EDM_Classification_Request_gne__c
        ];

        for(EDM_Classification_Request_gne__c cr : crList) {
            System.debug('cr: ' + cr);
        }

        EDM_Classification_Request_gne__c crWithCommentedUser = crList.get(0);
        crWithCommentedUser.EDM_Action_Comments_gne__c = 'Comment 1';
        update crWithCommentedUser;

        EDM_Classification_Request_gne__c crWithoutCommentedUser = crList.get(1);
        update crWithoutCommentedUser;

        List<EDM_Classification_Request_gne__c> crListAfterUpdate = [
                SELECT Id, Name, EDM_Action_Comments_gne__c, EDM_Commented_By_gne__c
                FROM EDM_Classification_Request_gne__c
        ];

        for(EDM_Classification_Request_gne__c cr : crListAfterUpdate) {
            if(String.isNotBlank(cr.EDM_Action_Comments_gne__c)) {
                System.assert(String.isNotBlank(cr.EDM_Commented_By_gne__c));
            } else {
                System.assert(String.isBlank(cr.EDM_Commented_By_gne__c));
            }

        }

    }

    private static void initData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= 3; i++) {
            accounts.add(new Account(Name='testAccount' + i));
        }
        insert accounts;

        RecordType rtBusiness = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Business'];
        RecordType rtClinical = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Clinical'];

        List<EDM_Classification_Request_gne__c> classReqs = new List<EDM_Classification_Request_gne__c> {
                prapareTestClassReq(accounts.get(0), rtClinical),
                prapareTestClassReq(accounts.get(1), rtBusiness)
        };

        insert classReqs;
    }
    private static EDM_Classification_Request_gne__c prapareTestClassReq(Account acc, RecordType rt) {
        return new EDM_Classification_Request_gne__c(
                EDM_Account_gne__c = acc.Id,
                EDM_Type_of_Classification_gne__c = rt.DeveloperName,
                RecordTypeId = rt.Id,
                EDM_Pending_Days_gne__c = 0
        );
    }

}