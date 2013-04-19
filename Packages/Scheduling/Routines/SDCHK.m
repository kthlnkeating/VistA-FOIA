SDCHK ; RGI/CBR -- Scheduling Validators ;4/19/13
 ;;5.3;scheduling;**260003**;08/13/93
DTIME(RETURN,PARM,PNAME,OPT,RQTIME) ;Validate DateTime fields
 N DATE,TIME,M,D
 I $G(PARM)="",+$G(OPT) Q 1
 S PNAME=$G(PNAME)
 I '$D(PARM),'+$G(OPT) D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0
 S DATE=$P(PARM,".")
 S TIME=+$P(PARM,".",2)
 I '$$TIME(TIME,'+$G(RQTIME)) D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0
 I DATE'?3.7N D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0
 S M=$E(DATE,4,5),D=$E(DATE,6,7)
 I M>12 D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0
 I D>31 D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0
 Q 1
 ;
TIME(TIME,OPT) ;Validate time
 N H,M,S
 I 'OPT,TIME="" Q 0
 I TIME="" Q 1
 I TIME'?1.6N Q 0
 S H=$E(TIME,1,2),M=$E(TIME,3,4),S=$E(TIME,5,6)
 I H>23 Q 0
 I M>59 Q 0
 I S>59 Q 0
 Q 1
 ;
PATIEN(RETURN,PARM,OPT) ;Patient
 N R
 I $G(PARM)="",+$G(OPT) Q 1
 I '$$PATDET^SDWLEXT(.R,.PARM) D  Q 0
 . M RETURN=R
 Q 1
 ;
SDWLIEN(RETURN,PARM,PNAME,OPT) ;SDWL(409.3) IEN
 I $G(PARM)="",+$G(OPT) Q 1
 S PNAME=$G(PNAME,"SDWLIEN")
 I '($G(PARM)?1.N) D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0 ; Invalid parameter value
 I PARM'>0 D ERRX^SDAPIE(.RETURN,"INVPARAM",PNAME) Q 0 ; Invalid parameter value
 I '$$IENVLD^SDWLDAL(PARM) D ERRX^SDAPIE(.RETURN,"WLNFND") Q 0
 Q 1
 ;
