global class GENE_WS_CalendarAccess {
        WebService static Contact getContact(String contactId){
            Contact contact = [select Phone, MobilePhone, MailingStreet, MailingState, MailingPostalCode, MailingCity, FirstName, LastName, Fax, Email, AccountId from Contact where id =: contactId];
            return contact;
        }
        WebService static String getContactAddress(String contactId){
              Contact contact = [select Phone, MobilePhone, MailingStreet, MailingState, MailingPostalCode, MailingCity, FirstName, LastName, Fax, Email, AccountId from Contact where id =: contactId];
              String address = contact.MailingStreet+','+contact.MailingCity+','+contact.MailingState+','+contact.MailingPostalCode;
              address = address.replaceAll(' ', '%20');
              return address;
        }

        WebService static Account getAccount(String accountId){
            Account acct = [select id, name, site  from Account where id =: accountId];
            return acct;
        }
        
        WebService static List<Contact> getAccountContacts(String accountId) {
            List<Contact> accountContacts =  [select id, firstname, lastname, email, phone from Contact where Accountid =: accountId];
            return accountContacts;
        }

        WebService static List<Contact> getUserContacts(string userId){
            DateTime d1=System.now();
            DateTime d2=(System.now()).addYears(-1);
            List<Event> evs=getUserEvents(userId,d2,d1);
            Set<Id> ids = new Set<Id>();
            for(Event e:evs){
                for(EventAttendee ea:e.EventAttendees){
                    if(ids.contains(ea.AttendeeId)) continue;
                    ids.add(ea.AttendeeId);
                }   
            }
            return [select id, firstname, lastname, email, phone, AccountId from Contact where Id in :ids];
        }
        WebService static List<Account> getUserAccounts(string userId){
            Set<Id> ids = new Set<Id>();
            for(Contact c:getUserContacts(userId)){
                if(ids.contains(c.AccountId)) continue;
                ids.add(c.AccountId);
            }
            return [select id, name, site  from Account where Id in :ids];
        }
        WebService static List<Event> getAccountEvents(string accountId, DateTime startDate, DateTime endDate){
                List<Call2_vod__c> calls=[Select c.Account_vod__c, c.Id, c.Parent_Call_vod__c, (Select Id From Events where ActivityDateTime>=:startDate and ActivityDateTime<=:endDate) from Call2_vod__c c where c.Account_vod__c=:accountId];
                List<Event> evs=new List<Event>();
                Set<Id> ids = new Set<Id>();
                Set<Id> parentIds= new Set<Id>();
                Set<Id> parentEventIds= new Set<Id>();
                for(Call2_vod__c call2:calls){
                    if(call2.Parent_Call_vod__c!=null) parentIds.add(call2.Parent_Call_vod__c);
                    for(Event ev:call2.Events){
                        ids.add(ev.id);
                    }
                }
                List<Call2_vod__c> parentCalls=[Select c.Account_vod__c, c.Id, c.Parent_Call_vod__c, (Select Id From Events where ActivityDateTime>=:startDate and ActivityDateTime<=:endDate) from Call2_vod__c c where c.Id in :parentIds];
                for(Call2_vod__c call2:parentCalls){
                    for(Event ev:call2.Events){
                        parentEventIds.add(ev.id);
                    }
                }
                evs.addAll([Select e.AccountId, e.ActivityDate, e.ActivityDateTime, e.CreatedById, e.Type,
                    e.CreatedBy.Alias, e.CreatedBy.Email, e.CreatedBy.FirstName, e.CreatedBy.LastName, e.CreatedBy.Phone,
                    e.CreatedDate, e.Description, e.DurationInMinutes, e.Id, e.IsAllDayEvent, e.IsArchived, e.IsChild, e.IsDeleted, e.IsGroupEvent, e.IsPrivate, e.IsRecurrence, e.IsReminderSet, 
                    e.LastModifiedById, 
                    e.LastModifiedBy.Alias, e.LastModifiedBy.Email, e.LastModifiedBy.FirstName, e.LastModifiedBy.LastName, e.LastModifiedBy.Phone,
                    e.LastModifiedDate, e.Location, e.OwnerId, 
                    e.Owner.Alias, e.Owner.Email, e.Owner.FirstName, e.Owner.LastName, e.Owner.Phone,
                    e.RecurrenceActivityId, e.RecurrenceDayOfMonth, e.RecurrenceDayOfWeekMask, e.RecurrenceEndDateOnly, e.RecurrenceInstance, e.RecurrenceInterval, 
                    e.RecurrenceMonthOfYear, e.RecurrenceStartDateTime, e.RecurrenceTimeZoneSidKey, e.RecurrenceType, e.ReminderDateTime, e.ShowAs, e.Subject, e.SystemModstamp, e.WhatId, e.WhoId, 
                    (Select AttendeeId, CreatedById, CreatedDate, EventId, Id, IsDeleted, LastModifiedById, LastModifiedDate, RespondedDate, Response, Status, SystemModstamp From EventAttendees) 
                    from Event e where e.Id in:ids]);
                for(Event ev:evs){
                    ev.Type='Call';
                }
                update evs;
                evs.addAll([Select e.AccountId, e.ActivityDate, e.ActivityDateTime, e.CreatedById, e.Type,
                    e.CreatedBy.Alias, e.CreatedBy.Email, e.CreatedBy.FirstName, e.CreatedBy.LastName, e.CreatedBy.Phone,
                    e.CreatedDate, e.Description, e.DurationInMinutes, e.Id, e.IsAllDayEvent, e.IsArchived, e.IsChild, e.IsDeleted, e.IsGroupEvent, e.IsPrivate, e.IsRecurrence, e.IsReminderSet, 
                    e.LastModifiedById, 
                    e.LastModifiedBy.Alias, e.LastModifiedBy.Email, e.LastModifiedBy.FirstName, e.LastModifiedBy.LastName, e.LastModifiedBy.Phone,
                    e.LastModifiedDate, e.Location, e.OwnerId, 
                    e.Owner.Alias, e.Owner.Email, e.Owner.FirstName, e.Owner.LastName, e.Owner.Phone,
                    e.RecurrenceActivityId, e.RecurrenceDayOfMonth, e.RecurrenceDayOfWeekMask, e.RecurrenceEndDateOnly, e.RecurrenceInstance, e.RecurrenceInterval, 
                    e.RecurrenceMonthOfYear, e.RecurrenceStartDateTime, e.RecurrenceTimeZoneSidKey, e.RecurrenceType, e.ReminderDateTime, e.ShowAs, e.Subject, e.SystemModstamp, e.WhatId, e.WhoId, 
                    (Select AttendeeId, CreatedById, CreatedDate, EventId, Id, IsDeleted, LastModifiedById, LastModifiedDate, RespondedDate, Response, Status, SystemModstamp From EventAttendees ea) 
                    from Event e where (e.AccountId=:accountId or e.id in :parentEventIds) and e.ActivityDateTime>=:startDate and e.ActivityDateTime<=:endDate]);
                return evs;
        }
        WebService static List<Event> getUserEvents(string userId, DateTime startDate, DateTime endDate){
                List<Event> evs=new List<Event>();
                Set<Id> ids = new Set<Id>();                
                for(EventAttendee ea:[SELECT ea.Event.Id FROM EventAttendee ea WHERE ea.AttendeeId = :userId  and ea.Event.ActivityDateTime>=:startDate and ea.Event.ActivityDateTime<=:endDate]){
                    ids.add(ea.Event.Id);
                }
                evs.addAll([Select e.AccountId, e.ActivityDate, e.ActivityDateTime, e.CreatedById, e.Type,
                    e.CreatedBy.Alias, e.CreatedBy.Email, e.CreatedBy.FirstName, e.CreatedBy.LastName, e.CreatedBy.Phone,
                    e.CreatedDate, e.Description, e.DurationInMinutes, e.Id, e.IsAllDayEvent, e.IsArchived, e.IsChild, e.IsDeleted, e.IsGroupEvent, e.IsPrivate, e.IsRecurrence, e.IsReminderSet, 
                    e.LastModifiedById, 
                    e.LastModifiedBy.Alias, e.LastModifiedBy.Email, e.LastModifiedBy.FirstName, e.LastModifiedBy.LastName, e.LastModifiedBy.Phone,
                    e.LastModifiedDate, e.Location, e.OwnerId, 
                    e.Owner.Alias, e.Owner.Email, e.Owner.FirstName, e.Owner.LastName, e.Owner.Phone,
                    e.RecurrenceActivityId, e.RecurrenceDayOfMonth, e.RecurrenceDayOfWeekMask, e.RecurrenceEndDateOnly, e.RecurrenceInstance, e.RecurrenceInterval, 
                    e.RecurrenceMonthOfYear, e.RecurrenceStartDateTime, e.RecurrenceTimeZoneSidKey, e.RecurrenceType, e.ReminderDateTime, e.ShowAs, e.Subject, e.SystemModstamp, e.WhatId, e.WhoId, 
                    (Select AttendeeId, CreatedById, CreatedDate, EventId, Id, IsDeleted, LastModifiedById, LastModifiedDate, RespondedDate, Response, Status, SystemModstamp From EventAttendees ea) 
                    from Event e where e.id in :ids]);
                evs.addAll([Select e.AccountId, e.ActivityDate, e.ActivityDateTime, e.CreatedById, e.Type,
                    e.CreatedBy.Alias, e.CreatedBy.Email, e.CreatedBy.FirstName, e.CreatedBy.LastName, e.CreatedBy.Phone,
                    e.CreatedDate, e.Description, e.DurationInMinutes, e.Id, e.IsAllDayEvent, e.IsArchived, e.IsChild, e.IsDeleted, e.IsGroupEvent, e.IsPrivate, e.IsRecurrence, e.IsReminderSet, 
                    e.LastModifiedById, 
                    e.LastModifiedBy.Alias, e.LastModifiedBy.Email, e.LastModifiedBy.FirstName, e.LastModifiedBy.LastName, e.LastModifiedBy.Phone,
                    e.LastModifiedDate, e.Location, e.OwnerId, 
                    e.Owner.Alias, e.Owner.Email, e.Owner.FirstName, e.Owner.LastName, e.Owner.Phone,
                    e.RecurrenceActivityId, e.RecurrenceDayOfMonth, e.RecurrenceDayOfWeekMask, e.RecurrenceEndDateOnly, e.RecurrenceInstance, e.RecurrenceInterval, 
                    e.RecurrenceMonthOfYear, e.RecurrenceStartDateTime, e.RecurrenceTimeZoneSidKey, e.RecurrenceType, e.ReminderDateTime, e.ShowAs, e.Subject, e.SystemModstamp, e.WhatId, e.WhoId, 
                    (Select AttendeeId, CreatedById, CreatedDate, EventId, Id, IsDeleted, LastModifiedById, LastModifiedDate, RespondedDate, Response, Status, SystemModstamp From EventAttendees ea) 
                    from Event e where (e.CreatedById=:userId or e.OwnerId=:userId) and e.ActivityDateTime>=:startDate and e.ActivityDateTime<=:endDate]);
                return evs;
        }
        WebService static List<Event> getContactEvents(string contactId, DateTime startDate, DateTime endDate){
                List<Event> evs=new List<Event>();
                
                List<EventAttendee> eas=new List<EventAttendee>();
                eas=[SELECT ea.Event.Id FROM EventAttendee ea WHERE ea.AttendeeId = :contactId and ea.Event.ActivityDateTime>=:startDate and ea.Event.ActivityDateTime<=:endDate];
                Set<Id> ids = new Set<Id>();
                for(EventAttendee ea:eas){
                    ids.add(ea.Event.Id);
                }
                evs.addAll([Select e.AccountId, e.ActivityDate, e.ActivityDateTime, e.CreatedById, e.Type,
                e.CreatedBy.Alias, e.CreatedBy.Email, e.CreatedBy.FirstName, e.CreatedBy.LastName, e.CreatedBy.Phone,
                e.CreatedDate, e.Description, e.DurationInMinutes, e.Id, e.IsAllDayEvent, e.IsArchived, e.IsChild, e.IsDeleted, e.IsGroupEvent, e.IsPrivate, e.IsRecurrence, e.IsReminderSet, 
                e.LastModifiedById, 
                e.LastModifiedBy.Alias, e.LastModifiedBy.Email, e.LastModifiedBy.FirstName, e.LastModifiedBy.LastName, e.LastModifiedBy.Phone,
                e.LastModifiedDate, e.Location, e.OwnerId, 
                e.Owner.Alias, e.Owner.Email, e.Owner.FirstName, e.Owner.LastName, e.Owner.Phone,
                e.RecurrenceActivityId, e.RecurrenceDayOfMonth, e.RecurrenceDayOfWeekMask, e.RecurrenceEndDateOnly, e.RecurrenceInstance, e.RecurrenceInterval, 
                e.RecurrenceMonthOfYear, e.RecurrenceStartDateTime, e.RecurrenceTimeZoneSidKey, e.RecurrenceType, e.ReminderDateTime, e.ShowAs, e.Subject, e.SystemModstamp, e.WhatId, e.WhoId, 
                (Select AttendeeId, CreatedById, CreatedDate, EventId, Id, IsDeleted, LastModifiedById, LastModifiedDate, RespondedDate, Response, Status, SystemModstamp From EventAttendees ea) 
                from Event e where e.id in:ids]);
                return evs;
        }
        WebService static List<Contact> getEventContacts(string eventId){
            Set<Id> ids = new Set<Id>();
            for(EventAttendee ea:[select ea.AttendeeId FROM EventAttendee ea where ea.Event.Id=:eventId]){
                if(ids.contains(ea.AttendeeId)) continue;
                ids.add(ea.AttendeeId);
            }
            Event ev=[Select whoid from Event where id=:eventId];
            if(ev.whoid!=null && !ids.contains(ev.whoid)) ids.add(ev.whoid);
            return [select id, firstname, lastname, email, phone, AccountId from Contact where Id in :ids];
        }
}