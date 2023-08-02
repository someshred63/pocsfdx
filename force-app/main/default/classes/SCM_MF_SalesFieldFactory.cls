public class SCM_MF_SalesFieldFactory {

    // commented - cannot use class level variable
    // for this purpose
    // private static List<User> users;

    private static String getProductCode(String Product){
        return SCM_Security.getEnvironmentVariable('SCM_SFAPrefix'+ product);
    }

    private static string getCaseAlignedRepProfileName(String Product) {
        return SCM_Security.getEnvironmentVariable('SCM_SFAProfile'+ product);
    }

    public static List<User> getSalesRep(Case selectedCase)
    {

        List<User> users = new List<User>();


            String caseTerritoryPrefix = getProductCode(selectedCase.Product_gne__c);
            if ( caseTerritoryPrefix == null )
                return users;

            System.debug ( 'Territory prefix for Product > ' + selectedCase.Product_gne__c +
                           ' --> ' + caseTerritoryPrefix);

            Map<Id, Territory2> territoryMap = new Map<Id, Territory2>([select id, name
                                                                     from Territory2
                                                                     where external_id_gne__c like :caseTerritoryPrefix ]);


            System.debug ('number of ' + selectedCase.Product_gne__c  +
                          ' territories   --> ' + territoryMap.size() );

            Map<id,Group> groupMap = new Map<Id,Group>([select id, relatedId from group
                                                        where     type ='Territory'
                                                              and relatedId in :territoryMap.keySet()]);

            List<AccountShare> acctShareList = [select accountId, userorgroupid from accountshare
                                                where     accountId = :selectedCase.Case_Treating_Physician_gne__c
                                                      and userorgroupId in :groupMap.keySet()];


            Set<Id> territoryIdSet =new Set<Id>(); // unique/distinct territories for this brand the physician belongs
            for (AccountShare ac : acctShareList) {
                territoryIdSet.add ( groupMap.get(ac.UserOrGroupId).relatedId);
            }

            System.debug ('Distinct Territory for Case Treating Physician --> ' + territoryIdSet );

            string profileName = getCaseAlignedRepProfileName(selectedCase.Product_gne__c);

            if ( territoryIdSet.size() > 0 && profileName != null ) {

                Set<Id> salesRepIdSet = new Set<Id> (); // all salesforce user Ids aligned to teritoryIdSet
                for (UserTerritory2Association ut : [select userId from UserTerritory2Association where Territory2Id in :territoryIdSet]) {
                    salesRepIdSet.add ( ut.userid );
                }

                Map <Id, Profile> profileMap = new Map<Id,Profile>( [select id, name from profile where name = :profileName]);

                for ( User u : [select id, name, email,FirstName,LastName, profileId
                                from user
                                where     isactive = true
                                      and id in :salesRepIdSet
                                      and profileId in :profileMap.keySet()] ) {

                    users.add (u);
                    break;
                }
            }

         return users;
     }

    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;

        return mf;
    }

    public static SCM_MergeField SalesRepName(Case SelectedCase)
    {
        SCM_MergeField mf = createMergeField('SalesRepName');
        List<User> usr = getSalesRep(SelectedCase);

        String fullName='';

        if (null != usr)
        {
            if (usr.size() >=1)
            {
            fullName = usr[0].Name;

            }

         mf.fieldValue = fullName;
        }
        return mf;
    }

    public static SCM_MergeField SalesRepEmail(Case SelectedCase)
    {
        SCM_MergeField mf = createMergeField('SalesRepEmail');
        List<User> usr = getSalesRep(SelectedCase);

        String email='';
        if ((null != usr) && (usr.size() >=1))
        {
            email =(usr[0].Email == null)? '': usr[0].Email ;
        }

         mf.fieldValue = email;

        return mf;
    }

}