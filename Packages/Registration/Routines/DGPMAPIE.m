DGPMAPIE ;RGI/VSL - Registration Error provider; 1/10/2013
 ;;5.3;Registration;**260003**;
ERRX(RETURN,ERRNO,TEXT,LVL) ; adds error to RETURN
 N ERRTXT,IND,ST,STR,TXT,I
 Q:'$D(RETURN)
 Q:'$D(ERRNO)
 S:$G(LVL)="" LVL=1
 N I S I=0
 I $D(RETURN(I)) F I=0:1 Q:$O(RETURN(I))=""
 S RETURN(I)=ERRNO_U_$$EZBLD^DIALOG($P($T(@ERRNO),";;",2),.TEXT)_U_LVL
 Q
 ;
ERRTXT(RETURN) ;
 Q $P($G(RETURN(0)),U,2)
 ; 
ERRTABLE ; Error table
INVPARM ;;4070000.078;;Invalid parameter
WRDINACT ;;4070000.079;;Ward is inactive.
BEDINACT ;;4070000.08;;Bed is inactive.
BEDOCC ;;4070000.081;;Bed is occupied.
FILELOCK ;;4070000.082;;Record in use. Try again in a few moments.
CANDASIH ;;4070000.086;;Cannot delete before ASIH transfers are removed
CANMDDF ;;4070000.087;;Must delete discharge first
CANDWPTF ;;4070000.088;;Cannot delete while PTF Census record # is closed.
DELTITP ;;4070000.095;;Cannot delete transfer - would create an invalid transfer pair
DELTMDTA ;;4070000.096;;Must delete through corresponding hospital admission
DELTCDWD ;;4070000.097;;Cannot delete while discharge exists
DELTCDPC ;;4070000.098;;Cannot delete when corresponding admission PTF closed out
DELTMMRF ;;4070000.099;;|1| movement must be removed first
TRANBADM ;;4070000.114;;Not before admission movement
DSCNMVTD ;;4070000.116;;There is no movement type define for
