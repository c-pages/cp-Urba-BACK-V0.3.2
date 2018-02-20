



--- parametres de base	-----------------------------
toiture_titre 	= "Toiture plate"	
toiture_type	=	#toiturePlate
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	longueur = 100.
)
--- les rollout du composant	---------
rollout toiture_dialog "Toiture plate" width:180 height:70	(
	local m_rollPrt
	local m_compo
	
	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
	label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_longueur.value 	= 	m_compo.params.longueur
		edt_nom.text 			=	m_compo.nom
	)

	on spn_longueur changed val do (
		m_compo.params.longueur = val
		m_rollPrt.actualiser ()
	)
	on edt_nom	 entered txt 	do	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= (
	
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
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Modele - composant.ms"
--- Creation de la structure mere	-----------------
parametresTMP = toiture_params () 
str_toiture_mere 	tooltip:toiture_tooltip		titre:toiture_titre	type:toiture_type	params:(parametresTMP)	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	