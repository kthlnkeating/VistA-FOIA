DGPMAPI6 ;RGI/VSL - FACILITY TRATING SPECIALTY API; 8/26/13
 ;;5.3;Registration;**260005**;
CHKADD(RETURN,PARAM,PC) ; 
 N % K RETURN S RETURN=1
 ; facility treating specialty
 S:'$G(PC) %=$$CHKFTS^DGPMAPI6(.RETURN,$G(PARAM("FTSPEC")),PARAM("DATE")) Q:'RETURN 0
 ;attender
 S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("ATNDPHY")),PARAM("DATE"),"PARAM(""ATNDPHY"")") Q:'RETURN 0
 ; primary physician
 I $G(PARAM("PRYMPHY"))'=""&($G(PARAM("PRYMPHY"))'="^") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("PRYMPHY")),PARAM("DATE"))
 Q 1
 ;
CHKUPD(RETURN,PARAM,MFN,OLD,NEW,PC) ; 
 N %,I,OLD
 K RETURN S RETURN=1
 S %=$$GETMVT^DGPMAPI8(.OLD,MFN)
 S PARAM("PATIENT")=OLD("PATIENT")
 ; facility treating specialty
 I '$G(PC),$G(PARAM("FTSPEC"))'="",+OLD("FTSPEC")'=+PARAM("FTSPEC") D  Q:'RETURN 0
 . S %=$$CHKFTS^DGPMAPI6(.RETURN,$G(PARAM("FTSPEC")),PARAM("DATE")) Q:'RETURN
 . S NEW("FTSPEC")=+PARAM("FTSPEC")
 ;attender
 I $G(PARAM("ATNDPHY"))'="",+OLD("ATNDPHY")'=+PARAM("ATNDPHY") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("ATNDPHY")),PARAM("DATE"),"PARAM(""ATNDPHY"")") Q:'RETURN
 . S NEW("ATNDPHY")=+PARAM("ATNDPHY")
 ; primary physician
 I $G(PARAM("PRYMPHY"))'="",+OLD("PRYMPHY")'=+PARAM("PRYMPHY") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("PRYMPHY")),PARAM("DATE")) Q:'RETURN
 . S NEW("PRYMPHY")=+PARAM("PRYMPHY")
 ; diagosis
 I $D(PARAM("DIAG")) D
 . N CH S CH=0
 . F I=0:0 S I=$O(PARAM("DIAG",I)) Q:'I  S:PARAM("DIAG",I)'=$G(OLD("DIAG",I)) CH=1 S NEW("DIAG",I)=PARAM("DIAG",I)
 . K:'CH NEW("DIAG")
 S RETURN=($D(NEW)>0)
 Q 1
 ;
CHKFTS(RETURN,FTS,DATE) ; Check FTS
 N TMP,TXT K RETURN S RETURN=0
 I $G(FTS)="" S TXT(1)="PARAM(""FTSPEC"")" D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETFTS^DGPMDAL2(.TMP,+FTS,".01;100*") I TMP=0 D ERRX^DGPMAPIE(.RETURN,"FTSNFND") Q 0
 I $D(TMP("E")),'$$ISFTSACT^DGPMAPI9(.TMP,+DATE) D ERRX^DGPMAPIE(.RETURN,"FTSINAC") Q 0
 S RETURN=1
 Q 1
 ;
CHKPROV(RETURN,PROV,DATE,TXT) ; Check provider
 N TMP K RETURN S RETURN=0
 I $G(PROV)="" S TXT(1)=TXT D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETPROV^DGPMDAL2(.TMP,+PROV)
 I TMP=0 D ERRX^DGPMAPIE(.RETURN,"PROVNFND") Q 0
 I '$$SCREEN^DGPMDD(+PROV,,+DATE) D  Q 0
 . S TXT(1)=$G(TMP(.01,"E")) D ERRX^DGPMAPIE(.RETURN,"PROVINAC",.TXT)
 S RETURN=1
 Q 1
 ;
CHKUDT(RETURN,MFN,DGDT,OLD,NEW) ; Check date
 N %
 S %=$$CHKUDT^DGPMAPI2(.RETURN,MFN,$G(DGDT),.OLD,.NEW) Q:'RETURN 0
 Q 1
 ;
UPDPC(RETURN,PARAM,MFN) ; Update provider change
 ;Input:
 ;  .RETURN [Required,Numeric] Set to 1 if the operation succeeds
 ;                             Set to Error description if the call fails
 ;  .PARAM [Optional,Array] Array passed by reference that holds the new data.
 ;      PARAM("DATE") [Optional,DateTime] Provider change date
 ;      PARAM("ATNDPHY") [Optional,Numeric] Attending physician IEN (pointer to the New Person file #200)
 ;      PARAM("PRYMPHY") [Optional,Numeric] Primary physician IEN (pointer to the New Person file #200)
 ;      PARAM("DIAG") [Optional,Array] Array of detailed diagnosis description.
 ;         PARAM("DIAG",n) [Optional,String] Detailed diagnosis description.
 ;   MFN [Required,Numeric] Provider change movement IEN to update (pointer to the Patient Movement file #405)
 ;Output:
 ;  1=Success,0=Failure
 Q $$UPDFTS1(.RETURN,.PARAM,.MFN,1)
 ;
UPDFTS(RETURN,PARAM,MFN) ; Update facility treating movement
 ;Input:
 ;  .RETURN [Required,Numeric] Set to 1 if the operation succeeds
 ;                             Set to Error description if the call fails
 ;  .PARAM [Optional,Array] Array passed by reference that holds the new data.
 ;      PARAM("DATE") [Optional,DateTime] Facility treating movement date
 ;      PARAM("ATNDPHY") [Optional,Numeric] Attending physician IEN (pointer to the New Person file #200)
 ;      PARAM("FTSPEC") [Optional,Numeric] Facility treating specialty IEN (pointer to the Facility Treating Specialty file #45.7)
 ;      PARAM("PRYMPHY") [Optional,Numeric] Primary physician IEN (pointer to the New Person file #200)
 ;      PARAM("DIAG") [Optional,Array] Array of detailed diagnosis description.
 ;         PARAM("DIAG",n) [Optional,String] Detailed diagnosis description.
 ;   MFN [Required,Numeric] Facility treating movement IEN to update (pointer to the Patient Movement file #405)
 ;Output:
 ;  1=Success,0=Failure
 Q $$UPDFTS1(.RETURN,.PARAM,.MFN)
 ;
UPDFTS1(RETURN,PARAM,MFN,PC) ; Update specialty transfer
 N %,OLD,NEW,DFN,TXT
 K RETURN S RETURN=0
 S %=$$GETMVT^DGPMAPI8(.OLD,+$G(MFN))
 I OLD=0 S TXT(1)=$$EZBLD^DIALOG(4070000.01_(6+$G(PC))) D ERRX^DGPMAPIE(.RETURN,"MVTNFND",.TXT) Q 0
 S %=$$CHKUDT(.RETURN,MFN,$G(PARAM("DATE")),.OLD,.NEW)
 S:RETURN %=$$CHKUPD(.RETURN,.PARAM,.MFN,.OLD,.NEW,$G(PC))
 I RETURN=0 S:'$D(RETURN(0)) RETURN=1 Q $S('$D(RETURN(0)):1,1:0)
 S DFN=$P(OLD("PATIENT"),U)
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$UPD(.RETURN,.PARAM,MFN,.OLD,.NEW,1)
 S %=$$UPDPAT^DGPMAPI9(,.PARAM,DFN,,1)
 D EVT(DFN,+MFN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
UPD(RETURN,PARAM,MFN,OLD,NEW,QUIET) ; Update facility treating specialty
 N %,MVT,DIAG,DGQUIET
 S:$G(QUIET) DGQUIET=1
 K RETURN S RETURN=0
 D SETREVT^DGPMDAL1(MFN,"P")
 S:+$G(NEW("DATE")) MVT(.01)=+NEW("DATE")  ; date
 S:+$G(NEW("PRYMPHY")) MVT(.08)=+NEW("PRYMPHY")  ; primary physician
 S:$D(NEW("FTSPEC")) MVT(.09)=+NEW("FTSPEC")   ; facility treating specialty
 S:$D(NEW("ATNDPHY")) MVT(.19)=+NEW("ATNDPHY")  ; attending physician
 D UPDMVT^DGPMDAL1(.RETURN,.MVT,MFN)
 M DIAG=PARAM("DIAG")
 D UPDDIAG^DGPMDAL1(.RETURN,.DIAG,MFN)
 D SETREVT^DGPMDAL1(MFN,"A")
 Q 1
 ;
CHKDT(RETURN,PARAM) ;
 N %
 S %=$$CHKDT^DGPMAPI2(.RETURN,.PARAM) Q:'RETURN 0
 Q 1
PROVCH(RETURN,PARAM) ; Provider change
 ;Input:
 ;  .RETURN [Required,Numeric] Set to the new provider change movement IEN, 0 otherwise.
 ;                             Set to Error description if the call fails
 ;  .PARAM [Required,Array] Array passed by reference that holds the new data.
 ;      PARAM("ADMIFN") [Required,Numeric] Admission associated IEN (pointer to the Patient Movement file #405)
 ;      PARAM("DATE") [Required,DateTime] Provider change date
 ;      PARAM("ATNDPHY") [Required,Numeric] Attending physician IEN (pointer to the New Person file #200)
 ;      PARAM("PRYMPHY") [Optional,Numeric] Primary physician IEN (pointer to the New Person file #200)
 ;      PARAM("DIAG") [Optional,Array] Array of detailed diagnosis description.
 ;         PARAM("DIAG",n) [Optional,String] Detailed diagnosis description.
 ;Output:
 ;  1=Success,0=Failure
 Q $$FTS1(.RETURN,.PARAM,1)
 ;
FTS(RETURN,PARAM) ; Facility treating movement
 ;Input:
 ;  .RETURN [Required,Numeric] Set to the new facility treating movement IEN, 0 otherwise.
 ;                             Set to Error description if the call fails
 ;  .PARAM [Required,Array] Array passed by reference that holds the new data.
 ;      PARAM("ADMIFN") [Required,Numeric] Admission associated IEN (pointer to the Patient Movement file #405)
 ;      PARAM("DATE") [Required,DateTime] Facility treating movement date
 ;      PARAM("ATNDPHY") [Required,Numeric] Attending physician IEN (pointer to the New Person file #200)
 ;      PARAM("FTSPEC") [Required,Numeric] Facility treating specialty IEN (pointer to the Facility Treating Specialty file #45.7)
 ;      PARAM("PRYMPHY") [Optional,Numeric] Primary physician IEN (pointer to the New Person file #200)
 ;      PARAM("DIAG") [Optional,Array] Array of detailed diagnosis description.
 ;         PARAM("DIAG",n) [Optional,String] Detailed diagnosis description.
 ;Output:
 ;  1=Success,0=Failure
 Q $$FTS1(.RETURN,.PARAM)
 ;
FTS1(RETURN,PARAM,PC) ; Add specialty transfer
 N %,DFN,ADM
 K RETURN S RETURN=0
 S %=$$CHKDT(.RETURN,.PARAM) Q:'RETURN 0
 S %=$$CHKADD(.RETURN,.PARAM,$G(PC)) Q:'RETURN 0
 D GETMVT^DGPMDAL1(.ADM,+$G(PARAM("ADMIFN")))
 S DFN=+ADM(.03,"I")
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$ADD(.RETURN,.PARAM,$G(PC),1)
 S %=$$UPDPAT^DGPMAPI9(,.PARAM,DFN,,1)
 D EVT(DFN,+RETURN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
EVT(DFN,IFN,MODE) ; Event
 D MVTEVT^DGPMAPI9(DFN,6,IFN,.MODE)
 Q
 ;
ADD(RETURN,PARAM,PC,QUIET) ; Add ralated physical movement
 N %,PM6,MFN,DIAG,PTS,DGQUIET
 S:$G(QUIET) DGQUIET=1
 I $G(PC) D
 . S PTS=$$GETPVTS^DGPMDAL1(+PARAM("PATIENT"),+PARAM("ADMIFN"),+PARAM("DATE"))
 . D GETMVT^DGPMDAL1(.PTS,PTS)
 . S PARAM("FTSPEC")=PTS(.09,"I")
 S PM6(.01)=+PARAM("DATE") ; admission date
 S PM6(.02)=6  ; transaction
 S PM6(.03)=+PARAM("PATIENT")  ; patient
 S PM6(.04)=42
 S PM6(.09)=+PARAM("FTSPEC")  ; facility treating specialty
 S PM6(.14)=+PARAM("ADMIFN")  ; admission checkin movement
 D ADDMVMTX^DGPMDAL1(.RETURN,.PM6)
 S MFN=+RETURN
 S:$D(PARAM("RELIFN")) PM6(.24)=+PARAM("RELIFN")  ; related physical movement
 S PM6(100)=DUZ,PM6(101)=$$NOW^XLFDT()
 S PM6(102)=DUZ,PM6(103)=$$NOW^XLFDT()
 S:+$G(PARAM("PRYMPHY")) PM6(.08)=+PARAM("PRYMPHY")  ; primary physician
 S PM6(.19)=+PARAM("ATNDPHY")  ; attending physician
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,MFN)
 S:'$D(PARAM("DIAG"))&($G(PARAM("SHDIAG"))]"") DIAG(1)=$G(PARAM("SHDIAG"))
 M:$D(PARAM("DIAG")) DIAG=PARAM("DIAG")
 D UPDDIAG^DGPMDAL1(.RETURN,.DIAG,MFN)
 D SETREVT^DGPMDAL1(MFN,"A")
 S RETURN=MFN
 Q 1
 ;
ASIH(RETURN,PARAM,TFN) ; ASIH transfer
 ;Input:
 ;  .RETURN [Required,Numeric] Set to the new transfer IEN, 0 otherwise.
 ;                             Set to Error description if the call fails
 ;  .PARAM [Required,Array] Array passed by reference that holds the new data.
 ;      PARAM("WARD") [Required,Numeric] Ward location IEN (pointer to the Ward Location file #42)
 ;      PARAM("FTSPEC") [Required,Numeric] Facility treating specialty IEN (pointer to the Facility Treating Specialty file #45.7)
 ;      PARAM("ATNDPHY") [Required,Numeric] Attending physician IEN (pointer to the New Person file #200)
 ;      PARAM("ADMREG") [Required,Numeric] Admitting regulation IEN (pointer to the VA Admitting Regulation file #43.4)
 ;      PARAM("FDEXC") [Required,Boolean] Patient wants to be excluded or not from Facility Directory.
 ;                                        If it is set to 1 the patient will be excluded from Facility Directory.
 ;      PARAM("SHDIAG") [Required,String] A brief description of the diagnosis (3-30 chars) 
 ;      PARAM("ADMSCC") [Optional,Boolean] Set to 1 if patient is admitted for service connected condition. Default: 0
 ;      PARAM("ADMSRC") [Optional,Numeric] Source of admission IEN (pointer to the Source of Admission file #45.1)
 ;      PARAM("ROOMBED") [Optional,Numeric] Room-bed IEN (pointer to the Room-bed file #405.4)
 ;      PARAM("PRYMPHY") [Optional,Numeric] Primary physician IEN (pointer to the New Person file #200)
 ;      PARAM("DIAG") [Optional,Array] Array of detailed diagnosis description.
 ;         PARAM("DIAG",n) [Optional,String] Detailed diagnosis description.
 ;Output:
 ;  1=Success,0=Failure
 N %,AFN,NADM,TRA,DIS,FTS,FTSFN,DFN,DMFN
 D SETAEVT^DGPMDAL1(+PARAM("ADMIFN"),,"P")
 S:'$G(TFN) TFN=$$ADDTRA^DGPMAPI2(.RETURN,.PARAM)
 M NADM=PARAM S DFN=+PARAM("PATIENT"),RETURN("TFN")=+TFN
 S NADM("TYPE")=10 ; mvmt type
 S %=$$ADDADM^DGPMAPI1(,.NADM)
 S AFN=+%,TRA(.15)=AFN,TRA(.22)=1,RETURN("NAFN")=+AFN
 D UPDMVT^DGPMDAL1(,.TRA,TFN)
 M DIS=PARAM
 S DIS("TYPE")=34,DIS("DATE")=$$FMADD^XLFDT(+PARAM("DATE"),30)
 S %=$$ADDDIS^DGPMAPI3(.RETURN,.DIS,DFN)
 S DMFN=+RETURN,RETURN("DMFN")=+DMFN
 K NADM
 ;S NADM(.17)=DMFN ; asih transfer
 S NADM(.21)=TFN ; asih transfer
 S NADM(.22)=2 ; asih sequence
 D UPDMVT^DGPMDAL1(,.NADM,AFN)
 M FTS=PARAM
 S FTS("ADMIFN")=AFN,FTS("RELIFN")=AFN
 S %=$$ADD^DGPMAPI6(.RETURN,.FTS)
 S FTSFN=+RETURN
 D SETTEVT^DGPMDAL1(TFN,,"A")
 D SETDEVT^DGPMDAL1(DMFN,"A")
 D SETAEVT^DGPMDAL1(+PARAM("ADMIFN"),,"A")
 D SETAEVT^DGPMDAL1(AFN,FTSFN,"A")
 S RETURN=TFN
 Q 1
 ;
CANDEL(RETURN,MFN,MVT) ; facility treating movement
 N % K RETURN S RETURN=0
 S %=$$GETMVT^DGPMAPI8(.MVT,+MFN)
 I MVT=0 D ERRX^DGPMAPIE(.RETURN,"RPMNFND") Q 0
 I +MVT("ADMIFN")=+MVT("RPM") D ERRX^DGPMAPIE(.RETURN,"CANDRPM") Q 0
 S RETURN=1
 Q 1
 ;
DELFTS(RETURN,MFN) ; Delete facility treating movement
 ;Input:
 ;  .RETURN [Required,Numeric] Set to 1 if the operation succeeds
 ;                             Set to Error description if the call fails
 ;   MFN [Required,Numeric] Facility treating movement IEN to delete (pointer to the Patient Movement file #405)
 ;Output:
 ;  1=Success,0=Failure
 N %,MVT,DFN
 K RETURN S RETURN=0
 S %=$$CANDEL(.RETURN,+MFN,.MVT) Q:'RETURN 0
 S DFN=MVT("PATIENT")
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$DEL(.RETURN,+MFN,.MVT,1)
 D EVT(+DFN,+MFN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
DEL(RETURN,MFN,MVT,QUIET) ; Delete facility treating movement
 N DGQUIET
 S:$G(QUIET) DGQUIET=1
 D INITEVT^DGPMDAL1
 D SETREVT^DGPMDAL1(+MFN,"P")
 D DELMVT^DGPMDAL1(+MFN)
 D SETREVT^DGPMDAL1(+MFN,"A","")
 Q 1
CHKASH(RETURN,PARAM,DFN,MAS,ASH) ;
 N %,WRD
 S RETURN=0,ASH=$S($G(ASH):ASH,1:1)
 S %=$$CHKADD^DGPMAPI1(.RETURN,.PARAM,ASH) Q:'RETURN&($P($G(RETURN(0)),U)'="WRDCNASB") 0
 K RETURN
 D GETWARD^DGPMDAL2(.WRD,+PARAM("WARD"),".01;.03;.17")
 I WRD=1,"^NH^D^"[(U_WRD(.03,"I")_U) S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"ASHWINVS") Q 0
 S RETURN=1
 Q 1
 ;
CHKFCTY(RETURN,ADMREG) ; Check asih facility
 N TMP,TXT K RETURN S RETURN=0
 I $G(ADMREG)="" S TXT(1)="PARAM(""FCTY"")" D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETFCTY^DGPMDAL2(.TMP,+ADMREG)
 I TMP=0 D ERRX^DGPMAPIE(.RETURN,"TFCNFND") Q 0
 I $G(TMP(101,"I"))=1 S TXT(1)=TMP(.01,"E") D ERRX^DGPMAPIE(.RETURN,"TFCINAC",.TXT) Q 0
 S RETURN=1
 Q 1
 ;
CHKTTYP(RETURN,TYPE,DFN,DATE) ; Check transfer type
 N %,TMP,TXT,ADTYP,ERR K RETURN S RETURN=0
 S %=$$CHKTYPE^DGPMAPI9(.RETURN,.TYPE,+DFN,+DATE,.TMP) Q:'RETURN 0
 S RETURN=0
 S %=$$LSTTRTYP^DGPMAPI7(.ADTYP,TMP(.01,"E"),,,+DFN,+DATE)
 S TXT(1)=TMP(.01,"E"),TXT(2)=$$LOW^XLFSTR($$EZBLD^DIALOG(4070000.012))
 I $G(TMP(.04,"I"))'=1 D ERRX^DGPMAPIE(.RETURN,"MVTTINAC",.TXT) Q 0
 I +$G(ADTYP(0))=0 D ERRX^DGPMAPIE(.RETURN,"ADMINVAT",.TXT) Q 0
 S RETURN=1
 Q 1
 ;
