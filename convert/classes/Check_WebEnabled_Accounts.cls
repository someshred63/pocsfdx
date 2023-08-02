/*  This program returns all Accounts where lastmodified date of account is greater than the date which is passed to this function. 

     ESB calls this method once in a day and passes todays date. ESB collects Accounts information and place it in a flat file . SAP then consumes this flat file and updates in their system.
     
     
Author: Rakesh 08/20/2011.      


*/


global class Check_WebEnabled_Accounts
{
     
    global class Web_Enabled {
        webservice String Name;
        webservice String SAP_ID;
        //webservice ID Account_SFDC_ID;
        webservice String IS_Web_Enabled;
        webservice String IsActive;
        webservice DateTime Last_Modified_Date;
     }
   
    webservice static List<Web_Enabled> getAccounts(String strDate)
  {
       Integer counter=0;
    boolean webenabled;
    boolean Accountactive;
    boolean check_point;
    Map<id,id> user_map=new Map<id,id>();
    Map<id,boolean> active_check=new Map<id,boolean>();
    Set<Id> Accountid = new Set<Id>();
    Set<Id> Contactid = new Set<Id>();
    Set<Id> RecordTypeId = new Set<Id>();
    List<RecordType> LWO_ORG=[select id from recordtype where name='LWO Health Care Organization_gne'];
   List<RecordType> LWO_PROF=[select id from recordtype where name='LWO Healthcare Professional_gne'];
   RecordTypeId .add(LWO_ORG[0].ID);
   RecordTypeId .add(LWO_PROF[0].ID);
   
     List<Account> accountlist = new List<Account>();
    List<Contact> contactlist = new List<Contact>();
    List<Web_Enabled> Allaccounts_Today=new List<Web_Enabled>();
    String[] strDTDivided = strDate.split('/',5);
    datetime myDate =datetime.newInstance(Integer.valueof(strDTDivided[2]), Integer.valueof(strDTDivided[0]),INteger.valueof(strDTDivided[1]));
    System.debug('**** '+Integer.valueof(strDTDivided[0]));
     System.debug('**** '+Integer.valueof(strDTDivided[2]));
    System.debug('**** '+Integer.valueof(strDTDivided[1]));
    System.debug('**** '+myDate); 
    //filter by record type also 
    List<Account> validaccounts= [select id,name,SAP_ID_gne__c,LastModifiedDate,Web_Order_Enabled_gne__c,(select  Role_vod__c,To_Account_vod__r.ispersonaccount,To_account_vod__r.personcontactid,Web_Order_Enabled_gne__c,From_account_vod__c, To_Account_vod__c,To_Contact_vod__c from  Affiliation_vod__r where From_account_vod__c!=null ) from Account a where LastModifiedDate>:myDate and SAP_ID_gne__c!=null and recordtypeid in :RecordTypeId ];
                   
    
    for(User  us : [select id,contactid,isactive from User where profile.name='GNE-CM-IHCP-PROFILE'])
    {
    
      user_map.put(us.contactid,us.id);
      active_check.put(us.id,us.isactive);
      
    }   
    
 
    for(Account acctoday: validaccounts){
    	counter++;
    	 Web_Enabled  web_accounts = new Web_Enabled ();
    	 
    	  web_accounts.Name=acctoday.name;
        web_accounts.SAP_ID=acctoday.SAP_ID_gne__c;
       
       // 
        web_accounts.Last_Modified_Date=acctoday.LastModifiedDate;
        
            	 
    	if(acctoday.Web_Order_Enabled_gne__c)
    		 web_accounts.IS_Web_Enabled='Y';
         else
    		 web_accounts.IS_Web_Enabled='';
    	
    	
    	
    	for( Affiliation_vod__c aff : acctoday.Affiliation_vod__r){
    	 
    	    	  	
    	 if(/*aff.Role_vod__c=='Affiliated with' && */ aff.Web_Order_Enabled_gne__c &&  user_map.get(aff.To_Account_vod__r.personContactId) != null && active_check.get(user_map.get(aff.To_Account_vod__r.personContactId)))
           web_accounts.IsActive='Y';
         else 
          web_accounts.IsActive='';   
    	
    	 if(web_accounts.IsActive=='Y')
    	 break;
     } //end of inner for loop . 

    	Allaccounts_Today.add(web_accounts);
    	
  }//end of outer for loop . 
   System.debug('total records processed' + counter);
    return Allaccounts_Today;
          
  }
 }