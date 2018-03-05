

	
	
( ----	FileIn ----


--- parametres de base	-----------------------------
compo_nom 	= "Loggia"	
compo_type	=	#loggia
compo_toolTip =	""


--- les parametres du composant	---------
struct compo_params	(
	longueur = 0,
	profondeur	= 100
)


--- les rollout du composant	---------
rollout compo_dialog "Loggia" width:180 height:70	(
	
	local m_compo
	local m_rollPrt
	local m_plug

	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
	label 'lbl_profondeur' "profondeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_profondeur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_profondeur.value 	= 	m_compo.params.profondeur
		edt_nom.text 		=	m_compo.nom
	)

	on spn_profondeur changed val do 
		m_compo.params.profondeur = val		
	
	on edt_nom	 entered txt 	do	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	
)


--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		norm_dir:		 this:		onConstruitLaDalle:false	 = (
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
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
		local vec_longueur 	= norm_dir 	* 	longueur
		local vec_prof			= ( norm_dir * rotateZ ( matrix3 1 ) 90 ) *  this.params.profondeur 
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= pts_accroches[1]
		local id_ptAccroche_2 	= pts_accroches[2]
		local id_ptAccroche_3 	= pts_accroches[3] 
		
		local ptAccroche_1		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	) 
		local ptAccroche_2		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	) 
		local ptAccroche_3		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	) 
		
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		+ vec_prof
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
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----
	
	
	
	
	
	
	