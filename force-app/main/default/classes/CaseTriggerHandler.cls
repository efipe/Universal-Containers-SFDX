/**
 * Created by POTERFI on 3/23/2022.
 */

public with sharing class CaseTriggerHandler {
    // zrobic na konstruktorze

    private static Set<String> caseExternalIdsToDelete = new Set<String>();
    private static Set<String> caseExternalIdsToUpsert = new Set<String>();
    private static final String DESTINATION_ORG_NAME = 'PAULINA';
    private static boolean isUpsertRequestSent = false;
    private static boolean isDeleteRequestSent = false;

    CaseTriggerHelper helper = new CaseTriggerHelper();

    public void run() {
        if (Trigger.isBefore) {
            bulkBefore();
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    beforeInsert(newCase);
                }
            } else if (Trigger.isUpdate) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    beforeUpdate(newCase, (Case) Trigger.oldMap.get(newCase.Id));
                }
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    afterInsert(newCase);
                }
            } else if (Trigger.isUpdate) {
                System.debug('Trigger new size ' + Trigger.new.size());
                for (Case newCase : (List<Case>) Trigger.new) {
                    afterUpdate(newCase, (Case) Trigger.oldMap.get(newCase.Id));
                }
            } else if (Trigger.isDelete) {
                for (Case oldCase : (List<Case>) Trigger.old) {
                    afterDelete(oldCase);
                }
            }
        }
        andFinally();
    }

    public void bulkBefore() {
        // TODO if when case.Booking_number__r == null && booking_number_from_webform != null
        List<String> bookingNumbers = new List<String>();
        for (Case newCase : (List<Case>) Trigger.new) {
            bookingNumbers.add(newCase.Booking_number_from_webform__c);
        }
        helper.bookingsRelated = new List<Schedule_booking__c>([SELECT Booking_name__c, Id FROM Schedule_booking__c WHERE Booking_name__c IN :bookingNumbers]);
        for (Schedule_booking__c booking : helper.bookingsRelated) {
            helper.bookingsNamesAndIds.put(booking.Booking_name__c, booking.Id);
        }
    }

    public void bulkAfter() {

    }

    public void beforeInsert(Case newCase) {
        helper.setDateTimeOfLastStatusChange(newCase);
        helper.assignRelatedBooking(newCase);
        helper.setLastChangeOrgUponInsert(newCase);
        helper.generateExternalId(newCase);
    }

    public void beforeUpdate(Case newCase, Case oldCase) {
        helper.getDefaultQueue(newCase, oldCase);
        helper.getQueueForCase(newCase);
        helper.incrementTimesOpenedField(newCase, oldCase);
        helper.setDateTimeOfLastStatusChange(newCase, oldCase);
        helper.calculatePreviousCloseTimes(newCase, oldCase);
        helper.setLastChangeOrgOnCaseUponUpdate(newCase, oldCase);
    }

    public void afterInsert(Case newCase) {
        System.debug('After insert triggered');

        if (newCase.External_Id__c != null) {
            System.debug('External id: ' + newCase.External_Id__c);
            System.debug('newCase.Last_Change_Org_Id__c ' + newCase.Last_Change_Org_Id__c);
            if (newCase.Last_Change_Org_Id__c != DESTINATION_ORG_NAME){
                caseExternalIdsToUpsert.add(newCase.External_Id__c);
            }
        }
    }

    public void afterUpdate(Case newCase, Case oldCase) {
        System.debug('After update method entry');
        if (newCase.External_Id__c != null) {
            System.debug('External id: ' + newCase.External_Id__c);
            System.debug('newCase.Last_Change_Org_Id__c ' + newCase.Last_Change_Org_Id__c);
            if (newCase.Last_Change_Org_Id__c != DESTINATION_ORG_NAME && helper.isIntegrationSensitiveDataChanged(newCase, oldCase)) {
                caseExternalIdsToUpsert.add(newCase.External_Id__c);
                System.debug('sensitive data changed: ');
                System.debug(newCase.Preferred_language__c + ' : ' + oldCase.Preferred_language__c);
                System.debug(newCase.RecordTypeId + ' : ' + oldCase.RecordTypeId);
                System.debug(newCase.Priority + ' : ' + oldCase.Priority);
                System.debug(newCase.Origin + ' : ' + oldCase.Origin);
                System.debug(newCase.Subject + ' : ' + oldCase.Subject);
                System.debug(newCase.Description + ' : ' + oldCase.Description);
                System.debug(newCase.Comments + ' : ' + oldCase.Comments);
                System.debug(newCase.SuppliedPhone + ' : ' + oldCase.SuppliedPhone);
                System.debug(newCase.SuppliedEmail + ' : ' + oldCase.SuppliedEmail);
                System.debug(newCase.SuppliedName + ' : ' + oldCase.SuppliedName);
            }
        }
    }

    public void afterDelete(Case oldCase) {
        if (oldCase.External_Id__c != null) {
            if (oldCase.Last_Change_Org_Id__c != DESTINATION_ORG_NAME) {
                caseExternalIdsToDelete.add(oldCase.External_Id__c);
            }
        }
    }

    public void andFinally() {
        if (Trigger.isDelete) {
            if (!caseExternalIdsToDelete.isEmpty() && isDeleteRequestSent == false) {
                isDeleteRequestSent = true;
                UCPCaseCalloutService.sendDeleteCallout(caseExternalIdsToDelete);
            }
        } else {
            if (!caseExternalIdsToUpsert.isEmpty() && isUpsertRequestSent == false) {
                isUpsertRequestSent = true;
                UCPCaseCalloutService.sendUpsertCallout(caseExternalIdsToUpsert);
            }
        }
    }
}


