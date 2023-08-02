/** @date 20/11/2014
* @Author Michal Szewczyk
* @description Controller Class for SRW_Sweep page
*/
public with sharing class SRW_SweepController {
  
  public SRW_DataMonths__c currentDataMonth {get;set;}
  public String historyDataMonthSweepDate {get;set;}
  public String sweepDateForDataMonth {get;set;}
  public String maxSweepCustomDate {get;set;}
  public String sweepCurrentStatus {get;set;}

  public Boolean showTriggerBtn {get;set;}

  public Map<Id,SRW_DataMonths__c> mapDataMonths;
  public List<SRW_DataMonths__c> lstDataMonths ;
  
  /** @date 20/11/2014
  * @Author Michal Szewczyk
  * @description Constructor for SRW_SweepController
  */
  public SRW_SweepController() {
    
    mapDataMonths = new Map<Id,SRW_DataMonths__c>();


        lstDataMonths = [Select Id,
                               Name,
                               Data_Month_Cal_gne__c,
                               Sweep_Custom_Date_gne__c,
                               Sweep_Default_Date_gne__c,
                               Last_Sweep_Occurrence_Date_gne__c,
                               Sweep_Status_gne__c,
                               Real_Sweep_Date_gne__c,
                               Data_Year_gne__c,
                               Data_Month_Number_gne__c
                         from SRW_DataMonths__c
                         Order By Sweep_Default_Date_gne__c DESC];

        for(SRW_DataMonths__c temp : lstDataMonths) {

            mapDataMonths.put(temp.Id , temp);

            if(temp.Sweep_Status_gne__c =='Current') {
                currentDataMonth = temp;
            } 
        }

        if(currentDataMonth == null) {

            currentDataMonth = lstDataMonths[0];
        }
        
        determinSweetDateForDataMonth();
        checkTriggerBtnVisible();

        // determin maxSweepCustomDate
        maxSweepCustomDate = String.valueOf(currentDataMonth.Sweep_Default_Date_gne__c.toStartOfMonth().addMonths(2).addDays(-1));
        system.debug('MICK_LOKO maxSweepCustomDate:'+ maxSweepCustomDate);
  }
  
   @RemoteAction
  public static String checkSweepStatus(String currentId){
      
      String sweepStatus = SRW_Utils.getSettingByName('Sweep Status');
      system.debug('MICK_LOKO RemoteAction checkSweepStatus : ' + sweepStatus);
      if(sweepStatus != '' && sweepStatus != null && sweepStatus == currentId ) {
        return 'Not Ready';
      }
      else {
        SRW_DataMonths__c currentRealStatus= [Select Id,Sweep_Status_gne__c from SRW_DataMonths__c where ID = :currentId];
        if(currentRealStatus.Sweep_Status_gne__c == 'Current') 
          return 'Ready';
        else
          return 'Not Ready';
      }
  }

  /** @date 25/11/2014
  * @Author Michal Szewczyk
  * @description Getter returning Data Month for History picklist on the page
  */  
  public List<SelectOption> getHistoryDataMonthOptions() {
      
      List<SelectOption> dataMonth = new List<SelectOption>();
      dataMonth.add(new Selectoption('all','All'));
      for(SRW_DataMonths__c tmp : lstDataMonths) {
          if(tmp.Sweep_Status_gne__c == 'Sweep' || tmp.Sweep_Status_gne__c == 'ReSweep')
              dataMonth.add(new Selectoption(tmp.Data_Month_Cal_gne__c,tmp.Data_Month_Cal_gne__c));
      }
      
      if(dataMonth.size() <1) {
          dataMonth.add(new Selectoption('','-None-'));
      }
      historyDataMonthSweepDate = 'all';
      return dataMonth;
  }

  
  /** @date 20/11/2014
  * @Author Michal Szewczyk
  * @description action method showing sweep date
  */  
  public void determinSweetDateForDataMonth() {
     
          SRW_DataMonths__c tempDataM = mapDataMonths.get(currentDataMonth.Id);

          if(tempDataM.Sweep_Custom_Date_gne__c != null) {
            sweepDateForDataMonth =  tempDataM.Sweep_Custom_Date_gne__c.format();
          }
          else if ( tempDataM.Sweep_Default_Date_gne__c != null){
            sweepDateForDataMonth =  tempDataM.Sweep_Default_Date_gne__c.format();
          }
          else {
            sweepDateForDataMonth = '';
          }

          checkTriggerBtnVisible();
  }

  /** @date 20/11/2014
  * @Author Michal Szewczyk
  * @description action method updating sweep date
  */  
  public void updateSweepCustomDate(){

      SRW_DataMonths__c selectedDataM = mapDataMonths.get(currentDataMonth.Id);
      try {

               if(sweepDateForDataMonth != null && sweepDateForDataMonth != '') {
                  Date myDate = date.valueOf(convertDate(sweepDateForDataMonth));
                  selectedDataM.Sweep_Custom_Date_gne__c = myDate;
               } 
               else {
                      selectedDataM.Sweep_Custom_Date_gne__c = null;
               }
    
        update selectedDataM;
        checkTriggerBtnVisible();
      }
      catch (Exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,Label.SRW_CutomDate_Update_Error)); 
           system.debug('MICK_LOKO: Insert error :' + e);
      } 
      
  }
    /** @date 26/11/2014
    * @Author Michal Szewczyk
    * @description action method generating csv file
    */  
    public void checkTriggerBtnVisible() {

            if(Date.today() >= mapDataMonths.get(currentDataMonth.Id).Sweep_Default_Date_gne__c &&  mapDataMonths.get(currentDataMonth.Id).Sweep_Status_gne__c == 'Current' ) {
                showTriggerBtn =  true;
            }
            else if (Date.today() >= mapDataMonths.get(currentDataMonth.Id).Sweep_Custom_Date_gne__c  &&  mapDataMonths.get(currentDataMonth.Id).Sweep_Status_gne__c == 'Current') {
                showTriggerBtn = true;
            }
            else
            {
                showTriggerBtn = false;
            }

    }

    public String getSweepStatus (){

      String SweepStatus = '';

      if(currentDataMonth.Sweep_Status_gne__c == 'Current')
        SweepStatus = 'Not Sweep';
      else if(currentDataMonth.Sweep_Status_gne__c == 'Active')
        SweepStatus = 'Not Sweep';
      else if(currentDataMonth.Sweep_Status_gne__c == 'Sweep')
        SweepStatus = 'Swept';
      else if(currentDataMonth.Sweep_Status_gne__c == 'ReSweep')
        SweepStatus = 'Re-Swept';

      return SweepStatus;
    }
    /** @date 20/11/2014
  * @Author Michal Szewczyk
    * @description action method generating csv file
    */  
    public PageReference  triggerSweep() {

        SRW_DataMonths__c tempDM = mapDataMonths.get(currentDataMonth.Id);
        tempDM.Real_Sweep_Date_gne__c = system.now();
        showTriggerBtn = false;

        upsert new SRW_Settings__c( Name = 'Sweep Status',Value_gne__c = currentDataMonth.Id) Name;
        SRW_SweepProcessBatch batchJob = new SRW_SweepProcessBatch(tempDM,true);
        Database.executeBatch(batchJob);    
        try {
          
            update tempDM;
        
        } catch (Exception e) {

            system.debug('MICK_LOKO Something went wrong with updating Real Sweep Date for current moonth');
        }
      
        return null;  
    
    }


    /** @date 20/11/2014
  * @Author Michal Szewczyk
    * @description helper method switching order in date string
    */  
    private String convertDate(String sDate) {

      String convertedDAte ='';
      List<String> temp = sDate.split('/',0);

      // set year
      convertedDAte += temp[2] + '-';
      //set month
      convertedDAte += temp[0] + '-';
      // set day
      convertedDAte += temp[1];

    system.debug('MICK_LOKO: convertedDAte :' + convertedDAte);
    return convertedDAte;
    }
    /** @date 25/11/2014
    * @Author Michal Szewczyk
    * @description method returning data monnt for display in hisotry section
    */  
    public List<SRW_DataMonths__c> getHistoryDataMonths() {

        List<SRW_DataMonths__c> DataMonthFiltered = new List<SRW_DataMonths__c>();

        for(SRW_DataMonths__c tmp : lstDataMonths) {

            if(tmp.Sweep_Status_gne__c == 'Sweep' || tmp.Sweep_Status_gne__c == 'ReSweep')
            DataMonthFiltered.add(tmp);
        }

        return DataMonthFiltered;
    }


}