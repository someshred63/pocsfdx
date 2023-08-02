global class CONGA_AttendanceProperties extends CONGA_Iproperties{
 	public ID eventId { get; set; }
 	public ID physicianId { get; set; }
 	public ID sponsorId { get; set; }
	public Integer attendanceStatus { get; set; } 
	public Long timestamp { get; set; }

	public CONGA_AttendanceProperties(){}
	
	public CONGA_AttendanceProperties(CONGA_Attendance_gne__c attendance){
		this.id = attendance.id; 
		this.eventId = attendance.Event__c; 
		this.physicianId = attendance.Physician__c; 
		this.sponsorId = attendance.Sponsor__c; 
		this.timestamp = attendance.LastModifiedDate.getTime(); 
		
		if (attendance.Attendance_Status__c == 'None')
			this.attendanceStatus = 0; 
		if (attendance.Attendance_Status__c == 'Maybe')
			this.attendanceStatus = 1; 
		if (attendance.Attendance_Status__c == 'Confirmed')
			this.attendanceStatus = 2;
	}
	
	private String getSFDCstatus(){
		if (this.attendanceStatus == 0)
			return 'None'; 
		if (this.attendanceStatus == 1)
			return 'Maybe';
		if (this.attendanceStatus == 2)
			return 'Confirmed';
		System.assert(false, 'AttendanceProperties had no appropriate status: ' + this.attendanceStatus);
		return '';  
	}
	
	
	public CONGA_Attendance_gne__c toAttendanceSobject(Boolean onlyNotNullFields){
		
		if (!onlyNotNullFields)
		{
			return new CONGA_Attendance_gne__c(
				id = this.id, 
				Event__c=this.eventId,
				Attendance_Status__c=this.getSFDCstatus(),
				Physician__c = this.physicianId,
				Sponsor__c = this.sponsorId,
				Timestamp__c = Datetime.newInstance(this.timestamp) 
				); 
		}
		
		CONGA_Attendance_gne__c retAttendance = new CONGA_Attendance_gne__c(  );
		if (this.physicianId != null)
		retAttendance.Physician__c = this.physicianId; 
		if(this.id != null)
		 retAttendance.id = this.id;  
		if(this.eventId != null)
		 retAttendance.Event__c=this.eventId;  
		if(this.attendanceStatus!= null)
		 retAttendance.Attendance_Status__c=this.getSFDCstatus();  
		retAttendance.Sponsor__c=this.sponsorId;  //to remove sponsorship there needs to be option to assign null to Sponsor__c field, that's why we do not check this.sponsorId != null before populating Sponsor__c
		if(this.timestamp != null)
		 retAttendance.Timestamp__c=Datetime.newInstance(this.timestamp);  
		String externalId =getExternalId(); 
		if (externalId!=null)
		 retAttendance.External_Id__c = externalId; 
				
		return retAttendance; 
	}
	
	
	public String getExternalId(){
		return physicianId != null && this.eventId != null ? ''+this.physicianId+'@'+this.eventId : null; 
	}
	



}