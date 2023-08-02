global virtual class CONGA_ManageAttendancesRespBaseItem{
    public id id ; 
    public string error; 
    public integer result;  
    public CONGA_ManageAttendancesRespBaseItem(integer result,string error,id id)
    {

        this.error = error; 
        this.result = result; 
        this.id = id; 
    }
        
}