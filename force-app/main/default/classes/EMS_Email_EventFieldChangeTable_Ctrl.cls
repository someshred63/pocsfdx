public with sharing class EMS_Email_EventFieldChangeTable_Ctrl {
    public Id eventId { get; set; }
    public String eventSysName { get; set; }
    public String eventName { get; set; }
    public String eventStatus { get; set; }
    public String agendaActual { get; set; }
    public String agendaPrev { get; set; }

    public List<historyWrapper> getChangedFieldsList() {
        List<EMS_Event__History> eventHistory = new List<EMS_Event__History>();
        List<historyWrapper> historyWrapperList = new List<historyWrapper>();
        List<String> watchedFields = new List<String>{
                'Start_Date_gne__c', 'End_Date_gne__c', 'Agenda_Comments_gne__c'
        };

        eventHistory = [
                SELECT Id, CreatedById, CreatedDate, Field, NewValue, OldValue, ParentId
                FROM EMS_Event__History
                WHERE Field IN :watchedFields AND ParentId = :eventId
                ORDER BY CreatedDate DESC
        ];

        for (EMS_Event__History eh : eventHistory) {
            if (eh.CreatedDate == eventHistory.get(0).CreatedDate) {
                historyWrapper hw = new historyWrapper(eh.CreatedById, eh.CreatedDate, eh.Field, eh.OldValue, eh.NewValue, agendaPrev, agendaActual);
                historyWrapperList.add(hw);
            }
        }

        return historyWrapperList;
    }

    public class historyWrapper {
        public Id createdById { get; set; }
        public String createdDate { get; set; }
        public String field { get; set; }
        public String oldValue { get; set; }
        public String newValue { get; set; }

        public historyWrapper(Id createdById, DateTime createdDate, String field, Object oldValue, Object newValue, String agendaPrev, String agendaActual) {
            String fieldType = String.valueOf(Schema.getGlobalDescribe().get('EMS_Event__c').getDescribe().fields.getMap().get(field).getDescribe().getType());
            String fieldLabel = Schema.getGlobalDescribe().get('EMS_Event__c').getDescribe().fields.getMap().get(field).getDescribe().getLabel();

            this.createdById = createdById;
            DateTime crDt = DateTime.valueOf(createdDate);
            this.createdDate = crDt.format('M/d/yyyy');
            this.field = fieldLabel;

            if (field == 'Agenda_Comments_gne__c') {
                this.oldValue = agendaPrev;
                this.newValue = agendaActual;
            } else if (fieldType == 'Date') {
                Date oldDt = Date.valueOf(oldValue);
                Date newDt = Date.valueOf(newValue);
                this.oldValue = String.valueOf(oldDt.month() + '/' + oldDt.day() + '/' + oldDt.year());
                this.newValue = String.valueOf(newDt.month() + '/' + newDt.day() + '/' + newDt.year());
            } else {
                this.oldValue = String.valueOf(oldValue);
                this.newValue = String.valueOf(newValue);
            }
        }
    }

}