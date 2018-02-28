



--- parametres de base	-----------------------------
compo_nom 	= "Mur"	
compo_type	=	#mur
compo_toolTip =	"Ajouter un mur plein de longueur fixe."

--- les parametres du composant	---------
struct compo_params	(
	longueur = 100.
	
)

--- les rollout du composant	---------
rollout compo_dialog "Mur plein" width:180 height:70	(
	
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
	)
	on edt_nom	 entered txt 	do	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	
)

--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		profondeur:0		onConstruitLaDalle:true	= (
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	_composant
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		
-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		local ep_dalle 			= ptr_plug.const_dalle_epaisseur
		local ht_niveaux 		= ptr_plug.etages_hauteur
		local longueur 			= ptr_composant.params.longueur
		
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3
		
		--- Vecteurs ------------
		local vec_ep_dalle 	= [0,0,1] 		* 	ep_dalle
		local vec_ht 				= [0,0,1] 		* 	ht_niveaux
		local vec_longueur 	= _normDir 		* 	longueur
		local vec_prof			= ( _normDir * rotateZ ( matrix3 1 ) 90 ) *  profondeur
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= pts_accroches[1]
		local id_ptAccroche_2 	= pts_accroches[2]
		local id_ptAccroche_3 	= pts_accroches[3] 
		
		local ptAccroche_1		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	) -- + vec_prof
		local ptAccroche_2		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	)  --+ vec_prof
		local ptAccroche_3		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	)  --+ vec_prof
		
		
		
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		+ 	vec_longueur 
		local pt_3 		= pt_2					+	vec_ep_dalle
		
		--- creation des points --------------
		local pts_pos 	= #( pt_2, pt_3 )
		local pts_ids 	= ptr_geo.points 	pts_pos	
		
		-------	Creation des faces 	--------
		if onConstruitLaDalle do (
			local nvlFace = ptr_geo.face 		#( id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2 )		
			ptr_geo.set_matID 	nvlFace	#mur 	
		)
		
		--- Result -------------
		pt_result_1 = pts_ids[1]
		pt_result_2 = pts_ids[2]
		
		
		
		---- LE MUR -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_3 		= pt_3 +	vec_ht
		
		--- creation des points --------------
		local pts_pos 	= #( pt_3 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		local nvlFace = ptr_geo.face 		#( id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3 )		 
		ptr_geo.set_matID 	nvlFace		#mur 	
		
		--- Result -------------
		pt_result_3 = pts_ids[1]
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
parametresTMP = compo_params () 
str_modelBase 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(parametresTMP)	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	