public with sharing class GNE_SFA2_Call_Observation_Help_Info_Ext {

    public class ObservationWrapper{
        public String obsValue {get; set;}
        public String obsDefinition {get; set;}

        ObservationWrapper(String obsValue, String obsDefinition){
            this.obsValue = obsValue;
            this.obsDefinition = obsDefinition;
        }
    }

    public final Map<String, String> mapObsDefinitions = new Map<String, String>{
        'GNE Disclosures' => 'Required Genentech disclosures must be displayed in PRC-approved materials. Speaker must direct audience members to review the disclosures and/or read through the disclosures<br/>- This program is presented on behalf of Genentech and the information presented is consistent with FDA guidelines.<br/>- I have been compensated by Genentech to serve as faculty for this program.<br/>- This program is intended to provide general information about [insert Product/Disease State]and not medical advice for any particular patient<br/>- This program may be monitored by Genentech for adherence to program requirements<br/>',
        'Disclaimer - Response to Unsolicited Question' => 'When briefly responding to an unsolicited question on uses not consistent with approved product labeling, speaker must clearly state that such use has not been approved by the FDA as safe or effective<br/>',
        'Safety/Fair Balance' => 'Speaker must not omit, skip through, or downplay safety information included in the slide deck<br/>',
        'Proactive Statements/Discussions' => 'Speaker must not proactively make statements or initiate discussions on topics or uses that are not consistent with FDA guidelines. Proactive product mentions at unbranded/disease programs are not appropriate<br/>',
        'Non-PRC Approved Materials' => 'Speaker must not use their own materials or remove/modify any PRC-approved slides<br/>',
        'Reimbursement/Profitability' => 'Speaker must not make statements or engage in discussions regarding practice economics (e.g., profitability, margin, enhancing revenue, coding and billing advice, etc.)<br/>',
        'Other (Contact HCO at 650-467-0422)' => 'Contact HCO at 650-467-0422 if you have questions about other observations<br/>'
    };

    public List<ObservationWrapper> observations {get; set;}

    public GNE_SFA2_Call_Observation_Help_Info_Ext() {
        observations = new List<ObservationWrapper>();
        Schema.DescribeFieldResult fieldResult = Call2_Discussion_vod__c.Observation_gne__c.getDescribe();
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
            observations.add(new ObservationWrapper(f.getValue(), mapObsDefinitions.get(f.getValue())));
        }
        /*
        for(String obsVal : mapObsDefinitions.keySet()){
            observations.add(new ObservationWrapper(obsVal, mapObsDefinitions.get(obsVal)));
        }
        */
    }
}