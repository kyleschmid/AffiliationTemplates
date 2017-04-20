# Affiliation Templates

<a href="https://github.com/SalesforceFoundation/HEDAP" >Higher-Ed Data Architecture (HEDA)</a> and <a href="https://github.com/SalesforceFoundation/Cumulus" >Non-Profit Success Pack (NPSP)</a> Affiliation Templates for Salesforce

## Description

When we started our Salesforce implementation at the McCombs School of Business (University of Texas at Austin), we found that Contact record sharing amongst various departments around the college was an interesting problem that needed solving. We needed to share and un-share Contact records as our students progressed through the student lifecycle. When the Salesforce Foundation released the Higher-Ed Data Architecture (HEDA), we determined that a security solution based on the Affiliations object would be ideal. We then built a <a href="https://github.com/utmccombs/AffiliationSecurity" >solution</a> that allows admins to define an Affiliation "template" and share a Contact record with a group of users if the Contact had an Affiliation that fit said template.

This repository contains a modified version of the <a href="https://github.com/utmccombs/AffiliationSecurity" >original solution</a> that is less security-focused. Most of the basic functionality is the same, but some of the wording has changed. Additionally, this solution allows checkbox fields to be specified on both the Contact and the Contact's related Account. It also works with Salesforce.org's <a href="https://github.com/SalesforceFoundation/Cumulus" >Non-Profit Success Pack (NPSP)</a> in addition to the <a href="https://github.com/SalesforceFoundation/HEDAP" >Higher-Ed Data Architecture (HEDA)</a>.

## Requirements

* Installation of the <a href="https://github.com/SalesforceFoundation/HEDAP" >Higher-Ed Data Architecture (HEDA)</a> version 1.20 or later (managed or open-source)
<br />-or-
* Installation of the <a href="https://github.com/SalesforceFoundation/Cumulus" >Non-Profit Success Pack (NPSP)</a>

## Installation

Affiliation Templates is released under the open source BSD license. Contributions (code and otherwise) are welcome and encouraged. You can fork this repository and deploy the unmanaged version of the code into a Salesforce org of your choice.

* Fork the repository by clicking on the "Fork" button in the upper-righthand corner. This creates your own copy of Affiliation Templates for your Github user.
* Clone your fork to your local machine via the command line
```sh
$ git clone https://github.com/YOUR-USERNAME/AffiliationTemplates.git
```
* You now have a local copy on your machine. Affiliation Templates has some built-in scripts to make deploying to your Salesforce org easier. Utilizing ant and the Force.com Migration tool, you can push your local copy of Affiliation Templates to the org of your choice. You'll need to provide a build.properties to tell ant where to deploy. An example file might look like:

```
sf.username = YOUR_ORG_USERNAME
sf.password = YOUR_ORG_PASSWORD
sf.serverurl = https://login.salesforce.com ##or test.salesforce.com for sandbox environments
sf.maxPoll = 20
```

* Now deploy to your org utilizing ant

Open-source installation of HEDA:
```sh
$ cd AffiliationTemplates
$ ant deployHEDAUnmanaged
```

Managed package installation of HEDA:
```sh
$ cd AffiliationTemplates
$ ant deployHEDAManaged
```

NPSP:
```sh
$ cd AffiliationTemplates
$ ant deployNPSP
```

* If you get a test failure with the message "UNABLE_TO_LOCK_ROW", go to Setup>Develop>Apex Test Execution>Options and check the "Disable Parallel Apex Testing" checkbox.
* You'll need to give the System Administrator profile access to the fields on the newly-created Affiliation Template object as well as the Affiliation Templates tab.
* Go to the Developer Console and run the following in an Execute Anonymous window:

```
UTIL_AffiliationTemplate.CreateTriggerHandlers();
```

## Using Affiliation Templates

Once installed, you'll want to set up your first Affiliation Template. To do so, follow these instructions:

1. Create a checkbox field on the Account or Contact object
2. Navigate to the Affiliation Templates tab and create a new template
  * This template will define the "model" for the type of Affiliation that needs to exist to check the checkbox
  * Object is either "Contact" (Contact record related to an Affiliation) or "Related Account" (Account record related to the Contact record)
  * Field Name is the API name of the field you created in step 1

That's it! Now the checkbox you specified on any Contact or Related Account with an Affiliation matching the template you defined will be checked. This has a variety of uses:

* Security (See the README <a href="https://github.com/utmccombs/AffiliationSecurity" >here</a>)
* Aggregation (ex. All contacts with an Affiliation to a sports team should have the Student Athlete checkbox checked)
* List Views (ex. All Student Athletes)
* Reports (ex. All Student Athletes with a 3.0 or greater GPA)
* Dashboards (ex. Chart all Student Athletes’ GPAs)
* Workflows (ex. Update an “At-Risk” field when a Student Athlete falls below a 2.5 GPA)
* Process Flows (ex. Create a Case when a Student Athlete falls below a 2.5 GPA)
