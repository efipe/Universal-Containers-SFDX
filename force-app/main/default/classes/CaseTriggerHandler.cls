/**
 * Created by POTERFI on 3/23/2022.
 */

public with sharing class CaseTriggerHandler {
    // zrobic na konstruktorze
    private Set<String> caseExternalIdsToDelete = new Set<String>();
    CaseTriggerHelper helper = new CaseTriggerHelper();

    public void run() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    beforeInsert(newCase);
                }
            } else if (Trigger.isUpdate) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    for (Case oldCase : (List<Case>) Trigger.old) {
                        beforeUpdate(newCase, oldCase);
                    }
                }
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    afterInsert(newCase);
                }
            } else if (Trigger.isUpdate) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    for (Case oldCase : (List<Case>) Trigger.old) {
                        afterUpdate(newCase, oldCase);
                    }
                }
            } else if (Trigger.isDelete) {
                for (Case oldCase : (List<Case>) Trigger.old) {
                    afterDelete(oldCase);
                }
            }
        }
        andFinally();
    }

    public void beforeInsert(Case newCase) {
        helper.setDateTimeOfLastStatusChange(newCase);
        helper.assignRelatedBooking(newCase);
        helper.setLastChangeOrgUponInsert(newCase);
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

    }

    public void afterUpdate(Case newCase, Case oldCase) {

    }

    public void afterDelete(Case oldCase) {
        if (oldCase.External_Id__c != null) {
            caseExternalIdsToDelete.add(oldCase.External_Id__c);
        }

    }

    public void andFinally(){
        if (Trigger.isDelete ) {
            if (!caseExternalIdsToDelete.isEmpty()){
                UCPCaseCalloutService.sendDeleteCallout(caseExternalIdsToDelete);
            }
        } else {
        //    UCPCaseCalloutService.sendUpsertCallout();
        }
    }
}


