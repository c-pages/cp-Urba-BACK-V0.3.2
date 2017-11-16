



struct 	str_composant (
	
	------ Membres ------------------------------------------------------------------------------
	private
		---- Parametres -----------------------------------
		m_id					=	"#",		
		m_type				=	undefined,
		m_nom				=	"",
		m_params			=	undefined,
		
		---- Pointeurs -----------------------------------
		m_plugThis		=	undefined,
		m_construction	=	undefined,
		m_geo				=	undefined,
		m_matID 			= 	str_prefs_matID (),
		
		---- Rollout -----------------------------------
		m_dialog 			= undefined,
		
		---- Fonction virtuelle pure pour construire le composant	----
		fnVirt_construire	= (),
		
	------ Fonctions ------------------------------------------------------------------------------
	public
		---- Mutations -----------------------
		fn set_dialog 		_dialog 				= ( m_dialog 				= _dialog ),
		fn set_construire 	_fnConstruire 	= ( fnVirt_construire 	= _fnConstruire ),
		fn set_params		_params				= ( m_params				= _params ),
		
		---- Accessions -----------------------
		fn get_dialog			=	m_dialog,
		fn get_params			=	m_params,
		
		--- Initialisations -----------------------
		fn initialiser_dialog 	_roll_parent 	=(
			dialog.m_rollPrt	= 	_roll_parent
			dialog.m_param	=	m_params
			dialog.actualiser()
		),
		fn initialiser 			_plugThis	_type	_nom 	=(
			---- id unique ----
			m_id += _type
			for i= 1 to 10 do m_id += ( random 0 9 ) as string	
			
			m_type 				=	_type 			
			m_nom				=	_nom
			m_plugThis			=	_plugThis
			m_construction 	= 	m_plugThis.construction
			m_geo				=	m_plugThis.geo	
		),
		
		---- Construction du mesh 	( fonction virtuelle ) -----------------------
		fn construire			= fnVirt_construire		(),
		
		
		---- Destructeur/Copies	-----------------
		fn supprimer =(
			
		),
		fn dupliquer =(
			
		),
		fn cloner =(
			
		)
		
) ---- fin composant -------------------------------

struct 	str_constructeur_composants (
	
		m_this,
		
		---- Espacement -------------------------------------------
		fn espacement =(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 0
			)
			local dialog  = rollout dialog "Espacement" width:180 height:70	(
									local m_compo, m_rollPrt, m_param
									fn actualiser =()
								)
			fn fnConstruire   pts_accroches		_normDir		=()
			
			--- Creation du composant --------------
			local nvComposant = str_facade_composant 	()
			nvComposant.initialiser			m_this			#FAC_COMP_ESP		"Espacement"
			nvComposant.set_dialog		dialog
			nvComposant.set_params	 	params
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
									GroupBox 'grp1' "G�n�rale" pos:[6,21] width:167 height:37 align:#left
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
			fn fnConstruire  pts_accroches		_normDir		 		= (
									
									--- Result -------------
									local pt_result_1, pt_result_2, pt_result_3
									
									--- Vecteurs ------------
									local vec_ep_dalle 	= [0,0,1] 		* 	m_this.ep_dalle		
									local vec_ht 			= [0,0,1] 		* 	m_this.niveaux_hauteur				
									local vec_longueur 	= _normDir 	* 	m_compo.longueur
									
									--- Points d'accroche ------------
									local id_ptAccroche_1 	= pts_accroches[1]
									local id_ptAccroche_2 	= pts_accroches[2]
									local id_ptAccroche_3 	= pts_accroches[3]
									
									local ptAccroche_1		=	polyop.getVert 	m_this.delegate		id_ptAccroche_1	
									local ptAccroche_2		=	polyop.getVert 	m_this.delegate		id_ptAccroche_2	
									local ptAccroche_3		=	polyop.getVert 	m_this.delegate		id_ptAccroche_3	
									
									
									
									---- LA DALLE  -----------------------------------------------------------------------				
									-------	Creation des points 	--------
									local pt_2 		= ptAccroche_1		+ 	vec_longueur
									local pt_3 		= pt_2					+	vec_ep_dalle
									
									--- creation des points --------------
									local pts_pos 	= #( pt_2, pt_3 )
									local pts_ids 	= m_geo.points 	pts_pos		
									
									-------	Creation des faces 	--------
									local nvlFace = m_geo.face 		#(	 id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2	)		 	
									polyop.setFaceMatID	 m_this.delegate		nvlFace	  ( matID.mur + 1 )
									
									--- Result -------------
									pt_result_1 = pts_ids[1]
									pt_result_2 = pts_ids[2]
									
									
									
									---- LE MUR -----------------------------------------------------------------------			
									-------	Creation des points 	--------
									local pt_3 		= pt_3		+	vec_ht
									
									--- creation des points --------------
									local pts_pos 	= #( pt_3 )
									local pts_ids 	= m_geo.points 	pts_pos		
									
									-------	Creation des faces 	--------
									local nvlFace = m_geo.face 		#(	 		id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3	)		 	
									polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
									
									--- Result -------------
									pt_result_3 = pts_ids[1]
									
									
									---- Result final -----------------------------------------------------------------------
									#( pt_result_1, pt_result_2, pt_result_3 )
									
								)
			
			local nvComposant = str_facade_composant 	()
			nvComposant.initialiser			m_this			#FAC_COMP_MUP		"Mur plein"
			nvComposant.set_dialog		dialog
			nvComposant.set_params	 	params
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
											GroupBox 'grp1' "G�n�rale" pos:[6,21] width:167 height:37 align:#left
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
			fn fnConstruire  	pts_accroches		_normDir				 		= (
				
				--- Result -------------
				local pt_result_1, pt_result_2, pt_result_3
				
				--- Vecteurs ------------
				local vec_ep_dalle 	= [0,0,1] 			* 	m_this.ep_dalle			
				local vec_longueur 	= _normDir 		* 	m_compo.longueur
				local norm_balcon	= _normDir * rotateZ ( matrix3 1 ) -90
				local vec_largeur		= norm_balcon 	*	 largeur				
				
				--- Points d'accroche ------------
				local id_ptAccroche_1 	= pts_accroches[1]
				local id_ptAccroche_2 	= pts_accroches[2]
				local id_ptAccroche_3 	= pts_accroches[3]
				
				local ptAccroche_1		=	polyop.getVert 	m_this.delegate		id_ptAccroche_1	
				local ptAccroche_2		=	polyop.getVert 	m_this.delegate		id_ptAccroche_2	
				local ptAccroche_3		=	polyop.getVert 	m_this.delegate		id_ptAccroche_3	
				
				
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
				local pts_ids 	= m_geo.points 	pts_pos		
				
				-------	Creation des faces 	--------
				local nvlFace = m_geo.face 		#(	pts_ids[1], 		pts_ids[5], 		pts_ids[8], 		pts_ids[4] )		 			
				polyop.setFaceMatID	 m_this.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[7] , 	pts_ids[8] )		 				
				polyop.setFaceMatID	 m_this.delegate		nvlFace	   ( matID.mur + 1 )					
				local nvlFace = m_geo.face 		#(	pts_ids[6], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[7] )		 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = m_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[6], 		pts_ids[5] )		 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = m_geo.face 		#(	pts_ids[8], 		pts_ids[7], 		pts_ids[3], 		pts_ids[4] )		 				
				polyop.setFaceMatID	 m_this.delegate		nvlFace	   ( matID.mur + 1 )
				
				
				
				
				#()
			)
			
			--- Creation du composant --------------
			local nvComposant = str_facade_composant 	()
			nvComposant.initialiser			m_this			#FAC_COMP_BAL		"Balcon"
			nvComposant.set_dialog		dialog
			nvComposant.set_params	 	params
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		
		---- Balcon fin -------------------------------------------
		fn balconFin 	=(
			
			--- les parametres du composant --------------
			local dialog  = rollout dialog "Balcon fin" (
								)
			fn fnConstruire   pts_accroches		_normDir		=()
			
			--- Creation du composant --------------
			local nvComposant = str_facade_composant 	()
			nvComposant.initialiser			m_this			#FAC_COMP_BAF		"Balcon fin"
			nvComposant.set_dialog		dialog
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
		)

) -- fin creer composant ---------
	

 

------------------------------------------------------------------------------------------------------------------------------------
----------------- FACADE --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
struct 	str_facade (
	
	---------- MEMBRES	--------------------------------------------------------------------------------------
	public
		---- Base	-----------
		nom 							=	"Fa�ade",
		id								=	"#FACAD_",
		
		---- proba g�n�rale -----------
		probabilite					=	100,
		
		--- Limiteurs - Etages	---
		etages_use_min			=	false,
		etages_nbre_min			= 	0,
		etages_use_max			=	false,
		etages_nbre_max			=	0,
		
		--- Limiteurs - longueurs	---
		longueur_use_min			=	false,
		longueur_nbre_min		= 	0,
		longueur_use_max		=	false,
		longueur_nbre_max		=	0,
		
		--- Limiteurs - Murs	---
		murs							=	1,					---- ( 1:les deux	2:gouttereaux	3:pignons )	----
		mode							=	1,					---- ( 1:repeter	2:etrier			3:centrer )	----
		
		--- Sequence	---
		sequence					=	#(),
		sequence_longueur		=	0,
		
		
-- 		mgr_composants			= str_mgr_arrayParametres (),
		
	---------- INTERFACE	--------------------------------------------------------------------------------------
	public
		fn initialiser 		 		=	(
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		),
		
		
		---- Composants -----------------
		fn ajouter_composant 	_type 	=(
			case _type of (
				#espacement: 	()
			)
		),
		fn supprimer_composant 	_composant 	=(
			
		),
		fn dupliquer_composant 	_composant 	=(
			
		),
		fn cloner_composant 		_composant 	=(
			
		),
		
		---- Destructeur/Copies	-----------------
		fn supprimer =(
			
		),
		fn dupliquer =(
			
		),
		fn cloner =(
			
		),
		
		
		---- Parametres	-----------------
		fn ecrire_parametres 	=(
			
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
		points				=	#(),				----	les points du trac� de la surface 						----
		etages				=	0,					----	le nombre d'�tages 										----
		etages_hauteur	=	0,					----	lea hauteur de chaque �tages							----
		orientation			=	0.0,				----	l'orientation du faitage pour orienter le batiments	----
		toiture				=	"",					----	ID de la toiture � appliquer � cette surface			----
		
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