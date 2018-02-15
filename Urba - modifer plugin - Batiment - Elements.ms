



struct 	str_mgr_composants (
		
		m_plug,
	private
		
		---- Le tableau des éléments --------
		m_items	=	#(),
		
		fn get_nouveauComposant =(
			--- on importe le fichier du struct des composants (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements - Composant.ms"
			str_composant ()
		),
		
		---- CONSTRUCTION DES  COMPOSANTS -------------------------------------------
	private
		fn espacement 	=(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 0
			)
			local dialog  = rollout dialog "Espacement" width:180 height:70	(
									local m_compo, m_rollPrt, m_param
									fn actualiser =()
								)
			fn fnConstruire  	_plug	 	pts_accroches		_normDir			_composant		=()
			
			--- Creation du composant --------------
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_ESP		"Espacement"
			nvComposant.set_dialog			dialog
			nvComposant.set_params	 	( params () )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		
		---- Mur plein -------------------------------------------
		fn murPlein 	=(
			
			local params = struct param (
				longueur = 100
			)
			local dialog  = rollout dialog "Mur plein" width:180 height:70	(
									local m_compo
									local m_rollPrt
									local m_param
									
									edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
									GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
									label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
									spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
									
									fn actualiser =(
										spn_longueur.value 	= 	m_compo.longueur
										edt_nom.text 			=	m_compo.nom
									)

									on spn_longueur changed val do (
										m_compo.longueur = val		
										m_rollPrt.actualiser ()
									)
									on edt_nom	 entered txt 	do	(
										m_compo.nom = txt
										m_rollPrt.actualiser ()
									)
									
								)
			fn fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= (
									
									
							-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
									local ptr_plug				= 	_plug
									local ptr_composant  	= 	_composant
									local ptr_geo 				= 	ptr_plug.core.get_geo ()
									local matID					=	ptr_plug.core.get_matID ()
									
							-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
									local ep_dalle 			= ptr_plug.etages_epaiss_dalle
									local ht_niveaux 		= ptr_plug.etages_hauteur
									local longueur 			= ptr_composant.params.longueur
									
									
							-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
									--- Result -------------
									local pt_result_1, pt_result_2, pt_result_3
									
									--- Vecteurs ------------
									local vec_ep_dalle 	= [0,0,1] 		* 	ep_dalle
									local vec_ht 			= [0,0,1] 		* 	ht_niveaux
									local vec_longueur 	= _normDir 	* 	longueur
									
									--- Points d'accroche ------------
									local id_ptAccroche_1 	= pts_accroches[1]
									local id_ptAccroche_2 	= pts_accroches[2]
									local id_ptAccroche_3 	= pts_accroches[3]
									
									local ptAccroche_1		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	
									local ptAccroche_2		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	
									local ptAccroche_3		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	
									
									
									
									---- LA DALLE  -----------------------------------------------------------------------			
									-------	Creation des points 	--------
									local pt_2 		= ptAccroche_1		+ 	vec_longueur
									local pt_3 		= pt_2					+	vec_ep_dalle
									
									--- creation des points --------------
									local pts_pos 	= #( pt_2, pt_3 )
									local pts_ids 	= ptr_geo.points 	pts_pos		
									
									-------	Creation des faces 	--------
									local nvlFace = ptr_geo.face 		#(	 id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2	)		 	
									polyop.setFaceMatID	 ptr_plug.delegate		nvlFace	  ( matID.mur + 1 )
									
									--- Result -------------
									pt_result_1 = pts_ids[1]
									pt_result_2 = pts_ids[2]
									
									
									
									---- LE MUR -----------------------------------------------------------------------			
									-------	Creation des points 	--------
									local pt_3 		= pt_3		+	vec_ht
									
									--- creation des points --------------
									local pts_pos 	= #( pt_3 )
									local pts_ids 	= ptr_geo.points 	pts_pos		
									
									-------	Creation des faces 	--------
									local nvlFace = ptr_geo.face 		#(	 		id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3	)		 	
									polyop.setFaceMatID	 ptr_plug.delegate		nvlFace	  matID.mur
									
									--- Result -------------
									pt_result_3 = pts_ids[1]
									
									
									---- Result final -----------------------------------------------------------------------
									#( pt_result_1, pt_result_2, pt_result_3 )
									
								)
			
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_MUP		"Mur plein"
			nvComposant.set_dialog		dialog
			nvComposant.set_params	 	( params() )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		
		---- Balcon -------------------------------------------
		fn balcon 		=(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 100,
				largeur	= 100
			)
			local dialog  = rollout dialog "Balcon" width:180 height:70	(
											local m_compo
											local m_rollPrt
											local m_param
										
											edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
											GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
											label 'lbl_largeur' "Largeur:" pos:[13,37] width:49 height:13 align:#left
											spinner 'spn_largeur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
											
											fn actualiser =(
												spn_largeur.value 	= 	m_param.largeur
												edt_nom.text 			=	m_compo.nom
											)

											on spn_largeur changed val do 
												m_param.largeur = val		
											
											on edt_nom	 entered txt 	do	(
												m_compo.nom = txt
												m_rollPrt.actualiser ()
											)
											
									)
			fn fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= (
				
				--- Result -------------
				local pt_result_1, pt_result_2, pt_result_3
				
				--- Vecteurs ------------
				local vec_ep_dalle 	= [0,0,1] 			* 	m_plug.etages_epaiss_dalle			
				local vec_longueur 	= _normDir 		* 	m_compo.longueur
				local norm_balcon	= _normDir * rotateZ ( matrix3 1 ) -90
				local vec_largeur		= norm_balcon 	*	 largeur				
				
				--- Points d'accroche ------------
				local id_ptAccroche_1 	= pts_accroches[1]
				local id_ptAccroche_2 	= pts_accroches[2]
				local id_ptAccroche_3 	= pts_accroches[3]
				
				local ptAccroche_1		=	polyop.getVert 	m_plug.delegate		id_ptAccroche_1	
				local ptAccroche_2		=	polyop.getVert 	m_plug.delegate		id_ptAccroche_2	
				local ptAccroche_3		=	polyop.getVert 	m_plug.delegate		id_ptAccroche_3	
				
				
				-------	Placement des points 	--------
				local pt_1 		= ptAccroche_1
				local pt_2 		= pt_1		+  vec_longueur
				local pt_3 		= pt_2		+ 	vec_ep_dalle				
				local pt_4		= pt_1		+ 	vec_ep_dalle
				
				local pt_5		= pt_1		+	vec_largeur
				local pt_6		= pt_2		+	vec_largeur		
				local pt_7		= pt_3		+	vec_largeur
				local pt_8		= pt_4		+	vec_largeur
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
				local pts_ids 	= ptr_geo.points 	pts_pos		
				
				-------	Creation des faces 	--------
				local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[5], 		pts_ids[8], 		pts_ids[4] )		 			
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[7] , 	pts_ids[8] )		 				
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )					
				local nvlFace = ptr_geo.face 		#(	pts_ids[6], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[7] )		 		
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[6], 		pts_ids[5] )		 		
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = ptr_geo.face 		#(	pts_ids[8], 		pts_ids[7], 		pts_ids[3], 		pts_ids[4] )		 				
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )
				
				
				
				
				#()
			)
			
			--- Creation du composant --------------
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_BAL		"Balcon"
			nvComposant.set_dialog		dialog
			nvComposant.set_params	 	( params () )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		
		---- Balcon fin -------------------------------------------
		fn balconFin 	=(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 0
			)
			
			--- les parametres du composant --------------
			local dialog  = rollout dialog "Balcon fin" (
								)
			fn fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= ()
			
			--- Creation du composant --------------
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_BAF		"Balcon fin"
			nvComposant.set_dialog			dialog
			nvComposant.set_params	 	( params () )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		
		
		
		---- INTERFACE -------------------------------------------
	public
		fn creer		_typeDeComposant	=(
			local nvComposant
			case	_typeDeComposant of (
				#espacement:		nvComposant = espacement()
				#murPlein:			nvComposant = murPlein()
				#balcon:				nvComposant = balcon()
				#balconFin:			nvComposant = balconFin()
			)
			append m_items	nvComposant
			nvComposant
		),
		fn get_murPlein = murPlein	(),
		
		-----INIT	--------------
	public
		fn initialiser	_plug	=(
			
			m_plug = _plug
			
		)
		
		
) -- fin creer composant ---------
	

 

------------------------------------------------------------------------------------------------------------------------------------
----------------- FACADE --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
struct 	str_facade (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_facade",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
	---------- MEMBRES	--------------------------------------------------------------------------------------
	public
		---- Base	-----------
		nom 							=	"Façade",
		id								=	"#FACAD_",
		mode						=	1,					---- ( 1:repeter	2:etrier			3:centrer )	----
		
		--- Limiteurs - Murs	---
		murs							=	1,					---- ( 1:les deux	2:gouttereaux	3:pignons )	----
		
		--- Limiteurs - Etages	---
		etages_min_use		=	false,
		etages_min				= 	0,
		etages_max_use			=	false,
		etages_max			=	0,
		
		--- Limiteurs - longueurs	---
		longueur_min_use			=	false,
		longueur_min		= 	0,
		longueur_max_use	=	false,
		longueur_max		=	0,
		
		--- Sequence	---
		sequence					=	#(),
		sequence_longueur		=	0,
		
		
	---------- INTERFACE	--------------------------------------------------------------------------------------
	public
		fn initialiser 		 		=	(
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		),
		
		
		---- Composants -----------------
		fn get_composants_noms =(
			for compo in sequence collect compo.nom
		),
		fn get_sequence_longueur	=(
			sequence_longueur		=	0
			for compo in sequence do
				sequence_longueur	+=	compo.get_longueur ()
			
			sequence_longueur
		),
		
		fn ajouter_composant 		_composant 	=(
			append sequence 		_composant
		),
		fn supprimer_composant 	_composant 	=(
			
		),
		fn dupliquer_composant 	_composant 	=(
			
		),
		fn cloner_composant 		_composant 	=(
			
		),
				
		---- Enregistrement / chargement	-----------------
		fn enregistrer 		_plug 	=(
			
			debug "enregistrer"
			local mgr_datas = _plug.core.get_mgrDatas ()
			
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to _plug.fac_ids.count do
				if _plug.fac_ids[i] == id  do index_facade = i
			
			
			--- s'il n'existe pas encore, on l'ajoute -----
			if index_facade == 0 then (
				debug "enregistrer nouvelle facade"
				append 	_plug.fac_ids 				id
				append 	_plug.fac_noms  			nom
				
				--- Limiteurs - Murs	---
				append 	_plug.fac_murs		 murs
				
				--- Limiteurs - Etages	---
				append 	_plug.fac_etagesMin_uses 		 etages_min_use
				append 	_plug.fac_etagesMin  					etages_min
				append 	_plug.fac_etagesMax_uses 		 etages_max_use
				append 	_plug.fac_etagesMax 					etages_max
				
				--- Limiteurs - longueurs	---
				append 	_plug.fac_longueurMin_uses 	 longueur_min_use
				append 	_plug.fac_longueurMin 				longueur_min
				append 	_plug.fac_longueurMax_uses 		longueur_max_use
				append 	_plug.fac_longueurMax 			 longueur_max
				
				--- la sequence de composants	-------
				append 	_plug.fac_sequences 						( mgr_datas.array_to_string		#() )
				append 	_plug.fac_sequence_longueurs 			sequence_longueur
				
			--- s'il existe, on l'actualise -----
			) else (
				
				debug "enregistrer facade existante"
				debug "id"		var:id
				
				_plug.fac_noms[index_facade] 		=	nom				
				_plug.fac_modes[index_facade]		=	mode
				
				--- Limiteurs - Murs	---
				_plug.fac_murs[index_facade]		= murs
				
				--- Limiteurs - Etages	---
				_plug.fac_etagesMin_uses[index_facade] 		= etages_min_use
				_plug.fac_etagesMin[index_facade]  				=	etages_min
				_plug.fac_etagesMax_uses[index_facade] 		= etages_max_use
				_plug.fac_etagesMax[index_facade] 				=	etages_max
				
				--- Limiteurs - longueurs	---
				_plug.fac_longueurMin_uses[index_facade] 	= longueur_min_use
				_plug.fac_longueurMin[index_facade] 			=	longueur_min
				_plug.fac_longueurMax_uses[index_facade] 	=	longueur_max_use
				_plug.fac_longueurMax[index_facade] 			= longueur_max
				
				-- la sequence	-----
				local sequenceIDs = for compo in sequence collect	compo.id
				_plug.fac_sequences[index_facade] 						= mgr_datas.array_to_string		sequenceIDs		
				_plug.fac_sequence_longueurs[index_facade] 			= sequence_longueur		
				
				--- les composants -----
				for compo in sequence do
					compo.enregistrer _plug			
				
			)
			
			
		),
		
		fn charger	 	_plug		_id  =(
			
			debug "charger"
			debug "_id" var:_id
			
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to _plug.fac_ids.count do (
				debug "id test" var:_plug.fac_ids[i]
				
				if _plug.fac_ids[i] as string == _id as string do (
					index_facade = i
				)
			)
			
			if index_facade != 0 then (
				
				id 								= _plug.fac_noms[index_facade]
				nom 								= _plug.fac_noms[index_facade]
				
				mode							= _plug.fac_modes[index_facade]
				
				--- Limiteurs - Murs	---
				murs								= _plug.fac_murs[index_facade]
				
				--- Limiteurs - Etages	---
				etages_min_use			= _plug.fac_etagesMin_uses[index_facade] 
				etages_min					= _plug.fac_etagesMin[index_facade] 
				etages_max_use			= _plug.fac_etagesMax_uses[index_facade] 
				etages_max					= _plug.fac_etagesMax[index_facade] 
				
				--- Limiteurs - longueurs	---
				longueur_min_use			= _plug.fac_longueurMin_uses[index_facade] 
				longueur_min				= _plug.fac_longueurMin[index_facade] 
				longueur_max_use			= _plug.fac_longueurMax_uses[index_facade] 
				longueur_max				= _plug.fac_longueurMax[index_facade] 
				
				--- Sequence	---
-- 				fac_sequences					= _plug.
-- 				fac_sequence_longueurs		= _plug.
				
			) else messagebox ("Erreur de chargement de facade : " + _id as string )
			
		),
		
		
	---------- EVENEMENTS	--------------------------------------------------------------------------------------
	public
		on create do initialiser ()
	
) -- fin Facade	------------










/* 
struct	str_surface	(
	---------- Membres	--------------------------------------------------------------------------------------
	public
		---- Base	-----------
		nom 							=	"Surface",
		id								=	"#SURF_",
		
		---- Parametres	-----------
		points				=	#(),				----	les points du tracé de la surface 						----
		etages				=	0,					----	le nombre d'étages 										----
		etages_hauteur	=	0,					----	lea hauteur de chaque étages							----
		orientation			=	0.0,				----	l'orientation du faitage pour orienter le batiments	----
		toiture				=	"",					----	ID de la toiture à appliquer à cette surface			----
		
	--- INTERFACE -------------------
	public
		---- Destructeur/Copies	-----------------
		fn supprimer =(
			
		),
		fn dupliquer =(
			
		),
		fn cloner =(
			
		),
		
		---- Parametres	-----------------
		fn ecrire_parametres 	=(
			
		)
)

 */
