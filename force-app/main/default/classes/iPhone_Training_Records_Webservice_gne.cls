global class iPhone_Training_Records_Webservice_gne
{
    WebService DateTime lastSyncDate;

    global class Result
    {
        Webservice AccountTrainingRecords trainRecs;
    }
    global class AccountTrainingRecords
    {
        Webservice AccountTrainingRecordsRows rows;
    }
    global class AccountTrainingRecordsRows
    {
        Webservice Added added;
        Webservice Updated updated;
        Webservice String allIds = '';
    }
   global class Added{
       Webservice List<AccountTrainingRecordRow> row;
   }
   global class Updated{
       Webservice List<AccountTrainingRecordRow> row;
   }
   global class AccountTrainingRecordRow
    {
        Webservice String id;
        Webservice String curriculumName;
        Webservice Id currId;
        Webservice Id speakerId;
        Webservice String trainingStatus;
        Webservice String SpkrName;
        Webservice Date trainingDate;
        Webservice Date deactivationDate;
        Webservice List<String> prcCodes;
        Webservice String deliveryMethod;
        Webservice Id createdBy;
        Webservice String createdByName;
        Webservice String trainingId;
    }

    static List<Speaker_Training_gne__c> speakerTrainings(List<Id> acctIds)
    {
        List<Speaker_Training_gne__c> speakerTrainingList = new List<Speaker_Training_gne__c>();

        speakerTrainingList =
        [
            Select
            Id,
            Speaker_gne__c,

                     Speaker_gne__r.MDMId_gne__c,
            Name,
            CreatedBy.Id,
            CreatedBy.LastName,
            CreatedBy.FirstName,
            CreatedDate,
            LastmodifiedDate,
            Curriculum_Name__c,
            Curriculum_Status1__c,
            Trained_Date_gne__c,
            Training_Status_gne__c,
            Delivery_Method_gne__c,
            Event_Curriculum_gne__c,
            Speaker_gne__r.name,
            Event_Curriculum_gne__r.Deactivation_date_gne__c
            From
            Speaker_Training_gne__c where Speaker_gne__c in :acctIds //and Event_Curriculum_gne__r.Deactivation_date_gne__c > today
        ];
        return speakerTrainingList;
    }

    /**
     * List of all modules for matching PRC IDs
     */
    static List<Curriculum_Module_gne__c> modules(){
       List<Curriculum_Module_gne__c> modules = new List<Curriculum_Module_gne__c>();
       modules = [Select Id, PRC_Id_gne__c, event_curriculum_gne__c from curriculum_Module_gne__c];
       return modules;
    }
    /**
     * Assign all PRC Codes for Speakers Trainings Curriculum
     *
     *   row: Speaker Training Summary Record. Currid indicates Curriculum of training
     *   mod: List of all Training Modules
     */
    static void assignPRCs(AccountTrainingRecordRow row, List<Curriculum_Module_gne__c> mods){
       System.debug(' @@--%%--@@-: '+'assignPRCs '+ row);
       row.prcCodes = new List<String>();
       for(Curriculum_Module_gne__c mod: mods){
          if (mod.Event_Curriculum_gne__c == row.currId){
             System.debug('assignPRCs '+ row.currId +' : ' + mod.Event_Curriculum_gne__c);

             if (mod.PRC_ID_gne__c != null)
                row.prcCodes.add(mod.PRC_ID_gne__c);
          }
//          System.debug(' @@--%%--@@-: assignPRCs '+ row.currId +' : ' + mod.Event_Curriculum_gne__c);
       }
    }



    /**
     * Get Accounts and Aligns Dates for all user's territories
     */
    public static Map<Id,DateTime> acctAlignDates(Id uId){
       List<Territory2> terrs = new List<Territory2>();
       List<Group> grps = new List<Group>();
       List<AccountShare> shares = new List<AccountShare>();
       List<UserTerritory2Association> uts = new List<UserTerritory2Association>();


       uts = [Select Territory2Id from UserTerritory2Association where UserId = :uId];
       System.debug(' @@--%%--@@-:uts '+uts);
       List<Id>terrIds = new List<Id>();
       for(UserTerritory2Association uterr: uts)
         terrIds.add(uterr.Territory2Id);

       System.debug(' @@--%%--@@-:terrIds '+terrIds);
       if (terrIds.size() >0){
          grps = [Select Id from Group where relatedId in :terrIds];
          System.debug(' @@--%%--@@-:grps '+grps);
          List<Id>grpIds = new List<Id>();
          for(Group grp: grps)
            grpIds.add(grp.Id);
          shares =  [Select AccountId, LastModifiedDate from AccountShare where UserorGroupId in :grpIds];
       }
       System.debug(' @@--%%--@@-:shares '+shares);
       Map<Id,DateTime> aAndD = new Map<Id,DateTime>();
       for( AccountShare share: shares){
          aAndD.put(share.AccountId, share.LastModifiedDate);
       }

       return aAndD;
    }
    /**
     * Return Speaker Training Summarys for all Speakers in AccIds
     *   Returns only those created since lastSync Date
     */
    Webservice static Result returnSpeakerTrainings(Id userId, DateTime lastSyncDate)
    {
        Map<Id,DateTime> acctsAndDates = acctAlignDates(userId);
        Set<Id> acctIdsSet = new Set<Id>();
        acctIdsSet = acctsAndDates.keySet();
        List<Id> acctIds = new List<Id>();
        for(Id accId: acctIdsSet)
           acctIds.add(accId);

        System.debug(' @@--%%--@@-:Entry returnSpeakerTraining with '+acctIds);
        List<Speaker_Training_gne__c> spkrTrainings = speakerTrainings(acctIds);

        System.debug(' @@--%%--@@-: Speaker Trainings '+spkrTrainings);
        Result result_set_sync = new Result();
        result_set_sync.trainRecs = new AccountTrainingRecords();

        // Get list of all Curriculum Modules to lookup PRC Codes
        List<Curriculum_Module_gne__c> mods =modules();

        Integer trCounter = 0;
        result_set_sync.trainRecs.rows = new AccountTrainingRecordsRows();
        result_set_sync.trainRecs.rows.added = new Added();
        result_set_sync.trainRecs.rows.added.row = new List<AccountTrainingRecordRow>();
//        result_set_sync.trainRecs.rows.added = new List<AccountTrainingRecordRow>();
        result_set_sync.trainRecs.rows.updated = new Updated();
        result_set_sync.trainRecs.rows.updated.row = new List<AccountTrainingRecordRow>();
//        result_set_sync.trainRecs.updated = new List<AccountTrainingRecordRow>();
        for(Speaker_Training_gne__c training : spkrTrainings)
        {
            trCounter++;
            AccountTrainingRecordRow newRow = new AccountTrainingRecordRow();
            newRow.id = training.Id;
            newRow.curriculumName = training.Curriculum_Name__c;
            newRow.trainingStatus = training.Training_Status_gne__c;
            newRow.trainingDate = training.Trained_Date_gne__c;
            newRow.deactivationDate = training.Event_Curriculum_gne__r.Deactivation_date_gne__c;
            newRow.SpkrName = training.Speaker_gne__r.name;
            newRow.speakerId = training.Speaker_gne__c;
            newRow.currId = training.Event_Curriculum_gne__c;
            newRow.deliveryMethod = training.Delivery_Method_gne__c;
            newRow.createdBy = training.CreatedBy.Id;
            newRow.createdByName = training.CreatedBy.FirstName + ' ' + training.CreatedBy.LastName;
            newRow.trainingId = training.Name;
            assignPRCs(newRow, mods);
            System.debug(training.CreatedDate + ' --:-- '+training.LastmodifiedDate + ' --:-- '+ acctsAndDates.get(training.Speaker_gne__c).date()+ ' --:-- '+ lastSyncDate);
            if(lastSyncDate == null || training.CreatedDate >=lastSyncDate || acctsAndDates.get(training.Speaker_gne__c).date() >= lastSyncDate)
            {
                result_set_sync.trainRecs.rows.added.row.add(newRow);
            }
            else if(training.LastmodifiedDate >= lastSyncDate)
            {
                result_set_sync.trainRecs.rows.updated.row.add(newRow);
            }
            if(trCounter != spkrTrainings.size())
                result_set_sync.trainRecs.rows.allIds += newRow.id +',';
            else
                result_set_sync.trainRecs.rows.allIds += newRow.id;
        }
        return result_set_sync;
    }
    public static Result testMe(String unixId){
        Date dt = Date.newInstance(2010,06,12);
        User user = [Select id from user where external_id_gne__c = :unixId];
        Result resp = iPhone_Training_Records_Webservice_gne.returnSpeakerTrainings(user.Id, dt);

        System.debug('Added-size--:'+resp.trainRecs.rows.added.row.size());
        System.debug('Updated-size--:'+resp.trainRecs.rows.updated.row.size());
        System.debug(resp);
        for(AccountTrainingRecordRow row: resp.trainRecs.rows.added.row)
           System.debug('Added---:'+row);

        for(AccountTrainingRecordRow row2: resp.trainRecs.rows.updated.row)
           System.debug('Updated---:'+row2);

        System.debug('Result:@@@@###@@@:\n'+resp.toString());



        return resp;

    }

}