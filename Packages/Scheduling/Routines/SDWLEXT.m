SDWLEXT ;RGI/CBR - WAIT LIST API - EXTERNAL FUNCTIONS;3/29/13
 ;;5.3;scheduling;**260003**;08/13/93
PATDET(RETURN,DFN) ;RETURN PATIENT DETAILS
 S DFN=$G(DFN)
 I '(DFN?1.N) D ERRX^SDAPIE(.RETURN,"INVPARAM","DFN") Q 0
 I DFN'>0 D ERRX^SDAPIE(.RETURN,"INVPARAM","DFN") Q 0
 N REC,ERT,ERR,I
 K RETURN
 D GETS^DIQ(2,DFN,".01;.351","IE","REC","ERT")
 S ERR=0,I=0
 F  S I=$O(ERT("DIERR",I)) Q:I'>0!ERR  D
 . I ERT("DIERR",1)=601 S ERR=1
 I ERR D ERRX^SDAPIE(.RETURN,"PATNFND") Q 0
 S RETURN("NAME")=REC(2,DFN_",",.01,"I")_"^"_REC(2,DFN_",",.01,"E")
 S RETURN("DOD")=REC(2,DFN_",",.351,"I")_"^"_REC(2,DFN_",",.351,"E")
 Q 1
 ;
INSTFMST(STN) ;RETURNS INSTITUTION NAME FROM STATION NUMBER
 N INSTIEN
 S INSTIEN=$$FIND1^DIC(4,"","X",STN,"D")
 Q $$GET1^DIQ(4,INSTIEN,60)
 ;
