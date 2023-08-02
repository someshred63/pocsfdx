/*  _____ ___ ___ _      ___ ___  ___     _ ___ ___ _____    */ 
/* |_   _|_ _/ __| |    | _ \ _ \/ _ \ _ | | __/ __|_   _|   */
/*   | |  | |\__ \ |__  |  _/   / (_) | || | _| (__  | |     */
/*   |_| |___|___/____| |_| |_|_\\___/ \__/|___\___| |_|     */


public with sharing class GNE_TISL_Trial_Pager extends GNE_Base_Pager{

  private GNE_TISL_Trial_Dao dao;  
  
  public String FilteredBy;
  public String FilteredByLev2;
  public Boolean bFilteredSet;
  public String sSearchString;
  public String sSiteContact;
  public Boolean ShowRecBtnWasClicked;
  private List<String> tmpSiteStates;
  private String QueryString ;
    private String QueryParam ;
    public Boolean PerformAdvancedSerach {get;set;}
    private static final Integer ParamLong = 3;
    private static final String ACTIVE = 'Active Recruiting';
    private static final String NOSELECTION = '--None--';
    
    
    public GNE_TISL_Trial_Pager()
    {
      IsTestCase = false;
      setup();
    }
    //--- Test Constructor
    public GNE_TISL_Trial_Pager(Boolean testVal)
    {      
        IsTestCase = testVal;
        setup();
    }
    
    private void setup()
    {
      dao = new GNE_TISL_Trial_Dao(IsTestCase);
      ShowRecBtnWasClicked = false;
      currSort = 'Trial_Full_Title_gne__c';
    currSortOrder = 'asc';
    QueryParam = ''; 
    PerformAdvancedSerach = false; 
    } 
    
    public override List<SObject> getByPager(GNE_Base_Pager pager)
  {
    fullList = dao.getByPager(this); 
    return fullList;
  }
  
  // method return 2 elem list  - first is a message for VF Page alert secend is a QueryString for SOSL , if empty means param was too short. 
  public List<String> formatQueryString(String str)
  { 
        
        System.Debug('XXXXXXXXXX |Starting  formatQueryString from Pager and input string is  :' + str);
        str = String.escapeSingleQuotes(str);
        List<String> StringParam =  str.split(',',0);
        List<String> ReturningList = new List<String>();
      String tmp ='';
      String Msg = '';
      QueryParam = '';
      
       if(str != null && str != '' && str != 'Search Text...')
       {
       
                for(Integer i =0 ; i < StringParam.size();i++)
              {
                  tmp = StringParam[i].trim();              
                System.Debug('XXXXXXXXXX | input string after trim   :' + tmp);
                //checking that SOSL queury param has at least "ParamLong" character.
                if ( tmp.length() < ParamLong )
                {
                  QueryParam = '';
                  Msg = 'One of your search strings is too short, please enter at least 3 characters';
                  break;
                } 
            
            // Building Query String                     
                if(i != StringParam.size() -1 )
                {
                     QueryParam +='"'+ tmp +'" AND ';
                }     
                else
                {
                    QueryParam +='"'+ tmp +'"';
                }
              }
       System.Debug('XXXXXXXXXX | QueryParam value   :' + QueryParam);
       }
       else
       {
           QueryParam = '';
        Msg = 'Please enter search criteria and try again.';
       }
        
     
     System.Debug('XXXXXXXXXX | Msg Added to Result   :' + Msg);
     System.Debug('XXXXXXXXXX | QueryParam Added to Result   :' + QueryParam);      
       ReturningList.add(Msg);
         ReturningList.add(QueryParam);              
     
     StringParam.clear();
         QueryParam ='';
            
       return ReturningList ; 
  }
  
  public List<String> formatQueryStringAdvanced(String str1,String str2,String str3,String str4,String str5,String str6) {
    return formatQueryStringAdvanced(str1, str2, str3, str4, str5, str6, null);
  }

  public List<String> formatQueryStringAdvanced(String str1,String str2,String str3,String str4,String str5,String str6,String str7)
  { 
    // str1 - NCT Number    // str4 - Status
    // str2 - Diagnosis      // str5 - Phase
    // str3 - Product      // str6 - State
    // str7 - Contact
    List<String> ReturningList = new List<String>();
    String Msg = '';
    Boolean wasPrevious = false;
    Boolean wasPreviousCountry = false;
    
    QueryParam ='WHERE ';
    String SubQueryParam = '';
    if (str1 != null && str1 != '')
      {
        str1 = String.escapeSingleQuotes(str1);
        QueryParam += 'NCT_Number_gne__c LIKE \'%'+ str1 +'%\'';
        wasPrevious = true;
      }
    if (str2 != null && str2 != '')
      {
        if (wasPrevious) QueryParam += ' AND ';
        str2 = String.escapeSingleQuotes(str2);
        QueryParam += 'Diagnosis_gne__c LIKE \'%'+ str2 +'%\'';
        wasPrevious = true;
      }
      if (str3 != null && str3 != '')
        {
          if (wasPrevious) QueryParam += ' AND ';
          str3 = String.escapeSingleQuotes(str3);
          System.Debug('XXXXXXXXXXXXXXXX : ' + str3);
          QueryParam += '(Product_Name_gne__c LIKE \'%'+ str3 +'%\'';
          QueryParam += ' OR ';
          str1 = String.escapeSingleQuotes(str3);
          QueryParam += 'Product_Description_gne__c  LIKE \'%'+ str3 +'%\')';
          wasPrevious = true;
        }
      if (str4 != null && str4 != '' && str4 != NOSELECTION)
        {
          if (wasPrevious) QueryParam += ' AND ';
          str4 = String.escapeSingleQuotes(str4);
          QueryParam += 'Trial_Status_gne__c LIKE \''+ str4 +'\'';
          wasPrevious = true;
        }
      if (str5 != null && str5 != '' && str5 != NOSELECTION)
      {        
          if (wasPrevious) QueryParam += ' AND ';
          str5 = String.escapeSingleQuotes(str5);
          QueryParam += 'Phase_gne__c LIKE \''+ str5 +'\'';
      }
      if (str6 != null && str6 != '' && str6 != NOSELECTION)
      {
        str6 = String.escapeSingleQuotes(str6);
        SubQueryParam += '\''+ str6 +'\'';
        wasPreviousCountry = true;
      }
        
      if (QueryParam.length() == 6 && SubQueryParam == '' && (str7 == null || str7.trim() == '' ))
      {  
        Msg = 'Please enter search criteria and try again';
        QueryParam = '';
        ReturningList.add(Msg);
           ReturningList.add(QueryParam);      
      }
      else
      {
         if(SubQueryParam != '')
         {
           QueryParam += '#'+ SubQueryParam;
         }
         ReturningList.add(Msg);
            ReturningList.add(QueryParam);    
      }
    return ReturningList;  
    
  }
  //---Build the display list
  private List<TISL_Clinical_Trial_gne__c> dispList;
  private List<TISL_Clinical_Trial_gne__c> tmplist;
  private List<TISL_Clinical_Trial_gne__c> filteredlist;
    public List<TISL_Clinical_Trial_gne__c> getDispList()
    {
        return dispList;
    }
    
  public override void changeDispData()
    {  
      Boolean IsPresent;
      dispList = new List<TISL_Clinical_Trial_gne__c>{};
        
        if (bFilteredSet)
        {
        if(FilteredBy != null && FilteredBy != '' && FilteredBy != '--None--')
      {
            filteredlist = new List<TISL_Clinical_Trial_gne__c>{};
            Set<id> TrialId = new Set<Id>();
            try {
                 for(AggregateResult ag : [Select t.Clinical_Trial_gne__c, count(t.Site_State_gne__c) from TISL_Site_gne__c t Where t.Site_State_gne__c in (:FilteredBy,'') AND t.Clinical_Trial_gne__c in :(List<TISL_Clinical_Trial_gne__c>)fullList  GROUP BY t.Clinical_Trial_gne__c])
                 {
                     TrialId.add((Id)ag.get('Clinical_Trial_gne__c'));
                 }
                 for (SObject row : fullList)
                  {
                    if (TrialId.contains(row.Id))
                      {
                             filteredlist.add((TISL_Clinical_Trial_gne__c)row);
                      }
                  }
   
            }
            catch (Exception e)
            {
              System.Debug('TISL : Method changeDispData : ' + e);
            }
            tmplist = filteredlist;
      }
        }
        else
        {
           tmplist = fullList;
        } 
        
        if(ShowRecBtnWasClicked)
        {
          if(bFilteredSet)
          {
            filteredlist = new List<TISL_Clinical_Trial_gne__c>{};
            
            try {
              for (SObject row : tmplist)
              {
                TISL_Clinical_Trial_gne__c tmpRow = (TISL_Clinical_Trial_gne__c)row;
                if (tmpRow.Trial_Status_gne__c  == ACTIVE)
                    {
                      filteredlist.add(tmpRow);
                    }
              }
            }
            catch (Exception e)
            {
              System.Debug('TISL : Method changeDispData : ' + e);
            }
            tmplist = filteredlist;
          }
          else
          {
           try{  
            filteredlist = new List<TISL_Clinical_Trial_gne__c>{};
            for (SObject row : fullList)
            {
              TISL_Clinical_Trial_gne__c tmpRow = (TISL_Clinical_Trial_gne__c)row;
              if (tmpRow.Trial_Status_gne__c  == ACTIVE)
                  {
                    filteredlist.add(tmpRow);
                  }
            }
           }
           catch (Exception e)
            {
              System.Debug('TISL : Method changeDispData : ' + e);
            }
            tmplist = filteredlist;
          }
        }
   
            
            setRecordCount(tmplist.size());
        if (tmplist != null && tmplist.size() > 0)
        {       
              if (tmplist.size() < pageEndPos) pageEndPos = tmplist.size();
              for (Integer i = pageStartPos; i < pageEndPos + 1; i++) 
              {
              dispList.add((TISL_Clinical_Trial_gne__c) tmplist[i-1]);
            }
      }  
      
   }  
    
    public List<String> getStates()
  {
    tmpSiteStates = dao.getStates(this);
    return tmpSiteStates;
  }
}