public without sharing class AGS_ST_Utils {
    public static final List<String> MANAGER_PROFILES = new List<String>{'GNE-AGS-CCO-Manager','System Administrator','GNE-SYS-Support'};
    
    public static Boolean hasValue(String s) {
        return String.isNotBlank(s);
    }
    
    public static Boolean isUserLoggedIn() {
        return UserInfo.getProfileId() == AGS_ST_DbUtils.findProfileIdByName('GNE-CM-IHCP-PROFILE');
    }
    
    public static Boolean validateEmail(String email) {
        if (email == null) {
            return false;
        }
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);
        return emailMatcher.matches();
    }
    
    public static Boolean isLastName(String s) {
        if (s == null) {
            return false;
        }
        String str = s.trim();
        String alphaRegex = '[a-zA-Z- \']+';
        Pattern alphaPattern = Pattern.compile(alphaRegex);
        Matcher alphaMatcher = alphaPattern.matcher(str);
        return alphaMatcher.matches();
    }
    
    public static Boolean isAlpha(String s) {
        if (s == null) {
            return false;
        }
        String str = s.trim();
        String alphaRegex = '[a-zA-Z]+';
        Pattern alphaPattern = Pattern.compile(alphaRegex);
        Matcher alphaMatcher = alphaPattern.matcher(str);
        return alphaMatcher.matches();
    }
    
    public static Boolean isAlphaWithSpaces(String s) {
        if (s == null) {
            return false;
        }
        String str = s.trim();
        String alphaRegex = '[a-zA-Z ]+';
        Pattern alphaPattern = Pattern.compile(alphaRegex);
        Matcher alphaMatcher = alphaPattern.matcher(str);
        return alphaMatcher.matches();
    }
    
    public static Boolean isCCOManager(Id profileId) {
        return profileId != null && [SELECT Id FROM Profile where id = :profileId and Name in :MANAGER_PROFILES].size() == 1;
    }
    
    public static Boolean isNumber(String s) {
        if (s == null) {
            return false;
        }
        String str = s.trim();
        String alphaRegex = '[0-9]+';
        Pattern alphaPattern = Pattern.compile(alphaRegex);
        Matcher alphaMatcher = alphaPattern.matcher(str);
        return alphaMatcher.matches();
    }
    
    public static String getSubstring(String s, Integer length) {
        return s == null ? null : s.length()>length ? s.substring(0, length) : s;
    }
    
    public static String dateToString(Date d) {
        return d == null ? '' : DateTime.newInstance(d, null).format('yyyy-MM-dd');
    }
    
    public static String dateToString(Date d, String format) {
        return format == null ? dateToString(d) : d == null ? '' : DateTime.newInstance(d.year(), d.month(), d.day()).format(format);
    }
    
    /* Method creates Date object from string "MM/DD/YYYY" */
    public static Date stringToDate(String s) {
        Integer slash1pos, slash2pos;
        Integer y, m, d;
        String yyyymmdd;
        try {
            slash1pos = s.indexof('/');
            slash2pos = s.lastindexof('/');
            // format check
            m = Integer.valueOf(s.substring(0, slash1pos++));
            d = Integer.valueOf(s.substring(slash1pos, slash2pos++));
            y = Integer.valueOf(s.substring(slash2pos));
            // data value check
            yyyymmdd = String.valueOf(y) + '-' + String.valueOf(m) + '-' + String.valueOf(d);
            return Date.valueOf(yyyymmdd);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
        }
        return null;
    }
    
    public static String getSunshineOrgWideAddressID() {
        if (AGS_ST_Utils.getDefaultCustomSettings() != null && AGS_ST_Utils.getDefaultCustomSettings().OrgWideAddressName_gne__c != null) {
            String oweaName = AGS_ST_Utils.getDefaultCustomSettings().OrgWideAddressName_gne__c;
            OrgWideEmailAddress[] oweas = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: oweaName LIMIT 1];
            return oweas.isEmpty() ? null : oweas[0].Id;
        }
        return null;
    }
    
    public static String getSunshineOrgWideAddress() {
        if (AGS_ST_Utils.getDefaultCustomSettings() != null && AGS_ST_Utils.getDefaultCustomSettings().OrgWideAddressName_gne__c != null) {
            String oweaName = AGS_ST_Utils.getDefaultCustomSettings().OrgWideAddressName_gne__c;
            OrgWideEmailAddress[] oweas = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName =: oweaName LIMIT 1];
            return oweas.isEmpty() ? null : oweas[0].Address;
        }
        return null;
    }
    
    @future
    public static void logRegistrationError(String className, String content, String errorMessage, String methodName, String NPI, String StateLicense, String StateLicenseState) {
        String content2 = content;
        if (content != null && content.length() > 254) {
            content2 = content.substring(254);
        }
        AGS_ST_SFDC_Registration_Error_Log_gne__c err = new AGS_ST_SFDC_Registration_Error_Log_gne__c();
        err.Class_gne__c = className;
        err.Content_gne__c = content2;
        err.Error_Message_gne__c = errorMessage;
        err.Method_gne__c = methodName;
        //err.MPS_User_gne__c = mpsUserId;
        //err.Proxy_gne__c = proxyId;
        err.NPI_gne__c = NPI;
        err.State_License_gne__c = StateLicense;
        err.State_License_State_gne__c = StateLicenseState;
        insert err;
    }
    
    public static void forwardPageParam(PageReference pr, String paramName) {
        String paramValue = ApexPages.currentPage().getParameters().get(paramName);
        if (paramValue != null && paramValue != '') {
            pr.getParameters().put(paramName, paramValue);
        }
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description  Method for getting Picklist BY Field Description
    * @param Schema.DescribeFieldResult fieldResult
    * @return List<SelectOption>
    */
    public static List<SelectOption> getPickListValues(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.Picklistentry p : fieldResult.getPicklistValues()) {
            options.add(new SelectOption(p.getValue(), p.getValue()));
        }
        return options;
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description  Method for getting Picklist BY Field Description with except of values from List in param
    * @param Schema.DescribeFieldResult fieldResult
    * @param List<String> exceptList
    * @return List<SelectOption>
    */
    public static List<SelectOption> getPickListValuesWithExcept(Schema.DescribeFieldResult fieldResult, List<String> exceptList) {
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.Picklistentry p : fieldResult.getPicklistValues()) {
            Boolean isExcept = false;
            for (String except : exceptList) {
                if (except.equals(p.getValue())) {
                    isExcept = true;
                    break;
                }
            }
            if (!isExcept) {
                options.add(new SelectOption(p.getValue(), p.getValue()));
            }
        }
        return options;
    }
    
    /** @date 9/3/2012
    * @Author Michal Zaganczyk
    * @description Only detail type products not owned by GNE-SFA-Canada-Queue are part of display list. Product name needs
    * to be truncated till first '-' and the list should not contain duplicates.
    * @return List<SelectOption>
    */
    public static List<SelectOption> getDrugNames() {
        Set<String> tmp = new Set<String>();
        for (Product_vod__c product : [SELECT Name FROM Product_vod__c
                                            WHERE (Product_vod__c.Product_Type_vod__c = 'Detail')
                                            AND ((Product_vod__c.Owner.Type <> 'Queue') OR ((Product_vod__c.Owner.Type = 'Queue')
                                            AND (Product_vod__c.Owner.Name <> 'GNE-SFA-Canada-Queue')))]) {
            tmp.add(product.Name.replaceAll('-.*', '').trim());
        }
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-NONE-'));
        for (String s : tmp) {
            result.add(new SelectOption(s, s));
        }
        result.sort();
        return result;
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for filling Dispute List and Dispute Management Objects
    * @param AGS_ST_Dispute_List_gne__c dlObj
    * @param AGS_ST_DisputeManagement_gne__c dmObj,
    * @param String dispAmount
    * @param Decimal spendAmount
    * @param String dispBrand
    * @param String spendBrand
    * @param String dispForm
    * @param String spendForm
    * @param String dispNature
    * @param String spendNature
    */
    public static void fillDLAndDMByStdValues(AGS_ST_Dispute_List_gne__c dlObj, AGS_ST_DisputeManagement_gne__c dmObj, String dispAmount, Decimal spendAmount, String dispBrand, String spendBrand, String dispForm, String spendForm, String dispNature, String spendNature) {
        if (dispAmount != '' && dispAmount != null) {
            dlObj.Amount_gne__c = Decimal.valueOf(dispAmount);
            dmObj.Amount_gne__c = Decimal.valueOf(dispAmount);
            dlObj.isAmountDisputed_gne__c = true;
        } else {
            dlObj.Amount_gne__c = spendAmount;
            dmObj.Amount_gne__c = spendAmount;
        }
        if (dispBrand != '' && dispBrand != null) {
            dlObj.Drug_Name_gne__c  = dispBrand;
            dmObj.Drug_Name_gne__c  = dispBrand;
            dlObj.isBrandDisputed_gne__c = true;
        } else {
            dlObj.Drug_Name_gne__c  = spendBrand;
            dmObj.Drug_Name_gne__c  = spendBrand;
        }
        if (dispForm != '' && dispForm != null) {
            dlObj.Form_Of_Payment_gne__c  = dispForm;
            dmObj.Form_Of_Payment_gne__c  = dispForm;
            dlObj.isFormDisputed_gne__c = true;
        } else {
            dlObj.Form_Of_Payment_gne__c  = spendForm;
            dmObj.Form_Of_Payment_gne__c  = spendForm;
        }
        if (dispNature != '' && dispNature != null) {
            dlObj.Nature_Of_Payment_gne__c  = dispNature;
            dmObj.Nature_Of_Payment_gne__c  = dispNature;
            dlObj.isNatureDisputed_gne__c = true;
        } else {
            dlObj.Nature_Of_Payment_gne__c = spendNature;
            dmObj.Nature_Of_Payment_gne__c = spendNature;
        }
    }
    
    public static String getPartyData(AGS_Spend_Expense_Transaction_gne__c spend, Boolean primaryRecipient, String fieldName) {
        Boolean availableRecipientData = false;
        if (primaryRecipient) {
            availableRecipientData = (spend.Primary_Recipient_gne__r != null) ? true : false;
        }
        if (!primaryRecipient) {
            availableRecipientData = (spend.Secondary_Recipient_gne__r != null) ? true : false;
        }
        if ('RecipientObject'.equals(fieldName)) {
            return (availableRecipientData ? 'YES' : 'NO');
        }
        if ('Address_Line1'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Address_Line_1_gne__c : spend.Secondary_Recipient_gne__r.Address_Line_1_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_ADDRESS_LINE1_gne__c : spend.PTY2_ADDRESS_LINE1_gne__c);
            }
        }
        if ('Address_Line2'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Address_line_2_gne__c : spend.Secondary_Recipient_gne__r.Address_line_2_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_ADDRESS_LINE2_gne__c : spend.PTY2_ADDRESS_LINE2_gne__c);
            }
        }
        if ('City'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.City_gne__c : spend.Secondary_Recipient_gne__r.City_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_CITY_gne__c : spend.PTY2_CITY_gne__c);
            }
        }
        if ('Country'.equals(fieldName)) {
            if (availableRecipientData) {
                return 'USA';
            } else {
                return ((primaryRecipient) ? spend.PTY1_COUNTRY_gne__c : spend.PTY2_COUNTRY_gne__c);
            }
        }
        if ('State'.equals(fieldName)) {
            if (availableRecipientData) {
                String stateVal = ((primaryRecipient) ? spend.Primary_Recipient_gne__r.State_gne__c : spend.Secondary_Recipient_gne__r.State_gne__c);
                if (stateVal != null && createInverseMap().get(stateVal.toLowerCase()) != null) {
                    stateVal = createInverseMap().get(stateVal.toLowerCase());
                }
                return stateVal;
            } else {
                return ((primaryRecipient) ? spend.PTY1_STATE_gne__c : spend.PTY2_STATE_gne__c);
            }
        }
        if ('StateFull'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.State_gne__c : spend.Secondary_Recipient_gne__r.State_gne__c);
            } else {
                return null;
            }
        }
        if ('ZIP'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Zip_gne__c : spend.Secondary_Recipient_gne__r.Zip_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_ZIP_gne__c : spend.PTY2_ZIP_gne__c);
            }
        }
        if ('FirstName'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.First_Name_gne__c : spend.Secondary_Recipient_gne__r.First_Name_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_FirstName_gne__c : spend.PTY2_FirstName_gne__c);
            }
        }
        if ('LastName'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Last_Name_gne__c : spend.Secondary_Recipient_gne__r.Last_Name_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_LastName_gne__c : spend.PTY2_LastName_gne__c);
            }
        }
        if ('LegalName'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Institution_Name_gne__c : spend.Secondary_Recipient_gne__r.Institution_Name_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_Name_gne__c : spend.PTY2_Name_gne__c);
            }
        }
        if ('FullName'.equals(fieldName)) {
            if (availableRecipientData) {
                if (primaryRecipient) {
                    if (!String.isBlank(spend.Primary_Recipient_gne__r.Institution_Name_gne__c)) {
                        return spend.Primary_Recipient_gne__r.Institution_Name_gne__c;
                    } else {
                        return spend.Primary_Recipient_gne__r.First_Name_gne__c + ' ' + spend.Primary_Recipient_gne__r.Last_Name_gne__c;
                    }
                } else {
                    if (!String.isBlank(spend.Secondary_Recipient_gne__r.Institution_Name_gne__c)) {
                        return spend.Secondary_Recipient_gne__r.Institution_Name_gne__c;
                    } else {
                        return spend.Secondary_Recipient_gne__r.First_Name_gne__c + ' ' + spend.Secondary_Recipient_gne__r.Last_Name_gne__c;
                    }
                }
            } else {
                return ((primaryRecipient) ? spend.PTY1_Name_gne__c : spend.PTY2_Name_gne__c);
            }
        }
        if ('NPI'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.NPI_gne__c : spend.Secondary_Recipient_gne__r.NPI_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_NPI_gne__c : spend.PTY2_NPI_gne__c);
            }
        }
        if ('TIN'.equals(fieldName)) {
//            if (availableRecipientData) {
//                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Tax_Id_gne__c : spend.Secondary_Recipient_gne__r.Tax_Id_gne__c);
//            } else {
//                return ((primaryRecipient) ? spend.PTY1_TIN_gne__c : spend.PTY2_TIN_gne__c);
//            }
            //AGGSTRIM-117
            return ((primaryRecipient) ? spend.PTY1_TIN_gne__c : spend.PTY2_TIN_gne__c);
        }
        if ('Specialty'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Specialty_gne__c : spend.Secondary_Recipient_gne__r.Specialty_gne__c);
            } else {
                return ((primaryRecipient) ? spend.PTY1_SPECIALITY_gne__c : spend.PTY2_SPECIALITY_gne__c);
            }
        }
        if ('MDMID'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Name : spend.Secondary_Recipient_gne__r.Name);
            } else {
                return null;
            }
        }
        if ('Credential'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Credential_gne__c : spend.Secondary_Recipient_gne__r.Credential_gne__c);
            } else {
                return null;
            }
        }
        if ('Specialty2'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Specialty2_gne__c : spend.Secondary_Recipient_gne__r.Specialty2_gne__c);
            } else {
                return null;
            }
        }
        if ('RchCategory'.equals(fieldName)) {
            if (availableRecipientData) {
                return ((primaryRecipient) ? spend.Primary_Recipient_gne__r.RCH_Category_gne__c : spend.Secondary_Recipient_gne__r.RCH_Category_gne__c);
            } else {
                return null;
            }
        }
        if ('SrcAtndKey'.equals(fieldName)) {
            return ((primaryRecipient) ? spend.PTY1_SRC_ATND_KEY_gne__c : spend.PTY2_SRC_ATND_KEY_gne__c);
        }
        if ('LicenseNumber'.equals(fieldName)) {
            if (availableRecipientData) {
                return null;
            } else {
                return ((primaryRecipient) ? spend.PTY1_LIC_NUM_gne__c : spend.PTY2_LIC_NUM_gne__c);
            }
        }
        if ('LicenseState'.equals(fieldName)) {
            if (availableRecipientData) {
                return null;
            } else {
                return ((primaryRecipient) ? spend.PTY1_LIC_ST_CD_gne__c : spend.PTY2_LIC_ST_CD_gne__c);
            }
        }
        if ('Type'.equals(fieldName)) {
            if (availableRecipientData) {
                String orgName = ((primaryRecipient) ? spend.Primary_Recipient_gne__r.Institution_Name_gne__c : spend.Secondary_Recipient_gne__r.Institution_Name_gne__c);
                if (!String.isBlank(orgName)) {
                    return 'ORGANIZATION';
                } else {
                    return 'INDIVIDUAL';
                }
            } else {
                return ((primaryRecipient) ? spend.PTY1_TYPE_gne__c : spend.PTY2_TYPE_gne__c);
            }
        }
        return null;
    }
    
    public static AGS_Recipient_License_State_gne__c getRecipientLicenseState(String recipientSfdcId, String recipientState, Boolean convertToCode) {
        AGS_Recipient_License_State_gne__c rls;
        List<AGS_Recipient_License_State_gne__c> licenseList = [SELECT State_License_Number_gne__c, License_State_gne__c FROM AGS_Recipient_License_State_gne__c WHERE AGS_Recipient_MDM_ID_gne__c = :recipientSfdcId ORDER BY License_State_gne__c ASC];
        if (licenseList.size() > 0) {
            rls = licenseList.get(0);
            for (AGS_Recipient_License_State_gne__c license : licenseList) {
                if (license.License_State_gne__c != null && license.License_State_gne__c.equals(recipientState)) {
                    rls = license;
                    break;
                }
            }
            if (convertToCode && rls.License_State_gne__c != null && VDST_Utils.getInverseStatesMap().get(rls.License_State_gne__c.toLowerCase()) != null) {
                rls.License_State_gne__c = VDST_Utils.getInverseStatesMap().get(rls.License_State_gne__c.toLowerCase());
            }
            return rls;
        }
        return null;
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for creating Spend Expense Transaction query only with Spend Id's
    * @param String firstName
    * @param String lastName
    * @param Decimal amountFrom
    * @param Decimal amountTo
    * @param AGS_ST_DisputeManagement_gne__c paymentDateFrom
    * @param AGS_ST_DisputeManagement_gne__c paymentDateTo
    * @param String eventCity
    * @param String mdmId
    * @param String npi
    * @param String spendName
    * @return String
    */
    public static String getSpendExpenseTransactionIdsQueryByParam(String firstName, String lastName, Decimal amountFrom, Decimal amountTo, AGS_ST_DisputeManagement_gne__c paymentDateFrom, AGS_ST_DisputeManagement_gne__c paymentDateTo, String eventCity, String mdmId, String npi, String spendName) {
        List<String> andStatementList = new List<String>();
        // Participant
        List<String> orParty1StatementList = new List<String>();
        List<String> orParty2StatementList = new List<String>();
        if (!firstName.equals('')) {
            orParty1StatementList.add('Party1_FirstName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\'');
            orParty2StatementList.add('Party2_FirstName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\'');
        }
        if (!lastName.equals('')) {
            orParty1StatementList.add('Party1_LastName_gne__c LIKE \'' + String.escapeSingleQuotes(lastName.trim()).replace('*', '%') + '\'');
            orParty2StatementList.add('Party2_LastName_gne__c LIKE \'' + String.escapeSingleQuotes(lastName.trim()).replace('*', '%') + '\'');
        }
        if (!mdmId.equals('')) {
            orParty1StatementList.add('Primary_Recipient_MDM_ID_gne__c = \'' + String.escapeSingleQuotes(mdmId.trim()) + '\'');
            orParty2StatementList.add('Secondary_Recipient_MDM_ID_gne__c = \'' + String.escapeSingleQuotes(mdmId.trim()) + '\'');
        }
        if (!npi.equals('')) {
            orParty1StatementList.add('Party1_NPI_gne__c = \'' + String.escapeSingleQuotes(npi.trim()) + '\'');
            orParty2StatementList.add('Party2_NPI_gne__c = \'' + String.escapeSingleQuotes(npi.trim()) + '\'');
        }
        if (orParty1StatementList.size() > 1) {
            andStatementList.add('( (' + String.join(orParty1StatementList, ' AND ') + ') OR (' + String.join(orParty2StatementList, ' AND ') + ') )');
        } else if (orParty1StatementList.size() > 0) {
            andStatementList.add('(' + orParty1StatementList.get(0) + ' OR ' + orParty2StatementList.get(0) + ')');
        }
        // Event + Transaction
        if (!spendName.equals('')) {
            andStatementList.add('Name = \'' + String.escapeSingleQuotes(spendName.trim()) + '\'');
        }
        if (amountFrom != null) {
            andStatementList.add('Allocated_Transaction_Amount_gne__c >= ' + amountFrom);
        }
        if (amountTo != null) {
            andStatementList.add('Allocated_Transaction_Amount_gne__c <= ' + amountTo);
        }
        if (paymentDateFrom != null && paymentDateFrom.Payment_Date_gne__c != null) {
            andStatementList.add('Event_Date_gne__c >= ' + Datetime.newInstance(paymentDateFrom.Payment_Date_gne__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'));
        }
        if (paymentDateTo != null && paymentDateTo.Payment_Date_gne__c != null) {
            andStatementList.add('Event_Date_gne__c <= ' + Datetime.newInstance(paymentDateTo.Payment_Date_gne__c, Time.newInstance(23, 59, 59, 0)).format('yyyy-MM-dd'));
        }
        if (!eventCity.equals('')) {
            andStatementList.add('Event_City_gne__c = \'' + String.escapeSingleQuotes(eventCity.trim()) + '\'');
        }
        andStatementList.add('Report_Code_gne__c = \'XC_MON\'');
        String whereStatement = '';
        for (String andStat : andStatementList) {
                if (whereStatement.equals('')) {
                        whereStatement = andStat;
                } else {
                        whereStatement += ' AND ' + andStat;
                }
        }
        if (!whereStatement.equals('')) {
            whereStatement = ' WHERE ' + whereStatement;
        }
        String selectQuery = 'SELECT Id FROM AGS_Spend_Expense_Transaction_gne__c';
        if (!whereStatement.equals('')) {
            selectQuery += whereStatement;
        }
        return selectQuery;
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for limiting and offseting string query
    * @param String returnVal
    * @param Integer limitVal
    * @param Integer offsetVal
    * @return String
    */
    public static String getNewQueryWithOffsetAndLimit(String returnVal, Integer limitVal, Integer offsetVal) {
        returnVal += ' LIMIT ' + limitVal + ' OFFSET ' + offsetVal;
        return returnVal;
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for sorting sObject list
    * @param List<Sobject> items
    * @param String sortField
    * @param String order
    */
    public static void sortList(List<Sobject> items, String sortField, String orderField) {
       List<Sobject> resultList = new List<Sobject>();
        //Create a map that can be used for sorting
       Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
       for (Sobject ob : items) {
                if (objectMap.get(ob.get(sortField)) == null) {  // For non Sobject use obj.ProperyName
                    objectMap.put(ob.get(sortField), new List<Sobject>());
                }
                objectMap.get(ob.get(sortField)).add(ob);
        }
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
        for (object key : keys) {
            resultList.addAll(objectMap.get(key));
        }
        //Apply the sorted values to the source list
        items.clear();
        if (orderField.toLowerCase() == 'asc') {
            for (Sobject ob : resultList) {
                items.add(ob);
            }
        } else if (orderField.toLowerCase() == 'desc') {
            for (integer i = resultList.size()-1; i >= 0; i--) {
                items.add(resultList[i]);
            }
        }
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for getting enviroment name
    * @return String
    */
    public static String getEnvName() {
        String env ='prod';
        String userName = Userinfo.getUsername();
        if (userName != '') {
            if (userName.lastIndexOf('.') > 0) {
                env = userName.substring(userName.lastIndexOf('.') + 1, userName.length());
            }
        }
        return env;
    }
    
    public static AGS_ST_Settings_gne__c getDefaultCustomSettings() {
        MAP<String, AGS_ST_Settings_gne__c> domains = AGS_ST_Settings_gne__c.getAll();
        if (domains.size() == 1)
            return domains.values().get(0);
        else return getCustomSettingsIntExt();
    }
    
    public static AGS_ST_Settings_gne__c getCustomSettingsIntExt() {
        if (Site.getDomain() != null) {
            return getCustomSettingsInSite();
        } else {
            return getCustomSettings();
        }
    }
    
    public static AGS_ST_Settings_gne__c getCustomSettings() {
        MAP<String, AGS_ST_Settings_gne__c> domains = AGS_ST_Settings_gne__c.getAll();
        AGS_ST_Settings_gne__c cs;
        for (AGS_ST_Settings_gne__c env_domain : domains.values()) {
            if (getEnvName().equals(env_domain.Name)) {
                cs = env_domain;
            }
        }
        if (cs == null) {
            for (AGS_ST_Settings_gne__c env_domain : domains.values()) {
                if ('prod'.equals(env_domain.Name)) {
                    cs = env_domain;
                }
            }
        }
        return cs;
    }
    
    public static AGS_ST_Settings_gne__c getCustomSettingsInSite() {
        MAP<String, AGS_ST_Settings_gne__c> domains = AGS_ST_Settings_gne__c.getAll();
        for (AGS_ST_Settings_gne__c env_domain : domains.values()) {
            if (env_domain.Site_Domain_gne__c != null) {
                if (Test.isRunningTest() || env_domain.Site_Domain_gne__c.contains(Site.getDomain())) {
                    return env_domain;
                }
            }
        }
        return null;
    }
    
    // checks if given userName has sufix from custom settings
    public static String getEnvNameForUsername(String userName) {
        if (String.isBlank(userName)) {
            return '';
        }
        String userSufix = (userName.lastIndexOf('.') > 0) ? userName.substring(userName.lastIndexOf('.') + 1, userName.length()) : '';
        if (String.isBlank(userSufix)) {
            return '';
        }
        AGS_ST_Settings_gne__c envSettings;
        String sufixToRemove = '';
        if (Site.getDomain() != null) {
            // external
            AGS_ST_Settings_gne__c tmpEnvSettings = getCustomSettingsInSite();
            if (userSufix.equals(tmpEnvSettings.Name)) {
                sufixToRemove = userSufix;
            }
        } else {
            // internal
            MAP<String, AGS_ST_Settings_gne__c> domains = AGS_ST_Settings_gne__c.getAll();
            if (domains.containsKey(userSufix))
                sufixToRemove = userSufix;
        }
        return sufixToRemove;
    }
    
    public static String getDomainURL() {
        String domainURL = '';
        MAP<String, AGS_ST_Settings_gne__c> domains = AGS_ST_Settings_gne__c.getAll();
        for (AGS_ST_Settings_gne__c env_domain : domains.values()) {
            if (getEnvName().equals(env_domain.Name)) {
                domainURL = env_domain.Site_Domain_gne__c;
            }
        }
        return domainURL;
    }
    
    public static List<SelectOption> getStates() {
        final List<SelectOption> options = new List<SelectOption>{
            new SelectOption('', '--NONE--')
        };
        for (VDST_States__c state : VDST_States__c.getAll().values()) {
            options.add(new SelectOption(state.Code__c, state.Code__c));
        }
        options.sort();
        return options;
    }
    
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for getting State Names for Select List
    * @return List<SelectOption>
    */
    public static List<SelectOption> getStatesNames() {
        final List<SelectOption> options = new List<SelectOption>();
        for (String stateName : VDST_States__c.getAll().keySet()) {
            options.add(new SelectOption(stateName, stateName));
        }
        options.sort();
        return options;
    }
    
    public static void logException(String stUserId, String area ,String className, Exception e, String methodName) {
        String content = 'type: ' + e.getTypeName() + ' line:' + e.getLineNumber() + ' stack: ' + e.getStackTraceString();
        logStError(stUserId, area, className, content, e.getMessage(), methodName, 'Code');
    }
    
    public static List<SCHValues> getOptOutValues() {
        List<SCHValues> returnList = new List<SCHValues>();
        returnList.add(new SCHValues('Speaker Program', 'Speaker Program', 'Speaker Program Meal Expenses', 'In Office HCP Meal'));
        returnList.add(new SCHValues('Speaker Training', 'Speaker Training', 'Speaker Training Meal Expenses', 'In Office HCP Meal'));
        returnList.add(new SCHValues('Speaker Program', 'Speaker Program', 'Speaker Program Meal Expenses', 'In Office HCP Meal (Non-Contracted)'));
        returnList.add(new SCHValues('Speaker Program', 'Speaker Program', 'Speaker Program Meal Expenses', 'Out of Office HCP Meal'));
        returnList.add(new SCHValues('Speaker Training', 'Speaker Training', 'Speaker Training Meal Expenses', 'Out of Office HCP Meal'));
        returnList.add(new SCHValues('Speaker Program', 'Speaker Program', 'Speaker Program Meal Expenses', 'Out of Office HCP Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals with Contracted Services', 'Out of Office Individual Meal'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'In Office Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'Out of Office Individual Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'In Office Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals with Contracted Services', 'In Office Meal'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'In Office Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'Out of Office Individual Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals with Contracted Services', 'Out of Office Individual Meal'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'Out of Office Individual Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals with Contracted Services', 'Out of Office Individual Meal'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals without Contracted Services', 'In Office Meal (Non-Contracted)'));
        returnList.add(new SCHValues('HCP Meal', 'HCP Interaction', 'Meals with Contracted Services', 'Out of Office Individual Meal'));
        return returnList;
    }
    
    private static Map<String, String> createInverseMap() {
        final Map<String, String> results = new Map<String, String>();
        for (VDST_States__c state : VDST_States__c.getAll().values()) {
            results.put(state.Name.toLowerCase(), state.Code__c);
        }
        return results;
    }
    
    public static Boolean isOptOutForSpend(AGS_Spend_Expense_Transaction_gne__c trans) {
        for (SCHValues sch : getOptOutValues()) {
            if (sch.equals(trans)) {
                return true;
            }
        }
        return false;
    }
    
    @future
    public static void logStError(String stUserId, String area, String className, String content, String errorMessage, String methodName, String type) {
        AGS_ST_SFDC_Registration_Error_Log_gne__c err = new AGS_ST_SFDC_Registration_Error_Log_gne__c();
        err.AGS_ST_User_gne__c = stUserId;
        err.Area_gne__c = area;
        err.Class_gne__c = className;
        err.Error_Content_gne__c= content;
        err.Error_Message_gne__c = errorMessage;
        err.Method_gne__c = methodName;
        err.Type_gne__c = type;
        insert err;
    }
    
    @future
    public static void logStErrorByUserId(String usrId, String area, String className, String content, String errorMessage, String methodName, String type) {
        AGS_ST_User_gne__c stUsr = AGS_ST_DbUtils.findAgsStUserByUserId(usrId);
        AGS_ST_SFDC_Registration_Error_Log_gne__c err = new AGS_ST_SFDC_Registration_Error_Log_gne__c();
        err.AGS_ST_User_gne__c = stUsr.id;
        err.Area_gne__c = area;
        err.Class_gne__c = className;
        err.Error_Content_gne__c= content;
        err.Error_Message_gne__c = errorMessage;
        err.Method_gne__c = methodName;
        err.Type_gne__c = type;
        insert err;
    }
    
    public static void logStErrorByUserIdNoFuture(String usrId, String area, String className, String content, String errorMessage, String methodName, String type) {
        AGS_ST_User_gne__c stUsr = AGS_ST_DbUtils.findAgsStUserByUserId(usrId);
        AGS_ST_SFDC_Registration_Error_Log_gne__c err = new AGS_ST_SFDC_Registration_Error_Log_gne__c();
        err.AGS_ST_User_gne__c = stUsr.id;
        err.Area_gne__c = area;
        err.Class_gne__c = className;
        err.Error_Content_gne__c= content;
        err.Error_Message_gne__c = errorMessage;
        err.Method_gne__c = methodName;
        err.Type_gne__c = type;
        insert err;
    }
    
    public class SCHValues{
        public String SCHActivity;
        public String SCHCategory;
        public String SCHExpense;
        public String SCHSpend;
        
        public SCHValues(String cat, String act, String spd, String exp) {
            this.SCHActivity = act;
            this.SCHCategory = cat;
            this.SCHExpense = exp;
            this.SCHSpend = spd;
        }
        
        public Boolean equals(AGS_Spend_Expense_Transaction_gne__c trans) {
            return this.SCHActivity.equalsIgnoreCase(trans.SCH_Activity_gne__c) &&
            this.SCHCategory.equalsIgnoreCase(trans.SCh_Category_gne__c) &&
            this.SCHExpense.equalsIgnoreCase(trans.SCH_Expense__c) &&
            this.SCHSpend.equalsIgnoreCase(trans.SCH_Spend_gne__c);
        }
    }
}