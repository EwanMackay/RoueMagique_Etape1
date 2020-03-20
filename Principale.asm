		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Syst�me
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]
		




; IMPORT/EXPORT de proc�dure           

	IMPORT Init_Cible
        IMPORT Allume_LED
	IMPORT Eteint_LED
	

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

	


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Proc�dure principale et point d'entr�e du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************



;Algorithme Fronts montants
;		Old = Lire_Capteur()

;while(1)
;{
;Etat = Lire_Capteur()
;     if (etat=!old)
 ;          if(etat >0)
;                  si Ledeteinte
;				        led_allumer
;				 sinon 
;				        led eteinte
;				 end si
;			end if
;		end if
;			
;Old = Etat ; on m�morise l�ancien �tat pour le prochain tour
;}
		
		MOV R0,#0
		BL Init_Cible;
		
		LDR R10,=(GPIOBASEA+OffsetInput)        ;Initialisation oldEtat      r5= OldEtat
		LDRH R5, [R10]

Boucle	LDR R10,=(GPIOBASEA+OffsetInput)        ;lire capteur    R9=Capteur
		LDRH R9, [R10]
		
		CMP R9,R5
		BEQ FIN                                 ; comparaison old vs capteur    si aucun changement on saute a la fin
		
		MOV R3, #(0x01<<8)                      
		AND R6,R5,R3                            ;masquage pour r�cuperer la valeur du bit du capteur      R6= r�sulatat du masquage
		CMP R6, #0								; comparaison du bit de old a 0 => si old=0 alors on est sur un front montant
		BNE FIN                                 ; si old=1 on est sur front decendant: on ne fait rien
		
			                                    
		    ; on est dans le cas front montant
	    LDR R2,=(GPIOBASEB+OffsetOutput)          ; On verifie si la LED est allum�e   
		LDRH R4, [R2]                                  	   	
		MOV R3, #(0x01<<10)                      
		AND R6,R4,R3                            ;masquage pour r�cuperer la valeur du bit de la LED      R6= r�sulatat du masquage
		CMP R6, #0								; comparaison du bit a 0 => si 0 alors on led est � 0 -> on doit la mettre � 1    
        BEQ sinon		
		BL Eteint_LED 
		B FIN
sinon	BL Allume_LED
        
	
	
FIN	    LDR R10,=(GPIOBASEA+OffsetInput)        ;Actualisation oldEtat      r5= OldEtat
		LDRH R5, [R10]
		
        B Boucle



		;LDR R10,=(GPIOBASEB+OffsetOutput)             //Etape 1 : Alternatives pour allumer/eteindre
		;LDRH R9, [R10]
		;ORR R9,R5,R9
		;STRH R9,[R10]
		
		;LDR R10,=(GPIOBASEB+OffsetOutput)
		;LDRH R9, [R10]
		;MVN R5,R5
		;AND R9,R9,R5
		;STRH R9,[R10]
		

		B .


		ENDP

	END

;*******************************************************************************
