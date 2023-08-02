/*  _____ ___ ___ _      ___ ___  ___     _ ___ ___ _____    */ 
/* |_   _|_ _/ __| |    | _ \ _ \/ _ \ _ | | __/ __|_   _|   */
/*   | |  | |\__ \ |__  |  _/   / (_) | || | _| (__  | |     */
/*   |_| |___|___/____| |_| |_|_\\___/ \__/|___\___| |_|     */


public with sharing class GNE_TISL_Trial_Dao extends GNE_Base_Dao {

    public class SiteException extends Exception {}  
    public class TooManyResultsException extends Exception {}
    private List<TISL_Clinical_Trial_gne__c> lTrials;
    private List<Id> TrialsID;
    private List<String> lSitesStates;
    private List<TISL_Clinical_Trial_gne__c> lSeachedTrials;
    public static final String TOO_MANY_RESULTS_MSG = 'Too many query rows';
    private String QueryString ;
    private String QueryParam ;
    private String SubQueryParam ;
    public Map <Id,List<TISL_Site_gne__c>> mTrialswithSites;
    //---Test Constructor
    public GNE_TISL_Trial_Dao(boolean testCase)
    {
        IsTestCase = testCase;
        init();
    }
    
    public void init()
    {
        ClassName = 'GNE_TISL_Trial_Dao';
        lSitesStates = new List<String>();
        lTrials = new List<TISL_Clinical_Trial_gne__c>();
        mTrialswithSites = new Map<Id , List<TISL_Site_gne__c>>();
        TrialsID = new List<Id>();
        QueryParam = '';
        QueryString = '';
        
    }
    
    public TISL_Clinical_Trial_gne__c getTrialObject()
    {
        return  new TISL_Clinical_Trial_gne__c();
    }
    public List<TISL_Clinical_Trial_gne__c> getByPager(GNE_TISL_Trial_Pager pager)
    {
        System.Debug('XXXXXXXXXXXX Lunch getByPager from DAO');
        lTrials.clear();
        TrialsID.clear();
        mTrialswithSites.clear();
        
        lSeachedTrials = new List<TISL_Clinical_Trial_gne__c>();
        
                List<String> TmpQueryParam = pager.sSearchString.split('#');
                System.Debug('XXXXXXXXXXXX TmpQueryParam size : ' + TmpQueryParam.size());
                if(TmpQueryParam.size() > 1)
                {
                    QueryParam = TmpQueryParam[0];
                    SubQueryParam = TmpQueryParam[1];
                }
                else
                {
                    QueryParam = TmpQueryParam[0];
                    SubQueryParam ='';
                }
                if(Pager.PerformAdvancedSerach)
                {
                    String sSiteContact = pager.sSiteContact;
                    System.Debug('XXXXXXXXXXXX QueryParam and SubQueryParam : ' + QueryParam + ' SubQuery : ' +SubQueryParam + ' sSiteContact: ' + sSiteContact);
                    if(QueryParam != '' && QueryParam != null && SubQueryParam =='' && QueryParam.length() != 6)
                    { 
                        QueryString = 'Select Trial_Status_gne__c, Trial_Number_gne__c, Trial_Full_Title_gne__c, Product_Name_Calc_gne__c, Phase_gne__c, NCT_Number_gne__c, Diagnosis_gne__c,Sites_With_no_State_Count_gne__c,LastModifiedDate,Last_Updated_Date_Calc_gne__c  From TISL_Clinical_Trial_gne__c ' + QueryParam;
                        if (sSiteContact != null && sSiteContact != '') {
                            QueryString += ' AND Id in (select Clinical_Trial_gne__c from TISL_Site_gne__c WHERE Site_Contact_Name_gne__c like \'%' + sSiteContact + '%\')';
                        }
                        QueryString += ' limit 200';

                        System.Debug('XXXXXXXXXXX QueryString : ' + QueryString);
                        lSeachedTrials = Database.query(QueryString);
                        System.Debug('XXXXXXXXXXXX Founded results for query : ' + lSeachedTrials.size());
                           for (TISL_Clinical_Trial_gne__c tmp : lSeachedTrials)
                           {
                                TISL_Clinical_Trial_gne__c tmpTrial;
                                tmpTrial = tmp.clone(true,false); 
                                lTrials.add(tmpTrial);     
                           }
                    }
                    else
                    {
                      
                        if(QueryParam.length() != 6)
                            QueryString = 'SELECT Id, Trial_Status_gne__c, Trial_Number_gne__c, Trial_Full_Title_gne__c,Product_Name_Calc_gne__c,Phase_gne__c,NCT_Number_gne__c,Diagnosis_gne__c,Sites_With_no_State_Count_gne__c,Last_Updated_Date_Calc_gne__c  from  TISL_Clinical_Trial_gne__c '+ QueryParam + 'AND ';
                        else
                            QueryString = 'SELECT Id, Trial_Status_gne__c, Trial_Number_gne__c, Trial_Full_Title_gne__c,Product_Name_Calc_gne__c,Phase_gne__c,NCT_Number_gne__c,Diagnosis_gne__c,Sites_With_no_State_Count_gne__c,Last_Updated_Date_Calc_gne__c  from  TISL_Clinical_Trial_gne__c WHERE ';

                        String sitePhrase = 'Id in (select Clinical_Trial_gne__c from TISL_Site_gne__c WHERE ';
                        if (SubQueryParam != null && SubQueryParam != '') {
                            sitePhrase += 'Site_State_gne__c in ('+ SubQueryParam +' ,\'\') ';
                            if (sSiteContact != null && sSiteContact != '') {
                                sitePhrase += 'AND Site_Contact_Name_gne__c like \'%' + sSiteContact + '%\'';
                            }
                        } else if (sSiteContact != null && sSiteContact != '') {
                            sitePhrase += 'Site_Contact_Name_gne__c like \'%' + sSiteContact + '%\'';
                        }
                        QueryString += sitePhrase + ') limit 10000';
                        System.Debug('XXXXXXXXXXX QueryString : ' + QueryString);
                        lTrials = Database.query(QueryString);
                     
                    }
                }
                else
                {
                    QueryString = 'FIND \'( '+QueryParam+' )\' IN ALL FIELDS RETURNING TISL_Clinical_Trial_gne__c(Trial_Status_gne__c,Trial_Full_Title_gne__c,Trial_Contact_Name_gne__c,Therapeutic_Area_gne__c,Product_Name_Calc_gne__c,Phase_gne__c,NCT_Number_gne__c,Id,Diagnosis_gne__c,Sites_With_no_State_Count_gne__c,Last_Updated_Date_Calc_gne__c)';
                    System.Debug('XXXXXXXXXX find string : ' + QueryString);
                    List<List <sObject>> searchList = search.query(QueryString);
                
                    // Looping on results to collect searched Trials
                    if(searchList != null)
                    {
                        for(SObject tmp :searchList[0])
                        {
                            lSeachedTrials.add((TISL_Clinical_Trial_gne__c) tmp);
                            TrialsID.add(tmp.Id);
                        }
                    }
                    System.Debug('XXXXXXXXXXXX getByPager from DAO and list size' + lSeachedTrials.size()); 
                    // Preparing list of Trial sObject to show them on page
                    for (TISL_Clinical_Trial_gne__c tmp : lSeachedTrials)
                    {
                            TISL_Clinical_Trial_gne__c tmpTrial;
                            
                            tmpTrial = tmp.clone(true,false); 
                             
                            lTrials.add(tmpTrial);     
                    }
                    // Clearing all variable involved in search process
                    searchList.clear();
                }
                
       
       System.Debug('XXXXXXXXXXXX getByPager from DAO and lTrials size' + lTrials.size()); 
       return lTrials;
    }
   
    public List<String> getStates(GNE_TISL_Trial_Pager pager)
    {
         lSitesStates.clear();
         if(mTrialswithSites.size() > 0 && mTrialswithSites != null  )
         {
            for ( Id tmp : mTrialswithSites.keySet())
            {
                 List<TISL_Site_gne__c> tmp1 = mTrialswithSites.get(tmp);
                 for (TISL_Site_gne__c site : tmp1 )
                 {
                    if (site.Site_State_gne__c != null && site.Site_State_gne__c != '' && site.Site_Country_gne__c == 'UNITED STATES' )
                        lSitesStates.add(site.Site_State_gne__c);   
                 }
                
            } 
         }
          System.debug('XXXXXXXXXXX lSitesStates : ' + lSitesStates);
          return lSitesStates; 
     }   
}