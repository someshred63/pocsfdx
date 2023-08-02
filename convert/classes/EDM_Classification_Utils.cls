public class EDM_Classification_Utils{

	public EDM_Classification_Utils(){}

    public static Integer workingDaysBetweenTwoDates(Date firstDate, Date secondDate, List<Actual_Working_Days_gne__c> workingDaysList){
        Integer days=0;
        for(Actual_Working_Days_gne__c wd : workingDaysList){
            if(wd.Date_gne__c > firstDate && wd.Date_gne__c < secondDate){
                days++;
            }
        }       
        return days;
    }

    public static List<Messaging.EmailFileAttachment> objectAttachments(Id objId,List<Attachment> attachments){
        List<Messaging.EmailFileAttachment> objAtt= new List<Messaging.EmailFileAttachment>();
        Integer attachmentSizeSum=0;
        for(Attachment att : attachments){      
            //3145728 = 3MB, 10485760 = 10MB      
            if(att.ParentId==objId && att.BodyLength<=3145728 && attachmentSizeSum+att.BodyLength<=10485760){
                attachmentSizeSum+=att.BodyLength;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setBody(att.Body);
                efa.setContentType(att.ContentType);
                efa.setFileName(att.Name);
                efa.setInline(false);
                objAtt.add(efa);
            }
        }
        return objAtt;
    }

    public static List<SelectOption> getPickListValues(Schema.sObjectType sObjType, String fieldName) {
        Schema.DescribeSObjectResult descSObjectResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = descSObjectResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();

        for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new selectOption(entry.getLabel(), entry.getValue()));
        }

        return options;
    }

    public static String getReturnURL() {
        return ApexPages.currentPage().getParameters().get('retURL');
    }

    public static String getReturnURL(Id idWhenRetURLIsEmpty) {
        String retURL = getReturnURL();
        if (String.isBlank(retURL)) {
            retURL = '/' + idWhenRetURLIsEmpty;
        }
        return retURL;
    }

    public static PageReference createPageRef(String url) {
        PageReference pr = new PageReference(url);
        pr.setRedirect(true);
        return pr;
    }

    public static Boolean checkIfPendingClassificationRequest(Id accountId, String typeOfClassification) {
        List<EDM_Classification_Request_gne__c> pendingClassificationRequests = [
                SELECT Id
                FROM EDM_Classification_Request_gne__c
                WHERE EDM_Account_gne__c = :accountId and
                    EDM_Type_of_Classification_gne__c = :typeOfClassification and
                    EDM_Status_gne__c != 'Completed'
                LIMIT 1];
        return !pendingClassificationRequests.isEmpty();
    }

    public static Date getPendingClassificationRequestDate(Id accountId, String typeOfClassification) {
        List<EDM_Classification_Request_gne__c> pendingClassificationRequests = [
                SELECT CreatedDate
                FROM EDM_Classification_Request_gne__c
                WHERE EDM_Account_gne__c = :accountId and
                    EDM_Type_of_Classification_gne__c = :typeOfClassification and
                    EDM_Status_gne__c != 'Completed'
                LIMIT 1];
        if(!pendingClassificationRequests.isEmpty()){
            return pendingClassificationRequests[0].CreatedDate.date();
        } else {
            return null;
        }
    }

    public static Map<String, EDM_Classification_Request_gne__c> getPendingClassificationRequestsByTypes(Id accountId) {
        List<EDM_Classification_Request_gne__c> pendingClassificationRequests = [
                SELECT Id, CreatedDate, EDM_Type_of_Classification_gne__c
                FROM EDM_Classification_Request_gne__c
                WHERE EDM_Account_gne__c = :accountId AND                    
                    EDM_Status_gne__c != 'Completed'
                ORDER BY CreatedDate];

        Map<String, EDM_Classification_Request_gne__c> classificationRequestsByTypes = new Map<String, EDM_Classification_Request_gne__c>();
        for (EDM_Classification_Request_gne__c cr : pendingClassificationRequests) {
            classificationRequestsByTypes.put(cr.EDM_Type_of_Classification_gne__c, cr);
        }
        return classificationRequestsByTypes;
    }

    public static String getEDMClassification(Account account, String speakerBureauType) {
        String classification;
        Id accountId = account.Id;
        
        if (speakerBureauType == 'Clinical') {
            classification = account.EDM_Clinical_Classification_gne__c;
        } else {
            classification = account.EDM_Business_Classification_gne__c;
        }

        if ((classification == 'Not Classified' || String.isEmpty(classification)) && EDM_Classification_Utils.checkIfPendingClassificationRequest(accountId, speakerBureauType)) {
            classification = 'Classification Pending';
        }

        if(account.Professional_Type_gne__c == 'Patient Ambassador') {
            classification = 'Not Applicable';
        }
        system.debug('### classification:'+classification+' sbt:'+speakerBureauType);
        return classification;
    }

    public static String prepareLinkToAttachment(Attachment attach) {
        String viewURL = '/servlet/servlet.FileDownload?file=';
        return viewURL + attach.Id;
    }

    public static Boolean insertAttachment(Attachment attach, Id parentId) {
        if(attach.body != null) {
            attach.ParentId = parentId;
            insert attach;
            return true;
        }
        return false;
    }
}