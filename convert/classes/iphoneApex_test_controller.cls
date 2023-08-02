public class iphoneApex_test_controller {
    
    public String testData {get;set;}
    public String errorIdsData {get;set;}
    private List<ErrorItemWrapper> errorItems = new List<ErrorItemWrapper>();  
    private List<iPhone_API_Errors__c> iPhoneAPIErrors;
    public Boolean transactionMode {get;set;}
   
    public iphoneApex_test_controller() {
        transactionMode = false;
        iPhoneAPIErrors = [Select Details__c, Details_Exception__c from iPhone_API_Errors__c];
        Set<String> iPhoneAPIErrorsStrings = new Set<String>();
        for(iPhone_API_Errors__c iPhoneAPIError : iPhoneAPIErrors){
            iPhoneAPIErrorsStrings.add(iPhoneAPIError.Details_Exception__c);
        }
        Integer i = 0;
        for(String iPhoneAPIErrorsString : iPhoneAPIErrorsStrings){
            ErrorItemWrapper errorItem = new ErrorItemWrapper(i, iPhoneAPIErrorsString);
            errorItems.add(errorItem);
            i++;
        }
    }
    
    public class ErrorItemWrapper {
        public Integer errorId {get;set;}
        public String errorName {get;set;}
        public ErrorItemWrapper(Integer id, String ename){
            errorId = id;
            errorName = ename;
        }
        
    }
    
    public List<ErrorItemWrapper> getErrorsWrappers() {
        return errorItems;
    }
    
    public PageReference startBatch(){
    
        List<iPhone_API_Errors__c> iPhoneAPIErrorsToRun = new List<iPhone_API_Errors__c>(); 
        
        //getting error name
        String errorName;
        Integer errorId = Integer.valueOf(System.currentPageReference().getParameters().get('errorId'));
        for(ErrorItemWrapper errorItem : errorItems){
            if(errorId==errorItem.errorId){
                errorName = errorItem.errorName;
                break;
            }
        }
        
        Id batchinstanceid = database.executeBatch(new OTR_ErrorCallsInsertBatch(errorName), 200);
                
        return null;
    }
    
    public PageReference startBatchByIdsBeta(){
    
        System.debug('swajrych errorIdsData='+errorIdsData);
        if(errorIdsData != null && errorIdsData.length()>=15){
            //prepare ids to Set 
            Set<String> errorIds = new Set<String>(errorIdsData.split(','));
            System.debug('swajrych errorIds='+errorIds);
            Id batchinstanceid = database.executeBatch(new OTR_ErrorCallsInsertByIdsBatch(errorIds), 200);
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'API Errors Ids not well formated')); 
        }
                
        return null;
    }
    
    public PageReference startBatchByIds(){
    
        List<String> resultsListSuccess = new List<String>();
        List<String> resultsListFailure = new List<String>();
    
        System.debug('swajrych errorIdsData='+errorIdsData);
        if(errorIdsData != null && errorIdsData.length()>=15){
            //prepare ids to Set 
            List<String> errorIds = errorIdsData.split(',');
            
            for(iPhone_API_Errors__c  apiError : [SELECT id,Details__c, Details_Exception__c FROM iPhone_API_Errors__c where id in :errorIds]){
                iPhoneApex.Response iPhoneCallResponse = new iPhoneApex.Response();
                List<iPhoneApex.CallAttributes> iPhoneCallAttribs = prepareCallAttributes(apiError.Details__c); 
                for(iPhoneApex.CallAttributes iPhoneCallAttrib : iPhoneCallAttribs){
                    iPhoneCallResponse = iPhoneApex.updateOrCreateCall(iPhoneCallAttrib);
                    Integer i = 0;          
                    while ((i < iPhoneCallResponse.RequestIdResponseIdList.size()) && (iPhoneCallResponse.RequestIdResponseIdList[i].ObjectType <> 'Call2_vod__c')) {
                        i++;
                    }
                    if(iPhoneCallResponse.ErrorMessage != null){
                        resultsListFailure.add(apiError.id+','+iPhoneCallResponse.ErrorMessage);
                    }else{
                        resultsListSuccess.add(apiError.id);
                    }
                }
                
            }
            sendMailWithResults(resultsListSuccess, resultsListFailure);
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,'Please check your email for results summary'));

        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'API Errors Ids not well formated')); 
        }
                
        return null;
    }
    
    private static void sendMailWithResults(List<String> resultsListSuccess, List<String> resultsListFailure){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<User> usrs = new List<User>([select email,Name from User where id=:UserInfo.getUserId()]);
        mail.setToAddresses(new String[]{usrs[0].email});
        mail.setSubject('Interactions update/insert');
        mail.setReplyTo('wajrycs1@gene.com');
        String mailText = '******PLEASE DO NOT REPLY TO THIS EMAIL****** \n\n';
        mailText += 'Dear '+ usrs[0].Name+',\n\n'; 
         
        if(resultsListSuccess.size()>0){
            mailText += 'The folowing Interactions update/insert succesfull:\n\n';
            for(String success : resultsListSuccess){
                mailText += success +'\n';
            }
        }        
        
        if(resultsListFailure.size()>0){
            mailText += '\n\n';
            mailText += 'The folowing Interactions update/insert failure:\n\n';
            for(String failure : resultsListFailure){
                mailText += failure +'\n';
            }
        }
        mailText += '\nBest regards,\n';
        mailText += 'System Administrator';
        mailText += '\n\n';
        mail.setPlainTextBody(mailText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    

    public PageReference startTest(){
        SavePoint savePoint; 
        if(transactionMode){
            savePoint = Database.setSavePoint();
        }
        
        iPhoneApex.Response iPhoneCallResponse = new iPhoneApex.Response();
        try {
            List<iPhoneApex.CallAttributes> iPhoneCallAttribs = prepareCallAttributes(testData);    
            for(iPhoneApex.CallAttributes iPhoneCallAttrib : iPhoneCallAttribs){
                iPhoneCallResponse = iPhoneApex.updateOrCreateCall(iPhoneCallAttrib);
                Integer i = 0;          
                while ((i < iPhoneCallResponse.RequestIdResponseIdList.size()) && (iPhoneCallResponse.RequestIdResponseIdList[i].ObjectType <> 'Call2_vod__c')) {
                    i++;
                }
            }
        } catch (Exception e) {  
            ApexPages.addMessages(e);
            return null;                                               
        } finally {
            if(iPhoneCallResponse.ErrorMessage != null){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Response: ErrorMessage:'+iPhoneCallResponse.ErrorMessage));
            }else{
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Interactions created successfully'));
            }
            if(transactionMode){
                Database.rollback ( savePoint );
            }
        }
        
        return null;
    }
    
    public static List<iPhoneApex.CallAttributes> prepareCallAttributes(String testData){

        System.debug('testData=>>>'+testData+'<<<<');
        
        List<iPhoneApex.CallAttributes> iPhoneCallAttribs = new List<iPhoneApex.CallAttributes>();
        List<String> callAttributes = testData.split('iPhoneApex.CallAttributes:');
        System.debug('callAttribute000000.size()=>>>'+callAttributes.size()+'<<<<');
        System.debug('callAttribute0=>>>'+callAttributes+'<<<<');
        
        for(String callAttribute : callAttributes){
            
            if(callAttribute.length()<10){ continue; }
            
            System.debug('callAttribute1=>>>'+callAttribute+'<<<<');
            
            List<iPhoneApex.CallAttendee> callAttendees = new List<iPhoneApex.CallAttendee>();
            List<iPhoneApex.CallDetail> callDetails = new List<iPhoneApex.CallDetail>();
            List<iPhoneApex.CallDiscussion> callDiscussions = new List<iPhoneApex.CallDiscussion>();
            List<iPhoneApex.CallSample> callSamples = new List<iPhoneApex.CallSample>();
            List<iPhoneApex.CallKeyMessage> callKeyMessages = new List<iPhoneApex.CallKeyMessage>();
            
            Integer firstFrame, lastFrame;
            firstFrame = callAttribute.indexOf('[');
            lastFrame = callAttribute.lastIndexOf(']');
            if(firstFrame > -1 && lastFrame > -1){
                callAttribute = callAttribute.substring(firstFrame+1,lastFrame);
            }
            
            System.debug('callAttribute2=>>>'+callAttribute+'<<<<');
            
            callAttendees = prepareCallAttendeeList(callAttribute);
            callAttribute = removeDataElement(callAttribute,'callAttendeeList');
            
            callDetails = prepareCallDetailList(callAttribute);
            callAttribute = removeDataElement(callAttribute,'callDetailList');
            
            callDiscussions = prepareCallDiscussionList(callAttribute);
            callAttribute = removeDataElement(callAttribute,'callDiscussionList');
            
            callKeyMessages = prepareCallKeyMessageList(callAttribute);
            callAttribute = removeDataElement(callAttribute,'callKeyMessageList');
            
            callSamples = prepareCallSampleList(callAttribute);
            callAttribute = removeDataElement(callAttribute,'prepareCallSampleList');
            
            
            
            String addressText = prepareAddressText(callAttribute);             
            System.debug('callAttribute3=>>>'+callAttribute+'<<<<');
            callAttribute = removeAddressText(callAttribute);
            
            System.debug('callAttribute4=>>>'+callAttribute+'<<<<');
            
            
            Map<String,String> callAttributesPrams = mapParameters(callAttribute);
            callAttributesPrams.put('AddressText',addressText);
            //System.debug('callAttributesPrams=>>>'+callAttributesPrams+'<<<<');
            
            iPhoneApex.CallAttributes iPhoneCallAttrib = new iPhoneApex.CallAttributes();
            iPhoneCallAttrib.Account = callAttributesPrams.get('Account');   
            iPhoneCallAttrib.AdditionalNotes = callAttributesPrams.get('AdditionalNotes'); 
            iPhoneCallAttrib.Address = callAttributesPrams.get('Address');            
            iPhoneCallAttrib.AddressText = callAttributesPrams.get('AddressText');
            iPhoneCallAttrib.BusinessSponsor = callAttributesPrams.get('BusinessSponsor');
            iPhoneCallAttrib.CallAttendeeType = translateAttendeeType(callAttributesPrams.get('CallAttendeeType'));
            if(callAttributesPrams.get('CallDateTime') != null){
                iPhoneCallAttrib.CallDateTime = Datetime.valueOf(callAttributesPrams.get('CallDateTime'));
            }
            if(callAttributesPrams.get('ContractedServices') != null){
                iPhoneCallAttrib.ContractedServices = Boolean.valueOf(callAttributesPrams.get('ContractedServices'));
            }
            iPhoneCallAttrib.Disclaimer = callAttributesPrams.get('Disclaimer');
            iPhoneCallAttrib.GroupMeetingTopic = callAttributesPrams.get('GroupMeetingTopic');
            iPhoneCallAttrib.id = callAttributesPrams.get('Id');
            iPhoneCallAttrib.InteractionLocation = callAttributesPrams.get('InteractionLocation');
            iPhoneCallAttrib.InteractionMethod = callAttributesPrams.get('InteractionMethod');
            iPhoneCallAttrib.InteractionType = callAttributesPrams.get('InteractionType');
            if(callAttributesPrams.get('IsComplete') != null){
                iPhoneCallAttrib.IsComplete = Boolean.valueOf(callAttributesPrams.get('IsComplete'));
            }
            iPhoneCallAttrib.LicenseNumber = callAttributesPrams.get('LicenseNumber');
            if(callAttributesPrams.get('MealActualAttendeeCount') != null){
                iPhoneCallAttrib.MealActualAttendeeCount = Integer.valueOf(callAttributesPrams.get('MealActualAttendeeCount'));
            }
            if(callAttributesPrams.get('MealAmount') != null){
                iPhoneCallAttrib.MealAmount = Double.valueOf(callAttributesPrams.get('MealAmount'));
            }
            iPhoneCallAttrib.MealLocationCity = callAttributesPrams.get('MealLocationCity'); 
            iPhoneCallAttrib.MealLocationState = callAttributesPrams.get('MealLocationState');
            if(callAttributesPrams.get('MealPlannedAttendeeCount') != null){
                iPhoneCallAttrib.MealPlannedAttendeeCount = Integer.valueOf(callAttributesPrams.get('MealPlannedAttendeeCount'));
            } 
            if(callAttributesPrams.get('NumOfCustomersPresent') != null){
                iPhoneCallAttrib.NumOfCustomersPresent = Integer.valueOf(callAttributesPrams.get('NumOfCustomersPresent'));
            }
            iPhoneCallAttrib.OwnerId = callAttributesPrams.get('OwnerId'); 
            iPhoneCallAttrib.PrimaryInteractionReason = callAttributesPrams.get('PrimaryInteractionReason');
            if(callAttributesPrams.get('Reactive') != null){
                iPhoneCallAttrib.Reactive = Boolean.valueOf(callAttributesPrams.get('Reactive'));
            }
            iPhoneCallAttrib.RequestId = callAttributesPrams.get('RequestId');
            iPhoneCallAttrib.Resolution = callAttributesPrams.get('Resolution'); 
            iPhoneCallAttrib.ResponseTime = callAttributesPrams.get('ResponseTime'); 
            iPhoneCallAttrib.SampleReceiver = callAttributesPrams.get('SampleReceiver'); 
            iPhoneCallAttrib.Signature = callAttributesPrams.get('Signature');
            if(callAttributesPrams.get('SignatureDate') != null){
                iPhoneCallAttrib.SignatureDate = Datetime.valueOf(callAttributesPrams.get('SignatureDate'));
            }
            iPhoneCallAttrib.SpeakerProgram = callAttributesPrams.get('SpeakerProgram'); 
            iPhoneCallAttrib.SpendUser = callAttributesPrams.get('SpendUser'); 
            iPhoneCallAttrib.TerritoryName = callAttributesPrams.get('TerritoryName');
            iPhoneCallAttrib.TopicsAddressed = callAttributesPrams.get('TopicsAddressed'); 
            if(callAttributesPrams.get('ValidationEngine') != null){
                iPhoneCallAttrib.ValidationEngine = Boolean.valueOf(callAttributesPrams.get('ValidationEngine'));
            }
            iPhoneCallAttrib.callKeyMessageList = callKeyMessages;
            iPhoneCallAttrib.callSampleList = callSamples;
            iPhoneCallAttrib.callDiscussionList = callDiscussions;
            
            
            iPhoneCallAttrib.callAttendeeList = callAttendees;
            iPhoneCallAttrib.callDetailList = callDetails;
            
            if(callAttributesPrams.get('isFRM') != null){
                iPhoneCallAttrib.isFRM = Boolean.valueOf(callAttributesPrams.get('isFRM'));
            }
            if(callAttributesPrams.get('isMSL') != null){
                iPhoneCallAttrib.isMSL = Boolean.valueOf(callAttributesPrams.get('isMSL'));
            }
            iPhoneCallAttrib.isVisitReason = callAttributesPrams.get('isVisitReason');
            if(callAttributesPrams.get('UnwillingToMeet') != null)
            	iPhoneCallAttrib.UnwillingToMeet = Boolean.valueOf(callAttributesPrams.get('UnwillingToMeet'));
                       
            iPhoneCallAttribs.add(iPhoneCallAttrib);

        }
        
        return iPhoneCallAttribs;
    }
    
    private static String prepareAddressText(String callAttribute){
        String result;
        Integer firstFrame = callAttribute.indexOf('AddressText=');
        Integer lastFrame = callAttribute.indexOf(', BusinessSponsor=');
        if(firstFrame > -1 && lastFrame > -1){
                result= callAttribute.substring(firstFrame+12,lastFrame);
        }
        return result;
    }
    
    private static String removeAddressText(String callAttribute){
        String result = callAttribute;
        Integer firstFrame, lastFrame;
        String firstPart,lastPart;
        
        firstFrame = result.indexOf('AddressText=');
        lastFrame = callAttribute.indexOf(', BusinessSponsor=');
          

        if(firstFrame > -1 && lastFrame > -1){
            firstPart = result.substring(0,firstFrame);     
            lastPart = result.substring(lastFrame+2,result.length());
            result = firstPart+lastPart;
        }

        return result;
    }
    
    private static List<iPhoneApex.CallAttendee> prepareCallAttendeeList(String callAttribute){
        List<iPhoneApex.CallAttendee> callAttendees = new List<iPhoneApex.CallAttendee>();
        String allAttendeesInString = '';
        List<String> callAttendeesString = new List<String>();
        
        Integer firstFrame, lastFrame;
        firstFrame = callAttribute.indexOf('callAttendeeList=(')+18;
        lastFrame = callAttribute.indexOf(')',firstFrame);
        System.debug('firstFrame=>>>>'+firstFrame + '<<<');
        System.debug('lastFrame=>>>'+lastFrame + '<<<');
        System.debug('callAttribute=>>>>'+callAttribute + '<<<');
        if(firstFrame > -1 && lastFrame > -1){
                allAttendeesInString = callAttribute.substring(firstFrame,lastFrame);
        }       
        callAttendeesString = allAttendeesInString.split('iPhoneApex.CallAttendee:');
        
        for(String att : callAttendeesString){
            
            if(att==null || att =='' || att.length() < 10){
                continue;
            }

            att = substringFrames(att);
            Map<String,String> attendeePrams = mapParameters(att.trim());           
            
            iPhoneApex.CallAttendee iPhoneCallAttendee = new iPhoneApex.CallAttendee();           
            iPhoneCallAttendee.Attendee = attendeePrams.get('Attendee');
            iPhoneCallAttendee.CallAttendeeType = translateAttendeeType(attendeePrams.get('CallAttendeeType'));
            iPhoneCallAttendee.RequestId = attendeePrams.get('RequestId');
            callAttendees.add(iPhoneCallAttendee);

        }

        return callAttendees;
    }
    
    private static List<iPhoneApex.CallDetail> prepareCallDetailList(String callAttribute){
        
        System.debug('prepareCallDetailList.callAttribute=>>>'+ callAttribute + '<<<');
        
        List<iPhoneApex.CallDetail> callDetails = new List<iPhoneApex.CallDetail>();
        String allCallsInString = '';
        List<String> callDetailsString = new List<String>();
        
        Integer firstFrame, lastFrame;
        firstFrame = callAttribute.indexOf('callDetailList=(')+17;
        lastFrame = callAttribute.indexOf(')',firstFrame);
        if(firstFrame > -1 && lastFrame > -1){
                allCallsInString = callAttribute.substring(firstFrame,lastFrame);
        }       
        callDetailsString = allCallsInString.split('iPhoneApex.CallDetail:');
        
        System.debug('allCallsInString.size()=>>>'+ callDetailsString.size() + '<<<');
        
        for(String callDetailItem : callDetailsString){
            System.debug('callDetailItem=>>>'+ callDetailItem + '<<<');
            if(callDetailItem==null || callDetailItem =='' || callDetailItem.length() < 10){
                continue;
            }

            callDetailItem = substringFrames(callDetailItem);
            Map<String,String> callsPrams = mapParameters(callDetailItem.trim());           
            System.debug('callsPrams=>>>'+ callsPrams + '<<<');
            System.debug('callsPrams.get(DetailPriority)=>>>'+ callsPrams.get('DetailPriority') + '<<<');
            iPhoneApex.CallDetail iPhoneCallDetail = new iPhoneApex.CallDetail(); 
            iPhoneCallDetail.DetailPriority = callsPrams.get('DetailPriority');
            iPhoneCallDetail.DiseaseIndication = callsPrams.get('DiseaseIndication');
            iPhoneCallDetail.Product= callsPrams.get('Product');
            iPhoneCallDetail.RequestId = callsPrams.get('RequestId');
            iPhoneCallDetail.TherapeuticArea = callsPrams.get('TherapeuticArea');
            callDetails.add(iPhoneCallDetail);
        }

        return callDetails;
    
    }
    
    private static List<iPhoneApex.CallDiscussion> prepareCallDiscussionList(String callAttribute){
        List<iPhoneApex.CallDiscussion> callDiscussions = new List<iPhoneApex.CallDiscussion>();
        String allCallsInString = '';
        List<String> callDiscussionsString = new List<String>();
        
        Integer firstFrame, lastFrame;
        firstFrame = callAttribute.indexOf('callDiscussionList=(')+20;
        lastFrame = callAttribute.indexOf(')',firstFrame);
        if(firstFrame > -1 && lastFrame > -1){
                allCallsInString = callAttribute.substring(firstFrame,lastFrame);
        }       
        callDiscussionsString = allCallsInString.split('iPhoneApex.CallDetail:');
        
        for(String callDiscussionItem : callDiscussionsString){
            
            if(callDiscussionItem==null || callDiscussionItem =='' || callDiscussionItem.length() < 10){
                continue;
            }

            callDiscussionItem = substringFrames(callDiscussionItem);
            Map<String,String> callsPrams = mapParameters(callDiscussionItem.trim());           
            
            iPhoneApex.CallDiscussion iPhoneCallDiscussion = new iPhoneApex.CallDiscussion(); 
            iPhoneCallDiscussion.Product = callsPrams.get('Product');
            iPhoneCallDiscussion.ProductStrategy = callsPrams.get('ProductStrategy');
            iPhoneCallDiscussion.ProductTactic = callsPrams.get('ProductTactic');
            iPhoneCallDiscussion.Reaction = callsPrams.get('Reaction');
            iPhoneCallDiscussion.RequestId = callsPrams.get('RequestId');
            iPhoneCallDiscussion.Answer = callsPrams.get('Answer');
            iPhoneCallDiscussion.Question = callsPrams.get('Question');
            iPhoneCallDiscussion.Topic = callsPrams.get('Topic');
            iPhoneCallDiscussion.CurrentIssue = callsPrams.get('CurrentIssue');
            iPhoneCallDiscussion.Molecule = callsPrams.get('Molecule');
            if(callsPrams.get('NbrPatientsImpacted')!=null && callsPrams.get('NbrPatientsImpacted')!=''){
                iPhoneCallDiscussion.NbrPatientsImpacted = Integer.valueOf(callsPrams.get('NbrPatientsImpacted'));
            }
            callDiscussions.add(iPhoneCallDiscussion);
        }

        return callDiscussions;
    
    }
    
    
    //
    
    private static List<iPhoneApex.CallSample> prepareCallSampleList(String callAttribute){
        List<iPhoneApex.CallSample> callSamples = new List<iPhoneApex.CallSample>();
        String allCallsInString = '';
        List<String> callSamplesString = new List<String>();
        
        Integer firstFrame, lastFrame;
        firstFrame = callAttribute.indexOf('callSampleList=')+15;
        lastFrame = callAttribute.indexOf(')',firstFrame);
        System.debug('firstFrame=>>>>'+firstFrame + '<<<');
        System.debug('lastFrame=>>>'+lastFrame + '<<<');
        System.debug('callAttribute=>>>>'+callAttribute + '<<<');
        if(firstFrame > -1 && lastFrame > -1){
                allCallsInString = callAttribute.substring(firstFrame,lastFrame);
        }       
        callSamplesString = allCallsInString.split('iPhoneApex.CallSample:');
        
        for(String callSampleItem : callSamplesString){
            
            if(callSampleItem==null || callSampleItem =='' || callSampleItem.length() < 10){
                continue;
            }

            callSampleItem = substringFrames(callSampleItem);
            Map<String,String> callsPrams = mapParameters(callSampleItem.trim());           
            
            iPhoneApex.CallSample iPhoneCallSample = new iPhoneApex.CallSample(); 
            iPhoneCallSample.Account = callsPrams.get('Account');
            iPhoneCallSample.Product = callsPrams.get('Product');
            if(callsPrams.get('Quantity') != null && callsPrams.get('Quantity') != ''){
                iPhoneCallSample.Quantity = Double.valueOf(callsPrams.get('Quantity')); 
            }
            iPhoneCallSample.RequestId = callsPrams.get('RequestId');
            iPhoneCallSample.LotNo = callsPrams.get('LotNo');
            callSamples.add(iPhoneCallSample);
        }

        return callSamples;
    
    }

    private static List<iPhoneApex.CallKeyMessage> prepareCallKeyMessageList(String callAttribute){
        List<iPhoneApex.CallKeyMessage> callKeyMessages = new List<iPhoneApex.CallKeyMessage>();
        String allCallsInString = '';
        List<String> callKeyMessagesString = new List<String>();
        
        Integer firstFrame, lastFrame;
        firstFrame = callAttribute.indexOf('callKeyMessageList=(') + 20;
        lastFrame = callAttribute.indexOf(')',firstFrame);
        if(firstFrame > -1 && lastFrame > -1){
                allCallsInString = callAttribute.substring(firstFrame,lastFrame);
        }       
        callKeyMessagesString = allCallsInString.split('iPhoneApex.CallKeyMessage:');
        
        for(String callKeyMessageItem : callKeyMessagesString){
            
            if(callKeyMessageItem==null || callKeyMessageItem =='' || callKeyMessageItem.length() < 10){
                continue;
            }

            callKeyMessageItem = substringFrames(callKeyMessageItem);
            Map<String,String> callsPrams = mapParameters(callKeyMessageItem.trim());           
            
            iPhoneApex.CallKeyMessage iPhoneCallKeyMessage = new iPhoneApex.CallKeyMessage(); 
            iPhoneCallKeyMessage.Account = callsPrams.get('Account');
            iPhoneCallKeyMessage.KeyMessage = callsPrams.get('KeyMessage');
            iPhoneCallKeyMessage.Reaction = callsPrams.get('Reaction');
            iPhoneCallKeyMessage.RequestId = callsPrams.get('RequestId');
            callKeyMessages.add(iPhoneCallKeyMessage);
        }

        return callKeyMessages;
    
    }
    
    private static String substringFrames(String data){
        String result = data;
        Integer firstFrame, lastFrame;
        firstFrame = data.indexOf('[');
        lastFrame = data.lastIndexOf(']');
        if(firstFrame > -1 && lastFrame > -1){
            result = data.substring(firstFrame+1,lastFrame);
        }
        return result;
    }
    
    private static Map<String,String> mapParameters(String data){
        System.debug('mapParameters=['+data+']');
        
        Map<String,String> results = new Map<String,String>();
        List<String> params = data.split(',');
        for(String param : params){
            if(param == null || param == ''){
                continue;
            }
            System.debug('param='+param);
            List<String> keyValus = param.split('=');
            System.debug('keyValus.size()=>>>'+keyValus.size()+'<<<<');
            
            if(keyValus.size() == 2 && keyValus.get(1).trim() != '' && keyValus.get(1).trim() != 'null'){
                results.put(keyValus.get(0).trim(),keyValus.get(1));
            }
            
        }
        
        return results;
    }
    
    private static String removeDataElement(String data, String pattern){
        String result = data;
        Integer firstFrame, lastFrame;
        firstFrame = result.indexOf(pattern+'=(');
        lastFrame = result.indexOf(')',firstFrame);
        String firstPart,lastPart;  

        if(firstFrame > -1 && lastFrame > -1){
            firstPart = result.substring(0,firstFrame);     
            lastPart = result.substring(lastFrame+2,result.length());
            result = firstPart+lastPart;
        }

        return result;
    }
    
    private static iPhoneApex.AttendeeType translateAttendeeType(String attendeeType){
        System.debug('attendeeType=['+attendeeType+']');
        if(attendeeType==null){
            return iPhoneApex.AttendeeType.USER;
        }
        if(attendeeType.trim() == 'PERSONACCOUNT'){
            return iPhoneApex.AttendeeType.PERSONACCOUNT;
        } else if(attendeeType.trim() == 'ACCOUNT'){
            return iPhoneApex.AttendeeType.ACCOUNT;
        } else if (attendeeType.trim() == 'CONTACT') {
            return iPhoneApex.AttendeeType.CONTACT;
        } else {
            return iPhoneApex.AttendeeType.USER;
        }
    
    }

    public PageReference test(){
            User objOwner;
            Account objAccount;
            Address_vod__c objAddress;
            Product_vod__c objProduct;
              
            try
            {
                /*
                //call
                iPhoneApex.CallAttributes iPhoneCallAttrib = new iPhoneApex.CallAttributes();
                iPhoneCallAttrib.Account                = '0017000000XttvGAAR';   
                iPhoneCallAttrib.AdditionalNotes        = null;    
                iPhoneCallAttrib.Address                = 'a017000000FgKaMAAV';            
                iPhoneCallAttrib.AddressText            = '36000 Euclid Ave;Willoughby, OH 44094-4625';
                iPhoneCallAttrib.CallAttendeeType       = iPhoneApex.AttendeeType.ACCOUNT;
                iPhoneCallAttrib.CallDateTime           = DateTime.now();
                iPhoneCallAttrib.BusinessSponsor        = null;
                iPhoneCallAttrib.ContractedServices     = null;
                iPhoneCallAttrib.Disclaimer             = null;
                iPhoneCallAttrib.GroupMeetingTopic      = null;
                iPhoneCallAttrib.id                     = null;
                iPhoneCallAttrib.InteractionLocation    = null;
                iPhoneCallAttrib.InteractionMethod      = null;
                iPhoneCallAttrib.InteractionType        = 'Office Appt/Drop In';
                iPhoneCallAttrib.IsComplete             = true;
                iPhoneCallAttrib.LicenseNumber          = null;
                iPhoneCallAttrib.MealActualAttendeeCount = null;
                iPhoneCallAttrib.MealAmount             =null;
                iPhoneCallAttrib.MealLocationCity           =null; 
                iPhoneCallAttrib.MealLocationState=null;
                iPhoneCallAttrib.MealPlannedAttendeeCount=null;
                iPhoneCallAttrib.NumOfCustomersPresent=1;
                iPhoneCallAttrib.OwnerId                = null; 
                iPhoneCallAttrib.PrimaryInteractionReason=null;
                iPhoneCallAttrib.Reactive=null;
                iPhoneCallAttrib.RequestId              = 'INTtimac201012101702561657';
                iPhoneCallAttrib.Resolution=null; 
                iPhoneCallAttrib.ResponseTime=null; 
                iPhoneCallAttrib.SampleReceiver=null; 
                iPhoneCallAttrib.Signature              = null;
                iPhoneCallAttrib.SignatureDate          = null; 
                iPhoneCallAttrib.SpeakerProgram=null; 
                iPhoneCallAttrib.SpendUser=null; 
                iPhoneCallAttrib.TerritoryName=null;
                iPhoneCallAttrib.TopicsAddressed=null; 
                iPhoneCallAttrib.ValidationEngine=null; 
                
                //attendees
                List<iPhoneApex.CallAttendee> iPhoneCallAttendeeList= new List<iPhoneApex.CallAttendee>();
                            
                iPhoneApex.CallAttendee iPhoneCallAttendee1 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee1.Attendee    = '0017000000bG4jgAAC';
                iPhoneCallAttendee1.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee1.RequestId   = 'ATTtimac201012101703249511';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee1);    
                iPhoneCallAttrib.callAttendeeList = iPhoneCallAttendeeList;
                
                //CallDetail
                List<iPhoneApex.CallDetail> iPhoneCallDetailList= new List<iPhoneApex.CallDetail>(); 
                
                iPhoneApex.CallDetail iPhoneCallDetail1 = new iPhoneApex.CallDetail(); 
                iPhoneCallDetail1.DetailPriority = '1';
                iPhoneCallDetail1.DiseaseIndication = null;
                iPhoneCallDetail1.Product= 'a007000000Ai4XMAAZ';
                iPhoneCallDetail1.RequestId = 'DETtimac201012101702561650';
                iPhoneCallDetail1.TherapeuticArea = null;
                iPhoneCallDetailList.add(iPhoneCallDetail1);
                iPhoneCallAttrib.callDetailList=iPhoneCallDetailList;
                */
                /*
                //call
                iPhoneApex.CallAttributes iPhoneCallAttrib = new iPhoneApex.CallAttributes();
                iPhoneCallAttrib.Account                = '0017000000WdH4gAAF';   
                iPhoneCallAttrib.AdditionalNotes        = null;    
                iPhoneCallAttrib.Address                = 'a017000000FOS1nAAH';            
                iPhoneCallAttrib.AddressText            = '1423 Chicago Rd;Chicago Heights, IL 60411';
                iPhoneCallAttrib.CallAttendeeType       = iPhoneApex.AttendeeType.ACCOUNT;
                iPhoneCallAttrib.CallDateTime           = DateTime.now();
                iPhoneCallAttrib.BusinessSponsor        = null;
                iPhoneCallAttrib.ContractedServices     = null;
                iPhoneCallAttrib.Disclaimer             = null;
                iPhoneCallAttrib.GroupMeetingTopic      = null;
                iPhoneCallAttrib.id                     = null;
                iPhoneCallAttrib.InteractionLocation    = null;
                iPhoneCallAttrib.InteractionMethod      = null;
                iPhoneCallAttrib.InteractionType        = 'Office Appt/Drop In';
                iPhoneCallAttrib.IsComplete             = true;
                iPhoneCallAttrib.LicenseNumber          = null;
                iPhoneCallAttrib.MealActualAttendeeCount = null;
                iPhoneCallAttrib.MealAmount             =null;
                iPhoneCallAttrib.MealLocationCity           =null; 
                iPhoneCallAttrib.MealLocationState=null;
                iPhoneCallAttrib.MealPlannedAttendeeCount=null;
                iPhoneCallAttrib.NumOfCustomersPresent=0;
                iPhoneCallAttrib.OwnerId                = null; 
                iPhoneCallAttrib.PrimaryInteractionReason=null;
                iPhoneCallAttrib.Reactive=null;
                iPhoneCallAttrib.RequestId              = 'INTpothastm201102172148276410';
                iPhoneCallAttrib.Resolution=null; 
                iPhoneCallAttrib.ResponseTime=null; 
                iPhoneCallAttrib.SampleReceiver=null; 
                iPhoneCallAttrib.Signature              = null;
                iPhoneCallAttrib.SignatureDate          = null; 
                iPhoneCallAttrib.SpeakerProgram=null; 
                iPhoneCallAttrib.SpendUser=null; 
                iPhoneCallAttrib.TerritoryName='00L1507-Chicago South';
                iPhoneCallAttrib.TopicsAddressed=null; 
                iPhoneCallAttrib.ValidationEngine=null; 
                
                //attendees
                List<iPhoneApex.CallAttendee> iPhoneCallAttendeeList= new List<iPhoneApex.CallAttendee>();
                            
                iPhoneApex.CallAttendee iPhoneCallAttendee1 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee1.Attendee    = '0017000000dv0rcAAA';
                iPhoneCallAttendee1.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee1.RequestId   = 'ATTpothastm201102172148281281';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee1);   
                
                iPhoneApex.CallAttendee iPhoneCallAttendee2 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee2.Attendee    = '0017000000WdAr4AAF';
                iPhoneCallAttendee2.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee2.RequestId   = 'ATTpothastm201102172148281282';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee2);   
                iPhoneCallAttrib.callAttendeeList = iPhoneCallAttendeeList;
                
                //CallDetail
                List<iPhoneApex.CallDetail> iPhoneCallDetailList= new List<iPhoneApex.CallDetail>(); 
                
                iPhoneApex.CallDetail iPhoneCallDetail1 = new iPhoneApex.CallDetail(); 
                iPhoneCallDetail1.DetailPriority = '1';
                iPhoneCallDetail1.DiseaseIndication = null;
                iPhoneCallDetail1.Product= 'a007000000Ai4XMAAZ';
                iPhoneCallDetail1.RequestId = 'DETpothastm201102172148276420';
                iPhoneCallDetail1.TherapeuticArea = null;
                iPhoneCallDetailList.add(iPhoneCallDetail1);
                iPhoneCallAttrib.callDetailList=iPhoneCallDetailList;
    
                //call
                iPhoneApex.CallAttributes iPhoneCallAttrib = new iPhoneApex.CallAttributes();
                iPhoneCallAttrib.Account                = '0017000000OYNnGAAX';   
                iPhoneCallAttrib.AdditionalNotes        = null;    
                iPhoneCallAttrib.Address                = 'a017000000Ga63tAAB';            
                iPhoneCallAttrib.AddressText            = '1000 Salem Rd;Willingboro, NJ 08046-2852';
                iPhoneCallAttrib.CallAttendeeType       = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttrib.CallDateTime           = DateTime.now();
                iPhoneCallAttrib.BusinessSponsor        = null;
                iPhoneCallAttrib.ContractedServices     = null;
                iPhoneCallAttrib.Disclaimer             = null;
                iPhoneCallAttrib.GroupMeetingTopic      = null;
                iPhoneCallAttrib.id                     = null;
                iPhoneCallAttrib.InteractionLocation    = null;
                iPhoneCallAttrib.InteractionMethod      = null;
                iPhoneCallAttrib.InteractionType        = 'Office Appt/Drop In';
                iPhoneCallAttrib.IsComplete             = true;
                iPhoneCallAttrib.LicenseNumber          = null;
                iPhoneCallAttrib.MealActualAttendeeCount = 14;
                iPhoneCallAttrib.MealAmount             =null;
                iPhoneCallAttrib.MealLocationCity           =null; 
                iPhoneCallAttrib.MealLocationState=null;
                iPhoneCallAttrib.MealPlannedAttendeeCount=null;
                iPhoneCallAttrib.NumOfCustomersPresent=0;
                iPhoneCallAttrib.OwnerId                = null; 
                iPhoneCallAttrib.PrimaryInteractionReason=null;
                iPhoneCallAttrib.Reactive=null;
                iPhoneCallAttrib.RequestId              = 'INTandys201102232142251554';
                iPhoneCallAttrib.Resolution=null; 
                iPhoneCallAttrib.ResponseTime=null; 
                iPhoneCallAttrib.SampleReceiver=null; 
                iPhoneCallAttrib.Signature              = null;
                iPhoneCallAttrib.SignatureDate          = null; 
                iPhoneCallAttrib.SpeakerProgram=null; 
                iPhoneCallAttrib.SpendUser=null; 
                iPhoneCallAttrib.TerritoryName='00B2206-Toms River, NJ';
                iPhoneCallAttrib.TopicsAddressed=null; 
                iPhoneCallAttrib.ValidationEngine=null; 
                
                //attendees
                List<iPhoneApex.CallAttendee> iPhoneCallAttendeeList= new List<iPhoneApex.CallAttendee>();
                            
                iPhoneApex.CallAttendee iPhoneCallAttendee1 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee1.Attendee    = '0017000000dMQ8PAAW';
                iPhoneCallAttendee1.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee1.RequestId   = 'ATTandys201102232142260821';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee1);   
               
                iPhoneCallAttrib.callAttendeeList = iPhoneCallAttendeeList;
                
                //CallDetail
                List<iPhoneApex.CallDetail> iPhoneCallDetailList= new List<iPhoneApex.CallDetail>(); 
                
                iPhoneApex.CallDetail iPhoneCallDetail1 = new iPhoneApex.CallDetail(); 
                iPhoneCallDetail1.DetailPriority = '1';
                iPhoneCallDetail1.DiseaseIndication = null;
                iPhoneCallDetail1.Product= 'a007000000CJA0YAAX';
                iPhoneCallDetail1.RequestId = 'DETandys201102232142251560';
                iPhoneCallDetail1.TherapeuticArea = null;
                iPhoneCallDetailList.add(iPhoneCallDetail1);
                iPhoneCallAttrib.callDetailList=iPhoneCallDetailList;*/
                
                //Call Attributes 
                iPhoneApex.CallAttributes iPhoneCallAttrib = new iPhoneApex.CallAttributes();
                iPhoneCallAttrib.Account                = '0017000000XciW4AAJ';//'0017000000Sw5EGAAZ';   
                iPhoneCallAttrib.AdditionalNotes        = null;    
                iPhoneCallAttrib.Address                = 'a017000000Db22xAAB';            
                iPhoneCallAttrib.AddressText            = '1200 Garden View Rd;Encinitas, CA 92024-2475';
                iPhoneCallAttrib.BusinessSponsor     = null;
                iPhoneCallAttrib.CallAttendeeType       = iPhoneApex.AttendeeType.ACCOUNT;
                iPhoneCallAttrib.CallDateTime           = DateTime.now();
                iPhoneCallAttrib.ContractedServices    = null;
                iPhoneCallAttrib.Disclaimer             = null;
                iPhoneCallAttrib.GroupMeetingTopic    = null;
                iPhoneCallAttrib.id           = null;
                iPhoneCallAttrib.InteractionLocation   = null;
                iPhoneCallAttrib.InteractionMethod     = null;
                iPhoneCallAttrib.InteractionType        = 'In Service';
                iPhoneCallAttrib.IsComplete             = true;
                iPhoneCallAttrib.LicenseNumber          = null;
                iPhoneCallAttrib.MealActualAttendeeCount = 16;
                iPhoneCallAttrib.MealAmount        =null;
                iPhoneCallAttrib.MealLocationCity      =null; 
                iPhoneCallAttrib.MealLocationState=null;
                iPhoneCallAttrib.MealPlannedAttendeeCount=18;
                iPhoneCallAttrib.NumOfCustomersPresent  =null;
                iPhoneCallAttrib.OwnerId                = null; 
                iPhoneCallAttrib.PrimaryInteractionReason=null;
                iPhoneCallAttrib.Reactive=null;
                iPhoneCallAttrib.RequestId              = 'INTerins201102242301241225';
                iPhoneCallAttrib.Resolution=null; 
                iPhoneCallAttrib.ResponseTime=null; 
                iPhoneCallAttrib.SampleReceiver=null; 
                iPhoneCallAttrib.Signature              = null;
                iPhoneCallAttrib.SignatureDate          = null; 
                iPhoneCallAttrib.SpeakerProgram=null; 
                iPhoneCallAttrib.SpendUser=null; 
                iPhoneCallAttrib.TerritoryName=null;
                iPhoneCallAttrib.TopicsAddressed=null; 
                iPhoneCallAttrib.ValidationEngine=null;
                iPhoneCallAttrib.callDiscussionList = null;
                iPhoneCallAttrib.callKeyMessageList = null;
                iPhoneCallAttrib.callSampleList = null;
                iPhoneCallAttrib.isFRM = null;
                iPhoneCallAttrib.isMSL = null;
                iPhoneCallAttrib.isVisitReason = null;
                
                //attendees
                List<iPhoneApex.CallAttendee> iPhoneCallAttendeeList= new List<iPhoneApex.CallAttendee>();
                
                iPhoneApex.CallAttendee iPhoneCallAttendee1 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee1.Attendee    = '0017000000Yuvo5AAB';
                iPhoneCallAttendee1.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee1.RequestId   = 'ATTerins201102242301248461';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee1); 
                
                iPhoneApex.CallAttendee iPhoneCallAttendee2 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee2.Attendee    = '0017000000fT0qmAAC';
                iPhoneCallAttendee2.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee2.RequestId   = 'ATTerins201102242301248482';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee2); 
                
                iPhoneApex.CallAttendee iPhoneCallAttendee3 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee3.Attendee    = '0017000000Yuvi7AAB';
                iPhoneCallAttendee3.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee3.RequestId   = 'ATTerins201102242301248793';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee3); 
                
                iPhoneApex.CallAttendee iPhoneCallAttendee4 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee4.Attendee    = '0017000000Yuvo3AAB';
                iPhoneCallAttendee4.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee4.RequestId   = 'ATTerins201102242301248814';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee4); 
                
                iPhoneApex.CallAttendee iPhoneCallAttendee5 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee5.Attendee    = '0017000000OYMHtAAP';
                iPhoneCallAttendee5.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee5.RequestId   = 'ATTerins201102242301248825';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee5); 
                
                iPhoneApex.CallAttendee iPhoneCallAttendee6 = new iPhoneApex.CallAttendee();           
                iPhoneCallAttendee6.Attendee    = '0017000000YuvoXAAR';
                iPhoneCallAttendee6.CallAttendeeType    = iPhoneApex.AttendeeType.PERSONACCOUNT;
                iPhoneCallAttendee6.RequestId   = 'ATTerins201102242301248876';
                iPhoneCallAttendeeList.add(iPhoneCallAttendee6); 
                   
                iPhoneCallAttrib.callAttendeeList = iPhoneCallAttendeeList;
                
                //CallDetail
                List<iPhoneApex.CallDetail> iPhoneCallDetailList= new List<iPhoneApex.CallDetail>(); 
                
                iPhoneApex.CallDetail iPhoneCallDetail1 = new iPhoneApex.CallDetail(); 
                iPhoneCallDetail1.DetailPriority = '3';
                iPhoneCallDetail1.DiseaseIndication = null;
                iPhoneCallDetail1.Product= 'a0070000009miyKAAQ';
                iPhoneCallDetail1.RequestId = 'DETerins201102242301241230';
                iPhoneCallDetail1.TherapeuticArea = null;
                iPhoneCallDetailList.add(iPhoneCallDetail1);
                
                iPhoneApex.CallDetail iPhoneCallDetail2 = new iPhoneApex.CallDetail(); 
                iPhoneCallDetail2.DetailPriority = '2';
                iPhoneCallDetail2.DiseaseIndication = null;
                iPhoneCallDetail2.Product= 'a0070000009miyLAAQ';
                iPhoneCallDetail2.RequestId = 'DETerins201102242301241241';
                iPhoneCallDetail2.TherapeuticArea = null;
                iPhoneCallDetailList.add(iPhoneCallDetail2);
                
                iPhoneApex.CallDetail iPhoneCallDetail3 = new iPhoneApex.CallDetail(); 
                iPhoneCallDetail3.DetailPriority = '1';
                iPhoneCallDetail3.DiseaseIndication = null;
                iPhoneCallDetail3.Product= 'a0070000009miyMAAQ';
                iPhoneCallDetail3.RequestId = 'DETerins201102242301241242';
                iPhoneCallDetail3.TherapeuticArea = null;
                iPhoneCallDetailList.add(iPhoneCallDetail3);
                
                iPhoneCallAttrib.callDetailList=iPhoneCallDetailList; 
                
                
                //callDiscussionList
                //callKeyMessageList
                //callSampleList
                //isFRM=null
                //isMSL=null
                //isVisitReason=null 
                
                iPhoneApex.Response iPhoneCallResponse = new iPhoneApex.Response();
                iPhoneCallResponse = iPhoneApex.updateOrCreateCall(iPhoneCallAttrib);
                
                Integer i = 0;          
                while ((i < iPhoneCallResponse.RequestIdResponseIdList.size()) && (iPhoneCallResponse.RequestIdResponseIdList[i].ObjectType <> 'Call2_vod__c')) {
                    i++;
                }                                                     
            } catch (Exception e) {  
                ApexPages.addMessages(e);
                return null;                                               
            }
            return null;
    }
    
}