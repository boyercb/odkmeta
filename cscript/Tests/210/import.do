* Created on October 22, 2015 at 22:08:54 by the following -odkmeta- command:
* odkmeta using import,         csv(odkmetatest210) survey(survey) choices(choices) replace         shortnames
* -odkmeta- version 1.1.0 was used.

version 9

* Change these values as required by your data.

* The mask of date values in the .csv files. See -help date()-.
* Fields of type date or today have these values.
local datemask MDY
* The mask of time values in the .csv files. See -help clock()-.
* Fields of type time have these values.
local timemask hms
* The mask of datetime values in the .csv files. See -help clock()-.
* Fields of type datetime, start, or end have these values.
local datetimemask MDYhms


/* -------------------------------------------------------------------------- */

* Start the import.
* Be cautious about modifying what follows.

local varabbrev = c(varabbrev)
set varabbrev off

* Find unused Mata names.
foreach var in values text {
	mata: st_local("external", invtokens(direxternal("*")'))
	tempname `var'
	while `:list `var' in external' {
		tempname `var'
	}
}

label drop _all

#delimit ;
* yesno;
label define yesno
	1 Yes
	0 No
;
* yesnodkr;
label define yesnodkr
	1    Yes
	0    No
	-999 "Don't know"
	-888 "Refused to answer"
;
* yesnoFeedback;
label define yesnoFeedback
	1    Constituents
	2    "Party leadership"
	3    "Constituents and party leadership"
	0    Neither
	-999 "Don't know"
	-888 "Refused to answer"
;
* feedback2;
label define feedback2
	1    `"1 "Meet the People" sessions"'
	2    "2 Written statement"
	3    "3 Public statement to constituents"
	4    "4 Email/social networking"
	5    "5 Speaking out in an official session of the CDF committee or in Parliament"
	6    "6 Speaking out at an official party meeting/function"
	-999 "Don't know"
	-888 "Refused to answer"
;
* support;
label define support
	0    "The policy supported by constituents"
	1    "The policy supported by traditional leaders/chiefs"
	-999 "Don't know"
	-888 "Refused to answer"
;
* support1;
label define support1
	1    "The policy supported by traditional leaders/chiefs"
	2    "The policy supported by party leadership"
	-999 "Don't know"
	-888 "Refused to answer"
;
* support2;
label define support2
	2    "The policy supported by party leadership"
	0    "The policy supported by constituents"
	-999 "Don't know"
	-888 "Refused to answer"
;
* outreach;
label define outreach
	1    "In person meetings"
	2    "By phone"
	3    "By email"
	4    "Social networking site"
	5    "Television, radio, poster"
	-999 "Don't know"
	-888 "Refused to answer"
;
* meetingwithleadership;
label define meetingwithleadership
	1    "More than once per month"
	2    "Once per month"
	3    "5-10 times per year"
	4    "2-4 times per year"
	5    "Once per year"
	6    "Less than once per year"
	0    Never
	-999 "Don't know"
	-888 "Refused to answer"
;
* hansard;
label define hansard
	0    "Very important"
	1    Important
	2    "Somewhat important"
	3    Unimportant
	-999 "Don't know"
	-888 "Refused to answer"
;
* needs;
label define needs
	1    "1 Water Supply and Sanitation"
	2    "2 Roads, Bridges and Canals"
	3    "3 Agricultural Projects (including Irrigation)"
	4    "4 Markets and Bus Shelters"
	5    "5 Education"
	6    "6 Health"
	7    "7 Sports and Recreation"
	8    "8 Other Income Generating Activities"
	9    "9 Electricity and Energy"
	10   "10 Other"
	-999 "Don't know"
	-888 "Refused to answer"
;
* impgaps;
label define impgaps
	1    "1 CDF release by Ministry of Finance was delayed"
	2    "2 Inadequate CDF allocation to recipient for the scope of their project"
	3    "3 Contractor did not abide by terms of contract"
	4    "4 Red tape / bureaucracy in procurement procedures"
	5    "5 CDF funds were misappropriated for other purposes by recipient group"
	6    "6 Disagreement among stakeholders on how CDF should be used after disbursement"
	7    "7 Natural causes or disasters "
	-999 "Don't know"
	-888 "Refused to answer"
;
* mpactions;
label define mpactions
	1    "1 Voting on well-reasoned and researched policies and laws"
	2    "2 Voting on policies and laws that are supported by a majority of Zambians"
	3    "3 Voting on policies and laws that traditional leaders in your constituency support"
	4    "4 Voting on policies and laws that ordinary citizens in your constituency support"
	5    "5 Voting on policies and laws that your party leadership supports"
	6    "6 Contributing actively in Parliament through debate and proposing bills"
	7    "7 Speaking with constituents to better understand their needs"
	8    "8 Bringing assistance and public services to the constituency"
	9    "9 Providing personal assistance to members of the constituency acutely in need, such as money for school fees or funeral costs"
	10   "10 Other"
	-999 "Don't know"
	-888 "Refused to answer"
;
* mpverify;
label define mpverify
	1 "Last name"
	2 "First name"
	3 Constituency
	4 Party
;
* enumerator;
label define enumerator
	1  "Lucy Pemba"
	2  "Ireen Sinyangwe Kapisa"
	3  "Mambwe Kaoma"
	4  "Irene Njobvu"
	5  "Ngoma Edward"
	6  "Conceptor Chilopa"
	7  "Kate Naluyele"
	8  "Mukupa Justin Bwalya"
	9  "Jackson Mwewa"
	10 "Muyamwa Matauka"
	11 "Musa Mtonga"
;
* assistance;
label define assistance
	1 Cash
	2 "Clothing / apparel"
	3 Bicycles
	4 Vehicles
;
* correctedparty;
label define correctedparty
	1 PF
	2 MMD
	3 UPND
	4 FDD
	5 "IND(Independent)"
;
#delimit cr

* Add "other" values to value labels that need them.
local otherlabs feedback2 impgaps mpactions assistance outreach
foreach lab of local otherlabs {
	mata: st_vlload("`lab'", `values' = ., `text' = "")
	mata: st_local("otherval", strofreal(max(`values') + 1, "%24.0g"))
	local othervals `othervals' `otherval'
	label define `lab' `otherval' other, add
}

* Save label information.
label dir
local labs `r(names)'
foreach lab of local labs {
	quietly label list `lab'
	* "nassoc" for "number of associations"
	local nassoc `nassoc' `r(k)'
}

* Import ODK attributes as characteristics.
* - constraint message will be imported to the characteristic Odk_constraint_message.
* - required message will be imported to the characteristic Odk_required_message.
* - media:image will be imported to the characteristic Odk_media_image.

insheet using odkmetatest210.csv, comma nonames clear
local fields
foreach var of varlist _all {
	local field = trim(`var'[1])
	assert `:list sizeof field' == 1
	assert !`:list field in fields'
	local fields : list fields | field
}

insheet using odkmetatest210.csv, comma names case clear
unab all : _all

* starttime
char starttime[Odk_name] starttime
char starttime[Odk_bad_name] 0
char starttime[Odk_long_name] starttime
char starttime[Odk_type] start
char starttime[Odk_or_other] 0
char starttime[Odk_is_other] 0

* endtime
char endtime[Odk_name] endtime
char endtime[Odk_bad_name] 0
char endtime[Odk_long_name] endtime
char endtime[Odk_type] end
char endtime[Odk_or_other] 0
char endtime[Odk_is_other] 0

* deviceid
char deviceid[Odk_name] deviceid
char deviceid[Odk_bad_name] 0
char deviceid[Odk_long_name] deviceid
char deviceid[Odk_type] deviceid
char deviceid[Odk_or_other] 0
char deviceid[Odk_is_other] 0

* subscriberid
char subscriberid[Odk_name] subscriberid
char subscriberid[Odk_bad_name] 0
char subscriberid[Odk_long_name] subscriberid
char subscriberid[Odk_type] subscriberid
char subscriberid[Odk_or_other] 0
char subscriberid[Odk_is_other] 0

* simid
char simid[Odk_name] simid
char simid[Odk_bad_name] 0
char simid[Odk_long_name] simid
char simid[Odk_type] simserial
char simid[Odk_or_other] 0
char simid[Odk_is_other] 0

* devicephonenum
char devicephonenum[Odk_name] devicephonenum
char devicephonenum[Odk_bad_name] 0
char devicephonenum[Odk_long_name] devicephonenum
char devicephonenum[Odk_type] phonenumber
char devicephonenum[Odk_or_other] 0
char devicephonenum[Odk_is_other] 0

* timestamps
char timestamps[Odk_name] timestamps
char timestamps[Odk_bad_name] 0
char timestamps[Odk_long_name] timestamps
char timestamps[Odk_type] text audit
char timestamps[Odk_or_other] 0
char timestamps[Odk_is_other] 0
char timestamps[Odk_appearance] p=100

* image_test
char image_test[Odk_name] image_test
char image_test[Odk_bad_name] 0
char image_test[Odk_long_name] image_test
char image_test[Odk_type] note
char image_test[Odk_or_other] 0
char image_test[Odk_is_other] 0
char image_test[Odk_label] testing
char image_test[Odk_relevance] \${enum_confirm}=0

* enum_confirm
char enum_confirm[Odk_name] enum_confirm
char enum_confirm[Odk_bad_name] 0
char enum_confirm[Odk_long_name] enum_confirm
char enum_confirm[Odk_type] select_one yesno
char enum_confirm[Odk_list_name] yesno
char enum_confirm[Odk_or_other] 0
char enum_confirm[Odk_is_other] 0
char enum_confirm[Odk_label] You have selected enumerator ID \${enumerator}. Is this correct?
char enum_confirm[Odk_required] yes
char enum_confirm[Odk_required_message] This is a required field.

* enum_correct
char enum_correct[Odk_name] enum_correct
char enum_correct[Odk_bad_name] 0
char enum_correct[Odk_long_name] enum_correct
char enum_correct[Odk_type] note
char enum_correct[Odk_or_other] 0
char enum_correct[Odk_is_other] 0
char enum_correct[Odk_label] Please go back and select the correct name.
char enum_correct[Odk_relevance] \${enum_confirm}=0

* mpid
char mpid[Odk_name] mpid
char mpid[Odk_bad_name] 0
char mpid[Odk_long_name] mpid
char mpid[Odk_type] integer
char mpid[Odk_or_other] 0
char mpid[Odk_is_other] 0
char mpid[Odk_label] DO NOT READ: Please enter the ID for the MP you are interviewing.
char mpid[Odk_hint] ENUMERATOR: The ID is between 1 and 170
char mpid[Odk_appearance] minimal
char mpid[Odk_constraint] .>=1 and .<=170
char mpid[Odk_constraint_message] This is not a valid id!
char mpid[Odk_required] yes
char mpid[Odk_required_message] This is a required field. If the MP does not have an ID, please enter 170 and enter his/her details in the verification pages.

* verifymp
char verifymp[Odk_name] verifymp
char verifymp[Odk_bad_name] 0
char verifymp[Odk_long_name] verifymp
char verifymp[Odk_type] select_one yesno
char verifymp[Odk_list_name] yesno
char verifymp[Odk_or_other] 0
char verifymp[Odk_is_other] 0
char verifymp[Odk_label] DO NOT READ: You have selected details for the following. Is this the correct MP? Last Name: \${lastname}  First Name: \${firstname} Constituency: \${constituency} Party: \${party}                                                                                                                                                     Image: {image}
char verifymp[Odk_required] yes
char verifymp[Odk_media_image] \${image}

* correctmpid
char correctmpid[Odk_name] correctmpid
char correctmpid[Odk_bad_name] 0
char correctmpid[Odk_long_name] correctmpid
char correctmpid[Odk_type] note
char correctmpid[Odk_or_other] 0
char correctmpid[Odk_is_other] 0
char correctmpid[Odk_label] DO NOT READ: Please go back and enter the correct ID.
char correctmpid[Odk_relevance] \${verifymp}=0

* consent
char consent[Odk_name] consent
char consent[Odk_bad_name] 0
char consent[Odk_long_name] consent
char consent[Odk_type] select_one yesno
char consent[Odk_list_name] yesno
char consent[Odk_or_other] 0
char consent[Odk_is_other] 0
char consent[Odk_label] Do I have your consent to conduct the interview?
char consent[Odk_hint] ENUMERATOR: If the answer is no discontinue the interview
char consent[Odk_required] yes

* Discontinue
char Discontinue[Odk_name] Discontinue
char Discontinue[Odk_bad_name] 0
char Discontinue[Odk_long_name] Discontinue
char Discontinue[Odk_type] note
char Discontinue[Odk_or_other] 0
char Discontinue[Odk_is_other] 0
char Discontinue[Odk_label] Thank you for your response.
char Discontinue[Odk_relevance] \${consent}=0

* noconsent
char noconsent[Odk_name] noconsent
char noconsent[Odk_bad_name] 0
char noconsent[Odk_long_name] noconsent
char noconsent[Odk_type] text
char noconsent[Odk_or_other] 0
char noconsent[Odk_is_other] 0
char noconsent[Odk_label] DO NOT READ: Please explain in detail why the MP refused to consent to participate in the survey.
char noconsent[Odk_relevance] \${consent}=0
char noconsent[Odk_required] yes

* begin group condentgroup

* verifyln
char condentgroupverifyln[Odk_name] verifyln
char condentgroupverifyln[Odk_bad_name] 0
char condentgroupverifyln[Odk_group] condentgroup
char condentgroupverifyln[Odk_long_name] condentgroup-verifyln
char condentgroupverifyln[Odk_type] select_one yesno
char condentgroupverifyln[Odk_list_name] yesno
char condentgroupverifyln[Odk_or_other] 0
char condentgroupverifyln[Odk_is_other] 0
char condentgroupverifyln[Odk_label] The last name I have on record for you is \${lastname}. Would you like to make any corrections?
char condentgroupverifyln[Odk_required] yes

* correctln
char condentgroupcorrectln[Odk_name] correctln
char condentgroupcorrectln[Odk_bad_name] 0
char condentgroupcorrectln[Odk_group] condentgroup
char condentgroupcorrectln[Odk_long_name] condentgroup-correctln
char condentgroupcorrectln[Odk_type] text
char condentgroupcorrectln[Odk_or_other] 0
char condentgroupcorrectln[Odk_is_other] 0
char condentgroupcorrectln[Odk_label] Please enter the corrected last name.
char condentgroupcorrectln[Odk_relevance] \${verifyln}=1
char condentgroupcorrectln[Odk_required] yes

* verifyfn
char condentgroupverifyfn[Odk_name] verifyfn
char condentgroupverifyfn[Odk_bad_name] 0
char condentgroupverifyfn[Odk_group] condentgroup
char condentgroupverifyfn[Odk_long_name] condentgroup-verifyfn
char condentgroupverifyfn[Odk_type] select_one yesno
char condentgroupverifyfn[Odk_list_name] yesno
char condentgroupverifyfn[Odk_or_other] 0
char condentgroupverifyfn[Odk_is_other] 0
char condentgroupverifyfn[Odk_label] The first name I have on record for you is \${firstname}. Would you like to make any corrections?
char condentgroupverifyfn[Odk_required] yes

* correctfn
char condentgroupcorrectfn[Odk_name] correctfn
char condentgroupcorrectfn[Odk_bad_name] 0
char condentgroupcorrectfn[Odk_group] condentgroup
char condentgroupcorrectfn[Odk_long_name] condentgroup-correctfn
char condentgroupcorrectfn[Odk_type] text
char condentgroupcorrectfn[Odk_or_other] 0
char condentgroupcorrectfn[Odk_is_other] 0
char condentgroupcorrectfn[Odk_label] Please enter the corrected first name.
char condentgroupcorrectfn[Odk_relevance] \${verifyfn}=1
char condentgroupcorrectfn[Odk_required] yes

* verifycons
char condentgroupverifycons[Odk_name] verifycons
char condentgroupverifycons[Odk_bad_name] 0
char condentgroupverifycons[Odk_group] condentgroup
char condentgroupverifycons[Odk_long_name] condentgroup-verifycons
char condentgroupverifycons[Odk_type] select_one yesno
char condentgroupverifycons[Odk_list_name] yesno
char condentgroupverifycons[Odk_or_other] 0
char condentgroupverifycons[Odk_is_other] 0
char condentgroupverifycons[Odk_label] The constituency I have on record for you is \${constituency}. Would you like to make any corrections?
char condentgroupverifycons[Odk_required] yes

* correctcons
char condentgroupcorrectcons[Odk_name] correctcons
char condentgroupcorrectcons[Odk_bad_name] 0
char condentgroupcorrectcons[Odk_group] condentgroup
char condentgroupcorrectcons[Odk_long_name] condentgroup-correctcons
char condentgroupcorrectcons[Odk_type] text
char condentgroupcorrectcons[Odk_or_other] 0
char condentgroupcorrectcons[Odk_is_other] 0
char condentgroupcorrectcons[Odk_label] Please enter the corrected constituency.
char condentgroupcorrectcons[Odk_relevance] \${verifycons}=1
char condentgroupcorrectcons[Odk_required] yes

* verifyparty
char condentgroupverifyparty[Odk_name] verifyparty
char condentgroupverifyparty[Odk_bad_name] 0
char condentgroupverifyparty[Odk_group] condentgroup
char condentgroupverifyparty[Odk_long_name] condentgroup-verifyparty
char condentgroupverifyparty[Odk_type] select_one yesno
char condentgroupverifyparty[Odk_list_name] yesno
char condentgroupverifyparty[Odk_or_other] 0
char condentgroupverifyparty[Odk_is_other] 0
char condentgroupverifyparty[Odk_label] The party I have on record for you is \${party}. Would you like to make any corrections?
char condentgroupverifyparty[Odk_required] yes

* correctparty
char condentgroupcorrectparty[Odk_name] correctparty
char condentgroupcorrectparty[Odk_bad_name] 0
char condentgroupcorrectparty[Odk_group] condentgroup
char condentgroupcorrectparty[Odk_long_name] condentgroup-correctparty
char condentgroupcorrectparty[Odk_type] select_one correctedparty
char condentgroupcorrectparty[Odk_list_name] correctedparty
char condentgroupcorrectparty[Odk_or_other] 0
char condentgroupcorrectparty[Odk_is_other] 0
char condentgroupcorrectparty[Odk_label] Please enter the corrected party.
char condentgroupcorrectparty[Odk_relevance] \${verifyparty}=1
char condentgroupcorrectparty[Odk_required] yes

* primarycontact
char condentgroupprimarycontact[Odk_name] primarycontact
char condentgroupprimarycontact[Odk_bad_name] 0
char condentgroupprimarycontact[Odk_group] condentgroup
char condentgroupprimarycontact[Odk_long_name] condentgroup-primarycontact
char condentgroupprimarycontact[Odk_type] text
char condentgroupprimarycontact[Odk_or_other] 0
char condentgroupprimarycontact[Odk_is_other] 0
char condentgroupprimarycontact[Odk_label] Please provide the best phone number to reach you.
char condentgroupprimarycontact[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupprimarycontact[Odk_appearance] numbers
char condentgroupprimarycontact[Odk_constraint] string-length(.) <= 10
char condentgroupprimarycontact[Odk_constraint_message] Phone number should not exceed 10 digits
char condentgroupprimarycontact[Odk_required] yes

* secondcontact
char condentgroupsecondcontact[Odk_name] secondcontact
char condentgroupsecondcontact[Odk_bad_name] 0
char condentgroupsecondcontact[Odk_group] condentgroup
char condentgroupsecondcontact[Odk_long_name] condentgroup-secondcontact
char condentgroupsecondcontact[Odk_type] text
char condentgroupsecondcontact[Odk_or_other] 0
char condentgroupsecondcontact[Odk_is_other] 0
char condentgroupsecondcontact[Odk_label] Please provide an alternative phone number to reach you.
char condentgroupsecondcontact[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupsecondcontact[Odk_appearance] numbers
char condentgroupsecondcontact[Odk_constraint] string-length(.) <= 10
char condentgroupsecondcontact[Odk_constraint_message] Phone number should not exceed 10 digits
char condentgroupsecondcontact[Odk_required] yes

* intronote
char condentgroupintronote[Odk_name] intronote
char condentgroupintronote[Odk_bad_name] 0
char condentgroupintronote[Odk_group] condentgroup
char condentgroupintronote[Odk_long_name] condentgroup-intronote
char condentgroupintronote[Odk_type] note
char condentgroupintronote[Odk_or_other] 0
char condentgroupintronote[Odk_is_other] 0
char condentgroupintronote[Odk_label] [Read] Thank you for taking the time to participate in this survey. The purpose of this study is to understand MP views on accountability and explore the relationship between these views and other characteristics, such as beliefs, priorities, and party relations.  The survey should take approximately one hour, and will proceed through 4 modules: (1st) development needs and your constituency development fund, (2nd) MP roles and responsibilities, (3rd) MP party relations, and (4th) accountability measures. I would like to reiterate here that all your responses will be kept absolutely confidential, and that any results that are presented will be anonymised, as was mentioned in the consent form. If over the course of the interview there are any questions that you are not comfortable with, please do not hesitate to stop me for clarifications. Shall we begin?

* intronoteToFirstModule
char condentgroupintronoteToFirstModu[Odk_name] intronoteToFirstModule
char condentgroupintronoteToFirstModu[Odk_bad_name] 0
char condentgroupintronoteToFirstModu[Odk_group] condentgroup
char condentgroupintronoteToFirstModu[Odk_long_name] condentgroup-intronoteToFirstModule
char condentgroupintronoteToFirstModu[Odk_type] note
char condentgroupintronoteToFirstModu[Odk_or_other] 0
char condentgroupintronoteToFirstModu[Odk_is_other] 0
char condentgroupintronoteToFirstModu[Odk_label] Module 1: Development Needs and the CDF - [Read] This first section will concentrate on the Constituency Development Fund. I will be recording all your answers on a secure tablet. Unless otherwise specified, all questions in this survey refer to the time period 1 April 2015 to 17 September 2015. To help you reflect on this time period, I am providing a calendar for easy reference.

* begin group mostpressingneeds

* mostpressingneedsr1
char condentgroupmostpressingneedsmos[Odk_name] mostpressingneedsr1
char condentgroupmostpressingneedsmos[Odk_bad_name] 0
char condentgroupmostpressingneedsmos[Odk_group] condentgroup mostpressingneeds
char condentgroupmostpressingneedsmos[Odk_long_name] condentgroup-mostpressingneeds-mostpressingneedsr1
char condentgroupmostpressingneedsmos[Odk_type] select_one needs
char condentgroupmostpressingneedsmos[Odk_list_name] needs
char condentgroupmostpressingneedsmos[Odk_or_other] 0
char condentgroupmostpressingneedsmos[Odk_is_other] 0
char condentgroupmostpressingneedsmos[Odk_label] Rank 1 Need
char condentgroupmostpressingneedsmos[Odk_appearance] minimal
char condentgroupmostpressingneedsmos[Odk_required] yes

* mostpressingneedsr2
* Duplicate variable name with condentgroup-mostpressingneeds-mostpressingneedsr1
local pos : list posof "condentgroup-mostpressingneeds-mostpressingneedsr2" in fields
local var : word `pos' of `all'
char `var'[Odk_name] mostpressingneedsr2
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup mostpressingneeds
char `var'[Odk_long_name] condentgroup-mostpressingneeds-mostpressingneedsr2
char `var'[Odk_type] select_one needs
char `var'[Odk_list_name] needs
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] Rank 2 Need
char `var'[Odk_appearance] minimal
char `var'[Odk_constraint] .!=\${mostpressingneedsr1}
char `var'[Odk_constraint_message] You must choose a different response for each field!

* mostpressingneedsr3
* Duplicate variable name with condentgroup-mostpressingneeds-mostpressingneedsr1
local pos : list posof "condentgroup-mostpressingneeds-mostpressingneedsr3" in fields
local var : word `pos' of `all'
char `var'[Odk_name] mostpressingneedsr3
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup mostpressingneeds
char `var'[Odk_long_name] condentgroup-mostpressingneeds-mostpressingneedsr3
char `var'[Odk_type] select_one needs
char `var'[Odk_list_name] needs
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] Rank 3 Need
char `var'[Odk_appearance] minimal
char `var'[Odk_constraint] .!=\${mostpressingneedsr1} and .!=\${mostpressingneedsr2}
char `var'[Odk_constraint_message] You must choose a different response for each field!

* end group mostpressingneeds

* mostpressingneedsr_other
char condentgroupmostpressingneedsr_o[Odk_name] mostpressingneedsr_other
char condentgroupmostpressingneedsr_o[Odk_bad_name] 0
char condentgroupmostpressingneedsr_o[Odk_group] condentgroup
char condentgroupmostpressingneedsr_o[Odk_long_name] condentgroup-mostpressingneedsr_other
char condentgroupmostpressingneedsr_o[Odk_type] text
char condentgroupmostpressingneedsr_o[Odk_or_other] 0
char condentgroupmostpressingneedsr_o[Odk_is_other] 0
char condentgroupmostpressingneedsr_o[Odk_label] Specify Other
char condentgroupmostpressingneedsr_o[Odk_relevance] \${mostpressingneedsr1}=10 or \${mostpressingneedsr2}=10 or \${mostpressingneedsr3}=10

* cdfallocationmeetings
char condentgroupcdfallocationmeeting[Odk_name] cdfallocationmeetings
char condentgroupcdfallocationmeeting[Odk_bad_name] 0
char condentgroupcdfallocationmeeting[Odk_group] condentgroup
char condentgroupcdfallocationmeeting[Odk_long_name] condentgroup-cdfallocationmeetings
char condentgroupcdfallocationmeeting[Odk_type] integer
char condentgroupcdfallocationmeeting[Odk_or_other] 0
char condentgroupcdfallocationmeeting[Odk_is_other] 0
char condentgroupcdfallocationmeeting[Odk_label] 2) How many times did you meet with your constituency’s CDF Committee to discuss CDF allocations?
char condentgroupcdfallocationmeeting[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupcdfallocationmeeting[Odk_required] yes

* newcdfallocations
char condentgroupnewcdfallocations[Odk_name] newcdfallocations
char condentgroupnewcdfallocations[Odk_bad_name] 0
char condentgroupnewcdfallocations[Odk_group] condentgroup
char condentgroupnewcdfallocations[Odk_long_name] condentgroup-newcdfallocations
char condentgroupnewcdfallocations[Odk_type] select_one yesnodkr
char condentgroupnewcdfallocations[Odk_list_name] yesnodkr
char condentgroupnewcdfallocations[Odk_or_other] 0
char condentgroupnewcdfallocations[Odk_is_other] 0
char condentgroupnewcdfallocations[Odk_label] 3) Did your constituency’s CDF Committee make any new CDF allocations?
char condentgroupnewcdfallocations[Odk_required] yes

* ynmostpressing
char condentgroupynmostpressing[Odk_name] ynmostpressing
char condentgroupynmostpressing[Odk_bad_name] 0
char condentgroupynmostpressing[Odk_group] condentgroup
char condentgroupynmostpressing[Odk_long_name] condentgroup-ynmostpressing
char condentgroupynmostpressing[Odk_type] select_one yesnodkr
char condentgroupynmostpressing[Odk_list_name] yesnodkr
char condentgroupynmostpressing[Odk_or_other] 0
char condentgroupynmostpressing[Odk_is_other] 0
char condentgroupynmostpressing[Odk_label] 4) In your opinion, were CDF allocations made according to the most pressing developmental needs for your constituency in the period under review?
char condentgroupynmostpressing[Odk_relevance] \${newcdfallocations}=1
char condentgroupynmostpressing[Odk_required] yes

* begin group ifnewcdfallocations
* begin group ifnotmostpressing

* whymisallocation
char condentgroupifnewcdfallocationsi[Odk_name] whymisallocation
char condentgroupifnewcdfallocationsi[Odk_bad_name] 0
char condentgroupifnewcdfallocationsi[Odk_group] condentgroup ifnewcdfallocations ifnotmostpressing
char condentgroupifnewcdfallocationsi[Odk_long_name] condentgroup-ifnewcdfallocations-ifnotmostpressing-whymisallocation
char condentgroupifnewcdfallocationsi[Odk_type] text
char condentgroupifnewcdfallocationsi[Odk_or_other] 0
char condentgroupifnewcdfallocationsi[Odk_is_other] 0
char condentgroupifnewcdfallocationsi[Odk_label] 5) In your opinion, what caused the potential MISALIGNMENT between allocations and developmental needs? So I can properly record your answer, please tell me in 1-3 short sentences.
char condentgroupifnewcdfallocationsi[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupifnewcdfallocationsi[Odk_relevance] \${ynmostpressing}=0
char condentgroupifnewcdfallocationsi[Odk_required] yes

* giveFeedback
* Duplicate variable name with condentgroup-ifnewcdfallocations-ifnotmostpressing-whymisallocation
local pos : list posof "condentgroup-ifnewcdfallocations-ifnotmostpressing-giveFeedback" in fields
local var : word `pos' of `all'
char `var'[Odk_name] giveFeedback
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup ifnewcdfallocations ifnotmostpressing
char `var'[Odk_long_name] condentgroup-ifnewcdfallocations-ifnotmostpressing-giveFeedback
char `var'[Odk_type] select_one yesnoFeedback
char `var'[Odk_list_name] yesnoFeedback
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] 6) In the case of a misalignment, did you provide any FEEDBACK to constituents and/or party leadership on allocation disparities? PROMPT:
char `var'[Odk_required] yes

* feedback
foreach suffix in "" _other {
	* condentgroup-ifnewcdfallocations-ifnotmostpressing-feedback: duplicate variable name with condentgroup-ifnewcdfallocations-ifnotmostpressing-whymisallocation.
	local pos : list posof "condentgroup-ifnewcdfallocations-ifnotmostpressing-feedback`suffix'" in fields
	local var : word `pos' of `all'
	local isbadname = "`var'" != substr("condentgroupifnewcdfallocationsi`suffix'", 1, 32)
	char `var'[Odk_name] feedback
	char `var'[Odk_bad_name] `isbadname'
	char `var'[Odk_group] condentgroup ifnewcdfallocations ifnotmostpressing
	char `var'[Odk_long_name] condentgroup-ifnewcdfallocations-ifnotmostpressing-feedback
	char `var'[Odk_type] select_multiple feedback2 or_other
	char `var'[Odk_list_name] feedback2
	char `var'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char `var'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char `var'[Odk_label] 7) What form did this feedback take? PROMPT:`labend'
	char `var'[Odk_hint] ENUMERATOR: Select all that apply.
	char `var'[Odk_relevance] \${giveFeedback}>0
	char `var'[Odk_required] yes
}

* end group ifnotmostpressing
* end group ifnewcdfallocations

* begin group cdpriorities

* cdprioritiesr1
char condentgroupcdprioritiescdpriori[Odk_name] cdprioritiesr1
char condentgroupcdprioritiescdpriori[Odk_bad_name] 0
char condentgroupcdprioritiescdpriori[Odk_group] condentgroup cdpriorities
char condentgroupcdprioritiescdpriori[Odk_long_name] condentgroup-cdpriorities-cdprioritiesr1
char condentgroupcdprioritiescdpriori[Odk_type] select_one needs
char condentgroupcdprioritiescdpriori[Odk_list_name] needs
char condentgroupcdprioritiescdpriori[Odk_or_other] 0
char condentgroupcdprioritiescdpriori[Odk_is_other] 0
char condentgroupcdprioritiescdpriori[Odk_label] Rank 1 Priority
char condentgroupcdprioritiescdpriori[Odk_appearance] minimal
char condentgroupcdprioritiescdpriori[Odk_required] yes

* cdprioritiesr2
* Duplicate variable name with condentgroup-cdpriorities-cdprioritiesr1
local pos : list posof "condentgroup-cdpriorities-cdprioritiesr2" in fields
local var : word `pos' of `all'
char `var'[Odk_name] cdprioritiesr2
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup cdpriorities
char `var'[Odk_long_name] condentgroup-cdpriorities-cdprioritiesr2
char `var'[Odk_type] select_one needs
char `var'[Odk_list_name] needs
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] Rank 2 Priority
char `var'[Odk_appearance] minimal
char `var'[Odk_constraint] .!=\${cdprioritiesr1}
char `var'[Odk_constraint_message] You must choose a different response for each field!

* cdprioritiesr3
* Duplicate variable name with condentgroup-cdpriorities-cdprioritiesr1
local pos : list posof "condentgroup-cdpriorities-cdprioritiesr3" in fields
local var : word `pos' of `all'
char `var'[Odk_name] cdprioritiesr3
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup cdpriorities
char `var'[Odk_long_name] condentgroup-cdpriorities-cdprioritiesr3
char `var'[Odk_type] select_one needs
char `var'[Odk_list_name] needs
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] Rank 3 Priority
char `var'[Odk_appearance] minimal
char `var'[Odk_constraint] .!=\${cdprioritiesr1} and .!=\${cdprioritiesr2}
char `var'[Odk_constraint_message] You must choose a different response for each field!

* end group cdpriorities

* cdprioritiesr_other
char condentgroupcdprioritiesr_other[Odk_name] cdprioritiesr_other
char condentgroupcdprioritiesr_other[Odk_bad_name] 0
char condentgroupcdprioritiesr_other[Odk_group] condentgroup
char condentgroupcdprioritiesr_other[Odk_long_name] condentgroup-cdprioritiesr_other
char condentgroupcdprioritiesr_other[Odk_type] text
char condentgroupcdprioritiesr_other[Odk_or_other] 0
char condentgroupcdprioritiesr_other[Odk_is_other] 0
char condentgroupcdprioritiesr_other[Odk_label] Specify Other
char condentgroupcdprioritiesr_other[Odk_relevance] \${cdprioritiesr1}=10 or \${cdprioritiesr2}=10 or \${cdprioritiesr3}=10

* implementationgaps
char condentgroupimplementationgaps[Odk_name] implementationgaps
char condentgroupimplementationgaps[Odk_bad_name] 0
char condentgroupimplementationgaps[Odk_group] condentgroup
char condentgroupimplementationgaps[Odk_long_name] condentgroup-implementationgaps
char condentgroupimplementationgaps[Odk_type] select_one yesnodkr
char condentgroupimplementationgaps[Odk_list_name] yesnodkr
char condentgroupimplementationgaps[Odk_or_other] 0
char condentgroupimplementationgaps[Odk_is_other] 0
char condentgroupimplementationgaps[Odk_label] 9) Did any CDF-funded projects experience UNPLANNED delays of more than one month? These delays could be for either project activities or project spending.
char condentgroupimplementationgaps[Odk_required] yes

* whyimplementationgaps
foreach suffix in "" _other {
	* condentgroup-whyimplementationgaps_other: duplicate variable name with condentgroup-whyimplementationgaps.
	local pos : list posof "condentgroup-whyimplementationgaps`suffix'" in fields
	local var : word `pos' of `all'
	local isbadname = "`var'" != substr("condentgroupwhyimplementationgap`suffix'", 1, 32)
	char `var'[Odk_name] whyimplementationgaps
	char `var'[Odk_bad_name] `isbadname'
	char `var'[Odk_group] condentgroup
	char `var'[Odk_long_name] condentgroup-whyimplementationgaps
	char `var'[Odk_type] select_multiple impgaps or_other
	char `var'[Odk_list_name] impgaps
	char `var'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char `var'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char `var'[Odk_label] 10) In your opinion, what do you think MOST contributed to these unplanned delays? I will provide you with a list of options so you can follow as I read them. PROMPT:`labend'
	char `var'[Odk_hint] ENUMERATOR: You may select all that apply.
	char `var'[Odk_relevance] \${implementationgaps}=1
	char `var'[Odk_required] yes
}

* module1end
char condentgroupmodule1end[Odk_name] module1end
char condentgroupmodule1end[Odk_bad_name] 0
char condentgroupmodule1end[Odk_group] condentgroup
char condentgroupmodule1end[Odk_long_name] condentgroup-module1end
char condentgroupmodule1end[Odk_type] note
char condentgroupmodule1end[Odk_or_other] 0
char condentgroupmodule1end[Odk_is_other] 0
char condentgroupmodule1end[Odk_label] End of Module 1

* module2start
char condentgroupmodule2start[Odk_name] module2start
char condentgroupmodule2start[Odk_bad_name] 0
char condentgroupmodule2start[Odk_group] condentgroup
char condentgroupmodule2start[Odk_long_name] condentgroup-module2start
char condentgroupmodule2start[Odk_type] note
char condentgroupmodule2start[Odk_or_other] 0
char condentgroupmodule2start[Odk_is_other] 0
char condentgroupmodule2start[Odk_label] Module 2: MP Roles and Responsibilities - [Read] In this section, we will be asking your opinions on the most important roles of MPs according to: your own opinion/beliefs, people in your constituency’s beliefs, and those of your party (if applicable).

* begin group mpactions

* hqmpr1
char condentgroupmpactionshqmpr1[Odk_name] hqmpr1
char condentgroupmpactionshqmpr1[Odk_bad_name] 0
char condentgroupmpactionshqmpr1[Odk_group] condentgroup mpactions
char condentgroupmpactionshqmpr1[Odk_long_name] condentgroup-mpactions-hqmpr1
char condentgroupmpactionshqmpr1[Odk_type] select_one mpactions
char condentgroupmpactionshqmpr1[Odk_list_name] mpactions
char condentgroupmpactionshqmpr1[Odk_or_other] 0
char condentgroupmpactionshqmpr1[Odk_is_other] 0
char condentgroupmpactionshqmpr1[Odk_label] Rank Action 1
char condentgroupmpactionshqmpr1[Odk_appearance] minimal
char condentgroupmpactionshqmpr1[Odk_required] yes

* hqmpr2
char condentgroupmpactionshqmpr2[Odk_name] hqmpr2
char condentgroupmpactionshqmpr2[Odk_bad_name] 0
char condentgroupmpactionshqmpr2[Odk_group] condentgroup mpactions
char condentgroupmpactionshqmpr2[Odk_long_name] condentgroup-mpactions-hqmpr2
char condentgroupmpactionshqmpr2[Odk_type] select_one mpactions
char condentgroupmpactionshqmpr2[Odk_list_name] mpactions
char condentgroupmpactionshqmpr2[Odk_or_other] 0
char condentgroupmpactionshqmpr2[Odk_is_other] 0
char condentgroupmpactionshqmpr2[Odk_label] Rank Action 2
char condentgroupmpactionshqmpr2[Odk_appearance] minimal
char condentgroupmpactionshqmpr2[Odk_constraint] .!=\${hqmpr1}
char condentgroupmpactionshqmpr2[Odk_constraint_message] You must choose a different response for each field!

* hqmpr3
char condentgroupmpactionshqmpr3[Odk_name] hqmpr3
char condentgroupmpactionshqmpr3[Odk_bad_name] 0
char condentgroupmpactionshqmpr3[Odk_group] condentgroup mpactions
char condentgroupmpactionshqmpr3[Odk_long_name] condentgroup-mpactions-hqmpr3
char condentgroupmpactionshqmpr3[Odk_type] select_one mpactions
char condentgroupmpactionshqmpr3[Odk_list_name] mpactions
char condentgroupmpactionshqmpr3[Odk_or_other] 0
char condentgroupmpactionshqmpr3[Odk_is_other] 0
char condentgroupmpactionshqmpr3[Odk_label] Rank Action 3
char condentgroupmpactionshqmpr3[Odk_appearance] minimal
char condentgroupmpactionshqmpr3[Odk_constraint] .!=\${hqmpr1} and .!=\${hqmpr2}
char condentgroupmpactionshqmpr3[Odk_constraint_message] You must choose a different response for each field!

* end group mpactions

* hqmpr_other
char condentgrouphqmpr_other[Odk_name] hqmpr_other
char condentgrouphqmpr_other[Odk_bad_name] 0
char condentgrouphqmpr_other[Odk_group] condentgroup
char condentgrouphqmpr_other[Odk_long_name] condentgroup-hqmpr_other
char condentgrouphqmpr_other[Odk_type] text
char condentgrouphqmpr_other[Odk_or_other] 0
char condentgrouphqmpr_other[Odk_is_other] 0
char condentgrouphqmpr_other[Odk_label] Specify Other
char condentgrouphqmpr_other[Odk_relevance] \${hqmpr1}=10 or \${hqmpr2}=10 or \${hqmpr3}=10

* begin group mproles

* roleconr1
char condentgroupmprolesroleconr1[Odk_name] roleconr1
char condentgroupmprolesroleconr1[Odk_bad_name] 0
char condentgroupmprolesroleconr1[Odk_group] condentgroup mproles
char condentgroupmprolesroleconr1[Odk_long_name] condentgroup-mproles-roleconr1
char condentgroupmprolesroleconr1[Odk_type] select_one mpactions
char condentgroupmprolesroleconr1[Odk_list_name] mpactions
char condentgroupmprolesroleconr1[Odk_or_other] 0
char condentgroupmprolesroleconr1[Odk_is_other] 0
char condentgroupmprolesroleconr1[Odk_label] Rank most important role
char condentgroupmprolesroleconr1[Odk_appearance] minimal
char condentgroupmprolesroleconr1[Odk_required] yes

* roleconr2
char condentgroupmprolesroleconr2[Odk_name] roleconr2
char condentgroupmprolesroleconr2[Odk_bad_name] 0
char condentgroupmprolesroleconr2[Odk_group] condentgroup mproles
char condentgroupmprolesroleconr2[Odk_long_name] condentgroup-mproles-roleconr2
char condentgroupmprolesroleconr2[Odk_type] select_one mpactions
char condentgroupmprolesroleconr2[Odk_list_name] mpactions
char condentgroupmprolesroleconr2[Odk_or_other] 0
char condentgroupmprolesroleconr2[Odk_is_other] 0
char condentgroupmprolesroleconr2[Odk_label] Rank 2nd most important role
char condentgroupmprolesroleconr2[Odk_appearance] minimal
char condentgroupmprolesroleconr2[Odk_constraint] .!=\${roleconr1}
char condentgroupmprolesroleconr2[Odk_constraint_message] You must choose a different response for each field!

* roleconr3
char condentgroupmprolesroleconr3[Odk_name] roleconr3
char condentgroupmprolesroleconr3[Odk_bad_name] 0
char condentgroupmprolesroleconr3[Odk_group] condentgroup mproles
char condentgroupmprolesroleconr3[Odk_long_name] condentgroup-mproles-roleconr3
char condentgroupmprolesroleconr3[Odk_type] select_one mpactions
char condentgroupmprolesroleconr3[Odk_list_name] mpactions
char condentgroupmprolesroleconr3[Odk_or_other] 0
char condentgroupmprolesroleconr3[Odk_is_other] 0
char condentgroupmprolesroleconr3[Odk_label] Rank 3rd most important role
char condentgroupmprolesroleconr3[Odk_appearance] minimal
char condentgroupmprolesroleconr3[Odk_constraint] .!=\${roleconr1} and .!=\${roleconr2}
char condentgroupmprolesroleconr3[Odk_constraint_message] You must choose a different response for each field!

* end group mproles

* roleconr_other
char condentgrouproleconr_other[Odk_name] roleconr_other
char condentgrouproleconr_other[Odk_bad_name] 0
char condentgrouproleconr_other[Odk_group] condentgroup
char condentgrouproleconr_other[Odk_long_name] condentgroup-roleconr_other
char condentgrouproleconr_other[Odk_type] text
char condentgrouproleconr_other[Odk_or_other] 0
char condentgrouproleconr_other[Odk_is_other] 0
char condentgrouproleconr_other[Odk_label] Specify Other
char condentgrouproleconr_other[Odk_relevance] \${roleconr1}=10 or \${roleconr2}=10 or \${roleconr3}=10

* begin group mproleparty

* mprolepartyr1
char condentgroupmprolepartymprolepar[Odk_name] mprolepartyr1
char condentgroupmprolepartymprolepar[Odk_bad_name] 0
char condentgroupmprolepartymprolepar[Odk_group] condentgroup mproleparty
char condentgroupmprolepartymprolepar[Odk_long_name] condentgroup-mproleparty-mprolepartyr1
char condentgroupmprolepartymprolepar[Odk_type] select_one mpactions
char condentgroupmprolepartymprolepar[Odk_list_name] mpactions
char condentgroupmprolepartymprolepar[Odk_or_other] 0
char condentgroupmprolepartymprolepar[Odk_is_other] 0
char condentgroupmprolepartymprolepar[Odk_label] Rank Most important role
char condentgroupmprolepartymprolepar[Odk_appearance] minimal
char condentgroupmprolepartymprolepar[Odk_required] yes

* mprolepartyr2
* Duplicate variable name with condentgroup-mproleparty-mprolepartyr1
local pos : list posof "condentgroup-mproleparty-mprolepartyr2" in fields
local var : word `pos' of `all'
char `var'[Odk_name] mprolepartyr2
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup mproleparty
char `var'[Odk_long_name] condentgroup-mproleparty-mprolepartyr2
char `var'[Odk_type] select_one mpactions
char `var'[Odk_list_name] mpactions
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] Rank 2nd most important role
char `var'[Odk_appearance] minimal
char `var'[Odk_constraint] .!=\${mprolepartyr1}
char `var'[Odk_constraint_message] You must choose a different response for each field!

* mprolepartyr3
* Duplicate variable name with condentgroup-mproleparty-mprolepartyr1
local pos : list posof "condentgroup-mproleparty-mprolepartyr3" in fields
local var : word `pos' of `all'
char `var'[Odk_name] mprolepartyr3
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup mproleparty
char `var'[Odk_long_name] condentgroup-mproleparty-mprolepartyr3
char `var'[Odk_type] select_one mpactions
char `var'[Odk_list_name] mpactions
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] Rank 3rd most important role
char `var'[Odk_appearance] minimal
char `var'[Odk_constraint] .!=\${mprolepartyr1} and .!=\${mprolepartyr2}
char `var'[Odk_constraint_message] You must choose a different response for each field!

* end group mproleparty

* mprolepartyr_other
char condentgroupmprolepartyr_other[Odk_name] mprolepartyr_other
char condentgroupmprolepartyr_other[Odk_bad_name] 0
char condentgroupmprolepartyr_other[Odk_group] condentgroup
char condentgroupmprolepartyr_other[Odk_long_name] condentgroup-mprolepartyr_other
char condentgroupmprolepartyr_other[Odk_type] text
char condentgroupmprolepartyr_other[Odk_or_other] 0
char condentgroupmprolepartyr_other[Odk_is_other] 0
char condentgroupmprolepartyr_other[Odk_label] Specify Other
char condentgroupmprolepartyr_other[Odk_relevance] \${mprolepartyr1}=10 or \${mprolepartyr2}=10 or \${mprolepartyr3}=10

* mainaction
foreach suffix in "" _other {
	char condentgroupmainaction`suffix'[Odk_name] mainaction
	char condentgroupmainaction`suffix'[Odk_bad_name] 0
	char condentgroupmainaction`suffix'[Odk_group] condentgroup
	char condentgroupmainaction`suffix'[Odk_long_name] condentgroup-mainaction
	char condentgroupmainaction`suffix'[Odk_type] select_one mpactions or_other
	char condentgroupmainaction`suffix'[Odk_list_name] mpactions
	char condentgroupmainaction`suffix'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char condentgroupmainaction`suffix'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char condentgroupmainaction`suffix'[Odk_label] 14) What is the MAIN ACTION an MP needs to take in order to get re-elected? Please select one only. PROMPT:`labend'
	char condentgroupmainaction`suffix'[Odk_required] yes
}

* mproleother
char condentgroupmproleother[Odk_name] mproleother
char condentgroupmproleother[Odk_bad_name] 0
char condentgroupmproleother[Odk_group] condentgroup
char condentgroupmproleother[Odk_long_name] condentgroup-mproleother
char condentgroupmproleother[Odk_type] text
char condentgroupmproleother[Odk_or_other] 0
char condentgroupmproleother[Odk_is_other] 0
char condentgroupmproleother[Odk_label] 15) In 1-3 short sentences, can you describe what your CONSTITUENTS UNDERSTAND the role of an MP is?
char condentgroupmproleother[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupmproleother[Odk_required] yes

* TraditionalLeadership
char condentgroupTraditionalLeadershi[Odk_name] TraditionalLeadership
char condentgroupTraditionalLeadershi[Odk_bad_name] 0
char condentgroupTraditionalLeadershi[Odk_group] condentgroup
char condentgroupTraditionalLeadershi[Odk_long_name] condentgroup-TraditionalLeadership
char condentgroupTraditionalLeadershi[Odk_type] select_one yesnodkr
char condentgroupTraditionalLeadershi[Odk_list_name] yesnodkr
char condentgroupTraditionalLeadershi[Odk_or_other] 0
char condentgroupTraditionalLeadershi[Odk_is_other] 0
char condentgroupTraditionalLeadershi[Odk_label] 16) Does your constituency have TRADITIONAL LEADERS such as chiefs or headmen?
char condentgroupTraditionalLeadershi[Odk_required] yes

* traditionalvconstituency
char condentgrouptraditionalvconstitu[Odk_name] traditionalvconstituency
char condentgrouptraditionalvconstitu[Odk_bad_name] 0
char condentgrouptraditionalvconstitu[Odk_group] condentgroup
char condentgrouptraditionalvconstitu[Odk_long_name] condentgroup-traditionalvconstituency
char condentgrouptraditionalvconstitu[Odk_type] select_one support
char condentgrouptraditionalvconstitu[Odk_list_name] support
char condentgrouptraditionalvconstitu[Odk_or_other] 0
char condentgrouptraditionalvconstitu[Odk_is_other] 0
char condentgrouptraditionalvconstitu[Odk_label] "17) Suppose the majority of ordinary citizens in your CONSTITUENCY support one policy while a majority of TRADITIONAL LEADERS / chiefs in your constituency support another. If you felt EQUALLY about both policies but could only support ONE, which would you support? "
char condentgrouptraditionalvconstitu[Odk_relevance] \${TraditionalLeadership}=1
char condentgrouptraditionalvconstitu[Odk_required] yes

* traditionalvparty
char condentgrouptraditionalvparty[Odk_name] traditionalvparty
char condentgrouptraditionalvparty[Odk_bad_name] 0
char condentgrouptraditionalvparty[Odk_group] condentgroup
char condentgrouptraditionalvparty[Odk_long_name] condentgroup-traditionalvparty
char condentgrouptraditionalvparty[Odk_type] select_one support1
char condentgrouptraditionalvparty[Odk_list_name] support1
char condentgrouptraditionalvparty[Odk_or_other] 0
char condentgrouptraditionalvparty[Odk_is_other] 0
char condentgrouptraditionalvparty[Odk_label] "18) Suppose your PARTY leadership supports one policy while a majority of TRADITIONAL LEADERS / chiefs in your constituency supports another. If you felt EQUALLY about both policies but could only support ONE, which would you support? "
char condentgrouptraditionalvparty[Odk_relevance] \${TraditionalLeadership}=1 and \${party}!='IND' and (\${correctparty}=1 or \${correctparty}=2 or \${correctparty}=3 or \${correctparty}=4 or \${correctparty}='')
char condentgrouptraditionalvparty[Odk_required] yes

* partyvconstituency
char condentgrouppartyvconstituency[Odk_name] partyvconstituency
char condentgrouppartyvconstituency[Odk_bad_name] 0
char condentgrouppartyvconstituency[Odk_group] condentgroup
char condentgrouppartyvconstituency[Odk_long_name] condentgroup-partyvconstituency
char condentgrouppartyvconstituency[Odk_type] select_one support2
char condentgrouppartyvconstituency[Odk_list_name] support2
char condentgrouppartyvconstituency[Odk_or_other] 0
char condentgrouppartyvconstituency[Odk_is_other] 0
char condentgrouppartyvconstituency[Odk_label] "19) Suppose your PARTY leadership supports one policy while a majority of your CONSTITUENTS supports another. If you felt EQUALLY about both policies but could only support ONE, which would you support? "
char condentgrouppartyvconstituency[Odk_relevance] \${party}!='IND' and (\${correctparty}=1 or \${correctparty}=2 or \${correctparty}=3 or \${correctparty}=4 or  \${correctparty}='')
char condentgrouppartyvconstituency[Odk_required] yes

* module2end
char condentgroupmodule2end[Odk_name] module2end
char condentgroupmodule2end[Odk_bad_name] 0
char condentgroupmodule2end[Odk_group] condentgroup
char condentgroupmodule2end[Odk_long_name] condentgroup-module2end
char condentgroupmodule2end[Odk_type] note
char condentgroupmodule2end[Odk_or_other] 0
char condentgroupmodule2end[Odk_is_other] 0
char condentgroupmodule2end[Odk_label] DO NOT READ: End of Module 2

* begin group party_begin

* module3start
char condentgroupparty_beginmodule3st[Odk_name] module3start
char condentgroupparty_beginmodule3st[Odk_bad_name] 0
char condentgroupparty_beginmodule3st[Odk_group] condentgroup party_begin
char condentgroupparty_beginmodule3st[Odk_long_name] condentgroup-party_begin-module3start
char condentgroupparty_beginmodule3st[Odk_type] note
char condentgroupparty_beginmodule3st[Odk_or_other] 0
char condentgroupparty_beginmodule3st[Odk_is_other] 0
char condentgroupparty_beginmodule3st[Odk_label] Module 3: MP Party Standing - [Read] The questions in this section are meant to help us understand structures and relations that exist within parties. Again please remember that all information provided in this survey is strictly confidential and survey responses will not be tied to the name of any individual MP. Unless otherwise specified, please answer for the time period 1 April 2015 to 17 September 2015.

* PartyLeadershipPosition
char condentgroupparty_beginPartyLead[Odk_name] PartyLeadershipPosition
char condentgroupparty_beginPartyLead[Odk_bad_name] 0
char condentgroupparty_beginPartyLead[Odk_group] condentgroup party_begin
char condentgroupparty_beginPartyLead[Odk_long_name] condentgroup-party_begin-PartyLeadershipPosition
char condentgroupparty_beginPartyLead[Odk_type] select_one yesnodkr
char condentgroupparty_beginPartyLead[Odk_list_name] yesnodkr
char condentgroupparty_beginPartyLead[Odk_or_other] 0
char condentgroupparty_beginPartyLead[Odk_is_other] 0
char condentgroupparty_beginPartyLead[Odk_label] 20) During this time period, did you hold any LEADERSHIP positions within your PARTY?
char condentgroupparty_beginPartyLead[Odk_required] yes

* PositionInParty
char condentgroupparty_beginPositionI[Odk_name] PositionInParty
char condentgroupparty_beginPositionI[Odk_bad_name] 0
char condentgroupparty_beginPositionI[Odk_group] condentgroup party_begin
char condentgroupparty_beginPositionI[Odk_long_name] condentgroup-party_begin-PositionInParty
char condentgroupparty_beginPositionI[Odk_type] text
char condentgroupparty_beginPositionI[Odk_or_other] 0
char condentgroupparty_beginPositionI[Odk_is_other] 0
char condentgroupparty_beginPositionI[Odk_label] 21) What position or positions of leadership do you hold within your party during this time period?
char condentgroupparty_beginPositionI[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupparty_beginPositionI[Odk_relevance] \${PartyLeadershipPosition}=1
char condentgroupparty_beginPositionI[Odk_required] yes

* meetingwithleadership
char condentgroupparty_beginmeetingwi[Odk_name] meetingwithleadership
char condentgroupparty_beginmeetingwi[Odk_bad_name] 0
char condentgroupparty_beginmeetingwi[Odk_group] condentgroup party_begin
char condentgroupparty_beginmeetingwi[Odk_long_name] condentgroup-party_begin-meetingwithleadership
char condentgroupparty_beginmeetingwi[Odk_type] integer
char condentgroupparty_beginmeetingwi[Odk_or_other] 0
char condentgroupparty_beginmeetingwi[Odk_is_other] 0
char condentgroupparty_beginmeetingwi[Odk_label] 22) How many TIMES did you meet with your PARTY'S LEADERSHIP, meaning any senior party leader, over the past year (September 2014 – September 2015)? Note that these are other official meetings outside of the party workshops / meetings where all MPs are invited.
char condentgroupparty_beginmeetingwi[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupparty_beginmeetingwi[Odk_required] yes

* CampaignAppearances
char condentgroupparty_beginCampaignA[Odk_name] CampaignAppearances
char condentgroupparty_beginCampaignA[Odk_bad_name] 0
char condentgroupparty_beginCampaignA[Odk_group] condentgroup party_begin
char condentgroupparty_beginCampaignA[Odk_long_name] condentgroup-party_begin-CampaignAppearances
char condentgroupparty_beginCampaignA[Odk_type] select_one yesnodkr
char condentgroupparty_beginCampaignA[Odk_list_name] yesnodkr
char condentgroupparty_beginCampaignA[Odk_or_other] 0
char condentgroupparty_beginCampaignA[Odk_is_other] 0
char condentgroupparty_beginCampaignA[Odk_label] "23) During the 2011 general elections (or by-elections in which you were elected to this office), did any senior PARTY LEADER make an APPEARANCE in your constituency to campaign with you? "
char condentgroupparty_beginCampaignA[Odk_required] yes

* CampaignAssistance_2011
* Duplicate variable name with condentgroup-party_begin-CampaignAppearances
local pos : list posof "condentgroup-party_begin-CampaignAssistance_2011" in fields
local var : word `pos' of `all'
char `var'[Odk_name] CampaignAssistance_2011
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup party_begin
char `var'[Odk_long_name] condentgroup-party_begin-CampaignAssistance_2011
char `var'[Odk_type] select_one yesnodkr
char `var'[Odk_list_name] yesnodkr
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] "24) During the 2011 general elections (or by-elections in which you were elected to this office), did you receive any FUNDS or other material assistance from your PARTY to support your campaign efforts? "
char `var'[Odk_required] yes

* CampaignAssitance_2011
foreach suffix in "" _other {
	* condentgroup-party_begin-CampaignAssitance_2011: duplicate variable name with condentgroup-party_begin-CampaignAppearances.
	local pos : list posof "condentgroup-party_begin-CampaignAssitance_2011`suffix'" in fields
	local var : word `pos' of `all'
	local isbadname = "`var'" != substr("condentgroupparty_beginCampaignA`suffix'", 1, 32)
	char `var'[Odk_name] CampaignAssitance_2011
	char `var'[Odk_bad_name] `isbadname'
	char `var'[Odk_group] condentgroup party_begin
	char `var'[Odk_long_name] condentgroup-party_begin-CampaignAssitance_2011
	char `var'[Odk_type] select_multiple assistance or_other
	char `var'[Odk_list_name] assistance
	char `var'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char `var'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char `var'[Odk_label] 25) What type of assistance did you receive? You can choose more than one option. PROMPT:`labend'
	char `var'[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
	char `var'[Odk_relevance] \${CampaignAssistance_2011}=1
	char `var'[Odk_required] yes
}

* Re-elect_2016
char condentgroupparty_beginReelect_2[Odk_name] Re-elect_2016
char condentgroupparty_beginReelect_2[Odk_bad_name] 0
char condentgroupparty_beginReelect_2[Odk_group] condentgroup party_begin
char condentgroupparty_beginReelect_2[Odk_long_name] condentgroup-party_begin-Re-elect_2016
char condentgroupparty_beginReelect_2[Odk_type] select_one yesnodkr
char condentgroupparty_beginReelect_2[Odk_list_name] yesnodkr
char condentgroupparty_beginReelect_2[Odk_or_other] 0
char condentgroupparty_beginReelect_2[Odk_is_other] 0
char condentgroupparty_beginReelect_2[Odk_label] 26) Do you plan to run for re-election for your constituency in 2016?
char condentgroupparty_beginReelect_2[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888

* Prepare_2016
char condentgroupparty_beginPrepare_2[Odk_name] Prepare_2016
char condentgroupparty_beginPrepare_2[Odk_bad_name] 0
char condentgroupparty_beginPrepare_2[Odk_group] condentgroup party_begin
char condentgroupparty_beginPrepare_2[Odk_long_name] condentgroup-party_begin-Prepare_2016
char condentgroupparty_beginPrepare_2[Odk_type] select_one yesnodkr
char condentgroupparty_beginPrepare_2[Odk_list_name] yesnodkr
char condentgroupparty_beginPrepare_2[Odk_or_other] 0
char condentgroupparty_beginPrepare_2[Odk_is_other] 0
char condentgroupparty_beginPrepare_2[Odk_label] 27) Have you already started preparing for the 2016 elections?
char condentgroupparty_beginPrepare_2[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupparty_beginPrepare_2[Odk_relevance] \${Re-elect_2016}=1

* CampaignAssistance_2016
* Duplicate variable name with condentgroup-party_begin-CampaignAppearances
local pos : list posof "condentgroup-party_begin-CampaignAssistance_2016" in fields
local var : word `pos' of `all'
char `var'[Odk_name] CampaignAssistance_2016
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup party_begin
char `var'[Odk_long_name] condentgroup-party_begin-CampaignAssistance_2016
char `var'[Odk_type] select_one yesnodkr
char `var'[Odk_list_name] yesnodkr
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] "28) Have you received any FUNDS or other material assistance from your party in preparation for your campaigning efforts of the upcoming 2016 ELECTIONS? "
char `var'[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -889
char `var'[Odk_relevance] \${Re-elect_2016}=1
char `var'[Odk_required] yes

* CampaignAssitance_2016
foreach suffix in "" _other {
	* condentgroup-party_begin-CampaignAssitance_2016: duplicate variable name with condentgroup-party_begin-CampaignAppearances.
	local pos : list posof "condentgroup-party_begin-CampaignAssitance_2016`suffix'" in fields
	local var : word `pos' of `all'
	local isbadname = "`var'" != substr("condentgroupparty_beginCampaignA`suffix'", 1, 32)
	char `var'[Odk_name] CampaignAssitance_2016
	char `var'[Odk_bad_name] `isbadname'
	char `var'[Odk_group] condentgroup party_begin
	char `var'[Odk_long_name] condentgroup-party_begin-CampaignAssitance_2016
	char `var'[Odk_type] select_multiple assistance or_other
	char `var'[Odk_list_name] assistance
	char `var'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char `var'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char `var'[Odk_label] 29) What type of assistance did you receive? You can choose more than one option. PROMPT:`labend'
	char `var'[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
	char `var'[Odk_relevance] \${CampaignAssistance_2016}=1
	char `var'[Odk_required] yes
}

* module3end
char condentgroupparty_beginmodule3en[Odk_name] module3end
char condentgroupparty_beginmodule3en[Odk_bad_name] 0
char condentgroupparty_beginmodule3en[Odk_group] condentgroup party_begin
char condentgroupparty_beginmodule3en[Odk_long_name] condentgroup-party_begin-module3end
char condentgroupparty_beginmodule3en[Odk_type] note
char condentgroupparty_beginmodule3en[Odk_or_other] 0
char condentgroupparty_beginmodule3en[Odk_is_other] 0
char condentgroupparty_beginmodule3en[Odk_label] DO NOT READ: End of Module 3

* end group party_begin

* module3_end
char condentgroupmodule3_end[Odk_name] module3_end
char condentgroupmodule3_end[Odk_bad_name] 0
char condentgroupmodule3_end[Odk_group] condentgroup
char condentgroupmodule3_end[Odk_long_name] condentgroup-module3_end
char condentgroupmodule3_end[Odk_type] note
char condentgroupmodule3_end[Odk_or_other] 0
char condentgroupmodule3_end[Odk_is_other] 0
char condentgroupmodule3_end[Odk_label] DO NOT READ: Please note that module 3 is skipped in this case because it doesn’t apply for independent MPs.
char condentgroupmodule3_end[Odk_relevance] "\${party}='IND' or \${correctparty}=5 "

* module4start
char condentgroupmodule4start[Odk_name] module4start
char condentgroupmodule4start[Odk_bad_name] 0
char condentgroupmodule4start[Odk_group] condentgroup
char condentgroupmodule4start[Odk_long_name] condentgroup-module4start
char condentgroupmodule4start[Odk_type] note
char condentgroupmodule4start[Odk_or_other] 0
char condentgroupmodule4start[Odk_is_other] 0
char condentgroupmodule4start[Odk_label] Module 4: Accountability Measures - [Read] In this section, we will be asking questions to help us better understand and independently assess the accountability measures that are being used as part of Caritas Zambia's Parliamentary work. As a reminder, IPA is an independent local research firm and this survey data will be used for research purposes only; all information provided in this survey is strictly confidential and survey responses will not be tied to the name of any individual MP. Unless otherwise specified, please answer for the time period 1 April 2015 to 17 September 2015.

* parliamentattendance
char condentgroupparliamentattendance[Odk_name] parliamentattendance
char condentgroupparliamentattendance[Odk_bad_name] 0
char condentgroupparliamentattendance[Odk_group] condentgroup
char condentgroupparliamentattendance[Odk_long_name] condentgroup-parliamentattendance
char condentgroupparliamentattendance[Odk_type] integer
char condentgroupparliamentattendance[Odk_or_other] 0
char condentgroupparliamentattendance[Odk_is_other] 0
char condentgroupparliamentattendance[Odk_label] 30) How many days did you visit NATIONAL ASSEMBLY during the period?
char condentgroupparliamentattendance[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupparliamentattendance[Odk_constraint] .<=170
char condentgroupparliamentattendance[Odk_constraint_message] Please enter a value less than or equal to 170.
char condentgroupparliamentattendance[Odk_required] yes

* officevisits
char condentgroupofficevisits[Odk_name] officevisits
char condentgroupofficevisits[Odk_bad_name] 0
char condentgroupofficevisits[Odk_group] condentgroup
char condentgroupofficevisits[Odk_long_name] condentgroup-officevisits
char condentgroupofficevisits[Odk_type] integer
char condentgroupofficevisits[Odk_or_other] 0
char condentgroupofficevisits[Odk_is_other] 0
char condentgroupofficevisits[Odk_label] 31) On the days you were at NATIONAL ASSEMBLY during the period, how many hours did you spend there on AVERAGE per day?
char condentgroupofficevisits[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupofficevisits[Odk_constraint] .<=24
char condentgroupofficevisits[Odk_constraint_message] Please enter a value less than or equal to 24.
char condentgroupofficevisits[Odk_required] yes

* ConstituencyVisits
char condentgroupConstituencyVisits[Odk_name] ConstituencyVisits
char condentgroupConstituencyVisits[Odk_bad_name] 0
char condentgroupConstituencyVisits[Odk_group] condentgroup
char condentgroupConstituencyVisits[Odk_long_name] condentgroup-ConstituencyVisits
char condentgroupConstituencyVisits[Odk_type] integer
char condentgroupConstituencyVisits[Odk_or_other] 0
char condentgroupConstituencyVisits[Odk_is_other] 0
char condentgroupConstituencyVisits[Odk_label] 32) How many days did you visit the office in your CONSTITUENCY?
char condentgroupConstituencyVisits[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupConstituencyVisits[Odk_constraint] .<=170
char condentgroupConstituencyVisits[Odk_required] yes

* outreach
foreach suffix in "" _other {
	char condentgroupoutreach`suffix'[Odk_name] outreach
	char condentgroupoutreach`suffix'[Odk_bad_name] 0
	char condentgroupoutreach`suffix'[Odk_group] condentgroup
	char condentgroupoutreach`suffix'[Odk_long_name] condentgroup-outreach
	char condentgroupoutreach`suffix'[Odk_type] select_multiple outreach or_other
	char condentgroupoutreach`suffix'[Odk_list_name] outreach
	char condentgroupoutreach`suffix'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char condentgroupoutreach`suffix'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char condentgroupoutreach`suffix'[Odk_label] 33) In your day-to-day activities as an MP, have you engaged in any of the following OUTREACH to your constituency in the period, excluding campaigning? You can chose more than one option. PROMPT:`labend'
	char condentgroupoutreach`suffix'[Odk_hint] ENUMERATOR: Select all that apply.
	char condentgroupoutreach`suffix'[Odk_required] yes
}

* effectiveMP1
char condentgroupeffectiveMP1[Odk_name] effectiveMP1
char condentgroupeffectiveMP1[Odk_bad_name] 0
char condentgroupeffectiveMP1[Odk_group] condentgroup
char condentgroupeffectiveMP1[Odk_long_name] condentgroup-effectiveMP1
char condentgroupeffectiveMP1[Odk_type] integer
char condentgroupeffectiveMP1[Odk_or_other] 0
char condentgroupeffectiveMP1[Odk_is_other] 0
char condentgroupeffectiveMP1[Odk_label] 34) In a given month while NATIONAL ASSEMBLY is in session, how many PLENARY SESSIONS do you think an MP needs to attend to be effective at his or her job?
char condentgroupeffectiveMP1[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupeffectiveMP1[Odk_required] yes

* effectiveMP2
char condentgroupeffectiveMP2[Odk_name] effectiveMP2
char condentgroupeffectiveMP2[Odk_bad_name] 0
char condentgroupeffectiveMP2[Odk_group] condentgroup
char condentgroupeffectiveMP2[Odk_long_name] condentgroup-effectiveMP2
char condentgroupeffectiveMP2[Odk_type] text
char condentgroupeffectiveMP2[Odk_or_other] 0
char condentgroupeffectiveMP2[Odk_is_other] 0
char condentgroupeffectiveMP2[Odk_label] 35) In a given month while NATIONAL ASSEMBLY is in session, how many times do you think an MP should visit his/her CONSTITUENCY OFFICE to be effective at his or her job?
char condentgroupeffectiveMP2[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupeffectiveMP2[Odk_required] yes

* effectiveMP3
char condentgroupeffectiveMP3[Odk_name] effectiveMP3
char condentgroupeffectiveMP3[Odk_bad_name] 0
char condentgroupeffectiveMP3[Odk_group] condentgroup
char condentgroupeffectiveMP3[Odk_long_name] condentgroup-effectiveMP3
char condentgroupeffectiveMP3[Odk_type] integer
char condentgroupeffectiveMP3[Odk_or_other] 0
char condentgroupeffectiveMP3[Odk_is_other] 0
char condentgroupeffectiveMP3[Odk_label] 36) Where an MP has a committee appointment, what PERCENTAGE of COMMITTEE SESSIONS do you think an MP needs to attend to be effective at his or her job?
char condentgroupeffectiveMP3[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupeffectiveMP3[Odk_constraint] .<=100
char condentgroupeffectiveMP3[Odk_constraint_message] Please enter a value between 0 and 100!
char condentgroupeffectiveMP3[Odk_required] yes

* CampaignAssistance
char condentgroupCampaignAssistance[Odk_name] CampaignAssistance
char condentgroupCampaignAssistance[Odk_bad_name] 0
char condentgroupCampaignAssistance[Odk_group] condentgroup
char condentgroupCampaignAssistance[Odk_long_name] condentgroup-CampaignAssistance
char condentgroupCampaignAssistance[Odk_type] select_one yesnodkr
char condentgroupCampaignAssistance[Odk_list_name] yesnodkr
char condentgroupCampaignAssistance[Odk_or_other] 0
char condentgroupCampaignAssistance[Odk_is_other] 0
char condentgroupCampaignAssistance[Odk_label] "37) Do you maintain a RESIDENCE in or near Lusaka even when NATIONAL ASSEMBLY is not in session? "
char condentgroupCampaignAssistance[Odk_hint] ENUMERATOR: if asked, "near" means within 2 hours driving
char condentgroupCampaignAssistance[Odk_required] yes

* accountabilitymonitoring
char condentgroupaccountabilitymonito[Odk_name] accountabilitymonitoring
char condentgroupaccountabilitymonito[Odk_bad_name] 0
char condentgroupaccountabilitymonito[Odk_group] condentgroup
char condentgroupaccountabilitymonito[Odk_long_name] condentgroup-accountabilitymonitoring
char condentgroupaccountabilitymonito[Odk_type] text
char condentgroupaccountabilitymonito[Odk_or_other] 0
char condentgroupaccountabilitymonito[Odk_is_other] 0
char condentgroupaccountabilitymonito[Odk_label] 38) How is ACCOUNTABILITY currently monitored and enforced internally within your PARTY? So I can properly record your answer, please tell me in 1-3 short sentences.
char condentgroupaccountabilitymonito[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgroupaccountabilitymonito[Odk_required] yes

* accountabilitymonitoring1
* Duplicate variable name with condentgroup-accountabilitymonitoring
local pos : list posof "condentgroup-accountabilitymonitoring1" in fields
local var : word `pos' of `all'
char `var'[Odk_name] accountabilitymonitoring1
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup
char `var'[Odk_long_name] condentgroup-accountabilitymonitoring1
char `var'[Odk_type] text
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] 39) In your OPINION, how should  MP accountability be monitored and enforced within your PARTY? So I can properly record your answer, please tell me in 1-3 short sentences.
char `var'[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888

* accountabilitymonitoring2
* Duplicate variable name with condentgroup-accountabilitymonitoring
local pos : list posof "condentgroup-accountabilitymonitoring2" in fields
local var : word `pos' of `all'
char `var'[Odk_name] accountabilitymonitoring2
char `var'[Odk_bad_name] 1
char `var'[Odk_group] condentgroup
char `var'[Odk_long_name] condentgroup-accountabilitymonitoring2
char `var'[Odk_type] text
char `var'[Odk_or_other] 0
char `var'[Odk_is_other] 0
char `var'[Odk_label] 40) In your OPINION, how should  MP accountability be monitored and enforced within your CONSTITUENCY? So I can properly record your answer, please tell me in 1-3 short sentences.
char `var'[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char `var'[Odk_required] yes

* hansard
char condentgrouphansard[Odk_name] hansard
char condentgrouphansard[Odk_bad_name] 0
char condentgrouphansard[Odk_group] condentgroup
char condentgrouphansard[Odk_long_name] condentgroup-hansard
char condentgrouphansard[Odk_type] select_one hansard
char condentgrouphansard[Odk_list_name] hansard
char condentgrouphansard[Odk_or_other] 0
char condentgrouphansard[Odk_is_other] 0
char condentgrouphansard[Odk_label] 41) How IMPORTANT is record-keeping of all plenary and committee session transcripts / minutes (Hansards) for MP accountability? PROMPT:
char condentgrouphansard[Odk_required] yes

* hansarddisclosure
char condentgrouphansarddisclosure[Odk_name] hansarddisclosure
char condentgrouphansarddisclosure[Odk_bad_name] 0
char condentgrouphansarddisclosure[Odk_group] condentgroup
char condentgrouphansarddisclosure[Odk_long_name] condentgroup-hansarddisclosure
char condentgrouphansarddisclosure[Odk_type] select_one yesnodkr
char condentgrouphansarddisclosure[Odk_list_name] yesnodkr
char condentgrouphansarddisclosure[Odk_or_other] 0
char condentgrouphansarddisclosure[Odk_is_other] 0
char condentgrouphansarddisclosure[Odk_label] 42)  Do you believe Hansard records should be widely available to the public and media/press?
char condentgrouphansarddisclosure[Odk_required] yes

* hansardwhy
char condentgrouphansardwhy[Odk_name] hansardwhy
char condentgrouphansardwhy[Odk_bad_name] 0
char condentgrouphansardwhy[Odk_group] condentgroup
char condentgrouphansardwhy[Odk_long_name] condentgroup-hansardwhy
char condentgrouphansardwhy[Odk_type] text
char condentgrouphansardwhy[Odk_or_other] 0
char condentgrouphansardwhy[Odk_is_other] 0
char condentgrouphansardwhy[Odk_label] 43) Why do you believe Hansard records should not be widely available? So I can properly record your answer, please tell me in 1-3 short sentences.
char condentgrouphansardwhy[Odk_hint] ENUMERATOR: For "don't know" enter -999; for "refused" enter -888
char condentgrouphansardwhy[Odk_relevance] \${hansarddisclosure}=0
char condentgrouphansardwhy[Odk_required] yes

* votechoices
char condentgroupvotechoices[Odk_name] votechoices
char condentgroupvotechoices[Odk_bad_name] 0
char condentgroupvotechoices[Odk_group] condentgroup
char condentgroupvotechoices[Odk_long_name] condentgroup-votechoices
char condentgroupvotechoices[Odk_type] select_one yesnodkr
char condentgroupvotechoices[Odk_list_name] yesnodkr
char condentgroupvotechoices[Odk_or_other] 0
char condentgroupvotechoices[Odk_is_other] 0
char condentgroupvotechoices[Odk_label] 44) Currently, the specific vote choices of MPs on bills in plenary sessions are not recorded in the Hansard records. Should they be added?
char condentgroupvotechoices[Odk_relevance] \${hansarddisclosure}=1
char condentgroupvotechoices[Odk_required] yes

* TreatmentStatus
char condentgroupTreatmentStatus[Odk_name] TreatmentStatus
char condentgroupTreatmentStatus[Odk_bad_name] 0
char condentgroupTreatmentStatus[Odk_group] condentgroup
char condentgroupTreatmentStatus[Odk_long_name] condentgroup-TreatmentStatus
char condentgroupTreatmentStatus[Odk_type] select_one yesnodkr
char condentgroupTreatmentStatus[Odk_list_name] yesnodkr
char condentgroupTreatmentStatus[Odk_or_other] 0
char condentgroupTreatmentStatus[Odk_is_other] 0
char condentgroupTreatmentStatus[Odk_label] "45) As a part of the Scorecard pilot, 50 MPs were randomly selected to participate / be assessed. Were you one of those selected? "
char condentgroupTreatmentStatus[Odk_required] yes

* module4end
char condentgroupmodule4end[Odk_name] module4end
char condentgroupmodule4end[Odk_bad_name] 0
char condentgroupmodule4end[Odk_group] condentgroup
char condentgroupmodule4end[Odk_long_name] condentgroup-module4end
char condentgroupmodule4end[Odk_type] note
char condentgroupmodule4end[Odk_or_other] 0
char condentgroupmodule4end[Odk_is_other] 0
char condentgroupmodule4end[Odk_label] DO NOT READ: End of Module 4

* endnote
char condentgroupendnote[Odk_name] endnote
char condentgroupendnote[Odk_bad_name] 0
char condentgroupendnote[Odk_group] condentgroup
char condentgroupendnote[Odk_long_name] condentgroup-endnote
char condentgroupendnote[Odk_type] note
char condentgroupendnote[Odk_or_other] 0
char condentgroupendnote[Odk_is_other] 0
char condentgroupendnote[Odk_label] [Read] Thank you for your time. Please note that in the next few days, you may be contacted by telephone by another surveyor who will ask you a few questions from the ones in the questionnaire to ensure that I have recorded your responses accurately. We will also be contacting you in January for the second wave of the survey.

* end group condentgroup

* recordgps
foreach suffix in Latitude Longitude Altitude Accuracy {
	char recordgps`suffix'[Odk_name] recordgps
	char recordgps`suffix'[Odk_bad_name] 0
	char recordgps`suffix'[Odk_long_name] recordgps
	char recordgps`suffix'[Odk_type] geopoint
	char recordgps`suffix'[Odk_geopoint] `suffix'
	char recordgps`suffix'[Odk_or_other] 0
	char recordgps`suffix'[Odk_is_other] 0
	char recordgps`suffix'[Odk_label] DO NOT READ: please record your current GPS location. (`suffix')
}

* surveyornotes
char surveyornotes[Odk_name] surveyornotes
char surveyornotes[Odk_bad_name] 0
char surveyornotes[Odk_long_name] surveyornotes
char surveyornotes[Odk_type] text
char surveyornotes[Odk_or_other] 0
char surveyornotes[Odk_is_other] 0
char surveyornotes[Odk_label] DO NOT READ: please report any key information on how the interview went, including problems with survey questions. Please be sure to list all reasons for refusal to answer questions.

* Abbreviate long variable names that exceed Stata's 32 character maximum.
foreach var of varlist _all {
	if "`:char `var'[Odk_group]'" != "" {
		local name = "`:char `var'[Odk_name]'" + ///
			cond(`:char `var'[Odk_is_other]', "_other", "") + ///
			"`:char `var'[Odk_geopoint]'"
		local newvar = strtoname("`name'")
		capture rename `var' `newvar'
	}
}

* Rename any variable names that are difficult for -split-.
// rename ...

* Split select_multiple variables.
ds, has(char Odk_type)
foreach typevar in `r(varlist)' {
	if strmatch("`:char `typevar'[Odk_type]'", "select_multiple *") & ///
		!`:char `typevar'[Odk_is_other]' {
		* Add an underscore to the variable name if it ends in a number.
		local var `typevar'
		local list : char `var'[Odk_list_name]
		local pos : list posof "`list'" in labs
		local nparts : word `pos' of `nassoc'
		if `:list list in otherlabs' & !`:char `var'[Odk_or_other]' ///
			local --nparts
		if inrange(substr("`var'", -1, 1), "0", "9") & ///
			length("`var'") < 32 - strlen("`nparts'") {
			numlist "1/`nparts'"
			local splitvars " `r(numlist)'"
			local splitvars : subinstr local splitvars " " " `var'_", all
			capture confirm new variable `var'_ `splitvars'
			if !_rc {
				rename `var' `var'_
				local var `var'_
			}
		}

		capture confirm numeric variable `var', exact
		if !_rc ///
			tostring `var', replace format(%24.0g)
		split `var'
		local parts `r(varlist)'
		local next = `r(nvars)' + 1
		destring `parts', replace

		forvalues i = `next'/`nparts' {
			local newvar `var'`i'
			generate byte `newvar' = .
			local parts : list parts | newvar
		}

		local chars : char `var'[]
		local label : char `var'[Odk_label]
		local len : length local label
		local i 0
		foreach part of local parts {
			local ++i

			foreach char of local chars {
				mata: st_global("`part'[`char']", st_global("`var'[`char']"))
			}

			if `len' {
				mata: st_global("`part'[Odk_label]", st_local("label") + ///
					(substr(st_local("label"), -1, 1) == " " ? "" : " ") + ///
					"(#`i'/`nparts')")
			}

			move `part' `var'
		}

		drop `var'
	}
}

* Drop note variables.
ds, has(char Odk_type)
foreach var in `r(varlist)' {
	if "`:char `var'[Odk_type]'" == "note" ///
		drop `var'
}

* Date and time variables
capture confirm variable SubmissionDate, exact
if !_rc {
	local type : char SubmissionDate[Odk_type]
	assert !`:length local type'
	char SubmissionDate[Odk_type] datetime
}
local datetime date today time datetime start end
tempvar temp
ds, has(char Odk_type)
foreach var in `r(varlist)' {
	local type : char `var'[Odk_type]
	if `:list type in datetime' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace
			replace `var' = "" if `var' == "."
		}

		if inlist("`type'", "date", "today") {
			local fcn    date
			local mask   datemask
			local format %tdMon_dd,_CCYY
		}
		else if "`type'" == "time" {
			local fcn    clock
			local mask   timemask
			local format %tchh:MM:SS_AM
		}
		else if inlist("`type'", "datetime", "start", "end") {
			local fcn    clock
			local mask   datetimemask
			local format %tcMon_dd,_CCYY_hh:MM:SS_AM
		}
		generate double `temp' = `fcn'(`var', "``mask''")
		format `temp' `format'
		count if missing(`temp') & !missing(`var')
		if r(N) {
			display as err "{p}"
			display as err "`type' variable `var'"
			if "`repeat'" != "" ///
				display as err "in repeat group `repeat'"
			display as err "could not be converted using the mask ``mask''"
			display as err "{p_end}"
			exit 9
		}

		move `temp' `var'
		foreach char in `:char `var'[]' {
			mata: st_global("`temp'[`char']", st_global("`var'[`char']"))
		}
		drop `var'
		rename `temp' `var'
	}
}
capture confirm variable SubmissionDate, exact
if !_rc ///
	char SubmissionDate[Odk_type]

* Encode fields whose list contains a noninteger name.
local lists enumerator
tempvar temp
ds, has(char Odk_list_name)
foreach var in `r(varlist)' {
	local list : char `var'[Odk_list_name]
	if `:list list in lists' & !`:char `var'[Odk_is_other]' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace format(%24.0g)
			if !`:list list in sysmisslabs' ///
				replace `var' = "" if `var' == "."
		}
		generate `temp' = `var'

		* enumerator
		if "`list'" == "enumerator" {
			replace `temp' = "Lucy Pemba"             if `var' == "963363/11/1"
			replace `temp' = "Ireen Sinyangwe Kapisa" if `var' == "301692/66/1"
			replace `temp' = "Mambwe Kaoma"           if `var' == "789616/11/1"
			replace `temp' = "Irene Njobvu"           if `var' == "254515/53/1"
			replace `temp' = "Ngoma Edward"           if `var' == "606347/11/1"
			replace `temp' = "Conceptor Chilopa"      if `var' == "274290/82/1"
			replace `temp' = "Kate Naluyele"          if `var' == "354122/67/1"
			replace `temp' = "Mukupa Justin Bwalya"   if `var' == "952885/11/1"
			replace `temp' = "Jackson Mwewa"          if `var' == "770536/11/1"
			replace `temp' = "Muyamwa Matauka"        if `var' == "196905/10/1"
			replace `temp' = "Musa Mtonga"            if `var' == "122024/10/1"
		}

		replace `var' = `temp'
		drop `temp'
		encode `var', gen(`temp') label(`list') noextend
		move `temp' `var'
		foreach char in `:char `var'[]' {
			mata: st_global("`temp'[`char']", st_global("`var'[`char']"))
		}
		drop `var'
		rename `temp' `var'
	}
}

* Attach value labels.
ds, not(vallab)
if "`r(varlist)'" != "" ///
	ds `r(varlist)', has(char Odk_list_name)
foreach var in `r(varlist)' {
	if !`:char `var'[Odk_is_other]' {
		capture confirm string variable `var', exact
		if !_rc {
			replace `var' = ".o" if `var' == "other"
			destring `var', replace
		}

		local list : char `var'[Odk_list_name]
		if !`:list list in labs' {
			display as err "list `list' not found in choices sheet"
			exit 9
		}
		label values `var' `list'
	}
}

* select or_other variables
forvalues i = 1/`:list sizeof otherlabs' {
	local lab      : word `i' of `otherlabs'
	local otherval : word `i' of `othervals'

	ds, has(vallab `lab')
	if "`r(varlist)'" != "" ///
		recode `r(varlist)' (.o=`otherval')
}

* Attach field labels as variable labels and notes.
ds, has(char Odk_long_name)
foreach var in `r(varlist)' {
	* Variable label
	local label : char `var'[Odk_label]
	mata: st_varlabel("`var'", st_local("label"))

	* Notes
	if `:length local label' {
		char `var'[note0] 1
		mata: st_global("`var'[note1]", "Question text: " + ///
			st_global("`var'[Odk_label]"))
		mata: st_local("temp", ///
			" " * (strlen(st_global("`var'[note1]")) + 1))
		#delimit ;
		local fromto
			{			"`temp'"
			}			"{c )-}"
			"`temp'"	"{c -(}"
			'			"{c 39}"
			"`"			"{c 'g}"
			"$"			"{c S|}"
		;
		#delimit cr
		while `:list sizeof fromto' {
			gettoken from fromto : fromto
			gettoken to   fromto : fromto
			mata: st_global("`var'[note1]", ///
				subinstr(st_global("`var'[note1]"), "`from'", "`to'", .))
		}
	}
}

local repeats `"`repeats' """'

local badnames
ds, has(char Odk_bad_name)
foreach var in `r(varlist)' {
	if `:char `var'[Odk_bad_name]' & ///
		("`:char `var'[Odk_type]'" != "begin repeat" | ///
		("`repeat'" != "" & ///
		"`:char `var'[Odk_name]'" == "SET-OF-`repeat'")) {
		local badnames : list badnames | var
	}
}
local allbadnames `"`allbadnames' "`badnames'""'

ds, not(char Odk_name)
local datanotform `r(varlist)'
local exclude SubmissionDate KEY PARENT_KEY metainstanceID
local datanotform : list datanotform - exclude
local alldatanotform `"`alldatanotform' "`datanotform'""'

compress

local dta `""odkmetatest210""'
save `dta', replace
local dtas : list dtas | dta

capture mata: mata drop `values' `text'

set varabbrev `varabbrev'

* Display warning messages.
quietly {
	noisily display

	#delimit ;
	local problems
		allbadnames
			"The following variables' names differ from their field names,
			which could not be {cmd:insheet}ed:"
		alldatanotform
			"The following variables appear in the data but not the form:"
	;
	#delimit cr
	while `:list sizeof problems' {
		gettoken local problems : problems
		gettoken desc  problems : problems

		local any 0
		foreach vars of local `local' {
			local any = `any' | `:list sizeof vars'
		}
		if `any' {
			noisily display as txt "{p}`desc'{p_end}"
			noisily display "{p2colset 0 34 0 2}"
			noisily display as txt "{p2col:repeat group}variable name{p_end}"
			noisily display as txt "{hline 65}"

			forvalues i = 1/`:list sizeof repeats' {
				local repeat : word `i' of `repeats'
				local vars   : word `i' of ``local''

				foreach var of local vars {
					noisily display as res "{p2col:`repeat'}`var'{p_end}"
				}
			}

			noisily display as txt "{hline 65}"
			noisily display "{p2colreset}"
		}
	}
}
