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
trigger TDTM_AffiliationTemplate on AffiliationTemplate__c (after delete, after insert, after undelete, after update, before delete,
                                  before insert, before update) {
    
    npsp.TDTM_Runnable.Action action;
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) action = npsp.TDTM_Runnable.Action.BeforeInsert;
        else if (Trigger.isUpdate) action = npsp.TDTM_Runnable.Action.BeforeUpdate;
        else if (Trigger.isDelete) action = npsp.TDTM_Runnable.Action.BeforeDelete;
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) action = npsp.TDTM_Runnable.Action.AfterInsert;
        else if (Trigger.isUpdate) action = npsp.TDTM_Runnable.Action.AfterUpdate;
        else if (Trigger.isDelete) action = npsp.TDTM_Runnable.Action.AfterDelete;
        else if (Trigger.isUndelete) action = npsp.TDTM_Runnable.Action.AfterUndelete;
    }
    
    // We have to manually check here because TDTM isn't global in NPSP like it is in HEDA
    if (action == npsp.TDTM_Runnable.Action.AfterInsert || action == npsp.TDTM_Runnable.Action.AfterUpdate || action == npsp.TDTM_Runnable.Action.AfterDelete) {
        AFFLTMP_Template_TDTM cls = new AFFLTMP_Template_TDTM();
        cls.run((List<SObject>)Trigger.new, (List<SObject>)Trigger.old, action, Schema.Sobjecttype.AffiliationTemplate__c);
    }
}
