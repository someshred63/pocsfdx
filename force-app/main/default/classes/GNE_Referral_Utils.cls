public class GNE_Referral_Utils {

    /* 
    This class is used as util class to create/edit and view Referral.
    Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication
    request with a recordType Referral.

    Author : Sweta Khalasi
    Created : 01 Jul 2011
    Last Modified : 07 Oct 2014
    Modification:
	giszczap: SFA-923
    Project : gMARS Phase 2
    */
    public static final String REFERRAL_RECORD_TYPE_NAME_CANADA = 'ReferralCanada';

    public static final String strQueue='Queue';
    public static final String strHigh='High';
    public static final String strUrgent='Urgent';
    public static final String strNormal='Normal';
    
    public static final String ReferralReassignedQueueName='GNE-Referral-Reassigned-Queue';
    public static final String GneSFACanadaQueueName='GNE-SFA-CANADA-Queue';
    public static final String strReferral = 'Referral';    
    public static final String strObjectName ='Medical_Communication_gne__c';
    public static final String strRefObjectName ='Referral_Assignment_gne__c';
    public static final String strStatusField ='Status_Referral_gne__c';
    
    public static final String MedAffairProfile = 'MedAffairs';
    public static final String SFAProfile = 'GNE-SFA';
    public static final String ATLSProfile = 'GNE-TLS';
    public static final String SysAdminProfile = 'System Administrator';
    public static final String MCLProfile = 'GNE-MedAffairs-MCL';
    public static final String MSLProfile = 'GNE-MedAffairs-MSL';
    public static final String MSLCanadaProfile = 'RCanada-SFA-MSL';
    public static final String MCLManagerProfile = 'GNE-MedAffairs-MCL-Manager';
    public static final String ManagerProfile = 'Manager';
    public static final String MSLManagerProfile = 'GNE-MedAffairs-MSL-Manager';
    public static final String SPProfile = 'GNE-MedAffairs-SP';
    public static final String SPManagerProfile = 'GNE-MedAffairs-SP-Manager';
    public static final String TISLProfile = 'GNE-MedAffairs-TISL';
    
    public static final String strReassigned = 'Reassigned';
    public static final String strRequestVerified = 'Request Verified';
    public static final String strStatusUpdate = 'Status Update';
    public static final String strCompletionDateUpdate = 'Completion Date Update';
    public static final String strCreated = 'Created';
    
    //Status Email
    public static final String strStatusSendEmail = 'Send Email';
    public static final String strStatusAssignedEmail = 'Email Sent - Assigned';    
    public static final String strStatusAcknowledgedEmail = 'Email Sent - Acknowledged';
    public static final String strStatusClosedDuplicateEmail = 'Email Sent - Closed - Duplicate';
    public static final String strStatusClosedHCPUnresponsiveEmail = 'Email Sent - Closed - HCP Unresponsive';
    public static final String strStatusClosedNotVerifiableEmail = 'Email Sent - Closed - Not Verifiable';
    public static final String strStatusFulfilledEmail = 'Email Sent - Fulfilled';
    public static final String strStatusFulfilledMedCommEmail = 'Email Sent - Fulfilled and Med Comm';
    public static final String strStatusUrgentEscalationEmail = 'Email Sent - Urgent Escalation';
    public static final String strStatusNormalEscalationEmail = 'Email Sent - Normal Escalation';
    public static final String strStatusUnsolicitedRequestVerifiedEmail = 'Email Sent - Unsolicited Request Verified';
    
    public static final String strPrimary = 'P';
    public static final String strSecondary = 'S';

    //Referral Status
    public static final String strAcknowledged = 'Acknowledged';
    public static final String strAssigned = 'Assigned';
    public static final String strClosedDuplicate = 'Closed - Duplicate';
    public static final String strClosedHCPUnresponsive = 'Closed - HCP Unresponsive';
    public static final String strClosedNotVerifiable = 'Closed - Not Verifiable';
    public static final String strFulfilled = 'Fulfilled';
    public static final String strFulfilledMedComm = 'Fulfilled and Med Comm';
    public static final String strUrgentEscalation = 'Urgent Escalation';
    public static final String strNormalEscalation = 'Normal Escalation';
    
    public static final String orgName = 'gMARS Administrator';
    //TimeZone
    public static final String strGMTFormat = 'yyyy-MM-dd HH:mm:ss';
    public static final String strPSTFormat = 'MM/dd/yyyy hh:mm a';
    public static final String strDateFormat = 'yyyy-MM-dd';
    
    public static final String strPST = 'PST';
    public static final String strEST = 'EST';
    public static final String strGMT = 'GMT';
    
    public static String strReferralCurrentStatus = 'Assigned';
    public static String strVerifiedBy = '';
    public static Id strReferralId = null;
    
    public static DateTime strReferralDate = null;
    public static Integer recursiveCount = 0;
    public static Boolean isMSL = false;
    public static Boolean isMSLCanada = false;
    public static Boolean isMCL = false;
    public static Boolean isManager = false;
    public static Boolean isMedicalReferral = false;
    
    // helper cache to avoid too many SOQL queries
    private static Map<Id,User> usersCache = new Map<Id,User>();
    private static Date nearestWorkingDay;
    
    public static Boolean isOnVacation(Id userId, DateTime dueDate){
        //[BOS] It will be calculated in different way for MSLs
        String profileName = getCurrentUser(userId).Profile_Name_gne__c;
        if(profileName.equalsIgnoreCase(MSLProfile) || profileName.equalsIgnoreCase(MSLManagerProfile)) {
            return false;
        }
        List<Time_off_Territory_Day_gne__c> tots = [SELECT CreatedById, Date_gne__c, Id FROM Time_off_Territory_Day_gne__c WHERE CreatedById= :userId AND Date_gne__c>=:datetime.now().dateGMT() AND Date_gne__c<=:dueDate.dateGMT()];
        return tots.size() >0;
    }
    
    public static Integer getIntAddDay(String strPriority){
        Integer intAddDay = 0;
        if(!String.isEmpty(strPriority)){
            Referral_Escalation_gne__c objReferralEscalation = [SELECT Days_gne__c, Id, Priority_gne__c, Status_gne__c FROM Referral_Escalation_gne__c WHERE Priority_gne__c= : strPriority LIMIT 1];
            if(objReferralEscalation.Days_gne__c != null){
                intAddDay = objReferralEscalation.Days_gne__c.intValue();
            }
        }
        System.debug('intAddDay: ' + intAddDay);
        return intAddDay;    
    }
    
    public static DateTime getDueDate(DateTime refDate, String strPriority){
        System.debug('Inside getDueDate: --> ');
        if(!String.isEmpty(strPriority)){
            DateTime refStatusDate = getGMTDate(refDate);
            DateTime newRefStatusDate = getBusinessWorkingDay(refStatusDate);
            Integer intAddDay = getIntAddDay(strPriority);
            Integer intHour = newRefStatusDate.hourGmt();
            
            if(intHour >= 16 && intHour < 24){ 
                
            }else if(intHour >= 0 && intHour < 7){
                intAddDay = intAddDay + 1;
            }
            newRefStatusDate = newRefStatusDate.AddDays(intAddDay);
            DateTime gmtDateTime = getDayAdded(newRefStatusDate);
            return datetime.newInstanceGmt(gmtDateTime.year(), gmtDateTime.month(), gmtDateTime.day(), 24, 0, 0);
        }else{
            return datetime.now();
        }
    }
    
    public static Boolean IsWeekendDay(Datetime dateParam){
        Date startOfWeek   = dateParam.date().toStartOfWeek();
        Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
        return dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
    }
    
    public static Integer IsFridDayEvening(Datetime dateParam){
        Integer intHour = dateParam.hourGmt();
        Integer intAddDays = 0;
        
        Date startOfWeek   = dateParam.date().toStartOfWeek();
        Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
        
        Boolean result = dayOfWeek == 5 ? true : false;
        if(result && intHour >= 0 && intHour < 7){
            intAddDays = 3; 
        }
        return intAddDays;
    }
    
    public static List<Actual_Working_Days_gne__c> getActualWorkingDays(DateTime newRefDate){
        Date dtGivenDate = newRefDate.dateGMT();
        Date dtNewDate = dtGivenDate.addMonths(1);
        return [SELECT Date_gne__c, Id FROM Actual_Working_Days_gne__c WHERE Date_gne__c >= :dtGivenDate AND Date_gne__c <= :dtNewDate order by Date_gne__c];
    }
    
    public static DateTime getDayAdded(DateTime refDate){
        Integer intAddDays = 0;
        DateTime newRefDate = refDate;
        Date dtGivenDate = newRefDate.dateGMT();
        
        Boolean isDateFound = false;
        try{
            for(Actual_Working_Days_gne__c ad : getActualWorkingDays(newRefDate)){
                if(!isDateFound){
                    Integer daysDifference = dtGivenDate.daysBetween(ad.Date_gne__c);               
                    if(dtGivenDate.isSameDay(ad.Date_gne__c)){
                        isDateFound = true;
                        intAddDays = 0;
                    }else{
                        isDateFound = true;
                        intAddDays = daysDifference;
                    }
                }
            }
            if(intAddDays > 0){
                return newRefDate.AddDays(intAddDays);                
            }else{
                return newRefDate;
            }
        }catch (Exception ex){
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching getDayAdded' + ex));
            throw ex;            
        }   
    }
    
    public static DateTime getBusinessWorkingDay(DateTime refDate){
        Integer intAddDays = IsFridDayEvening(refDate);
        
        DateTime newRefDate = refDate;
        if(intAddDays > 0){
            newRefDate = addGivenDays(refDate, intAddDays);
            intAddDays = 0;
        }
        
        Date dtGivenDate = newRefDate.dateGMT();
        try{
            for(Actual_Working_Days_gne__c ad : getActualWorkingDays(newRefDate)){
                Integer daysDifference = dtGivenDate.daysBetween(ad.Date_gne__c);               
                if(dtGivenDate.isSameDay(ad.Date_gne__c)){
                    intAddDays = 0;
                    break;
                }else{
                    intAddDays = daysDifference;
                    break;
                }
            }
            if(intAddDays > 0){
                newRefDate = addGivenDays(newRefDate,intAddDays);
            }
            return newRefDate;
        }catch (Exception ex){
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching BusinessWorkingDay' + ex));
            throw ex;            
        }
    }
    
    public static DateTime addGivenDays(DateTime refStatusDate,Integer intAddDays){
        DateTime gmtDateTime = refStatusDate.AddDays(intAddDays);
        return datetime.newInstanceGmt(gmtDateTime.year(), gmtDateTime.month(), gmtDateTime.day(), 16, 0, 0);
    }
    
    public static DateTime getGMTDate(DateTime refStatusDate){
        return datetime.newInstanceGmt( refStatusDate.dateGMT(), refStatusDate.timeGmt());
    }
    
    public static void loadUserProfileType(User currentUser){
        isMCL = false;
        isMSL = false;
        isMSLCanada = false;
        isManager = false;
        if (currentUser !=null && currentUser.Profile_Name_gne__c == MCLProfile){
            isMCL = true;
        }else if (currentUser !=null && currentUser.Profile_Name_gne__c == MSLProfile){
            isMSL = true;
        }else if (currentUser !=null && currentUser.Profile_Name_gne__c == MSLCanadaProfile){
            isMSLCanada = true;
        }else if (currentUser !=null && (currentUser.Profile_Name_gne__c == MCLManagerProfile || currentUser.Profile_Name_gne__c == MSLManagerProfile || currentUser.Profile_Name_gne__c == SPManagerProfile || currentUser.Profile_Name_gne__c == SPProfile)){
            isManager = true;
        }
    }
    
    public static Boolean isCreateReferralAllowed(User currentUser){
        //Referral will be created by SFA, MedAffair, ATLS and system admin profile only.
        if(currentUser !=null && (currentUser.Profile_Name_gne__c.contains(MedAffairProfile) || (currentUser.Profile_Name_gne__c.contains(SFAProfile) && !currentUser.Profile_Name_gne__c.startsWithIgnoreCase('GNE-SFA-OPS') ) || currentUser.Profile_Name_gne__c.contains(ATLSProfile) || currentUser.Profile_Name_gne__c.contains(SysAdminProfile)) && (!currentUser.Profile_Name_gne__c.contains(TISLProfile))){
            return true;
        }else{
            return false;
        }   
    }
    
    public static String getStatusEmail(String strStatus){
        if(strStatus == strAssigned){
            return strStatusAssignedEmail;
        }else if(strStatus == strAcknowledged){
            return strStatusAcknowledgedEmail;
        }else if(strStatus == strClosedDuplicate){
            return strStatusClosedDuplicateEmail;
        }else if(strStatus == strClosedHCPUnresponsive){
            return strStatusClosedHCPUnresponsiveEmail;
        }else if(strStatus == strClosedNotVerifiable){
            return strStatusClosedNotVerifiableEmail;
        }else if(strStatus == strFulfilled){
            return strStatusFulfilledEmail;
        }else if(strStatus == strFulfilledMedComm){
            return strStatusFulfilledMedCommEmail;
        }else if(strStatus == strUrgentEscalation){
            return strStatusUrgentEscalationEmail;
        }else if(strStatus == strNormalEscalation){
            return strStatusNormalEscalationEmail;
        }else{
            return strStatusSendEmail;
        }
    }

    public static RecordType getReferralRecordType(){
        String recTypeName = GNE_SFA2_Util.isCanadaUser() ? REFERRAL_RECORD_TYPE_NAME_CANADA : strReferral;
        return [SELECT Id, IsActive, Name, SobjectType FROM RecordType WHERE SobjectType =:strObjectName AND Name = :recTypeName AND IsActive= true LIMIT 1];
    }
    
    public static Address_vod__c getAddressInfo(Id AddId, Id AccountId){
        Address_vod__c objAddress = new Address_vod__c();
        Account objAccount = [SELECT Id, Name,PersonEmail, (SELECT Account_vod__c, Account_vod__r.Cell_Phone_gne__c, Active_Flag_gne__c, Address_1_gne__c, Address_line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, Address_Type_gne__c, City_vod__c, Country_gen__c, Email_gne__c, Fax_2_vod__c, Fax_vod__c, Id, Inactive_vod__c, License_Status_vod__c, License_vod__c, Name, Phone_1_Ext_gne__c, Phone_2_Ext_gne__c, Phone_2_vod__c, Phone_vod__c, State_vod__c, Zip_4_vod__c, Zip_vod__c, Province_can_gne__c FROM Address_vod__r WHERE id = :AddId AND Inactive_vod__c = false LIMIT 1), IsPersonAccount,Secondary_Email_gne__c FROM Account WHERE id = :AccountId];    
        //asssign address
        List<Address_vod__c> lstAddress = objAccount.address_vod__r;
        if(lstAddress != null && lstAddress.size()>0){
            objAddress = lstAddress[0];
            if(objAccount.PersonEmail != null){
                objAddress.Email_gne__c = objAccount.PersonEmail;
            }else if(objAccount.Secondary_Email_gne__c != null){
                objAddress.Email_gne__c = objAccount.Secondary_Email_gne__c;
            }
        }
        return objAddress;
    }
    
    public static String setErrorMessage(List<String> lstFieldValidationErrors){
        String strError = '';
        try{
            if(lstFieldValidationErrors != null && lstFieldValidationErrors.size()>0){
                for(Integer i = 0 ; i < lstFieldValidationErrors.size() ; i++ ){
                    String strErr = lstFieldValidationErrors.get(i);
                    if(i==0){
                        strError = strErr;
                    }else{
                        strError = strError + ',' + strErr;
                    }             
                }
            }
        }catch(Exception ex){
            System.debug('Inside setErrorMessage Catch Exception: ' + ex);
            throw ex;
        }
        return strError;
    }
    
    public static List<Integer> shuffleArray(List<Integer> arr) {
		List<Integer> randomizedArray = new List<Integer>();
        List<Boolean> choseArray = new List<Boolean>();
        for (Integer i=0; i<arr.size(); i++) {
        	choseArray.add(false);
		}
		for(Integer i=0; i<arr.size();) {
			Double dbl = Math.random() * arr.size();
            Integer dblInt = dbl.intValue();
            if (!choseArray.get(dblInt)) {
   			     randomizedArray.add(dbl.intValue());
                 choseArray[dblInt] = true;
                 i++;
            }
		}
		return randomizedArray;
	}
	
	private static List<Integer>getListOfInteger(Integer maxNumber){
		List<Integer>result = new List<Integer>();
		for(Integer i=0; i< maxNumber; i++){
			result.add(i);
		}
		return result;
	}
	
    public static Id getMSLId(List<Referral_Roster_Detail_gne__c> lstReferralRosterDetails, DateTime dueDate){
        Id mslId=null;
        Boolean isMSLOnVacation = false;
        try{
            if(lstReferralRosterDetails != null && lstReferralRosterDetails.size() >0){
                //If single MSL found assign Referral to the MSL
                if(lstReferralRosterDetails.size() ==1){
                    if((getActiveUserId(lstReferralRosterDetails[0].Referral_Roster_gne__r.User_gne__c) != null) && (!isOnVacation(lstReferralRosterDetails[0].Referral_Roster_gne__r.User_gne__c, dueDate))){
                        return lstReferralRosterDetails[0].Referral_Roster_gne__r.User_gne__c;
                    }else{
                        //If single MSL found and MSL is on vacation assign to the MSL Manager.
                        return getActiveUserId(lstReferralRosterDetails[0].Referral_Roster_gne__r.Manager_gne__c);
                    }
                }else{
                    //If Multiple MSL found determine who is Primary and assign MSL to Primary.
                    //If multiple Primary found assign to any random Primary
                    //List with random indexes is used for searching for random MSL
                    List<Integer>randomIndexes = shuffleArray(getListOfInteger(lstReferralRosterDetails.size()));
                    for( Integer i = 0 ; i < lstReferralRosterDetails.size() ; i++ ){
                    	Integer index = randomIndexes[i];
                        Referral_Roster_Detail_gne__c objReferralRosterDetail = lstReferralRosterDetails[index];
                        //If multiple Primary found assign to any random Primary
                        if(objReferralRosterDetail.Referral_Roster_gne__r.Primary_OR_Secondary_gne__c != null && objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c != null && objReferralRosterDetail.Referral_Roster_gne__r.Primary_OR_Secondary_gne__c==strPrimary){
                            if((getActiveUserId(objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c) != null) && (!isOnVacation(objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c,dueDate))){
                                mslId = objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c;
                                isMSLOnVacation = false;
                                if(mslId != null){
                                    return mslId;
                                }
                            }else{
                                isMSLOnVacation = true;
                            }
                        }                               
                    }
                    //If multiple MSL found and all Primary are on vacation assign to MSL Manager
                    if(isMSLOnVacation){
                        for( Integer i = 0 ; i < lstReferralRosterDetails.size() ; i++ ){
                        	Integer index = randomIndexes[i];
                            Referral_Roster_Detail_gne__c objReferralRosterDetail = lstReferralRosterDetails[index];
                            if(objReferralRosterDetail.Referral_Roster_gne__r.Manager_gne__c!=null){
                                //If multiple MSL found and all Primary are on vacation assign to MSL Manager
                                mslId = getActiveUserId(objReferralRosterDetail.Referral_Roster_gne__r.Manager_gne__c);
                                if(mslId != null){
                                    return mslId;
                                }
                            }
                        }
                    }
                    
                    //If Multiple MSL found but no one is Primary, assigned to first secondary
                    isMSLOnVacation = false;
                    for( Integer i = 0 ; i < lstReferralRosterDetails.size() ; i++ ){
                    	Integer index = randomIndexes[i];
                        Referral_Roster_Detail_gne__c objReferralRosterDetail = lstReferralRosterDetails[index];
                        //If Multiple MSL found but no one is Primary, assign to any random secondary
                        if(objReferralRosterDetail.Referral_Roster_gne__r.Primary_OR_Secondary_gne__c != null && objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c != null && objReferralRosterDetail.Referral_Roster_gne__r.Primary_OR_Secondary_gne__c != strPrimary){
                            if((getActiveUserId(objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c) != null) && (!isOnVacation(objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c, dueDate))){
                                mslId = objReferralRosterDetail.Referral_Roster_gne__r.User_gne__c;
                                isMSLOnVacation = false;
                                if(mslId != null){
                                    return mslId;
                                }
                            }else{
                                isMSLOnVacation = true;
                            }
                        }
                    }
                    if(isMSLOnVacation){
                        //If Multiple MSL found but no one is Primary, and secondary are on vacation, assign to MSL Manager
                        for( Integer i = 0 ; i < lstReferralRosterDetails.size() ; i++ ){
                        	Integer index = randomIndexes[i];
                            Referral_Roster_Detail_gne__c objReferralRosterDetail = lstReferralRosterDetails[index];
                            if(objReferralRosterDetail.Referral_Roster_gne__r.Manager_gne__c!=null){
                                mslId = getActiveUserId(objReferralRosterDetail.Referral_Roster_gne__r.Manager_gne__c);
                                if(mslId != null){
                                    return mslId;
                                }
                            }                               
                        }
                    }                               
                }
            }
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching mslId' + ex));
            throw ex;            
        }
        return mslId;
    }
    
    public static Id getAutoAssigned(Id TA_SubTAId, String strAddressState, User requestedByUser, DateTime dueDate){
        Id mslId=null;
        Product_vod__c objTAOtherProduct = new Product_vod__c();
        String strOther='- Other';
        try{
            if (requestedByUser !=null && (requestedByUser.Profile_Name_gne__c == MCLProfile || requestedByUser.Profile_Name_gne__c == MCLManagerProfile)){
                mslId = getMCLManager(System.Label.GNE_MCL_Manager);
                if(mslId != null){
                    return mslId;
                }              
            }else{
                if(recursiveCount < 2){
                    //get the lis of Roster detail for TA and State condition
                    List<Referral_Roster_Detail_gne__c> lstReferralRosterDetails = [SELECT Id, Name, Product_TA_SubTA_gne__c, Product_TA_SubTA_gne__r.Id, Product_TA_SubTA_gne__r.Name, Referral_Roster_gne__c, Referral_Roster_gne__r.First_Name_gne__c, Referral_Roster_gne__r.Id, Referral_Roster_gne__r.Last_Name_gne__c, Referral_Roster_gne__r.Manager_gne__c, Referral_Roster_gne__r.Manager_Name_gne__c, Referral_Roster_gne__r.Name, Referral_Roster_gne__r.Primary_OR_Secondary_gne__c, Referral_Roster_gne__r.UnixId_Manager_gne__c, Referral_Roster_gne__r.UnixId_User_gne__c, Referral_Roster_gne__r.User_gne__c, State_gne__c, TA_SubTA_gne__c 
                                                                                    FROM Referral_Roster_Detail_gne__c WHERE Product_TA_SubTA_gne__c= :TA_SubTAId AND State_gne__c= :strAddressState];
                    if(lstReferralRosterDetails.size()>0){
                        mslId = getMSLId(lstReferralRosterDetails, dueDate);
                        if(mslId != null){
                            return mslId;
                        }
                    }
                    
                    //if there is no MSL in state we are looking for other MSLs
                    //get the lis of Roster detail for TA condition only
                    lstReferralRosterDetails = [SELECT Id, Name, Product_TA_SubTA_gne__c, Product_TA_SubTA_gne__r.Id, Product_TA_SubTA_gne__r.Name, Referral_Roster_gne__c, Referral_Roster_gne__r.First_Name_gne__c, Referral_Roster_gne__r.Id, Referral_Roster_gne__r.Last_Name_gne__c, Referral_Roster_gne__r.Manager_gne__c, Referral_Roster_gne__r.Manager_Name_gne__c, Referral_Roster_gne__r.Name, Referral_Roster_gne__r.Primary_OR_Secondary_gne__c, Referral_Roster_gne__r.UnixId_Manager_gne__c, Referral_Roster_gne__r.UnixId_User_gne__c, Referral_Roster_gne__r.User_gne__c, State_gne__c, TA_SubTA_gne__c 
                                                FROM Referral_Roster_Detail_gne__c WHERE Product_TA_SubTA_gne__c= :TA_SubTAId];
                    if(lstReferralRosterDetails.size()>0){
                        mslId = getMSLId(lstReferralRosterDetails, dueDate);
                        if(mslId != null){
                            return mslId;
                        }
                    }
                    
                    //get the 'TA - Other' product detail and than
                    //get the lis of Roster detail for that 'TA - Other' product
                    List<Product_vod__c> lstObjProduct = [SELECT Id, Name, Detail_Product_Subtype_Code_gne__c, Product_Type_vod__c, Therapeutic_Area_vod__c FROM Product_vod__c WHERE Id= :TA_SubTAId LIMIT 1];
                    if(lstObjProduct.size()>0){
                        Product_vod__c objProduct = lstObjProduct[0];
                        String strTAName = objProduct.Name;
                        if(strTAName != null && strTAName.indexOf('-') != -1){                                   
                            String strTAOtherName = strTAName.substring(0, strTAName.indexOf('-')) + strOther;
                            strTAOtherName = strTAOtherName.trim();
                            
                            List<Product_vod__c> lstObjTAOtherProduct = [SELECT Id, Name, Detail_Product_Subtype_Code_gne__c, Product_Type_vod__c FROM Product_vod__c WHERE Name= :strTAOtherName LIMIT 1];
                            if(lstObjTAOtherProduct.size() > 0){
                                objTAOtherProduct = lstObjTAOtherProduct[0];
                                recursiveCount = recursiveCount +1;
                                mslId = getAutoAssigned(objTAOtherProduct.Id, strAddressState, requestedByUser, dueDate);
                                if(mslId != null){
                                    return mslId;
                                }
                            }else{
                                System.debug('no product exist with this TA_SubTAId Other Name: ' + objTAOtherProduct);
                                return null;
                            }
                        }
                    }else{
                        System.debug('no product exist with this TA_SubTAId : ' + TA_SubTAId);
                        return null;
                    }                                   
                }else{
                    System.debug('recursiveCount: ' + recursiveCount);
                    return null;
                }
            }
            return mslId;
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while fetching MSL Name' + ex));
            throw ex;            
        }       
    }

    public static Map<String,User> getAssignedManagerUser(Id assignedUserId){
        Map<String,User> mapUserManagerId = new Map<String,User> ();
        List<String> lstUsers = new List<String> ();
        Id ManagerId = null;
        lstUsers.add(assignedUserId);
        try{
            List<Referral_Roster_gne__c> lstObjReferralRoster = [SELECT Id, Manager_gne__c, User_gne__c FROM Referral_Roster_gne__c
                                                                WHERE User_gne__c = :assignedUserId LIMIT 1];
            if(lstObjReferralRoster.size()>0){
                if(lstObjReferralRoster[0].Manager_gne__c != null){
                    lstUsers.add(lstObjReferralRoster[0].Manager_gne__c);
                    ManagerId = lstObjReferralRoster[0].Manager_gne__c;
                }
            }           
            Map<String,User> mapUserId = getUserData(lstUsers);
            if(mapUserId != null && mapUserId.size()>0){
                if(ManagerId != null && mapUserId.containsKey((String)ManagerId)){
                    mapUserManagerId.put('ManagerId', mapUserId.get(ManagerId));
                }
                if(assignedUserId != null && mapUserId.containsKey((String)assignedUserId)){
                    mapUserManagerId.put('UserId', mapUserId.get(assignedUserId));
                }
                return mapUserManagerId;                
            }else{
                return null;
            }
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching getAssignedManagerUser ' + ex));
            throw ex;            
        } 
    }
    
    public static List<String> getRestrictedProductName(){
        List<String> lstMedAffairsMoleculeNames = new List<String> ();
        try{
            for (MedAffairs_Molecules_gne__c objMedAffairsMolecule : [SELECT Id, Molecule_Name_gne__c, Name FROM MedAffairs_Molecules_gne__c]){
                if(objMedAffairsMolecule != null && objMedAffairsMolecule.Molecule_Name_gne__c != null){
                    lstMedAffairsMoleculeNames.add(objMedAffairsMolecule.Molecule_Name_gne__c);
                }               
            }                   
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching getRestrictedProductName ' + ex));
            throw ex;            
        }
        return lstMedAffairsMoleculeNames;
    }
    
    public static Id getManualAssigned(Id userId, DateTime dueDate){
        try{
            if(isMCL){
                if(isOnVacation(userId, dueDate)){
                    return getMCLManager(System.Label.GNE_MCL_Manager);
                }else{
                    return userId;
                }
            }else if(isMSLCanada){
            	return userId;
            }else{
                //get the lis of Roster detail for this user
                List<Referral_Roster_gne__c> lstReferralRoster = [SELECT First_Name_gne__c, Id, Last_Name_gne__c, Manager_gne__c, Manager_gne__r.Alias, Manager_gne__r.Email, Manager_gne__r.Id, Manager_gne__r.IsActive, Manager_gne__r.Name, Manager_Name_gne__c, Name, Primary_OR_Secondary_gne__c, UnixId_Manager_gne__c, UnixId_User_gne__c, User_gne__c, User_gne__r.Alias, User_gne__r.Email, User_gne__r.Id, User_gne__r.IsActive, User_gne__r.Name
                                                                    FROM Referral_Roster_gne__c
                                                                    WHERE User_gne__c = :userId];
                for (Referral_Roster_gne__c objRoster : lstReferralRoster){
                    if(!isOnVacation(objRoster.User_gne__c,dueDate)){
                        return objRoster.User_gne__c;
                    }else{
                        return getActiveUserId(objRoster.Manager_gne__c);
                    }
                }               
            }
            return null;
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while doing Manual Assignment' + ex));
            throw ex;            
        }       
    }
    
    public static Id getOWEmailAddressId(){
        Id OrgId=null;
        for(OrgWideEmailAddress owa : [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName= :orgName LIMIT 1]) {
            if(owa.DisplayName.contains('gMARS Administrator')){
                OrgId = owa.Id;
            }
        }
        return OrgId;
    }
    
    public static Boolean sendReferralEmail(Referral_Assignment_gne__c newRefAssignment, Medical_Communication_gne__c objReferral, String referralStatus){
        Set<String> toAddresses = new Set<String>();
        strReferralId = newRefAssignment.Id;

        Referral_Assignment_gne__c newRefAss = getReferralAssignment(newRefAssignment.Id);
        String refAssignedTo = newRefAss.Assigned_To_gne__c;
        strReferralCurrentStatus = newRefAss.Status_Referral_gne__c;
        
        Medical_Communication_gne__c newRef = getReferral(objReferral.Id);
        String refCreatedBy = newRef.CreatedById;
        if(!GNE_SFA2_Util.isCanadaUser() && newRef.Unsolicited_Request_Verified_By_gne__c != null && referralStatus != strAssigned){
            String strVerifiedByUserNameRole = GNE_Referral_Utils.getUserNameAndRole(newRef.Unsolicited_Request_Verified_By_gne__c);
            String[] lstUserNameAndRole = strVerifiedByUserNameRole.split(',',2);
            if(lstUserNameAndRole.size() > 0){
                strVerifiedBy = lstUserNameAndRole[0];                   
            }
        }
        
        Set<String> lstUsers = new Set<String>();
        lstUsers.add(refCreatedBy);
        lstUsers.add(refAssignedTo);
        
        if(referralStatus != strAssigned){
            lstUsers.addAll(getReferralAssignee(newRef.Referral_History_gne__c));
        }
        
        Map<String, User> mapUserId = getUserEmailId(new List<String>(lstUsers));
        System.debug('mapUserId:' + mapUserId);

        if(referralStatus == strAssigned || referralStatus == strReassigned){
            if(mapUserId.containsKey(refAssignedTo)){
                toAddresses.add(mapUserId.get(refAssignedTo).Email);
            }
        }else if(mapUserId.containsKey(refCreatedBy)){
            toAddresses.add(mapUserId.get(refCreatedBy).Email);
        }        

        Set<String> ccAddresses = new Set<String>();
        if (!GNE_SFA2_Util.isCanadaUser()){
        	for (User objUser : mapUserId.values()){
            	ccAddresses.add(objUser.Email);
        	}
        }
        
        User assUser = getCurrentUser(newRefAss.Assigned_To_gne__r.Id);
        EmailTemplate emailTemplate = getEmailTemplate(referralStatus, newRef.Priority_gne__c, assUser);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (!GNE_SFA2_Util.isCanadaUser()){
            mail.setOrgWideEmailAddressId(getOWEmailAddressId());
        }

        mail.setToAddresses(new List<String>(toAddresses));
        if(ccAddresses != null && ccAddresses.size() >0){
            mail.setCcAddresses(new List<String>(ccAddresses));
        }
        mail.setTargetObjectId(Userinfo.getUserId());
        mail.setSaveAsActivity(false);
        
        if( emailTemplate != null ) {
        	mail.setWhatId(newRefAssignment.Id);
       		mail.setTemplateId(emailTemplate.id);
        } else {
        	List<String> email = getEmailLabelTemplate(referralStatus, newRef.Priority_gne__c, newRefAssignment.Id);
        	if( email == null ) {
        		return false;
        	}
        	mail.setHtmlBody( email[0] );
        	mail.setSubject( email[1] );
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return true;
    }

    private static EmailTemplate getEmailTemplate(String updateType, String priority, User assUser){
    	User currUser = getCurrentUser( UserInfo.getUserId() );
        Boolean isCanadaUser = GNE_SFA2_Util.isCanadaUser(currUser.Profile_Name_gne__c);
        Boolean isUrgent = priority == strUrgent;
        String emailTemplate = '';
        if(updateType == strAssigned){
            if(isMCLorMSL(assUser)) {
            	return null;
            }
            if(isUrgent){
                emailTemplate = isCanadaUser ? 'Urgent_Referral_Assigned_Canada' : 'Urgent_Referral_Assigned';
            }else{
                emailTemplate = isCanadaUser ? 'Regular_Referral_Assigned_Canada' : 'Regular_Referral_Assigned';
            }
        }else if(updateType == strReassigned){
        	if(isMCLorMSL(assUser)) {
            	return null;
            }
            if(isUrgent){
                emailTemplate = isCanadaUser ? 'Urgent_Referral_ReAssigned_Canada' : 'Urgent_Referral_ReAssigned';
            }else{
                emailTemplate = isCanadaUser ? 'Regular_Referral_ReAssigned_Canada' : 'Regular_Referral_ReAssigned';
            }
        } else if(updateType == strAcknowledged){
        	if(isMCLorMSL(currUser) || isUSCSUser()) {
        		return null;
        	}
            emailTemplate = isCanadaUser ? 'Referral_Acknowledge_Status_Canada' : 'Referral_Acknowledge_Status';
        } else if (updateType == strFulfilled && (isMCLorMSL(currUser) || isUSCSUser())) {
        	return null;
        } else if ((updateType == strClosedHCPUnresponsive || updateType == strClosedNotVerifiable || updateType == strClosedDuplicate ) && (isMCLorMSL(currUser) || isUSCSUser())) {
        	return null;
        } else {
            emailTemplate = isCanadaUser ? 'Referral_Closed_Canada' : 'Referral_Closed';
        }
        return [SELECT Id, IsActive, Name, OwnerId, FolderId, Subject, TemplateType, Body, Markup FROM EmailTemplate WHERE IsActive=true AND DeveloperName = :emailTemplate LIMIT 1];
    }

    private static String[] getEmailLabelTemplate(String updateType, String priority, Id refId){
    	User currUser = getCurrentUser( UserInfo.getUserId() );
        Boolean isCanadaUser = GNE_SFA2_Util.isCanadaUser(currUser.Profile_Name_gne__c);
    	List<Referral_Assignment_gne__c> refAssList = [SELECT Name, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Account_gne__r.Name, Assigned_To_gne__r.Name, Requested_By_gne__c, Referral_Link_gne__c FROM Referral_Assignment_gne__c WHERE Id = :refId];
		String acc_ID = refAssList[0].Medical_Request_gne__r.Account_gne__c;
		List<Address_vod__c> addressList = [SELECT City_vod__c, State_vod__c FROM Address_vod__c WHERE Account_vod__c = :acc_ID AND Primary_vod__c = true LIMIT 1];

		String refName = refAssList[0].Name;
		String refLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + refId + '?email=1';
		String accName = refAssList[0].Medical_Request_gne__r.Account_gne__r.Name;
		String assName = refAssList[0].Assigned_To_gne__r.Name;
		String reqName = refAssList[0].Requested_By_gne__c;
		String isUrgent = priority == strUrgent ? '[Urgent]' : '';
		String city = '', state = '';

		if(addressList.size() == 1) {
			city = addressList[0].City_vod__c;
			state = addressList[0].State_vod__c;
		}

		if( updateType == strAcknowledged ) {
			return new List<String> { String.format( System.Label.Email_Template_Referral_Acknowledge_Status, new string []{ refName, accName, assName, reqName, city, state, refLink } ), 
				String.format( System.Label.Email_Template_Referral_Acknowledge_Status_Subject, new string []{ isUrgent, refName, accName, assName } ) };
	    } else if( updateType == strAssigned || updateType == strReassigned ) {
	    	return new List<String> { priority == strUrgent
	    		? String.format(System.Label.Email_Template_Referral_Assigned_Urgent_Status, new string []{ refName, accName, reqName, assName, city, state, refLink })
	    		: String.format(System.Label.Email_Template_Referral_Assigned_Status, new string []{ refName, accName, reqName, assName, city, state, refLink }), 
	    		String.format( System.Label.Email_Template_Referral_Assigned_Status_Subject, new string []{ isUrgent, refName, accName, reqName } ) };
	    } else if( updateType == strFulfilled ) {
	    	return new List<String> { String.format(System.Label.Email_Template_Referral_Fulfilled_Status, new string []{ refName, accName, assName, reqName, city, state, refLink }), 
	    		String.format( System.Label.Email_Template_Referral_Fulfilled_Status_Subject, new string []{ isUrgent, refName, accName, assName } ) };
		} else if( updateType == strClosedHCPUnresponsive || updateType == strClosedNotVerifiable || updateType ==  strClosedDuplicate ) {
	    	return new List<String> { String.format(System.Label.Email_Template_Referral_Closed_Status, new string []{ refName, accName, assName, reqName, city, state, refLink, updateType }), 
	    		String.format( System.Label.Email_Template_Referral_Closed_Status_Subject, new string []{ isUrgent, refName, accName, updateType } ) };
	    } else {
	    	return null;
	    }
    }
    
    public static Boolean isUSCSUser(){
        return GNE_SFA2_Util.getUserApplicationContext().App_Name_gne__c == 'SFA-US' && GNE_SFA2_Util.getUserApplicationContext().Role_gne__c == 'CS';
    }

    public static Boolean isCanadaUser(){
        return GNE_SFA2_Util.getUserApplicationContext().App_Name_gne__c == 'SFA-Canada';
    }
	
    public static Boolean isMCLorMSL(User user) {
    	return user != null && (
    		user.Profile_Name_gne__c == GNE_Referral_Utils.MCLProfile || 
    		user.Profile_Name_gne__c == GNE_Referral_Utils.MCLManagerProfile || 
    		user.Profile_Name_gne__c == GNE_Referral_Utils.MSLProfile || 
    		user.Profile_Name_gne__c == GNE_Referral_Utils.MSLManagerProfile
    	);
    }

    public static Id getMSLQueueId(String refQueue){
        Group MSLQueue=null;
        try{
            List<Group> lstMSLQueue = [SELECT Id,Name,Type FROM Group WHERE Name= :refQueue AND type= :strQueue LIMIT 1];
            if(lstMSLQueue.size() > 0){
                MSLQueue = lstMSLQueue[0];
            }else{
                return null;
            }
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching MSL Group' + ex));
            return null;
        }
        return MSLQueue.Id;
    }
    
    public static List<Id> getProductOwnerQueueId(List<String> prodQueueName){
        List<Id> productOwnerQueueId = new List<Id> ();
        try{
            List<Group> lstMSLQueue = [SELECT Id, Name, Type FROM Group WHERE Name in :prodQueueName AND Type= :strQueue];
            if(lstMSLQueue.size() > 0){
                for(Group objGrp: lstMSLQueue){
                    if(objGrp != null){
                        productOwnerQueueId.add(objGrp.Id);
                    }
                }
            }else{
                return null;
            }
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching Product Owner Group' + ex));
            return null;
        }
        return productOwnerQueueId;
    }
    
    public static Map<String,User> getUserData(List<String> userId){   
        List<User> lstUsers = new List<User> ();
        Map<String,User> mapUserId = new Map<String,User> ();
        try{
            lstUsers = [SELECT Id,Name,FirstName,LastName,IsActive,Profile_Name_gne__c, Email FROM User WHERE Id In :userId];
            if(lstUsers != null && lstUsers.size()>0){
                for( User objUser : lstUsers){
                    if(mapUserId != null && mapUserId.size() >0){
                        if(!mapUserId.containsKey((String)objUser.Id))
                        mapUserId.put((String)objUser.Id,objUser);
                    }else{
                        mapUserId.put((String)objUser.Id,objUser);
                    }
                }
            }
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching User Data' + ex));
            return null;
        }
        return mapUserId;
    }
    
    public static List<User> getRequestedByUser(String userName){
        try{
            if (userName != null && userName != ''){
                userName.Replace('*','%');
                userName='%'+userName+'%';
                List<User> myUsers = [SELECT Id, Name, isActive, Profile_Name_gne__c FROM User u WHERE Profile_name_gne__c like 'GNE-MCCO%' AND isActive= true AND Name like :userName order by name];
                if(myUsers.size()>0){
                    return myUsers;
                }
            }
        }catch (Exception ex){
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching getRequestedByUser' + ex));
            throw ex;            
        }
        return null; 
    }
    
    public static List<User> getAssignedUser(String userName,String callType){
        List<User> myUsers = new List<User>();
        List<Referral_Roster_gne__c> repRoster;
        
        try{
            if(!String.isEmpty(userName)){
                userName.Replace('*','%');
                userName='%'+userName+'%';
                if(callType == 'Create'){
                    repRoster = [SELECT Id,User_gne__c, User_gne__r.Name,User_gne__r.FirstName,User_gne__r.LastName,User_gne__r.Profile_Name_gne__c,Manager_gne__c, Manager_gne__r.Name,Manager_gne__r.FirstName,Manager_gne__r.LastName,Manager_gne__r.Profile_Name_gne__c FROM Referral_Roster_gne__c WHERE (User_gne__r.Profile_Name_gne__c = : MSLProfile or Manager_gne__r.Profile_Name_gne__c = : MSLProfile) AND  (User_gne__r.Name like :userName or Manager_gne__r.Name like :userName) order by user_gne__r.name];
                }else{
                    repRoster = [SELECT Id,User_gne__c, User_gne__r.Name,User_gne__r.FirstName,User_gne__r.LastName,User_gne__r.Profile_Name_gne__c,Manager_gne__c, Manager_gne__r.Name,Manager_gne__r.FirstName,Manager_gne__r.LastName,Manager_gne__r.Profile_Name_gne__c FROM Referral_Roster_gne__c WHERE (User_gne__r.Name like :userName or Manager_gne__r.Name like :userName) order by user_gne__r.name];
                }
                if(repRoster.size()>0){
                    List<Id> lstUserIds = new List<Id> ();
                    for(Referral_Roster_gne__c objRefRoster : repRoster){   
                        if(objRefRoster!=null && objRefRoster.User_gne__c != null && objRefRoster.Manager_gne__c != null){
                            lstUserIds.add(objRefRoster.User_gne__c);
                            lstUserIds.add(objRefRoster.Manager_gne__c);                            
                        }
                    }
                    if(lstUserIds.size() > 0){
                        if(callType == 'Create'){
                            myUsers = [SELECT Id, Name, isActive, Profile_Name_gne__c FROM User u WHERE Id in: lstUserIds AND Profile_name_gne__c= : MSLProfile AND isActive= true AND Name like :userName order by name];
                        }else{
                            myUsers = [SELECT Id, Name, isActive, Profile_Name_gne__c FROM User u WHERE Id in: lstUserIds AND isActive= true AND Name like :userName order by name];
                        }                       
                        if(myUsers.size()>0){
                            return myUsers;
                        }
                    }
                }else if(callType == 'Edit'){
                    myUsers = [SELECT Id, Name, isActive, Profile_Name_gne__c FROM User u WHERE isActive= true AND Name like :userName AND (Profile_Name_gne__c= :MSLManagerProfile or Profile_Name_gne__c= :SPManagerProfile or Profile_Name_gne__c= :SPProfile) order by name];                  
                    if(myUsers.size() > 0){
                        return myUsers;
                    }                                   
                }               
            }
        }catch (Exception ex){
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching getAssignedUser' + ex));
            throw ex;            
        }
        return null;            
    }

    public static Id getMCLManager(String userAlias){
        try{
            List<User> lstUsers = [SELECT Id, Alias, IsActive FROM User WHERE Alias= :userAlias AND IsActive = true LIMIT 1];
            if (lstUsers.size() >0){
                return lstUsers[0].Id;
            }
        }catch (Exception ex){
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching MCLManager' + ex));
            throw ex;            
        }
        return null;
    }
    
    public static Id getActiveUserId(Id userId){
        List<User> lstUser = [SELECT Id, Name, Profile_Name_gne__c,isActive FROM User WHERE Id= :userId AND isActive = true LIMIT 1];
        if (lstUser.size() >0){
            system.debug('lstUser: ' + lstUser);
            return lstUser[0].Id;
        }
        return null;
    }
    
    public static User getCurrentUser(Id userId){
        // Try to get value FROM cache
        if(usersCache.containsKey(userId)){
            return usersCache.get(userId);
        }
        try{
            List<User> lstUser = [SELECT Id, Name, Email, IsActive, Profile_Name_gne__c, Title, ManagerId, Manager.Email FROM User WHERE Id= :userId LIMIT 1];
            if(lstUser.size() >0){
                System.debug('lstUser: ' + lstUser);
                User currentUser = lstUser[0];
                System.debug('currentUser: --> ' + currentUser);
                if(currentUser.isActive){
                    usersCache.put(userId, currentUser);
                    return currentUser;
                }
            }
        }catch (Exception ex){
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching CurrentUser' + ex));
            throw ex;
        }
        return null;
    }
    
    public static String getUserNameAndRole(String userId){
        User objUser=getCurrentUser(userId);
        if(objUser != null){
            return objUser.Name + ',' + (GNE_SFA2_Util.isCanadaUser(objUser.Profile_Name_gne__c) && String.isNotBlank(objUser.Title) ? objUser.Title : objUser.Profile_Name_gne__c);
        }
        return '';
    }
    
    public static string serverURL{
        get{
            return System.URL.getSalesforceBaseUrl().toExternalForm();
        }
    }
    
    public static String getMedCommReferralSource(){
        String strProfileName=System.Label.GNE_MedComm_Profile;
        String strReferralSource='';
        Referral_Source_gne__c objReferralSource = [SELECT Id, Name, Profile_Name_gne__c, Source_Name_gne__c FROM Referral_Source_gne__c WHERE Profile_Name_gne__c= :strProfileName LIMIT 1];
        if(objReferralSource.Source_Name_gne__c != null){
            strReferralSource = objReferralSource.Source_Name_gne__c;
        }else{
            strReferralSource = strProfileName;
        }
        System.debug('strReferralSource: ' + strReferralSource);
        return strReferralSource;
    }
    
    public static String getReferralSource(Id requestedById){
        String strReferralSource='';
        User objUser = [SELECT Id, Name, Title, Profile_Name_gne__c, isActive FROM User WHERE Id= :requestedById AND isActive= true LIMIT 1];
        if (GNE_SFA2_Util.isCanadaUser(objUser.Profile_Name_gne__c)){
        	strReferralSource = String.isNotBlank(objUser.Title) ? objUser.Title : objUser.Profile_Name_gne__c;
        } else {
        	List<Referral_Source_gne__c> objReferralSource = [SELECT Id, Name, Profile_Name_gne__c, Source_Name_gne__c FROM Referral_Source_gne__c WHERE Profile_Name_gne__c= :objUser.Profile_Name_gne__c LIMIT 1];
        	if(objReferralSource.isEmpty()){
            	strReferralSource = objUser.Profile_Name_gne__c;
        	}else{
            	strReferralSource = objReferralSource.get(0).Source_Name_gne__c;
        	}
        }
        System.debug('strReferralSource: ' + strReferralSource);
        return strReferralSource;
    }
    
    public static Map<String, User> getUserEmailId(List<String> userId){   
        System.debug('userId:' + userId);
        Map<String,User> mapUserId = new Map<String,User> ();
        /******* get all email address related to Group *******/
        try{
            List<User> lstUsers = [SELECT Id, Name, FirstName, LastName, IsActive, Email FROM User WHERE Id In :userId AND IsActive= true];
            for(User objUser : lstUsers){
                if(!mapUserId.containsKey(objUser.Id)){
                    mapUserId.put(objUser.Id, objUser);
                }
            }
        }catch (Exception ex) {
            System.debug('Error on the page:' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while fetching Email Ids' + ex));
            return null;
        }
        return mapUserId;
    }
    
    public static List<String> getReferralAssignee(String refHistory){
        List<String> lstAssignee= new List<String> ();
        try{
            for (String refHist : refHistory.split(';')) {
                System.debug('refHist: ' + refHist);
                String[] lstSepRefAssRec = refHist.split(',');
                System.debug('lstSepRefAssRec.size(): ' + lstSepRefAssRec.size());
                if(lstSepRefAssRec.size()>4 && lstSepRefAssRec[4] != null && lstSepRefAssRec[1] != strStatusUpdate){
                    lstAssignee.add(lstSepRefAssRec[4]);
                }
            }
            if(lstAssignee.size()>0){
                return lstAssignee;
            }else{
                return null;
            }
        }catch(Exception ex){
            System.debug('Inside getReferralAssignee Catch Exception: ' + ex);
            throw ex;         
        }
    }
    
    public static Medical_Communication_gne__c getReferral(Id RefId){
        return [SELECT Account_gne__c, Account_Medcom_gne__c, Account_Referral_gne__c, Address_Line_1_gne__c, Assigned_To_gne__c, Assigned_To_Id_gne__c, Comments_Referral_gne__c, CreatedById, CreatedDate, Email_gne__c, Fax_gne__c, Follow_up_Method_gne__c, Id, Medical_Question_gne__c, Molecule_gne__c, Name, OwnerId, Phone_gne__c, Priority_gne__c, Product_gne__c, RecordTypeId, Referral_Assignment_gne__c, Referral_History_gne__c,  Requested_By_gne__c, Requested_Completion_Date_gne__c, 
                        Status_Referral_Date_gne__c, Status_Referral_Email_Date_gne__c, Status_Referral_Email_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c, Unsolicited_Request_Verified_By_gne__c, Unsolicited_Request_Verified_Date_gne__c 
                FROM Medical_Communication_gne__c WHERE id = :RefId LIMIT 1];
    }
    
    public static Referral_Assignment_gne__c getReferralAssignment(Id RefAssId){
        return [SELECT Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, Assigned_To_gne__r.Id, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id, Medical_Request_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c 
                FROM Referral_Assignment_gne__c WHERE Id= :RefAssId LIMIT 1];
    }
    
    public static String getReferralAssignmentStatusDate(String RefAssignmentId){
        Referral_Assignment_gne__c referralAssignment = [SELECT Id, Status_Referral_Date_gne__c FROM Referral_Assignment_gne__c WHERE Id= :RefAssignmentId LIMIT 1];
        return referralAssignment.Status_Referral_Date_gne__c.format(strDateFormat,strPST);
    }
    
    public static String getReferralAssignmentName(Id RefId){
        Referral_Assignment_gne__c referralAssignment = [SELECT Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id, Medical_Request_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c FROM Referral_Assignment_gne__c WHERE Id= :RefId LIMIT 1];
        return referralAssignment.Name;
    }
    
    public static Id getAssignedIncludingToT(Id assignedUserId) {
        Id newAssignedUserId = assignedUserId;
        String profileName = getCurrentUser(assignedUserId).Profile_Name_gne__c;
        if(profileName.equalsIgnoreCase(MSLProfile) || profileName.equalsIgnoreCase(MSLManagerProfile)) {
            System.debug('BOS:: Trying to find ToT for ' +assignedUserId);
            for (Time_Off_Territory_Day_gne__c totDayRec : [SELECT Time_Off_Territory_gne__r.Assigned_Referral_Activity_gne__c
                                                            FROM Time_Off_Territory_Day_gne__c
                                                            WHERE Date_gne__c = :getNearestWorkingDay() AND Time_Off_Territory_gne__c IN 
                                                            (SELECT ID FROM Time_Off_Territory_gne__c WHERE OwnerId = :assignedUserId AND Assigned_Referral_Activity_gne__c <> null)
                                                            LIMIT 1]) {
                System.debug('BOS:: Switching to new Referral FROM ' + assignedUserId + ' to ' + totDayRec.Time_Off_Territory_gne__r.Assigned_Referral_Activity_gne__c);
                newAssignedUserId = totDayRec.Time_Off_Territory_gne__r.Assigned_Referral_Activity_gne__c;
            }
        }
        return newAssignedUserId;
    }
    
    public static Date getNearestWorkingDay() {
        if(nearestWorkingDay != null){
            return nearestWorkingDay;
        }
        AggregateResult[] nearestWorkingDayData = [SELECT Min(Date_gne__c) Date_gne__c FROM Actual_Working_Days_gne__c WHERE Date_gne__c=TODAY OR Date_gne__c = NEXT_N_DAYS:30];
        nearestWorkingDay = DateTime.now().dateGmt();
        if(!nearestWorkingDayData.isEmpty()) {
            nearestWorkingDay = (Date)nearestWorkingDayData[0].get('Date_gne__c');
        }
        return nearestWorkingDay;
    }
    
    public static String getPreviousAssignedUserId(Referral_Assignment_gne__c refAssignment) {
        String prevUserId = null;
        String historyText = refAssignment.Medical_Request_gne__r.Referral_History_gne__c;
        if(historyText==null){
            return prevUserId;
        }
        String[] refHistoryRecords = historyText.split(';');
        String lastAssignedId = null;      
        for(Integer i = refHistoryRecords.size()-1; i>=0; i--) {
            String[] refHistValues = refHistoryRecords[i].split(',');
            if(refHistValues.size() > 4) {
                String assignedId = refHistValues[4];
                if(lastAssignedId==null) {
                    lastAssignedId=assignedId;
                } else if(!assignedId.equals(lastAssignedId)) {
                    prevUserId=assignedId;
                    break;
                }
            }
        }
        return prevUserId;
    }
    
    public static String createHistoryInfo(String strStatus, String strAssignedUserName, ID strAssignedUserId, String strAssignedUserRole) {
        String dateTimeText = datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST);
        return createHistoryInfo(dateTimeText, strStatus, strAssignedUserName, strAssignedUserId, strAssignedUserRole);
    }
    
    public static String createHistoryInfo(String dateTimeText, String strStatus, String strAssignedUserName, ID strAssignedUserId, String strAssignedUserRole) {
        return dateTimeText + ',' + strStatus + ',' + UserInfo.getName() + ',' + strAssignedUserName + ',' + (String)strAssignedUserId + ',' + strAssignedUserRole + ',' + (GNE_SFA2_Util.isCanadaUser() ? strStatus : GNE_Referral_Utils.strAssigned) + ';';
    }
    
    public static String createHistoryInfo(String dateTimeText, String strAction, String strAssignedUserName, ID strAssignedUserId, String strAssignedUserRole, String strStatus) {
        return dateTimeText + ',' + strAction + ',' + UserInfo.getName() + ',' + strAssignedUserName + ',' + (String)strAssignedUserId + ',' + strAssignedUserRole + ',' + strStatus + ';';
    }

    public static String createCommentsInfo(String dateTimeText, String strComment, String prevStrComment) {
        String lineDelimeter = ',#,';
        String cellDelimeter = ',@,';
        String result = dateTimeText + cellDelimeter + strComment + cellDelimeter + UserInfo.getName() + lineDelimeter;
        if (String.isNotBlank(prevStrComment)){
            result += prevStrComment + lineDelimeter;
        }
        return result;
    }
}