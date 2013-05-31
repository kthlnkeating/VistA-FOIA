SDMAPI1 ;RGI/VSL - APPOINTMENT API; 5/31/13
 ;;5.3;scheduling;**260003**;08/13/93
CLNCK(RETURN,CLN) ;Check clinic for valid stop code restriction.
 ;  INPUT:   CLN   = IEN of Clinic
 ;
 ;  OUTPUT:  1 if no error or 0^error message
 N PSC,SSC,ND0,VAL,FLDS,%
 K RETURN S RETURN=0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.CLN) Q:'% 0
 D GETCLN^SDMDAL1(.FLDS,+CLN,1,0,0)
 I $G(FLDS(2))'="C" Q 1     ;not a Clinic
 S %=$$SCREST(.RETURN,FLDS(8),"P")
 Q:'% %  Q:FLDS(2503)="" 1
 S %=$$SCREST(.RETURN,FLDS(2503),"S")
 S RETURN=%
 Q RETURN
 ;
SCREST(RETURN,SCIEN,TYP) ;check stop code restriction in file 40.7 for a clinic. 
 ;  INPUT:   SCIEN = IEN of Stop Code
 ;           TYP   = Stop Code Type, Primary (P) or Secondary (S)
 ;           DIS   = Message Display, 1 - Display or 0 No Display
 ;
 ;  OUTPUT:  1 if no error, or 0^error message
 ;          
 N SCN,RTY,CTY,RDT,STR,STYP,FLDS,TEXT
 S STYP="("_$S(TYP="P":"Prim",1:"Second")_"ary)"
 K RETURN S RETURN=0
 I +SCIEN<1 S TEXT(1)=STYP D ERRX^SDAPIE(.RETURN,"CLNSCIN",.TEXT) Q 0
 S CTY=$S(TYP="P":"^P^E^",1:"^S^E^")
 D GETCSC^SDMDAL1(.FLDS,+SCIEN)
 S RTY=$G(FLDS(5)),RDT=$G(FLDS(6))
 I RTY="" D  Q 0
 . S TEXT(1)=$G(FLDS(1)),TEXT(2)=STYP
 . D ERRX^SDAPIE(.RETURN,"CLNSCNR",.TEXT)
 I CTY'[("^"_RTY_"^") D  Q 0
 . S TEXT(1)=$G(FLDS(1)),TEXT(2)=$S(TYP="P":"Prim",1:"Second")_"ary"
 . D ERRX^SDAPIE(.RETURN,"CLNSCPS",.TEXT)
 I RDT>DT D  Q 0
 . S TEXT(1)=$G(FLDS(1)),TEXT(2)=$$FMTE^XLFDT(RDT,"1F"),TEXT(3)=STYP
 . D ERRX^SDAPIE(.RETURN,"CLNSCRD",.TEXT)
 S RETURN=1
 Q 1
 ;
GETCLN(RETURN,SC) ; Get Clinic data
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;      RETURN(field_name)=internal^external
 ;   SC [Required,Numeric] Clinic IEN (pointer to File 44)
 ;Output:
 ;  1=Success,0=Failure
 N % K RETURN
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 D GETCLN^SDMDAL1(.RETURN,+SC,1,1,1)
 S RETURN=1
 Q 1
 ;
LSTCLNS(RETURN,SEARCH,START,NUMBER) ; Return clinics filtered by name.
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;      RETURN [Boolean] 1=success, 0=failure
 ;      RETURN(#,"ID") [Numeric] Clinic IEN
 ;      RETURN(#,"NAME") [String] Clinic name
 ;   SEARCH [Optional,String] Partial match restriction. Default: All entries
 ;  .START [Optional,String] The clinic name from which to begin the list.
 ;   NUMBER [Optional,Numeric] Number of entries to return. Default: All entries
 ;Output:
 ;  1=Success,0=Failure
 N LST K RETURN S RETURN=0
 D LSTCLNS^SDMDAL1(.LST,$G(SEARCH),.START,$G(NUMBER))
 D BLDLST^SDMAPI(.RETURN,.LST)
 S RETURN=1
 Q 1
 ;
CLNRGHT(RETURN,CLN) ; Verifies (DUZ) user access to Clinic
 N DATA,TXT,%
 K RETURN S RETURN=0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.CLN) Q:'% 0
 D GETCLN^SDMDAL1(.DATA,+CLN,1)
 I DATA(2500)="Y"  D  Q RETURN
 . I $D(DATA(2501,DUZ,.01))>0 S RETURN=1 Q
 . E  D
 . . S RETURN=0 S TXT(1)=DATA(.01),TXT(2)=" "
 . . D ERRX^SDAPIE(.RETURN,"CLNURGT",.TXT)
 . . S RETURN("CLN")=DATA(.01)
 S RETURN=1
 Q 1
 ;
GETSCAP(RETURN,SC,DFN,SD) ; Get clinic appointment
 N NOD0,CO,%
 K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 I +$G(SD)=0 S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","SD") Q 0
 D GETSCAP^SDMDAL1(.RETURN,+SC,+DFN,+SD)
 I $D(RETURN)>1 D
 . S NOD0=RETURN(0),CO=$G(RETURN("C"))
 . S RETURN("IFN")=RETURN
 . S RETURN("USER")=$P(NOD0,U,6)
 . S RETURN("DATE")=$P(NOD0,U,7)
 . S RETURN("CHECKOUT")=$P(CO,U,3)
 . S RETURN("CHECKIN")=$P(CO,U,1)
 . S RETURN("LENGTH")=$P(NOD0,U,2)
 . S RETURN("CONSULT")=$P($G(RETURN("CONS")),U)
 S RETURN=1
 Q 1
 ;
GETAPT(RETURN,DFN,SD) ; Get appointment
 S FLDS=".01;1;3;9;10;30;309;302;303;304;306;222;333;444;555"
 S NAMES="PATIENT;LENGTH;OTHER;OVERBOOK;RQXRAY;EVISIT;CIDT;"
 S NAMES=NAMES_"CIUSER;CODT;COUSER;COENTER;222;333;RQXRAY;CONSULT"
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;		RETURN [Boolean] Set to 1 if the the call succeeded, 0 otherwise
 ;		RETURN("CLINIC") [String] Clinic (pointer to file 44) (I^E)
 ;		RETURN("STATUS") [String] Appointment status (I^E)
 ;		RETURN("LABDT")	[String] The date/time the patient should report for LAB tests (I^E)
 ;		RETURN("XRAYDT") [String] The date/time the patient should report for XRAY tests (I^E)
 ;		RETURN("EKGDT") [String] The date/time the patient should report for EKG tests (I^E)
 ;		RETURN("PURPOSE") [String] One of: 1^C&P, 2^10-10, 3^SCHEDULED VISIT, 4^UNSCHED. VISIT
 ;		RETURN("ARBK") [String] Auto-rebooked appt. date/time (I^E)
 ;		RETURN("CVISIT") [String] Collateral visit flag. Empty or 1^YES 
 ;		RETURN("NOSHOWBY") [String] The date/time the no-show was cancelled (I^E)
 ;		RETURN("NOSHOWDT") [String] The user who cancelled the no-show (pointer to file 200) (I^E)
 ;		RETURN("CREASON") [String] Cancellation reason (pointer to file 409.2) (I^E)
 ;		RETURN("TYPE") [String] Type of appointment (pointer file 409.1) (I^E)
 ;		RETURN("CREMARKS") [String] Cancellation remarks
 ;		RETURN("ENTRY") [String] User who made appointment (pointer to file 200) (I^E)
 ;		RETURN("MADEDT") [String] The date the appointment was entered into the scheduling system (I^E)
 ;		RETURN("OE") [String] Outpatient encounter created from this appointment (pointer to file 409.68) (I^E)
 ;		RETURN("RTYPE") [String] One of: N^'NEXT AVAILABLE' APPT., C^OTHER THAN 'NEXT AVA.' (CLINICIAN REQ.),
 ;                               P^OTHER THAN 'NEXT AVA.' (PATIENT REQ.), W^WALKIN APPT., M^MULTIPLE APPT. BOOKING,
 ;                               A^AUTO REBOOK, O^OTHER THAN 'NEXT AVA.' APPT.
 ;		RETURN("NEXTA") [String] One of: 0^NOT INDICATED TO BE A 'NEXT AVA.' APPT., 1^'NEXT AVA.' APPT. INDICATED BY USER,
 ;                               2^'NEXT AVA.' APPT. INDICATED BY CALCULATION, 3^'NEXT AVA.' APPT. INDICATED BY USER & CALCULATION
 ;		RETURN("DDATE") [String] Desired date of appointment (I^E)
 ;		RETURN("FVISIT") [String] One of: 0^NO, 1^YES
 ;		RETURN("PATIENT") [String] Patient (pointer to file 2) (I^E)
 ;		RETURN("LENGTH") [Numeric]Appointment length (minutes)
 ;		RETURN("OTHER") [String] Other observations
 ;		RETURN("OVERBOOK") [String] O^OVERBOOK if this appointment was an overbook, empty otherwise
 ;		RETURN("RQXRAY") [String] Y^YES if prior x-ray results are required to be sent to clinic, empty otherwise
 ;		RETURN("EVISIT") [String] Eligibility of visit (pointer to file 8) (I^E)
 ;		RETURN("CIDT") [String] Check in date (I^E)
 ;		RETURN("CIUSER") [String] Check in user (pointer to file 200) (I^E)
 ;		RETURN("CODT") [String] Check out date (I^E)
 ;		RETURN("COUSER") [String] Check out user (pointer to file 200) (I^E)
 ;		RETURN("COENTER") [String] Date and time that the check out was entered (I^E)
 ;		RETURN("CONSULT") [Numeric] Consult associated with this appointment (pointer to REQUEST/CONSULTATION FILE <#123>)
 ;   DFN [Required,Numeric] Patient IEN
 ;   SD [Required,DateTime] Appointment date/time
 ;Output:
 ;  1=Success,0=Failure
 N NOD0,CO,%,PAPT,CAPT
 K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 I '$$DTIME^SDCHK(.RETURN,.SD,"SD") S RETURN=0 Q 0
 S %=$$GETPAPT^SDMAPI4(.PAPT,+DFN,+SD)
 S %=$$GETCAPT^SDMAPI4(.CAPT,+DFN,+SD)
 M RETURN=PAPT,RETURN=CAPT
 S RETURN=1
 Q 1
 ;
SLOTS(RETURN,SC) ; Get available slots
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;      RETURN [Boolean] 1=success,0=failure
 ;      RETURN(0) [Numeric] Hour, clinic display begins (this is the starting point of each line in the availability pattern)
 ;      RETURN(DATE,1) [String] Availability string
 ;   SC [Required,Numeric] Clinic IEN (pointer to File 44)
 ;Output:
 ;  1=Success,0=Failure
 N % K RETURN
 S RETURN=0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 D SLOTS^SDMDAL2(.RETURN,+SC)
 S RETURN=1
 Q 1
 ;
LSTAPPT(RETURN,SEARCH,START,NUMBER) ; Lists appointment types
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN(0) � [String] # of entries found^maximum requested^any more?^flags
 ;    RETURN(#,"ID") � [Numeric] Appointment type IEN
 ;    RETURN(#,"NAME") � [String] Appointment type name
 ;   SEARCH [Optional,String] Partial match restriction. Default: All entries
 ;   START [Optional,String] The appointment type name from which to begin the list. Default: ""
 ;   NUMBER [Optional,Numeric] Number of entries to return. Default: All entries
 ;Output:
 ;  1=Success,0=Failure
 N RET,DL,IN
 S:'$D(START) START="" S:'$D(SEARCH) SEARCH=""
 S:'$G(NUMBER) NUMBER=""
 K RETURN S RETURN=0
 D LSTAPPT^SDMDAL2(.RET,$$UP^XLFSTR(SEARCH),.START,NUMBER)
 S RETURN(0)=RET("DILIST",0)
 S DL="DILIST"
 F IN=1:1:$P(RETURN(0),U,1) D
 . S RETURN(IN,"ID")=RET(DL,2,IN)
 . S RETURN(IN,"NAME")=RET(DL,"ID",IN,".01")
 S RETURN=1
 Q 1
 ;
GETAPPT(RETURN,TYPE) ; Returns Appointment Type detail
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN("NAME") � [String] Appointment type name
 ;    RETURN("NUMBER") � [Numeric] Appointment type IEN
 ;    RETURN("SYNONIM") � [String] Appointment type synonim
 ;   TYPE [Required,Numeric] Appointment type IEN (File 409.1)
 ;Output:
 ;  1=Success,0=Failure
 K RETURN S RETURN=0
 I +$G(TYPE)=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","TYPE") Q 0
 I '$$TYPEXST^SDMDAL3(+TYPE) D ERRX^SDAPIE(.RETURN,"TYPNFND") Q 0
 D GETAPPT^SDMDAL2(.RETURN,TYPE,1,1,1)
 S RETURN=1
 Q 1
 ;
GETELIG(RETURN,ELIG) ; Returns Eligibility Code detail
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN("ABBREVIATION") [String] Eligibility Code abbreviation
 ;    RETURN("MAS ELIGIBILITY CODE") [Numeric]
 ;    RETURN("NAME") [String] Eligibility Code name
 ;    RETURN("PRINT NAME") [String] Eligibility Code print name
 ;    RETURN("TYPE") [String] Eligibility Code type (N:NON VETERAN,Y:VETERAN)
 ;    RETURN("VA CODE NUMBER") [Numeric] VA Code Number
 ;    RETURN("INACTIVE") [Boolean] Eligibility Code status
 ;   ELIG [Required,Numeric] Eligibility code IEN
 ;Output:
 ;  1=Success,0=Failure
 K RETURN S RETURN=0
 I +$G(ELIG)=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","ELIG") Q 0
 D GETELIG^SDMDAL2(.RETURN,ELIG,1,1,1)
 S RETURN=1
 Q 1
 ;
GETPEND(RETURN,DFN) ; Get pending appointments
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data
 ;                           Set to Error description if the call fails
 ;      RETURN [Numeric] Number of entries returned
 ;      RETURN(APPTDT,"APPOINTMENT TYPE") - [Numeric] Type of appointment
 ;      RETURN(APPTDT,"CLINIC") - [Numeric] Clinic
 ;      RETURN(APPTDT,"COLLATERAL VISIT") - [Boolean] Collateral visit
 ;      RETURN(APPTDT,"CONSULT LINK") - [Numeric]
 ;      RETURN(APPTDT,"EKG DATE/TIME") - [DateTime]
 ;      RETURN(APPTDT,"LAB DATE/TIME") - [DateTime]
 ;      RETURN(APPTDT,"LENGTH OF APP'T") - [Numeric] Length of appointment
 ;      RETURN(APPTDT,"X-RAY DATE/TIME") - [DateTime]
 ;   DFN [Required,Numeric] Patient IEN (pointer to File 2)
 ;Output:
 ;  1=Success,0=Failure
 N CNT,SCAP,APP,CLN,%,TOT
 K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S CNT="",TOT=0
 D GETPEND^SDMDAL2(.APP,+DFN,$$DT^XLFDT())
 F  S CNT=$O(APP(CNT)) Q:CNT=""  D
 . S TOT=TOT+1
 . S RETURN(CNT,"COLLATERAL VISIT")=APP(CNT,13)
 . S RETURN(CNT,"APPOINTMENT TYPE")=$$APTYNAME^SDMDAL2(APP(CNT,9.5))
 . S RETURN(CNT,"LAB")=APP(CNT,2)
 . S RETURN(CNT,"XRAY")=APP(CNT,3)
 . S RETURN(CNT,"EKG")=APP(CNT,4)
 . S %=$$GETCLN^SDMAPI1(.CLN,APP(CNT,.01))
 . S RETURN(CNT,"CLINIC")=$P(CLN("NAME"),U)
 . S %=$$GETSCAP^SDMAPI1(.SCAP,APP(CNT,.01),+DFN,CNT)
 . S RETURN(CNT,"LENGTH OF APP'T")=$G(SCAP("LENGTH"))
 . S RETURN(CNT,"CONSULT LINK")=$G(SCAP("CONSULT"))
 S RETURN=TOT
 Q 1
 ;
GETAPTS(RETURN,DFN,SD) ; Get patient appointments
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data
 ;                           Set to Error description if the call fails
 ;      RETURN("APT",date,field_name)=internal^external
 ;   DFN [Required,Numeric] Patient IEN (pointer to File 2)
 ;   SD [Optional,DateTime] - if not set returns all patient appointments.
 ;      - If SD is set to a valid date-time returns the corresponding appointment.
 ;      - If SD(0) is set (0/1) returns patient appointments before/after specified date (SD).
 ;Output:
 ;  1=Success,0=Failure
 N %,TXT,CA,IN K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S RETURN=0
 I '$$DTIME^SDCHK(.RETURN,.SD,"SD",1) Q 0
 I $G(SD(0))'="",$S($G(SD(0))=0:0,$G(SD(0))=1:0,1:1) S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","SD(0)") Q 0
 D GETAPTS^SDMDAL2(.RETURN,+DFN,.SD)
 F IN=0:0 S IN=$O(RETURN("APT",IN)) Q:'IN  D
 . S %=$$GETCAPT^SDMAPI5(.CA,+DFN,+IN) M RETURN("APT",IN)=CA
 S RETURN=($D(RETURN)>0)
 Q 1
 ;
LSTCRSNS(RETURN,SEARCH,START,NUMBER) ; Return cancelation reasons.
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN(0) � [String] # of entries found^maximum requested^any more?^flags
 ;    RETURN(#,"ID") � [Numeric] Cancellation reason IEN
 ;    RETURN(#,"NAME") � [String] Cancellation reason name
 ;   SEARCH [Optional,String] Partial match restriction. Default: All entries
 ;   START [Optional,String] The appointment type name from which to begin the list. Default: ""
 ;   NUMBER [Optional,Numeric] Number of entries to return. Default: All entries
 ;Output:
 ;  1=Success,0=Failure
 N LST
 M LST=RETURN
 D LSTCRSNS^SDMDAL2(.LST,$$UP^XLFSTR($G(SEARCH)),.START,$G(NUMBER))
 K RETURN
 D BLDLST^SDMAPI(.RETURN,.LST)
 S RETURN=1
 Q RETURN
 ;
FRSTAVBL(RETURN,SC) ; Get first available date
 ;Input:
 ;  .RETURN [Required,DateTime] Passed by reference, set to the first available date.
 ;                              Set to Error description if the call fails
 ;   SC [Required,Numeric] Clinic IEN (pointer to File 44)
 ;Output:
 ;  1=Success,0=Failure
 N % K RETURN S RETURN=0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 F I=0:1:6 S SD=$$FMADD^XLFDT($$DT^XLFDT(),I),%=$$SETST^SDMAPI5(.RETURN,+SC,SD) Q:RETURN
 D FRSTAVBL^SDMDAL2(.RETURN,+SC,$$FMADD^XLFDT($$DT^XLFDT(),,,,-1))
 Q 1
 ;
LSTAGRP(RETURN) ; Returns appointment groups
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;      RETURN [Boolean] 1=success, 0=failure
 ;      RETURN(#,"ID") [Numeric] Appointment group IEN
 ;      RETURN(#,"NAME") [String] Appointment group name
 ;      RETURN(#,"TITLE") [String] Appointment group title
 ;Output:
 ;  1=Success,0=Failure
 N LST,FLDS K RETURN S RETURN=0
 D LSTAGRP^SDMDAL1(.LST)
 S FLDS(.02)="TITLE"
 D BLDLST^SDMAPI(.RETURN,.LST,.FLDS)
 S RETURN=1
 Q 1
 ;
LSTCAPTS(RETURN,SC,SDBEG,SDEND,STAT) ; Returns clinic appointments filtered by date and status
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;      RETURN [Boolean] 1=success, 0=failure
 ;      RETURN(#,"BID") [Numeric] Last 4 digits of the patient SSN
 ;      RETURN(#,"CIDT") [DateTime] Check-in date (internal format)
 ;      RETURN(#,"CLINIC") [String] Clinic (pointer to file 44) (I^E)
 ;      RETURN(#,"CODT") [DateTime] Check-out date (internal format)
 ;      RETURN(#,"DATE") [DateTime] Appointment date (internal format)
 ;      RETURN(#,"EKG") [DateTime] EKG tests date/time (internal format)
 ;      RETURN(#,"LAB") [DateTime] LAB tests date/time (internal format)
 ;      RETURN(#,"LEN") [Numeric] Appointment length (minutes)
 ;      RETURN(#,"OE") [Numeric] Outpatient encounter IEN (pointer to file 409.68)
 ;      RETURN(#,"PATIENT") [String] Patient (pointer to file 2) (I^E)
 ;      RETURN(#,"STAT") [String] appt status ifn ^ status name ^ print status ^
 ;                        check in d/t ^ check out d/t ^ adm mvt ifn
 ;      RETURN(#,"XRAY") [DateTime] XRAY tests date/time (internal format)
 ;   SC [Required,Numeric] Clinic IEN (pointer to file 44)
 ;   SDBEG [Required,DateTime] Start date
 ;   SDEND [Required,DateTime] End date
 ;   STAT [Required,Numeric] Appointment group IEN (pointer to file 409.62)
 ;Output:
 ;  1=Success,0=Failure
 N APTS,FAPTS,GROUPS,%,GRP
 K RETURN S RETURN=0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 S:$G(STAT)="" STAT=6
 S GRP=$$GETGRP^SDMDAL1($G(STAT))
 I GRP="" S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","STAT") Q 0
 D GROUP^SDAM($P(GRP,U),.GROUPS)
 S:'$D(SDBEG) SDBEG=1 S:'$D(SDEND) SDEND=99999999
 D LSTCAPTS^SDMDAL1(.APTS,+SC,+SDBEG,+SDEND)
 D BLDAPTS(.RETURN,.APTS,+SC,,.GROUPS)
 S RETURN=1
 Q 1
 ;
LSTPAPTS(RETURN,DFN,SDBEG,SDEND,STAT) ; Returns patient appointments filtered by date and status
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;      See LSTCAPTS^SDMAPI1 for detailed RETURN format
 ;   DFN [Required,Numeric] Patient IEN (pointer to file 2)
 ;   SDBEG [Required,DateTime] Start date
 ;   SDEND [Required,DateTime] End date
 ;   STAT [Required,Numeric] Appointment group IEN (pointer to file 409.62)
 ;Output:
 ;  1=Success,0=Failure
 N APTS,FAPTS,GROUPS,%,GRP
 K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S:$G(STAT)="" STAT=6
 S GRP=$$GETGRP^SDMDAL1($G(STAT))
 I GRP="" S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","STAT") Q 0
 D GROUP^SDAM($P(GRP,U),.GROUPS)
 S:'$D(SDBEG) SDBEG=DT S:'$D(SDEND) SDEND=99999999
 D LSTPAPTS^SDMDAL1(.APTS,+DFN,+SDBEG,+SDEND)
 D BLDAPTS(.RETURN,.APTS,,+DFN,.GROUPS)
 S RETURN=1
 Q 1
 ;
BLDAPTS(RETURN,APTS,SSC,SDFN,GROUPS) ; Build appointment list
 N IND,DFN,SC,VA,VADM,CDATA,SDATA,SDDA,SDSTAT,CAPT,PAPT,SD,CNT
 K RETURN S RETURN=0
 S CNT=0
 F IND=0:0 S IND=$O(APTS(IND)) Q:IND=""  D
 . S SDATA=APTS(IND,"SDATA")
 . Q:'$G(SDFN)&($P(SDATA,U,2)["C")
 . S DFN=$S('$G(SDFN):+APTS(IND,"CDATA"),1:SDFN)
 . S SD=APTS(IND,"SD")
 . S SC=$S('$G(SSC):APTS(IND,"SC"),1:SSC)
 . S SDDA=APTS(IND,"SDDA")
 . S CDATA=$G(APTS(IND,"CDATA"))
 . S SDSTAT=$$STATUS^SDAM1(DFN,SD,SC,SDATA,$S($D(SDDA):SDDA,1:""))
 . F  S SDSTAT=$P(SDSTAT,";")_U_$P(SDSTAT,";",2,99)  Q:SDSTAT'[";"
 . Q:'$$CHK^SDAM1(DFN,SD,SC,,.GROUPS,SDSTAT)
 . Q:$G(SSC)&(($P(CDATA,U,9)="C")!($P(SDATA,U,2)["C")&($G(SC)))
 . S CNT=CNT+1
 . D 2^VADPT
 . S RETURN(CNT,"BID")=VA("BID")
 . D GETPAPT^SDMDAL4(.PAPT,DFN,SD)
 . S RETURN(CNT,"GAF")=$$GAFREQ(DFN,SC,$P(SDATA,U,11))
 . S RETURN(CNT,"DATE")=SD
 . S RETURN(CNT,"STAT")=SDSTAT
 . S RETURN(CNT,"STATI")=PAPT(3,"I")
 . S RETURN(CNT,"OE")=PAPT(21,"I")
 . S RETURN(CNT,"PATIENT")=DFN_U_VADM(1)
 . S RETURN(CNT,"LAB")=$P(SDATA,U,3)
 . S RETURN(CNT,"XRAY")=$P(SDATA,U,4)
 . S RETURN(CNT,"EKG")=$P(SDATA,U,5)
 . D GETCAPT^SDMDAL4(.CAPT,DFN,SD)
 . S RETURN(CNT,"LEN")=$G(CAPT(1))
 . S RETURN(CNT,"CIDT")=$G(CAPT(309,"I"))
 . S RETURN(CNT,"CODT")=$G(CAPT(303,"I"))
 . S RETURN(CNT,"CLINIC")=SC_U_PAPT(.01,"E")
 . S:$G(APTS(IND,"CONS"))>0 RETURN(CNT,"CSTAT")=$$CNSSTAT^SDMEXT(APTS(IND,"CONS"))
 S RETURN=1
 Q
 ;
GAFREQ(DFN,SC,CVSIT) ;
 N SDELIG,SDGAF,SDGAFST
 S SDELIG=$$ELSTAT^SDUTL2(+DFN)
 I $$MHCLIN^SDUTL2(+SC),'($$COLLAT^SDUTL2(SDELIG)!$G(CVSIT)) D  Q SDGAFST
 . S SDGAF=$$NEWGAF^SDUTL2(+DFN),SDGAFST=$P(SDGAF,"^") Q
 Q 0
 ;
GETCSC(RETURN,CSC) ; Get clinic stop code
 ;Input:
 ;  .RETURN [Required,Boolean] Set to 1 if the patient has pending appointments
 ;                             Set to Error description if the call fails
 ;      RETURN("ID") [Numeric] Clinic stop code IEN (pointer to file 40.7)
 ;      RETURN("NAME") [String] Clinic stop code name
 ;      RETURN("AMIS") [Numeric] AMIS reporting stop code
 ;      RETURN("IDT") [DateTime] Inactive date
 ;   CSC [Required,Numeric] Clinic stop code IEN (pointer to File 40.7)
 ;Output:
 ;  1=Success,0=Failure
 N %,CS
 K RETURN S RETURN=0
 I '$G(CSC) D ERRX^SDAPIE(.RETURN,"INVPARAM","CSC") Q 0
 D GETCSC^SDMDAL1(.CS,+CSC)
 I '$D(CS) S TEXT(1)=+CSC D ERRX^SDAPIE(.RETURN,"CLNSCIN",.TEXT) Q 0
 S RETURN("ID")=+CSC
 S RETURN("NAME")=CS(.01)
 S RETURN("AMIS")=CS(1)
 S RETURN("IDT")=CS(2)
 S RETURN=1
 Q 1
 ;
CPAIR(RETURN,SC) ;Validate primary stop code, get credit pair
 ;Input: SC=HOSPITAL LOCATION record IFN
 ;Input: RETURN=variable to return clinic credit pair (pass by reference)
 ;Output: 1=success, 0=invalid primary stop code
 N SDSSC,CLN,CS
 K RETURN S RETURN=0
 D GETCLN^SDMDAL1(.CLN,+SC,1)
 D GETCSC^SDMDAL1(.CS,CLN(8))
 S RETURN=$G(CS(1)),RETURN=$S(RETURN<100:0,RETURN>999:0,1:RETURN)
 Q:RETURN'>0 0
 K CS D GETCSC^SDMDAL1(.CS,CLN(2503))
 S SDSSC=$G(CS(1)),RETURN=RETURN_$S(SDSSC<100:"000",SDSSC>999:"000",1:SDSSC)
 Q 1
 ;
PTFU(RETURN,DFN,SC)    ;Determine if this is a follow-up (return to clinic within 24 months)
 ;Input: DFN=patient ifn
 ;Input: SC=clinic ifn
 ;Output: '1' if seen within 24 months, '0' otherwise
 ;
 N % K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 S RETURN=0
 N SDBDT,SDT,SDX,SDY,SDZ,SDCP,SDCP1,SC0,SDENC,SDCT,LST,ENC,FLDS
 ;set up variables
 S SDBDT=(DT-20000)+.24,SDT=DT_.999999,SDY=0
 S SDX=$$CPAIR(.SDCP,+SC)  ;get credit pair for this clinic
 ;Iterate through encounters
 D LSTAENC^SDMDAL1(.LST,+DFN)
 S FLDS(.04)="CLINIC",FLDS(.06)="PARENT"
 D BLDLST^SDMAPI(.ENC,.LST,.FLDS)
 F  S SDT=$O(ENC(SDT),-1) Q:'SDT!SDY  D
 . Q:ENC(SDT,"PARENT")]""  ;parent encounters only
 . Q:ENC(SDT,"NAME")<SDBDT
 . S SDX=$$CPAIR(.SDCP1,ENC(SDT,"CLINIC"))  ;get credit pair for encounter
 . S SDY=SDCP=SDCP1  ;compare credit pairs
 . Q
 Q SDY
 ;
HASPEND(RETURN,DFN) ; Check if patient has panding appointments
 ;Input:
 ;  .RETURN [Required,Boolean] Set to 1 if the patient has pending appointments
 ;                             Set to Error description if the call fails
 ;   DFN [Required,Numeric] Patient IEN (pointer to File 2)
 ;Output:
 ;  1=Success,0=Failure
 N % K RETURN
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 Q $$HASPEND^SDMDAL2(.RETURN,+DFN,$$DT^XLFDT())
 ;
LSTSRT(RETURN) ;List scheduling request types
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN(0) � [Numeric] # of entries found
 ;    RETURN(#) � [String] code^display_name
 ;Output:
 ;  1=Success,0=Failure
 K RETURN
 S RETURN=1
 D LSTSCOD^SDMDAL(2.98,25,.RETURN)
 Q 1
 ;
LSTAPPST(RETURN) ;List appointment statuses
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN(0) � [Numeric] # of entries found
 ;    RETURN(#) � [String] code^display_name
 ;Output:
 ;  1=Success,0=Failure
 K RETURN
 S RETURN=1
 D LSTSCOD^SDMDAL(2.98,3,.RETURN)
 Q 1
 ;
LSTHLTP(RETURN) ;List hospital location types
 ;Input:
 ;  .RETURN [Required,Array] Array passed by reference that will receive the data.
 ;                           Set to Error description if the call fails
 ;    RETURN(0) � [Numeric] # of entries found
 ;    RETURN(#) � [String] code^display_name
 ;Output:
 ;  1=Success,0=Failure
 K RETURN
 S RETURN=1
 D LSTSCOD^SDMDAL(44,2,.RETURN)
 Q 1
 ;
