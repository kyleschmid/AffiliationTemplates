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
* @description Tests for UTIL_AffiliationTemplate
*/
@isTest
private class UTIL_AffiliationTemplate_TEST {
    
    /*********************************************************************************************************
    * @description Test Method for AffiliationMatches
    */
    @isTest
    static void test_match_method() {
        
        Account a1 = [SELECT Id FROM Account WHERE Name = :'test_acc_1'];
        Account a2 = [SELECT Id FROM Account WHERE Name = :'test_acc_2'];
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :'test2'];
        
        // Account
        npe5__Affiliation__c affl1 = new npe5__Affiliation__c(npe5__Contact__c = c1.Id, npe5__Organization__c = a1.Id, npe5__Primary__c = false, npe5__Role__c = 'test', npe5__Status__c = 'Current');
        AffiliationTemplate__c r1 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a1.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        AffiliationTemplate__c r2 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a2.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        
        // Primary
        npe5__Affiliation__c affl2 = new npe5__Affiliation__c(npe5__Contact__c = c1.Id, npe5__Organization__c = a1.Id, npe5__Primary__c = true, npe5__Role__c = 'test', npe5__Status__c = 'Current');
        npe5__Affiliation__c affl3 = new npe5__Affiliation__c(npe5__Contact__c = c1.Id, npe5__Organization__c = a1.Id, npe5__Primary__c = false, npe5__Role__c = 'test', npe5__Status__c = 'Current');
        AffiliationTemplate__c r3 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a1.Id, Primary__c = true, Role__c = 'test', Status__c = 'Current');
        
        // Role
        npe5__Affiliation__c affl4 = new npe5__Affiliation__c(npe5__Contact__c = c1.Id, npe5__Organization__c = a1.Id, npe5__Primary__c = false, npe5__Role__c = 'test', npe5__Status__c = 'Current');
        AffiliationTemplate__c r4 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a1.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        AffiliationTemplate__c r5 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a1.Id, Primary__c = false, Role__c = 'nottest', Status__c = 'Current');
        
        // Status
        npe5__Affiliation__c affl5 = new npe5__Affiliation__c(npe5__Contact__c = c1.Id, npe5__Organization__c = a1.Id, npe5__Primary__c = false, npe5__Role__c = 'test', npe5__Status__c = 'Current');
        AffiliationTemplate__c r6 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a1.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        AffiliationTemplate__c r7 = new AffiliationTemplate__c(Object__c = 'Contact', Account__c = a1.Id, Primary__c = false, Role__c = 'test', Status__c = 'NotCurrent');
        
        insert new List<npe5__Affiliation__c>{affl1, affl2, affl3, affl4, affl5};
        Map<Id, npe5__Affiliation__c> affls = new Map<Id, npe5__Affiliation__c>([SELECT Id, npe5__Organization__c, npe5__Role__c, npe5__Status__c, npe5__Primary__c FROM npe5__Affiliation__c]);
        
        Test.startTest();
        
        // Account
        System.assert(UTIL_AffiliationTemplate.AffiliationMatches(r1, affls.get(affl1.Id)));
        System.assert(!UTIL_AffiliationTemplate.AffiliationMatches(r2, affls.get(affl1.Id)));
        
        // Primary
        System.assert(UTIL_AffiliationTemplate.AffiliationMatches(r3, affls.get(affl2.Id)));
        System.assert(!UTIL_AffiliationTemplate.AffiliationMatches(r3, affls.get(affl3.Id)));
        
        // Role
        System.assert(UTIL_AffiliationTemplate.AffiliationMatches(r4, affls.get(affl4.Id)));
        System.assert(!UTIL_AffiliationTemplate.AffiliationMatches(r5, affls.get(affl4.Id)));
        
        // Status
        System.assert(UTIL_AffiliationTemplate.AffiliationMatches(r6, affls.get(affl5.Id)));
        System.assert(!UTIL_AffiliationTemplate.AffiliationMatches(r7, affls.get(affl5.Id)));
        
        Test.stopTest();
    }
    
    /*********************************************************************************************************
    * @description Test Method for GetContactMap
    */
    @isTest
    static void test_contact_query_method() {
        
        Id conId = [SELECT Id FROM Contact WHERE LastName = :'test1'].Id;
        Set<Id> conIds = new Set<Id>{conId};
        Set<String> fieldNames = new Set<String>();
        
        Test.startTest();
        
        Map<Id, Contact> result = UTIL_AffiliationTemplate.GetContactMap(fieldNames, conIds);
        
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assert(result.containsKey(conId));
    }
    
    /*********************************************************************************************************
    * @description Test Method for GetAdminAccountMap
    */
    @isTest
    static void test_account_query_method() {
        
        Id accId = [SELECT Id FROM Account WHERE Name = :'test_acc_1'].Id;
        Set<Id> accIds = new Set<Id>{accId};
        Set<String> fieldNames1 = new Set<String>();
        Set<String> fieldNames2 = new Set<String>{'Name'};
        
        Test.startTest();
        
        Map<Id, Account> result1 = UTIL_AffiliationTemplate.GetAdminAccountMap(fieldNames1, accIds);
        Map<Id, Account> result2 = UTIL_AffiliationTemplate.GetAdminAccountMap(fieldNames2, accIds);
        
        Test.stopTest();
        
        System.assertEquals(0, result1.size());
        System.assertEquals(1, result2.size());
        System.assert(result2.containsKey(accId));
    }
    
    /*********************************************************************************************************
    * @description Test Method for CreateTriggerHandlers
    */
    @isTest
    static void test_create_method() {
        
        Set<String> classes = new Set<String>{'AFFL_Template_TDTM'};
        
        Test.startTest();
        
        UTIL_AffiliationTemplate.CreateTriggerHandlers();
        Integer size = [SELECT Id FROM npsp__Trigger_Handler__c WHERE npsp__Class__c IN :classes].size();
        
        Test.stopTest();
        
        System.assertEquals(2, size);
    }
    
    /*********************************************************************************************************
    * @description Test setup method
    */
    @testSetup
    static void setup() {
        
        List<npsp__Trigger_Handler__c> handlers = npsp.TDTM_Config_API.getDefaultRecords();
        
        handlers.add(new npsp__Trigger_Handler__c(npsp__Active__c = true, npsp__Asynchronous__c = false,
            npsp__Class__c = 'AFFL_Template_TDTM', npsp__Load_Order__c = 5, npsp__Object__c = 'npe5__Affiliation__c',
            npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete'));
        
        insert handlers;
        
        Account a1 = new Account(Name = 'test_acc_1');
        Account a2 = new Account(Name = 'test_acc_2');
        insert new List<Account>{a1, a2};
        
        Contact c1 = new Contact(LastName = 'test1');
        Contact c2 = new Contact(LastName = 'test2');
        insert new List<Contact>{c1, c2};
    }
}
