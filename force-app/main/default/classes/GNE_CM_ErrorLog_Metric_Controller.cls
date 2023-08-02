global class GNE_CM_ErrorLog_Metric_Controller 
 {
   
      Integer CurrYear;
     
      public void setCurrYear(Integer CurrYear)
      {
      this.CurrYear = CurrYear;
      }
      public Integer getCurrYear() 
      {
      return CurrYear;
      }
   
    public double percentage{get; set;}
    public Integer year{get; set;}
    public string Month{get; set;}
    List<double> ErrorLogPercentage;
    public integer BaseYear = 2012;
    public double M1{get; set;}
    public double M2{get; set;} 
    public double M3{get; set;} 
    public double M4{get; set;} 
    public double M5{get; set;}
    public double M6{get; set;} 
    public double M7{get; set;}
    public double M8{get; set;}
    public double M9{get; set;}
    public double M10{get; set;}
    public double M11{get; set;}
    public double M12{get; set;} 
    
    public GNE_CM_ErrorLog_Metric_Controller(){
        system.debug('IN Constructor');
              year = 2012;
              M1=M2=M3=M4=M5=M6=M7=M8=M9=M10=M11=M12=0.0;
        
                //ErrorLogPercentage();
    }
    //public list<AggregateResult> CaseCount = new list<AggregateResult>(); 
    List<Case> CaseCount; 
    integer CaseYear;
    List<User> userList;
    Set<Id> userSet;
       
        
    public List <SelectOption> getSelectedYear()
    {
        List<SelectOption> options = new List<SelectOption>();   
        
        List<Case> caseList = new List<Case>([Select id, createdDate from Case order by createdDate desc limit 1]);
        system.debug('caseList ------> ' + caseList);
        integer Diff = caseList[0].createdDate.year();
        integer counter = Diff - BaseYear +1;
        for(integer i=0; i<counter; i++)
        {
            integer IncYear = BaseYear+i; 
            String YearValue = String.valueOf(IncYear);
            options.add(new SelectOption(YearValue, YearValue));
        }
         
        return options;
    }
    
    public void ErrorLogPercentage()
    {
        
        List<integer> MonthList = new List<integer>{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
        if(Year != null)
        {
            CaseYear = integer.valueOf(Year);
        }
                       
        for(integer i=1; i<= MonthList.size(); i++)
        {
            Decimal ErrorLogPercent=0.0;
            if(CaseYear != null)
            {
                double CaseCount = [Select Count() from Case where CALENDAR_YEAR(CreatedDate) =: CaseYear and CALENDAR_MONTH(convertTimezone(CreatedDate)) =: MonthList[i-1] and (Owner_Profile__c = 'GNE-CM-INTAKE' or Owner_Profile__c = 'GNE-CM-INTAKESUPERVISOR')];
                double ErrLogCount = [Select Count() from CM_Error_Log_gne__c where CALENDAR_YEAR(CreatedDate) =: CaseYear and CALENDAR_MONTH(convertTimezone(CreatedDate)) =: MonthList[i-1] and Status__c !=: 'Created in error'];
   
                if(CaseCount > 0.0)
                {
                    ErrorLogPercent = (ErrLogCount/CaseCount)*100;
               
                }
            }   
                if(i==1)
                {
                    M1 = ErrorLogPercent.setScale(2);
                }
                else if(i==2)
                {
                    M2 = ErrorLogPercent.setScale(2);
                }
                else if(i==3)
                {
                    M3 = ErrorLogPercent.setScale(2);
                }
                else if(i==4)
                {
                    M4 = ErrorLogPercent.setScale(2);
                }
                else if(i==5)
                {
                    M5 = ErrorLogPercent.setScale(2);
                }
                else if(i==6)
                {
                    M6 = ErrorLogPercent.setScale(2);
                }
                else if(i==7)
                {
                    M7 = ErrorLogPercent.setScale(2);
                }
                else if(i==8)
                {
                    M8 = ErrorLogPercent.setScale(2);
                }
                else if(i==9)
                {
                    M9 = ErrorLogPercent.setScale(2);
                }
                else if(i==10)
                {
                    M10 = ErrorLogPercent.setScale(2);
                }
                else if(i==11)
                {
                    M11 = ErrorLogPercent.setScale(2);
                }
                else if(i==12)
                {
                    M12 = ErrorLogPercent.setScale(2);
                }
                
        }
   } 
     
     Public Boolean getSelmonthsFlag()
     {
        if((M1 == 0.0 ) && (M2 == 0.0 ) && (M3 == 0.0 ) && (M4 == 0.0 ) && (M5 == 0.0 ) && (M6 == 0.0 ) && (M7 == 0.0 ) && (M8 == 0.0 ) && (M9 == 0.0 ) && (M10 == 0.0 ) && (M11 == 0.0 ) && (M12 == 0.0 ) )
        {
                return true;    
        }
        else
        {
                return false;
        }
     }
       
  
}