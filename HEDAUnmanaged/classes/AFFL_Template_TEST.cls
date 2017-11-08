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
* @description Tests for AFFL_Template_TDTM
*/
@isTest
private class AFFL_Template_TEST {
    
    /*********************************************************************************************************
    * @description Test insert one affiliation that checks box on a record and
    * another that should not
    */
    @isTest
    static void test_insert() {
        
        Account a1 = [SELECT Id FROM Account WHERE Name = :'test_acc_1'];
        
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        Contact c3 = [SELECT Id FROM Contact WHERE LastName = :'test3'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a1.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Current');
        Affiliation__c affl2 = new Affiliation__c(Account__c = a1.Id, Contact__c = c3.Id, Role__c = 'nottest', Status__c = 'Current');
        
        Test.startTest();
        
        insert new List<Affiliation__c>{affl1, affl2};
        
        Test.stopTest();
        
        Contact con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        Contact con3 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test3'];
        System.assert(con1.HasOptedOutOfFax);
        System.assert(!con3.HasOptedOutOfFax);
    }
    
    /*********************************************************************************************************
    * @description Test update an affiliation that checks box on a record
    */
    @isTest
    static void test_update_check() {
        
        Account a1 = [SELECT Id FROM Account WHERE Name = :'test_acc_1'];
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a1.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Former');
        insert affl1;
        
        Contact con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(!con1.HasOptedOutOfFax);
        
        Test.startTest();
        
        affl1.Status__c = 'Current';
        update affl1;
        
        Test.stopTest();
        
        con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
    }
    
    /*********************************************************************************************************
    * @description Test update an affiliation that unchecks box on a record
    */
    @isTest
    static void test_update_uncheck() {
        
        Account a2 = [SELECT Id FROM Account WHERE Name = :'test_acc_2'];
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a2.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Current');
        insert affl1;
        
        Contact con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
        
        Test.startTest();
        
        affl1.Status__c = 'NotCurrent';
        update affl1;
        
        Test.stopTest();
        
        con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(!con1.HasOptedOutOfFax);
    }
    
    /*********************************************************************************************************
    * @description Test update an affiliation that would uncheck box on a
    * record but another affiliation exists that checks box on a record so box
    * should still be checked.
    */
    @isTest
    static void test_update_uncheck_check() {
        
        Account a2 = [SELECT Id FROM Account WHERE Name = :'test_acc_2'];
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a2.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Current');
        Affiliation__c affl2 = new Affiliation__c(Account__c = a2.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Former');
        insert new List<Affiliation__c>{affl1, affl2};
        
        Contact con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
        
        Test.startTest();
        
        affl1.Role__c = 'nottest';
        update affl1;
        
        Test.stopTest();
        
        con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
    }
    
    /*********************************************************************************************************
    * @description Test delete an affiliation that unchecks box on a record
    */
    @isTest
    static void test_delete_uncheck() {
        
        Account a2 = [SELECT Id FROM Account WHERE Name = :'test_acc_2'];
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a2.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Current');
        insert affl1;
        
        Contact con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
        
        Test.startTest();
        
        delete affl1;
        
        Test.stopTest();
        
        con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(!con1.HasOptedOutOfFax);
    }
    
    /*********************************************************************************************************
    * @description Test deletes an affiliation that would uncheck box on a
    * record but another affiliation exists that checks box on a record so box
    * should still be checked.
    */
    @isTest
    static void test_delete_uncheck_check() {
        
        Account a2 = [SELECT Id FROM Account WHERE Name = :'test_acc_2'];
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a2.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Current');
        Affiliation__c affl2 = new Affiliation__c(Account__c = a2.Id, Contact__c = c1.Id, Role__c = 'test', Status__c = 'Former');
        insert new List<Affiliation__c>{affl1, affl2};
        
        Contact con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
        
        Test.startTest();
        
        delete affl1;
        
        Test.stopTest();
        
        con1 = [SELECT Id, HasOptedOutOfFax FROM Contact WHERE LastName = :'test1'];
        System.assert(con1.HasOptedOutOfFax);
    }
    
    /*********************************************************************************************************
    * @description Test insert/update an affiliation that updates a field on related account
    */
    @isTest
    static void test_related_account() {
        
        Account a3 = [SELECT Id FROM Account WHERE Name = :'test_acc_3'];
        Contact c4 = [SELECT Id FROM Contact WHERE LastName = :'test4'];
        
        Affiliation__c affl1 = new Affiliation__c(Account__c = a3.Id, Contact__c = c4.Id, Role__c = 'test', Status__c = 'Current');
        
        Test.startTest();
        
        insert affl1;
        affl1.Status__c = 'Former';
        update affl1;
        
        Test.stopTest();
    }
    
    /*********************************************************************************************************
    * @description Test setup method
    */
    @testSetup
    static void setup() {
        
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getTdtmConfig();
        tokens.add(new TDTM_Global_API.TdtmToken('AFFL_Template_TDTM', 'Affiliation__c', 'AfterInsert;AfterUpdate;AfterDelete', 5.0));
        tokens.add(new TDTM_Global_API.TdtmToken('AFFLTMP_Template_TDTM', 'AffiliationTemplate__c', 'AfterInsert;AfterUpdate;AfterDelete', 1.0));
        TDTM_Global_API.setTdtmConfig(tokens);
        
        Account a1 = new Account(Name = 'test_acc_1');
        Account a2 = new Account(Name = 'test_acc_2');
        Account a3 = new Account(Name = 'test_acc_3');
        insert new List<Account>{a1, a2, a3};
        
        Contact c1 = new Contact(LastName = 'test1');
        Contact c2 = new Contact(LastName = 'test2');
        Contact c3 = new Contact(LastName = 'test3');
        Contact c4 = new Contact(LastName = 'test4');
        insert new List<Contact>{c1, c2, c3, c4};
        
        // We use the HasOptedOutOfFax checkbox on Contact because it is a
        // standard field in all orgs
        AffiliationTemplate__c t1 = new AffiliationTemplate__c(Object__c = 'Contact', FieldName__c = 'HasOptedOutOfFax', Account__c = a1.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        AffiliationTemplate__c t2 = new AffiliationTemplate__c(Object__c = 'Contact', FieldName__c = 'HasOptedOutOfFax', Account__c = a2.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        AffiliationTemplate__c t3 = new AffiliationTemplate__c(Object__c = 'Contact', FieldName__c = 'HasOptedOutOfFax', Account__c = a2.Id, Primary__c = false, Role__c = 'test', Status__c = 'Former');
        AffiliationTemplate__c t4 = new AffiliationTemplate__c(Object__c = 'Related Account', FieldName__c = 'Industry', Account__c = a3.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        insert new List<AffiliationTemplate__c>{t1, t2, t3, t4};
    }
}