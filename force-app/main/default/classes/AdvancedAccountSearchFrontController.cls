public class AdvancedAccountSearchFrontController {

public SFASearch_gne__c sfaSearch;
public String step0 { get; set; }
public String step1 { get; set; }


public String actTyp = 'HCP';
public SFASearchStrings_gne__c sfaSearchStrings;
public String accountType= getActType();

public String getActType()
{
    try {
        List<SFASearchStrings_gne__c> act = [Select AccountType_gne__c from SFASearchStrings_gne__c where ownerid = :Userinfo.getUserId() ];
            if(act[0].AccountType_gne__c != '' || act[0].AccountType_gne__c != null)
             { actTyp = act[0].AccountType_gne__c; }
            else
             {actTyp = 'HCP';} 
        }
    catch (ListException e) { System.debug(e); }// List Exception handling code here 
    catch (Exception e) { System.debug(e); }
 return actTyp;
}

public SFASearch_gne__c getSFASearch() {
if(sfaSearch == null) sfaSearch = new SFASearch_gne__c();
return sfaSearch;
}


public void init() { 
    Id id = ApexPages.currentPage().getParameters().get('id'); 
    getSFASearchStrings();
    return ; 
  }


public SFASearchStrings_gne__c getSFASearchStrings()
{
    if(sfaSearchStrings == null) 
       {
        sfaSearchStrings = new SFASearchStrings_gne__c(); }
    else
       {
        String stringQuery = 'select AccountType_gne__c, FirstName_gne__c, LastName_gne__c, OrgName_gne__c, Street_gne__c, City_gne__c, Zip_gne__c, State_gne__c from SFASearchStrings_gne__c where ownerid =\''+ Userinfo.getUserId()+'\'';
        try {
        sfaSearchStrings = Database.query(stringQuery);
            }
        catch (ListException e) { System.debug(e); }// List Exception handling code here 
        catch (Exception e) { System.debug(e); } }
return sfaSearchStrings;
}


public List<SelectOption> getItems() {
List<SelectOption> options = new List<SelectOption>();
options.add(new SelectOption('HCO',Label.AdvAccSearch_HealthcareOrganization));
options.add(new SelectOption('HCP',Label.AdvAccSearch_HealthcareProfessional));
return options;
}

public String getaccountType() {
return accountType;}
public void setaccountType(String accountType) { this.accountType = accountType;
System.debug('#########Reached here'); sfaSearch.AccountType_gne__c = accountType;}
//accountType = sfaSearchStrings.AccountType_gne__c; }

//Code added to rad the Sobject description. Reads the URL location too
public Static String getKeyprefix(){

   Schema.DescribeSObjectResult sObjectDescription = SFASearch_gne__c.sObjectType.getDescribe();
   return '/'+ sObjectDescription.keyPrefix;
}

PageReference pageRefsearch = new PageReference('/apex/AdvancedAccountSearch');
PageReference pageRef = new PageReference(getKeyPrefix());


// when users move from page to page.

Public PageReference step0() {
try{
    SFASearchStrings_gne__c existingStrings = [select id from SFASearchStrings_gne__c where ownerid = :Userinfo.getUserId()];
    delete existingStrings;}
catch (ListException e) { System.debug(e); }// List Exception handling code here 
catch (Exception e) { System.debug(e); }
pageRefsearch.setRedirect(true);
return pageRefsearch;
}


public PageReference step1() {

    sfaSearch.FirstName_gne__c = sfaSearchStrings.FirstName_gne__c;
    sfaSearch.LastName_gne__c = sfaSearchStrings.LastName_gne__c;
    sfaSearch.OrgName_gne__c = sfaSearchStrings.OrgName_gne__c; 
    sfaSearch.City_gne__c = sfaSearchStrings.City_gne__c;
    sfaSearch.Street_gne__c = sfaSearchStrings.Street_gne__c; 
    sfaSearch.Zip_gne__c = sfaSearchStrings.Zip_gne__c ;
       
    SFAsearchForAccount(sfaSearch.AccountType_gne__c, sfaSearch.OrgName_gne__c, sfaSearch.FirstName_gne__c, sfaSearch.LastName_gne__c, sfaSearch.City_gne__c, sfaSearch.State_gne__c,sfaSearch.Street_gne__c,sfaSearch.Zip_gne__c);

try{    
    SFASearchStrings_gne__c existingStrings = [select id from SFASearchStrings_gne__c where ownerid = :Userinfo.getUserId()];
    delete existingStrings;
    }
catch (ListException e) { System.debug(e); }// List Exception handling code here 
catch (Exception e) { System.debug(e); } 
    SFASearchStrings_gne__c newsfaSearchStrings = new SFASearchStrings_gne__c();
    newsfaSearchStrings.FirstName_gne__c = sfaSearch.FirstName_gne__c;
    newsfaSearchStrings.LastName_gne__c = sfaSearchStrings.LastName_gne__c;
    newsfaSearchStrings.OrgName_gne__c = sfaSearch.OrgName_gne__c; 
    newsfaSearchStrings.City_gne__c = sfaSearch.City_gne__c;
    newsfaSearchStrings.Street_gne__c = sfaSearch.Street_gne__c; 
    newsfaSearchStrings.Zip_gne__c = sfaSearch.Zip_gne__c ;
    newsfaSearchStrings.AccountType_gne__c = accountType;
    insert newsfaSearchStrings;
    
return pageRef; }

// This method cancels the wizard, and returns the user to the tab
public PageReference cancel() {
PageReference AdvancedAccountSearch = new ApexPages.StandardController(sfaSearch).view();
AdvancedAccountSearch.setRedirect(true);
return AdvancedAccountSearch;
//PageReference SFASearchPage = new ApexPages.StandardController(sfaSearch).view();
//SFASearchPage.setRedirect(true);
//return SFASearchPage;
}


// Code for searching and inserting the account.
 Public Static void SFAsearchForAccount(String accounttype, String orgname, String firstname, String lastname, String city, String state, String street, String zip)
 {
    boolean peraccount = false; 
    if(accounttype == 'HCO')  { peraccount = false; } else {  peraccount = true; }
        
    List<SFASearch_gne__c> existingResults = [select id from SFASearch_gne__c where ownerid = :Userinfo.getUserId()];
    delete existingResults;
    
   if (firstname == null || firstname == '') 
            { firstname = '%'; } 
         else   
             { firstname = '%'+firstname+'%'; firstname = firstname; }
   if (lastname == null || lastname == '') 
               { lastname= '%'; }
         else   
             { lastname= '%'+lastname+'%'; lastname = lastname; }
   if (orgname  == null || orgname == '')  { orgname = '%'; } else { orgname = '%'+orgname+'%'; }  
   if (city == null) {  city = '%'; } else { city = '%'+city+'%';} 
   if (state == null || state=='')  { state = '%';} else { state = '%'+state+'%';}    
   if (street == null || street=='') { street = '%'; } else  { street = '%'+street+'%';}
   if (zip == null || zip=='') { zip = '%'; } else { zip = zip+'%'; }
    
   
  try
  {
   
   String queryString = NULL ;
       
   if(peraccount == false)
       queryString = 'select account_vod__r.professional_Type_gne__c, account_vod__r.formatted_name_vod__c, account_vod__r.name, account_vod__r.FirstName, account_vod__r.LastName, account_vod__r.preferred_name_vod__c, name, city_vod__c, state_vod__c, zip_vod__c, Map_vod__c, account_vod__r.Account_Type_gne__c, account_vod__r.MDMID_gne__c    from address_vod__c where (account_vod__r.name like :orgname OR account_vod__r.preferred_name_vod__c like :orgname) and city_vod__c like :city and state_vod__c like :state and name like :street and zip_vod__c like :zip and account_vod__r.IsPersonAccount = :peraccount limit 500';
   else
      queryString = 'select account_vod__r.professional_Type_gne__c, account_vod__r.formatted_name_vod__c, account_vod__r.name, account_vod__r.FirstName, account_vod__r.LastName, account_vod__r.preferred_name_vod__c, name, city_vod__c, state_vod__c, zip_vod__c, Map_vod__c, account_vod__r.MDMID_gne__c    from address_vod__c where (account_vod__r.FirstName like :firstname OR account_vod__r.preferred_name_vod__c like :firstname) and account_vod__r.LastName like :lastname and city_vod__c like :city and state_vod__c like :state and name like :street and zip_vod__c like :zip and account_vod__r.IsPersonAccount = :peraccount limit 500';

   System.debug('###########QueryString: ' +queryString);    
       
    List<Address_vod__c> addressResults =  Database.query(queryString);
      
    List<SFASearch_gne__c> sfaSearchData = new List<SFASearch_gne__c>();
    
    if (addressResults.size() > 0)
    {
     for(Integer i=0; i< addressResults.size(); i++){
      
    System.debug('Account Found:' +addressResults[i].account_vod__r.name+'\nFirstName:'+addressResults[i].account_vod__r.FirstName+'\nPreferredName:'+addressResults[i].account_vod__r.preferred_name_vod__c+' Street:'+ addressResults[i].name+'City: '+ addressResults[i].city_vod__c+' State: '+ addressResults[i].state_vod__c+ ' zip: '+ addressResults[i].zip_vod__c);
      SFASearch_gne__c resultItem = new SFASearch_gne__c();
      resultItem.Account_gne__c = addressResults[i].account_vod__c;
      resultItem.FirstName_gne__c = addressResults[i].account_vod__r.FirstName; 
      resultItem.LastName_gne__c = addressResults[i].account_vod__r.LastName;
      resultItem.OrgName_gne__c = addressResults[i].account_vod__r.name;
      resultItem.FormattedName_gne__c = addressResults[i].account_vod__r.formatted_name_vod__c;
      resultItem.Street_gne__c = addressResults[i].name;
      resultItem.State_gne__c = addressResults[i].state_vod__c;
      resultItem.City_gne__c = addressResults[i].city_vod__c;
      resultItem.Zip_gne__c = addressResults[i].zip_vod__c;
      resultItem.name_gne__c = addressResults[i].account_vod__r.name;
      resultItem.MDMID_gne__c = addressResults[i].account_vod__r.MDMID_gne__c;
      resultItem.AccountType_gne__c = accountType;
      if(peraccount == false)
      {
         resultItem.Type_gne__c = addressResults[i].account_vod__r.Account_Type_gne__c;
      }
      else
      {
       if(addressResults[i].account_vod__r.professional_Type_gne__c != '' || addressResults[i].account_vod__r.professional_Type_gne__c != null)
           {
           resultItem.Type_gne__c = addressResults[i].account_vod__r.professional_Type_gne__c;
           }
      }     
      resultItem.Map_gne__c = 'http://maps.google.com/maps?f=q&hl=en&q='+addressResults[i].name+'+'+addressResults[i].city_vod__c+'+'+addressResults[i].state_vod__c+'+'+addressResults[i].zip_vod__c; 
      
      if(addressResults[i].account_vod__r.professional_Type_gne__c != '' || addressResults[i].account_vod__r.professional_Type_gne__c != null)
            resultItem.professionalType_gne__c = addressResults[i].account_vod__r.professional_Type_gne__c;
      
      resultItem.preferredName_gne__c = addressResults[i].account_vod__r.Preferred_Name_vod__c;
      sfaSearchData.add ( resultItem );
      
     }
     
    insert sfaSearchData;
    
    }//if ends
   }//try ends
   catch (ListException e) { System.debug(e); }// List Exception handling code here 
  catch (Exception e) { System.debug(e); }
 }
 
 // Delete all results
 public void deleteResults(){
   
    List<SFASearch_gne__c> existingResults = [select id from SFASearch_gne__c where ownerid = :Userinfo.getUserId()];
    delete existingResults;
 }   
 
 
 
 
}