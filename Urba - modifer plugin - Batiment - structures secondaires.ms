
------------- declaration en global car erreurs "plugin no active machin..." -----
global str_plan
global str_facade_modele
global str_createur_de_composant
-- global str_facadeParam_murPlein, str_facadeParam_baie , str_facadeParam_espacement		, str_facadeParam_balcon, str_facadeParam_balconFin
global str_facade, str_facade_composant	, str_ssTrace		/* , str_regle_ssTrace */

global	str_prefs_matID 

struct 	str_prefs_matID (
	mur 				= 	10,
	menuiserie 		= 	20,
	vitrage 			= 	30,
	toiture 			= 	40,
	metal				=	50
)

struct str_plan (
	
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="str_plan",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		a,
		b,
		c,
		d,
		normal ,
		
		fn creerFrom_2vecs_et_1Point	_vec1 	_vec2  	_point	=(
			
-- 			debug "creerFrom_2vecs_et_1Point"
			---le vec normal du plan-----
			local norm1 = normalize _vec1
			local norm2 = normalize _vec2		
			normal =  cross    norm2 	norm1
			
			--- definition equation ---------
			a = normal.x
			b = normal.y
			c = normal.z		
			d = -( a*_point.x + b*_point.y + c*_point.z )
			
-- 			debug "a" var:a
-- 			debug "b" var:b
-- 			debug "c" var:c
-- 			debug "d" var:d
		),
		fn projeter_point_verticalement 		_pt 	=(
-- 			debug "projeter_point_verticalement"
			local result = copy _pt
			result.z =  -( a*_pt.x + b*_pt.y + d ) / c
			result
			
		),
		

		fn get_intersection_segment	_segPt1		_segPt2			=(
			
			local k	= -( a * _segPt1.x 		+	b * _segPt1.y 	+	c * _segPt1.z 	+ d ) 	/	( a * ( _segPt2.x -  _segPt1.x ) + b * ( _segPt2.y -  _segPt1.y )  + c * ( _segPt2.z -  _segPt1.z )  )

			local ptResult 	= [0,0,0]
			ptResult.x 			=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
			ptResult.y 			=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
			ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
			
			ptResult
			
		),
		fn coupe_segment	_segPt1		_segPt2			=(
			
			local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
			-- debug-------
-- 			point pos:pointIntersect isSelected:true
			
			local vecSeg 	= _segPt2 - _segPt1
			local vecInter = pointIntersect - _segPt1
			
			if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
				true
			else
				false
			
		)
		
		
		
		
)



struct str_facade_composant (
	
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
		fn set_params		_params			= ( m_params				= _params ),
		
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
		
		---- Construction du mesh -----------------------
		fn construire			= fnVirt_construire		()
		
) ---- fin composant -------------------------------

struct str_constructeur_composants (
	
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

struct str_facade (
		
		nom 							=	"Façade",
		id								=	"#FACADE_",
		probabilite					=	100,
		
		etages_use_min			=	false,
		etages_nbre_min		= 	0,
		etages_use_max		=	false,
		etages_nbre_max		=	0,
	
		longueur_use_min		=	false,
		longueur_nbre_min	= 	0,
		longueur_use_max		=	false,
		longueur_nbre_max	=	0,
		
		murs							=	1,			---- ( 1:les deux	2:gouttereaux	3:pignons )
		mode						=	1,			---- ( 1:repeter	2:etrier			3:centrer )
		
		sequence					=	#(),
		sequence_longueur	=0
		
		fn initialiser 		 	=(
			---- id unique ----
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		)
) 



/* 
struct	str_ssTrace	(
	
	trace		=	#(),
	etages	=	0,
	toiture	=	#()
	
)




struct str_mgr_composants (
	
	---- Membres ----------------------------------------------------------------------------------------------------------------
	public
		m_this,
		
	private
		m_composants	=	#(),
		
	---- Fonctions ----------------------------------------------------------------------------------------------------------------
	private
		---- Parametres blocks ----
		fn lire_parametres 		=(),
		fn ecrire_parametres 	=(),
		
	---- Creations -------------------------------------------
	public
		---- Creation/Suppression ----
		creer				=	str_constructeur_composants 	m_this:m_this,
		fn supprimer 	=	(),
		
		---- Parametres Block ----
		fn lire			=	lire_parametres(),
		fn ecrire			=	ecrire_parametres()
		
)	--	fin manager de composants ------


 */

/* 
-----------------------	MODELE	-------------------------------------------------------------------------------------------------------------
struct str_facade_modele (
		
		id				= "#FAC_MOD_",			---- "MOD" : modele -----------
		nom 			=	"Modèle",
		
		verts 		= #(),
		edges		= #(),
		faces			= #(),		
		SMs			= #(),
		matIDs		= #(),
		
		longueur 	=  0.,
		hauteur		=	0.,
		
		----- events ------------------------------------------
		on create do 
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		

)


-----------------------	FACADES PARAMETRIQUES	-------------------------------------------------------------------------------------------------------------
struct	str_facadeParam_espacement (
	
	
	public
		m_commun	=	str_facadeParam_commun 	m_parent:this		type:#FAC_PES
		
		dialog 		= 	rollout dialog "Espacement" width:180 height:70	(
								local m_compo, m_rollPrt, m_param
								fn actualiser =()
							),
		
	---- membres  spécifiques	----------
		
		
		
	------ CONSTRUIRE -------
		fn construire	 _id_pt_bas		_id_pt_ht		_normDir		 		= (
		),
		
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		

)

struct	str_facadeParam_murPlein (
		private
			----- membres communs --------------
			m_compo,								---- le composant parant	
			m_this,
			m_construction,
			m_geo,
			matID = str_prefs_matID (),
			
		public
			id				= "#FAC_PMP_",		
			
			dialog 		= 		rollout dialog "Mur plein" width:180 height:70	(
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
										
									),
							
		---- membres  spécifiques	----------
		
		------ fonctions -------
			fn actualiser 			_compo		_construc	= (
				m_construction 		= _construc
				m_geo					=	m_construction.m_geo
				m_compo 				= _compo
				m_this					=	m_construction.m_this
			),
			fn initialiser 			_compo		_construc	= (
				
				actualiser 			_compo		_construc	
				
				m_compo.nom 		= "Mur plein"
				m_compo.longueur 	= 100
				m_compo.hauteur 	= 100
			),
			fn initialiser_dialog 	roll_prt 	=(
				dialog.m_compo 	= m_compo
				dialog.m_rollPrt	= roll_prt
				dialog.m_param	=	this
				dialog.actualiser()
			),
			
			
		------ CONSTRUIRE -------
			fn construire	 pts_accroches		_normDir		 		= (
				
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
				
			),
			
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		
		
)

struct	str_facadeParam_baie (
		
		private
			----- membres communs --------------
			m_compo,								---- le composant parant	
			m_this,
			m_construction,
			m_geo,
			matID = str_prefs_matID (),
		public
	
			---- membres  spécifiques	----------
			baie_allege_hauteur 			= 	100,
			baie_allege_use				=	true,
			baie_hauteur_use				=	true,
			mur_profondeur				= 	20,
			
			menuis_largeur				=	7.,
			menuis_epaisseur				=	3.,			
			menuis_divisions				=	0,
	
			menuis_allege_use			=	false,
			menuis_allege_ht				=	100,
			menuis_trav_use				=	false,
			menuis_trav_ht				=	210,			
			menuis_ouvrant_use			=	true,
			menuis_double_use			=	true,
			
			tablette_use					= true,
			tablette_hauteur 				= 5,
			tablette_debord 				= 5,
			tablette_cote 					= 5,
			
			volet								= false,
			coffre							= false,
			
			----- membres communs --------------
			id				= "#FAC_PBT_",		
			dialog 		= 		
						rollout dialog "Baie " width:200 height:532
						(
							local m_compo
							local m_rollPrt
							local m_param
							
							edittext 'edt_nom' "" pos:[7,3] width:186 height:16 align:#left
							
							label 'lbl19' "Longeur:" pos:[11,37] width:49 height:13 align:#left
							spinner 'spn_longueur' "" pos:[116,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							label 'lbl21' "Hauteur:" pos:[11,53] width:49 height:13 align:#left
							spinner 'spn_hauteur' "" pos:[116,52] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							GroupBox 'grp1' "Baie" pos:[6,21] width:187 height:85 align:#left
							label 'lbl24' "Allège:" pos:[11,68] width:49 height:13 align:#left
							spinner 'spn_allege' "" pos:[116,67] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							checkbutton 'ckb_hauteur' "" pos:[96,51] width:17 height:17 toolTip:"Toute hauteur Valeur négative pour descendre depuis plafond" align:#left
							checkbutton 'ckb_allege' "" pos:[96,67] width:17 height:17 align:#left
							label 'lbl29' "Profondeur:" pos:[11,84] width:59 height:13 align:#left
							spinner 'spn_profondeur' "" pos:[116,83] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							
							
							
							GroupBox 'grp_divers' "Divers" pos:[6,254] width:187 height:114 align:#left
							checkbox 'chk_tablette' "Tablette" pos:[10,269] width:59 height:16 align:#left
							label 'lbl_tablette_hauteur' "Hauteur:" pos:[11,284] width:49 height:13 align:#left
							spinner 'spn_tablette_hauteur' "" pos:[116,283] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							label 'lbl_tablette_debord' "Débord:" pos:[11,299] width:49 height:13 align:#left
							spinner 'spn_tablette_debord' "" pos:[116,298] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							label 'lbl_tablette_cote' "Cotés:" pos:[11,315] width:59 height:13 align:#left
							spinner 'spn_tablette_cote' "" pos:[116,314] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							checkbox 'chk_volets' "Volets" pos:[10,330] width:47 height:16 align:#left
							checkbox 'chk_coffreStore' "Coffre store" pos:[10,344] width:81 height:16 align:#left
							GroupBox 'grp_menuiseries' "Menuiseries" pos:[6,110] width:187 height:141 align:#left
							
							label 'lbl_allege_hauteur' "Hauteur:" pos:[11,199] width:50 height:13 align:#left
							spinner 'spn_allege_hauteur' "" pos:[116,198] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							checkbox 'chk_allege' "Allège" pos:[10,184] width:48 height:16 align:#left
							label 'lbl_traverse_hauteur' "Hauteur:" pos:[11,228] width:50 height:13 align:#left
							spinner 'spn_traverse_hauteur' "" pos:[116,227] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							checkbox 'chk_traverse' "Traverse" pos:[10,213] width:64 height:16 align:#left
							label 'lbl_menuis_epaisseur' "Epaisseur:" pos:[11,139] width:51 height:13 align:#left
							spinner 'spn_menuis_epaisseur' "" pos:[116,138] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							label 'lbl_menuis_largeur' "Largeur:" pos:[11,124] width:42 height:13 align:#left
							spinner 'spn_menuis_Largeur' "" pos:[116,123] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
							checkbox 'chk_double' "Double" pos:[137,154] width:48 height:16 enabled:false align:#left
							checkbox 'chk_ouvrant' "Ouvrant" pos:[10,154] width:57 height:16 align:#left
							
							label 'lb_divisions' "Divisions:" pos:[11,171] width:59 height:13 align:#left
							spinner 'spn_divisions' "" pos:[116,170] width:70 height:16 range:[0,4,0] type:#integer scale:1 align:#left
							
							fn actualiser =(
										spn_longueur.value 			= 	m_compo.longueur
										edt_nom.text 					=	m_compo.nom
										spn_profondeur.value 		=	m_param.mur_profondeur	
										ckb_hauteur.checked		=	m_param.baie_hauteur_use 
										ckb_allege.checked			=	m_param.baie_allege_use
								
										if not ckb_hauteur.checked then (
											spn_hauteur.enabled 	= true
											spn_hauteur.value 		=	m_compo.hauteur 
										) else (
											spn_hauteur.enabled 			= false
											spn_hauteur.indeterminate 	=	true
										)
										if not ckb_allege.checked then (
											spn_allege.enabled 				= true
											spn_allege.value 					=	m_param.baie_allege_hauteur 
										) else (
											spn_allege.enabled 				= false
											spn_allege.indeterminate 		=	true
										)
										
										chk_tablette.checked 				= m_param.tablette_use
										lbl_tablette_hauteur.enabled 		= m_param.tablette_use
										spn_tablette_hauteur.enabled 	= m_param.tablette_use
										lbl_tablette_cote.enabled 			= m_param.tablette_use
										spn_tablette_cote.enabled 		= m_param.tablette_use
										spn_tablette_debord.enabled 	= m_param.tablette_use
										lbl_tablette_debord.enabled 		= m_param.tablette_use
										
										spn_profondeur.value 					=	m_param.mur_profondeur
										spn_tablette_hauteur.value 			=	m_param.tablette_hauteur
										spn_tablette_debord.value 			=	m_param.tablette_debord
										spn_tablette_cote.value 				=	m_param.tablette_cote
										
										spn_tablette_hauteur.indeterminate = not m_param.tablette_use
										spn_tablette_cote.indeterminate 	= not m_param.tablette_use
										spn_tablette_debord.indeterminate 	= not m_param.tablette_use
										
										
										
										spn_menuis_epaisseur.value 				=	m_param.menuis_epaisseur
										spn_menuis_Largeur.value 				=	m_param.menuis_largeur
										chk_double.checked 						=	m_param.menuis_double_use
										chk_ouvrant.checked 						=	m_param.menuis_ouvrant_use
										
										spn_allege_hauteur.value 					=	m_param.menuis_allege_ht
										spn_allege_hauteur.enabled 				=	m_param.menuis_allege_use
										spn_allege_hauteur.indeterminate 		= not m_param.menuis_allege_use
										lbl_allege_hauteur.enabled 				=	m_param.menuis_allege_use
										chk_allege.checked 							=	m_param.menuis_allege_use
										
										spn_traverse_hauteur.value 				=	m_param.menuis_trav_ht
										lbl_traverse_hauteur.enabled 				=	m_param.menuis_trav_use
										spn_traverse_hauteur.indeterminate 	= not m_param.menuis_trav_use
										chk_traverse.checked 						=	m_param.menuis_trav_use
										spn_traverse_hauteur.enabled 			=	m_param.menuis_trav_use
										
										spn_divisions.value 							=	m_param.menuis_divisions
										
										
									)
										
									
							
							
							
							
							
							
							
							on edt_nom entered txt 	do
							(
																					m_compo.nom = txt
																					m_rollPrt.actualiser ()
																				)
							on spn_longueur changed val 	do
								m_compo.longueur 					= val
							on spn_hauteur changed val 	do
								m_compo.hauteur 					= val
							on spn_allege changed val 	do
								m_param.baie_allege_hauteur 	= val
							on ckb_hauteur changed state do
							(
																				m_param.baie_hauteur_use 	= state
																				actualiser ()
																			)
							on ckb_allege changed state do
							(
																				m_param.baie_allege_use 	= state											
																				actualiser ()
																			)
							on spn_profondeur changed val 	do
								m_param.mur_profondeur	= val
							on chk_tablette changed state do
							(
																				m_param.tablette_use 	= state											
																				actualiser ()
																			)
							on spn_tablette_hauteur changed val 	do
								m_param.tablette_hauteur 					= val
							on spn_tablette_debord changed val 	do
								m_param.tablette_debord 	= val
							on spn_tablette_cote changed val 	do
								m_param.tablette_cote	= val
							on spn_allege_hauteur changed val 	do
								m_param.menuis_allege_ht 		= val
							on chk_allege changed state do
							(
																				m_param.menuis_allege_use 	= state											
																				actualiser ()
																			)
							on spn_traverse_hauteur changed val 	do
								m_param.menuis_trav_ht 					= val
							on chk_traverse changed state do
							(
																				m_param.menuis_trav_use 	= state											
																				actualiser ()
																			)
							on spn_menuis_epaisseur changed val 	do
								m_param.menuis_epaisseur 					= val
							on spn_menuis_Largeur changed val 	do
								m_param.menuis_largeur 					= val
							on chk_double changed state do
							(
																				m_param.menuis_double_use 	= state											
																				actualiser ()
																			)
							on chk_ouvrant changed state do
							(
																				m_param.menuis_ouvrant_use 	= state											
																				actualiser ()
																			)
							on spn_divisions changed val 	do
								m_param.menuis_divisions	= val
							
						) -- fin rollout ----------
													
						
						,
			
		------ CONSTRUIRE -------
			fn construire	 pts_accroches		_normDir		 		est_DansBalcon:false	= (
				
				--- Result -------------
				local pt_result_1, pt_result_2, pt_result_3
				
				--- Vecteurs ------------
				local vec_ep_dalle 	= [0,0,1] 		* 	m_this.ep_dalle		
				local vec_allege 		= if baie_allege_use 	then 	[0,0,0] 
																			else		[0,0,1] *	baie_allege_hauteur
				local vec_rtmb 		= if baie_hauteur_use 	then 	[0,0,0] 
																			else		[0,0,1] *	( m_this.niveaux_hauteur - (baie_allege_hauteur + m_compo.hauteur ) )				
				local norm_prof		= _normDir 	* rotateZ ( matrix3 1 ) 90				
				local vec_ht 			= if baie_hauteur_use 	then 	[0,0,1] *	 m_this.niveaux_hauteur
																			else		[0,0,1] * 	m_compo.hauteur				
				local vec_longueur 	= _normDir * m_compo.longueur
				local norm_prof		= _normDir * rotateZ ( matrix3 1 ) 90
				local vec_prof			=  norm_prof * mur_profondeur
				
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
				
				
				
				
				---- LA BAIE -----------------------------------------------------------------------				
				-------	Creation des points 	--------
				--- mur d'allege ----
				local pt_bas 	= ptAccroche_2
				local pt_ht 	= ptAccroche_3
				
				local pt_1 		= pt_bas	+  vec_longueur
				local pt_2 		= pt_1		+  vec_allege
				local pt_3 		= pt_bas	+ 	vec_allege
				
				local pt_4 		= pt_bas	+ 	vec_ht
				local pt_5 		= pt_4		+ 	vec_longueur				
				local pt_6 		= pt_ht		+ 	vec_longueur
				local pt_7 		= pt_3		+ 	vec_prof
				local pt_8 		= pt_2		+ 	vec_prof
				local pt_9 		= pt_5		+ 	vec_prof
				local pt_10		= pt_4		+ 	vec_prof
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
				local pts_ids 	= m_geo.points 	pts_pos		
				
				--- Result -------------
				pt_result_3 = pts_ids[6]
-- 				local pts_results = #(pts_ids[1] , pts_ids[6])
				
				----- pour plus tard, ...  le raccord avec les menuiseries, et return -----
				local ids_pts_racc_menuis =#(pts_ids[7], pts_ids[8], pts_ids[9], pts_ids[10])
				
				-------	Creation des faces 	--------
				local nvlFace = m_geo.face 		#(	id_ptAccroche_2, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 	
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
				
				local nvlFace = m_geo.face 		#(	pts_ids[3], 		pts_ids[2], 		pts_ids[8] , 	pts_ids[7] )		 	
				if tablette_use and not est_DansBalcon	then	polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie
																		else 	polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
				
				local nvlFace = m_geo.face 		#(	pts_ids[10], 	pts_ids[9], 		pts_ids[5], 		pts_ids[4] )		 
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
				
				local nvlFace = m_geo.face 		#(	pts_ids[4], 		pts_ids[5], 		pts_ids[6], 		id_ptAccroche_3 )			 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
				
				local nvlFace = m_geo.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10],   	pts_ids[4] )		 	
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
				
				local nvlFace = m_geo.face 		#(	pts_ids[8], 		pts_ids[2], 		pts_ids[5],   	pts_ids[9] )		 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.mur
				
				
				
				
				
				
				
				
				--- CADRE MENUISERIE ----------------------------------------------------------------------------------------------------------------		
				
				local vec_men_ep			= norm_prof	*	menuis_epaisseur
				local vec_men_lrg			=	_normDir		*	menuis_largeur
				local vec_men_ht			=	[0,0,1] 		*	menuis_largeur
				local vec_men_allegeHt	 =	[0,0,1] 		*	menuis_allege_ht
				local vec_men_travHt		=	[0,0,1] 		*	menuis_trav_ht
				
				-------	Placement des points 	--------
				local pt_A	= polyop.getVert 	m_this.delegate		ids_pts_racc_menuis[1]		
				local pt_B	= polyop.getVert 	m_this.delegate		ids_pts_racc_menuis[2]		
				local pt_C	= polyop.getVert 	m_this.delegate		ids_pts_racc_menuis[3]		
				local pt_D	= polyop.getVert 	m_this.delegate		ids_pts_racc_menuis[4]
				
				local pt_1		= pt_A		+ 	vec_men_lrg 	+ 	vec_men_ht
				local pt_2		= pt_B		- 	vec_men_lrg 	+ 	vec_men_ht
				local pt_3		= pt_C		- 	vec_men_lrg 	- 	vec_men_ht
				local pt_4		= pt_D		+ 	vec_men_lrg 	- 	vec_men_ht
				
				local pt_5		= pt_1		+ 	vec_men_ep
				local pt_6		= pt_2		+ 	vec_men_ep
				local pt_7		= pt_3		+ 	vec_men_ep
				local pt_8		= pt_4		+ 	vec_men_ep
				
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
				local pts_ids 	= m_geo.points 	pts_pos		
				
				----- pour plus tard, ... 
				local pts_pourOuvrant	= #( pt_5, pt_6, pt_7, pt_8  )
				
				---- cadre ------
				local nvlFace = m_geo.face 		#(	ids_pts_racc_menuis[1]	, 			ids_pts_racc_menuis[2]	, 			ids_pts_racc_menuis[3]	, 			ids_pts_racc_menuis[4]	 ,
													pts_ids[4], 		pts_ids[3], 		pts_ids[2], 		pts_ids[1] , 	
													pts_ids[4], 		ids_pts_racc_menuis[4]	 )		 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
				
				local nvlFace = m_geo.face 		#(	pts_ids[1], 	pts_ids[2], 	pts_ids[6],   	pts_ids[5]  )			 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie	
				local nvlFace = m_geo.face 		#(	pts_ids[6], 	pts_ids[2], 	pts_ids[3],   	pts_ids[7]  )			 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie	
				local nvlFace = m_geo.face 		#(	pts_ids[7], 	pts_ids[3], 	pts_ids[4],   	pts_ids[8]  )			 		
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie	
				local nvlFace = m_geo.face 		#(	pts_ids[1], 	pts_ids[5], 	pts_ids[8],   	pts_ids[4]  )			 			
				polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie
				
				--- la face du fond -----------
-- 				if not menuis_ouvrant_use do (
					local nvlFace = m_geo.face 		#(	pts_ids[5], 	pts_ids[6], 	pts_ids[7],   	pts_ids[8]  )			 			
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.vitrage
				
-- 				)
				
				
													
													
													
				
				
				--- TABLETTE  ----------------------------------------------------------------------------------------------------------------		
				if tablette_use and not est_DansBalcon do (
					
					local vec_tab_ht		= 	[0,0,1] 		* tablette_hauteur
					local vec_tab_deb	= -norm_prof 	* tablette_debord
					local vec_tab_cote	= _normDir 	* tablette_cote					
					
					-------	Placement des points 	--------
					local pt_1 		= pt_bas	+  vec_allege 	- 	vec_tab_ht		-	vec_tab_cote	+ vec_tab_deb
					local pt_2 		= pt_1		+  2 * vec_tab_cote 				+	vec_longueur 	
					local pt_3 		= pt_2		+ 	vec_tab_ht				
					local pt_4		= pt_1		+ 	vec_tab_ht
					
					local pt_5		= pt_1		-	vec_tab_deb
					local pt_6		= pt_2		-	vec_tab_deb			
					local pt_7		= pt_3		-	vec_tab_deb
					local pt_8		= pt_4		-	vec_tab_deb
					
					--- creation des points --------------
					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
					local pts_ids 	= m_geo.points 	pts_pos		
					
					-------	Creation des faces 	--------
					local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )		 			
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					local nvlFace = m_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )		 				
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie					
					local nvlFace = m_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )		 		
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4], 		pts_ids[8] )		 		
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					local nvlFace = m_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7], 		pts_ids[3] )		 				
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					
				)
				
				
				
				
				---  ALLEGE  ----------------------------------------------------------------------------------------------------------------	
				if menuis_allege_use do (
					local vec_allege_ht = vec_men_ht * 1.5
					-------	Placement des points 	--------
					local pt_1 		= pt_bas	+ 	[0,0,1] * menuis_allege_ht	- 	 vec_allege_ht	 + vec_men_lrg + vec_prof
					local pt_2 		= pt_1		+	vec_longueur 			- 2 * vec_men_lrg 
					local pt_3 		= pt_2		+   vec_allege_ht	
					local pt_4		= pt_1		+ 	 vec_allege_ht
					
					local pt_5		= pt_1		+	vec_men_ep
					local pt_6		= pt_2		+	vec_men_ep			
					local pt_7		= pt_3		+	vec_men_ep
					local pt_8		= pt_4		+	vec_men_ep
					
					
					--- creation des points --------------
					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
					local pts_ids 	= m_geo.points 	pts_pos		
					
					
					-------	Creation des faces 	--------
					local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )		 			
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie						
					local nvlFace = m_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )		 				
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie					
					local nvlFace = m_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )		 		
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					
-- 					-- la face vitre du bas
-- 					local pts_pos 	= #( 	 pts_pourOuvrant[1], pts_pourOuvrant[2] ,pt_6 , pt_5)
-- 					local pts_ids 	= m_geo.points 	pts_pos		m_this
-- 					local nvlFace = m_geo.face 		#(pts_ids[1], 		pts_ids[2]	, 		pts_ids[3] , 	pts_ids[4] )		 m_this		
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.vitrage			
					
					----- pour plus tard, ... 
-- 					pts_pourOuvrant[1]		= pt_8
-- 					pts_pourOuvrant[2]		= pt_7
					
				)
				
				
				local pos_largeur_temp1 = pts_pourOuvrant[1]
				local pos_largeur_temp2 = pts_pourOuvrant[4]
				--- DOUBLE  ----------------------------------------------------------------------------------------------------------------	
				for i = 1 to  menuis_divisions  do (
-- 				if menuis_double_use do (
					
					local largeur_vitre = ( distance	pts_pourOuvrant[1] 	pts_pourOuvrant[2] ) / ( menuis_divisions + 1 )
					
					-------	Placement des points 	--------
					local pt_1		= pts_pourOuvrant[1]   			- 		vec_men_lrg - vec_men_ep 	+ _normDir * largeur_vitre * i 
					local pt_2		= pt_1 + 2 * vec_men_lrg
					local pt_3		= pts_pourOuvrant[4]   			+ 		vec_men_lrg - vec_men_ep	+ _normDir * largeur_vitre * i 
					local pt_4		= pt_3  - 2 * vec_men_lrg
					
					local pt_5		= pt_1		+ 	vec_men_ep
					local pt_6		= pt_2		+ 	vec_men_ep
					local pt_7		= pt_3		+ 	vec_men_ep
					local pt_8		= pt_4		+ 	vec_men_ep
					
					--- creation des points --------------
					local pts_pos 	= #( pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
					local pts_ids 	= m_geo.points 	pts_pos		
					
					---- faces ------
					local nvlFace = m_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )			 					
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					local nvlFace = m_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )			 					
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )			 					
					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
					
					if menuis_ouvrant_use do (
						
						local pt_1_men = pt_1
						local pt_2_men = pt_2
						local pt_3_men = pt_3
						local pt_4_men = pt_4
						
						local vec_bandeau_ep = vec_men_ep/2
						
						-------	Placement des points 	--------
						local pt_1		= pt_1_men	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
						local pt_2		= pt_2_men 	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
						local pt_3		= pt_3_men	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
						local pt_4		= pt_4_men  	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
						
						local pt_5		= pt_1		+ 	vec_bandeau_ep
						local pt_6		= pt_2		+ 	vec_bandeau_ep
						local pt_7		= pt_3		+ 	vec_bandeau_ep
						local pt_8		= pt_4		+ 	vec_bandeau_ep
						
						--- creation des points --------------
						local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
						local pts_ids 	= m_geo.points 	pts_pos		
						
						---- faces ------
						local nvlFace = 	m_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )			 						
						polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
						local nvlFace = 	m_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )			 						
						polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
						local nvlFace = 	m_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )			 					
						polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
						
					)
				)
				
				
-- 				
-- 				--- OUVRANT  ----------------------------------------------------------------------------------------------------------------	
-- 				if menuis_ouvrant_use do (
-- 					
-- 					-------	Placement des points 	--------
-- 					local pt_1		= pts_pourOuvrant[1]
-- 					local pt_2		= pts_pourOuvrant[2]
-- 					local pt_3		= pts_pourOuvrant[3]
-- 					local pt_4		= pts_pourOuvrant[4]
-- 					
-- 					local pt_5		= pt_1		+ 	vec_men_lrg 	+ 	vec_men_ht
-- 					local pt_6		= pt_2		- 	vec_men_lrg 	+ 	vec_men_ht
-- 					local pt_7		= pt_3		- 	vec_men_lrg 	- 	vec_men_ht
-- 					local pt_8		= pt_4		+ 	vec_men_lrg 	- 	vec_men_ht
-- 					
-- 					local pt_9		= pt_5		+ 	vec_men_ep
-- 					local pt_10		= pt_6		+ 	vec_men_ep
-- 					local pt_11		= pt_7		+ 	vec_men_ep
-- 					local pt_12		= pt_8		+ 	vec_men_ep
-- 					
-- 					local pts_pourOuvrant	= #( pt_9, pt_10, pt_11, pt_12  )
-- 					
-- 					--- creation des points --------------
-- 					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 , pt_9, pt_10, pt_11, pt_12 )
-- 					local pts_ids 	= m_geo.points 	pts_pos		m_this
-- 					
-- 					---- cadre ------
-- 					
-- 					local nvlFace = m_geo.face 		#(	pts_ids[1]	, pts_ids[2], pts_ids[3], pts_ids[4], pts_ids[8], pts_ids[7], pts_ids[6], pts_ids[5], pts_ids[8], pts_ids[4] )		 m_this				
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie					
-- 					
-- 					local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[10],   	pts_ids[9]  )			 m_this			
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
-- 					local nvlFace = m_geo.face 		#(	pts_ids[10], 	pts_ids[6], 		pts_ids[7],   	pts_ids[11]  )			 m_this			
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
-- 					local nvlFace = m_geo.face 		#(	pts_ids[12], 	pts_ids[11], 	pts_ids[7],   	pts_ids[8]  )			 m_this			
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
-- 					local nvlFace = m_geo.face 		#(	pts_ids[5], 		pts_ids[9], 		pts_ids[12],   	pts_ids[8]  )			 m_this			
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.menuiserie			
-- 	-- 					
-- 	-- 					----vitrage
-- 					local nvlFace = m_geo.face 		#(	pts_ids[9], 		pts_ids[10], 		pts_ids[11],   	pts_ids[12]  )			 m_this			
-- 					polyop.setFaceMatID	 m_this.delegate		nvlFace	  matID.vitrage			
-- 					
-- 				)
				
				
				
				
				----------------------------
-- 				format "-------------> 	BAIE -> pt_results :%\n" #( pt_result_1, pt_result_2, pt_result_3 )
				
				---- Result final -----------------------------------------------------------------------
				#( pt_result_1, pt_result_2, pt_result_3 )
				
				
			),
			
			
		------ fonctions -------
			fn actualiser 			_compo		_construc	= (
				m_construction 		= _construc
				m_geo					=	m_construction.m_geo
				m_compo 				= _compo
				m_this					=	m_construction.m_this
			),
			
			fn initialiser 			_compo		_construc	= (
				
				actualiser 			_compo		_construc	
				
				m_compo.nom 		= "Baie"
				m_compo.longueur 	= 100
				m_compo.hauteur 	= 210
			),
			
			fn initialiser_dialog 	roll_prt 	=(
				dialog.m_compo 	= m_compo
				dialog.m_rollPrt	= roll_prt
				dialog.m_param	=	this
				dialog.actualiser()
			),
			
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		
)

struct	str_facadeParam_balcon (
	private
		----- membres communs --------------
		m_compo,								---- le composant parant	

		m_construction,
		m_geo,
		m_this,
		matID = str_prefs_matID (),
		
	public
		id				= "#FAC_PBD_",			--- Parametre Balcon Debut
		dialog 		= 		
	rollout dialog "Balcon" width:180 height:70	(
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
										
								),
						
	---- membres  spécifiques	----------
		largeur				= 100,
		
		gardeCorps			=	0,
		
-- 		balcon_fin			=	#(),
		
		
		
		
		
		
		
	------ fonctions -------
		fn actualiser 			_compo		_construc	= (
			m_construction 		= _construc
			m_geo					=	m_construction.m_geo
			m_compo 				= _compo
			m_this					=	m_construction.m_this
		),
		
		fn initialiser 			_compo		_construc	= (
			
			actualiser 			_compo		_construc	
			
			m_compo.nom 		= "Balcon"
			m_compo.longueur 	= 0
			m_compo.hauteur 	= 0
		),
		fn initialiser_dialog 	roll_prt 	=(
			dialog.m_compo 	= m_compo
			dialog.m_rollPrt	= roll_prt
			dialog.m_param	=	this
			dialog.actualiser()
		),
		
		
	------ CONSTRUIRE -------
		fn construire	 pts_accroches		_normDir				 		= (
			
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
		),
		
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	


)

struct	str_facadeParam_balconFin (
	private
		----- membres communs --------------
		m_compo,								---- le composant parant	
		m_this,
		m_construction,
		m_geo,
		matID = str_prefs_matID (),
		
	public
	id				= "#FAC_PBF_",			--- Parametre Balcon Fin
	dialog 		= 		
	rollout dialog "Balcon - fin" width:180 height:70	(
									local m_compo
									local m_rollPrt
									local m_param
									
										fn actualiser =(
										)

								),
						
	---- membres  spécifiques	----------
		
-- 		balcon_debut		=	#(),
								
		
		
	------ fonctions -------
		fn actualiser 			_compo		_construc	= (
			m_construction 		= _construc
			m_geo					=	m_construction.m_geo
			m_compo 				= _compo
			m_this					=	m_construction.m_this
		),
		
		fn initialiser 			_compo		_construc	= (
			
			actualiser 			_compo		_construc	
			
			m_compo.nom 		= "Balcon - fin"
			m_compo.longueur 	= 0
			m_compo.hauteur 	= 0
		),
		fn initialiser_dialog 	roll_prt 	=(
			dialog.m_compo 	= m_compo
			dialog.m_rollPrt	= roll_prt
			dialog.m_param	=	this
			dialog.actualiser()
		),
		
		
	------ CONSTRUIRE -------
		fn construire	 _id_pt_bas		_id_pt_ht		_normDir		 		= (
	-- 		format "CONSTRUIRE : lg = %\n" m_compo.longueur
			local pt1 =  polyop.getVert 	m_this.delegate		_id_pt_bas	
			local pt2 = pt1 + _normDir * m_compo.longueur
			
			m_construction.creer_mur 	_id_pt_bas		_id_pt_ht	pt2 			matID:matID.mur
			
		),
		
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	


)

struct	str_facadeParam_modele (
	private
		----- membres communs --------------
		m_compo,								---- le composant parant	

		m_construction,
		m_geo,
		m_this,
		matID = str_prefs_matID (),
		
	public
		id				= "#FAC_PBF_",			--- Parametre Balcon Fin
		dialog 		= 		
		rollout dialog "Balcon - fin" width:180 height:70	(
										local m_compo
										local m_rollPrt
										local m_param
										
											fn actualiser =(
											)

									),
						
	---- membres  spécifiques	----------
		
-- 		balcon_debut		=	#(),
								
		
		
	------ fonctions -------
	private	
		
		--------------------------------------------------------------------------------------------------------
		----------------	 Manipulations MODELE	 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------		
		fn positionnerPivot_modele	 _node =(
			local segmentsOuverts 	= polyop.getOpenEdges _node
			local pointsSegsOuverts 	=#()
			local pointsResult 			=[0,0,0]
			for seg in segmentsOuverts do (
				local ptsDuSegment = polyop.getVertsUsingEdge   _node	seg
				for pt in ptsDuSegment do
					appendIfUnique pointsSegsOuverts	pt
			)
			
			--- on cherche le point  ------
			format "pointsSegsOuverts : %\n" pointsSegsOuverts
			
			for idPt in pointsSegsOuverts do (
				
				if idPt == pointsSegsOuverts[1] then pointsResult = _node.verts[ idPt ].pos
				else (
					local pt =_node.verts[ idPt ].pos
					if pt.x < pointsResult.x do pointsResult = pt
					if pt.y < pointsResult.y do pointsResult = pt
					if pt.z < pointsResult.z do pointsResult = pt
				)
			)
			_node.pivot = pointsResult
			
		),
		fn preparer_modele 	_node	=(
			
				--- preparation du model -------
				local nvModel_node = copy _node 
				convertToPoly 	nvModel_node
				local  BB = nodeGetBoundingBox 	nvModel_node	(matrix3 1)
				positionnerPivot_modele 	nvModel_node
				nvModel_node.rotation = quat 0 0 0 1
				nvModel_node.pos  = [0,0,0]
				
				nvModel_node
		),
		
	
	public
		fn actualiser 			_compo		_construc	= (
			m_construction 		= _construc
			m_geo					=	m_construction.m_geo
			m_compo 				= _compo
			m_this					=	m_construction.m_this
		),
		
		fn initialiser 			_compo		_construc	= (
			
			actualiser 			_compo		_construc	
			
			m_compo.nom 		= "Balcon - fin"
			m_compo.longueur 	= 0
			m_compo.hauteur 	= 0
		),
		fn initialiser_dialog 	roll_prt 	=(
			dialog.m_compo 	= m_compo
			dialog.m_rollPrt	= roll_prt
			dialog.m_param	=	this
			dialog.actualiser()
		),
		
		
	------ CONSTRUIRE -------
		fn construire	 _id_pt_bas		_id_pt_ht		_normDir		 		= (
	-- 		format "CONSTRUIRE : lg = %\n" m_compo.longueur
			local pt1 =  polyop.getVert 	m_this.delegate		_id_pt_bas	
			local pt2 = pt1 + _normDir * m_compo.longueur
			
			m_construction.creer_mur 	_id_pt_bas		_id_pt_ht	pt2 			matID:matID.mur
			
		),
		
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	


)




-----------------------	FACADE	-------------------------------------------------------------------------------------------------------------
struct str_facade_composant (
		
		id							= "#FAC_CMP_",						---- "CMP" : composant -----------
		nom 						=	"Composant de façade",
		
		type						= #Espacement,		--->	#Espacement		#LongueurFixe		#Modele		#Parametrique
		
		longueur					=	0.,	
		hauteur					= 	0.,
		
		modeles					=	#(),
		modeles_probas		=	#(),
		
		param					= 	#(),				
		
		----- events ------------------------------------------
		on create do (
			---- generation de l'id unique -------
			if type == #Espacement then 
				id = "#FAC_CMP_ESP"
			else
				for i= 1 to 10 do id += ( random 0 9 ) as string	
		)
		
	
)

 
struct	str_regle_ssTrace	(
	private
		trace_ptr,
		
	public
		nom 					=	"Sous Tracé",
		id						=	"",
		
		nombre_etages	=	0,
		surface_min		= 15.,
		surface_min_use	= true,
		surface_max		= 25.,
		surface_max_use	= true,
		toiture				=	#(),
		
		fn initialiser 	_trace_ptr =(
			trace_ptr = _trace_ptr
		)
)


 */



