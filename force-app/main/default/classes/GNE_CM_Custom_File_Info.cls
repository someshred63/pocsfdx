/*************************************************************************************************************
    Class Name: GNE_CM_Custom_File_Info
    Purpose: This class is being used in Triage/Vendor interface for display the info retreived from SCM
             onto SFDC VF page.
    Developed by: GDC - 3/24/2009

************************************************************************************************************/

global class GNE_CM_Custom_File_Info
{
    // Variable declaration
    Webservice string FileName;
    Webservice string LastUpdDt;
    Webservice string Description;
    Webservice string CaseNumber;
    Webservice string DocumentType;
    
    
     // Get and Set functions for CaseNumber
    public string getCaseNumber()
    {
        return CaseNumber;
    }
    
     // Get and Set functions for DocumentType
    public string getDocumentType()
    {
        return DocumentType;
    }
    
    // Get and Set functions for FileName
    public string getFileName()
    {
        return FileName;
    }
    public void setFileName(string value)
    {
        FileName = value;
    }
    
    // Get and Set functions for Last Updated Date
    public string getLastUpdDt()
    {
        return LastUpdDt;
    }
    public void setLastUpdDt(string value)
    {
        string Dt = value.substring(0,value.indexOf('T'));
        string[] Dtcomponents = Dt.split('-', 5);
        LastUpdDt = Dtcomponents[1] + '/' + Dtcomponents[2] + '/' + Dtcomponents[0]; 
    }
    
    // Get and Set functions for Description
    public string getDescription()
    {
        return Description;
    }
    public void setDescription(string value)
    {
        Description = value;
    }
    
    public void setDocumentType(string value)
    {
        DocumentType = value;
    }

    public void setCaseNumber(string value)
    {
        CaseNumber = value;
    }

    
    
    

} // end of class