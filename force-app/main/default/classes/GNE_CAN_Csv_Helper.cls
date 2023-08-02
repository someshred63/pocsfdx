public without sharing class GNE_CAN_Csv_Helper {

    public static final String SUBSCRIBE_ERRORS = 'Stg_SFA_Subscribe_Apex_Job_Error__c';
    public static final String SUBSCRIBE_JOB_FIELD_API_NAME = 'Job_Id_can__c';
    public static final String MERGE_ERROR = 'Merge_Type_Error_Log_gne__c';
    public static final String MERGE_JOB_FIELD_API_NAME = 'Merge_Type_Apex_Job_ref_gne__c';

    private Messaging.EmailFileAttachment attachment {get; set;}

    public GNE_CAN_Csv_Helper(String sObjectName, String jobId) {
        if(sObjectName.equals(SUBSCRIBE_ERRORS)) {
            BuildFileBasedOnSubscribedErrors subscribeErrors = new BuildFileBasedOnSubscribedErrors(jobId);
            this.attachment = subscribeErrors.attachment;
        } else if(sObjectName.equals(MERGE_ERROR)) {
            BuildFileBasedOnMergeErrors mergeErrors = new BuildFileBasedOnMergeErrors(jobId);
            this.attachment = mergeErrors.attachment;
        }
    }

    public Messaging.EmailFileAttachment getAttachment() {
        return this.attachment;
    }

    public abstract class BuildFile {
        public Messaging.EmailFileAttachment attachment {get; private set;}
        public abstract String createQueryString(String sObjectName, Set<String> fieldsApiNames, String jobFieldApiName, String jobId);
        public abstract String createFileBody(List<sObject> records);
        public abstract Messaging.EmailFileAttachment buildAttachment(String sObjectName, String fileBody);
        public abstract Messaging.EmailFileAttachment createCsvFile(String sObjectName, String jobId, Set<String> fieldsApiNames, String jobFieldApiName);
    }

    public virtual class BuildFileBase extends BuildFile {
        public Messaging.EmailFileAttachment attachment {get; private set;}

        public override virtual String createQueryString(String sObjectName, Set<String> fieldsApiNames, String jobFieldApiName, String jobId) {
            String queryString = 'SELECT ';
            for(Schema.sObjectField fieldApiName :Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values()) {
                if(fieldsApiNames.contains(String.valueOf(fieldApiName))) {
                    queryString += fieldApiName + ',';
                }
            }
            queryString = queryString.removeEnd(',');
            queryString += ' FROM ' + sObjectName;
            queryString += ' WHERE ' + jobFieldApiName +  ' = : jobId';
            return queryString;
        }
        public override virtual String createFileBody(List<sObject> records) {return null;}
        public override virtual Messaging.EmailFileAttachment buildAttachment(String sObjectName, String fileBody) {
            Messaging.EmailFileAttachment attachmentTmp = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(fileBody);
            attachmentTmp.setFileName(sObjectName + '.csv');
            attachmentTmp.setBody(csvBlob);
            return attachmentTmp;
        }
        public override virtual Messaging.EmailFileAttachment createCsvFile(String sObjectName, String jobId, Set<String> fieldsApiNames, String jobFieldApiName) {
            String fileBody = '';
            String queryString = this.createQueryString(sObjectName, fieldsApiNames, jobFieldApiName, jobId) ;
            List<sObject> queryResult = Database.query(queryString);
            fileBody = this.createFileBody(queryResult);
            return this.buildAttachment(sObjectName, fileBody);
        }
    }

    public class BuildFileBasedOnSubscribedErrors extends BuildFileBase {
        Set<String> fieldsToSelectConfig = new Set<String> {
                'Id', 'Code_Type_can__c', 'Error_Description_can__c', 'Error_Type_can__c', 'Object_Name_can__c',
                'Object_Type_can__c', 'Record_ID_can__c'};
        public BuildFileBasedOnSubscribedErrors(String jobId) {
            this.attachment = this.createCsvFile(SUBSCRIBE_ERRORS, jobId, fieldsToSelectConfig, SUBSCRIBE_JOB_FIELD_API_NAME);
        }

        public override String createFileBody(List<sObject> records) {
            String fileBodyTmp = '';
            String fileHeaderTmp = '';
            fileHeaderTmp = '"Id","Code_Type_can__c","Error_Description_can__c","Error_Type_can__c",' +
                    '"Object_Name_can__c",' + '"Object_Type_can__c","Record_ID_can__c"\n';

            fileBodyTmp += fileHeaderTmp;
            for(sObject rec : records) {
                String fileRecord = '';
                fileRecord = '"' + (String)rec.get('Id') + '","' + (String)rec.get('Code_Type_can__c') +
                        '","' + (String)rec.get('Error_Description_can__c') + '","' + (String)rec.get('Error_Type_can__c') +
                        '","' + (String)rec.get('Object_Name_can__c') + '","' + (String)rec.get('Object_Type_can__c')
                        + '","' + (String)rec.get('Record_ID_can__c') + '"' + '\n';
                fileBodyTmp += fileRecord;
            }

            return fileBodyTmp;
        }

    }

    public class BuildFileBasedOnMergeErrors extends BuildFileBase {
        Set<String> fieldsToSelectConfig = new Set<String>{
                'Id', 'Description_gne__c', 'Merge_Type_ref_gne__c', 'Merge_Type_Candidate_Stage_ref_gne__c',
                'Merge_Type_Unique_Name_calc_gne__c', 'Object_Name_calc_gne__c', 'Parent_Id_gne__c'
        };

        public BuildFileBasedOnMergeErrors(String jobId) {
            this.attachment = this.createCsvFile(MERGE_ERROR, jobId, fieldsToSelectConfig, MERGE_JOB_FIELD_API_NAME);
        }

        public override String createFileBody(List<sObject> records) {
            String fileBodyTmp = '';
            String fileHeaderTmp = '';
            fileHeaderTmp = '"Id","Description_gne__c","Merge_Type_ref_gne__c","Merge_Type_Candidate_Stage_ref_gne__c",' +
                    '"Merge_Type_Unique_Name_calc_gne__c","Object_Name_calc_gne__c","Parent_Id_gne__c"\n';

            fileBodyTmp += fileHeaderTmp;
            for(sObject rec : records) {
                String fileRecord = '';
                fileRecord = '"' + (String)rec.get('Id') + '","' + (String)rec.get('Description_gne__c') +
                        '","' + (String)rec.get('Merge_Type_ref_gne__c') + '","' + (String)rec.get('Merge_Type_Candidate_Stage_ref_gne__c') +
                        '","' + (String)rec.get('Merge_Type_Unique_Name_calc_gne__c') + '","' + (String)rec.get('Object_Name_calc_gne__c') +
                        '","' + (String)rec.get('Parent_Id_gne__c') + '"' + '\n';
                fileBodyTmp += fileRecord;
            }

            return fileBodyTmp;
        }

    }

}