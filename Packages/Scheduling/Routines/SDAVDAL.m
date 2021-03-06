SDAVDAL ;RGI/VSL - AVAILABILITY API;08/07/13  15:03
 ;;5.3;Scheduling;**260003**;
GETCLN(RETURN,SC,FLDS) ; Get clinic
 N CLN,DIQ,DIC,DA,DR
 S DIQ(0)="IE",DIQ="CLN(",DIC="^SC(",DA=SC
 S DR=$S('$D(FLDS):".01",1:FLDS)
 D EN^DIQ1
 M RETURN=CLN(44,SC)
 Q
 ;
GETCANP(RETURN,SC,SD) ; Get cancelled periods
 N I
 F I=SD:0 S I=$O(^SC(SC,"SDCAN",I)) Q:'I  D
 . S RETURN(I,"BEGIN")=$P(^SC(SC,"SDCAN",I,0),U)
 . S RETURN(I,"END")=$P(^SC(SC,"SDCAN",I,0),U,2)
 . S RETURN(I,"MESS")=$P(^SC(SC,"S",I,"MES"),"(",2)
 . S RETURN(I,"MESS")=$P(RETURN(I,"MESS"),")")
 Q
 ;
GETTMPL(SC,SD,DOW) ;
 N SS
 S SS=$O(^SC(SC,"T"_DOW,SD))
 I SS'="",$D(^SC(SC,"T"_DOW,SS,1)),^SC(SC,"T"_DOW,SS,1)]"" Q ^SC(SC,"T"_DOW,SS,1)
 Q ""
 ;
SETPATT(SC,SD,PATT,FLAG) ; Set pattern availability
 S ^SC(SC,"ST",SD,0)=SD
 S ^SC(SC,"ST",SD,1)=PATT
 S:$G(FLAG) ^SC(SC,"ST",SD,9)=SC
 Q
 ;
DELPATT(SC,SD) ; Delete pattern availability
 K ^SC(SC,"ST",SD)
 Q
 ;
DELSTCAN(SC,SD) ; Delete CAN node
 K ^SC(SC,"ST",SD,"CAN")
 Q
 ;
DELSMES(SC,SD) ; Delete MES node
 K ^SC(SC,"S",SD,"MES")
 Q
 ;
DELSDCAN(SC,SD) ; Delete SDCAN
 N CNT
 K ^SC(SC,"SDCAN",SD)
 I $D(^SC(SC,"SDCAN",0)) D
 . S CNT=$P(^SC(SC,"SDCAN",0),U,4)
 . S CNT=$S(CNT>0:CNT-1,1:0)
 . S ^SC(SC,"SDCAN",0)=$P(^SC(SC,"SDCAN",0),U,1,3)_U_CNT
 Q
 ;
ADDHOL(RETURN,PARAM) ; Add holiday
 N IENS,DIC S DIC="^HOLIDAY("
 S IENS="+1,"
 S IENS(1)=+PARAM(.01)
 D UPDFILE(.RETURN,40.5,.IENS,.PARAM)
 Q
 ;
UPDHOL(RETURN,IFN,PARAM) ; Update holiday
 D UPDFILE(.RETURN,40.5,IFN_",",.PARAM)
 Q
 ;
DELHOL(RETURN,IFN) ; Delete holiday
 N DA,DIK,DGIDX
 S DA=IFN,DIK="^HOLIDAY(" D ^DIK
 Q
 ;
UPDFILE(RETURN,FILE,IENS,PARAMS) ; Add/update entry to file
 N FLD,FDA
 S FLD=0
 F  S FLD=$O(PARAMS(FLD)) Q:'FLD  D
 . S FDA(FILE,IENS,FLD)=PARAMS(FLD)
 I $E(IENS,1,1)="+" D  I 1
 . D UPDATE^DIE("","FDA","IENS","RETURN")
 . S RETURN=IENS(1)
 E  D FILE^DIE("","FDA","RETURN") S RETURN=1
 Q
 ;
GETSCSL(RETURN,SC) ;
 S RETURN=$G(^SC(SC,"SL"))
 Q
 ;
LSTCAPTS(RETURN,SC,SDBEG,SDEND) ;
 N SDT,SDDA,CNT,APT,SDATA,CNSTLNK,SDT
 S CNT=0
 F SDT=SDBEG:0 S SDT=$O(^SC(SC,"S",SDT)) Q:'SDT!($P(SDT,".",1)>SDEND)  D
 . I $D(^SC(SC,"S",SDT,"MES")) S CNT=CNT+1,RETURN(CNT,"MES")="",RETURN(CNT,"DATE")=SDT
 . F SDDA=0:0 S SDDA=$O(^SC(SC,"S",SDT,1,SDDA)) Q:'SDDA  D
 . . S CNT=CNT+1
 . . S RETURN(CNT,"APT")=^SC(SC,"S",SDT,1,SDDA,0)
 . . S RETURN(CNT,"DATE")=SDT
 Q
 ;
