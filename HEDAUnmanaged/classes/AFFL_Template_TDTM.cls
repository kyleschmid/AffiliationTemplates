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
* @description Implements affiliation templates when an affiliation is created/changed
*/
global without sharing class AFFL_Template_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description Trigger Handler on Affiliation__c that handles affiliation templates
    * @param listNew the list of Affiliations from trigger new.
    * @param listOld the list of Affiliations from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Affiliations.
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        List<Affiliation__c> oldList;
        List<Affiliation__c> newList;
        
        // Get set of all affiliation ids
        // Get set of all account ids for old and new affiliations
        // Get set of contact ids
        Set<Id> afflIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete) {
            oldList = (List<Affiliation__c>)listOld;
            for (Affiliation__c a:oldList) {
                afflIds.add(a.Id);
                accIds.add(a.Account__c);
                conIds.add(a.Contact__c);
            }
        }
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            newList = (List<Affiliation__c>)listNew;
            for (Affiliation__c a:newList) {
                afflIds.add(a.Id);
                accIds.add(a.Account__c);
                conIds.add(a.Contact__c);
            }
        }
        
        // Check to see if anything has changed and exit if it hasn't
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            Boolean changed = false;
            for (Integer i = 0; i < newList.size(); i++) {
                if (oldList[i].Contact__c != newList[i].Contact__c ||
                    oldList[i].Account__c != newList[i].Account__c ||
                    oldList[i].Primary__c != newList[i].Primary__c ||
                    oldList[i].Role__c != newList[i].Role__c ||
                    oldList[i].Status__c != newList[i].Status__c) {
                    
                    changed = true;
                    break;
                }
            }
            if (!changed) return (new DmlWrapper());
        }
        
        // Get map of all templates: Account id is key and list of templates is value
        Map<Id, List<AffiliationTemplate__c>> templates = new Map<Id, List<AffiliationTemplate__c>>();
        Set<Id> templateIds = new Set<Id>();
        Set<String> conFields = new Set<String>();
        Set<String> accFields = new Set<String>();
        for (AffiliationTemplate__c t:[SELECT Id, Account__c, Object__c, Primary__c, Role__c, Status__c, FieldNameLower__c FROM AffiliationTemplate__c WHERE Account__c IN :accIds]) {
            if (!templates.containsKey(t.Account__c))
                templates.put(t.Account__c, new List<AffiliationTemplate__c>());
            templates.get(t.Account__c).add(t);
            templateIds.add(t.Id);
            if (t.Object__c.equals('Contact')) conFields.add(t.FieldNameLower__c);
            else accFields.add(t.FieldNameLower__c);
        }
        
        // Get map of contacts with Id as key
        Map<Id, Contact> cons = UTIL_AffiliationTemplate.GetContactMap(conFields, conIds);
        
        // Get Set of all administrative account ids
        Set<Id> adminIds = new Set<Id>();
        for (Contact c:cons.values())
            adminIds.add(c.AccountId);
        
        // Get map of administrative accounts with Id as key
        Map<Id, Account> adminAccs = UTIL_AffiliationTemplate.GetAdminAccountMap(accFields, adminIds);
        
        // newList is read only so we have to duplicate
        List<Affiliation__c> newAfflList = new List<Affiliation__c>();
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate)
            newAfflList.addAll(newList);
        
        // Actions to perform after update/after delete
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete) {
            
            // Uncheck checkbox on contact or administrative account for each affiliation that matches each template
            for (Affiliation__c a:oldList) {
                if (templates.containsKey(a.Account__c)) {
                    for (AffiliationTemplate__c t:templates.get(a.Account__c)) {
                        if (UTIL_AffiliationTemplate.AffiliationMatches(t, a)) {
                            try {
                                if (t.Object__c.equals('Contact')) {
                                    cons.get(a.Contact__c).put(t.FieldNameLower__c, false);
                                } else {
                                    adminAccs.get(cons.get(a.Contact__c).AccountId).put(t.FieldNameLower__c, false);
                                }
                            } catch (Exception e) {}
                        }
                    }
                }
            }
            
            // Add other affiliation templates that have to do with these fields
            for (AffiliationTemplate__c t:[SELECT Id, Account__c, Object__c, Primary__c, Role__c, FieldNameLower__c, Status__c FROM AffiliationTemplate__c WHERE ((Object__c = :'Contact' AND FieldNameLower__c IN :conFields) OR FieldNameLower__c IN :accFields) AND Id NOT IN :templateIds]) {
                if (!templates.containsKey(t.Account__c))
                    templates.put(t.Account__c, new List<AffiliationTemplate__c>());
                templates.get(t.Account__c).add(t);
            }
            
            // Add affiliations that have to do with these new templates
            newAfflList.addAll([SELECT Id, Contact__c, Contact__r.AccountId, Account__c, Primary__c, Role__c, Status__c FROM Affiliation__c WHERE Contact__c IN :conIds AND Account__c IN :(templates.keySet()) AND Id NOT IN :afflIds]);
        }
        
        // Actions to perform after insert/after update/after delete
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete) {
            
            // Check checkbox on contact or administrative account for each affiliation that matches each template
            for (Affiliation__c a:newAfflList) {
                if (templates.containsKey(a.Account__c)) {
                    for (AffiliationTemplate__c t:templates.get(a.Account__c)) {
                        if (UTIL_AffiliationTemplate.AffiliationMatches(t, a)) {
                            try {
                                if (t.Object__c.equals('Contact')) {
                                    cons.get(a.Contact__c).put(t.FieldNameLower__c, true);
                                } else {
                                    adminAccs.get(cons.get(a.Contact__c).AccountId).put(t.FieldNameLower__c, true);
                                }
                            } catch (Exception e) {}
                        }
                    }
                }
            }
        }
        
        update cons.values();
        update adminAccs.values();
        
        return (new DmlWrapper());
    }
}