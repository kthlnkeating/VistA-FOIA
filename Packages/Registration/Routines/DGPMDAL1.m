DGPMDAL1 ;RGI/VSL - PATIENT MOVEMENT DAL; 2/11/2013
 ;;5.3;Registration;**260005**;
ADDMVMT(RETURN,PARAMS) ; Add new patient movement
 N FLD,IENS,FDA
 S IENS="+1,"
 S FLD=0
 F  S FLD=$O(PARAMS(FLD)) Q:'FLD  D
 . S FDA(405,IENS,FLD)=PARAMS(FLD)
 D UPDATE^DIE("","FDA","IENS","RETURN")
 S RETURN=IENS(1)
 Q
 ;
ADDMVMTX(RETURN,PARAMS) ; Add new patient movement
 N X,Y,DD,DO,DIC
 S DIC="^DGPM(",DIC(0)="L",X=PARAMS(.01)
 K DD,DO
 D FILE^DICN
 S RETURN=Y
 Q
 ;
ADDPTF(RETURN,PARAMS) ; Add PTF
 N DFN,DGPTDATA S DFN=PARAMS(.01)
 S DGPTDATA=U_PARAMS(2),DIC="^DGPT(",DIC("DR")="[DG PTF CREATE PTF ENTRY]"
 S DIC(0)="FLZ",X=DFN K DD,DO D FILE^DICN
 S RETURN=+Y
 Q
 ;
UPDPTF(RETURN,PARAMS,IFN) ; Update PTF
 N FLD,IENS,FDA
 S IENS=IFN_","
 S FLD=0
 F  S FLD=$O(PARAMS(FLD)) Q:'FLD  D
 . S FDA(45,IENS,FLD)=PARAMS(FLD)
 D FILE^DIE("","FDA","RETURN")
 S RETURN=IFN
 Q
 ;
UPDMVT(RETURN,DATA,IFN) ; Update patient movement
 N IENS,I S I=0
 S IENS=IFN_","
 N FDA
 F I=0:0 S I=$O(DATA(I)) Q:I=""  D
 . S FDA(405,IENS,I)=DATA(I)
 D FILE^DIE("","FDA","RETURN")
 Q
 ;
UPDSCADM(RETURN,DATA,IFN) ; Update scheduled admission
 N IENS,I S I=0
 S IENS=IFN_","
 N FDA
 F  S I=$O(DATA(I)) Q:I=""  D
 . S FDA(41.1,IENS,I)=DATA(I)
 D FILE^DIE("","FDA","RETURN")
 S RETURN=1
 Q
 ;
UPDPAT(RETURN,DATA,IFN) ; Update patient
 N IENS,I,FDA S I=0
 S IENS=IFN_","
 F  S I=$O(DATA(I)) Q:I=""  D
 . S FDA(2,IENS,I)=DATA(I)
 D FILE^DIE("","FDA","RETURN")
 Q
 ;
UPDDIAG(RETURN,DATA,PM) ; Update patient movement diagnostic
 N I S I=0
 K ^DGPM(PM,"DX")
 S ^DGPM(PM,"DX",0)="^^0^0^"_$P($$NOW^XLFDT(),".")_"^^^"
 F  S I=$O(DATA(I)) Q:'I  D
 . S $P(^DGPM(PM,"DX",0),U,3)=$P(^DGPM(PM,"DX",0),U,3)+1
 . S $P(^DGPM(PM,"DX",0),U,4)=$P(^DGPM(PM,"DX",0),U,4)+1
 . S ^DGPM(PM,"DX",I,0)=DATA(I)
 S RETURN=$P(^DGPM(PM,"DX",0),3,4)_$G(DATA(1))
 Q
 ;
GETMVT0(MFN) ;
 Q $G(^DGPM(MFN,0))
 ;
INITEVT() ;
 K ^UTILITY("DGPM",$J)
 Q
 ;
SETAEVT(MFN,RFN,PA) ; Sets admission prior/after event
 S ^UTILITY("DGPM",$J,1,MFN,PA)=$G(^DGPM(MFN,0))
 S:'$D(^UTILITY("DGPM",$J,1,MFN,"P")) ^UTILITY("DGPM",$J,1,MFN,"P")=""
 Q:$G(RFN)'>0
 S ^UTILITY("DGPM",$J,6,RFN,PA)=$G(^DGPM(RFN,0))
 S:'$D(^UTILITY("DGPM",$J,6,RFN,"P")) ^UTILITY("DGPM",$J,6,RFN,"P")=""
 S ^UTILITY("DGPM",$J,6,RFN,"DX"_PA)=$P($G(^DGPM(RFN,"DX",0)),U,3,4)_$G(^DGPM(RFN,"DX",1,0))
 S:'$D(^UTILITY("DGPM",$J,6,RFN,"DXP")) ^UTILITY("DGPM",$J,6,RFN,"DXP")=""
 S ^UTILITY("DGPM",$J,6,RFN,"PTF"_PA)=$G(^DGPM(RFN,"PTF"))
 S:'$D(^UTILITY("DGPM",$J,6,RFN,"PTFP")) ^UTILITY("DGPM",$J,6,RFN,"PTFP")=""
 Q
 ;
SETTEVT(MFN,RFN,PA) ; Sets transfer prior/after event
 S ^UTILITY("DGPM",$J,2,MFN,PA)=$G(^DGPM(MFN,0))
 S:'$D(^UTILITY("DGPM",$J,2,MFN,"P")) ^UTILITY("DGPM",$J,2,MFN,"P")=""
 Q:$G(RFN)'>0
 S ^UTILITY("DGPM",$J,6,RFN,PA)=$G(^DGPM(RFN,0))
 S:'$D(^UTILITY("DGPM",$J,6,RFN,"P")) ^UTILITY("DGPM",$J,6,RFN,"P")=""
 S ^UTILITY("DGPM",$J,6,RFN,"DX"_PA)=$P($G(^DGPM(RFN,"DX",0)),U,3,4)_$G(^DGPM(RFN,"DX",1,0))
 S:'$D(^UTILITY("DGPM",$J,6,RFN,"DXP")) ^UTILITY("DGPM",$J,6,RFN,"DXP")=""
 S ^UTILITY("DGPM",$J,6,RFN,"PTF"_PA)=$G(^DGPM(RFN,"PTF"))
 S:'$D(^UTILITY("DGPM",$J,6,RFN,"PTFP")) ^UTILITY("DGPM",$J,6,RFN,"PTFP")=""
 Q
 ;
SETDEVT(MFN,PA) ; Sets discharge prior/after event
 S ^UTILITY("DGPM",$J,3,MFN,PA)=$G(^DGPM(MFN,0))
 S:'$D(^UTILITY("DGPM",$J,3,MFN,"P")) ^UTILITY("DGPM",$J,3,MFN,"P")=""
 Q
 ;
SETDLEVT(AFN) ; Sets delete prior/after event
 N I,TYPE S I=0
 F  S I=$O(^DGPM("CA",AFN,I)) Q:I=""  D
 . S TYPE=$P(^DGPM(I,0),U,2)
 . S ^UTILITY("DGPM",$J,TYPE,I,"P")=$G(^DGPM(AFN,0))
 . S ^UTILITY("DGPM",$J,TYPE,I,"A")=""
 Q
 ;
LOCKMVT(DFN) ; Lock patient movements
 L +^DGPM("C",DFN):1
 Q $T
ULOCKMVT(DFN) ; Unlock patient movements
 L -^DGPM("C",DFN)
 Q
GETLASTM(RETURN,DFN,DGDT) ; Get last patient movement
 N NOWI,VAX,VAIP,DGPMVI,NOW
 S NOWI=DGDT,NOW=DGDT,VAIP("D")="L",VAIP("L")=""
 D INP^DGPMV10
 M RETURN=DGPMVI
 Q
 ;
GETMVT(DATA,MFN,FLDS) ; Get patient movement
 N TMP,ERR
 I '$D(FLDS) S FLDS="*"
 D GETS^DIQ(405,MFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(405,MFN_",")
 Q
 ;
GETRPHY(MFN) ; Get related physical movement
 Q $O(^DGPM("APHY",MFN,0))
 ;
GETRPM(DATA,MFN,FLDS) ; Get related physical movement
 N TMP,ERR
 S IFN=0,IFN=$O(^DGPM("APHY",MFN,IFN))
 Q:IFN'>0
 I '$D(FLDS) S FLDS="*"
 D GETS^DIQ(405,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(405,IFN_",")
 Q
 ;
GETPTF(DATA,MFN,FLDS) ; Get ptf record
 N TMP,ERR
 I '$D(FLDS) S FLDS="*"
 D GETS^DIQ(45,MFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(45,MFN_",")
 Q
 ;
LSTCA(MVTS,MFN,FLDS) ; Get corresponding admission movements
 N I S I=0
 I '$D(FLDS) S FLDS=".02;.03"
 F  S I=$O(^DGPM("CA",MFN,I)) Q:I=""  D
 . K MVT D GETMVT(.MVT,I,FLDS)
 . M MVTS(I)=MVT
 Q
 ;
LSTAPMV(MVTS,MFN,FLDS) ; Get corresponding admission movements
 N I,DFN,ID,MVT S I=0
 I '$D(FLDS) S FLDS=".02;.03"
 S DFN=$P(^DGPM(MFN,0),U,3)
 F  S I=$O(^DGPM("APMV",DFN,MFN,I)) Q:I=""  D
 . S ID=$O(^DGPM("APMV",DFN,MFN,I,0))
 . K MVT D GETMVT(.MVT,ID,FLDS)
 . M MVTS(ID)=MVT
 Q
 ;
DELMVT(MFN) ; Delete movement
 N DA,DIK
 S DA=MFN,DIK="^DGPM(" D ^DIK
 Q
DELPTF(PTF) ; Delete PTF
 N DA,DIK
 S DA=PTF,DIK="^DGPT(" D ^DIK
 Q
ISPTFCEN(PTF) ;
 I $O(^DGPT("ACENSUS",+PTF,0)) Q $O(^DGPT("ACENSUS",+PTF,0))
 Q 0
