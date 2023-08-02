/** @date 1/15/2014
* @Author Paweł Sprysak
* @description Suplement Data Helper
*/
global without sharing class VDST_SuplementData {
    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Get Suplemented Transaction by Id and Type
    * @param String transId
    * @param String transType
    * @return SuplementedTransaction
    */
    public static SuplementedTransaction getSuplementTransaction(String transId, String transType) {
        SuplementedTransaction suplementPayment = new SuplementedTransaction();
        if(String.isBlank(transId)) {
        	suplementPayment.status = false;
            suplementPayment.error_message = 'Transaction ID is empty.';
            return suplementPayment;              
        }
        
        String tridSOSLId = transId.substring(0, transId.length() - 1) + '*';
        String tridLikeId = transId + '%';
        List<List<SObject>> searchList;
        if('RSCH'.equals(transType))
            searchList = [FIND :tridSOSLId IN ALL FIELDS RETURNING AGS_Spend_Expense_Transaction_gne__c (id,Source_Transaction_ID_gne__c,REPORT_CODE_GNE__C WHERE Source_Transaction_ID_gne__c like :tridLikeId and REPORT_CODE_GNE__C = 'XC_MON' and LogicalDeleteFlag_gne__c=false and (Research_Pymt_Typ_Cd_gne__c = 'CLINICAL' OR Research_Pymt_Typ_Cd_gne__c = 'PRECLINICAL'))];
        else if('INDVSPND'.equals(transType))
            searchList = [FIND :tridSOSLId IN ALL FIELDS RETURNING AGS_Spend_Expense_Transaction_gne__c (id,Source_Transaction_ID_gne__c,REPORT_CODE_GNE__C WHERE Source_Transaction_ID_gne__c like :tridLikeId and REPORT_CODE_GNE__C = 'XC_MON' and LogicalDeleteFlag_gne__c=false and Research_Pymt_Typ_Cd_gne__c != 'CLINICAL' AND Research_Pymt_Typ_Cd_gne__c != 'PRECLINICAL')];
        
        if(searchList == null || searchList.isEmpty() || searchList[0] == null || searchList[0].isEmpty()) {
            suplementPayment.status = false;
            suplementPayment.error_message = 'Transaction ID not found.';
            return suplementPayment;      
        } else if(searchList[0].size() > 1) { 
            suplementPayment.status = false;
            suplementPayment.error_message = 'More than one transaction found.';
            return suplementPayment;
        }
        
        Set<String> ids = new Set<String>();            
        for(AGS_Spend_Expense_Transaction_gne__c trans : ((List<AGS_Spend_Expense_Transaction_gne__c>)searchList[0])) {
            ids.add(trans.id);
        }
        
        List<AGS_Spend_Expense_Transaction_gne__c> transactions = [SELECT Id, (SELECT Name FROM AGS_ST_DisputeManagement_gne__r ORDER BY CreatedDate DESC LIMIT 1), (SELECT Source_Product_Name_gne__c FROM AGS_expense_products_intercations1__r), Spend_UserExternal_ID__c, Source_Transaction_ID_gne__c, Spend_User_Unix_ID_gne__c, Study_Name_gne__c, Event_Date_gne__c, Source_Transaction_Amount_gne__c, SCH_Expense__c, STUDY_DESCRIPTION_gne__c, THEME_NBR_gne__c, TRIAL_STATUS_gne__c, Legal_Entity_Company_Code_gne__c, Legal_Entity_Company_Location_gne__c, Legal_Entity_Company_Name_gne__c, GL_Code_gne__c, GL_Description_gne__c, WBS_Description_gne__c, WBS_Element_gne__c, Delayed_Reporting_Code_gne__c, Site_ID_gne__c, Trial_ID_gne__c, Invoice_ID_gne__c, Study_Manager_Email_gne__c, Study_Location_gne__c, CMS_Payment_ID_gne__c, Home_Payment_ID_gne__c /* task - AGGSPENDME-179 */ ,PO_number_gne__c  FROM AGS_Spend_Expense_Transaction_gne__c where Id in :ids and REPORT_CODE_GNE__C = 'XC_MON'];
        if(transactions.size() == 1) {
            suplementPayment = getTransactionRecord(transactions[0]);
            suplementPayment.disputeName = getMostRecentDisputeInTransaction(transactions[0]);
        }
        if(suplementPayment.status != false) {
            suplementPayment.status = true;
        }    
        return suplementPayment;
    }

    /** @date 8/21/2014
    * @Author Paweł Sprysak
    * @description Get most recent Dispute ID (Name)
    * @param AGS_Spend_Expense_Transaction_gne__c trans1, AGS_Spend_Expense_Transaction_gne__c trans2
    * @return String
    */
    public static String getMostRecentDisputeInTransaction(AGS_Spend_Expense_Transaction_gne__c trans) {
        if(trans.AGS_ST_DisputeManagement_gne__r.size() > 0) {
        	return trans.AGS_ST_DisputeManagement_gne__r.get(0).Name;
        }
        return null;
    }
    
    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Get Transaction Record
    * @param AGS_Spend_Expense_Transaction_gne__c trans
    * @return SuplementedTransaction
    */
    public static SuplementedTransaction getTransactionRecord(AGS_Spend_Expense_Transaction_gne__c trans) {
        SuplementedTransaction sp = new SuplementedTransaction();
        List<All_User_Hierarchy_gne__c> auh = [select FirstName_gne__c, LastName_gne__c from All_User_Hierarchy_gne__c where User_External_Id_gne__c =:trans.Spend_User_Unix_ID_gne__c];
        List<AGS_Expense_Products_Interaction__c> brands = [select AGS_Brand__c from AGS_Expense_Products_Interaction__c where Expense_Transaction_ID_gne__c  = :trans.id order by AGS_Brand__c];
        
        sp.TransactionID = trans.Source_Transaction_ID_gne__c;        
        if(!auh.isEmpty()) {
            sp.AccountableGNE_UnixID = trans.Spend_User_Unix_ID_gne__c;
            sp.AccountableGNE_FirstName = auh.get(0).FirstName_gne__c;
            sp.AccountableGNE_LastName = auh.get(0).LastName_gne__c;
        }
        sp.CPI = trans.CMS_Payment_ID_gne__c;
        sp.HPI = trans.Home_Payment_ID_gne__c;
        sp.EventMeetingName = trans.Study_Name_gne__c;
        if(trans.Event_Date_gne__c != null) {
            sp.EventStartDate = trans.Event_Date_gne__c.month()+'/' + trans.Event_Date_gne__c.day()+'/'+trans.Event_Date_gne__c.year();
        }
        sp.ItemAmount = trans.Source_Transaction_Amount_gne__c;
        sp.ItemCode = trans.SCH_Expense__c;
        sp.StudyDescription = trans.STUDY_DESCRIPTION_gne__c;
        sp.ThemeNumber = trans.THEME_NBR_gne__c;
        sp.PoNumber = trans.PO_number_gne__c;
        sp.TrialStatus = trans.TRIAL_STATUS_gne__c;
        sp.LegEntCompCode = trans.Legal_Entity_Company_Code_gne__c;
        sp.LegEntCompName = trans.Legal_Entity_Company_Name_gne__c;
        sp.LegEntCompLoc = trans.Legal_Entity_Company_Location_gne__c;
        sp.GlCode = trans.GL_Code_gne__c;
        sp.GlDesc = trans.GL_Description_gne__c;
        sp.WbsDesc = trans.WBS_Description_gne__c;
        sp.WbsElement = trans.WBS_Element_gne__c;
        sp.DelRepCode = trans.Delayed_Reporting_Code_gne__c;
        List<String> spnListFromEPI = new List<String>();
        for(AGS_Expense_Products_Interaction__c epi : trans.AGS_expense_products_intercations1__r) {
            spnListFromEPI.add(epi.Source_Product_Name_gne__c);
        }
        sp.spnList = spnListFromEPI;
        sp.SiteID = trans.Site_ID_gne__c;
        sp.TrialID = trans.Trial_ID_gne__c;
        sp.InvoiceID = trans.Invoice_ID_gne__c;
        sp.StudyManagerEmail = trans.Study_Manager_Email_gne__c;
        sp.StudyLocation = trans.Study_Location_gne__c;
        
        Map<String,String> orgBrands = VDST_Utils.getMapOfDrugNames();
        if(brands.size() > 0) {
            String br = ''; 
            String brIds = '';      
            Integer cnt = 0;
            for(AGS_Expense_Products_Interaction__c brand : brands) {            
                if(orgBrands.containsKey(brand.AGS_Brand__c)) {
                    cnt++;
                    if(cnt > 5)
                        break;
                    br = br + brand.AGS_Brand__c + ',';
                    brIds = brIds + orgBrands.get(brand.AGS_Brand__c) + ',';
                }
            }
            br = br.removeEnd(','); 
            brIds = brIds.removeEnd(',');   
            sp.Brands = br;
            sp.BrandIds = brIds;
        }       
            
        return sp;
    }

/******************* PARTICIPANT PART ***********************/

    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Get Suplemented Participants by Id and Type
    * @param String transId
    * @param String transType
    * @return SuplementedParticipants
    */
    public static SuplementedParticipants getSuplementedParticipants(String transId, String transType) {
        SuplementedParticipants participants = new SuplementedParticipants();
        String tridSOSLId = transId.substring(0, transId.length() - 1) + '*';
        String tridLikeId = transId + '%';
        List<List<SObject>> searchList = null;
        if('RSCH'.equals(transType))
            searchList = [FIND :tridSOSLId IN ALL FIELDS RETURNING AGS_Spend_Expense_Transaction_gne__c (id,Source_Transaction_ID_gne__c,REPORT_CODE_GNE__C WHERE Source_Transaction_ID_gne__c like :tridLikeId and REPORT_CODE_GNE__C = 'XC_MON' and LogicalDeleteFlag_gne__c=false and (Research_Pymt_Typ_Cd_gne__c = 'CLINICAL' OR Research_Pymt_Typ_Cd_gne__c = 'PRECLINICAL'))];
        else if('INDVSPND'.equals(transType))
            searchList = [FIND :tridSOSLId IN ALL FIELDS RETURNING AGS_Spend_Expense_Transaction_gne__c (id,Source_Transaction_ID_gne__c,REPORT_CODE_GNE__C WHERE Source_Transaction_ID_gne__c like :tridLikeId and REPORT_CODE_GNE__C = 'XC_MON' and LogicalDeleteFlag_gne__c=false and Research_Pymt_Typ_Cd_gne__c != 'CLINICAL' AND Research_Pymt_Typ_Cd_gne__c != 'PRECLINICAL')];

        if(searchList == null || searchList.isEmpty() || searchList[0] == null || searchList[0].isEmpty()) {
            participants.status = false;
            participants.error_message = 'This is new, not supplemented transaction.';
            return participants;      
        } else if(searchList[0].size() > 1) {
            participants.status = false;
            participants.error_message = 'More then two transaction found.';
            return participants;
        }
        
        Set<String> ids = new Set<String>();            
        for(AGS_Spend_Expense_Transaction_gne__c trans : ((List<AGS_Spend_Expense_Transaction_gne__c>)searchList[0])) {
            ids.add(trans.id);
        }
        List<AGS_Spend_Expense_Transaction_gne__c> transactions = 
                                [SELECT Id, Allocated_Transaction_Amount_gne__c, Spend_UserExternal_ID__c, Source_Transaction_ID_gne__c, 
                                    Spend_User_Unix_ID_gne__c, Study_Name_gne__c, Event_Date_gne__c, Source_Transaction_Amount_gne__c, 
                                    SCH_Expense__c, STUDY_DESCRIPTION_gne__c, THEME_NBR_gne__c, TRIAL_STATUS_gne__c, 
                                    
                                    PTY1_ADDRESS_LINE1_gne__c, PTY1_ADDRESS_LINE2_gne__c, PTY1_CITY_gne__c, PTY1_COUNTRY_gne__c, 
                                    PTY1_Name_gne__c, PTY1_FirstName_gne__c, PTY1_LastName_gne__c, 
                                    PTY1_NPI_gne__c, PTY1_SPECIALITY_gne__c, PTY1_TIN_gne__c, PTY1_TYPE_gne__c, PTY1_ZIP_gne__c, 
                                    PTY1_STATE_gne__c, PTY1_SRC_ATND_KEY_gne__c, PTY1_LIC_NUM_gne__c, PTY1_LIC_ST_CD_gne__c, 
                                    Primary_Recipient_gne__r.Address_Line_1_gne__c, Primary_Recipient_gne__r.Address_line_2_gne__c, 
                                    Primary_Recipient_gne__r.City_gne__c, Primary_Recipient_gne__r.Credential_gne__c, 
                                    Primary_Recipient_gne__r.Institution_Name_gne__c, Primary_Recipient_gne__r.NPI_gne__c, 
                                    Primary_Recipient_gne__r.First_Name_gne__c, Primary_Recipient_gne__r.Last_Name_gne__c, 
                                    Primary_Recipient_gne__r.RCH_Category_gne__c, 
                                    Primary_Recipient_gne__r.Specialty_gne__c, Primary_Recipient_gne__r.Specialty2_gne__c, 
                                    Primary_Recipient_gne__r.State_gne__c, Primary_Recipient_gne__r.Zip_gne__c, 
                                    Primary_Recipient_gne__r.Tax_Id_gne__c, Primary_Recipient_gne__r.Name, 
                                    
                                    PTY2_ADDRESS_LINE1_gne__c, PTY2_ADDRESS_LINE2_gne__c, PTY2_CITY_gne__c, PTY2_COUNTRY_gne__c, 
                                    PTY2_Name_gne__c, PTY2_FirstName_gne__c, PTY2_LastName_gne__c, 
                                    PTY2_NPI_gne__c, PTY2_SPECIALITY_gne__c, PTY2_TIN_gne__c, PTY2_TYPE_gne__c, PTY2_ZIP_gne__c, 
                                    PTY2_STATE_gne__c, PTY2_SRC_ATND_KEY_gne__c, PTY2_LIC_NUM_gne__c, PTY2_LIC_ST_CD_gne__c, 
                                    Secondary_Recipient_gne__r.Address_Line_1_gne__c, Secondary_Recipient_gne__r.Address_line_2_gne__c, 
                                    Secondary_Recipient_gne__r.City_gne__c, Secondary_Recipient_gne__r.Credential_gne__c, 
                                    Secondary_Recipient_gne__r.Institution_Name_gne__c, Secondary_Recipient_gne__r.NPI_gne__c, 
                                    Secondary_Recipient_gne__r.First_Name_gne__c, Secondary_Recipient_gne__r.Last_Name_gne__c, 
                                    Secondary_Recipient_gne__r.RCH_Category_gne__c, 
                                    Secondary_Recipient_gne__r.Specialty_gne__c, Secondary_Recipient_gne__r.Specialty2_gne__c, 
                                    Secondary_Recipient_gne__r.State_gne__c, Secondary_Recipient_gne__r.Zip_gne__c, 
                                    Secondary_Recipient_gne__r.Tax_Id_gne__c, Secondary_Recipient_gne__r.Name 
						       FROM AGS_Spend_Expense_Transaction_gne__c 
                               WHERE Id IN :ids and REPORT_CODE_GNE__C = 'XC_MON'];

        Boolean isParty1Availale = (transactions[0].Primary_Recipient_gne__c != null || transactions[0].PTY1_Name_gne__c != null);
        Boolean isParty2Availale = (transactions[0].Secondary_Recipient_gne__c != null || transactions[0].PTY2_Name_gne__c != null);
        if(transactions.size() == 1) {
        	participants = importRecord(transactions[0], isParty1Availale, isParty2Availale, transType);
        }

        if(participants.status != false) {
            participants.status = true;
        }
        return participants;
    }
    
    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Get Direct Record
    * @param AGS_Spend_Expense_Transaction_gne__c dirTransaction
    * @param Boolean isParty1Availale
    * @param Boolean isParty2Availale
    * @param String transactionType
    * @return SuplementedParticipants
    */
    public static SuplementedParticipants importRecord(AGS_Spend_Expense_Transaction_gne__c dirTransaction, Boolean isParty1Availale, Boolean isParty2Availale, String transactionType) {
        SuplementedParticipants participants = new SuplementedParticipants();
        VDST_EventDetailCommon commonUtils = new VDST_EventDetailCommon();
        if(isParty1Availale) {
            participants.directParticipant = getParticipant('Payee', dirTransaction, true, commonUtils);
        }
        if(isParty2Availale) {                                      
            if('RSCH'.equals(transactionType)) {           
                participants.indirectParticipant = getParticipant('PI', dirTransaction, false, commonUtils);
            } else if('INDVSPND'.equals(transactionType)) {             
                participants.indirectParticipant = getParticipant('Attendee', dirTransaction, false, commonUtils);
            }
        }
        return participants;
    }

    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Get Participant
    * @param String participantRole
    * @param AGS_Spend_Expense_Transaction_gne__c trans
    * @return Participant
    */
    public static Participant getParticipant(String participantRole, AGS_Spend_Expense_Transaction_gne__c trans, Boolean primaryRecipientData, VDST_EventDetailCommon commonUtils) {
        Participant part = new Participant();
        part.TransactionAmount = trans.Allocated_Transaction_Amount_gne__c;
        part.ParticipantRole = participantRole;
        
        String participantType = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'Type');
        Boolean isOrganization = ('ORGANIZATION'.equalsIgnoreCase(participantType)) ? true : false;

        if(isOrganization) {
        	part.LegalName = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'LegalName');
        	// TIN
		    String originalTIN = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'TIN');
		    if(!String.isBlank(originalTIN)) {
		        if(originalTIN.length() == 9 && !originalTIN.contains('-')) {
		            originalTIN = originalTIN.substring(0,2) + '-' + originalTIN.substring(2,9);
		        }
		    }
		    part.TIN = originalTIN;
        } else {
            part.FirstName = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'FirstName');
            part.LastName = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'LastName');
            if('YES'.equals(AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'RecipientObject'))) {
            	AGS_Recipient_License_State_gne__c rls;
            	if(primaryRecipientData) {
            	    rls = AGS_ST_Utils.getRecipientLicenseState(trans.Primary_Recipient_gne__c, AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'StateFull'), true);
            	} else {
            		rls = AGS_ST_Utils.getRecipientLicenseState(trans.Secondary_Recipient_gne__c, AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'StateFull'), true);
            	}
            	if(rls != null) {
            		part.LicenseNumber = rls.State_License_Number_gne__c;
            		part.LicenseState = rls.License_State_gne__c;
            	}
            } else {
		        part.LicenseNumber = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'LicenseNumber');
		        part.LicenseState = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'LicenseState');            	
            }
            part.Credential = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'Credential');
        }
        // Address
        part.City = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'City');
        part.Country = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'Country');
        if(part.Country != null && commonUtils.inverseMap.get(part.Country.toLowerCase()) != null) { // Change Label to Code
            part.Country = commonUtils.inverseMap.get(part.Country.toLowerCase());
        }
        if(String.isBlank(part.Country)) {
            part.Country = 'USA';
        }
        part.PostalCode = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'ZIP');
        part.StateProvince = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'State');
        part.StreetAddress = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'Address_Line1');
        part.StreetAddress2 = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'Address_Line2');
        // Other common fields
        part.NPI = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'NPI');
        part.MDMID = AGS_ST_Utils.getPartyData(trans, primaryRecipientData, 'MDMID');
        return part;
    }
    
    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Wrapper class for Suplemented Transaction
    */
    global class SuplementedTransaction {
        public Boolean status;
        public String error_message;
        
        // payment
        public String AccountableGNE_FirstName;
        public String AccountableGNE_LastName;
        public String AccountableGNE_UnixID;
        public String Brands;
        public String BrandIds;
        public String disputeName;
        public String EventMeetingName; 
        public String EventStartDate;
        public String GlCode;
        public String GlDesc;
        public String InvoiceID;
        public Decimal ItemAmount; 
        public String ItemCode;
        public String LegEntCompCode;
        public String LegEntCompName;
        public String LegEntCompLoc;
        public String SiteID;
        public String StudyDescription;
        public String StudyLocation;
        public String StudyManagerEmail; 
        public String ThemeNumber;
        public String TransactionID;
        public String TrialID;
        public String TrialStatus;
        public String WbsElement;
        public String WbsDesc;
        public String DelRepCode;
        public String HPI;
        public String CPI;
        public List<String> spnList;
        // Task  AGGSPENDME-179 - Start
        public String PoNumber;
        // Task  AGGSPENDME-179 - END
    }
    
    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Wrapper class for Suplemented Participants
    */
    public class SuplementedParticipants {
        public Boolean         status              { get; set; }
        public String          error_message       { get; set; }
        
        public Participant     directParticipant   { get; set; }
        public Participant     indirectParticipant { get; set; }
    }
    
    /** @date 1/15/2014
    * @Author Paweł Sprysak
    * @description Wrapper class for Participant
    */
    public class Participant {
        public String     City                { get; set; }
        public String     Country             { get; set; }
        public String     Credential          { get; set; }
        public String     PostalCode          { get; set; }
        public String     StateProvince       { get; set; }
        public String     StreetAddress       { get; set; }
        public String     StreetAddress2      { get; set; }
        public String     FirstName           { get; set; }
        public String     LastName            { get; set; }
        public String     LegalName           { get; set; }
        public String     LicenseNumber       { get; set; }
        public String     LicenseState        { get; set; }
        public String     MDMID               { get; set; }
        public String     NPI                 { get; set; }
        public String     ParticipantRole     { get; set; }
        public String     TIN                 { get; set; }
        public Decimal    TransactionAmount   { get; set; }
    }      
}