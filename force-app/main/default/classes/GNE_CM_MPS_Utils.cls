//Test Class: GNE_CM_MPS_Utils_Test

public class GNE_CM_MPS_Utils 
{
    public static final Date CURRENT_DATE = Date.today();
    public static final Integer ERROR_DESC_MAX_LENGTH = 4000;
    public static final String GNE_CM_MPS_Shipment_Refill_Product = 'GNE_CM_MPS_Shipment_Refill_Product';
    public static final String GNE_CM_MPS_Shipment_Refill_RecordType = 'GNE_CM_MPS_Shipment_Refill_RecordType';
    public static final String GNE_CM_MPS_Shipment_Refill_Ship_Action_Type = 'GNE_CM_MPS_Shipment_Refill_Ship_Action_Type';
    public static final String GNE_CM_MPS_PORTAL_PROFILES = 'GNE_CM_MPS_PORTAL_PROFILES';
    public static final String GNE_CM_MPS_INTAKE_PROFILES ='GNE_CM_MPS_INTAKE_PROFILES';
    public static final String GNE_CM_MPS_ARX_ESIGN_INVITE ='GNE_CM_MPS_ARX_ESIGN_INVITE';
    public static final String GNE_CM_MPS_ARX_EPAN ='GNE_CM_MPS_ARX_EPAN';
    public static final String GNE_CM_MPS_ARX_ESIGN_ENDPOINT ='GNE_CM_MPS_ARX_ESIGN_ENDPOINT';
    public static final String GNE_CM_MPS_XMLFEED_URL='GNE_CM_MPS_XMLFEED_URL';
    public static final String GNE_CM_MPS_MYPROFILE_SETTINGS = 'GNE_CM_MPS_MyProfileSettings';
    public static final String SCM_URL = 'SCM_URL';
    public static final String SCM_WebserviceURL = 'SCM_WebserviceURL';
    public static final String SCM_AccountID = 'SCM_AccountID';
    public static final String GNE_CM_MPS_PER_DOCUMENTS = 'GNE_CM_MPS_PER_DOCUMENTS';
    public static final String GNE_CM_MPS_SEARCH_PRODUCT_LIST = 'GNE_CM_MPS_SEARCH_PRODUCT_LIST';
    public static final String GNE_CM_MPS_SEARCH_GATCF_REC_TYPE_LIST = 'GNE_CM_MPS_SEARCH_GATCF_REC_TYPE_LIST'; 
    public static final String GNE_CM_MPS_PER_EDIT_PROFILE = 'GNE_CM_MPS_PER_EDIT_PROFILE';   
    public static final String BIO_ONC_ORAL='BioOncology Oral Products';
    public static final String BIO_ONC_INFU='BioOncology Infused Products';
    public static final String ZEL_240MG='ZELBORAF prescription';
    public static final String ZEL_960MG_2DAILY='960 mg twice a day';
    public static final String ZEL_240MG_SURE='ZELBORAF Sure Start free starter supply';
    public static final String ERI_150MG='Erivedge prescription';
    public static final String ERI_150MG_DAILY='150 mg daily';
    public static final String ERI_150MG_SURE='Erivedge Sure Start free starter supply';
    public static final String TAR_SURE='Tarceva Sure Start';
    public static final String TAR_PRESC='Tarceva prescription';
    public static final String COT_DOSAGE_60MG_21_ON_7_OFF = '60mg Daily 21 days on 7 days off';
    public static final String COT_SURE_START_60MG_21_ON_7_OFF = '60mg Daily 21 days on 7 days off';

    public static String externalAccountId {get; set;}    
    
    public static String basicSearchValue{Get; set;}
    
    private static GNE_CM_MPS_User__c currentMPSUser;
    public static GNE_CM_MPS_User__c getCurrentMpsUser(){
        if(currentMPSUser == null){
            List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id,SFDC_User__c,SFDC_User__r.AccountId,GNE_CM_MPS_Registration__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :UserInfo.getUserId()];
           if (mpsUsers.isEmpty())
           {
            throw new GNE_CM_Exception('No MPS user found for the current SFDC user with ID = ' + UserInfo.getUserId());
           }      
           currentMPSUser = mpsUsers.get(0);
        }
        return currentMPSUser;
    }//end getCurrentMpsUser()

    public static boolean  isLWOUser(String userEmail)
    {
       
         List<User> lwoUsers = [SELECT id FROM User WHERE Profile.name in
                              ('GNE-LWO-USER','GNE-LWO-USER-FREQUENT') 
                               and username LIKE : userEmail + '%'];
         if (lwoUsers !=null && lwoUsers.size() > 0) //the case when LWO user EXISTS
         {  
            return true;
         }
        return false;
    }

    // Return product selectoptions for use thoughout the MPS
    public static List<SelectOption> getTherapeuticAreaItems() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0', '--Select an Enrollment Form--'));       
  
        // SAW: 2012-07-12 Start: Added new BioOnc Areas
        options.add(new SelectOption('BioOncology Infused Products','BioOncology Infused Products')); 
        options.add(new SelectOption('BioOncology Oral Products','BioOncology Oral Products')); 
        // SAW: 2012-07-12 End: Added new BioOnc Areas
        //Rama 5/12/2015 - Esbriet
        if(!isMPSDisabledProduct('Esbriet')) {
            options.add(new SelectOption('Esbriet','Esbriet (pirfenidone)')); 
        }          
        //PS: 7/16/2012options.add(new SelectOption('Erivedge','Erivedge'));      
        options.add(new SelectOption('Lucentis','Lucentis (ranibizumab injection)'));
//DSO:PFS-1778 Pegasys Sunset   options.add(new SelectOption('PEGASYS','PEGASYS (peginterferon alfa-2a) for injection'));
        if(!isMPSDisabledProduct(System.Label.GNE_CM_OCRE_Product_Name)) {
            options.add(new SelectOption(System.Label.GNE_CM_OCRE_Product_Name,'Ocrevus (ocrelizumab)')); 
        }          
        options.add(new SelectOption('Pulmozyme','Pulmozyme (dornase alfa)')); 
        options.add(new SelectOption('Rheumatology','Rheumatology'));
        options.add(new SelectOption('Xolair','Xolair (Omalizumab) for subcutaneous use'));
        if(!isMPSDisabledProduct(System.Label.GNE_CM_Venetoclax_Product_Name)) {
            options.add(new SelectOption(System.Label.GNE_CM_Venetoclax_Product_Name,'Venclexta (venetoclax)')); 
        }          
        //PS: 7/16/2012  options.add(new SelectOption('ZELBORAF','ZELBORAF'));     
        return options;
    }
    
    /* gets a MPS User Preferences object for given MPS User */
    public static GNE_CM_MPS_User_Preferences__c getMpsUserPreferences(String uid, Boolean customFieldsOnly, List<String> fieldList)
    {
        if (uid == null) {
            return null;
        }
        Set<String> getFields = (customFieldsOnly || fieldList != null) ? new Set<String>{'Id'} : new Set<String>() ;
        if (fieldList != null) {
            getFields.addAll(fieldList);
        }
        else {
            Map<String,Schema.SObjectField> prefsFields = Schema.SObjectType.GNE_CM_MPS_User_Preferences__c.fields.getMap();
            for (String fn : prefsFields.keySet()) {
                if (customFieldsOnly && !fn.endsWith('__c')) {
                    continue;
                }
                else {
                    getFields.add(fn);
                }
            }
        }
    List<GNE_CM_MPS_User_Preferences__c> prefs = Database.query('SELECT ' + String.join(new List<String>(getFields), ', ') + ' FROM GNE_CM_MPS_User_Preferences__c WHERE MPS_User__c = :uid');
        if (prefs.isEmpty()) {
            return null;
        }
        else if (prefs.size() > 1) {
            throw new GNE_CM_Exception('More than one GNE_CM_MPS_User_Preferences__c object found for MPS user with Id = ' + uid);
        }
        return prefs.get(0);
    }
    
    /* gets a MPS User Preferences object for given MPS user */
    public static GNE_CM_MPS_User_Preferences__c getMpsUserPreferences(String uid, Boolean customFieldsOnly)
    {
        return GNE_CM_MPS_Utils.getMpsUserPreferences(uid, customFieldsOnly, null);
    }
    
    /* gets a MPS User Preferences object for given MPS user */
    public static GNE_CM_MPS_User_Preferences__c getMpsUserPreferences(String uid, List<String> fieldList)
    {
        return GNE_CM_MPS_Utils.getMpsUserPreferences(uid, false, fieldList);
    }
    
    /* gets a MPS User Preferences object for given MPS user */
    public static GNE_CM_MPS_User_Preferences__c getMpsUserPreferences(String uid)
    {
        return GNE_CM_MPS_Utils.getMpsUserPreferences(uid, false, null);
    }
    
    /* gets a MPS User Preferences object for given SFDC User */
    public static GNE_CM_MPS_User_Preferences__c getSfdcUserPreferences(Id uid, Boolean customFieldsOnly, List<String> fieldList)
    {
        if (uid == null) {
            return null;
        }
        List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :uid limit 1];
        if (mpsUsers.isEmpty()) {
            throw new GNE_CM_Exception('No MPS user found for the current SFDC user with Id = ' + uid);
            return null;
        }
        return GNE_CM_MPS_Utils.getMpsUserPreferences(mpsUsers.get(0).Id, customFieldsOnly, fieldList);
    }
    
    /* gets a MPS User Preferences object for given SFDC User */
    public static GNE_CM_MPS_User_Preferences__c getSfdcUserPreferences(Id uid, Boolean customFieldsOnly)
    {
        return GNE_CM_MPS_Utils.getSfdcUserPreferences(uid, customFieldsOnly, null);
    }
    
    /* gets a MPS User Preferences object for given SFDC User */
    public static GNE_CM_MPS_User_Preferences__c getSfdcUserPreferences(Id uid, List<String> fieldList)
    {
        return GNE_CM_MPS_Utils.getSfdcUserPreferences(uid, false, fieldList);
    }
    
    /* gets a MPS User Preferences object for given SFDC User */
    public static GNE_CM_MPS_User_Preferences__c getSfdcUserPreferences(Id uid)
    {
        return GNE_CM_MPS_Utils.getSfdcUserPreferences(uid, false, null);
    }
         
    public List<SelectOption> getNewProduct() 
    {
        Schema.DescribeFieldResult productField;
        List<Schema.PicklistEntry> productFieldValues;
        List<string> productValues = new List<String>();
        
        productField = Patient_Enrollment_Request_gne__c.Product_gne__c.getDescribe();
        if(productField != null)
        {
            productFieldValues = productField.getPicklistValues();
        }
        else
        {
            productFieldValues = new List<Schema.PicklistEntry>();
        }
        if(productFieldValues != null && productFieldValues.size() > 0)
        {
            for(Schema.PicklistEntry s : productFieldValues)
            {
                productValues.add(s.getLabel());
            }   
        }
        List<SelectOption> options = new List<SelectOption>();
        if(productValues != null && productValues.size() > 0)
        {
            for(String s : productValues)
            {
                options.add(new SelectOption(s, s));
            }
        }       
        return options;
    } 
    
    public static Map<String, List<Environment_Variables__c>> populateEnvVariables(Set<String> envVarNameSet)
    {
        Map<String, List<Environment_Variables__c>> result = new Map<String, List<Environment_Variables__c>>();
        List<Environment_Variables__c> evList = getAllEnvVariables(envVarNameSet);
        if(evList != null && evList.size() > 0)
        {
            for (Environment_Variables__c envVar : evList)
            {
                if(result.containsKey(envVar.Key__c))
                {
                    if(result.get(envVar.Key__c) != null)
                    {
                        result.get(envVar.Key__c).add(envVar);
                    }
                    else
                    {
                        result.put(envVar.Key__c, new List<Environment_Variables__c>());
                        result.get(envVar.Key__c).add(envVar);
                    }
                }
                else
                {
                    List<Environment_Variables__c> variables = new List<Environment_Variables__c>();
                    variables.add(envVar);
                    result.put(envVar.Key__c, variables);
                }        
            }
        }
        return result;
    }
    
    private static List<Environment_Variables__c> getAllEnvVariables(Set<String> variable)
    {
        try
        {            
            List<Environment_Variables__c> query = new List<Environment_Variables__c>();
            List<String> Environment = new List<String>{'ALL'};
            string userName = Userinfo.getUsername();
            if(userName != null && userName != '')
            {
                String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
                if(environmentName != null && environmentName.length() > 0)
                {
                    Environment.add(environmentName);
                }                
            }
            
            if(variable != null && variable.size()>0)
            {
                query = [select Environment__c, Key__c, Value__c from Environment_Variables__c where Environment__c IN :Environment and Key__c IN :variable];                 
            }
            return (query);
        }
        catch(exception e)
        {
            //wilczekk: environment variables are often populated in constructor so we cannot insert error in this context
            //Error_Log_gne__c err = createError('Environment_Variables__c', 'Low', 'getAllEnvVariables', 'Apex Class', e);
            //Database.insert(err);
            System.debug('EXCEPTION OCCURRED: ' + GlobalUtils.getExceptionDescription(e));
            List<Environment_Variables__c> query_error = new List<Environment_Variables__c>();
            return(query_error);
        }
    }
    
    public static Map<String, String> getLicenseInformation(Id accountId)
    {
        Map<String, String> result = new Map<String, String>();
        List<ProfileID_License_gne__c> license_info=[SELECT p.Account_Name_gne__c, 
                                            p.ID_License_gne__c, 
                                            p.ID_License_Type_gne__c,
                                            p.State_gne__c,
                                            p.LastModifiedDate,
                                            p.Address_gne__c
                                            FROM ProfileID_License_gne__c p  
                                            WHERE p.ID_License_Type_gne__c IN 
                                            ('State License', 'NPI #', 'PTAN', 'Tax ID', 'DEA #')
                                            AND p.Account_Name_gne__c =: accountId];
        if(license_info!=null && license_info.size()>0)
        {
            for(ProfileID_License_gne__c license : license_info)
            {
           
                if(license.ID_License_Type_gne__c == 'State License')
                {
                    if(!result.containsKey(license.Account_Name_gne__c + license.State_gne__c + license.Address_gne__c))
                    {
                        result.put(license.Account_Name_gne__c + license.State_gne__c + license.Address_gne__c, 
                                license.ID_License_gne__c);
                    }
                    
                }
                else
                {
                    if(!result.containsKey(license.Account_Name_gne__c + license.ID_License_Type_gne__c + license.State_gne__c + license.Address_gne__c))
                    {
                        result.put(license.Account_Name_gne__c + license.ID_License_Type_gne__c + license.State_gne__c + license.Address_gne__c, 
                                license.ID_License_gne__c);
                    } 
                }
            
            }
        }
        return result; 
    } 
    
    public static List<String> getListOfPicklistValues(List<Schema.PicklistEntry> fieldValues)
    {
        List<String> result = new List<String>();
        if(fieldValues != null && fieldValues.size() > 0)
        {
            for(Schema.PicklistEntry s : fieldValues)
            {
                result.add(s.getLabel());
            }
        }
        return result;
    }
    
    public static Set<String> getSetOfPicklistValues(List<Schema.PicklistEntry> fieldValues)
    {
        Set<String> result = new Set<String>();
        if(fieldValues != null && fieldValues.size() > 0)
        for(Schema.PicklistEntry s : fieldValues)
        {
            result.add(s.getLabel());
        }
        return result;
    }  
    
    public static Boolean userExists(String email)
    {
        //We need to check if there is any user with this email id for MPS Profile even if the SFDC user is active or not.
        Integer Count_user = [Select Count() from user where Email =:email and Profile_Name_gne__c  IN ('GNE-CM-Physician Profile', 'GNE-CM-Physician Profile-Frequent') /*and IsActive = true*/];
        if(Count_user != 0) {
            return true;
        } 
        else
            return false;
    }
    
    // Used by MPS simple search
    // processes special characters 
    public static String space(string param) 
    {

    String outputString='';
            
    if(param != null && param != '')
        {     
            Pattern pat=Pattern.compile('[a-zA-Z0-9]');
            Pattern pat1=Pattern.compile('[,\\W]+');
            Integer length=param.length();
            Integer index;
            Integer first1,second, enter=0;
            Boolean firstBol;
            Boolean run;
            String[] searchString=param.split(' ');
            Integer k;

            try 
            {
                if(searchString != null && searchString.size() > 0)
                {
                    for(integer l=0;l<searchString.size();l++)
                    {
                        System.debug('-==============================='+searchString[l]);
                    }
                }
                
                if(searchString != null && searchString.size() > 0 && param!=null && param!='')
                {
                    
                    for(k=0;k<searchString.size();k++)
                    {   
                        Matcher mat1=pat1.matcher(searchString[k]); // checking word containing whole special characters or not
                        length=searchString[k].length();
                        
                        if(mat1!=null && !mat1.matches())  // entering in loop for words with special characters
                        {
                            index=1;
                            for(Integer i=0;i<length;i++) // for 
                            {
                                index=i;
                                
                                System.debug('----------k----------'+k+'------------extracted string is -----'+searchString[k]);
                                Matcher match=pat.matcher(searchString[k].subString(index,i+1));
                                System.debug('-------------Character is -----------------'+searchString[k].subString(index,i+1)+'==========Matched or not================='+match.matches());
                                if(match.matches())
                                {
                                    first1=i;
                                    break;
                                }
                            
                            }
                            System.debug('--------First character at position---------------'+first1);
                            
                            index=length; // For reverse Checking
                            for(Integer i=1; i<length+1;i++)
                            {
                                index=i;
                                Matcher match=pat.matcher(searchString[k].subString(length-i,length-i+1));
                                System.debug('-------------Character is -----------------'+param.subString(length-i,length-i+1)+'==========Matched or not================='+match.matches());
                                if(match.matches())
                                {
                                    second=length-i+1;
                                    break;
                                }
                        
                            }
                            if(searchString[k]!= null && searchString[k]!= '' && k < searchstring.size() - 1)
                                outputString+=searchString[k].subString(first1,second)+' ';
                            else if(searchString[k]!= null && searchString[k]!= '')
                                outputString+=searchString[k].subString(first1,second);
                            else    
                                outputString+=' ';
                        } // ending of loop which escpaing special characters
                    } // ending of loop which contains set of words after splitting
                } // ending of if condition which checks param value null or not
                //outputString=outputString.trim();
                 System.debug('---output String is -----'+outputString);
                 //outputString=outputString.replace('(','\\\\(');
                 //outputString=outputString.replace(')','\\\\)');
            }
            catch(Exception e)
            {
                Error_Log_gne__c err = createError('String', 'Low', 'space', 'Apex Class', e);
                Database.insert(err);               
                System.debug('---Exception in replacing special character is -----'+e);
            }


        }
        System.debug('---output String is -----'+outputString);
    return outputString;
  }

    public static List<String> getCurrentUserAddressList()
    {
        return getCurrentUserAddressList([SELECT id, accountId FROM User where id =:UserInfo.getUserId()][0]);
    }
    
    public static List<String> getCurrentUserAddressList(User user)
    {
        List<String> addressStrList = new List<String>();
        List<GNE_CM_MPS_Practice_Agreement__c> regRecDet = new List<GNE_CM_MPS_Practice_Agreement__c>();
        List<GNE_CM_MPS_Practice_Agreement__c> prescriberList = new List<GNE_CM_MPS_Practice_Agreement__c>();
        List<GNE_CM_MPS_Practice_Agreement_Location__c> addressList = new List<GNE_CM_MPS_Practice_Agreement_Location__c>();

        regRecDet = [SELECT id, MPS_Registration__c, Account__c FROM GNE_CM_MPS_Practice_Agreement__c WHERE Account__c = :user.AccountId AND Is_User__c = true limit 1];
        if(regRecDet != null && regRecDet.size() > 0 ) 
        {
            addressList = [SELECT id, Address__c, MPS_Registration__c FROM GNE_CM_MPS_Practice_Agreement_Location__c WHERE MPS_Registration__c = :regRecDet[0].MPS_Registration__c];
        }

        if(addressList != null && addressList.size() > 0)
        {
            for(GNE_CM_MPS_Practice_Agreement_Location__c address : addressList )
            {
                if(address.Address__c != null)
                {
                    addressStrList.add(address.Address__c);
                }
            }
        }
        return addressStrList;
    }
    
    public static Boolean validateEmail(String emailAddress)
    {           
        Pattern mailPattern = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})');
        Matcher mailMatcher = mailPattern.matcher(emailAddress);
        if (mailMatcher != null && !mailMatcher.matches()) 
        {
            return false;            
        }
        return true;
    }
    
    public static Boolean validateNumeric(String input)
    {
        Pattern antiPattern = Pattern.compile('\\D+');
        Matcher containsInvalid = antiPattern.matcher(input);
        if (containsInvalid != null && containsInvalid.matches())
        {
            return false;
        }
        return true; 
    }
    
    public static Boolean validatePhone(String phone)
    {           
        Pattern phonePattern = Pattern.compile('^((\\([0-9]{3}\\))[ ][0-9]{3}[-][0-9]{4})$');
        Matcher phoneMatcher = phonePattern.matcher(phone);
        if (phoneMatcher != null && !phoneMatcher.matches()) 
        {
            return false;            
        }
        return true;
    }
    
    //  standard usa phone # format
    public static String formatPhoneNumber(String phone) 
    {
    return formatPhoneNumber(phone, 'usa');
  }    

  public static String unformatPhoneNumber(String phone) 
  {
    return formatPhoneNumber(phone, 'none');
  }    
  
  public static String formatPhoneNumber(String phone, String format) 
  {
        String phRet=phone;
    
        if (phone!=null) 
        {
            pattern myPattern = pattern.compile('^\\(?([\\d]{3})\\)?[\\s-]?([\\d]{3})[\\s-]?([\\d]{4})$'); 
            matcher myMatcher = myPattern.matcher(phone);
            if (myMatcher.matches() && myMatcher.groupCount()==3) 
            {
        if (format=='usa')
        {
                phRet='(' + myMatcher.group(1) + ') ' + myMatcher.group(2) + '-' + myMatcher.group(3);
            }           
        else
        {
          phRet=myMatcher.group(1) + myMatcher.group(2) + myMatcher.group(3);
        }
      }      
        }
        return phRet;
    }    
    
    // MM/dd/yyyy format
    public static String formatDate(Date dte)
    {
        String dteRet=null; 
            
        if (dte!=null)
        {
            dteRet=Datetime.newInstance(dte, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
        }
        return dteRet;
    }    
    
    
    public static Boolean validateZip(String zip)
    {           
        Pattern zipPattern = Pattern.compile('^([0-9]{5})$');
        Matcher zipMatcher = zipPattern.matcher(zip);
        if (zipMatcher != null && !zipMatcher.matches()) 
        {
            return false;            
        }
        return true;
    }
    
    public static Boolean checkForDate(String InDate)
    {
        String[] datestringsarray;
        Boolean validmonth,validyear,validdate;
        if(InDate != null)
        {
            datestringsarray = InDate.split('/');
            system.debug('***********datestringsarray************'+datestringsarray);
        }
        if(datestringsarray == null || datestringsarray.size()!=3)
        {
            return false;
        }
        else
        {
            validmonth = checkForMonth(datestringsarray[0]);
            validyear = checkForYear(datestringsarray[2]);
            validdate = checkForDayDate(datestringsarray[1]);
            if(validmonth && validyear && validdate)
            {
                return true;
            } 
            else
            {
                return false;
            }
        }        
    }
    
   private static Boolean checkForMonth(String Month)
    {   
        Boolean blnResMnth = false;
        if(Month == '01'|| Month == '02'|| Month == '03'|| Month == '04'|| Month == '05'|| Month == '06'|| Month == '07'||Month=='08'||Month=='09'||Month=='10'||Month=='11'||Month=='12'
          || Month == '1'|| Month == '2'|| Month == '3'|| Month == '4'|| Month == '5'|| Month == '6'|| Month == '7'||Month=='8'||Month=='9')   //PS:03/08/2013 Added OR condition for MPST-68
             blnResMnth = true;
        return blnResMnth;
    }
    
    private static Boolean checkForDayDate(String strdate)
    {   
        Boolean blnResDate = false;
        //PS:03/08/2013 Added for MPST-68 Start
        if(strdate.length() == 1)
        {
         Pattern p = Pattern.compile('[1-9]');
         Matcher m = p.matcher(strdate);
         blnResDate = m.matches();
        }
        else
        { //PS:03/08/2013 Added for MPST-68 End
         Pattern p = Pattern.compile('[0-9][0-9]');
         Matcher m = p.matcher(strdate);
         blnResDate = m.matches();
        }
        if(!blnResDate){
            return blnResDate;
        }
        Integer dateValue=Integer.valueOf(strdate);
        
        for (Integer i = 1; i <=9; i++)
        {
            if(strdate=='0' + String.valueOf(i))
            {
                blnResDate=true;
            }       
        }
        if(!blnResDate)
        {
            for (Integer i = 10; i <=31; i++)
            {
                if(strdate == String.valueOf(i))
                {
                    blnResDate=true;
                }               
            }
        }   
        return blnResDate;
    }
    
    private static Boolean checkForYear(String strYear)
    {
        Boolean blnResult = true;
        Pattern p = Pattern.compile('[1-9][0-9][0-9][0-9]');
        Matcher m = p.matcher(strYear);
        blnResult = m.matches();
        if(!blnResult){
            return blnResult;
        }
        String strValidChars = '0123456789' ;
        String strChar;
        Integer YrLngth=strYear.length();
        if(Integer.valueOf(strYear)>=1700 && Integer.valueOf(strYear)<=4000)
        {
            
            for (Integer i = 0; i < strYear.length() && blnResult == true; i++)
            {
                strChar = strYear.substring(i,i+1);
                if (strValidChars.indexOf(strChar) == -1 || YrLngth!=4)
                blnResult = false;
            }
        }
        else
            blnResult=false;
        return blnResult;      
    }
    
    public static List<String> getProductLogo(String productName)
    {
        List<String> result = new List<String>();
        String logoURL;
        String altLogo;
        if(productName=='Lucentis')
        {
            logoURL='/images/LUC-AS-Logo-Color.png';
            altLogo='Lucentis';
        }
        else if(productName==System.Label.GNE_CM_OCRE_Product_Name)
        {
            logoURL='/images/OCRE-AS-Logo-Color.png';
            altLogo=System.Label.GNE_CM_OCRE_Product_Name;
        }
        else
        if(productName.startswith('BioOnc') || ProductName == 'Avastin' || ProductName == 'Herceptin'
             || ProductName == 'Kadcyla' || ProductName == 'Perjeta' || ProductName == 'Rituxan'
              || ProductName == 'Erivedge' || ProductName == 'Zelboraf' || ProductName == 'XELODA' || ProductName == 'Tarceva'
              || ProductName == 'Gazyva' || ProductName=='Cotellic' || ProductName=='Tecentriq' || ProductName=='Venclexta' )
        {  
            logoURL='/images/BioOnc-AS-Logo-Color.png';
            altLogo='BioOnc';
        }
        else
        if(productName=='Pulmozyme')
        {  
            logoURL='/images/PUL-AS-Logo-Color.png';
            altLogo='Pulmozyme';
        }
        else
        if(productName=='PEGASYS')
        {  
            logoURL='/images/PEG-AS-Logo-Color.png';
            altLogo='Pegasys';
        }
        else
        if(productName=='Rheumatology' || ProductName == 'Rituxan RA' || ProductName == 'Actemra' ||ProductName == 'Actemra Subcutaneous')
        {  
            logoURL='/images/Rheumatology-Logo-Color.png';
            altLogo='Rheumatology';
        }
        else
        if(productName=='Xolair')
        {  
            logoURL='/images/XOL-AS-Logo-Color.png';
            altLogo='Xolair';
        }
        else
        if(productName=='ZELBORAF')
        {  
            logoURL='/images/ZEL-AS-Logo-Color.png';
            altLogo='ZELBORAF';
        }
         //KS: 3/12/2012 added condition for product image for MPS Erivedge
        else
        if(productName=='Erivedge')
        {  
            logoURL='/images/Erivedge_AS_Logo_Color.png';
            altLogo='Erivedge';
        }
        //Rama 5/12/2015 Esbriet
        else
        if(productName=='Esbriet')
        {  
            logoURL='/images/AS_Logo_Esbriet.png';
            altLogo='Esbriet';
        }        
        result.add(logoURL);
        result.add(altLogo);
        system.debug('LOGOS::: ' + logoURL + '  : ' + altLogo);
        return result;
    }
    
    // This function returns the Person Account related to the Logged in user
    public static Id getAccountId()
    {
         String userid = Userinfo.getuserid();  
         List<User> user_Info = new List<User>([Select AccountId From User where Id =: userid limit 1]);
         if(user_Info != null && user_Info.size() > 0)
         {
            return user_Info[0].AccountId;
         }
         return null;
    }
    
    public static Id getAccountId (String userid)
    {
         List<User> user_Info = new List<User>([Select AccountId From User where Id =: userid limit 1]);
         if(user_Info != null && user_Info.size() > 0)
         {
            return user_Info[0].AccountId;
         }
         return null;
    }
    
    // This function returns the Registration Id of the Logged In user
    public static Id getMPSRegistration()
    {    
        String accIdUser;
         if(externalAccountId == null)
            accIdUser = getAccountId();
         else
            accIdUser = externalAccountId ; 
                  
         List<GNE_CM_MPS_Practice_Agreement__c> userPracRegistrations;
         if(accIdUser != null && accIdUser != '')
         { 
             userPracRegistrations = [SELECT  MPS_Registration__c , account__c FROM GNE_CM_MPS_Practice_Agreement__c 
                                    WHERE Is_User__c = true  
                                    AND account__c =: accIdUser Limit 1];
         }
         
         if(userPracRegistrations != null && userPracRegistrations.size() > 0)
         {
            return userPracRegistrations[0].MPS_Registration__c;
         }
         return null;
    }
     // This function returns ALL the Practice Agreement records for the prescribers related to the Logged In user's Registration
     public static List<GNE_CM_MPS_Practice_Agreement__c>  getAllPrescribers()
     {
        Id registration = getMPSRegistration();
        List<GNE_CM_MPS_Practice_Agreement__c> prescriberList=new list<GNE_CM_MPS_Practice_Agreement__c>();
        List<GNE_CM_MPS_Practice_Agreement__c> praclist = [select id, Account__c, Account__r.Name, Account__r.Firstname, Account__r.Lastname, MPS_Prescriber__c,MPS_Prescriber__r.Intake_Status__c,
                                                               MPS_Prescriber__r.Mapped_Account__c, MPS_Registration__c from GNE_CM_MPS_Practice_Agreement__c 
                                                               where MPS_Registration__c=:registration
                                                               AND Is_Prescriber__c=true AND Prescriber_Disabled_Flag__c != 'Yes' order by Account__r.createdDate];
        if(praclist != null && praclist.size() > 0)
        { 
            for(GNE_CM_MPS_Practice_Agreement__c prac : praclist )
            {
                if(prac.MPS_Prescriber__r.Intake_Status__c=='Processed')
                    prescriberList.add(prac);
            }
            return prescriberList;
        }
        return null;
     }
     
     
     // This function returns UNIQUE Practice Agreement records for the prescribers related to the Logged In user's Registration
     public static List<GNE_CM_MPS_Practice_Agreement__c> getUniquePrescribers()
     {
        List<GNE_CM_MPS_Practice_Agreement__c> userPrescriberAcc=getAllPrescribers();
        
        System.debug('-------AllPrescribers List is ------------'+userPrescriberAcc);
        List<GNE_CM_MPS_Practice_Agreement__c> uniquePrescribers = new List<GNE_CM_MPS_Practice_Agreement__c>();
        
        Set<Id> presc_id = new Set<Id>();
        if (userPrescriberAcc != NULL && userPrescriberAcc.size() > 0 )
        {                                                                                                                                                                      
            for (Integer i = 0; i < userPrescriberAcc.size(); i++)
            {
                if(!presc_id.contains(userPrescriberAcc[i].MPS_Prescriber__c))
                {
                    uniquePrescribers.add(userPrescriberAcc[i]);
                    presc_id.add(userPrescriberAcc[i].MPS_Prescriber__c);
                  } 
            }
        }
        
        System.debug('-------Unique Prescribers List is ------------'+uniquePrescribers);
        if(uniquePrescribers != null && uniquePrescribers.size() > 0)
        {
            return uniquePrescribers;
        }
        return null;
     }
     
     // This function returns a list of alkl the locations in the logged in user's registration
     public static List<GNE_CM_MPS_Location__c> getPrescriberLocation()
     {
        Id registration=getMPSRegistration();
        List<GNE_CM_MPS_Location__c> locationList = [select id, City__c,State__c,Zip__c,Office_Location_Address__c,Suite__c,Intake_Status__c,Disabled__c from GNE_CM_MPS_Location__c 
                                                    where GNE_CM_MPS_Registration__c=:registration AND Disabled__c=false AND Intake_Status__c ='Processed'];
        system.debug('@@@@@@locationList@@@@@@@@'+locationList);                                            
        if(locationList != null && locationList.size() > 0)
        {
            return locationList;
        }   
        return null;                                            
     }
     
     // Atimukt Jain: 10/08/2012 Start
     public static List<GNE_CM_MPS_Location__c> getAllPrescriberLocation()
     {
        Id registration=getMPSRegistration();
        List<GNE_CM_MPS_Location__c> locationList = [select id, City__c,State__c,Zip__c,Office_Location_Address__c,Suite__c,Intake_Status__c,Disabled__c from GNE_CM_MPS_Location__c 
                                                    where GNE_CM_MPS_Registration__c=:registration AND Intake_Status__c ='Processed'];
        system.debug('@@@@@@locationList@@@@@@@@'+locationList);                                            
        if(locationList != null && locationList.size() > 0)
        {
            return locationList;
        }   
        return null;                                            
     }
     // End of Code Added by Atimukt Jain : 10/08/2012 
     
     
      public static Account getAccount(Id AccId, Id PER_registration, Id PER_location)
     {
        try
        {
            Id tempAccId=null;
            List<GNE_CM_MPS_Practice_Agreement__c> practice=[select id, account__c,MPS_Prescriber__c, MPS_Registration__c from GNE_CM_MPS_Practice_Agreement__c
                                                            where account__c=:AccId and MPS_Registration__c=: PER_registration ];
            Set<Id> pres_id=new Set<Id>();
            
            //Making a set of prescriber's Id
            if(practice!=null && practice.size()>0)
            {
                for(GNE_CM_MPS_Practice_Agreement__c prac:practice)
                {
                    pres_id.add(prac.MPS_Prescriber__c);        
                }
            }
            
            System.debug('-----Prescribers Id Set----'+pres_id);
            //Query on PA with Prescriber's Id with registration Number
            List<GNE_CM_MPS_Practice_Agreement__c> practice_prescribers=[select id, Account__r.CreatedDate, account__c,account__r.name, MPS_Prescriber__c, MPS_Registration__c from GNE_CM_MPS_Practice_Agreement__c
                                                                        where MPS_Prescriber__c in:pres_id and MPS_Registration__c=:PER_registration order by Account__r.CreatedDate];
            Set<Id> acc_id=new Set<Id>();
            System.debug('-----First Query output is -----------'+practice_prescribers);
            
            if(practice_prescribers.size()==1)  // If one record (account) is found
            {
                tempAccId=practice_prescribers[0].Account__c;
                System.debug('--------Only one record found-------------'+AccId);
            }
            else if(practice_prescribers.size()>1) // more than one account
            {
                System.debug('--------More than one record found-------------');
                
                for(GNE_CM_MPS_Practice_Agreement__c prac:practice_prescribers) // then make sets of Account's Id through practice_prescribers list
                {
                    acc_id.add(prac.account__c);        
                }
                System.debug('---Set of Account id is ---------'+acc_id);
                List<GNE_CM_MPS_Practice_Agreement_Location__c> PAL=[select id, Account__c, Account__r.CreatedDate, Address__c, Address__r.name, Address__r.Fax_vod__c, Address__r.Phone_vod__c,
                                                                                MPS_Location__c from GNE_CM_MPS_Practice_Agreement_Location__c 
                                                                                where MPS_Location__c=:PER_location and Account__c in:acc_id
                                                                                and MPS_Registration__c=:PER_registration order by Account__r.CreatedDate];
                System.debug('--------Query on Practice Agreement Location--------'+PAL);
                if(PAL.size()==0)   // if PAL list is null
                {
                    tempAccId=practice_prescribers[0].account__c;
                    System.debug('-----IN PAL if no record is found-----Account Id is(using previous selected Id in first Query) -------'+tempAccId);
                }
                else if(PAL.size()==1)  // if PAL contains only one record
                {
                    tempAccId= PAL[0].account__c;
                    System.debug('-----IN PAL if one record is found-----Account Id is -------'+tempAccId);
                    
                }
                else if(PAL.size()>1)   // if PAL contains more than one record
                {
                    tempAccId=PAL[0].account__c;
                    System.debug('---------All PAL Records-----------'+PAL);
                    System.debug('-----IN PAL if more than one record is found-----Account Id is -------'+tempAccId);
                }
            }
            System.debug('-------Temporary Account Id get---------'+tempAccId);
            List<Account> acc=[select id, name, firstName, LastName, Subspecialties_gne__c from Account where id=:tempAccId limit 1];
            System.debug('------output of account-------------'+acc);
            if(acc != null && acc.size() > 0)
            {
                return acc[0];
            }
            else
            {
                return null;
            }
        }
        catch(Exception e)
        {
            Error_Log_gne__c err = createError('Account', 'Low', 'getAccount', 'Apex Class', e);
            Database.insert(err);
            return null;
        }
     }
     
     // Depricated: user GNE_CM_MPS_ReEnroll instead
     /*
     public static Id reEnroll(Id per)
     {
        try
        {   
            Patient_Enrollment_Request_gne__c patenrol=new Patient_Enrollment_Request_gne__c();
            Map<String,sObjectField> fields;
            fields=Schema.sobjectType.patient_enrollment_request_gne__c.fields.getMap();
            List<sObjectField> pat_enroll_fields=new List<sObjectField>(); 
            pat_enroll_fields=fields.values();
            string query='select ';
            
            if(pat_enroll_fields != null && pat_enroll_fields.size() > 0)
            {
                for(sObjectField f:pat_enroll_fields)
                {
                    query+=String.valueOf(f)+',';
                }
            }
            Integer indexOfComma=query.lastIndexOf(',');
            query=query.subString(0,indexOfComma);
            if(per!=null)
            {
                query+=' from patient_enrollment_request_gne__c where id=:per';
                patient_enrollment_request_gne__c x;
                x=Database.query(query);
                system.debug('x is'+x);
                patenrol=x.clone(false,true);
                system.debug('patenrol is'+patenrol);
                patenrol.Status__c='Draft';
                patenrol.Date_Submitted_gne__c=null;
                insert patenrol;
                return  patenrol.id;
            }
            else
                return null;
        }
        catch(Exception e)
        {
            Error_Log_gne__c err = createError('Id', 'Low', 'reEnroll', 'Apex Class', e);
            Database.insert(err);
            return null;            
        }
     }
     */
     
     public static String getUserName()
     {
        String userName;
        userName=UserInfo.getUserName();
        
        if (userName.length()>30)
        {
           userName=userName.subString(0,29);
        }
        
        return userName;
     }
     
     @future
     public static void insertError(String objectName, String errorLevel, String snippetName, String codeType, String errDesc)
     {
        Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = objectName, 
                                                        Error_Level_gne__c = errorLevel,
                                                        Snippet_Name__c = snippetName, 
                                                        Code_Type__c = codeType, 
                                                        Error_Description__c = errDesc, 
                                                        User_Name__c = getUserName());
        insert error; 
     }
     
     public static boolean contains(List<String> allValues, String aValue) {
        if(allValues == null || allValues.size() <= 0) {
            return false;
        }
        
        for(String value : allValues) {
            if(value != null && aValue != null && value.equals(aValue)) {
                return true;
            }   
        }
        
        return false;
     }
     
    public static String getDatabaseErrorDescription(Database.Error error)
    {
        String errorText;
        errorText += ' Error Status Code: ' + error.getStatusCode();        
        errorText += ' Error Message: ' + error.getMessage();
        return errorText;                
    }
    
    public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, Database.Error e)
    {
        return createError(objectName, errorLevel, snippetName, codeType, null, e);
    }
    
    public static Error_Log_gne__c createError (String objectName, String errorLevel, String snippetName, String codeType, String errorDesc, Database.Error e)
    {
        Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = objectName, 
                                                      Error_Level_gne__c = errorLevel,
                                                      Snippet_Name__c = snippetName, 
                                                      Code_Type__c = codeType, 
                                                      Error_Description__c = (errorDesc != null ? errorDesc + '. ' : '') + getDatabaseErrorDescription(e), 
                                                      User_Name__c = getUserName());
                                                      
        return error; 
    }
    
    public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, Exception e)
    {
        return createError(objectName, errorLevel, snippetName, codeType, null, e);
    }
    
    public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, String errorDesc)
    {
        Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = objectName, 
                                                  Error_Level_gne__c = errorLevel,
                                                  Snippet_Name__c = snippetName, 
                                                  Code_Type__c = codeType, 
                                                  Error_Description__c = errorDesc,
                                                  User_Name__c = getUserName());
        return error;
    }
    
    public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, String errorDesc, Exception e)
    {
        Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = objectName, 
                                                  Error_Level_gne__c = errorLevel,
                                                  Snippet_Name__c = snippetName, 
                                                  Code_Type__c = codeType, 
                                                  Error_Description__c = (errorDesc != null ? errorDesc + '. ' : '') + (e != null ? GlobalUtils.getExceptionDescription(e) : ''),
                                                  User_Name__c = getUserName());
        return error; 
    }
     
     // Helper to initialize first char
     public static String initCap(String input) {
        String output=input;
        if (input!=null && input != system.label.GNE_CM_Rituxan_SC_Product_Name) {
            if (input.length()>1) {
                output=input.substring(0,1).touppercase() + input.substring(1).tolowercase();
            } else {
                output=input.substring(0,1).touppercase();
            }
        }
        return output;
     }
     
     public static void debugError(Exception e)
     {
        System.Debug(GlobalUtils.getExceptionDescription(e));
     }
     
     public static void debugError(Database.Error e)
     {
        System.Debug(getDatabaseErrorDescription(e));
     }
     
     //PS: Erivedge 08/17/2012 Start
     public static string getDispenseErivedge(string StrDispense) 
     {      
       if(StrDispense == '1 Month')
          StrDispense = '28';
       else if(StrDispense == '2 Month')   
          StrDispense = '56';
       else if(StrDispense == '3 Month')     
          StrDispense = '84';          
       return StrDispense; 
     }
      //PS: Erivedge 08/17/2012 End    

    public static string getApiHostURL() 
    {
        return GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).API_Host_URL__c;
    }
      
     public static String per2mhOcrevusIndication(String perOcrevusIndication) {
     	String mhOcrevusIndication = null;
     	if (perOcrevusIndication == 'Relapsing Multiple Sclerosis (RMS)') {
     		mhOcrevusIndication = 'RMS';
     	} else if (perOcrevusIndication == 'Primary Progressive Multiple Sclerosis (PPMS)') {
     		mhOcrevusIndication = 'PPMS';
     	}
     	return mhOcrevusIndication;
     }
     
     public static String mh2perOcrevusIndication(String mhOcrevusIndication) {
     	String perOcrevusIndication = null;
     	if (mhOcrevusIndication == 'RMS') {
     		perOcrevusIndication = 'Relapsing Multiple Sclerosis (RMS)';
     	} else if (mhOcrevusIndication == 'PPMS') {
     		perOcrevusIndication = 'Primary Progressive Multiple Sclerosis (PPMS)';
     	}
     	return perOcrevusIndication;
     }
     
     public static String per2mhDispenseMonths(String perDispenseMonth)
     {
       Map<string, string> dispense_months_transfrm = new Map<string, string>{'1'=>'1 Month', '2'=>'2 Month','3'=>'3 Month'};
       
       return dispense_months_transfrm.get(perDispenseMonth);
     }
     
     public static String per2mhFEV1(String perFEV1)
     {
       String ret=null;
    if (perFEV1 == 'Mild – greater than 70%')
    {
      ret = 'Greater than 70: Mild';
    }
    else if (perFEV1 == 'Moderate – between 40% and 70%')
    {
      ret = 'Between 40-70: Moderate';
    }
    else if (perFEV1 == 'Severe– less than 40%')
    {
      ret = 'Less than 40: Severe';
    }
    else if (perFEV1 == 'Patient Under 6 Years Old')
    {
      ret = 'Unavailable: Patient is under 6 years old';
    }
    return ret;
     }
     
     public static String per2mhPulmozymePrescType(String perVal)
     {
       String mhVal=null;
    if (perVal == 'Naive/New Start')
    {
      mhVal = 'New Start';
    }
    else if (perVal == 'Continued Tx')
    {
      mhVal = 'Continued';
    }
    else if (perVal == 'Restart Tx')
    {
      mhVal = 'Restart';
    }
    return mhVal;
     }
     
     public static String per2mhPulmozymeDispense(String perVal)
     {
       String mhVal=null;
    if (perVal == '30-day supply')
    {
      mhVal = '30 days';
    }
    else if (perVal == '60-day supply')
    {
      mhVal = '60 days';
    }
    else if (perVal == '90-day supply')
    {
      mhVal = '90 days';
    }
    return mhVal;
     }

     public static String per2mhPulmozymeNebulize(String perVal)
     {
       String mhVal=null;
    if (perVal == 'Sidestream Nebulizer (part# MS2400)')
    {
      mhVal = '30 days';
    }
    else if (perVal == 'PARI LC Jet Nebulizer')
    {
      mhVal = 'One PARI LC Jet+ Nebulizer Cup';
    }
    else if (perVal == 'PARI Baby Mask size 0')
    {
      mhVal = 'One PARI Baby Mask (size 0)';
    }
    else if (perVal == 'PARI Baby Mask size 1')
    {
      mhVal = 'One PARI Baby Mask (size 1)';
    }
    else if (perVal == 'PARI Baby Mask size 2')
    {
      mhVal = 'One PARI Baby Mask (size 2)';
    }
    else if (perVal == 'PARI Baby Mask size 3')
    {
      mhVal = 'One PARI Baby Mask (size 3) comes with one PARI LC Jet+ Nebulizer Cup';
    }
    return mhVal;
     }

  public static String per2mhPlaceOfAdministration(String mhPlaceofAdmin)
  {
    String ret=null;
    system.debug ('mhPlaceofAdmin: '  + mhPlaceofAdmin);
    if (mhPlaceofAdmin == 'Physician\'s office') //Place of Administration
    {
      ret = 'MD Office / Clinic';
    }
    else if (mhPlaceofAdmin == 'Hospital - Outpatient')
    {
      ret = 'Hospital Outpatient';
    }
    else if (mhPlaceofAdmin == 'Hospital - Inpatient')
    {
      ret = 'Hospital Inpatient';
    }    
    return ret;
  }

    public static String mh2perPlaceOfAdministration(String mhPlaceofAdmin)
    {
        String ret=null;
system.debug ('mhPlaceofAdmin: '  + mhPlaceofAdmin);
        if (mhPlaceofAdmin == 'MD Office / Clinic')
        {
            ret = 'Physician\'s office';
        }
        else if (mhPlaceofAdmin == 'Hospital Outpatient')
        {
            ret = 'Hospital - Outpatient';
        }
        else if (mhPlaceofAdmin == 'Hospital Inpatient')
        {
            ret = 'Hospital - Inpatient';
        }       
           
        return ret;
        }
   
    public static String mh2perLineOfTherapy(String therapySequence)
    {
        String lineOfTherapy = null;
        
        if (therapySequence  ==  'First Line Therapy')
        {
             lineOfTherapy  =  'First';
        }
        else if (therapySequence  ==  'Second Line Therapy')
        {
             lineOfTherapy  =  'Second';
        }
        else if (therapySequence  ==  'Not Provided' || therapySequence  ==  'Other')
        {
             lineOfTherapy  =  'Other';
        }
        return lineOfTherapy;
    }

  public static String per2mhTestResultIHC(String testIHC)
  {
    String firstAssayTestResult = null;
    if (testIHC == '1+')
    { 
      firstAssayTestResult = '1+ (Neg.) - IHC only';
    }
    else if (testIHC == '2+')
    { 
      firstAssayTestResult = '2+ (Pos.) - IHC only';
    }  
    else if (testIHC == '3+')
    { 
      firstAssayTestResult = '3+ (Pos.) - IHC only';
    } 
    return firstAssayTestResult;
  }   

  public static String per2mhTherapySequence(String LineOfTherapy)
  {
    String sequence = null;
    if (LineOfTherapy == 'First') //Line of Therapy
    {
      sequence = 'First Line Therapy';
    }
    else if (LineOfTherapy == 'Second')
    {
      sequence = 'Second Line Therapy';
    }
    else if (LineOfTherapy == 'Other')
    {
      sequence = 'Not Provided';
    }
    return sequence;
  }   

    public static String mh2perTestResultIHC(String firstAssayTestResult)
    {
        String testResultsIHC = null;
        
        if (firstAssayTestResult == '1+ (Neg.) - IHC only')
        {
            testResultsIHC =  '1+';
        }
        else if (firstAssayTestResult == '2+ (Pos.) - IHC only')
        { 
            testResultsIHC =  '2+';
        }  
        else if (firstAssayTestResult == '3+ (Pos.) - IHC only')
        { 
            testResultsIHC = '3+';
        } 
        else if (firstAssayTestResult == '<=4 (Neg.) - FISH only' ||
            firstAssayTestResult == '>4 (Pos.) - FISH only' ||
            firstAssayTestResult == '0 (Neg.) - IHC only' ||
            firstAssayTestResult == 'Negative' ||
            firstAssayTestResult == 'Positive' ||
            firstAssayTestResult == 'Borderline/Equivocal' ||
            firstAssayTestResult == 'Yes' ||
            firstAssayTestResult == 'No')
        { 
            testResultsIHC = 'Other';
        } 
        return testResultsIHC;
    }   
    
    public static String mh2perClinicalTNMStage(String TNMStaging)
    {
        String clinicalTNMStage = null;
        
        if (TNMStaging==null)
        {
            // no-op
        }
        else if (TNMStaging.startsWith('Stage 0')) 
        {
            clinicalTNMStage = '0';
        }
        else if (TNMStaging.startsWith('Stage I (Early Local Disease)'))
        {
            clinicalTNMStage = 'I';
        }
        else if (TNMStaging.startsWith('Stage IIA (Early Local Disease)'))
        {
            clinicalTNMStage = 'IIA';
        }
        else if (TNMStaging.startsWith('Stage IIB (Early Local Disease)'))
        {
            clinicalTNMStage = 'IIB';
        }
        else if (TNMStaging.startsWith('Stage IIIA (Advanced Local Disease)'))
        {
            clinicalTNMStage = 'IIIA';
        }
        else if (TNMStaging.startsWith('Stage IIIB (Advanced Local Disease)'))
        {
            clinicalTNMStage = 'IIIB';
        }
        else if (TNMStaging.startsWith('Stage IIIC (Advanced Local Disease)'))
        {
            clinicalTNMStage = 'IIIC';
        }
        else if (TNMStaging.startsWith('Stage IV (Advanced Metastatic Disease)'))
        {
            clinicalTNMStage = 'IV';
        }
        
        return clinicalTNMStage;
    }   
    
  public static String per2mhClinicalTNMStage(String clinicalTNMStage)
  {
    String TNMStage = null;
    
    if (clinicalTNMStage==null)
    {
      // no-op
    }
    else if (clinicalTNMStage == '0') 
    {
      TNMStage = 'Stage 0'; 
    }
    else if (clinicalTNMStage == 'I')
    {
      TNMStage = 'Stage I (Early Local Disease)';
    }
    else if (clinicalTNMStage == 'IIA')
    {
      TNMStage = 'Stage IIA (Early Local Disease)';
    }
    else if (clinicalTNMStage == 'IIB')
    {
      TNMStage = 'Stage IIB (Early Local Disease)';
    }
    else if (clinicalTNMStage == 'IIIA')
    {
      TNMStage = 'Stage IIIA (Advanced Local Disease)';
    }
    else if (clinicalTNMStage == 'IIIB')
    {
      TNMStage = 'Stage IIIB (Advanced Local Disease)';
    }
    else if (clinicalTNMStage == 'IIIC')
    {
      TNMStage = 'Stage IIIC (Advanced Local Disease)';
    }
    else if (clinicalTNMStage == 'IV')
    {
      TNMStage = 'Stage IV (Advanced Metastatic Disease)';
    }
    
    return TNMStage;
  }  

    // helper to merge 2 multiselect (; separated) lists
    public static String mergeMultiSelects(String multiSelect1, String multiSelect2)
    {
        String ret='';
        
        // populate the set
        Set<String> setValues=new Set<String>();
        setValues.addAll((multiSelect1==null ? '' : multiSelect1).split(';'));
        setValues.addAll((multiSelect2==null ? '' : multiSelect2).split(';'));
        
        // now sort the list
        List<String> lstValues=new List<String>();
        lstValues.addAll(setValues);
        lstValues.sort();
        
        //concatenate the return string
        for (String s : lstValues)
        {
            if (ret!='')
            {
                ret+=';';
            }
            ret+=s;
        }
        
        return (ret=='' ? null : (ret + ';'));
    }
    
    /*
   * Helper class used generate the equivalent of a 'SELECT * FROM Table' query
   * 
   * @param sObjName - Object Name
   * @param bIncludeRO - flag to indicate if include Read Only Fields 
   */
    public static String getSelectStarSOQL(String sObjName) 
  {
    return getSelectStarSOQL(sObjName, true);
  }
  
    public static String getSelectStarSOQL(String sObjName, Boolean bIncludeRO) 
  {
    Map<String, Schema.SObjectField> M = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();
    String flds = '';

    // concat the field list
    for (Schema.SObjectField f : M.values())
    {
      Schema.Describefieldresult dr = f.getDescribe();
        if (dr.isUpdateable() || bIncludeRO || dr.getName() == 'Id')
        {
            if (flds.length() > 0)
            {
              flds += ',';
            }
            flds += dr.getName();
        }
      }

      return 'SELECT Recordtype.Name, ' + flds + ' FROM ' + sObjName;
  }
    
  /*
     * Helper class used by the GNE_CM_MPS_Practice_Agreement_HCO_Mapping
     * 
     * Creates an External Key map of GNE_CM_MPS_Registration_HCO_Mapping__c objects that
     * will be used by the trigger to upsert/delete these objects
     *
     * @param lst - list of objects from trigger
     * @param UseAll - flag to indicate if we lookup all HCP Registrations 
     */
    public static Map<String, GNE_CM_MPS_Registration_HCO_Mapping__c> generateRegHCOMappingMapNew(List<GNE_CM_MPS_Practice_Agreement__c> lst)
    {
        return generateRegHCOMappingMap(lst, true);
    }
    
    public static Map<String, GNE_CM_MPS_Registration_HCO_Mapping__c> generateRegHCOMappingMapOld(List<GNE_CM_MPS_Practice_Agreement__c> lst)
    {
        return generateRegHCOMappingMap(lst, false);
    }   

    public static Map<String, GNE_CM_MPS_Registration_HCO_Mapping__c> generateRegHCOMappingMap(List<GNE_CM_MPS_Practice_Agreement__c> lst)
    {
        return generateRegHCOMappingMap(lst, false);
    }   

    public static Map<String, GNE_CM_MPS_Registration_HCO_Mapping__c> generateRegHCOMappingMap(List<GNE_CM_MPS_Practice_Agreement__c> lst, Boolean UseAll)
    {
        Map<String, GNE_CM_MPS_Registration_HCO_Mapping__c> mapRet=new Map<String, GNE_CM_MPS_Registration_HCO_Mapping__c>();
    
        Set<Id> prscAcctIds=new Set<Id>();
        Map<String, List<String>> mapAffil=new Map<String, List<String>>();

        // get prescriber Accounts affected
        for (GNE_CM_MPS_Practice_Agreement__c pa : lst)
        {   
            if (pa.Account__c!=null && 
                    pa.Is_Prescriber__c==true && 
                    pa.MPS_Registration__c!=null)
            {
                prscAcctIds.add(pa.Account__c);
            }
        }
        
        
        // get HCO's for those prescriber
        for (Affiliation_vod__c aff : [SELECT Affiliation_Type_gne__c, From_Account_vod__c, Id, To_Account_vod__c FROM Affiliation_vod__c WHERE From_Account_vod__c!=null AND To_Account_vod__c IN :prscAcctIds])
        {
            if (!mapAffil.containsKey(aff.To_Account_vod__c))
            {
                mapAffil.put(aff.To_Account_vod__c, new List<String>());
            }
            mapAffil.get(aff.To_Account_vod__c).add(aff.From_Account_vod__c);
        }
        
        // pick the list to use
        List<GNE_CM_MPS_Practice_Agreement__c> lstAll=lst;
        
        if (UseAll)
        {
            lstAll=[SELECT Id, MPS_Registration__c, Account__c, Is_Prescriber__c 
                                                        FROM GNE_CM_MPS_Practice_Agreement__c 
                                                        WHERE Account__c IN :prscAcctIds];
        }
        
        // create our insert list using all Practice Agreements
        for (GNE_CM_MPS_Practice_Agreement__c pa : lstAll)
        {
            if (pa.Account__c!=null && pa.Is_Prescriber__c==true && pa.MPS_Registration__c!=null)
            {   
                if (mapAffil.containsKey(pa.Account__c))
                {
                    for (String hco : mapAffil.get(pa.Account__c))
                    {
                        String extId='HCP='+pa.Account__c + ',HCO=' + hco + ',REG='+pa.MPS_Registration__c;
                        mapRet.put(extId, new GNE_CM_MPS_Registration_HCO_Mapping__c(HCO__c=hco, 
                                        HCP__c=pa.Account__c, 
                                        MPS_Registration__c=pa.MPS_Registration__c, 
                                        MPS_Practice_Agreement__c=pa.Id,
                                        External_ID__c=extId));
                    }
                }
            }
        }
        return mapRet;
    }
    
    public static Boolean hasCaseCoPayService(Id caseId)
    {   
        List<GNE_CM_Requested_Services__c> requestedCopay = [SELECT Id FROM GNE_CM_Requested_Services__c WHERE Requested_Service_gne__c = 'Co-Pay Assistance' AND Case_gne__c =: caseId LIMIT 1];
        return !requestedCopay.isEmpty();
    }
/**
 * Indicates whether the EBI functionality is enabled for the given MPS registration. EBI is enabled for a registration if it's either enabled for all
 * registrations by the EBI_Functionality_For_Registration_gne__c custom setting, or if it's enabled only for specific registrations and this registration
 * is among them (according to the MPSRegistration.Is_Ebi_Functionality_Enabled_gne__c) flag.
 */
   
    public static boolean isEbiFunctionalityEnabledForMPSRegistration(ID registrationID)
    {
        String ebiFunctionalityForRegistration = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).EBI_Functionality_For_Registration_gne__c;    
        if(ebiFunctionalityForRegistration ==  GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED)
        {
            return true;
        }
        if(ebiFunctionalityForRegistration ==  GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED)
        {
            return false;
        }
        if(ebiFunctionalityForRegistration  == GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED)
        {
            GNE_CM_MPS_Registration__c registration = getRegistration(registrationID);
            if(registration.Ebi_Functionality_gne__c == 'enabled' )        
            {
                return true;
            }
            return false;   
        }       
        if(ebiFunctionalityForRegistration  == GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED_FOR_SELECTED)
        {
            GNE_CM_MPS_Registration__c registration = getRegistration(registrationID);
            if(registration.Ebi_Functionality_gne__c == 'disabled' )           
            {
                return false;
            }
            return true;        
        }       
        throw new GNE_CM_Exception('EBI_Functionality_gne__c equals ' + ebiFunctionalityForRegistration + '. Only the following values of EBI_Functionality_For_Registration_gne__c are correct :' + 
            GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED + ',' +
            GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED + ',' +
            GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED + ',' +
            GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED_FOR_SELECTED + ',');
        
    }
    
    private static GNE_CM_MPS_Registration__c getRegistration(ID registrationID)
    {
        List<GNE_CM_MPS_Registration__c> registrations = [select Id, Name, EBI_Functionality_gne__c from GNE_CM_MPS_Registration__c where id = :registrationId limit 1];
        if (registrations.isEmpty())
        {
            throw new GNE_CM_Exception('No MPS registration found with ID ' + registrationID);
        }
        return registrations[0];
    }   
    
    public static void createAndLogErrors(List<Database.SaveResult> saveResults, String descriptionPattern, List<String> descriptionValues, String objectName, String contextName) {
        createAndLogErrors(saveResults, descriptionPattern, descriptionValues, objectName, contextName, null);
    }
    
     public static void createAndLogErrors(List<Database.SaveResult> saveResults, String descriptionPattern, List<String> descriptionValues, String objectName, String contextName, List<sObject> originalList) {
        if (saveResults !=null && !saveResults.isEmpty()) {
            List<Error_Log_gne__c> errorsLogsToInsert = new List<Error_Log_gne__c>();
            for (Integer j=0; j< saveResults.size(); j++) {
                Database.SaveResult sr = saveResults.get(j);
                if (!sr.isSuccess()) {
                    String parsedDesc = descriptionPattern;
                    //If it is an update operation, get the id of the record that failed update.
                    if(originalList !=null && originalList.get(j) !=null && originalList.get(j).id !=null){
                       parsedDesc  = descriptionPattern.replace('{sr}', (String)originalList.get(j).id); 
                    }
                    for (Integer i = 0; i < descriptionValues.size(); i++) {
                         parsedDesc = parsedDesc.replace('{' + i + '}', descriptionValues.get(i));
                    }
                    parsedDesc = parsedDesc + createStandardErrorMessage(sr);
                    parsedDesc = shortenErrorMessage(parsedDesc);
                    Error_Log_gne__c err = GNE_CM_MPS_Utils.createError(objectName, 'High', contextName, 'Apex Class', parsedDesc);
                    errorsLogsToInsert.add(err);
                }
            }
            Database.insert(errorsLogsToInsert,false);
        } else {
            String parsedDesc  = descriptionPattern;
            for (Integer i = 0; i < descriptionValues.size(); i++) {
                parsedDesc  = parsedDesc.replace('{' + i + '}', descriptionValues.get(i));
            }
            parsedDesc = shortenErrorMessage(parsedDesc);
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError(objectName, 'High', contextName, 'Apex Class', parsedDesc);
            insert err;
            
        }
    }
    
    public static String createStandardErrorMessage(Database.SaveResult sr) 
    {
        String stdError = '';
        for (Database.Error err : sr.getErrors()) {
            stdError += ' due to fields: ' + String.join(err.getFields(),',');
            stdError += ' and the error Message is : ' + err.getMessage();
            if (stdError.length() > ERROR_DESC_MAX_LENGTH) {
                stdError = stdError.substring(0,ERROR_DESC_MAX_LENGTH);
                break;
            }
        }
        return stdError;
    }

    public static String shortenErrorMessage(String msg) 
    {
        return trimStringToMaxLength(msg,ERROR_DESC_MAX_LENGTH);
    }


    public static String trimStringToMaxLength(String stringName, Integer maxLength)
    {
        if(String.isNotBlank(stringName)&& stringName.length()>maxLength)
        {
            stringName = stringName.substring(0,maxLength);
        }
        return stringName;
    }        
    
    public static void createPERandBRarchive(List<GNE_CM_MPS_BRC_RituxanRA__c> brList, boolean findNameForPER)
    {
          List<BRC_RituxanRA_Archive__c> benefitReverificationToArchive = new List<BRC_RituxanRA_Archive__c>();
            List<Patient_Enrollment_Request_gne__c> persToUpdate = new  List<Patient_Enrollment_Request_gne__c>();
            List<QueueSObject> qID = [select QueueId from QueueSobject where Queue.name ='Submitted Patient Enrollment Requests' limit 1];
            System.debug('brlist===='+brList);
            List<Id> mhIds = new List<Id>();
            for(GNE_CM_MPS_BRC_RituxanRA__c br: brList)
            {
                mhIds.add(br.medical_history__c);
            }
            System.debug('mhIds===='+mhIds);
            Map<Id,Medical_History_gne__c> medicalHistoryMap = new Map<Id,Medical_History_gne__c>([SELECT Drug_gne__c,Product_gne__c,Eye_Affected_gne__c, Eye_Being_Treated_gne__c, ICD9_Code_1_gne__r.Name, ICD9_Code_2_gne__r.Name,ICD9_Code_3_gne__r.Name 
                                                                                                    FROM Medical_History_gne__c 
                                                                                                    WHERE id in :mhIds]);

            for (GNE_CM_MPS_BRC_RituxanRA__c benefitReverifcation : brList) 
            {
                BRC_RituxanRA_Archive__c benefitReveficationArchive = new BRC_RituxanRA_Archive__c(
                    Address_gne__c = benefitReverifcation.Address_gne__c,
                    Anticipated_Date_of_Treatment__c = benefitReverifcation.Anticipated_Date_of_Treatment__c,
                    Archive_Date_gne__c = CURRENT_DATE,
                    Case_gne__c = benefitReverifcation.Case_gne__c,
                    Cycle_End_Date_gne__c = benefitReverifcation.Cycle_End_Date_gne__c,
                    Cycle_Start_Date_gne__c = benefitReverifcation.Cycle_Start_Date_gne__c,
                    Is_Patient_Insured_gne__c = benefitReverifcation.Is_Patient_Insured__c,
                    MPS_Location_gne__c = benefitReverifcation.MPS_Location_gne__c,
                    MPS_Prescriber_gne__c = benefitReverifcation.MPS_Prescriber_gne__c,
                    MPS_Registration_gne__c = benefitReverifcation.MPS_Registration_gne__c,
                    PAN_Expiration_Date_gne__c = benefitReverifcation.PAN_Expiration_Date_gne__c,
                    Patient_Id_gne__c = benefitReverifcation.Patient_Id_gne__c,
                    PER_id_gne__c = benefitReverifcation.PER_id_gne__c,
                    PI_Phone_gne__c = benefitReverifcation.PI_Phone_gne__c,
                    PI_Policy_Group_gne__c = benefitReverifcation.PI_Policy_Group_gne__c,
                    PI_Subscriber_First_Name_gne__c = benefitReverifcation.PI_Subscriber_First_Name__c,
                    PI_Subscriber_ID_gne__c = benefitReverifcation.PI_Subscriber_ID__c,
                    PI_Subscriber_Name_gne__c = benefitReverifcation.PI_Subscriber_Name__c,
                    Prescriber_Id_Name_gne__c = benefitReverifcation.Prescriber_Id_Name_gne__c,
                    Primary_Insurance_Select_Type_gne__c = benefitReverifcation.Primary_Insurance_Select_Type__c,
                    Primary_Insurance_Carrier_Name_gne__c = benefitReverifcation.Primary_Insurance_PI_Name__c,
                    Primary_Prior_Authorization_gne__c = benefitReverifcation.Primary_Prior_Authorization_gne__c,
                    Primary_Prior_Auth_Reqd_gne__c = benefitReverifcation.Pri_Prior_Auth_Reqd_gne__c,
                    Product_gne__c = benefitReverifcation.Product_gne__c,
                    Reverification_Case_gne__c = null,
                    Secondary_Insurance_Select_Type_gne__c = benefitReverifcation.Secondary_Insurance_Select_Type__c,
                    Secondary_Insurance_Carrier_Name_gne__c = benefitReverifcation.Secondary_Insurance_SI_Name__c,
                    Secondary_Prior_Authorization_gne__c = benefitReverifcation.Secondary_Prior_Authorization_gne__c,
                    Secondary_Prior_Auth_Reqd_gne__c = benefitReverifcation.Sec_Prior_Auth_Reqd__c,
                    SI_Phone_gne__c = benefitReverifcation.SI_Phone__c,
                    SI_Policy_Group_gne__c = benefitReverifcation.SI_Policy_Group__c,
                    SI_Subscriber_First_Name_gne__c = benefitReverifcation.SI_Subscriber_First_Name__c,
                    SI_Subscriber_ID_gne__c = benefitReverifcation.SI_Subscriber_ID__c,
                    SI_Subscriber_Name_gne__c = benefitReverifcation.SI_Subscriber_Name__c,
                    Specialty_Pharmacy_Name__c = benefitReverifcation.Specialty_Pharmacy_Name__c,
                    Status_gne__c = 'Processed',
                    Submission_Date_gne__c = benefitReverifcation.Submission_Date_gne__c,
                    Submission_Number_gne__c = benefitReverifcation.Submission_Id_Number_gne__c,
                    Co_pay_Assistance_gne__c = benefitReverifcation.Co_pay_Assistance_gne__c,
                    Medical_History__c = benefitReverifcation.Medical_History__c
                );
                benefitReverificationToArchive.add(benefitReveficationArchive);
                
                if (benefitReverifcation.Case_gne__c != null) 
                {
                      Patient_Enrollment_Request_gne__c per;
                    //For single submission, don't pass MPS Reg to reenroll method.
                    if(findNameForPER)
                    {
                        per = GNE_CM_MPS_ReEnroll.reEnrollCase(benefitReverifcation.Case_gne__c);
                    }else
                    {
                        per = GNE_CM_MPS_ReEnroll.reEnrollCase(benefitReverifcation.Case_gne__c, benefitReverifcation.MPS_Registration_gne__c);
                    }
                    per.Primary_Insurance_Select_Type_gne__c        = benefitReverifcation.Primary_Insurance_Select_Type__c;
                    per.Primary_Insurance_Carrier_Name_gne__c       = benefitReverifcation.Primary_Insurance_PI_Name__c;
                    per.PI_Subscriber_First_Name_gne__c             = benefitReverifcation.PI_Subscriber_First_Name__c;
                    per.PI_Subscriber_Name_gne__c                   = benefitReverifcation.PI_Subscriber_Name__c;
                    per.PI_Phone_gne__c                             = benefitReverifcation.PI_Phone_gne__c;
                    per.PI_Subscriber_ID_gne__c                     = benefitReverifcation.PI_Subscriber_ID__c;
                    per.PI_Policy_Group_gne__c                      = benefitReverifcation.PI_Policy_Group_gne__c;
                    per.Secondary_Insurance_Select_Type_gne__c      = benefitReverifcation.Secondary_Insurance_Select_Type__c;
                    per.Secondary_Insurance_Carrier_Name_gne__c     = benefitReverifcation.Secondary_Insurance_SI_Name__c;
                    per.SI_Subscriber_First_Name_gne__c             = benefitReverifcation.SI_Subscriber_First_Name__c;
                    per.SI_Subscriber_Name_gne__c                   = benefitReverifcation.SI_Subscriber_Name__c;
                    per.SI_Phone_gne__c                             = benefitReverifcation.SI_Phone__c;
                    per.SI_Subscriber_ID_gne__c                     = benefitReverifcation.SI_Subscriber_ID__c;
                    per.SI_Policy_Group_gne__c                      = benefitReverifcation.SI_Policy_Group__c;
                    per.Anticipated_Date_of_Treatment_gne__c        = benefitReverifcation.Anticipated_Date_of_Treatment__c;
                    per.Status__c                                   = 'Submitted - Processing Enrollment Request';
                    per.Date_Submitted_gne__c                       = system.now();                 
                    per.OwnerId                                     = benefitReverifcation.LastModifiedById;
                    per.Submitted_By_gne__c                         = findNameForPER ? Userinfo.getUserId() : benefitReverifcation.LastModifiedById;
                    per.Benefits_Investigation_Prior_Auth_gne__c    = true;
                    per.BRC_Submission__c                           = benefitReverifcation.Submission_Id_Number_gne__c;
                    per.PER_Source_gne__c                           = 'Benefits Reverification';
                    per.Next_Treatment_Date__c                      = benefitReverifcation.Anticipated_Date_of_Treatment__c;
                    per.Primary_Insurance_Card_Attached__c          = 'No';
                    per.Secondary_Insurance_Card_Attached__c        = 'No';
                    per.GNE_CM_MPS_RegId__c                         = benefitReverifcation.MPS_Registration_gne__c;
                    per.GNE_CM_MPSLocationId__c                     = benefitReverifcation.MPS_Location_gne__c;
                    per.Co_pay_Assistance_gne__c                    = benefitReverifcation.Co_pay_Assistance_gne__c;
                    System.debug('medicalHistoryMap.get(benefitReverifcation.Medical_History__c)===='+medicalHistoryMap.get(benefitReverifcation.Medical_History__c));
                    System.debug('medicalHistoryMap===='+medicalHistoryMap);

                    GNE_CM_MPS_Utils.setNewDiagnosisCodesOnPER(per, medicalHistoryMap.get(benefitReverifcation.Medical_History__c));
                    //PFS-1691 Rama. The Treatment Location name should be MPS Registration's Practice Name
                    if(benefitReverifcation.Practice_Name_gne__c != null) {
                       per.Treating_Location_Name_gne__c               = benefitReverifcation.Practice_Name_gne__c.unescapeHtml4();   
                    }                 
                    if(qID != null )
                    {                
                        per.ownerid = qID[0].QueueId;
                    }
                    persToUpdate.add(per);
                    benefitReverifcation.PER_id_gne__c = per.id;
                    benefitReverifcation.Status_gne__c = 'Processed';
                    benefitReveficationArchive.PER_id_gne__c = per.Id;
                }
            }
    
            if (!benefitReverificationToArchive.isEmpty()) 
            {  
                try 
                {
                    List<Error_Log_gne__c> errorsLogsToInsert = new List<Error_Log_gne__c>();
                
                    List<Database.SaveResult> brArchiveInsertResults = Database.insert(benefitReverificationToArchive,false);
                    List<Database.SaveResult> brUpdateResults = Database.update(brList,false);
                    List<Database.SaveResult> perUpdateResults = new List<Database.SaveResult>();
                    if (persToUpdate.size() > 0) 
                    {
                        perUpdateResults = Database.update(persToUpdate,false);
                        if(findNameForPER) 
                        {
                            Map<Id, Patient_Enrollment_Request_gne__c> pers = new Map<Id, Patient_Enrollment_Request_gne__c>([SELECT Id, Name FROM Patient_Enrollment_Request_gne__c WHERE id in :persToUpdate]);
                            for (GNE_CM_MPS_BRC_RituxanRA__c benefitReverifcation : brList) 
                            {
                                 if(pers.get(benefitReverifcation.PER_id_gne__c) != null)
                                 {
                                    benefitReverifcation.PER_id_gne__r =  pers.get(benefitReverifcation.PER_id_gne__c);
                                 }
                            }
                        }
                    }

                    GNE_CM_MPS_Utils.createAndLogErrors(brUpdateResults, 'Error in updating Benefit Reverification record with ID: {sr}', new List<String>(), 'GNE_CM_MPS_BRC_RituxanRA__c', 'GNE_CM_MPS_Utils.createPERandBRarchive',brList);
                    GNE_CM_MPS_Utils.createAndLogErrors(perUpdateResults, 'Error in updating Benefit Reverification PER with ID: {sr}', new List<String>(), 'Patient_Enrollment_Request_gne__c', 'GNE_CM_MPS_Utils.createPERandBRarchive',persToUpdate);
                } 
                catch(Exception e) 
                {
                    GNE_CM_MPS_Utils.createAndLogErrors(new List<Database.SaveResult>(), 'Exception in inserting BR Archive records or updating BR records and exception message is: {0}', new List<String>{GlobalUtils.getExceptionDescription(e)}, 'BRC_RituxanRA_Archive__c', 'GNE_CM_MPS_Utils.createPERandBRarchive',null);
                }           
            }
    }//end createPERandBRarchive()
    
    public static void setNewDiagnosisCodesOnPER(Patient_Enrollment_Request_gne__c per, Medical_History_gne__c mh)
    {
        System.debug('mh---'+mh);
        System.debug('per---'+per);
        if(mh.Drug_gne__c=='Actemra' || mh.product_gne__c=='Rituxan RA')
        {
            per.Diagnosis_Dx_gne__c = removeSpecialCharacters(mh.ICD9_Code_1_gne__r.Name); 
            per.Diagnosis_Dx_Other_gne__c ='';
            per.Diagnosis_Dx_2_gne__c = removeSpecialCharacters(mh.ICD9_Code_2_gne__r.Name);
            per.Diagnosis_Dx_Other_2_gne__c = '';
            per.Diagnosis_Dx_3_gne__c = removeSpecialCharacters(mh.ICD9_Code_3_gne__r.Name);
            per.Diagnosis_Dx_Other_3_gne__c='';
        }
        else if(mh.Drug_gne__c == 'Lucentis')
        {
            /*if(String.isBlank(mh.Eye_Being_Treated_gne__c) || mh.Eye_Being_Treated_gne__c=='Both')
            {
                if(String.isNotBlank(mh.Eye_Being_Treated_gne__c))
                {
                    per.Eyes_Being_Treated_Right_gne__c = 'Both';    
                }
                
                per.Primary_Left_gne__c = removeSpecialCharacters(mh.ICD9_Code_1_gne__r.Name); 
                per.Secondary_Left_gne__c = removeSpecialCharacters(mh.ICD9_Code_2_gne__r.Name);
                per.Primary_Right_gne__c = removeSpecialCharacters(mh.ICD9_Code_1_gne__r.Name); 
                per.Secondary_Right_gne__c = removeSpecialCharacters(mh.ICD9_Code_2_gne__r.Name);
                per.Other_Please_Specify_ICD_9_gne__c='';
                per.Other_Please_Specify_ICD_9_Eye_2_gne__c='';
            }else if(mh.Eye_Being_Treated_gne__c=='Left')
            {
                per.Eyes_Being_Treated_Right_gne__c = 'Left';
                per.Primary_Left_gne__c = removeSpecialCharacters(mh.ICD9_Code_1_gne__r.Name); 
                per.Secondary_Left_gne__c = removeSpecialCharacters(mh.ICD9_Code_2_gne__r.Name);
                per.Other_Please_Specify_ICD_9_gne__c='';
            }else if(mh.Eye_Being_Treated_gne__c=='Right')
            {
                per.Eyes_Being_Treated_Right_gne__c = 'Right';
                per.Primary_Right_gne__c = removeSpecialCharacters(mh.ICD9_Code_1_gne__r.Name); 
                per.Secondary_Right_gne__c = removeSpecialCharacters(mh.ICD9_Code_2_gne__r.Name);
                per.Other_Please_Specify_ICD_9_Eye_2_gne__c='';
            }*/
			
			per.LUC_Dx1_gne__c = mh.ICD9_Code_1_gne__r.Name;
			per.LUC_Dx2_gne__c = mh.ICD9_Code_2_gne__r.Name;
			per.LUC_Dx3_gne__c = null;
			per.LUC_Dx4_gne__c = null;
			per.LUC_Dx1_Other_gne__c = '';
			per.LUC_Dx2_Other_gne__c = '';
			per.LUC_Dx3_Other_gne__c = '';
			per.LUC_Dx4_Other_gne__c = '';           
           
        }
    }

    public static String removeSpecialCharacters(String name)
    {
        String cleanString;
        if(String.isNotBlank(name))
        {
           cleanString= name.replaceAll('- ', '');
        }
        return cleanString;
    }


    public static String getDispenseBRAF(String StrDispense) 
    {      
        if (StrDispense == '1 Month') 
        {
            StrDispense = '28';
        }
        else if (StrDispense == '2 Month')
        {
            StrDispense = '56';            
        }   
        else if (StrDispense == '3 Month')
        { 
            StrDispense = '84';
        }         
        return StrDispense; 
    }
    
    public static Double getDispenseAlecensaDouble(String strDispense) 
     {  
        if (strDispense == null || strDispense == '')
        {
            return 0.0;    
        }
        if (strDispense == '1 Month')
        {
            strDispense = '30';
        }
        else if (strDispense == '2 Month')
        {   
            strDispense = '60';
        }
        else if (strDispense == '3 Month')     
        {
            strDispense = '90';
        }
        return Double.valueOf(strDispense.split(' ')[0]);
     }
     
     
     public static Double getDispenseDouble(String strDispense) 
     {  
        if (strDispense == null || strDispense == '')
        {
            return 0.0;    
        }
        if (strDispense == '1 Month')
        {
            strDispense = '28';
        }
        else if (strDispense == '2 Month')
        {   
            strDispense = '56';
        }
        else if (strDispense == '3 Month')     
        {
            strDispense = '84';
        }
        return Double.valueOf(strDispense.split(' ')[0]);
     }
     
     public static Double getDispenseMonthsDouble(String strDispense) 
     {  
        if (strDispense == null || strDispense == '')
        {
            return 0.0;    
        }
        if (strDispense == '1 Month')
        {
            strDispense = '1';
        }
        else if (strDispense == '2 Month')
        {   
            strDispense = '2';
        }
        else if (strDispense == '3 Month')     
        {
            strDispense = '3';
        }
        return Double.valueOf(strDispense.split(' ')[0]);
     }
     
     public static Double getDosageDouble(String strDosage) 
     {  
        if (strDosage == null || strDosage == '')
        {
            return 0.0;    
        }
        return Double.valueOf(strDosage.split(' ')[0]);
     }

    private static List<String> lstDisabledProducts=null;

    /* Xeloda Sunset, Method to check if product is disabled in GNE_CM_Disabled_Products__c custom settings managed list of values */
    public static Boolean isDisabledProduct(String productName)
    {
        Boolean flag = false;
        
        if (lstDisabledProducts==null) 
        {
            String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
            lstDisabledProducts = GNE_CM_CustomSettings_Utils.getValues(GNE_CM_Disabled_Products__c.getall().values(), env);
        }
        
        if(productName != null)
        {
            for(String value : lstDisabledProducts)
            {
                if(productName.touppercase() == value.touppercase())
                {
                    flag = true;
                    break;
                }
            }
        }   
        return flag;
    }
    
    /* Xeloda Sunset, Method to check if list of products e.g. from multiselect has disabled product */
    public static Boolean isDisabledProduct(List<String> productsList)
    {
        Boolean flag = false;
        
        if(productsList != null && productsList.size() > 0)
        {
            for(String product : productsList)
            {
                flag = isDisabledProduct(product);
                if(flag)
                {
                    break;
                }
            }   
        }
        return flag;
    }

    private static List<String> lstMPSDisabledProducts=null;

   /* use this if a product is available in CM but is to be disabled in MPS */
    public static Boolean isMPSDisabledProduct(String productName)
    {
        Boolean flag = false;
        
        if (lstMPSDisabledProducts==null) 
        {
            String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
            lstMPSDisabledProducts = GNE_CM_CustomSettings_Utils.getValues(GNE_MPS_Disabled_Products__c.getall().values(), env);
        }

        if(productName != null)
        {
            for(String value : lstMPSDisabledProducts)
            {
                if(productName.touppercase() == value.touppercase())
                {
                    flag = true;
                    break;
                }
            }
        }   
        return flag;
    }

    public static Boolean showProductInMPS(String productName) {
            Boolean isCotellicDisabled = GNE_CM_MPS_Utils.isMPSDisabledProduct(productName);
            return !isCotellicDisabled; //If product is not disabled the show it in MPS        
    }
    
    /* Method to check if product is not allowed to create MH records or not, product is maintain in GNE_CM_No_MH_Products__c custom settings */
    public static Boolean isNonMHProduct(String productName)
    {
        Boolean flag = false;
        
        if(productName != null)
        {
            String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
            for(String value : GNE_CM_CustomSettings_Utils.getValues(GNE_CM_No_MH_Products__c.getall().values(), env))
            {
                if(productName.touppercase() == value.touppercase())
                {
                    flag = true;
                    break;
                }
            }
        }   
        return flag;
    }
    /* Method to check if list of products e.g. from multiselect can create MH or not */
    public static Boolean isNonMHProduct(List<String> productsList)
    {
        Boolean flag = false;
        
        if(productsList != null && productsList.size() > 0)
        {
            for(String product : productsList)
            {
                flag = isNonMHProduct(product);
                if(flag)
                {
                    break;
                }
            }   
        }
        return flag;
    }

    public static Date getNextBusinessDay(Date dte)
    {
        Date dteRet = null;

        if (dte!=null)
        {
            Date weekStart = dte.toStartofWeek();
            integer dayOfWeek=weekStart.daysBetween(dte);

            dteRet = dte.addDays(dayOfWeek==0 ? 1 : (dayOfWeek==6 ? 2 : 0));
        }
        return dteRet;
    }
}