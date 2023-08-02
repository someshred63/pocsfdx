/*  _____ ___ ___ _      ___ ___  ___     _ ___ ___ _____    */ 
/* |_   _|_ _/ __| |    | _ \ _ \/ _ \ _ | | __/ __|_   _|   */
/*   | |  | |\__ \ |__  |  _/   / (_) | || | _| (__  | |     */
/*   |_| |___|___/____| |_| |_|_\\___/ \__/|___\___| |_|     */


public with sharing class GNE_TISL_Site_Dao extends GNE_Base_Dao{

    public class SiteException extends Exception {}  
    public class TooManyResultsException extends Exception {}
    public List<Integer> dataSetList;
    private List<TISL_Site_gne__c> lSites;
    private transient Map<Id,TISL_Site_gne__c> AllSitesMapForSets;
    private Map<String,Set<String>> dictionaryForFilters;
    private Set<Id> AllSitesSet;
    public Set<Id> QuerySet;
    private Integer CurrentSet;
    private Integer MaxSets;
    private Set<String> lSitesStates;
    static final Integer SET_SIZE;
    transient private String sAddresses;
    
    public static final String TOO_MANY_RESULTS_MSG = 'Too many query rows';

    //---Test Constructor
    public GNE_TISL_Site_Dao(boolean testCase)
    {
        IsTestCase = testCase;
        init();
    }
    
    static
         {
            GNE_TISL_Config_Items_gne__c configItem = GNE_TISL_Config_Items_gne__c.getValues('SetSize');
            SET_SIZE = Integer.ValueOf(configItem.Configuration_Value_gne__c);
         }   
    
    public void init()
    {
        ClassName = 'GNE_TISL_Site_Dao';
        lSites = new List<TISL_Site_gne__c>();
        lSitesStates = new Set<String>();
        QuerySet = new Set<Id>();
        CurrentSet = 1;
        dataSetList = new List<Integer>();
    }
    
    public void initFilterDictionary() {
    	dictionaryForFilters = new Map<String,Set<String>>();
    	for (TISL_Site_gne__c site : AllSitesMapForSets.values()) {
    		
    		for (String filterFieldName : new String[] {'State', 'Country', 'Status'}) {
    			if(!dictionaryForFilters.containsKey(filterFieldName))
    				dictionaryForFilters.put(filterFieldName, new Set<String>());
    			String val = (String)site.get('Site_' + filterFieldName + '_gne__c');
    			if(val!=null && val!='')	
					dictionaryForFilters.get(filterFieldName).add(val);
    		}
    	}
    }
    
    
    public List<TISL_Site_gne__c> getByPager(GNE_TISL_Site_Pager pager)
    {
        CurrentSet = Integer.valueof(pager.CurrentSet);
        dataSetList.clear();
        System.Debug('XXXXX Set new data for CurrentSet :' +CurrentSet );

         // Determin how many sets would be prepared
        if(!pager.isFilterMode()) {
        	if(dictionaryForFilters==null) {
        		AllSitesMapForSets = new Map<Id,TISL_Site_gne__c>([SELECT Id, Site_State_gne__c, Site_Country_gne__c, Site_Status_gne__c
        			FROM TISL_Site_gne__c WHERE Clinical_Trial_gne__c =:pager.TrialId]);
        		// Initialize filter dictionaries
        		initFilterDictionary();
        	} else {
        		AllSitesMapForSets = new Map<Id,TISL_Site_gne__c>([SELECT Id FROM TISL_Site_gne__c WHERE Clinical_Trial_gne__c =:pager.TrialId]);
        	}
        } else {
        	AllSitesMapForSets = new Map<Id,TISL_Site_gne__c>([SELECT Id FROM TISL_Site_gne__c WHERE Clinical_Trial_gne__c =:pager.TrialId
        		AND (Site_State_gne__c=:pager.FilteredByLev2 OR 
        			 Site_Country_gne__c=:pager.FilteredByLev2 OR 
        			 Site_Status_gne__c=:pager.FilteredByLev2)]);
        }
        AllSitesSet = AllSitesMapForSets.keySet();
        
        Integer siteNbr = AllSitesSet.size();
        Integer iFullCount = siteNbr/SET_SIZE;
        Integer iRestCount = 0;
        for (Integer i=0; i<iFullCount; i++) {
          dataSetList.add(SET_SIZE);
        }
        
        if (iFullCount > 0) 
           iRestCount = math.mod(siteNbr, SET_SIZE);
        
        if (iRestCount > 0)
           dataSetList.add(iRestCount);                        
        
        //** MaxSets - ustawić na max dla setów.
        System.Debug('XXXXXX Wartosc AllSitesSet.size() :' + AllSitesSet.size());
        Decimal dec = (AllSitesSet.size()/ Decimal.valueof(SET_SIZE));
        System.Debug('XXXXXX Wartosc z dzielenia :' + dec);
        MaxSets = dec.round(System.RoundingMode.UP).intValue();
        System.Debug('XXXXXX Wartosc MaxSets :' + MaxSets);
        pager.MaxVisibleSets = MaxSets;
                 
        if(AllSitesSet.size() >= SET_SIZE)
        {
            Set<Id> newQuerySet = new Set<Id>();
            Integer i = CurrentSet*SET_SIZE;
            Integer counter = 0;
            for(Id tmp : AllSitesSet)
            { 
                if(counter <= (CurrentSet * SET_SIZE) && counter >= ( CurrentSet * SET_SIZE ) - SET_SIZE )
                {
                    newQuerySet.add(tmp);
                }
                counter++;                          
            }
            
            QuerySet = newQuerySet;
        }
        else
        {
            QuerySet = AllSitesSet;
        }
        System.Debug('XXXXX Set new data for QuerySetSize :' +QuerySet.size());
        lSites =[SELECT t.Site_Zip_Code_gne__c,
	                             t.Site_Status_gne__c, 
	                             t.Site_State_gne__c, 
	                             t.Site_Longitude_gne__c, 
	                             t.Site_Latitude_gne__c,
	                             t.Site_Country_gne__c, 
	                             t.Site_Contact_Phone_gne__c, 
	                             t.Site_Contact_Name_gne__c, 
	                             t.Site_Contact_Email_gne__c,
	                             t.Site_Contact_Role_gne__c, 
	                             t.Site_City_gne__c, 
	                             t.Site_Name_gne__c, 
	                             t.Id,
	                             t.Site_Address_gne__c,
	                             t.Site_Distance_gne__c ,
	                             t.Site_Number_gne__c
	                    FROM TISL_Site_gne__c t 
	                    WHERE t.Clinical_Trial_gne__c =:pager.TrialId
	                    AND  t.Id IN :QuerySet 
	                    LIMIT :SET_SIZE];

        return lSites;
    }
    
    public void updatelSitesDAO(List<GNE_TISL_Site_Information_Controller.tempSite> tmp)
    {
        for(integer i=0; i < lSites.size(); i++)
        {
            for(GNE_TISL_Site_Information_Controller.tempSite tmpSite :tmp)
            {
                if(lSites[i].Id == tmpSite.Id)
                { 
                    lSites[i].Site_Latitude_gne__c = tmpSite.lat;
                    lSites[i].Site_Longitude_gne__c = tmpSite.lng;
                }
            }
        }   
    }
    
    
    public Set<ID> getQuerySet(){
    	
    	return QuerySet;
    }
    
    public String getAddresses(GNE_TISL_Site_Pager pager)
     {
        System.Debug('XXXXXXXXXXXX execute getAddresses from DAO :' + lSites.size()); 
        sAddresses = '';
        System.Debug('XXXXXXXXXXXX lSites :' + lSites.size()); 
        for (Integer i=0; i < lSites.size();i++)
                {
                   // if(lSites[i].Site_Country_gne__c != null) 
                        //0
                        sAddresses += lSites[i].Site_Country_gne__c;
                  //  if(lSites[i].Site_City_gne__c != null)
                        //1
                        sAddresses +=  '$' +  lSites[i].Site_City_gne__c;
                  //  if(lSites[i].Site_Zip_Code_gne__c != null)
                        //2
                        sAddresses += '$' + lSites[i].Site_Zip_Code_gne__c;
                  //  if(lSites[i].Site_State_gne__c != null)
                        //3
                        sAddresses +='$' + lSites[i].Site_State_gne__c;
                        //4
                        sAddresses +='$' + lSites[i].Site_Address_gne__c;
                  
                  // Adding lat and long information
                        //5
                        sAddresses +='$' +  lSites[i].Site_Latitude_gne__c;
                        //6
                        sAddresses +='$' +  lSites[i].Site_Longitude_gne__c;
                        
                  // Adding contact information
                        //7                 
                        sAddresses +='$' + lSites[i].Site_Contact_Name_gne__c;
                        //8
                        sAddresses +='$' + lSites[i].Site_Contact_Email_gne__c;
                        //9
                        sAddresses +='$' + lSites[i].Site_Contact_Phone_gne__c;
                        //10
                        sAddresses +='$' + lSites[i].Site_Name_gne__c;
                        //11
                        sAddresses +='$' + lSites[i].Site_Distance_gne__c;
                        //12
                        sAddresses +='$' + lSites[i].Site_Status_gne__c;
                        //13
                        sAddresses +='$' + lSites[i].id;
                    if(i != lSites.size()-1)
                    sAddresses += '#';
                    System.Debug('XXXXXXXXXXXX DAO :' + sAddresses); 
                }
        System.Debug('XXXXXXXXXXXX FULL DAO :' + sAddresses);  
        
        // Replace all " ' " to non-confilct sign.
        sAddresses = sAddresses.replace('\'','`'); 
        return sAddresses;
     }
    public Set<String> getStatesOrCountries(GNE_TISL_Site_Pager pager)
    {
         if(pager.FilteredBy =='State' || pager.FilteredBy =='Country')
         {
         	lSitesStates = dictionaryForFilters.get(pager.FilteredBy);
         } else if(pager.FilteredBy =='Status') {
         	lSitesStates = dictionaryForFilters.get(pager.FilteredBy);
         	for (String val : lSitesStates ) {
              if(val == 'Active Recruiting') pager.showDefaultActive = true;
         	}
         }
         
         return lSitesStates;
    }
    

}