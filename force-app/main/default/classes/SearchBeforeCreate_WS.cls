global class SearchBeforeCreate_WS {


    static string serializeMapStringString(Map<string,string> mapx){
        string ret='';
        Set<string> keySet=mapx.keySet();
        integer i=0;
        for(string s:keySet){
            i++;
            ret+='"'+ s+ '"' + ':';
            ret += '"'+mapx.get(s)+'"'+((i==keySet.size())?'':',');
        }
        return '{' + ret + '}';
    }

    static string serializeListMapStringString(List<Map<string,string>> listx){
        string ret='';
        for(integer i=0;i<listx.size();i++){
            ret+='"'+String.valueOf(i)+'"' +':' +serializeMapStringString(listx[i]) +((i==listx.size()-1)?'':',');
        }
        return '{' + ret + '}';
    }
    static string serializeMapStringListMapStringString (Map<string,List<Map<string,string>>> mapx){
        string ret='';
        Set<string> keySet=mapx.keySet();
        integer i=0;
        for(string s:keySet){
            i++;
            ret+='"'+s+'"' +':' + serializeListMapStringString(mapx.get(s))+((i==keySet.size())?'':',');
        }
        return '{' + ret + '}';
    }
    WebService static List<Account> searchMDMAccount (  String lastName,
                                                        String city,
                                                        String state,
                                                        String recordType) {

        List<Account> ret=new List<Account>();
        return ret;
    }
    WebService static string searchMDMAccount2 (    String firstName,
                                                        String lastName,
                                                        String city,
                                                        String state,
                                                        boolean isPro) {


        Map<string,List<Map<string,string>>> ret=new Map<string,List<Map<string,string>>>();

        mdm0620MDMProxyService.MdmProxyPortType mdmPort=new mdm0620MDMProxyService.MdmProxyPortType();
        if(city != null && city != ''){
            city=city+'%';
        }
        else{
            city='';
            }
        if(firstName != null && firstName != ''){
            lastName = firstName + ' ' + lastName;
        }
        mdmPort.Timeout_x = 30000;
        if(isPro){

            System.debug ('Web service call started -> ');
            mdm0620SearchIndividualAcctRS.IndividualAccountItemType[] mdmAccts= mdmPort.searchIndividualAccount(
                                                                                        null,
                                                                                        lastName,
                                                                                        null,
                                                                                        state,
                                                                                        city,
                                                                                        null,
                                                                                        50);
            System.debug ('Web service call ended -> ');


            if(mdmAccts!=null){
                System.debug ('mdmAccts.size() -> ' + mdmAccts.size());
                for(mdm0620SearchIndividualAcctRS.IndividualAccountItemType mdmAcct:mdmAccts){
                    List<Map<string,string>> srlz;
                    if(ret.containsKey(mdmAcct.mdmId)) { //Did i already found this mdm_id?
                        srlz=ret.get(mdmAcct.mdmId);
                        if(srlz[0].containsKey('Id')) continue; //If this so is an account in SFDC
                        Map<string,string> accAdd=new Map<string,string>(); //Else add the address
                        accAdd.put('Name',mdmAcct.primaryStreetAddress);
                        accAdd.put('City_vod__c',mdmAcct.city);
                        accAdd.put('State_vod__c',mdmAcct.state);
                        accAdd.put('Zip_vod__c',mdmAcct.postalCode);
                        accAdd.put('MDM_Address_ID_gne',mdmAcct.partyAddressId.trim());
                        srlz.add(accAdd);
                    } else{  //I Did not found this mdm_id yet
                        srlz=new List<Map<string,string>>();
                        ret.put(mdmAcct.mdmId,srlz);
                        List<Account> accts=[   Select a.Name, a.FirstName, a.Id, a.LastName, a.PersonEmail, a.PersonTitle, a.Salutation, a.RecordTypeId ,
                        (Select Account_vod__c, Name, Address_line_2_vod__c,
                        City_vod__c, Country_gen__c, State_vod__c, Zip_vod__c From Address_vod__r) from Account a where a.MDMID_gne__c=:mdmAcct.mdmId];
                        if(accts.size()>0){ //Is this in SFDC? if yes add it to my list
                            Map<string,string> acc=new Map<string,string>();
                            srlz.add(acc);
                            acc.put('MDMID_gne__c',mdmAcct.mdmId);
                            acc.put('FirstName',accts[0].FirstName);
                            acc.put('LastName',accts[0].LastName);
                            acc.put('Id',accts[0].Id);

                            for(Address_vod__c add:accts[0].Address_vod__r){//with addresses
                                Map<string,string> accAdd=new Map<string,string>();
                                accAdd.put('Name',add.Name);
                                accAdd.put('City_vod__c',add.City_vod__c);
                                accAdd.put('State_vod__c',add.State_vod__c);
                                accAdd.put('Zip_vod__c',add.Zip_vod__c);
                                srlz.add(accAdd);
                            }
                        } else {//Is not in SFDC
                            Map<string,string> acc=new Map<string,string>();
                            srlz.add(acc);
                            acc.put('MDMID_gne__c',mdmAcct.mdmId);
                            acc.put('FirstName',mdmAcct.individualFirstName);
                            acc.put('LastName',mdmAcct.individualFamilyName);
                            Map<string,string> accAdd=new Map<string,string>();
                            accAdd.put('Name',mdmAcct.primaryStreetAddress);
                            accAdd.put('City_vod__c',mdmAcct.city);
                            accAdd.put('State_vod__c',mdmAcct.state);
                            accAdd.put('Zip_vod__c',mdmAcct.postalCode);
                            accAdd.put('MDM_Address_ID_gne',mdmAcct.partyAddressId.trim());
                            srlz.add(accAdd);
                        }
                    }
                }
            }
            return serializeMapStringListMapStringString(ret);
        } else {
            mdm0620SearchOrgAcctRS.OrganizationAccountItemType[] mdmAccts= mdmPort.searchOrganizationAccount(
                                                                                        lastName,
                                                                                        null,
                                                                                        city,
                                                                                        state,
                                                                                        null,
                                                                                        50);
            if(mdmAccts!=null){
                for(mdm0620SearchOrgAcctRS.OrganizationAccountItemType mdmAcct:mdmAccts){
                    List<Map<string,string>> srlz;
                    if(ret.containsKey(mdmAcct.mdmId)) { //Did i already found this mdm_id?
                        srlz=ret.get(mdmAcct.mdmId);
                        srlz[0].put('RecordType',mdmAcct.organizationUrl);
                        if(srlz[0].containsKey('Id')) continue; //If this so is an account in SFDC
                        Map<string,string> accAdd=new Map<string,string>(); //Else add the address
                        accAdd.put('Name',mdmAcct.primaryStreetAddress);
                        accAdd.put('City_vod__c',mdmAcct.city);
                        accAdd.put('State_vod__c',mdmAcct.state);
                        accAdd.put('Zip_vod__c',mdmAcct.postalCode);
                        accAdd.put('MDM_Address_ID_gne',mdmAcct.partyAddressId.trim());

                        srlz.add(accAdd);
                    } else{  //I Did not found this mdm_id yet
                        srlz=new List<Map<string,string>>();
                        ret.put(mdmAcct.mdmId,srlz);
                        List<Account> accts=[   Select a.Name, a.FirstName, a.Id, a.LastName, a.PersonEmail, a.PersonTitle, a.Salutation, a.RecordTypeId ,
                        (Select Account_vod__c, Name, Address_line_2_vod__c,
                        City_vod__c, Country_gen__c, State_vod__c, Zip_vod__c From Address_vod__r) from Account a where a.MDMID_gne__c=:mdmAcct.mdmId];
                        if(accts.size()>0){ //Is this in SFDC? if yes add it to my list
                            Map<string,string> acc=new Map<string,string>();
                            srlz.add(acc);
                            acc.put('MDMID_gne__c',mdmAcct.mdmId);
                            acc.put('Name',accts[0].Name);
                            acc.put('Id',accts[0].Id);
                            acc.put('RecordType',mdmAcct.organizationUrl);
                            for(Address_vod__c add:accts[0].Address_vod__r){//with addresses
                                Map<string,string> accAdd=new Map<string,string>();
                                accAdd.put('Name',add.Name);
                                accAdd.put('City_vod__c',add.City_vod__c);
                                accAdd.put('State_vod__c',add.State_vod__c);
                                accAdd.put('Zip_vod__c',add.Zip_vod__c);
                                srlz.add(accAdd);
                            }
                        } else {//Is not in SFDC
                            Map<string,string> acc=new Map<string,string>();
                            srlz.add(acc);
                            acc.put('MDMID_gne__c',mdmAcct.mdmId);
                            acc.put('Name',mdmAcct.organizationFullName);
                            acc.put('RecordType',mdmAcct.organizationUrl);//<-----

                            Map<string,string> accAdd=new Map<string,string>();
                            accAdd.put('Name',mdmAcct.primaryStreetAddress);
                            accAdd.put('City_vod__c',mdmAcct.city);
                            accAdd.put('State_vod__c',mdmAcct.state);
                            accAdd.put('Zip_vod__c',mdmAcct.postalCode);
                            accAdd.put('MDM_Address_ID_gne',mdmAcct.partyAddressId.trim());
                            srlz.add(accAdd);
                        }
                    }
                }
            }
            return serializeMapStringListMapStringString(ret);
        }
    }

    WebService static List<Territory2> getUserTerritories(string userID){
        List<Territory2> ters=new List<Territory2>();
        Set<String> TerritoryIds=new Set<String>();
        List<UserTerritory2Association> uts= [Select u.Territory2Id, u.UserId from UserTerritory2Association u where u.UserId=:userID];
        for(UserTerritory2Association ut:uts){
            if  (ut.Territory2Id != null && TerritoryIds.contains(ut.Territory2Id) == False) {
                TerritoryIds.add(ut.Territory2Id);
            }

        }
        ters = [Select t.Id, t.Name from Territory2 t where t.Id in :TerritoryIds];
        return ters;
    }


    WebService static List<Account> searchSFAPersonAccount (String firstName, String lastName, String city, String state, List<Id> recordTypeIds, boolean isPro) {
        List<Account> res=new List<Account>();
        //Map<string,Account> mapAccs=new Map<string,Account>();
        Set<id> acctIds =new Set<Id>();



        String orgName = '%' + lastName + '%';
        String personLastName = lastName + '%';

        String orgName1=null;
        String personFirstName=null;



        if(city != null && city != ''){
            city=city+'%';
        }
        else{
            city='%';
        }

        if(firstName != null && firstName != ''){
            orgName1 = '%' + firstName + '%';
            personFirstName = firstName + '%';
        }

        List<Address_vod__c> adds = new List<Address_vod__c> ();
        if(isPro){
            if(firstName != null && firstName != ''){
                adds=[ Select a.id,
                                a.Account_vod__r.Name, a.Account_vod__r.FirstName, a.Account_vod__r.Id, a.Account_vod__r.LastName, a.Account_vod__r.recordTypeId
                                from Address_vod__c a where
                                a.City_vod__c like :city and
                                a.State_vod__c = :state and
                                a.Account_vod__r.recordTypeId in :recordTypeIds and
                                (a.Account_vod__r.LastName like :personLastName and a.Account_vod__r.FirstName like :personFirstName)
                                limit 50
                            ];
            }else{
                adds=[ Select a.id,
                                a.Account_vod__r.Name, a.Account_vod__r.FirstName, a.Account_vod__r.Id, a.Account_vod__r.LastName, a.Account_vod__r.recordTypeId
                                from Address_vod__c a where
                                a.City_vod__c like :city and
                                a.State_vod__c = :state and
                                a.Account_vod__r.recordTypeId in :recordTypeIds and
                                (a.Account_vod__r.LastName like :personLastName)
                                limit 50
                            ];
            }
        }
        else{
            adds=[ Select a.id,
                                a.Account_vod__r.Name, a.Account_vod__r.FirstName, a.Account_vod__r.Id, a.Account_vod__r.LastName, a.Account_vod__r.recordTypeId
                                from Address_vod__c a where
                                a.City_vod__c like :city and
                                a.State_vod__c = :state and
                                a.Account_vod__r.recordTypeId in :recordTypeIds and
                                a.Account_vod__r.Name like :orgName
                                limit 50
                            ];

        }
        for(Address_vod__c add:adds){
            if  (add.Account_vod__r != null && acctIds.contains(add.Account_vod__r.Id) == False) {
                acctIds.add( add.Account_vod__r.Id);
            }

        }
        System.debug('acctIds.size(): ' + acctIds.size());
        List<Account> resAddAccount=[
                            Select a.Name, a.FirstName, a.Id, a.LastName, a.PersonEmail, a.PersonTitle, a.Salutation, a.RecordTypeId ,
                            (Select Account_vod__c, Name, Address_line_2_vod__c,
                             City_vod__c, Country_gen__c, State_vod__c, Zip_vod__c From Address_vod__r) from Account a where a.Id in :acctIds
                        ];
        System.debug('resAddAccount.size(): ' + resAddAccount.size());
        if(resAddAccount.size() > 0){
            res.addAll(resAddAccount);
        }
        return res;
    }
    WebService static List<Address_vod__c> getAccountInactiveAddresses( id accountId ){
        return [Select a.Id, a.Account_vod__c, a.Address_line_2_vod__c, a.Address_Line_3_gne__c,
                a.Address_Line_4_gne__c, a.City_vod__c, a.Name, a.State_vod__c, a.Zip_vod__c
                from Address_vod__c a where  a.Account_vod__c=:accountId and a.Inactive_vod__c = true];
    }
    WebService static boolean activateAddress( id addressId){
        Address_vod__c a= [select Inactive_vod__c,Active_Flag_gne__c from Address_vod__c where id=:addressId];
        a.Inactive_vod__c=false;
        a.Active_Flag_gne__c=true;
        update a;
        return true;
    }
    WebService static boolean notifyMDMOfNewAccount(string mdmid,string SFDCId, boolean isPro){
        string partType=(isPro)?'IND':'ORG';
        mdm0620MDMProxyService.MdmProxyPortType mdmPort=new mdm0620MDMProxyService.MdmProxyPortType();
        mdmPort.Timeout_x = 30000;
        return mdmPort.updateSfdcAccountByMdmId(mdmid,partType,SFDCId);
    }

    WebService static boolean addAccountToMyTarget(Id accountId, Id territoryId) {
        List<Territory2> ters=[Select t.Name from Territory2 t where t.id=:TerritoryId];
        if(ters.size()==0) return false;

        /******************************************************************************
        Verify that the right account share for the territory is there
        ******************************************************************************/

        Group grp=[Select g.Id, g.RelatedId, g.Type from Group g where g.Type='Territory' and g.RelatedId=:TerritoryId];
        List<AccountShare> ashs= [  Select a.AccountAccessLevel, a.AccountId, a.CaseAccessLevel, a.ContactAccessLevel,
                                    a.Id, a.OpportunityAccessLevel, a.RowCause, a.UserOrGroupId from AccountShare a
                                    where a.AccountId =:accountId and a.UserOrGroupId=:grp.Id];
        if(ashs.size()==0){
			ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = accountId, Territory2Id = territoryId, AssociationCause='Territory2Manual');
            insert territoryAssociation;
        }
        /******************************************************************************
        Verify that the My Target flag is set.
        ******************************************************************************/

        TSF_vod__c tsf;
        string territoryName=ters[0].Name;
        List<TSF_vod__c> tsfs=[ Select t.My_Target_vod__c,t.Id  from TSF_vod__c t where t.Territory_vod__c=:territoryName
                                and t.Account_vod__c=:accountID];
        if(tsfs.size()==0) tsf=new TSF_vod__c(Account_vod__c=accountID,Territory_vod__c=territoryName,My_Target_vod__c=true);
        else {
            tsf=tsfs[0];
            tsf.My_Target_vod__c=true;
        }
        upsert tsf;
        return true;
    }
    WebService static boolean CreateDataChangeRequestForNewAccount(Id accountID){
        //  Jan 2009 Update for Data Change Request Connection
        ChangeRequestControllerHelper.CreateDataChangeRequestForGAPPayer(accountID);
        return true;
    }
}