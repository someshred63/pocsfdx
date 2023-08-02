public without sharing class iPhoneApexUtil
{


    //constant values for error messages
    static final String DISBURSEMENT_INVALID_ATTENDEE              = 'Invalid Attendee';
    static final String DISBURSEMENT_INVALID_SIGNATURE              = 'Invalid Signature';
    static final String DISBURSEMENT_INVALID_SIGNATURE_DATE         = 'Invalid Signature Date';
    static final String DISBURSEMENT_INVALID_SAMPLE                 = 'Invalid Sample';
    static final String DISBURSEMENT_INVALID_SAMPLE_FOR_RECIEVER    = 'Invalid Sample for sample reciever';
    static final String DISBURSEMENT_INVALID_LOT                    = 'Invalid Lot';
    static final String DISBURSEMENT_INVALID_QUANTITY               = 'Invalid Quantity';
    static final String DISBURSEMENT_INVALID_PRODUCT                = 'Invalid Product';
    static final String DISBURSEMENT_INVALID_ACCOUNT                = 'Invalid Account';
    static final String DISBURSEMENT_INVALID_ADDRESS                = 'Invalid Address';
    static final String DISBURSEMENT_INVALID_LICENSE                = 'Invalid License';
    static final String DISBURSEMENT_INVALID_LICENSE_TO_ADDRESS     = 'Invalid License to Address';
    static final String DISBURSEMENT_LICENSE_NOT_MATCH_ACCOUNT      = 'License does not match Account';
    static final String DISBURSEMENT_LICENSE_NOT_MATCH_ADDRESS_STATE= 'Licence doen not match Address State';
    static final String DISBURSEMENT_LICENSE_NOT_VALID_TO_SAMPLE    = 'Licence not valid to sample';
    static final String DISBURSEMENT_LICENSE_EXPIRED                = 'Licence expired';
    static final String DISBURSEMENT_SIGNATURE_PARAMATERS           = 'Invalid Signature Paramenters';
    static final String DISBURSEMENT_SIGNATURE_DATE                 = 'Invalid Signature Date';
    static final String DISBURSEMENT_SIGNATURE_DISCLAIMER           = 'Invalid Signature Disclaimer';
    static final String DISBURSEMENT_SIGNATURE_LICENSENUMBER        = 'Invalid Signature LicenseNumber';
    static final String DISBURSEMENT_INVALID_SAMPLERECIEVER         = 'Invalid Sample Reciever';

    static final String REQUESTID_VALENG_PREFIX_FOR_MAIN_CALL = 'Valeng_INT';
    static final String REQUESTID_VALENG_PREFIX_FOR_ATTENDEE  = 'Valeng_ATT';
    static final String REQUESTID_VALENG_PREFIX_FOR_SAMPLE    = 'Valeng_SAM';
    static final String REQUESTID_VALENG_PREFIX_FOR_DETAIL    = 'Valeng_DET';
    static final String REQUESTID_VALENG_PREFIX_FOR_DISCUSSION= 'Valeng_DISC';

    static final String NonProduct_NonMolecule= 'Non-Product/Non-Molecule';

    public static Boolean ignoreValidationTrigger = false;

    public class MyException extends Exception {}




    // Get List of Territories assigned to the logged in User
    public static String getUserTerritoryId(String CallUserId, String CallAcountId)
    {
        //If user exists in only one territory then assign user territory to call2_vod__c.teritory_vod__c
        //if user does not exist in any territory then do nothing
        //if user exists in more than one terrirory then get the account's territories and
        //assign the intersection of user and account teritory to call2_vod__c.teritory_vod__c
        String territoryId;
        String territoryName;
        List<String> userTerritoryList = new List<String>();

        try
        {

            for (UserTerritory2Association u: [Select ut.Territory2Id
                                      from UserTerritory2Association ut
                                      Where ut.UserId = :CallUserId])
                   userTerritoryList.add(u.Territory2Id);

            if (userTerritoryList.size() == 0){
                //do nothing
            }
            else if (userTerritoryList.size() == 1){
                territoryId = userTerritoryList.get(0);
            }
            else if (userTerritoryList.size() > 1)
            {
              if(CallAcountId!=null)
              {
                  // Get GroupId of Account
                  List<String> Account_GroupList = new List<String>();
                  try
                  {
                    for (AccountShare a: [ select UserOrGroupId
                                          from AccountShare
                                          where accountId = :CallAcountId])
                        Account_GroupList.add(a.UserOrGroupId) ;
                  }
                  catch(Exception ex){
                    //do nothing
                  }

                  if (Account_GroupList.size() > 0 ){
                  // get common Territory list for from_account and user

                    Group g;
                    try{
                        g= [Select RelatedId, ID
                                  from Group
                                  where Id in :Account_GroupList
                                        and   Type = 'Territory'
                                        and RelatedId in :userTerritoryList limit 1];
                        territoryId = g.relatedId;
                    }
                    catch(Exception ex){
                        //do nothing
                    }

                    if(g!=null )
                    {
                        territoryId = g.relatedId;
                    }
                    else
                    {
                        territoryId = userTerritoryList.get(0);
                    }
                  }
                  else
                  {
                     territoryId = userTerritoryList.get(0);
                  }
              }
              else //if accountId is null then assign the first user territory to call2_vod__c.territory_vod__c
              {
                territoryId = userTerritoryList.get(0);
              }
            }

            if (territoryId != null){
                    territoryName = [Select name
                                            from Territory2
                                            Where id = :territoryId limit 1].name;
            }
        }
        catch(Exception ex)
        {
            //do nothing
        }

        return territoryName;

    }

    /////////////////////////////Merge Account methods////////////////////////////////////
    //create and return a list of acountIds passed to iPhoneApex to later get their merged acoount Ids

    public static List<String> AccountIdsFromCallAttribute(iPhoneApex.CallAttributes callAttributes)
    {

        List<String> acctIds = new List<String>();

        if(callAttributes.Account!=null){
            acctIds.add(callAttributes.Account);
        }

        if ( callAttributes.CallAttendeeList != null &&
            callAttributes.CallAttendeeList.size() > 0 ) {
            List<Call2_vod__c> attendees    = new List<Call2_vod__c>();
            List<String> inputRequestIdList = new List<String>();

            for ( iPhoneApex.CallAttendee attendee : callAttributes.CallAttendeeList ){
                    if(attendee.Attendee!=null){
                        acctIds.add(attendee.Attendee);
                    }

            }
         }

         if ( callAttributes.callSampleList != null &&
            callAttributes.callSampleList.size() > 0 ) {
            for ( iPhoneApex.CallSample callSample : callAttributes.callSampleList ) {

                acctIds.add(callSample.Account);
            }
         }

        return acctIds;
    }


    //create and return map(accounts to their merged acountId) for merged acounts
    public static Map<String, String> findMergedAccounts (List<String> acctIds)
    {
        //AcctToMergedAcctList clsAcctToMergedAcctList = new AcctToMergedAcctList();
        //clsAcctToMergedAcctList.ListMergeAccts = new List<AcctToMergedAcct>();
        Map<String, String> mapAcctToMergedAcct = new Map<String, String>();
        List<Account> objAcct = new List<Account>();

        try{
            //objAcct=[SELECT Id, Name, isDeleted, MasterRecordId FROM Account WHERE Id IN : acctIds ALL ROWS];
            objAcct=[SELECT Id, Name, DCH_Previous_Id_gne__c, DCH_Parent_Id_gne__c FROM Account WHERE DCH_Parent_Id_gne__c!=null AND DCH_Action_gne__c='Merge (Loser)' AND DCH_Previous_Id_gne__c IN : acctIds];
        }
        catch(Exception ex){
            //do nothing
        }

        if(objAcct.size()>0){
            for(Account act : objAcct){
                //if(act.isDeleted==true && act.MasterRecordId!=null)   {
                    mapAcctToMergedAcct.put(act.DCH_Previous_Id_gne__c, act.DCH_Parent_Id_gne__c);
                    //AcctToMergedAcct acctMergrd = new AcctToMergedAcct();
                    //acctMergrd.PreviousId = act.DCH_Previous_Id_gne__c;
                    //acctMergrd.ParentId = act.DCH_Parent_Id_gne__c;

                    //clsAcctToMergedAcctList.ListMergeAccts.add(acctMergrd);
                //}
            }
        }

        //return clsAcctToMergedAcctList;
        return mapAcctToMergedAcct;
    }


    //create and return map(AddressId to their Merged AdressId) for merged Addreses
    public static Map<String, String> findMergedAddresses (List<String> addrIds)
    {
        Map<String, String> mapAddrToMergedAAddr = new Map<String, String>();
        List<Address_vod__c> objAddr ;

        try{
            //objAcct=[SELECT Id, Name, isDeleted, MasterRecordId FROM Account WHERE Id IN : acctIds ALL ROWS];
            objAddr=[SELECT Id, Name, DCH_Action_gne__c, DCH_Parent_Id_gne__c, DCH_Previous_Id_gne__c from Address_vod__c a WHERE DCH_Parent_Id_gne__c!=null AND DCH_Action_gne__c='Merge (Loser)' AND DCH_Previous_Id_gne__c IN : addrIds];
        }
        catch(Exception ex){
            //do nothing
        }

        if(objAddr!=null && objAddr.size()>0){
            for(Address_vod__c adr : objAddr){
                mapAddrToMergedAAddr.put(adr.DCH_Previous_Id_gne__c, adr.DCH_Parent_Id_gne__c);
            }
        }
        return mapAddrToMergedAAddr;
    }
    /////////////////////////////Ends Merge Account methods////////////////////////////////////



    public static void validateInteractionsFuture(iPhoneApex.CallAttributes callAttributes, String callId)
    {
        Map<String, Map<String, String>> callAttributesValidateMap = new Map<String, Map<String, String>>();
        Map<String, String> callAttribValidateMap = new Map<String, String>();
        Map<String, String> callAttendeeValidateMap = new Map<String, String>();
        Map<String, String> callSampleValidateMap = new Map<String, String>();
        callAttributesValidateMap = convertCallAtributesToMap(callAttributes);
        callAttribValidateMap = callAttributesValidateMap.get('callAttributes');
        callAttendeeValidateMap = callAttributesValidateMap.get('CallAttendee');
        callSampleValidateMap = callAttributesValidateMap.get('CallSample');

        ValidateSampleFuture(callAttribValidateMap, callAttendeeValidateMap, callSampleValidateMap, callId );
    }


    //convert callattributes to corresponding list and string representation to send to future method
    static Map<String, Map<String, String>> convertCallAtributesToMap(iPhoneApex.CallAttributes callAttributes)
    {
        Map<String, Map<String, String>> callAttributesMap = new Map<String, Map<String, String>>();

        Map<String, String> callAttribMap = new Map<String, String>();
        Map<String, String> callAttendeeMap = new Map<String, String>();
        Map<String, String> callSampleMap = new Map<String, String>();

        Integer cnt =1;
        if(callAttributes.CallAttendeeList!=null)
        {
            for( iPhoneApex.CallAttendee attendee : callAttributes.CallAttendeeList )
            {

                String joinAttendeeAttrib = '';

                if(attendee.Attendee!=null)
                {
                    joinAttendeeAttrib=attendee.Attendee;
                }
                else
                {
                    joinAttendeeAttrib='';
                }
                joinAttendeeAttrib = joinAttendeeAttrib + '::';

                if(attendee.RequestId!=null)
                {
                    joinAttendeeAttrib=joinAttendeeAttrib + attendee.RequestId;
                }
                else
                {
                    joinAttendeeAttrib=joinAttendeeAttrib + '';
                }
                joinAttendeeAttrib = joinAttendeeAttrib + '::';

                if(attendee.CallAttendeeType!=null)
                {
                    joinAttendeeAttrib=joinAttendeeAttrib + attendee.CallAttendeeType.Name();
                }
                else
                {
                    joinAttendeeAttrib=joinAttendeeAttrib + '';
                }


                //joinAttendeeAttrib = attendee.Attendee + '^' + attendee.RequestId + '^' + attendee.CallAttendeeType.Name();
                callAttendeeMap.put(String.valueOf(cnt), joinAttendeeAttrib);
                cnt++;
            }
        }


        cnt =1;
        if(callAttributes.callSampleList!=null)
        {
            for ( iPhoneApex.CallSample callSample : callAttributes.callSampleList )
            {

                String joinSampleAttrib = '';

                if(callSample.Product!=null)
                {
                    joinSampleAttrib=callSample.Product;
                }
                else
                {
                    joinSampleAttrib='';
                }
                joinSampleAttrib = joinSampleAttrib + '::';

                if(callSample.Account!=null)
                {
                    joinSampleAttrib=joinSampleAttrib + callSample.Account;
                }
                else
                {
                    joinSampleAttrib=joinSampleAttrib + '';
                }
                joinSampleAttrib = joinSampleAttrib + '::';

                if(callSample.RequestId!=null)
                {
                    joinSampleAttrib=joinSampleAttrib + callSample.RequestId;
                }
                else
                {
                    joinSampleAttrib=joinSampleAttrib + '';
                }
                joinSampleAttrib = joinSampleAttrib + '::';


                if(callSample.LotNo!=null)
                {
                    joinSampleAttrib=joinSampleAttrib + callSample.LotNo;
                }
                else
                {
                    joinSampleAttrib=joinSampleAttrib + '';
                }
                joinSampleAttrib = joinSampleAttrib + '::';

                if(callSample.Quantity!=null)
                {
                    joinSampleAttrib=joinSampleAttrib + String.valueOf(callSample.Quantity);
                }
                else
                {
                    joinSampleAttrib=joinSampleAttrib + '';
                }

                //joinSampleAttrib =  callSample.Product + '^' + callSample.Account + '^' + callSample.LotNo  + '^' + String.valueOf(callSample.Quantity) ;
                callSampleMap.put(String.valueOf(cnt), joinSampleAttrib);
                cnt++;

            }
        }


        if(callAttributes.id!=null)
        {
            callAttribMap.put('Id', callAttributes.id);
        }
        if(callAttributes.Account!=null)
        {
            callAttribMap.put('Account', callAttributes.Account);
        }
        if(callAttributes.Address!=null)
        {
            callAttribMap.put('Address', callAttributes.Address);
        }
        if(callAttributes.AddressText!=null)
        {
            callAttribMap.put('AddressText', callAttributes.AddressText);
        }
        if(callAttributes.InteractionType!=null)
        {
            callAttribMap.put('InteractionType', callAttributes.InteractionType);
        }
        if(callAttributes.RequestId!=null)
        {
            callAttribMap.put('RequestId', callAttributes.RequestId);
        }
        if(callAttributes.BusinessSponsor!=null)
        {
            callAttribMap.put('BusinessSponsor', callAttributes.BusinessSponsor);
        }
        if(callAttributes.MealLocationCity!=null)
        {
            callAttribMap.put('MealLocationCity', callAttributes.MealLocationCity);
        }
        if(callAttributes.MealLocationState!=null)
        {
            callAttribMap.put('MealLocationState', callAttributes.MealLocationState);
        }
        if(callAttributes.SpendUser!=null)
        {
            callAttribMap.put('SpendUser', callAttributes.SpendUser);
        }
        if(callAttributes.OwnerId!=null)
        {
            callAttribMap.put('OwnerId', callAttributes.OwnerId);
        }
        if(callAttributes.id!=null)
        {
            callAttribMap.put('Id', callAttributes.id);
        }
        if(callAttributes.TerritoryName!=null)
        {
            callAttribMap.put('TerritoryName', callAttributes.TerritoryName);
        }

        if(callAttributes.CallAttendeeType!=null)
        {
            callAttribMap.put('CallAttendeeType', callAttributes.CallAttendeeType.Name());
        }

        if(callAttributes.NumOfCustomersPresent!=null)
        {
            callAttribMap.put('NumOfCustomersPresent', String.valueOf(callAttributes.NumOfCustomersPresent));
        }

        if(callAttributes.MealPlannedAttendeeCount!=null)
        {
            callAttribMap.put('MealPlannedAttendeeCount', String.valueOf(callAttributes.MealPlannedAttendeeCount));
        }

        if(callAttributes.MealActualAttendeeCount!=null)
        {
            callAttribMap.put('MealActualAttendeeCount', String.valueOf(callAttributes.MealActualAttendeeCount));
        }

        if(callAttributes.MealAmount!=null)
        {
            callAttribMap.put('MealAmount', String.valueOf(callAttributes.MealAmount));
        }

        if(callAttributes.CallDateTime !=null)
        {
            callAttribMap.put('CallDateTime', callAttributes.CallDateTime.format('yyyy-MM-dd HH:mm:ss.sss'));
        }

        if(callAttributes.IsComplete!=null)
        {
            callAttribMap.put('IsComplete', String.valueOf(callAttributes.IsComplete));
        }

        if(callAttributes.isOtrRequest!=null)
        {
            callAttribMap.put('isOtrRequest', String.valueOf(callAttributes.isOtrRequest));
        }

        if(callAttributes.ContractedServices!=null)
        {
            callAttribMap.put('ContractedServices', String.valueOf(callAttributes.ContractedServices));
        }

        if(callAttributes.ValidationEngine!=null)
        {
            callAttribMap.put('ValidationEngine', String.valueOf(callAttributes.ValidationEngine));
        }

        //sampleable fields
        if(callAttributes.Signature!=null)
        {
            callAttribMap.put('Signature', callAttributes.Signature);
        }
        if(callAttributes.Disclaimer!=null)
        {
            callAttribMap.put('Disclaimer', callAttributes.Disclaimer);
        }
        if(callAttributes.SampleReceiver!=null)
        {
            callAttribMap.put('SampleReceiver', callAttributes.SampleReceiver);
        }
        if(callAttributes.LicenseNumber!=null)
        {
            callAttribMap.put('LicenseNumber', callAttributes.LicenseNumber);
        }
        if(callAttributes.SignatureDate !=null)
        {
            callAttribMap.put('SignatureDate', callAttributes.SignatureDate.format('yyyy-MM-dd HH:mm:ss.sss'));
        }

        callAttributesMap.put('callAttributes', callAttribMap);
        callAttributesMap.put('CallAttendee', callAttendeeMap);
        callAttributesMap.put('CallSample', callSampleMap);

        return callAttributesMap;
    }


    @future
    public static void ValidateSampleFuture(Map<String, String> CallAttribs, Map<String, String> callAttends, Map<String, String> callSamples, Id callId)
    {
        //errMessage='';
        //converts map parameters to CaalAttribute object
        iPhoneApex.CallAttributes callAttributes = new iPhoneApex.CallAttributes();

        if(CallAttribs.containsKey('Id'))
        {
            callAttributes.Id = CallAttribs.get('Id');
        }
        if(CallAttribs.containsKey('Account'))
        {
            callAttributes.Account = CallAttribs.get('Account');
        }
        if(CallAttribs.containsKey('Address'))
        {
            callAttributes.Address = CallAttribs.get('Address');
        }
        if(CallAttribs.containsKey('AddressText'))
        {
            callAttributes.AddressText = CallAttribs.get('AddressText');
        }
        if(CallAttribs.containsKey('InteractionType'))
        {
            callAttributes.InteractionType = CallAttribs.get('InteractionType');
        }
        if(CallAttribs.containsKey('RequestId'))
        {
            callAttributes.RequestId = CallAttribs.get('RequestId');
        }
        if(CallAttribs.containsKey('BusinessSponsor'))
        {
            callAttributes.BusinessSponsor = CallAttribs.get('BusinessSponsor');
        }
        if(CallAttribs.containsKey('MealLocationCity'))
        {
            callAttributes.MealLocationCity = CallAttribs.get('MealLocationCity');
        }
        if(CallAttribs.containsKey('MealLocationState'))
        {
            callAttributes.MealLocationState = CallAttribs.get('MealLocationState');
        }
        if(CallAttribs.containsKey('SpendUser'))
        {
            callAttributes.SpendUser = CallAttribs.get('SpendUser');
        }
        if(CallAttribs.containsKey('TerritoryName'))
        {
            callAttributes.TerritoryName = CallAttribs.get('TerritoryName');
        }

        if(CallAttribs.containsKey('MealPlannedAttendeeCount'))
        {
            callAttributes.MealPlannedAttendeeCount = Integer.valueOf(CallAttribs.get('MealPlannedAttendeeCount'));
        }
        if(CallAttribs.containsKey('MealPlannedAttendeeCount'))
        {
            callAttributes.MealPlannedAttendeeCount = Integer.valueOf(CallAttribs.get('MealPlannedAttendeeCount'));
        }
        if(CallAttribs.containsKey('MealActualAttendeeCount'))
        {
            callAttributes.MealActualAttendeeCount = Integer.valueOf(CallAttribs.get('MealActualAttendeeCount'));
        }
        if(CallAttribs.containsKey('NumOfCustomersPresent'))
        {
            callAttributes.NumOfCustomersPresent = Integer.valueOf(CallAttribs.get('NumOfCustomersPresent'));
        }
        if(CallAttribs.containsKey('MealAmount'))
        {
            callAttributes.MealAmount = Double.valueOf(CallAttribs.get('MealAmount'));
        }
        if(CallAttribs.containsKey('CallDateTime'))
        {
            callAttributes.CallDateTime = DateTime.valueOf(CallAttribs.get('CallDateTime'));
        }
        if(CallAttribs.containsKey('IsComplete'))
        {
            if(CallAttribs.get('IsComplete').toUpperCase()=='false'.toUpperCase())
                callAttributes.IsComplete = false;
            else if(CallAttribs.get('IsComplete').toUpperCase()=='true'.toUpperCase())
                callAttributes.IsComplete = true;
        }

        if(CallAttribs.containsKey('isOtrRequest'))
        {
            if(CallAttribs.get('isOtrRequest').toLowerCase()=='false')
                callAttributes.isOtrRequest = false;
            else if(CallAttribs.get('isOtrRequest').toLowerCase()=='true')
                callAttributes.isOtrRequest = true;
        }

        if(CallAttribs.containsKey('ContractedServices'))
        {
            if(CallAttribs.get('ContractedServices').toUpperCase()=='false'.toUpperCase())
                callAttributes.ContractedServices = false;
            else if(CallAttribs.get('ContractedServices').toUpperCase()=='true'.toUpperCase())
                callAttributes.ContractedServices = true;
        }

        if(CallAttribs.containsKey('Signature'))
        {
            callAttributes.Signature = CallAttribs.get('Signature');
        }
        if(CallAttribs.containsKey('Disclaimer'))
        {
            callAttributes.Disclaimer = CallAttribs.get('Disclaimer');
        }
        if(CallAttribs.containsKey('SampleReceiver'))
        {
            callAttributes.SampleReceiver = CallAttribs.get('SampleReceiver');
        }
        if(CallAttribs.containsKey('LicenseNumber'))
        {
            callAttributes.LicenseNumber = CallAttribs.get('LicenseNumber');
        }
        if(CallAttribs.containsKey('SignatureDate'))
        {
            callAttributes.SignatureDate = DateTime.valueOf(CallAttribs.get('SignatureDate'));
        }

        if(CallAttribs.containsKey('ValidationEngine'))
        {
            if(CallAttribs.get('ValidationEngine').toUpperCase()=='false'.toUpperCase())
                callAttributes.ValidationEngine = false;
            else if(CallAttribs.get('ValidationEngine').toUpperCase()=='true'.toUpperCase())
                callAttributes.ValidationEngine = true;
        }

        if(CallAttribs.containsKey('CallAttendeeType'))
        {
            if(CallAttribs.get('CallAttendeeType') == 'PERSONACCOUNT')
            {
                callAttributes.CallAttendeeType = iPhoneApex.AttendeeType.PERSONACCOUNT;
            }
            else if(CallAttribs.get('CallAttendeeType') == 'ACCOUNT')
            {
                callAttributes.CallAttendeeType = iPhoneApex.AttendeeType.ACCOUNT;
            }
            else if(CallAttribs.get('CallAttendeeType') == 'CONTACT')
            {
                callAttributes.CallAttendeeType = iPhoneApex.AttendeeType.CONTACT;
            }
            else if(CallAttribs.get('CallAttendeeType') == 'USER')
            {
                callAttributes.CallAttendeeType = iPhoneApex.AttendeeType.USER;
            }
        }


        //add attendee list to call attributes
        callAttributes.callAttendeeList = new List<iPhoneApex.CallAttendee>();
        for(String att : callAttends.keySet())
        {
            iPhoneApex.CallAttendee callAtt = new iPhoneApex.CallAttendee();
            String attString = callAttends.get(att);
            List<String> attArray = attString.split('::');
            if(attArray.size()>0)
            {
                if(attArray[0]!=null && attArray[0]!='')
                {
                    callAtt.Attendee = attArray[0];
                }
                if(attArray[1]!=null && attArray[1]!='')
                {
                    callAtt.RequestId = attArray[1];
                }

                if(attArray[2]!=null &&  attArray[2]!='')
                {
                    if(attArray[2] == iPhoneApex.AttendeeType.PERSONACCOUNT.Name())
                        callAtt.CallAttendeeType = iPhoneApex.AttendeeType.PERSONACCOUNT;
                    else if(attArray[2] == iPhoneApex.AttendeeType.ACCOUNT.Name())
                        callAtt.CallAttendeeType = iPhoneApex.AttendeeType.ACCOUNT;
                }
                callAttributes.callAttendeeList.add(callAtt);
            }
            //callAtt
        }

        //sample list to callattibutes
        callAttributes.callSampleList = new List<iPhoneApex.CallSample>();
        for(String sam : callSamples.keySet())
        {
            iPhoneApex.CallSample callSam = new iPhoneApex.CallSample();
            String samString = callSamples.get(sam);
            List<String> samArray = samString.split('::');

            //errMessage = errMessage + ' : ' + String.valueOf(samArray.size());
            //return ;

            if(samArray.size()>0)
            {
                if(samArray[0]!=null && samArray[0]!='')
                {
                    callSam.Product = samArray[0];
                }
                if(samArray[1]!=null && samArray[1]!='')
                {
                    callSam.Account = samArray[1];
                }
                if(samArray[2]!=null && samArray[2]!='')
                {
                    callSam.RequestId = samArray[2];
                }

                if(samArray[3]!=null && samArray[3]!='')
                {
                    callSam.LotNo = samArray[3];
                }
                if(samArray[4]!=null && samArray[4]!='')
                {
                    callSam.Quantity = Double.valueOf(samArray[4]);
                }

                callAttributes.callSampleList.add(callSam);
            }
        }

        ValidateSample(callAttributes, callId);

    }




    ////////////////////////////////////////Sample Disbursement methods////////////////////////////////
    //Validates Sample signatue. Calls EvaluateSampleIssues to evaluate Issues and create an Issue List
    //The Issue list is then inserted to create Disbursement issues
    public static void ValidateSample(iPhoneApex.CallAttributes callAttributes, Id callId)
    {
        List<Disbursement_Issue_gne__c> disbursementIssues = new List<Disbursement_Issue_gne__c>();

        try{
            EvaluateSampleIssues(callAttributes, disbursementIssues);

            if(disbursementIssues.size()>0)
            {
                if(callId!=null) //update call id of interaction created
                {
                    for(Disbursement_Issue_gne__c disb : disbursementIssues)
                    {
                        disb.call_gne__c = callId;
                    }
                }

                insert disbursementIssues;
            }
        }
        catch(Exception ex){
            //do nothing as this method runs independently of the calling method
        }
    }



    //@future
    //static void futureTest(List<Map<String, String>> lst, Map<String, String> mapCall, Map<String, String> mapCall1, Map<String, String> mapCall2)
    //{

    //}

    //method to validate sample signature and log disbursement issue
    static void EvaluateSampleIssues(iPhoneApex.CallAttributes callAttributes, List<Disbursement_Issue_gne__c> disbursementIssues)
    {
        Map<Id, Address_vod__c> addressVod = new Map<Id, Address_vod__c>();
        Map<String, Address_vod__c> stateMedLicence = new Map<String, Address_vod__c>();
        String sampleReciever;
        String CallOwnerId;

        //get userId to stamp call owner
        if(callAttributes.OwnerId!=null)
        {
            CallOwnerId=callAttributes.OwnerId;
        }
        else
        {
            CallOwnerId = UserInfo.getUserId();
        }



        //if Signature is passed then perform validations
        if ( callAttributes.Signature != null || callAttributes.SignatureDate!=null || callAttributes.Disclaimer!=null || callAttributes.LicenseNumber!=null)
        {
            //validate Signature parameters
            if(callAttributes.Signature==null)
            {
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_SIGNATURE, null, null, null );
                //return;
            }
            if(callAttributes.SignatureDate==null)
            {
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_SIGNATURE_DATE, null, null, null );
                //return;
            }
            else if(callAttributes.Disclaimer==null)
            {
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_SIGNATURE_DISCLAIMER, null, null, null );
                //return;
            }
            else if(callAttributes.LicenseNumber==null)
            {
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_SIGNATURE_LICENSENUMBER, null, null, null );
                //return;
            }


            boolean isMainCallHCO=false;
            if ( callAttributes.CallAttendeeType == iPhoneApex.AttendeeType.ACCOUNT )
            {
                if(callAttributes.SampleReceiver!=null){
                    sampleReciever = callAttributes.SampleReceiver;
                }
                isMainCallHCO=true;
            }
            else if(callAttributes.CallAttendeeType == iPhoneApex.AttendeeType.PERSONACCOUNT)
            {
                if(callAttributes.SampleReceiver!=null){
                    sampleReciever = callAttributes.SampleReceiver;
                }
                else
                {
                    sampleReciever = callAttributes.Account;
                }
            }


            //////validate account//////
            if(callAttributes.Account!=null)
            {
                Account objAccount ;
                if(sampleReciever!=null)
                {
                    objAccount = [SELECT Id, Name, (SELECT Id, Name, License_vod__c, License_Expiration_Date_vod__c, Designation_gne__c, License_Status_vod__c, State_vod__c FROM Address_Vod__r) FROM Account WHERE ID = : sampleReciever];
                }

                if(objAccount!=null)
                {
                    for(Address_vod__c addrV: objAccount.Address_Vod__r )
                    {
                        addressVod.put(addrV.Id, addrV);
                    }
                    for(Address_vod__c StateL: objAccount.Address_Vod__r )
                    {
                        stateMedLicence.put(StateL.License_vod__c, StateL); //to confirm if there will always be one license number per state else need to modify here
                    }
                }
                if(isMainCallHCO) //if HCP call then validate that callAttributes.SampleReceiver is an attendee
                {
                    boolean recieverExistsAsAttendee=false;
                    if(callAttributes.CallAttendeeList!=null && callAttributes.CallAttendeeList.size()>0)
                    {
                        for ( iPhoneApex.CallAttendee attendee : callAttributes.CallAttendeeList )
                        {
                            if(callAttributes.SampleReceiver == attendee.Attendee )
                            {
                                recieverExistsAsAttendee=true;
                            }
                        }
                        if(!recieverExistsAsAttendee)
                        {
                            CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_SAMPLERECIEVER, null, null, null);
                        }
                    }
                    else
                    {
                        CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_ATTENDEE, null, null, null);
                    }
                }
            }
            else
            {
                //log Issue - Invalid Account
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_ACCOUNT, null, null, null);
                return;
            }



            //////validate address//////
            if(callAttributes.Address!=null)
            {
                if(!addressVod.containsKey(callAttributes.Address))
                {
                    //log Issue - Invalid Address
                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_ADDRESS, null, null, null );
                    return ;
                }
            }
            else
            {
                //log Issue - Invalid Address
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_ADDRESS, null, null, null );
                return;
            }

            ////////validate if incoming call is a sample call and the call has a sample attached to it//////
            if(callAttributes.SampleReceiver!=null)
            {
                boolean isSamplePresent = false;
                for ( iPhoneApex.CallSample callSample : callAttributes.callSampleList )
                {
                    if(callSample.Account == sampleReciever) //get product ids for sample products
                    {
                        isSamplePresent=true;
                    }
                }
                if(!isSamplePresent)
                {
                    //log Issue - Invalid Sample
                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_SAMPLE_FOR_RECIEVER, null, null, null );
                    return ;
                }
            }
            else
            {
                //log Issue - Invalid Sample reciever
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_SAMPLERECIEVER, null, null, null );
                return ;
            }




            //////validate Lot and Quantity///////
            if ( callAttributes.callSampleList != null && callAttributes.callSampleList.size() > 0 )
            {
                //Call2_Sample_vod__c objCallSample = new Call2_Sample_vod__c();

                //iPhoneApex.CallSample callSample = new iPhoneApex.CallSample();
                //callSample = callAttributes.callSampleList[0];

                //sampleLot = callSample.LotNo;
                //sampleQty = callSample.Quantity;

                List<Product_vod__c> objProdCatalog = new List<Product_vod__c>();
                List<Sample_Lot_vod__c> objSampleLot = new List<Sample_Lot_vod__c>();
                Map<String, Sample_Lot_vod__c> objSampleLotMap = new Map<String, Sample_Lot_vod__c>();
                Map<String, Product_vod__c> objProdCatalogMap = new Map<String, Product_vod__c>();
                Set<String> sampleProdList = new Set<String>();
                Set<String> lotNameList = new Set<String>();

                for ( iPhoneApex.CallSample callSample : callAttributes.callSampleList )
                {
                    if(callSample.Account == sampleReciever) //get product ids for sample products
                    {
                        if(callSample.Product!=null)
                        {
                            sampleProdList.add(callSample.Product);
                        }
                    }
                }

                try{
                    objProdCatalog = [Select Id, Name, Product_Type_vod__c, Sample_U_M_vod__c from Product_vod__c where Product_Type_vod__c = 'Sample' AND Id IN :sampleProdList ];
                }
                catch(Exception ex){
                    //do nothing
                }
                //check if samples are of product type samplesa and theye exist as valid sample and they have valid sample lots
                if(objProdCatalog!=null)
                {
                    for(Product_vod__c pr : objProdCatalog)
                    {
                        objProdCatalogMap.put(pr.Id, pr);
                        for ( iPhoneApex.CallSample callSample : callAttributes.callSampleList )
                        {
                            //Previously, when resolving organization, user, or record IDs in formula expressions within aVisualforce page, the ID
                            //was a string of either 15? or 18 alphanumeric characters. Any Visualforce pages created against Salesforce.com API
                            //version 18.0 or higher will always resolve expressions that return IDs with a length of 18 characters.
                            if(callSample.Product == pr.Id )
                            {
                                lotNameList.add(CallOwnerId + '_' + pr.Name.replaceAll(' ', '_') + '_' + callSample.LotNo);
                            }
                        }
                    }
                }
                else
                {
                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_PRODUCT, null, null, null );
                    return;
                }

                objSampleLot =  [SELECT Id, Name, Active_vod__c, Calculated_Quantity_vod__c, Expiration_Date_vod__c, Sample_Lot_Id_vod__c FROM Sample_Lot_vod__c WHERE Sample_Lot_Id_vod__c IN :lotNameList];

                //if(callSample.LotNo==null)
                //{
                //  //log Issue - Invalid Lot
                //  CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LOT );
                //  return;
                //}

                //check if samples have valid sample lots and they have sufficient quantity and can be released
                if(objSampleLot!=null)
                {
                    for(Sample_Lot_vod__c sa: objSampleLot)
                    {
                        objSampleLotMap.put(sa.Sample_Lot_Id_vod__c, sa);
                    }

                    //traverse through the list of samples and check if quantity is valid else return error
                    for ( iPhoneApex.CallSample callSample : callAttributes.callSampleList )
                    {
                        if(callSample.Account == sampleReciever) //get product ids for sample products
                        {
                            String prodName='';
                            //spit error for samples with no lot number but product type sample because samples without lot number can exist other than product type sample
                            if(callSample.LotNo==null) //return error if lot # not specified for a sample
                            {
                                if(objProdCatalogMap!=null && objProdCatalogMap.containsKey(callSample.Product))
                                {
                                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LOT, null, callSample.Quantity, callSample.Product );
                                }
                                continue;
                            }
                            //if callSample.LotNo is null tnen processing would have been terminated by now so no need to check for null here
                            if(objProdCatalogMap!=null && objProdCatalogMap.containsKey(callSample.Product))
                            {
                                prodName = objProdCatalogMap.get(callSample.Product).Name;
                                prodName = prodName.replaceAll(' ', '_');
                            }
                            String sampleLot = CallOwnerId + '_' + prodName + '_' + callSample.LotNo;
                            Double sampleQty = callSample.Quantity;
                            Sample_Lot_vod__c objLot = new Sample_Lot_vod__c();
                            if(objSampleLotMap!=null && objSampleLotMap.containsKey(sampleLot))
                            {
                                objLot = objSampleLotMap.get(sampleLot);
                                if(objLot.Calculated_Quantity_vod__c!=null && objLot.Calculated_Quantity_vod__c >0 &&  objLot.Calculated_Quantity_vod__c > sampleQty )
                                {
                                    //do nothing
                                }
                                else
                                {
                                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_QUANTITY,  callSample.LotNo, callSample.Quantity, callSample.Product );
                                }
                            }
                            else
                            {
                                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LOT , callSample.LotNo, callSample.Quantity, callSample.Product );
                            }
                        }
                    }
                }
                else
                {
                    //log Issue - Invalid Lot
                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LOT , null, null, null );
                }

            }
            else
            {
                //log issue - Invalid Sample
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_SAMPLE, null, null, null );
            }

            //////Validate State Medical License//////
            //assuming LicenseNumber is the SFDC id of State_Medical_License_gne__c object. If after clarifying it turns out to be
            //the textual License number then will need to modify License number logic below
            if(callAttributes.LicenseNumber !=null)
            {
                if(stateMedLicence.containsKey(callAttributes.LicenseNumber))
                {
                    //check if a license is a valid address license
                    //here if address is valid only then check Licence validity else Address Issue would already have been logged, so no need to log license validity Issue
                    if(callAttributes.Address!=null && addressVod.containsKey(callAttributes.Address))
                    {
                        Address_vod__c objLicense = new Address_vod__c();
                        Address_vod__c objAdd = new Address_vod__c();
                        objLicense = stateMedLicence.get(callAttributes.LicenseNumber);
                        objAdd =addressVod.get(callAttributes.Address);
                        //check if License is valid for the address
                        if(objAdd.License_vod__c == callAttributes.LicenseNumber)
                        {
                            //check if license is a valid state license(match with address state)
                            if(objLicense.State_vod__c!=null && objAdd.State_vod__c == objLicense.State_vod__c)
                            {
                                //check if License has valid expiration date
                                if(objLicense.License_Expiration_Date_vod__c > System.today() )
                                {
                                    //do nothing
                                }
                                else
                                {
                                    //log Issue - License expired
                                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_LICENSE_EXPIRED, null, null, null );
                                }
                            }
                            else
                            {
                                //log Issue - Licence doen not match Address State
                                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_LICENSE_NOT_MATCH_ADDRESS_STATE, null, null, null );
                            }
                        }
                        else
                        {
                            //log Issue - Invalid License to Address
                            CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LICENSE_TO_ADDRESS, null, null, null );
                        }

                    }
                }
                else
                {
                    //log issue - Invalid State Medical Licence
                    CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LICENSE, null, null, null );
                }
            }
            else
            {
                //log issue - Invalid State Medical Licence
                CreateDisbursementIssues(disbursementIssues, callAttributes, DISBURSEMENT_INVALID_LICENSE, null, null, null );
            }

        }

    }

    //method to create/log disbursement issues
    public static void CreateDisbursementIssues(List<Disbursement_Issue_gne__c> disbursementIssues ,  iPhoneApex.CallAttributes callAttributes, String IssueType, String LotNo, Double Qty, String Product )
    {
        Disbursement_Issue_gne__c objDisbursement = new Disbursement_Issue_gne__c();
        objDisbursement.Issue_Datetime_gne__c = System.now();
        if(callAttributes.SampleReceiver!=null)
        {
            objDisbursement.Account_gne__c = callAttributes.SampleReceiver;
        }
        else
        {
            objDisbursement.Account_gne__c = callAttributes.Account;
        }
        objDisbursement.User_gne__c = UserInfo.getUserId();
        objDisbursement.Address_gne__c = callAttributes.Address;
        //objDisbursement.Call_gne__c =
        objDisbursement.Issue_Type_gne__c = IssueType;
        //objDisbursement.Description_gne__c
        objDisbursement.Is_Attendee_gne__c = false;
        //objDisbursement.State_Medical_License_gne__c = callAttributes.LicenseNumber;
        objDisbursement.License_gne__c = callAttributes.LicenseNumber;
        objDisbursement.Signature_gne__c=callAttributes.Signature;
        objDisbursement.Signature_Date_gne__c=callAttributes.SignatureDate;
        objDisbursement.Sample_Reciever_gne__c=callAttributes.SampleReceiver;
        objDisbursement.Disclaimer_gne__c = callAttributes.Disclaimer;
        objDisbursement.Lot_gne__c = LotNo;
        objDisbursement.Quantity_gne__c = Qty;
        objDisbursement.Product_gne__c = Product;

        disbursementIssues.add(objDisbursement);


    }
    ////////////////////////////////////////Ends Sample Disbursement methods////////////////////////////////

    //deletes and archives the call and its related items
    //when the main call objects get deleted the trigger will delete all child calls and their relateditems automatically
    public static void deletCallHelper(String callId)
    {
        List<Call2_vod__c> callList = new List<Call2_vod__c>();
        List<Call2_vod__c> callDeleteList = new List<Call2_vod__c>();
        Set<String> setDeleteId = new Set<String>();

        callList = [select id, parent_call_vod__c, account_vod__c,
                                       attendee_type_vod__c, call_type_vod__c,
                                       parent_address_vod__c,address_vod__c,
                                       completed_gne__c,
                                       customers_gne__c,
                                       meal_expense_gne__c,detailed_products_vod__c,
                                       planned_attendees_gne__c,actual_attendees_gne__c,
                                       business_sponsor_gne__c, city_gne__c, state_gne__c, Status_vod__c, iPhone_Request_Id_gne__c,
                                       Signature_Date_vod__c, License_vod__c, Is_Sampled_Call_vod__c, License_designation_gne__c,
                                       Last_Device_vod__c
                                       from call2_vod__c
                                       where     (Id = :callId or
                                                  parent_call_vod__c = :callId)
                                      ];

        boolean blIsSampled=false;
        boolean blIsCompleted = false;
        for(Call2_vod__c cl : callList)
        {
            if(cl.Is_Sampled_Call_vod__c)
            {
                blIsSampled=true;
            }
            if(cl.Completed_gne__c)
            {
                blIsCompleted = true;
            }
        }

        if(blIsSampled && blIsCompleted)
        {
            throw new MyException('Cannot delete a Completed and a Sampled call');
        }
        if(blIsSampled)
        {
            throw new MyException('Cannot delete a sampled call');
        }
        if(blIsCompleted)
        {
            throw new MyException('Cannot delete a Completed call');
        }

        //delete if its not sampled OR not Completed. Delete only if its a planned call
        //deleting main call will automatically delete and archive all child calls and their related items by a trigger on the call object
        //main call is the string callId passed as parameter to this method but confirming here again if the callId is for the main call
        if(!blIsSampled && !blIsCompleted)
        {
            for(Call2_vod__c cl : callList)
            {
                if(cl.parent_call_vod__c==null)
                {
                    callDeleteList.add(cl);
                    break;//main call found now exit
                }
            }
        }
        else
        {
            throw new MyException('Cannot delete a sampled call');
        }

        if(callDeleteList!=null && callDeleteList.size()>0)
        {
            try{
                delete callDeleteList;
            }
            catch(Exception ex)
            {
                throw ex; //throw exception to let the calling method know its an nexception
            }
        }
        else
        {
            throw new MyException('Invalid Call');
        }

    }

    public static Map<Id, Product_vod__c> getSampleProductList(Set<String> prodIds)
    {
        Map<Id, Product_vod__c> productMap = new Map<Id, Product_vod__c>();

        try{
        productMap = new Map<Id, Product_vod__c>([Select Id, Name, Product_Type_vod__c from Product_vod__c where id IN :prodIds ]);
        }
        catch(Exception ex)
        {
            //do nothing
        }

        return productMap;
    }

    // remove call dependents if callattributes.Id present
    public static iPhoneApex.CallListAfterDelete deleteCallRelatedItems (String callId, boolean isIncomingSignatureCall, String OwnerId) {

        Call2_vod__c mainCall                   = null;
        Call2_vod__c sampleAttendeeOnHCOCall    = null; //hold the call record with signature attached for an HCO call
        iPhoneApex.CallListAfterDelete callsAfterDelete     = new iPhoneApex.CallListAfterDelete();
        //mainCall and sampleAttendeeOnHCOCall varialbles can be added here to the list, as and when they are assigned a new object they will reference the corrrect object
        callsAfterDelete.remainingCallList      =  new List<Call2_vod__c>();

        //sampleAttendeeOnHCOCall = null; //hold the call record with signature attached for an HCO call(for HCO call attendee may have signature attached)
        String CallOwner;

        if(OwnerId!=null)
        {
            CallOwner = OwnerId;
        }
        else
        {
            CallOwner = UserInfo.getUserId();
        }
        List<Call2_vod__c> callList = [select id, parent_call_vod__c, account_vod__c,
                                       attendee_type_vod__c, call_type_vod__c,
                                       parent_address_vod__c,address_vod__c,
                                       completed_gne__c,
                                       customers_gne__c,
                                       meal_expense_gne__c,detailed_products_vod__c,
                                       planned_attendees_gne__c,actual_attendees_gne__c,
                                       business_sponsor_gne__c, city_gne__c, state_gne__c, Status_vod__c, iPhone_Request_Id_gne__c,
                                       Signature_Date_vod__c, License_vod__c, Disclaimer_vod__c, Signature_vod__c, Is_Sampled_Call_vod__c, License_designation_gne__c,
                                       Last_Device_vod__c,
                                       (select id from call2_detail_vod__r),
                                       (select id from call2_discussion_vod__r),
                                       (select id, account_vod__c, quantity_vod__c, Lot_vod__c, Product_vod__c, iphone_request_id_gne__c, call2_vod__c from call2_sample_vod__r),
                                       (select id from call2_key_message_vod__r),
                                       (select id from call2_expense_vod__r)
                                       from call2_vod__c
                                       where     (Id = :callId or
                                                  parent_call_vod__c = :callId)
                                            //and createdById = :CallOwner  //not required
                                             //and createdById = :UserInfo.getUserId()
                                      ];

        List<Call2_vod__c> deleteAttendeeCallList               = new List<Call2_vod__c>();
        List<Call2_Detail_vod__c> deleteCallDetailList          = new List<Call2_Detail_vod__c>();
        List<Call2_Discussion_vod__c> deleteCallDiscussionList  = new List<Call2_Discussion_vod__c>();
        List<Call2_Sample_vod__c> deleteCallSampleList          = new List<Call2_Sample_vod__c>();
        List<Call2_Key_Message_vod__c> deleteCallKeyMessageList = new List<Call2_Key_Message_vod__c>();
        List<Call2_Expense_vod__c> deleteCallExpenseList        = new List<Call2_Expense_vod__c>();

        Set<Id> idSet = new Set<Id>();

        for (Call2_vod__c callRecord : callList ) {

            callRecord.meal_expense_gne__c      = false;
            callRecord.planned_attendees_gne__c = 0;
            callRecord.actual_attendees_gne__c  = 0;

            if (callRecord.parent_call_vod__c == null)
            {
                mainCall = callRecord;

            }
            else
            {
                if(callRecord.Is_Sampled_Call_vod__c) //is a sample call then do not add attendee to deleted list
                {
                     sampleAttendeeOnHCOCall = callRecord;

                }
                else
                {
                    if ( idSet.add(callRecord.Id) )
                    {
                        deleteAttendeeCallList.add ( callRecord );
                    }
                }
            }

            for (Call2_Detail_vod__c callDetailRecord : callRecord.call2_detail_vod__r )
                if ( idSet.add(callDetailRecord.Id)  )
                    deleteCallDetailList.add ( callDetailRecord );

            for (Call2_Discussion_vod__c callDiscussionRecord : callRecord.call2_discussion_vod__r )
                if (idSet.add(callDiscussionRecord.Id))
                    deleteCallDiscussionList.add ( callDiscussionRecord );


            for (Call2_Sample_vod__c callSampleRecord : callRecord.call2_sample_vod__r )
            {
                //if sample attendee then delete call_sample records without Lot No. as these only will be material left behind
                if(callRecord.Is_Sampled_Call_vod__c)
                {
                    if(callSampleRecord.Lot_vod__c==null)
                    {
                        if (idSet.add(callSampleRecord.Id))
                        {
                            deleteCallSampleList.add ( callSampleRecord  );
                        }
                    }
                }
                else
                {
                    if (idSet.add(callSampleRecord.Id))
                    {
                        deleteCallSampleList.add ( callSampleRecord  );
                    }
                }
            }


            for (Call2_Key_Message_vod__c callKeyMessageRecord : callRecord.call2_key_message_vod__r )
                if (idSet.add(callKeyMessageRecord.Id))
                    deleteCallKeyMessageList.add ( callKeyMessageRecord );

            for (Call2_Expense_vod__c callExpenseRecord : callRecord.call2_expense_vod__r )
                if (idSet.add(callExpenseRecord.Id))
                    deleteCallExpenseList.add ( callExpenseRecord );

        }
        if(mainCall!=null)
        {
            callsAfterDelete.remainingCallList.add(mainCall);
        }
        if(sampleAttendeeOnHCOCall!=null)
        {
            callsAfterDelete.remainingCallList.add(sampleAttendeeOnHCOCall);
        }

        //not required anymore as dont see any reason for this update to be here.
        // unset key attributes to allow subsequent delete of related items
        //if ( callList.size() > 0 ) //not required
        //   update callList;

        if ( deleteCallExpenseList.size() > 0 )
           delete deleteCallExpenseList;

        if ( deleteCallKeyMessageList.size() > 0 )
           delete deleteCallKeyMessageList;

        if ( deleteCallSampleList.size() > 0 )
           delete deleteCallSampleList;

        if ( deleteCallDiscussionList.size() > 0 )
            delete deleteCallDiscussionList;

        if ( deleteCallDetailList.size() > 0 )
            delete deleteCallDetailList;

        if ( deleteAttendeeCallList.size() > 0 ) {
            GNE_SFA2_Interaction_Trigger_Helper.setIsAllowDeleteAttendeeMode(true);
            delete deleteAttendeeCallList;
        }

        return callsAfterDelete;
    }


    public static iPhoneApex.CallAttributes getCallAttributes(String callId)
    {
         List<Call2_vod__c> callList = [select id, parent_call_vod__c,
                                       call_datetime_vod__c,
                                       attendee_type_vod__c, account_vod__c,
                                       call_type_vod__c, interaction_type_gne__c,
                                       parent_address_vod__c,address_vod__c,
                                       completed_gne__c,  customers_gne__c,
                                       meal_expense_gne__c,meal_amount_gne__c,
                                       planned_attendees_gne__c,actual_attendees_gne__c,
                                       detailed_products_vod__c,
                                       Business_sponsor_gne__c,
                                       city_gne__c, state_gne__c,
                                       iphone_request_id_gne__c,  Territory_vod__c,
                                       Spend_User_gne__c, Contracted_Services_gne__c,
                                       Signature_vod__c, Interaction_Method_gne__c, Interaction_Location_gne__c,
                                       Primary_Interaction_Reason_gne__c, Visit_Reason_gne__c, Visit_Reason_Description_gne__c,
                                       (select id,iphone_request_id_gne__c, product_vod__c,
                                        Detail_Priority_vod__c,
                                        Therapeutic_Area_gne__c,
                                        Indication_gne__c from call2_detail_vod__r
                                        order by iphone_request_id_gne__c),
                                       (select id,iphone_request_id_gne__c,
                                        product_vod__c, product_strategy_Vod__c,
                                        product_tactic_vod__c, reaction_gne__c
                                        from call2_discussion_vod__r
                                        order by iphone_request_id_gne__c),
                                        (select id, iphone_request_id_gne__c,
                                         account_vod__c,contact_vod__c,user_vod__c,
                                         attendee_type_vod__c from call2_vod__r
                                         order by iphone_request_id_gne__c)
                                       from call2_vod__c
                                       where     Id = :callId  and parent_call_vod__c = null
                                      ];

        iPhoneApex.CallAttributes callAttributes       = null;

        if ( callList.size() == 1) {
            callAttributes                      = new iPhoneApex.CallAttributes();
            callAttributes.callAttendeeList     = new List<iPhoneApex.CallAttendee>();
            callAttributes.callDetailList       = new List<iPhoneApex.CallDetail>();
            callAttributes.callDiscussionList   = new List<iPhoneApex.CallDiscussion>();

            Call2_vod__c callRecord             = callList[0];

            callAttributes.CallAttendeeType      = iPhoneApex.AttendeeType.PERSONACCOUNT;

            callAttributes.Id                    = callRecord.Id;
            callAttributes.RequestId             = callRecord.iPhone_Request_id_gne__c;
            callAttributes.InteractionType       = callRecord.Interaction_Type_gne__c;
            callAttributes.Account               = callRecord.account_vod__c;
            callAttributes.CallDateTime          = callRecord.call_datetime_vod__c;
            callAttributes.NumOfCustomersPresent = callRecord.customers_gne__c != null ?
                                                   callRecord.customers_gne__c.intValue():0;
            callAttributes.IsComplete            = callRecord.completed_gne__c != null ?
                                                   callRecord.completed_gne__c : FALSE;
           	callAttributes.isOtrRequest          =  iPhoneApex.isOtrRequestStat;

            callAttributes.BusinessSponsor       = callRecord.Business_Sponsor_gne__c;
            callAttributes.MealLocationCity      = callRecord.City_gne__c;
            callAttributes.MealLocationState     = callRecord.State_gne__c;

            callAttributes.InteractionMethod    =  callRecord.Interaction_Method_gne__c;
            callAttributes.InteractionLocation  = callRecord.Interaction_Location_gne__c;

            if ( callRecord.call_type_vod__c.equalsIgnoreCase('Group_Account_vod') )
                callAttributes.CallAttendeeType = iPhoneApex.AttendeeType.ACCOUNT;

            if (callRecord.Address_vod__c != null  ) {
               callAttributes.Address     = callRecord.Parent_address_vod__c;
               callAttributes.AddressText = callRecord.address_vod__c;
            }

            if ( callRecord.meal_amount_gne__c != null ) {
               callAttributes.MealAmount = callRecord.meal_amount_gne__c;
            }

            if ( callRecord.planned_attendees_gne__c != null &&
                 callRecord.actual_attendees_gne__c  != null ) {
               callAttributes.MealPlannedAttendeeCount = callRecord.planned_attendees_gne__c.intValue();
               callAttributes.MealActualAttendeecount  = callRecord.actual_attendees_gne__c.intValue();
            }

            if ( callRecord.Spend_User_gne__c != null ) {
               callAttributes.SpendUser = callRecord.Spend_User_gne__c;
            }
            if ( callRecord.Contracted_Services_gne__c != null ) {
               callAttributes.ContractedServices = callRecord.Contracted_Services_gne__c;
            }

            for (Call2_vod__c callAttendeeRecord : callRecord.call2_vod__r ) {
                iPhoneApex.CallAttendee cAttendee = new iPhoneApex.CallAttendee();
                if ( callAttendeeRecord.attendee_type_vod__c == 'Contact_vod' ) {
                    cAttendee.CallAttendeeType = iPhoneApex.AttendeeType.CONTACT;
                    cAttendee.Attendee         = callAttendeeRecord.contact_vod__c;
                } else if ( callAttendeeRecord.attendee_type_vod__c == 'User_vod' ) {
                    cAttendee.CallAttendeeType = iPhoneApex.AttendeeType.USER;
                    cAttendee.Attendee         = callAttendeeRecord.user_vod__c;
                } else if ( callAttendeeRecord.account_vod__c != null ) {
                    cAttendee.CallAttendeeType = iPhoneApex.AttendeeType.PERSONACCOUNT;
                    cAttendee.Attendee         = callAttendeeRecord.account_vod__c;
                }
                cAttendee.RequestId      = callAttendeeRecord.iPhone_Request_id_gne__c;
                callAttributes.callAttendeeList.add ( cAttendee );
            }

            for (Call2_Detail_vod__c callDetailRecord : callRecord.call2_detail_vod__r ) {
                iPhoneApex.CallDetail cDetail        = new iPhoneApex.CallDetail();
                cDetail.Product           = callDetailRecord.Product_vod__c;
                cDetail.DetailPriority    = callDetailRecord.Detail_Priority_vod__c.format();
                cDetail.TherapeuticArea   = callDetailRecord.Therapeutic_Area_gne__c;
                cDetail.DiseaseIndication = callDetailRecord.Indication_gne__c;
                cDetail.RequestId         = callDetailRecord.iPhone_Request_id_gne__c;
                callAttributes.callDetailList.add ( cDetail );
            }

            for (Call2_Discussion_vod__c callDiscussionRecord : callRecord.call2_discussion_vod__r ) {
                iPhoneApex.CallDiscussion cDiscussion     = new iPhoneApex.CallDiscussion();
                cDiscussion.Product            = callDiscussionRecord.Product_vod__c;
                cDiscussion.ProductStrategy    = callDiscussionRecord.Product_Strategy_vod__c;
                cDiscussion.ProductTactic      = callDiscussionRecord.Product_Tactic_vod__c;
                cDiscussion.Reaction           = callDiscussionRecord.Reaction_gne__c;
                cDiscussion.RequestId          = callDiscussionRecord.iPhone_Request_id_gne__c;
                callAttributes.callDiscussionList.add ( cDiscussion );
            }
        }

        return callAttributes;

    }

    //split comma sepearted string to extract and update call2_vod__c for FRM users
    public static call2_vod__c getTopicsAddressedMSL(call2_vod__c callvod , String value)
    {
        String sTopics = value;

        List<String> topicsList = new List<String>();

        //set all FRM users boolean fields to false to later update the specific fileds to true in case of an update
        callvod.Access_Solutions_gne__c = false;
        callvod.Case_Review_gne__c = false;
        callvod.Coding_gne__c = false;
        callvod.Co_pay_INO_gne__c = false;
        callvod.Co_pay_BioOnc_Card_gne__c = false;
        callvod.Customer_frustration_gne__c = false;
        callvod.Delayed_Reimbursement_gne__c = false;
        callvod.Diagnostic_report_call_gne__c = false;
        callvod.GATCF_gne__c = false;
        callvod.GES_gne__c = false;
        callvod.Local_Market_Insights_Resource_gne__c = false;
        callvod.Medicare_Update_gne__c = false;
        callvod.Misc_J_Code_gne__c = false;
        callvod.New_indication_gne__c = false;
        callvod.Oncology_National_Accounts_gne__c = false;
        callvod.Price_Objections_gne__c = false;
        callvod.Private_Payer_Denial_gne__c = false;
        callvod.Private_Payer_PA_gne__c = false;
        callvod.Private_Payer_Update_gne__c = false;
        callvod.Public_Payer_Denial_gne__c = false;
        callvod.Public_Payer_PA_gne__c = false;
        callvod.PSL_gne__c = false;
        callvod.SP_Education_gne__c = false;
        callvod.Trends_in_Reimbursement_gne__c = false;
        callvod.Impact_Now_gne__c = false;
        callvod.Oncology_Trend_Report_Resource_gne__c = false;
        callvod.Other_Topics_Addressed_gne__c = false;

        try{
            topicsList = sTopics.split(',');
        }catch(Exception ex){
            //do nothing
        }

        if(topicsList.size()>0)
        {
            for(String tp : topicsList)
            {
                if(!isNull(tp))
                {
                    if(tp.trim().equalsIgnoreCase('Access_Solutions_gne__c')) {
                        callvod.Access_Solutions_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Case_Review_gne__c'))   {
                        callvod.Case_Review_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Coding_gne__c'))    {
                        callvod.Coding_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Co_pay_INO_gne__c'))    {
                        callvod.Co_pay_INO_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Co_pay_BioOnc_Card_gne__c')) {
                        callvod.Co_pay_BioOnc_Card_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Customer_frustration_gne__c'))  {
                        callvod.Customer_frustration_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Delayed_Reimbursement_gne__c'))     {
                        callvod.Delayed_Reimbursement_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Diagnostic_report_call_gne__c'))    {
                        callvod.Diagnostic_report_call_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('GATCF_gne__c')) {
                        callvod.GATCF_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('GES_gne__c'))   {
                        callvod.GES_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Local_Market_Insights_Resource_gne__c'))    {
                        callvod.Local_Market_Insights_Resource_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Medicare_Update_gne__c'))   {
                        callvod.Medicare_Update_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Misc_J_Code_gne__c'))   {
                        callvod.Misc_J_Code_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('New_indication_gne__c'))    {
                        callvod.New_indication_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Oncology_National_Accounts_gne__c'))    {
                        callvod.Oncology_National_Accounts_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Price_Objections_gne__c'))  {
                        callvod.Price_Objections_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Private_Payer_Denial_gne__c'))  {
                        callvod.Private_Payer_Denial_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Private_Payer_PA_gne__c'))  {
                        callvod.Private_Payer_PA_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Private_Payer_Update_gne__c'))  {
                        callvod.Private_Payer_Update_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Public_Payer_Denial_gne__c'))   {
                        callvod.Public_Payer_Denial_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Public_Payer_PA_gne__c'))   {
                        callvod.Public_Payer_PA_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('PSL_gne__c'))   {
                        callvod.PSL_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('SP_Education_gne__c'))  {
                        callvod.SP_Education_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Trends_in_Reimbursement_gne__c'))   {
                        callvod.Trends_in_Reimbursement_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Impact_Now_gne__c'))    {
                        callvod.Impact_Now_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Oncology_Trend_Report_Resource_gne__c'))    {
                        callvod.Oncology_Trend_Report_Resource_gne__c = true;
                    }
                    else if(tp.trim().equalsIgnoreCase('Other_Topics_Addressed_gne__c'))    {
                        callvod.Other_Topics_Addressed_gne__c = true;
                    }

                }
            }
        }
        return callvod;
    }

    public static String truncateString(String value)
    {
        String sTemp;
        if(!isNull(value)) {
            sTemp = value.trim();
            if(sTemp.equals('')) { //if priginal string had only spaces then it would now be an empty string so return null
                return null;
            }
        }
        else {
            return null;
        }

        if(sTemp.length() > 255){
            sTemp=sTemp.substring(0, 254);
        }
        else {
            sTemp =value;
        }

        return sTemp;
    }

    public static Call2_vod__c updateFRMInteraction(Call2_vod__c attendeeCall, iPhoneApex.callAttributes callAttributes)
    {
        //to support Interactions by FRM users
        if(callAttributes.isFRM!=null && callAttributes.isFRM) //its an FRM user
        {
            if(callAttributes.SpeakerProgram!=null) {
                attendeeCall.Speaker_Program_gne__c = callAttributes.SpeakerProgram;
            }
            if(callAttributes.Resolution!=null) {
                attendeeCall.Resolution_gne__c = callAttributes.Resolution;
            }

            if(callAttributes.Reactive!=null) {
                attendeeCall.Reactive__c = callAttributes.Reactive;
            }
            if(callAttributes.ResponseTime!=null) {
                attendeeCall.FRM_Response_Time_gne__c = callAttributes.ResponseTime;
            }
            if(callAttributes.InteractionMethod!=null) {
                attendeeCall.Interaction_Method_gne__c = callAttributes.InteractionMethod;
            }
            if(!isNull(callAttributes.InteractionLocation)) {
                attendeeCall.Interaction_Location_gne__c = callAttributes.InteractionLocation;
            }
            if(callAttributes.AdditionalNotes!=null) {

                attendeeCall.Other_Details_Topics_Addressed_gne__c = truncateString(callAttributes.AdditionalNotes);
            }
            if(callAttributes.TopicsAddressed!=null)
            {
                attendeeCall = iPhoneApexUtil.getTopicsAddressedMSL(attendeeCall, callAttributes.TopicsAddressed);
            }

        }
         return attendeeCall;
    }

    public static Call2_vod__c updateMSLInteraction(Call2_vod__c attendeeCall, iPhoneApex.callAttributes callAttributes)
    {
         //to support Interactions by MSL users
        if(callAttributes.isMSL!=null && callAttributes.isMSL)
        {
            if(callAttributes.InteractionMethod!=null) {
                attendeeCall.Interaction_Method_gne__c = callAttributes.InteractionMethod;
            }
            if(callAttributes.isVisitReason!=null)  {
                attendeeCall.Visit_Reason_gne__c = callAttributes.isVisitReason; //dependant picklist in SFDC. dependant on Primary_Interaction_Reason_gne__c
            }
            if(callAttributes.visitReasonDescription!=null)  {
                attendeeCall.Visit_Reason_Description_gne__c = callAttributes.visitReasonDescription; //dependant picklist in SFDC. dependant on Visit_Reason_gne__c
            }
            if(callAttributes.GroupMeetingTopic!=null)  {
                attendeeCall.Group_Meeting_Topic_gne__c = truncateString(callAttributes.GroupMeetingTopic);
            }
            if(callAttributes.PrimaryInteractionReason!=null)   {
                attendeeCall.Primary_Interaction_Reason_gne__c = callAttributes.PrimaryInteractionReason;
            }
            if(!isNull(callAttributes.InteractionLocation)) {
                attendeeCall.Interaction_Location_gne__c = callAttributes.InteractionLocation;
            }
        }
        return attendeeCall;
    }

    public static iPhoneApex.CallAttributes updateOrCreateCallForValEngine (iPhoneApex.CallAttributes callAttributes){

        String CallOwnerId;
        if(callAttributes.OwnerId!=null)
        {
            CallOwnerId = callAttributes.OwnerId;
        }
        else
        {
            CallOwnerId=UserInfo.getUserId();
        }
        String requestId = DateTime.Now().format ('yyyyMMddHHmmssS');
        String userAlias = [select alias from user where Id = :CallOwnerId].alias;

        if ( callAttributes == null )
            return null;

        if ( callAttributes.RequestId == null )
            callAttributes.RequestId = REQUESTID_VALENG_PREFIX_FOR_MAIN_CALL + userAlias + requestId + '0';

        if ( callAttributes.callAttendeeList != null ) {
            for ( Integer i = 0; i < callAttributes.CallAttendeeList.size(); i++ ) {
                if ( callAttributes.CallAttendeeList[i].RequestId == null )
                    callAttributes.CallAttendeeList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_ATTENDEE + userAlias + requestId + (i+1) ;

            }
        }

        if ( callAttributes.callDetailList != null ) {
            for ( Integer i = 0; i < callAttributes.callDetailList.size(); i++ ) {
                if ( callAttributes.callDetailList[i].RequestId == null )
                    callAttributes.callDetailList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_DETAIL + userAlias + requestId + i ;
            }
        }

        if ( callAttributes.callDiscussionList != null ) {
            for ( Integer i = 0; i < callAttributes.callDiscussionList.size(); i++ ) {
                if ( callAttributes.callDiscussionList[i].RequestId == null )
                    callAttributes.callDiscussionList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_DISCUSSION + userAlias + requestId + i ;
            }
        }

        if ( callAttributes.callSampleList != null ) {
            for ( Integer i = 0; i < callAttributes.callSampleList.size(); i++ ) {
                if ( callAttributes.callSampleList[i].RequestId == null )
                    callAttributes.callSampleList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_SAMPLE + userAlias + requestId + i ;
            }
        }

        return callAttributes;
   }

   //get product list in detal and discussion(only MSL)
    public static Set<Id> getDetailproductIdList(iPhoneApex.CallAttributes callAttributes)
    {
        // detailed product initializer
        set<Id> productIdList = new set<Id> ();
        if ( callAttributes.callDetailList != null ) {
            for ( iPhoneApex.CallDetail callDetail : callAttributes.callDetailList ) {
                if(!isNull(callDetail.Product) && !productIdList.contains(callDetail.Product)) {
                    productIdList.add(callDetail.Product);
                }
            }
            //callRecord.detailed_products_vod__c = iPhoneApex.getDetailedProductString(productIdList);
        }

        if(callAttributes.isMSL!=null && callAttributes.isMSL)  {
            if ( callAttributes.callDiscussionList != null ) {
                 for ( iPhoneApex.CallDiscussion callDisc : callAttributes.callDiscussionList ) {
                    if(!isNull(callDisc.Product) && !productIdList.contains(callDisc.Product) )  {
                        productIdList.add(callDisc.Product);
                    }
                }
            }
        }

        return productIdList;
    }

    //get molecule list from calldiscussion for MSL interaction
    public static Set<Id> getMoleculeproductIdList(iPhoneApex.CallAttributes callAttributes)
    {
        set<Id> productIdList = new set<Id> ();
        if(callAttributes.isMSL!=null && callAttributes.isMSL)  {
            if ( callAttributes.callDiscussionList != null ) {
                for ( iPhoneApex.CallDiscussion callDisc : callAttributes.callDiscussionList ) {
                    if(!isNull(callDisc.Molecule) && !callDisc.Molecule.equalsIgnoreCase('N/A') && !productIdList.contains(callDisc.Molecule))
                    {
                        productIdList.add(callDisc.Molecule);
                    }
                }
            }
        }

        return productIdList;
    }

    public static Map<Id, Product_vod__c> getDetailedProducts (set<Id> productIdList, iPhoneApex.CallAttributes callAttributes) {
        Map<Id, Product_vod__c> mapProducts;
        boolean isFoundNA = false;
        if(callAttributes.isMSL!=null && callAttributes.isMSL)  {
            if ( callAttributes.callDiscussionList != null ) {
                for ( iPhoneApex.CallDiscussion callDisc : callAttributes.callDiscussionList ) {
                    if(!isNull(callDisc.Molecule) && callDisc.Molecule.equalsIgnoreCase('N/A') )
                    {
                        isFoundNA=true;
                        break;
                    }
                }
            }
        }

        if(productIdList.size()>0 && isFoundNA)
        {
            mapProducts= new Map<Id, Product_vod__c>([select Id, name from product_vod__c where name =:NonProduct_NonMolecule OR Id in :productIdList]);
        }
        else if(productIdList.size()<=0 && isFoundNA)
        {
            mapProducts= new Map<Id, Product_vod__c>([select Id, name from product_vod__c where name =:NonProduct_NonMolecule]);
        }
        else if(productIdList.size()>0)
        {
            mapProducts= new Map<Id, Product_vod__c>([select Id, name from product_vod__c where Id in :productIdList]);
        }


        return mapProducts;
    }

    //returns product names.
    //accepts product list and exempt id list(molecule list)
    public static String getDetailedProductString (Map<Id, Product_vod__c> mapProducts, set<Id> moleculeIdList ) {
        String detailedProductString = null;

        if(mapProducts!=null && mapProducts.size()>0)
        {
            for ( Id productItem : mapProducts.keySet() )
            {
                if(!moleculeIdList.contains(productItem))
                {
                    if ( detailedProductString != null )
                    detailedProductString = detailedProductString + ' ' +
                                            mapProducts.get(productItem).Name;
                    else
                        detailedProductString =  mapProducts.get(productItem).Name ;
                }
           }
        }

        return detailedProductString;
    }

    public static boolean isNull(String value)
    {
        if(value==null || value.trim().equals(''))
            return true;
        return false;
    }

    public static String processProductTactic(String productTacticIdOld, iPhoneApex.CallAttributes callAttributes){

        //check if Product Tactic exist
        List<Product_Tactic_vod__c> existingProductTactics = [Select Id from Product_Tactic_vod__c where id = :productTacticIdOld];
        if(existingProductTactics != null && existingProductTactics.size()>0){
            return productTacticIdOld;
        }

        //search for Product Tactic in deleted
        List<Product_Tactic_vod__c> deletedProductTactics = [Select Id,isDeleted,Name from Product_Tactic_vod__c where isDeleted =:true and id = :productTacticIdOld ALL ROWS];
        String productTacticName;
        if(deletedProductTactics != null && deletedProductTactics.size()>0){

            //find in existing Product Tactics
            productTacticName = deletedProductTactics.get(0).Name;
            List<String> productIds = collectProducts(callAttributes);
            List<Product_Tactic_vod__c> productTactics = [Select p.Id,p.Name from Product_Tactic_vod__c p where p.Name = :productTacticName and p.Product_Strategy_vod__r.Product_Plan_vod__r.Product_vod__c in :productIds];
            if(productTactics != null && productTactics.size() > 0){
                return productTactics.get(0).Id;
            } else {
                return null;
            }
        } else {
            return null;
        }

        return null;
    }

    private static List<String> collectProducts(iPhoneApex.CallAttributes callAttributes){
        List<String> productIds = new List<String>();
        for(iPhoneApex.CallDiscussion callDiscussion : callAttributes.callDiscussionList){
            if(callDiscussion.Product != null && callDiscussion.Product.length() > 0){
                productIds.add(callDiscussion.Product);
            }
        }

        return productIds;
    }
}