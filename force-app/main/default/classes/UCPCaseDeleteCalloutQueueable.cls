/**
 * Created by POTERFI on 3/25/2022.
 */

public with sharing class UCPCaseDeleteCalloutQueueable implements Queueable, Database.AllowsCallouts {

    Set<String> caseExternalIdsToDelete;

    public UCPCaseDeleteCalloutQueueable(Set<String> caseExternalIdsToDelete) {
        this.caseExternalIdsToDelete = caseExternalIdsToDelete;
    }

    public void execute(QueueableContext context) {
        UCPCaseCalloutService.sendDeleteCallout(caseExternalIdsToDelete);
    }

}