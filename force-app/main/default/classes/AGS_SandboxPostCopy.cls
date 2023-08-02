/**
 * @date 01/28/2017
 * @author Gabriel Juriewicz, Grzegorz Laskowski
 * @description initializes AGS custom settings
 */
global without sharing class AGS_SandboxPostCopy implements SandboxPostCopy, Database.Batchable<sObject>, Database.Stateful {
    
    public static final Map<String, AGS_SObjectEmailFormatter> FORMATTERS = new Map<String, AGS_SObjectEmailFormatter>{
        'AGS_Case_Action_gne__c' => new AGS_SObjectEmailFormatter(new String[]{
            'AGS_Case_Resolver_Email_gne__c',
            'AGS_Case_Analyst_Email_gne__c'
        }),
        'All_User_Hierarchy_gne__c' => new AGS_AllUserHierarchyEmailFormatter(),
        'AGS_ST_User_gne__c' => new AGS_SunshineTrackUserEmailFormatter()
    };
    
    public final Map<String, Set<String>> queryFields = new Map<String, Set<String>>{
        'AGS_Case_Action_gne__c' => new Set<String>{ 'AGS_Case_Analyst_Email_gne__c', 'AGS_Case_Resolver_Email_gne__c' },
        'All_User_Hierarchy_gne__c' => new Set<String>{ 'User_External_Id_gne__c', 'Email_Id__c' },
        'AGS_ST_User_gne__c' => new Set<String>{ 'Email_Address__c', 'SFDC_User__r.Email' }
    };
    
    global void runApexClass(final SandboxContext ctx) {
        final Organization org = [
            SELECT InstanceName, IsSandbox, Name FROM Organization WHERE Id = :ctx.sandboxId() LIMIT 1
        ];
        initEmailLinks(ctx.sandboxName(), org);
        initDomains(ctx.sandboxName(), org);
        
        // create AGS_ST_Settings_gne__c record
        AGS_ST_Settings_gne__c[] stSettings = AGS_ST_Settings_gne__c.getall().values();
        delete stSettings;
        
        AGS_ST_Settings_gne__c stSetting = new AGS_ST_Settings_gne__c();
        stSetting.ARX_Url_gne__c = 'https://dev.sunshine.iassist.com';
        stSetting.ARX_Password_gne__c = 'f0l0wth3wr';
        stSetting.CCO_Email_gne__c = 'sfdctestemail-d@gene.com';
        stSetting.Domain_gne__c = 'https://test.salesforce.com';
        stSetting.OrganizationId__c = org.Id;
        stSetting.SIMS_WS_Address_gne__c = 'https://extsimsit.gene.com/idm/ext/mvc/ext/users';
        stSetting.ARX_QuizAccount__c = '0';
        stSetting.OrgWideAddressName_gne__c = 'Genentech Sunshine Help Desk';
        stSetting.AssistRx_retries_gne__c = 4;
        stSetting.ARX_User__c = 'gene';
        stSetting.Annually_Diggest_gne__c = Date.newInstance(2013, 9, 20);
        stSetting.Monthly_Diggest_gne__c = Date.newInstance(2013, 9, 20);
        stSetting.Quarterly_Diggest_gne__c = Date.newInstance(2013, 9, 20);
        stSetting.CmsPaymentIdDisplayDate_gne__c = Date.newInstance(2014, 9, 10);
        
        if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('sqa')) {
            stSetting.Name = 'sqa';
            stSetting.SuperAdmin1_gne__c = 'jennaf@gene.com.sqa';
            stSetting.SuperAdmin2_gne__c = 'ninaa@gene.com.sqa';
            stSetting.SuperAdmin3_gne__c = 'grzegorz.laskowski@gene.com.sqa';
            stSetting.Is_Arx_Skip_gne__c = true;
        } else if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('uat')) {
            stSetting.Name = 'uat';
            stSetting.SuperAdmin1_gne__c = 'jennaf@gene.com.uat';
            stSetting.SuperAdmin2_gne__c = 'ninaa@gene.com.uat';
            stSetting.SuperAdmin3_gne__c = 'grzegorz.laskowski@gene.com.uat';
        } else {
            stSetting.Name = 'dev';
            stSetting.SuperAdmin1_gne__c = 'jennaf@gene.com.dev';
            stSetting.SuperAdmin2_gne__c = 'ninaa@gene.com.dev';
            stSetting.SuperAdmin3_gne__c = 'grzegorz.laskowski@gene.com.dev';
        }
        insert stSetting;
        // Create VDST_Settings__c record
        String currentEnvironment;
        if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('sqa')) {
            currentEnvironment = 'sqa';
        } else if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('uat')) {
            currentEnvironment = 'uat';
        } else if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('dev')) {
            currentEnvironment = 'dev';
        }
        VDST_Settings__c[] vdstSettings = VDST_Settings__c.getall().values();
        delete vdstSettings;
        VDST_Settings__c vdstSetting = new VDST_Settings__c();
        vdstSetting.SIMS_Password__c = 'W0nP@sC#';
        vdstSetting.SIMS_Username__c = 'ctxconn';
        vdstSetting.EDM_Landing_Page_gne__c = 'GNE_SFA2_Application_Dispatcher?application=ABM';
        vdstSetting.SSO_Domain__c = 'test.salesforce.com';
        if (currentEnvironment == 'sqa') {
            vdstSetting.Name = 'sqa';
            vdstSetting.Admin_Username__c = 'grzegorz.laskowski@gene.com.sqa';
            vdstSetting.SIMS_Endpoint__c = 'https://extsimsit.gene.com/idm/ext/mvc/ext/users';
            vdstSetting.Username_Postfix__c = '@gene.com.sqa';
        } else if (currentEnvironment == 'uat') {
            vdstSetting.Name = 'uat';
            vdstSetting.Admin_Username__c = 'grzegorz.laskowski@gene.com.uat';
            vdstSetting.SIMS_Endpoint__c = 'https://extsimsval.gene.com/idm/ext/mvc/ext/users';
            vdstSetting.Username_Postfix__c = '@gene.com.uat';
        } else {
            vdstSetting.Name = 'dev';
            vdstSetting.Admin_Username__c = 'grzegorz.laskowski@gene.com.dev';
            vdstSetting.SIMS_Endpoint__c = 'https://extsimsit.gene.com/idm/ext/mvc/ext/users';
            vdstSetting.SIMS_Username__c = 'ctx_rest_user@yopmail.com';
            vdstSetting.Username_Postfix__c = '@gene.com.dev';
        }
        insert vdstSetting;
        Database.executeBatch(this);
    }

    public static Boolean initEmailLinks(final String sandboxName, final Organization org) {
        final Map<String, AGS_Email_Links__c> allLinks = AGS_Email_Links__c.getAll();
        final AGS_Email_Links__c envLinks = allLinks.size() == 1 ? allLinks.values()[0] : new AGS_Email_Links__c(
            AGS_IFU_Training_Link__c = 'https://comm.gene.com/ags-case-action',
            AGS_Training_Link__c = 'https://comm.gene.com/ags-case-action',
            AGS_Commportal_Link__c = 'https://comm.gene.com/'
        );
        final Set<AGS_Email_Links__c> redundantLinks = new Set<AGS_Email_Links__c>(allLinks.values());
        redundantLinks.remove(envLinks);
        envLinks.AGS_B2B_Link__c = 'https://b2b' + sandboxName.replace('sqa', 'qa').replace('uat', 'ua') + '.gene.com';
        envLinks.Name = org.IsSandbox ? 'Sandbox' : 'Production';
        return Database.upsert(envLinks).isSuccess();
    }

    public static Boolean initDomains(final String sandboxName, final Organization org) {
        final Map<String, AGS_Environment_Domain_gne__c> allDomains = AGS_Environment_Domain_gne__c.getAll();
        final AGS_Environment_Domain_gne__c envDomain = allDomains.containsKey(sandboxName) ?
            allDomains.get(sandboxName) : new AGS_Environment_Domain_gne__c(Name = sandboxName);
        envDomain.Domain_gne__c = '@gene.com' + (org.isSandbox ? '.' + sandboxName : '');
        envDomain.Mail_Domain__c = String.isNotBlank(envDomain.Mail_Domain__c)  || org.isSandbox ?
            envDomain.Mail_Domain__c : 'ags_tech_support_d@gene.com';
        envDomain.SSO_Domain_gne__c = org.Name.toLowerCase() + (
            org.isSandbox ? '--' + sandboxName + '.' + org.InstanceName.toLowerCase() : ''
        ) + '.my.salesforce.com';
        envDomain.Site_Domain_gne__c = (org.isSandbox ? sandboxName + '-' : '') + 'gene.' + (
            org.isSandbox ? org.InstanceName.toLowerCase() + '.' : ''
        ) + 'com';
        return Database.upsert(envDomain).isSuccess();
    }
    
    global Database.QueryLocator start(final Database.BatchableContext ctx) {
        String query = '';
        for (String objName : queryFields.keySet()) {
            query += 'SELECT ' +  String.join(new List<String>(queryFields.remove(objName)), ', ') +' FROM ' + objName;
            break;
        }
        return Database.getQueryLocator(String.isBlank(query) ? 'SELECT Id FROM User WHERE Id = null LIMIT 1' : query);
    }
    
    global void execute(final Database.BatchableContext ctx, final sObject[] records) {
        final Set<sObject> modifiedRecords = new Set<sObject>();
        final AGS_SObjectEmailFormatter formatter = records == null || records.isEmpty() ?
            new AGS_SObjectEmailFormatter(null) : FORMATTERS.get(String.valueOf(records[0].getSObjectType()));
        formatter.init(records);
        while (formatter.hasNext()) {
            modifiedRecords.add(formatter.next());
        }
        modifiedRecords.remove(null);
        Database.update(new List<sObject>(modifiedRecords), false);
    }
    
    global void finish(final Database.BatchableContext ctx) {
        if (queryFields.size() > 0) {
            Database.executeBatch(this);
        }
    }
    
    private virtual class AGS_SObjectEmailFormatter implements Iterator<sObject>{
        
        protected final sObject[] records { get; private set; }
        
        private final String[] emailFldNames = new String[]{ };
        
        private Integer index = 0;
        
        private AGS_SObjectEmailFormatter(final String[] fldNames) {
            emailFldNames.addAll(fldNames == null ? new String[]{ } : fldNames);
            records = new sObject[]{ };
        }
        
        private void init(final sObject[] recs) {
            records.addAll(recs == null ? new sObject[]{ } : recs);
        }
        
        public virtual Boolean hasNext() {
            Boolean hasNext = index < records.size();
            while (hasNext) {
                for (String fldName : emailFldNames) {
                    hasNext &= records[index].get(fldName) == null || String.valueOf(
                        records[index].get(fldName)
                    ).endsWithIgnoreCase('@example.com');
                }
                hasNext &= (index += hasNext ? 1 : 0) < records.size();
            }
            return index < records.size();
        }
        
        protected virtual Boolean format(final sObject record, final String fldName) {
            try {
                final String oldEmail = String.valueOf(record.get(fldName)).trim();
                final String[] emailParts = oldEmail.indexOf('@') < 0 ? new String[]{ oldEmail } : oldEmail.split('@');
                record.put(fldName, emailParts[0] + (emailParts.size() > 1 ? '=' + emailParts[1] : '') + '@example.com');
                return oldEmail != record.get(fldName); 
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, e);
                return false;
            }
        }
        
        public virtual sObject next() {
            Boolean hasFormatted = false;
            for (String fldName : emailFldNames) {
                hasFormatted |= format(records[index], fldName);
            }
            return ++index > 0 && hasFormatted ? records[index - 1] : null;
        }
    }
    
    private class AGS_AllUserHierarchyEmailFormatter extends AGS_SObjectEmailFormatter {
        
        private final Map<String, String> emailsByExternalId = new Map<String, String>{
            null => null // null values mapping indicates that collection is not initialized
        };
        
        private AGS_AllUserHierarchyEmailFormatter() {
            super(new String[]{ 'Email_Id__c' });
        }
        
        protected override Boolean format(final sObject record, final String fldName) {
            try {
                final String externalId = String.valueOf(record.get('User_External_Id_gne__c')).trim().toLowerCase();
                final Object oldValue = record.put(fldName, emailsByExternalId.get(externalId).trim().toLowerCase());
                return oldValue != record.get(fldName);
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, e);
                return super.format(record, fldName);
            }
        }
        
        public override sObject next() {
            if (emailsByExternalId.get(null) == null) {
                for (sObject rec : records) {
                    emailsByExternalId.put(String.valueOf(rec.get('User_External_Id_gne__c')), null);
                }
                // eliminate nullable external identifiers from further processing
                emailsByExternalId.remove(null);
                // normalize external identifiers by removing leading and trailing whitespace characters
                for (String externalId : emailsByExternalId.keySet()) {
                    emailsByExternalId.put(externalId.trim().toLowerCase(), emailsByExternalId.remove(externalId));
                }
                // collect emails of corresponding users and grouped them by external identifier
                for (User usr : emailsByExternalId.isEmpty() ? new User[]{ } : [
                    SELECT External_Id_gne__c, Email FROM User
                    WHERE External_Id_gne__c IN :emailsByExternalId.keySet()
                    ORDER BY LastModifiedDate LIMIT :emailsByExternalId.size() * 5 // external identifier is not unique
                ]) {
                    emailsByExternalId.put(usr.External_Id_gne__c.toLowerCase(), usr.Email);
                }
            }
            return super.next();
        }
    }
    
    private class AGS_SunshineTrackUserEmailFormatter extends AGS_SObjectEmailFormatter {
        
        private AGS_SunshineTrackUserEmailFormatter() {
            super(new String[]{ 'Email_Address__c' });
        }
        
        protected override Boolean format(final sObject record, final String fldName) {
            try {
                final Object oldValue = record.put(fldName, record.getSObject('SFDC_User__r').get('Email'));
                return oldValue != record.get(fldName);
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, e);
                return super.format(record, fldName);
            }
        }
    }
}