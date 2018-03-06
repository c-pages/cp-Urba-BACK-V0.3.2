
	


	
( ----	FileIn ----
	
	



--- parametres de base	-----------------------------
facade_nom 		= "Façade"	
facade_type		=	#facade
facade_toolTip 	=	""

--- les parametres du composant	---------
struct facade_params	(
	
	public
		mode					=	1,					---- le mode de repartition des element de la facade		 ( 1:repeter	2:etrier			3:centrer )	----
		
		--- Limiteurs - Murs	---
		murs						=	1,					---- ( 1:les deux	2:gouttereaux	3:pignons )	----
		
		--- Limiteurs - Etages	---
		etagesMin_use		=	false,
		etagesMin				= 	0,
		etagesMax_use		=	false,
		etagesMax				=	0,
		
		--- Limiteurs - longueurs	---
		longueurMin_use	=	false,
		longueurMin			= 	0,
		longueurMax_use	=	false,
		longueurMax			=	0,
		
		--- Sequence	---
		sequence				=	#(),
		
		
	private	
		modes_distribution	=	#("Centrer", "Répartir", "Répeter - Centrer", "Répeter - Répartir", "Répeter - Répartir éléments" ),
		
		------ fonctions ----------------------------------
	public
-- 		fn set_plug			_plug				= m_plug = _plug,
			
		fn get_modes_distribution = modes_distribution ,
		
		---- composants ------------
		fn ajouter_composant 		_composant 	position:(sequence.count+1)  =(
			if position == 0 do position = sequence.count+1
			insertItem _composant		sequence 				position
		),
		fn supprimer_composant 	_index 	=		deleteItem sequence	_index,
		fn instancier_composant 	_index 	=(
-- 			debug "sequence[_index]" var:sequence[_index]
			local compoInstance =  sequence[_index]
			ajouter_composant  compoInstance 	position:( _index+1)
-- 			debug "compoInstance" var:compoInstance
-- 			debug "sequence" var:sequence
			compoInstance
		),
		fn composant_monter 		_index =(
			local compoTemp = sequence[_index]
			deleteItem sequence		_index
			insertItem compoTemp		sequence 				(_index-1)			
		),
		fn composant_descendre 	_index =(
			local compoTemp = sequence[_index]
			deleteItem sequence		_index
			insertItem compoTemp		sequence 				(_index+1)			
		),
		
		
		
		
		/* 
		
		fn creer_murPlein		_longueur	 =(
			local nvComposant	 				= 	m_plug.core.get_murPlein		_longueur
			nvComposant
		), */
		
		
		---- sequence	------------
		fn get_longueur = (
			local result = 0
			for elem in sequence do 
					result += elem.get_longueur()
			result
		),
		fn get_sequenceFacade		_plug 	_longueur_facade	=(
			
			local	sequence_totale 			= #()
			
			
			local	nbr_espacemts				=	0
			local	nbr_espacemts_sequence				=	0
			local	nbr_repetitions				=	0
			local	longueur_restant			=	0
			local	longueur_espacement	=	0
			local longueur_sequence 		= get_longueur		()	
			
			
			--- le nombre l'element de la sequence à prendre en compte (pas les balcons) et espacments
			local nbr_compos_aPrendreEnCompte	=	0
			for  elem in sequence do (
				if elem.type != #balcon	and elem.type != #balconFin do 
					nbr_compos_aPrendreEnCompte	+= 1	
-- 					if elem.type != #espacement do
-- 						nbr_espacemts_sequence += 1
			)
			if longueur_sequence	== 0 or nbr_compos_aPrendreEnCompte == 0  then (
				
				sequence_totale 	= #( _plug.core.get_murPlein		longueur_facade )
				
			) else (
				
				--- le nombre l'element de la sequence à prendre en compte (pas les balcons) et espacments
				local nbr_compos_aPrendreEnCompte	=	0
				for  elem in sequence do (
					if elem.type != #balcon	and elem.type != #balconFin do 
						nbr_compos_aPrendreEnCompte	+= 1	
-- 					if elem.type != #espacement do
-- 						nbr_espacemts_sequence += 1
				)
				
				--- la sequence à répartir	---------
				local sequence_simple		= for compo in 	sequence collect compo
				
				-----	calcul de la longueur des espacements de la sequence	--------------------------------------
				case mode of (
					1:  (	--- centrer ----	
						
						nbr_repetitions				= 1
						nbr_espacemts				=	2  + nbr_espacemts_sequence
						longueur_restant 			= _longueur_facade - longueur_sequence
						longueur_espacement 	= longueur_restant / nbr_espacemts  
						
						
						--- création dela séquence	------------------
						sequence_simple		= for compo in 	sequence collect compo
						sequence_totale = #(_plug.core.get_murPlein	  longueur_espacement  )
						local poser_esp_debut = false
						for elem in	sequence_simple	do 	
							append sequence_totale		elem
							
						append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
						
						
					)		
					2:  	(	--- repartir ----
						nbr_repetitions				=  1		
						nbr_espacemts				=	nbr_compos_aPrendreEnCompte + 1	
						longueur_restant 			= _longueur_facade - longueur_sequence 
						longueur_espacement 	= longueur_restant / nbr_espacemts  
						
						--- création dela séquence	------------------
						sequence_totale = #(_plug.core.get_murPlein	  longueur_espacement  )
						
						local poser_esp_debut = false
						for i = 1 to	sequence_simple.count	do 		(
							local elem = 	sequence_simple[i]
							
							append sequence_totale		elem
							
							if poser_esp_debut do (								
								append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
								poser_esp_debut = false
							)
							
							local elem_suivant	=	if i < sequence_simple.count	then sequence_simple[i + 1] else undefined
							if elem_suivant != undefined do
								if  elem_suivant.type == #balconFin do (
									poser_esp_debut = true
								)
							
							if not poser_esp_debut and elem.type != #balcon	and elem.type != #balconFin do 
								append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
						)
					)
					3: 	(	--- repeter	-	centrer ----
						
						nbr_repetitions				= floor ( _longueur_facade / longueur_sequence )
						nbr_espacemts				=	2	--	nbr_compos_aPrendreEnCompte + 1
						longueur_restant 			= _longueur_facade - longueur_sequence * nbr_repetitions
						longueur_espacement 	= longueur_restant / nbr_espacemts  

						sequence_totale = #(_plug.core.get_murPlein	  longueur_espacement  )
						-- les boucles de la facade simple	--------
						for i = 1 to nbr_repetitions do (				
							----- les repetitions de sequence ------------------
							for compo	in	 sequence_simple	do 						
								append sequence_totale	compo							
						)
						append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
					)
					4: 	(	--- repeter	-	repartir  ----
						
						nbr_repetitions				= floor ( _longueur_facade / longueur_sequence )
						nbr_espacemts				=	nbr_repetitions + 1
						longueur_restant 			= _longueur_facade - longueur_sequence * nbr_repetitions
						longueur_espacement 	= longueur_restant / nbr_espacemts  

						sequence_totale = #(_plug.core.get_murPlein	  longueur_espacement  )
						-- les boucles de la facade simple	--------
						for i = 1 to nbr_repetitions do (				
							----- les repetitions de sequence ------------------
							for compo	in	 sequence_simple	do 						
								append sequence_totale	compo							
							append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
						)
					)
				) -- fin case	-----------
				
				/* 
				-------------------- la SEQUENCE TOTALE	----------------------------------------------------------------------------------------
				-----	si on a une sequence avec une longueur nulle, on creer un seul mur plein	--------------------------------------		

				
				for i=1 to sequence.count do (
					local composant = sequence_simple[i]
					case composant.type  as name of (
					-----	on remplace les espacements de la sequence par des murs pleins	--------------------------------------
						#espacement:	sequence_simple[i] = _plug.core.get_murPlein	 longueur_espacement
						
						---- on gere les balcons et loggias	---------
					)
				)
				
				--------------puis on creer la sequence total du mur	--------------------------------------
				----- le premier espacement ------------
				if mode != 3 do 
					append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
				
				-- les boucles de la facade simple	--------
				for i = 1 to nbr_repetitions do (				
					----- les repetitions de sequence ------------------
					for compo	in	 sequence_simple	do 						
						append sequence_totale	compo
					if espacer do 
						append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
				)
				
				----- le dernier espacement ------------
				if not espacer and  mode != 3 do 
						append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )					
				 */
			)
			
			sequence_totale
		)
)


--- la fonction de construction	---------
fn facade_fnConstruire  	_plug		_pts_extremite		norm_dir:		 		this:		onConstruit_gardeCorps:true		= (
	
			m_plug = _plug
			m_geo	=	_plug.core.get_geo ()
			
			------------ ANALYSE ------------------------------------------------------------------
		
			local	mur_norm 			= normalize ( _pts_extremite[2] -	_pts_extremite[1] )
			local longueur_facade 	= 	distance _pts_extremite[1] 		_pts_extremite[2]
			local norm_dir				=	normalize ( _pts_extremite[2] - _pts_extremite[1])			
			
			--- on  recupere la sequence totale de la facade en question ----
			local sequenceTotal  		=	this.params.get_sequenceFacade	_plug	longueur_facade	
			
			------------ CONSTRUCTION  DE LA FACADE	------------------------------------
			--- on créé  les 3 premiers points --------
			local pt_accroche_1 		= 	_pts_extremite[1]
			local pt_accroche_2 		= 	pt_accroche_1 + [0,0,m_plug.const_dalle_epaisseur]
			local pt_accroche_3 		= 	pt_accroche_2 + [0,0,m_plug.etages_hauteur]			
			local ptsIDs_accroche 	= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 ) )
			
			
			--- gestion balcon	------
			local balcon_ptID_debut
			local balcon_pts_debut
			local balcon_aConstruire = undefined
			
			----gestion loggia -------
			local	 loggia_ptID_debut
			local loggia_pts_debut
			local loggia_aConstruire = undefined
			
			local profondeurFacade = 0
			
			---  on créé la facade avec la sequence total --------
			for composant in sequenceTotal do (
				
				case composant.type as name of (
					
					#balcon:(
						balcon_aConstruire 	= composant
						ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche		norm_dir:norm_dir	onConstruitLaDalle:false				
						balcon_pts_debut 		= ptsIDs_accroche		
					)
					#balconFin:(
						local		pt_balcon_debut	=	polyop.getVert 	m_plug.delegate		balcon_pts_debut[1]	
						local		pt_balcon_fin		=	polyop.getVert 	m_plug.delegate		ptsIDs_accroche[1]	
						composant.params.longueur 				= 		distance	pt_balcon_debut 	pt_balcon_fin
-- 						composant.params.profondeur 			= 		balcon_aConstruire.params.profondeur
					
						ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche	norm_dir:norm_dir	\
																																		compo_debut:balcon_aConstruire \
																																		onConstruit_gardeCorps:( onConstruit_gardeCorps  )
						
						composant.params.longueur 	= 	0
						balcon_aConstruire 				=	undefined
					
					)
					
					/* 
					
					#loggia:(
						loggia_aConstruire 	= composant
-- 						profondeurFacade 		= loggia_aConstruire.params.profondeur
					-----	construction geometrie du composant	----------
						ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche		norm_dir:norm_dir	onConstruitLaDalle:false
						
						loggia_pts_debut 		= ptsIDs_accroche
					
					)
					#loggiaFin:(
						local		pt_loggia_debut			=	polyop.getVert 	m_plug.delegate		loggia_pts_debut[1]	
						local		pt_loggia_fin					=	polyop.getVert 	m_plug.delegate		ptsIDs_accroche[1]
						
						composant.params.longueur 		= 	(	distance	pt_loggia_debut 	pt_loggia_fin	)
						
						composant.params.profondeur 	= 		loggia_aConstruire.params.profondeur
						ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche		norm_dir:norm_dir	\
																																			onConstruitLaDalle:false	\
																																			compo_debut:loggia_aConstruire \
																																			onConstruit_gardeCorps:( onConstruit_gardeCorps and balcon_aConstruire == undefined )
						composant.params.longueur 		= 		0
						loggia_aConstruire = undefined
					
					)
					*/
					
					
					default:(
						local onConstruitLaDalle = ( balcon_aConstruire == undefined )  -- and  ( loggia_aConstruire == undefined )
						
						-----	construction geometrie du composant	----------
						ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche		norm_dir:norm_dir		onConstruitLaDalle:onConstruitLaDalle		
						
					)
				) -- fin case	-----------------
				
			) --- fin de la sequence -----
			
		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:facade_tooltip		nom:facade_nom	type:facade_type	params:( facade_params () )	dialog:undefined	fnConstruire:facade_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
