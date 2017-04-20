/*
    Copyright (c) 2017, Kyle Schmid
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Kyle Schmid
* @date 2017
* @description Implements affiliation templates when an affiliation template is created/changed
*/
global class AFFLTMP_Template_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description Trigger Handler on AffiliationTemplate__c that handles affiliation templates
    * @param listNew the list of Affiliation Templates from trigger new.
    * @param listOld the list of Affiliation Templates from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Affiliation Templates.
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        List<AffiliationTemplate__c> oldList;
        List<AffiliationTemplate__c> newList;
        
        // Get set of all template ids
        // Get set of all account ids for old and new templates
        // Get set of all field names for old and new templates
        Set<Id> templateIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<String> conFields = new Set<String>();
        Set<String> accFields = new Set<String>();
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete) {
            oldList = (List<AffiliationTemplate__c>)listOld;
            for (AffiliationTemplate__c t:oldList) {
                templateIds.add(t.Id);
                accIds.add(t.Account__c);
                if (t.Object__c.equals('Contact')) conFields.add(t.FieldNameLower__c);
                else accFields.add(t.FieldNameLower__c);
            }
        }
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            newList = (List<AffiliationTemplate__c>)listNew;
            for (AffiliationTemplate__c t:newList) {
                templateIds.add(t.Id);
                accIds.add(t.Account__c);
                if (t.Object__c.equals('Contact')) conFields.add(t.FieldNameLower__c);
                else accFields.add(t.FieldNameLower__c);
            }
        }
        
        // Get map of all affiliations: Account id is key and list of affiliations is value
        // Get set of contact ids
        // Get set of administrative account ids
        // Get set of affiliation ids
        Map<Id, List<Affiliation__c>> affls = new Map<Id, List<Affiliation__c>>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> adminIds = new Set<Id>();
        Set<Id> afflIds = new Set<Id>();
        for (Affiliation__c a:[SELECT Id, Contact__c, Contact__r.AccountId, Account__c, Primary__c, Role__c, Status__c FROM Affiliation__c WHERE Account__c IN :accIds]) {
            if (!affls.containsKey(a.Account__c))
                affls.put(a.Account__c, new List<Affiliation__c>());
            affls.get(a.Account__c).add(a);
            conIds.add(a.Contact__c);
            adminIds.add(a.Contact__r.AccountId);
            afflIds.add(a.Id);
        }
        
        // Get map of contacts with Id as key
        Map<Id, Contact> cons = UTIL_AffiliationTemplate.GetContactMap(conFields, conIds);
        
        // Get map of administrative accounts with Id as key
        Map<Id, Account> adminAccs = UTIL_AffiliationTemplate.GetAdminAccountMap(accFields, adminIds);
        
        // newList is read only so we have to duplicate
        List<AffiliationTemplate__c> newTemplateList = new List<AffiliationTemplate__c>();
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate)
            newTemplateList.addAll(newList);
        
        // Actions to perform after update/after delete
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete) {
            
            // Uncheck checkbox on contact or administrative account for each affiliation that matches each template
            for (AffiliationTemplate__c t:oldList) {
                if (affls.containsKey(t.Account__c)) {
                    for (Affiliation__c a:affls.get(t.Account__c)) {
                        if (UTIL_AffiliationTemplate.AffiliationMatches(t, a)) {
                            try {
                                if (t.Object__c.equals('Contact')) {
                                    cons.get(a.Contact__c).put(t.FieldNameLower__c, false);
                                } else {
                                    adminAccs.get(a.Contact__r.AccountId).put(t.FieldNameLower__c, false);
                                }
                            } catch (Exception e) {}
                        }
                    }
                }
            }
            
            // Add other affiliation templates that have to do with these accounts
            newTemplateList.addAll([SELECT Id, Account__c, Object__c, Primary__c, Role__c, FieldNameLower__c, Status__c FROM AffiliationTemplate__c WHERE ((Object__c = :'Contact' AND FieldNameLower__c IN :conFields) OR FieldNameLower__c IN :accFields) AND Id NOT IN :templateIds]);
            
            // Add affiliations that have to do with these new templates
            Set<Id> newAccIds = new Set<Id>();
            for (AffiliationTemplate__c t:newTemplateList)
                newAccIds.add(t.Account__c);
            newAccIds.removeAll(accIds);
            for (Affiliation__c a:[SELECT Id, Contact__c, Contact__r.AccountId, Account__c, Primary__c, Role__c, Status__c FROM Affiliation__c WHERE Contact__c IN :conIds AND Account__c IN :newAccIds AND Id NOT IN :afflIds]) {
                if (!affls.containsKey(a.Account__c))
                    affls.put(a.Account__c, new List<Affiliation__c>());
                affls.get(a.Account__c).add(a);
            }
        }
        
        // Actions to perform after insert/after update/after delete
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete) {
            
            // Check checkbox on contact or administrative account for each affiliation that matches each template
            for (AffiliationTemplate__c t:newTemplateList) {
                if (affls.containsKey(t.Account__c)) {
                    for (Affiliation__c a:affls.get(t.Account__c)) {
                        if (UTIL_AffiliationTemplate.AffiliationMatches(t, a)) {
                            try {
                                if (t.Object__c.equals('Contact')) {
                                    cons.get(a.Contact__c).put(t.FieldNameLower__c, true);
                                } else {
                                    adminAccs.get(a.Contact__r.AccountId).put(t.FieldNameLower__c, true);
                                }
                            } catch (Exception e) {}
                        }
                    }
                }
            }
        }
        
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)cons.values()); // Add contacts to dml wrapper
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)adminAccs.values()); // Add administrative accounts to dml wrapper
        
        return dmlWrapper;
    }
}