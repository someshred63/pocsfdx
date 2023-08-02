/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class gFRS_ObjectUtilTester {
    
    /**
     *  Method to create accounts for testing.
     *  <p>Changes may need to be made to work with your org
     **/
    private static Account createTestAccount( String accountName ){
        String testAddress= 'Address';
        String BillingStreet = 'testAddress', BillingCity = 'test',  BillingState = 'test', BillingPostalCode = 'test';

        return( new Account(
            Name = accountName,
            BillingStreet=BillingStreet,
            BillingCity=BillingCity,
            BillingState=BillingState,
            BillingPostalCode=BillingPostalCode ) );
    }

    private static Account createTestAccount( String accountName , String state){
        String testAddress= 'Address';
        String billState = String.isNotBlank(state) ? state : 'test';
        String BillingStreet = 'testAddress', BillingCity = 'test',  BillingState = billState, BillingPostalCode = 'test';

        return( new Account(
                Name = accountName,
                BillingStreet=BillingStreet,
                BillingCity=BillingCity,
                BillingState=BillingState,
                BillingPostalCode=BillingPostalCode ) );
    }

    static testMethod void checkingDuplicatesInNullListReturnsFalse(){
        List<Account> accountList = new List<Account>{
            createTestAccount( 'a'),
            createTestAccount( 'b'),
            createTestAccount( 'c')
        };
        
        System.assert( !gFRS_ObjectUtil.hasDuplicateIdFields( accountList, null, 'ParentId' ));
    }
    
    static testMethod void listWithoutDuplicatesMustNotFindDuplicates(){
        
        List<Account> parentAccountList = new List<Account>{
            createTestAccount( 'a'),
            createTestAccount( 'b'),
            createTestAccount( 'c')
        };
        insert parentAccountList;
        
        List<Account> accountList = new List<Account>{
            createTestAccount( 'a'),
            createTestAccount( 'b'),
            createTestAccount( 'c')
        };
        insert accountList;
        
        for( Integer i = 0; i < parentAccountList.size(); i++ ){
            accountList[i].ParentId = parentAccountList[i].id;
        }
        
        List<Account> duplicateAccounts = new List<Account>();
        System.assert( !gFRS_ObjectUtil.hasDuplicateIdFields(accountList,duplicateAccounts,'ParentId'));
        
        System.assertEquals( 0, duplicateAccounts.size() );
    }
    
    static testMethod void listWithDuplicatesMustFindDuplicates(){
        
        List<Account> parentAccountList = new List<Account>{
            createTestAccount( 'a'),
            createTestAccount( 'b'),
            createTestAccount( 'c')
        };
        insert parentAccountList;
        
        List<Account> accountList = new List<Account>{
            createTestAccount( 'a'),
            createTestAccount( 'b'),
            createTestAccount( 'c')
        };
        insert accountList;
        
        for( Integer i = 0; i < parentAccountList.size(); i++ ){
            accountList[i].ParentId = parentAccountList[i].id;
        }
        
        accountList[1].ParentId = parentAccountList[0].id;
        
        List<Account> duplicateAccounts = new List<Account>();
        System.assert( gFRS_ObjectUtil.hasDuplicateIdFields(accountList,duplicateAccounts,'ParentId'));
        
        System.assertEquals( 2, duplicateAccounts.size() );
        
        for( Account a : duplicateAccounts ){
            System.assertEquals( parentAccountList[0].id, a.ParentId );
        }
    }
    
    static testMethod void DowncastListCanBeCombined(){
        List<Account> accountList = new List<Account>();
        for( Integer i = 0; i < 10; i++ ){
            accountList.add( createTestAccount( 'a' + gFRS_TestCreationUtils.rand( 100000 )));
        }
        insert accountList;
        
        List<SObject> sList = (List<SObject>) accountList;
        
        //-- allow some manipulation on this list if needed
        
        List<Account> targetList = new List<Account>();
        gFRS_ObjectUtil.combineSList( sList, targetlist );
        
        System.assertEquals( 10, targetList.size() );
        
        //-- ensure all items were transferred
        Map<id,Account> accountMap = new Map<id,Account>( accountList );
        for( Account a : targetList ){
            accountMap.containsKey( a.id );
        }
        
        //-- ensure sets are equal
        accountMap = new Map<id,Account>( targetList );
        for( Account a : targetList ){
            accountMap.containsKey( a.id );
        }
    }
    
    static testMethod void createIdFieldSetMustHaveAllIds(){
        List<Account> parentList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert parentList;
        
        List<Account> childList = new List<Account>{
            createTestAccount( 'c1' ),
            createTestAccount( 'c2' ),
            createTestAccount( 'c3' )
        };
        //-- only 2 parents
        childList[0].ParentId = parentList[0].id;
        childList[1].ParentId = parentList[1].id;
        childList[2].ParentId = parentList[0].id;
        
        Set<id> parentSet = gFRS_ObjectUtil.createIdFieldSet( childList, 'ParentId' );
        
        System.assertEquals( 2, parentSet.size() );
        
        System.assert( parentSet.contains( parentList[0].id ));
        System.assert( parentSet.contains( parentList[1].id ));
        System.assert( !parentSet.contains( parentList[2].id ));
    }
    
    static testMethod void createIdMapFieldMustBeSimilarToConstructor(){
        List<Account> parentList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert parentList;
        
        Map<id,Account> sampleMap = new Map<id,Account>( parentList );
        Map<id,Account> resultMap = new Map<id,Account>();
        gFRS_ObjectUtil.createIdFieldMap(parentList, 'id',resultMap);
        
        //-- verify the sets are the same
        Set<id> sampleMapKeys = sampleMap.keySet();
        for( id sampleId : sampleMapKeys ){
            System.assert( resultMap.containsKey( sampleId ));
            System.assertEquals( sampleMap.get(sampleId), resultMap.get(sampleId) );
        }
        
        Set<id> resultMapKeys = resultMap.keySet();
        for( id resultId : resultMapKeys ){
            System.assert( sampleMap.containsKey( resultId ));
            System.assertEquals( resultMap.get(resultId), sampleMap.get(resultId) );
        }
    }
    
    static testMethod void mapIdFieldsMustBeFoundOnField(){
        List<Account> parentList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert parentList;
        
        List<Account> childList = new List<Account>{
            createTestAccount( 'c1' ),
            createTestAccount( 'c2' )
        };
        //-- only 2 parents
        childList[0].ParentId = parentList[0].id;
        childList[1].ParentId = parentList[1].id;
        
        Map<id,Account> resultMap = new Map<id,Account>();
        gFRS_ObjectUtil.createIdFieldMap(childList, 'ParentId',resultMap);
        
        Account testParentAccount = parentList[0];
        Account testChildAccount = childList[0];
        System.assert( resultMap.containsKey( testParentAccount.id ));
        System.assertEquals( testChildAccount, resultMap.get( testParentAccount.id ));
        
        testParentAccount = parentList[1];
        testChildAccount = childList[1];
        System.assert( resultMap.containsKey( testParentAccount.id ));
        System.assertEquals( testChildAccount, resultMap.get( testParentAccount.id ));
        
        //-- must not be found
        testParentAccount = parentList[2];
        System.assert( !resultMap.containsKey( testParentAccount.id ));
    }
    
    static testMethod void mapIdFieldsMustFailGracefullyOnInvalidMap(){
        List<Account> parentList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert parentList;
        
        gFRS_ObjectUtil.createIdFieldMap(parentList, 'id', null );
    }
    
    static testMethod void transferSObjectMapMustAllowUpcasting(){
        List<Account> parentList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert parentList;
        
        Map<id,Account> accountMap = new Map<id,Account>( parentList );
        Map<id,SObject> smap = (Map<id,SObject>)accountMap;
        
        Map<id,Account> resultMap = new Map<id,Account>();
        gFRS_ObjectUtil.transferSMap(smap, resultMap);
        
        //-- verify the sets are the same
        Set<id> smapKeys = smap.keySet();
        for( id sampleId : smapKeys ){
            System.assert( resultMap.containsKey( sampleId ));
            System.assertEquals( smap.get(sampleId), resultMap.get(sampleId) );
        }
        
        Set<id> resultMapKeys = resultMap.keySet();
        for( id resultId : resultMapKeys ){
            System.assert( smap.containsKey( resultId ));
            System.assertEquals( resultMap.get(resultId), smap.get(resultId) );
        }
    }
    
    static testMethod void filterChangedObjectsGetsOnlyChangedValues(){
        List<Account> oldList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert oldList;
        
        List<Account> newList = oldList.deepClone(true);
        
        Map<id,Account> oldMap = new Map<id,Account>( oldList );
        Map<id,Account> newMap = new Map<id,Account>( newList );
        
        List<Account> changedAccounts = new List<Account>();
        gFRS_ObjectUtil.filterChangedObjects(newList, oldMap, 'Name', changedAccounts);
        
        System.assertEquals( 0, changedAccounts.size() );
        
        newList[0].Name = 't1';
        newMap = new Map<id,Account>( newList );
        
        changedAccounts.clear();
        gFRS_ObjectUtil.filterChangedObjects( newList, oldMap, 'Name', changedAccounts );
        
        System.assertEquals( 1, changedAccounts.size() );
        System.assertEquals( newList[0].id, changedAccounts[0].id );
        System.assertEquals( newList[0], changedAccounts[0] );
    }

    static testMethod void filterNotChangedObjects(){
        List<Account> oldList = new List<Account>{
                createTestAccount( 'a1' ),
                createTestAccount( 'a2' ),
                createTestAccount( 'a3' )
        };
        insert oldList;

        List<Account> newList = oldList.deepClone(true);

        Map<id,Account> oldMap = new Map<id,Account>( oldList );
        Map<id,Account> newMap = new Map<id,Account>( newList );

        List<Account> changedAccounts = new List<Account>();
        gFRS_ObjectUtil.filterNotChangedObjects(newList, oldMap, 'Name', changedAccounts);

        System.assertEquals( 3, changedAccounts.size() );

        newList[0].Name = 't1';
        newMap = new Map<id,Account>( newList );

        changedAccounts.clear();
        gFRS_ObjectUtil.filterNotChangedObjects( newList, oldMap, 'Name', changedAccounts );

        System.assertEquals( 2, changedAccounts.size() );
    }
    
    static testMethod void filterChangedObjectsMustBeChangedIfOldMapIsNew(){
        List<Account> newList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert newList;
        
        List<Account> resultList = new List<Account>();
        gFRS_ObjectUtil.filterChangedObjects( newList, null, 'Name', resultList );
        
        System.assertEquals( newList.size(), resultList.size() );
        
        Set<String> newListNames = gFRS_ObjectUtil.createStringFieldSet( newList, 'Name' );
        Set<String> resultListNames = gFRS_ObjectUtil.createStringFieldSet( resultList, 'Name' );
        
        System.assert( newListNames.containsAll( resultListNames ));
        System.assert( resultListNames.containsAll( newListNames ));
    }

    static testMethod void filterChangedFieldsUnderRecordGetChangedFields(){
        List<Account> oldList = new List<Account>{
                createTestAccount( 'a1', 'test1' ),
                createTestAccount( 'a2', 'test2'),
                createTestAccount( 'a3', 'test1')
        };
        insert oldList;

        List<Account> newList = oldList.deepClone(true);

        Map<id,Account> oldMap = new Map<id,Account>( oldList );
        Map<id,Account> newMap = new Map<id,Account>( newList );

        List<Account> changedAccounts = new List<Account>();
        List<String> fieldNames = new List<String>{'Name', 'BillingState'};
        gFRS_ObjectUtil.filterChangedFieldsUnderRecord(newList, oldMap, fieldNames, changedAccounts);

        System.assertEquals( 0, changedAccounts.size() );

        newList[0].Name = 't1';
        newMap = new Map<id,Account>( newList );

        changedAccounts.clear();
        gFRS_ObjectUtil.filterChangedFieldsUnderRecord( newList, oldMap, fieldNames, changedAccounts );

        System.assertEquals( 1, changedAccounts.size() );
        System.assertEquals( newList[0].id, changedAccounts[0].id );
        System.assertEquals( newList[0], changedAccounts[0] );
    }

    static testMethod void getMapListItemsRetrievesEquivalentObjects(){
        List<Account> oldList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert oldList;
        
        List<Account> newList = oldList.deepClone(true);
        newList[0].Name = 't1';
        newList[1].Name = 't2';
        newList[2].Name = 't3';
        
        Map<id,Account> oldMap = new Map<id,Account>( oldList );
        Map<id,Account> newMap = new Map<id,Account>( newList );
        
        List<Account> newItems = new List<Account>();
        gFRS_ObjectUtil.getMapListItems( oldList, newMap, newItems);
        
        Map<id,Account> newItemMap = new Map<id,Account>( newItems );
        
        System.assertEquals( newList.size(), newItems.size() );
        
        //-- verify the sets are the same
        Set<id> newItemKeys = newItemMap.keySet();
        for( id newItemId : newItemKeys ){
            System.assert( newMap.containsKey( newItemId ));
            System.assertEquals( newItemMap.get(newItemId), newMap.get(newItemId) );
        }
        
        Set<id> newKeys = newMap.keySet();
        for( id newKey : newKeys ){
            System.assert( newItemMap.containsKey( newKey ));
            System.assertEquals( newMap.get(newKey), newItemMap.get(newKey) );
        }
    }
    
    static testMethod void filterListByStringProp(){
        List<Account> oldList = new List<Account>{
            new Account( Name='John', Website='johson@email.com' ),
            new Account( Name='Mary', Website='johson@email.com' ),
            new Account( Name='Linus', Website='rob@email.com' ),
            new Account( Name='Don', Website='thomson@email.com' )
        };
        
        List<Account> johnsonAccounts = new List<Account>();
        gFRS_ObjectUtil.filterListByString(oldList, 'Website', 'johson@email.com', johnsonAccounts );
        
        System.assertEquals( 2, johnsonAccounts.size() );
        
        for( Account acct : johnsonAccounts ){
            System.assert( acct.Name == 'John' || acct.Name == 'Mary' );
        }
    }
    
    static testMethod void filterListByStringFailsGraciously(){
        List<Account> oldList = new List<Account>{
            new Account( Name='John', Website='johson@email.com' ),
            new Account( Name='Mary', Website='johson@email.com' ),
            new Account( Name='Linus', Website='rob@email.com' ),
            new Account( Name='Don', Website='thomson@email.com' )
        };
        
        List<Account> johnsonAccounts = null; //-- fails since no place to put the values
        gFRS_ObjectUtil.filterListByString(oldList, 'Website', 'johson@email.com', null );  
    }
    
    static testMethod void cloneListWithoutIdsClearsIds(){
        List<Account> parentList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' )
        };
        insert parentList;
        
        List<Account> childList = new List<Account>{
            createTestAccount( 'c1' ),
            createTestAccount( 'c2' )
        };
        childList[0].ParentId = parentList[0].id;
        childList[1].ParentId = parentList[1].id;
        insert childList;
        
        List<Account> childWithParentList = [ SELECT Name, Parent.Name from Account where id in :childList ];
        
        for( Account a: childWithParentList ){
            System.assert( a.id != null );
            System.assert( a.Name != null );
            System.assert( a.Parent.Name != null );
        }
        
        //-- make clone of list so even referenced objects are included
        List<Account> clonedChildrenParent = new List<Account>();
        gFRS_ObjectUtil.cloneListWithoutIds( childWithParentList, clonedChildrenParent);
        
        for( Account a: clonedChildrenParent ){
            System.assert( a.id == null );
            System.assert( a.Name != null );
            System.assert( a.Parent.Name != null );
        }
    }
    
    static testMethod void testCreateStringFieldSet(){
        Account[] accounts = new Account[]{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' ),
            createTestAccount( 'a4' ),
            createTestAccount( 'a5' )
        };
        
        Set<String> expectedNames = new Set<String>{ 'a1','a2','a3','a4','a5' };
        Set<String> foundNames = gFRS_ObjectUtil.createStringFieldSet( accounts, 'Name' );
        
        System.assertEquals( true, expectedNames.containsAll( foundNames ));
        System.assertEquals( true, foundNames.containsAll( expectedNames ));
    }
    
    static testMethod void testCreateStringFieldMap(){
        Account[] accounts = new Account[]{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' ),
            createTestAccount( 'a4' ),
            createTestAccount( 'a5' )
        };
        
        Set<String> expectedNames = new Set<String>{ 'a1','a2','a3','a4','a5' };
        Map<String,Account> accountMap = new Map<String,Account>();
        gFRS_ObjectUtil.createStringFieldMap( accounts, 'Name', accountMap );
        
        System.assertEquals( expectedNames.size(), accountMap.size() );
        for( String n : expectedNames ){
            System.assert( accountMap.containsKey( n ));
        }
    }
    
    static testMethod void testRemoveMatchingLong(){
        Account[] accounts = new Account[]{};
        Account acct;
        
        for( Integer i = 1; i<6; i++ ){
            acct = createTestAccount( 'a' + i );
            acct.NumberOfEmployees = i;
            accounts.add( acct );
        }
        
        SObject sobj = gFRS_ObjectUtil.removeMatchingLong( accounts, 'NumberOfEmployees', 1 );
        System.assertEquals( 4, accounts.size() );
        acct = (Account)sobj;
        System.assertEquals( 1, acct.NumberOfEmployees );
        
        sobj = gFRS_ObjectUtil.findMatchingLong( accounts, 'NumberOfEmployees', 99 );
        System.assertEquals( 4, accounts.size() );
        System.assertEquals( null, sobj );
    }
    
    static testMethod void testFindMatchingLong(){
        Account[] accounts = new Account[]{};
        Account acct;
        
        for( Integer i = 1; i<6; i++ ){
            acct = createTestAccount( 'a' + i );
            acct.NumberOfEmployees = i;
            accounts.add( acct );
        }
        
        SObject sobj = gFRS_ObjectUtil.findMatchingLong( accounts, 'NumberOfEmployees', 1 );
        acct = (Account)sobj;
        System.assertEquals( 1, acct.NumberOfEmployees );
        
        sobj = gFRS_ObjectUtil.findMatchingLong( accounts, 'NumberOfEmployees', 99 );
        System.assertEquals( null, sobj );
    }
    
    static testMethod void testFindMatchingLongIndex(){
        Account[] accounts = new Account[]{};
        Account acct;
        
        for( Integer i = 1; i<6; i++ ){
            acct = createTestAccount( 'a' + i );
            acct.NumberOfEmployees = i;
            accounts.add( acct );
        }
        
        Integer matchingIndex = gFRS_ObjectUtil.findMatchingLongIndex( accounts, 'NumberOfEmployees', 1 );
        System.assertEquals( 0, matchingIndex );
        
        accounts.remove( matchingIndex );
        
        matchingIndex = gFRS_ObjectUtil.findMatchingLongIndex( accounts, 'NumberOfEmployees', 2 );
        System.assertEquals( 0, matchingIndex );
        
        matchingIndex = gFRS_ObjectUtil.findMatchingLongIndex( accounts, 'NumberOfEmployees', 99 );
        System.assertEquals( -1, matchingIndex );
    }
    
    static testMethod void testIndexByStringKey(){
        Account[] accounts = new Account[]{};
        Account acct;
        
        for( Integer i = 1; i <= 6; i++ ){
            acct = createTestAccount( 'a' + i );
            acct.NumberOfEmployees = i;
                        
            accounts.add( acct );
        }
        
        String city1 = 'Chicago';
        String city2 = 'New York';
        String invalidCity = 'Cucamonga';
        accounts[0].BillingCity = accounts[1].BillingCity = accounts[2].BillingCity = city1;
        accounts[3].BillingCity = accounts[4].BillingCity = accounts[5].BillingCity = city2;
        
        Map<String,SObject[]> cityMap = gFRS_ObjectUtil.indexByStringKey( accounts, 'BillingCity', null );
        
        //-- there were two cities so they should both be found
        SObject[] cityAccounts = null;
        System.assert( cityMap.containsKey( city1), 'city that was used [' + city1 + '] must have an index in the map' );
        cityAccounts = cityMap.get( city1 );
        System.debug( 'cityAccounts:' + cityAccounts );
        
        acct = (Account)cityAccounts[0];
        System.debug( 'firstCityAccount:' + acct );
        
        System.assertEquals( 3, cityAccounts.size(), 'There were three cities that used chicago' );
        
        cityAccounts = null;
        System.assert( cityMap.containsKey( city2), 'city[' + city2 + '] that was used must have an index in the map' );
        cityAccounts = cityMap.get( city2 );
        System.assertEquals( 3, cityAccounts.size(), 'There were three cities that used chicago' );
        
        //-- test an invalid city
        System.assertEquals( false, cityMap.containsKey( invalidCity ), 'InvalidCity[' + invalidCity + '] was not used, and should not be found' );
        
        Set<String> cityKeys = cityMap.keySet();
        System.assertEquals( 2, cityKeys.size(), 'there were two cities, and only two citys, so only two cities in the keys' );
    }

    static testMethod void testAddIndividualIndexByStringKey() {
        Account[] accounts = new Account[]{};
        Account acct;

        for( Integer i = 1; i <= 6; i++ ){
            acct = createTestAccount( 'a' + i );
            acct.NumberOfEmployees = i;

            accounts.add( acct );
        }

        String city1 = 'Chicago';
        String city2 = 'New York';
        String invalidCity = 'Cucamonga';
        accounts[0].BillingCity = city1;
        accounts[1].BillingCity = city2;

        Map<String,SObject[]> cityMap = gFRS_ObjectUtil.addIndividualIndexByStringKey( accounts[0], 'BillingCity', null );
        gFRS_ObjectUtil.addIndividualIndexByStringKey( accounts[1], 'BillingCity', cityMap );

        SObject[] cityAccounts = null;
        cityAccounts = cityMap.get( city1 );

        acct = (Account)cityAccounts[0];

        System.assertEquals( 1, cityAccounts.size(), 'There were one cities that used chicago' );

        cityAccounts = null;
        cityAccounts = cityMap.get( city2 );

        System.assertEquals( 1, cityAccounts.size(), 'There were one cities that used chicago' );

        //-- test an invalid city
        System.assertEquals( false, cityMap.containsKey( invalidCity ), 'InvalidCity[' + invalidCity + '] was not used, and should not be found' );

        Set<String> cityKeys = cityMap.keySet();
        System.assertEquals( 2, cityKeys.size(), 'there were two cities, and only two citys, so only two cities in the keys' );
    }
}