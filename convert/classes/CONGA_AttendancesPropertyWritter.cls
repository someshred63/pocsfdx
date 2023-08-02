@RestResource(urlMapping='/manageAttendances/*')
global class CONGA_AttendancesPropertyWritter {
	public static final Integer DUPLICATE_IDENTIFIER_CODE = 501; 
	public static final String DUPLICATE_IDENTIFIER_MSG = 'There is another Attendance in request with the same Identifier or Primary Key(Physician@Event).'; 
	
	public static final Integer INVALID_EVENT_CODE = 405 ; 
	public static final String INVALID_EVENT_MSG = 'Event field is missing or is not valid.'; 
	public static final Integer MISSING_PHYSICIAN_CODE = 406 ; 
	public static final String MISSING_PHYSICIAN_MSG = 'Physician field is missing or is not valid.'; 
	public static final Integer MISSING_SPONSOR_CODE = 407 ; 
	public static final String MISSING_SPONSOR_MSG = 'Sponsor field is missing or is not valid.'; 
    public static final Integer MISSING_KEY_CODE = 408 ; 
	public static final String MISSING_KEY_MSG = 'id is empty or EventID and PhysicianID are missing'; 
	
	public static final Integer OK_CODE = 200; 
	public static final String OK_MSG = 'OK '; 
	public static final Integer INTERNAL_ERR_CODE = 500 ; 
	public static final String INTERNAL_ERR_MSG = 'Unknown internal error: '; 
	
	
	public static final Integer CONFLICT_CODE = 509 ; 
	public static final String ALREADY_MOD_MSG = 'Attendance already modified'; 
	public static final String ALREADY_EXISTS_MSG = 'Attendance for this Event and Physician exists'; 
	
	
	List<CONGA_AttendanceProperties> attendances; 																	/*input attendances - WS input parameter*/
    List<CONGA_ManageAttendancesRespBaseItem> respAttendances;														/*WS output*/ 
	Map<ID,CONGA_Attendance_gne__c> id2dbAttendance; 																/*mapping from attendance.sfdcId => CONGA_Attendance_gne__c from DB*/
    Map<String,CONGA_Attendance_gne__c> externalId2dbAttendance= new Map<String,CONGA_Attendance_gne__c> (); 		/*mapping from attendance.externalId => CONGA_Attendance_gne__c from DB*/
    
	List<CONGA_Attendance_gne__c> upsertAttendancesList =new List<CONGA_Attendance_gne__c> ();  					/*list of attendances that will be upsert basing on id*/ 
	List<CONGA_Attendance_gne__c> upsertByExternalIdAttendancesList = new List<CONGA_Attendance_gne__c> (); 		/*list of attendances that will be upsert basing on External_id__c*/
	
	Set<ID> AttendanceIds = new Set<ID> (); 
	Set<String> AttendanceExternalIds = new Set<String> (); 
	
	Map<CONGA_AttendanceProperties, Integer> attendanceProperty2idx = new Map<CONGA_AttendanceProperties, Integer> (); 
	Map<CONGA_Attendance_gne__c, Integer> attendanceSobj2idx = new Map<CONGA_Attendance_gne__c, Integer> (); 
	
	public CONGA_AttendancesPropertyWritter(List<CONGA_AttendanceProperties> attendances){
		this.attendances = attendances;
	    this.respAttendances = new CONGA_ManageAttendancesRespBaseItem[attendances.size()];
		preprocessAttendances(); 
        
		
        id2dbAttendance = new Map<ID,CONGA_Attendance_gne__c>([select id, External_Id__c, Event__c,Attendance_Status__c,Physician__c,Sponsor__c,Timestamp__c 
                                                                from CONGA_Attendance_gne__c 
                                                                where id in: AttendanceIds 
                                                                or External_Id__c in :AttendanceExternalIds
                                                                for update ]);
        
        
        externalId2dbAttendance = new Map<String,CONGA_Attendance_gne__c> (); 
        for (CONGA_Attendance_gne__c dbAttendance: id2dbAttendance.values()){
            externalId2dbAttendance.put((String)dbAttendance.get('External_Id__c'), dbAttendance); 
        }
	}
	
	
	private void preProcessAttendances(){
		Long timeStampNow = datetime.now().getTime(); 
		for (Integer i = 0 ; i< attendances.size(); i++)
		{		
            CONGA_AttendanceProperties attendance = attendances[i];
			if (attendanceProperty2idx.get(attendance) == null)
				attendanceProperty2idx.put(attendance,i); 
			else 	
			{
				respAttendances[i] =  new CONGA_ManageAttendancesRespBaseItem(DUPLICATE_IDENTIFIER_CODE,DUPLICATE_IDENTIFIER_MSG,attendance.id);
				respAttendances[attendanceProperty2idx.get(attendance)] =  new CONGA_ManageAttendancesRespBaseItem(DUPLICATE_IDENTIFIER_CODE,DUPLICATE_IDENTIFIER_MSG,attendance.id);
				continue;
			}
            
            if (String.isEmpty(attendance.id) && (String.isEmpty(attendance.eventId) || String.isEmpty(attendance.physicianId) ) ){
				respAttendances[i] =  new CONGA_ManageAttendancesRespBaseItem(MISSING_KEY_CODE,MISSING_KEY_MSG,attendance.id);
				continue;
			}
			
			/* if event comes from the futer try inserting it but with current time, otherwise this one record will allow upserts of correct attendances*/ 
			if(attendance.timestamp > timeStampNow)
				attendance.timestamp = timeStampNow; 
			
			if (attendance.id != null)
				AttendanceIds.add(attendance.id); 
			AttendanceExternalIds.add(attendance.getExternalId());			
		}
	
	}
	

	/*modifies upsertAttendancesList and upsertByExternalIdAttendancesList lists*/ 
	private void prepareAttendanceSobjectsForUpsert(){
		CONGA_AttendanceProperties attendanceProp; 
        CONGA_Attendance_gne__c dbAttendance; 
        For (Integer i = 0 ; i< attendances.size(); i++ ){
			/*proceed only for attendances that were not already marked as faulty ones in preprocessing*/ 	
			if (respAttendances[i] ==null)
			{
				attendanceProp = attendances[i]; 
				
				dbAttendance = id2dbAttendance.get(attendanceProp.id) != null ?
									id2dbAttendance.get(attendanceProp.id) :
									this.externalId2dbAttendance.get(attendanceProp.getExternalId() ) ; 
				/*manage conflicts on as early stage as possible, providing appropriate error msg*/ 
				
				if (attendanceProp.id != null)/*its update*/
				{	
					/*there is record in Database and its timestamp is newer than ther proposed attendance*/ 
					if (dbAttendance != null && dbAttendance.Timestamp__c.getTime() >= attendanceProp.timestamp)
						respAttendances[attendanceProperty2idx.get(attendanceProp)] = new CONGA_ManageAttendancesRespConflictItem(ALREADY_MOD_MSG,CONFLICT_CODE,dbAttendance ); 
					else 
						{
						CONGA_Attendance_gne__c attendance = attendances[i].toAttendanceSobject(true);  
						upsertAttendancesList.add(attendance);
						attendanceSobj2idx.put(attendance.clone(true,true,false,false),i); /*we copy to clone of sObje, because key of Map needs to be immutable*/
						}
				}
				else if (attendanceProp.id == null && attendanceProp.getExternalId() != null && dbAttendance != null )
				{
					if (dbAttendance.Attendance_Status__c != 'None' && dbAttendance.Timestamp__c.getTime() > attendanceProp.timestamp )
						respAttendances[attendanceProperty2idx.get(attendanceProp)] = new CONGA_ManageAttendancesRespConflictItem(ALREADY_EXISTS_MSG,CONFLICT_CODE,dbAttendance ); 
					else
						{
						CONGA_Attendance_gne__c attendance = attendances[i].toAttendanceSobject(true);  
						upsertByExternalIdAttendancesList.add(attendance);
						attendanceSobj2idx.put(attendance.clone(true,true,false,false),i); /*we copy to clone of sObje, because key of Map needs to be immutable and we might upsert it*/
						}
				}
				else
				{
					CONGA_Attendance_gne__c attendance = attendances[i].toAttendanceSobject(true);  
					upsertAttendancesList.add(attendance);
					attendanceSobj2idx.put(attendance.clone(true,true,false,false),i); /*we copy to clone of sObje, because key of Map needs to be immutable and we might upsert it*/
				}
			}
        }	
	}
	
	
	private void upsertAttendances(){
	
		List<CONGA_Attendance_gne__c>upsertAttendancesListClone = upsertAttendancesList.deepclone(true,true,true); 
		List<CONGA_Attendance_gne__c>upsertByExternalIdAttendancesListClone = upsertByExternalIdAttendancesList.deepclone(true,true,true); 

        Database.UpsertResult[] upsertAttendancesByIdResult = Database.upsert(upsertAttendancesList, false);

		mapDMLresultToResponse(upsertAttendancesListClone,upsertAttendancesByIdResult); 
        
	    Database.UpsertResult[] upsertAttendancesByExternalIdResult = Database.upsert(upsertByExternalIdAttendancesList, CONGA_Attendance_gne__c.External_Id__c, false);
        mapDMLresultToResponse(upsertByExternalIdAttendancesListClone,upsertAttendancesByExternalIdResult); 
        
	}
	
	private void mapDMLresultToResponse(List<CONGA_Attendance_gne__c> modifiedAttendancesList,Database.UpsertResult[] upsertResults){
		for (Integer i = 0 ; i < upsertResults.size() ; i++)
		{
			Database.UpsertResult upsertResult = upsertResults[i]; 
				
			Integer responseIndex = attendanceSobj2idx.get(modifiedAttendancesList[i]);
			
            if(upsertResult.isSuccess()){
				respAttendances[responseIndex] = 
                    new CONGA_ManageAttendancesRespBaseItem(OK_CODE,OK_MSG,upsertResult.getId());
            }else{
                respAttendances[responseIndex] = new CONGA_ManageAttendancesRespBaseItem(INTERNAL_ERR_CODE,INTERNAL_ERR_MSG + upsertResult.getErrors() ,upsertResult.getId());
            }
		}
	}

	
	
@HttpPost 
    global static List<CONGA_ManageAttendancesRespBaseItem> manageAttendancesRest()
    {
    	if (null == RestContext.request.requestBody || String.isEmpty(RestContext.request.requestBody.toString()) )
    	{
    		return null; 
    	}
        List<CONGA_AttendanceProperties> attendances =(List<CONGA_AttendanceProperties> ) JSON.deserialize( RestContext.request.requestBody.toString(),   List<CONGA_AttendanceProperties>.class );
        CONGA_AttendancesPropertyWritter writter = new CONGA_AttendancesPropertyWritter(attendances); 
        return writter.manageAttendances();
    }
    
	
	public List<CONGA_ManageAttendancesRespBaseItem> manageAttendances()
	{
        prepareAttendanceSobjectsForUpsert();
        upsertAttendances();
		return this.respAttendances; 
	}
	
}