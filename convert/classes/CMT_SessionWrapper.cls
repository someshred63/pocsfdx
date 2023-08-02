// Wrapper class used in sorting
// The class needs to implement the IReflection interface to be used in the SuperSort.sortList method
public class CMT_SessionWrapper implements IReflection
{        
    public String sessionName { get; set; }
    public String franchiseName { get; set; }
    public String name { get; set; }
    public String startTime { get; set; }
    public String endTime { get; set; }
    public String location { get; set; }
    public String roomName { get; set; }
    public String description {get; set;}
    
    public object getValue(String name)
    {
        object result = null;
        
        if(name == 'Session_gne__r.Name')
        {
            result = sessionName;
        } 
        else if(name == 'Franchise_Name_gne__c')
        {
            result = franchiseName;
        }
        else if(name == 'Start_Time_gne__c')
        {
            result = startTime;
        }
        else if(name == 'End_Time_gne__c')
        {
            result = endTime;
        }
        else if(name == 'Location_gne__c')
        {
            result = location;
        }
        else if(name == 'Room_Name_gne__c')
        {
            result = roomName;
        }
        else if(name == 'Name')
        {
            result = name;
        }
        else if (description == 'Description_gne__c')
        {
            result = description;
        }
        
        return result;
    }
}