/**
 * Created by POTERFI on 3/25/2022.
 */

public with sharing class UCPCaseUpsertCalloutQueueable implements Queueable, Database.AllowsCallouts {

    Set<String> caseExternalIdsToUpsert;

    public UCPCaseUpsertCalloutQueueable(Set<String> caseExternalIdsToUpsert) {
        this.caseExternalIdsToUpsert = caseExternalIdsToUpsert;
    }

    public void execute(QueueableContext context) {
        UCPCaseCalloutService.sendUpsertCallout(caseExternalIdsToUpsert);
    }
}