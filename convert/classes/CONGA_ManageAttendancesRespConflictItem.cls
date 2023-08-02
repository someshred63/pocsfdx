global class CONGA_ManageAttendancesRespConflictItem extends CONGA_ManageAttendancesRespBaseItem{
        public Integer attendanceStatus; 
        public Id eventId; 
        public Id physicianId; 
        public Id sponsorId; 
        public Long timestamp; 
    
    public CONGA_ManageAttendancesRespConflictItem(String Error, Integer Result, CONGA_Attendance_gne__c dbAttendance){
        super(result,error,dbAttendance.id);
        //this.error = error; 
        //this.result = result;
        
        this.attendanceStatus = new Map<String,Integer>{'Maybe'=>1, 'None' => 0, 'Confirmed'=>2}.get(dbAttendance.Attendance_Status__c);
        this.eventId = dbAttendance.Event__c;
        this.physicianId = dbAttendance.Physician__c;
        this.sponsorId = dbAttendance.Sponsor__c;
        this.timestamp = dbAttendance.Timestamp__c.getTime(); 
    }
}