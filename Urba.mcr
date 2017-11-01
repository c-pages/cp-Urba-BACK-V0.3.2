
macroScript Urba
category:"#CPages"
buttonText:"Urba"
toolTip:"Generateur de ville"
(
	
	global urba  	=	fileIn	 "$userScripts\cp-Urba\Urba.ms"  
		on execute do 	(
		
		if ( urba.estOuvert () )	
			then	urba.fermer	()
			else 	urba.ouvrir 	()
		
	)
	
	on isChecked return try ( urba.estOuvert () )  catch	( false )
	
)

