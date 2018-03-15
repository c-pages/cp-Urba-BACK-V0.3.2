
	


	
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
		murs_nord			=	false,
		murs_sud				=	false,
		murs_est				=	false,
		murs_ouest			=	false,
	
	
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
		modes_distribution	=	#("Répartir", "Etirer", "Aligné à gauche", "Centré", "Aligné à droite"),
		modes_murs 			=	#("Tous", "Gouttereaux", "Pignons"/* , "Gauche", "Droite", "Avant", "Arrière" */),
		
		
		------ fonctions ----------------------------------
	public
		
		fn get_modes_distribution 	= modes_distribution ,
		fn get_modes_murs 			= modes_murs,
		
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
		
		
		
				
		
		---- sequence	------------
		fn get_longueur = (
			local result = 0
			local grp =#()
			local grp_repet =0
			local groupe_enFormation = false
			
			for elem in sequence do (
				if elem.type == #groupe then (
					groupe_enFormation = true
					grp =#()
					grp_repet = elem.params.repetitions
					if grp_repet == 0 do grp_repet = 1
				)
				else if elem.type == #groupeFin then (
					groupe_enFormation = false
					local longueur_grp = 0
					for elemGrp in grp do
						longueur_grp += elemGrp.get_longueur()		
					result += longueur_grp * grp_repet
				) else	if groupe_enFormation then append grp elem
				else	result += elem.get_longueur()
				
			)
			result
		),
		fn get_cardinaux =(
			local result = #()
			if murs_nord 	do append result #nord
			if murs_sud 		do append result #sud
			if murs_est	 	do append result #est
			if murs_ouest 	do append result #ouest
			result
		),
		fn get_sequenceFacade		_plug 	_longueur_facade	=(
			
			local	sequence_totale 		= #()
			local longueur_sequence 	= get_longueur ()
			
			
			local grp 		=#()
			
			local grp_repet 		=0
			local grp_longueur 	=0
			local reste 				=#()
			local reste_longueur 	=0
			local groupe_enFormation = false
			
			--- les infos du groupe	: repetition et longueur ---------------------
			for elem in sequence do (
				if elem.type == #groupe then (
					groupe_enFormation = true
					grp_repet = elem.params.repetitions
				)
				else if elem.type == #groupeFin then (
					groupe_enFormation = false
					grp_longueur = 0
					for elemGrp in grp do
						grp_longueur += elemGrp.get_longueur()					
				) else	
					if groupe_enFormation then 
						append grp elem		
					else (
						append reste elem		
						reste_longueur +=	elem.get_longueur ()
					)
			)
			-- si on a un groupe repet à 0 on clalcul combien de fois on repete le groupe -------------
			if grp.count> 0 and grp_repet == 0 do 
				grp_repet = floor ( (_longueur_facade - reste_longueur ) / grp_longueur )
			
			
			
			
			--- le nombre l'element de la sequence à prendre en compte (pas les balcons) et espacments
			local nbr_compos_aPrendreEnCompte	=	0
			local nbr_compos_etirables				=	0
			local i = 1
			while i  <= sequence.count do (
				local elem = sequence[i]
				if elem.type == #groupe then (
					for j= 1 to grp_repet do
						for elemGrp in grp do ( 
							if elemGrp.type != #balcon	and elemGrp.type != #balconFin and elemGrp.type != #groupe	and elemGrp.type != #groupeFin do (
								nbr_compos_aPrendreEnCompte	+= 1	
								if elemGrp.params.etirable do nbr_compos_etirables	+=1
							)
						)
					i += grp.count  + 1
				) else ( 
							if elem.type != #balcon	and elem.type != #balconFin and elem.type != #groupe	and elem.type != #groupeFin do (
								nbr_compos_aPrendreEnCompte	+= 1	
								if elem.params.etirable do nbr_compos_etirables	+=1
							)
						)
				
				i+= 1
			)
			
			
				
				
				
				
				
				
				
				
				
				
				
			if longueur_sequence	== 0 or nbr_compos_aPrendreEnCompte == 0  then (
				
				sequence_totale 	= #( _plug.core.get_murPlein		longueur_facade )
				
			) else (
				
				local result 	= 0
				
				
			
				
				--- la sequence à répartir	---------
				local sequence_simple		= for compo in 	sequence collect compo
				
				
				--- on transforme le mode etirer en centrer si on a aucun element etirable  --------
				if mode == 2 and nbr_compos_etirables == 0 do
					mode = 4
				
				-----	calcul de la longueur des espacements de la sequence	--------------------------------------
				case mode of (
					1: 	(	----- repartir  -----
						
						
						nbr_espacemts				=	grp.count * grp_repet + reste.count + 1
						
						longueur_restant 			=		_longueur_facade - ( grp_repet * grp_longueur + reste_longueur )
						
						longueur_espacement 	= longueur_restant / nbr_espacemts  

							append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
						
						---- les infos du groupe	: repetition et longueur ---------------------
						local i = 1
						while i  <= sequence.count do (
							local elem = sequence[i]
							if elem.type == #groupe then (
								for j= 1 to grp_repet do
									for elemGrp in grp do ( 
										append sequence_totale		elemGrp
										append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
									)
								i += grp.count  + 1
							)
							else ( 
										append sequence_totale		elem
										append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
									)
							
							i+= 1
						)
						
					)
					2: 	(	----- Etirer  -----
						
						nbr_espacemts				=	nbr_compos_etirables	--	nbr_compos_aPrendreEnCompte	--	grp.count * grp_repet + reste.count 						
						longueur_restant 			=	_longueur_facade - ( grp_repet * grp_longueur + reste_longueur )						
						longueur_espacement 	= longueur_restant / nbr_espacemts  
						
						
						---- les infos du groupe	: repetition et longueur ---------------------
						local i = 1
						while i  <= sequence.count do (
							local elem = sequence[i]
							if elem.type == #groupe then (
								for j= 1 to grp_repet do
									for elemGrp in grp do ( 
										if elemGrp.params.etirable  do
											elemGrp.params.set_longueur_etirer		longueur_espacement
										append sequence_totale		elemGrp
-- 										append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
									)
								i += grp.count  + 1
							)
							else ( 
										if elem.params.etirable  do
											elem.params.set_longueur_etirer		longueur_espacement
										append sequence_totale		elem
-- 										append sequence_totale	(  _plug.core.get_murPlein	  longueur_espacement )
									)
							
							i+= 1
						)
					)
					3:  	(	----- Aligner a gauche		----------
						
						longueur_restant 			=		_longueur_facade - ( grp_repet * grp_longueur + reste_longueur )
						longueur_espacement 	=		longueur_restant
						local groupe_enFormation = false
						
						---- les infos du groupe	: repetition et longueur ---------------------
						local i = 1
						while i  <= sequence.count do (
							local elem = sequence[i]
							if elem.type == #groupe then (
								for j= 1 to grp_repet do
									for elemGrp in grp do 
										append sequence_totale		elemGrp
								i += grp.count
							)
							else 
								append sequence_totale		elem
							
							i+= 1
						)
						append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
						
						
							
					)		
					4:  	(	----- centrer 	-----
						
						longueur_restant 			=		_longueur_facade - ( grp_repet * grp_longueur + reste_longueur )
						longueur_espacement 	=		longueur_restant /2
						local groupe_enFormation = false
						_plug.core.get_murPlein	  longueur_espacement
						
						append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
						
						---- les infos du groupe	: repetition et longueur ---------------------
						local i = 1
						while i  <= sequence.count do (
							local elem = sequence[i]
							if elem.type == #groupe then (
								for j= 1 to grp_repet do
									for elemGrp in grp do 
										append sequence_totale		elemGrp
								i += grp.count
							)
							else 
								append sequence_totale		elem
							
							i+= 1
						)
						
						append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
						
					)
					5: 	(	----- Aligner à droite -----
						
						longueur_restant 			=		_longueur_facade - ( grp_repet * grp_longueur + reste_longueur )
						longueur_espacement 	=		longueur_restant
						local groupe_enFormation = false
						
						append sequence_totale		(_plug.core.get_murPlein	  longueur_espacement)
						
						---- les infos du groupe	: repetition et longueur ---------------------
						local i = 1
						while i  <= sequence.count do (
							local elem = sequence[i]
							if elem.type == #groupe then (
								for j= 1 to grp_repet do
									for elemGrp in grp do 
										append sequence_totale		elemGrp
								i += grp.count
							)
							else 
								append sequence_totale		elem
							
							i+= 1
						)
						
					)
					
				) -- fin case	-----------
				
				
			)
			
			sequence_totale
		)
		
		
		
		
)


--- la fonction de construction	---------
fn facade_fnConstruire  	_plug		_pts_extremite		norm_dir:		 		this:		onConstruit_gardeCorps:true		etage_ht:	= (
	
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
			local pt_accroche_3 		= 	pt_accroche_2 + [0,0, etage_ht ]			
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


	
	
	
	
