public class GNE_AddressSplit_Controller {
	
	  Map<String,List<SObjectField>> acctChildObjectFieldNames = new Map <String, List<SObjectField>>(); // acct child Object with child field names
	  Map<String,List<SObjectField>> addrChildObjectFieldNames = new Map <String, List<SObjectField>>(); // addr child Object with child field names
	  
      Map<String,SObjectField> relationshipMap     = new Map<String,SObjectField>(); // relationship To Move 
      Map <String,String> addrRelationToObject     = new Map<String, String>(); // relationship Name to Object Name      
      
     
      String accountSQL = null;
      String addressSQL = null;    
    
    void initialize() {          
        // account sql     	      
	        GNE_Merge_BusinessRules_gne__c[] gneAccountFields  = 
	                        [select field_type_gne__c, field_name_gne__c 
	                         from gne_merge_businessrules_gne__c  
	                         where     object_name_gne__c      = 'Account' 
	                               and active_gne__c           = true
	                               and field_applies_to_gne__c includes( 'Address Split' )
	                         order by field_type_gne__c, field_name_gne__c desc];
	
	        accountSQL = 'select id ';
	        for (GNE_Merge_BusinessRules_gne__c gneMerge : gneAccountFields) {            
	                accountSQL += ',' + gneMerge.field_name_gne__c ;
	        }   
	        
	        accountSQL += ', (select userorgroupId, accountId from Shares where ' + 
	                      ' rowcause =\'Territory2AssociationManual\' )  ';
	        
            accountSQL += ', (select name, account_vod__c, my_target_vod__c, territory_vod__c ' +  
                          ' from tsf_vod__r ) ';

            accountSQL += ', (select Affiliation_Type_gne__c, From_Account_vod__c, ' +  
                          ' Role_vod__c, To_Account_vod__c,  To_Contact_vod__c, drug_gne__c, ' +
                          ' parent_vod__c from Affiliation_vod__r where createddate != today) ' ;  
                          
 	        accountSQL += ' from Account' ;  

        // address sql          
	        GNE_Merge_BusinessRules_gne__c[] gneAddressFields  = 
	                        [select field_type_gne__c, field_name_gne__c 
	                         from gne_merge_businessrules_gne__c  
	                         where     object_name_gne__c      = 'Address_vod__c' 
	                               and active_gne__c           = true
	                               and field_type_gne__c not in ('MDM Id Field Name', 'Sort By Columns')
	                         order by field_type_gne__c, field_name_gne__c desc];    
	        addressSQL = 'select id ';
	        for (GNE_Merge_BusinessRules_gne__c gneMerge : gneAddressFields) {            
	            if ( gneMerge.field_type_gne__c.equalsIgnoreCase('Relationship To Move') ) {
	                relationshipMap.put(gneMerge.field_name_gne__c.toUpperCase(), null);
	            } else {            
	                addressSQL += ',' + gneMerge.field_name_gne__c ;
	            }                
	        }   
	        addressSQL += ' from Address_vod__c  ' ; 

        // address child relationship field   
	        if ( relationshipMap.size() > 0 ) {            
	            
	            Schema.DescribeSObjectResult objectChildren      = getDescribe('Address_vod__c');
	            List<Schema.ChildRelationship> childRelationship = objectChildren.getChildRelationships();
	            
	            for (Schema.ChildRelationship child : childRelationship ) {	            

	                SObjectField fieldName  =  child.getField();
	                String objectName       =  child.getChildSObject().getDescribe().getLocalName().toUpperCase();
                    
                    List<SObjectField> fieldList = addrChildObjectFieldNames.get( objectName );               
                    if ( fieldList == null ) {
                       fieldList= new List<SObjectField>();
                       addrChildObjectFieldNames.put (objectName, fieldList);   
                    }
                    fieldList.add ( fieldName );

                    String relationshipName = child.getRelationshipName().toUpperCase();
                    addrRelationToObject.put (relationshipName, objectName); 
                    if ( relationshipMap.containsKey(relationshipName)  ) 
                       relationshipMap.put (relationshipName, child.getField() );

	            }
	            
	        }

        // acct relationship list             
	        if ( relationshipMap.size() > 0 ) {   
	            
	            Map<String,SObjectField> addrChildMap= new Map<String,SObjectField>{};
	            Schema.DescribeSObjectResult objectChildren = getDescribe('Account');
	            List<Schema.ChildRelationship> childRelationship = objectChildren.getChildRelationships();
	            
	            for (Schema.ChildRelationship child : childRelationship ) {
	            
	            	SObjectField fieldName  = child.getField();
	            	String objectName       = child.getChildSObject().getDescribe().getLocalName().toUpperCase();

	            	List<SObjectField> fieldList = acctChildObjectFieldNames.get( objectName );
	            	if ( fieldList == null ) {
	            	   fieldList= new List<SObjectField>();
	            	   acctChildObjectFieldNames.put (objectName, fieldList);	
	            	}
	            	fieldList.add ( fieldName );
	            }
	            
	        }        
        //System.debug ('account sql -> ' + accountSQL );
        //System.debug ('address sql -> ' + addressSQL );
    }
    
    private Schema.DescribeSObjectResult getDescribe(String objectName) {        
        Schema.DescribeSObjectResult objectChildren = null;        
        if ( objectName.equalsIgnoreCase('Account'))
            objectChildren = Account.SObjectType.getDescribe();
        else if (objectName.equalsIgnoreCase('Address_vod__c'))
            objectChildren = Address_vod__c.SObjectType.getDescribe();
        
        return objectChildren;          
    }       

    public String getAccountAddressRelationsipSQL () {

        String sql = 'select id ';
        
        for (String relationshipName : relationshipMap.keySet() ) {

            String childObjectName           = addrRelationToObject.get(relationshipName);            
            List<SObjectField> acctFieldList = acctChildObjectFieldNames.get(childObjectName);  
            
            sql += ', ( select id, ' + relationshipMap.get(relationshipName) ;
            
            if ( acctFieldList != null ) {
	            for (SObjectField fieldName : acctFieldList) {
	               sql += ', ' + fieldName  ;   	
	            } 
            }
            sql += ' from ' + relationshipName  + ') ' ;                     
        }
        
        sql += ' from address_vod__c ' ; 

        System.debug ( acctChildObjectFieldNames );
        System.debug ( addrChildObjectFieldNames );
        System.debug ( relationshipMap );
        System.debug ( addrRelationToObject );

        return sql;

    }
    
    public GNE_AddressSplit_Controller () { //String objectName, String objectType) {
        //this.objectName = objectName;
        //this.objectType = objectType;
        initialize();
    }

    
    public String getAccountSQL() {
        return accountSQL;   
    }  

    public String getAddressSQL() {
        return addressSQL;   
    }  

    private void copyAccountChildRecords (Account clonedAccount, String accountId) {            

	    List<AccountShare>  acctShares  =  new List<AccountShare>();   
	    List<TSF_vod__c>  tsfList       =  new List<TSF_vod__c>(); 
	    List<Affiliation_vod__c> affList=  new List<Affiliation_vod__c>();
	    Id newAccountId                 =  (Id )clonedAccount.get('Id');

        // account share
            SObject[] acctShareObjects = clonedAccount.getSObjects('Shares');
            if ( acctShareObjects != null ) {                         
                for (SObject acctShareObject : acctShareObjects ) {
                    AccountShare ac = (AccountShare ) acctShareObject.clone(false,true);
                    ac.accountId = newAccountId;
                    acctShares.add ( ac );
                }
                insert acctShares; 
            }
        
        // tsf entries
            SObject[] tsfObjects = clonedAccount.getSObjects('TSF_vod__r');
            if ( tsfObjects != null ) {
                for (SObject tsfObject : tsfObjects ) {
                    TSF_vod__c tsf = (TSF_vod__c) tsfObject.clone(false,true);
                    tsf.account_vod__c = newAccountId;
                    tsfList.add ( tsf); 
                }
                insert tsfList;
            }
        
        // affiliation entries
            SObject[] affObjects = clonedAccount.getSObjects('affiliation_vod__r');
            if ( affObjects != null ) {
                for (SObject affObject : affObjects ) {
                    Affiliation_vod__c aff = (Affiliation_vod__c) affObject.clone(false,true);
                    aff.from_account_vod__c = newAccountId;
                    aff.parent_vod__c = True;
                    affList.add (aff); 
                    if ( affList.size() == 20 ) { 
                        insert affList;
                        affList.clear() ;
                    }
                }
            }
        
        // create affiliation with Multi HCO Account & new cloned account             
            Affiliation_vod__c ToParent = new Affiliation_vod__c();
                ToParent.From_Account_vod__c = newAccountId;
                ToParent.To_Account_vod__c   = accountId;
                ToParent.Role_vod__c         = 'Affiliated with';
                ToParent.Affiliation_Type_gne__c = 'Affiliation';
                ToParent.parent_vod__c = true;
            affList.add ( ToParent );
            insert affList;
    	
    }
    
	public String doSplit(String accountId, String addressId)  {

        Id newAccountId = null;
        SObject clonedAccount = null;
        
        try {                                 
            
        // account clone logic                     	       
            String sql = accountSQL + ' where Id = :accountId ';  
            SObject accountObject = Database.query (sql);
            clonedAccount = accountObject.clone(false,true);
            insert clonedAccount;
            newAccountId       = (Id ) clonedAccount.get('id');
            System.debug ( 'Cloned Account Id for Account Id --> ' + newAccountId + '/' + accountId );            
            copyAccountChildRecords ((Account)clonedAccount, accountId);


        // address clone logic
            sql = addressSQL + ' where Id = :addressId ';  
            SObject addressObject = Database.query (sql);
            SObject clonedAddress = addressObject.clone(false,true);
            clonedAddress.put ('account_vod__c', newAccountId);             
            insert clonedAddress;
            
            Id newAddressId       = (Id ) clonedAddress.get('id');
            System.debug ( 'Cloned Address Id for Address Id --> ' + newAddressId + '/' + addressId );
            
	  		
        // move child record for account Id & address Id 
        // to newAccountId & newAddressId  
        
			sql = getAccountAddressRelationsipSQL () + 
			               ' where id = :addressId and account_vod__c = :accountId';                       
			System.debug ( 'child relationship dynamic sql prepared --> ' + sql );
			SObject addressChildRecords = Database.query ( sql );
		    
		    if ( addressChildRecords != null ) {
		        for (String relationshipName : relationshipMap.keySet() ) {
		            SObject[] childObjects = addressChildRecords.getSObjects (relationshipName);
		            if ( childObjects != null ) {		            	
		                for (SObject child : childObjects) {	
		                    System.debug ('Associating child relationship / child Id ' + 
		                                  relationshipName + '/' +
		                                  child.get('id')  + '/' + 
	                                      clonedAddress.get('id') );
	                                        
		                    child.put(relationshipMap.get(relationshipName), newAddressId); 
		                    
		                    // repointing account reference in address child records
			                    String objectName = addrRelationToObject.get(relationshipName);
			                    System.debug ( 'Relationship Name / Object Name ' + relationshipName + '/' + objectName );
			                    for ( SObjectField fieldName :  acctChildObjectFieldNames.get(objectName) ) {
			                      if ( child.get ( fieldName ) == accountId )
			                          child.put (fieldName, newAccountId);
			                    }
		                }
		                update childObjects;
		            }                          
		        }
		        delete addressChildRecords;
		    }
		      
        } catch (Exception e) {
			System.debug ( 'Error process doSplit -> '+ e.getMessage() );
			if ( newAccountId !=null )
                delete clonedAccount; 
			throw e; 
        }
        return newAccountId;
    }
}