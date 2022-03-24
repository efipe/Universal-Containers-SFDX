public with sharing class CaseTriggerHelper {

    private static final String MY_LAST_CHANGE_ORG_NAME = 'FILIP';
    public List<Schedule_booking__c> bookingsRelated;
    public Map<String, Id> bookingsNamesAndIds = new Map<String, Id>();

    public void getQueueForCase(Case newCase) {
        if (newCase.OwnerId.getSobjectType() != User.getSObjectType()) {
            Id queueLanguageId = CaseRoutingService.getInstance().getQueueForCase(newCase);
            if (queueLanguageId != null) {
                newCase.OwnerId = queueLanguageId;
            }
        }
    }

    public void generateExternalId(Case newCase) {
        if (newCase.External_Id__c == null) {
            newCase.External_Id__c = GuidGenerator.generate();
        }
    }

    public void getDefaultQueue(Case newCase, Case oldCase) {
        if (oldCase.Preferred_language__c != newCase.Preferred_language__c) {
            newCase.OwnerId = CaseRoutingService.getInstance().getDefaultQueue(oldCase.OwnerId, LanguageEnum.valueOf(oldCase.Preferred_language__c));
        }

    }

    public void incrementTimesOpenedField(Case newCase, Case oldCase) {
        if (oldCase.Status == 'Closed' && oldCase.Status != newCase.Status) {
            if (newCase.Times_reopened__c != null) {
                newCase.Times_reopened__c += 1;
            } else {
                newCase.Times_reopened__c = 1;
            }
        }
    }

    public void setDateTimeOfLastStatusChange(Case newCase, Case oldCase) {
        if (oldCase.Status != newCase.Status) {
            newCase.Last_status_change_date__c = Datetime.now();
        }
    }

    public void setDateTimeOfLastStatusChange(Case newCase) {
        newCase.Last_status_change_date__c = Datetime.now();
    }

    public void calculatePreviousCloseTimes(Case newCase, Case oldCase) {
        String statusIndicatingClosed = 'Closed';
        if (oldCase.Status == statusIndicatingClosed && newCase.Status != statusIndicatingClosed) {
            newCase.previous_closed_total_time__c = newCase.previous_closed_total_time__c += oldCase.Recent_close_time__c;
        }
    }

    public void assignRelatedBooking(Case newCase) {
        if (newCase.Related_booking__c == null) {
            newCase.Related_booking__c = bookingsNamesAndIds.get(newCase.Booking_number_from_webform__c);
        }
    }

    public void setLastChangeOrgOnCaseUponUpdate(Case newCase, Case oldCase) {
        if (isIntegrationSensitiveDataChanged(newCase, oldCase)) {
            if (RestUtilities.isRestApiContext() == false) {
                newCase.Last_Change_Org_Id__c = MY_LAST_CHANGE_ORG_NAME;
            }
        }
    }

    public Boolean isIntegrationSensitiveDataChanged(Case newCase, Case oldCase) {
        return newCase.Preferred_language__c != oldCase.Preferred_language__c ||
                newCase.RecordTypeId != oldCase.RecordTypeId ||
                newCase.Priority != oldCase.Priority ||
                newCase.Origin != oldCase.Origin ||
                newCase.Subject != oldCase.Subject ||
                newCase.Description != oldCase.Description ||
                newCase.Comments != oldCase.Comments ||
                newCase.SuppliedPhone != oldCase.SuppliedPhone ||
                newCase.SuppliedEmail != oldCase.SuppliedEmail ||
                newCase.SuppliedName != oldCase.SuppliedName;
    }

    public void setLastChangeOrgUponInsert(Case newCase) {
        if (String.isBlank(newCase.Last_Change_Org_Id__c)) {
            newCase.Last_Change_Org_Id__c = MY_LAST_CHANGE_ORG_NAME;
        }
    }


}