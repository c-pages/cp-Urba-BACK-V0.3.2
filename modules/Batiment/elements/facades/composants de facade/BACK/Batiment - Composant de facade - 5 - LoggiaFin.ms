
(	----	FileIn ----


--- parametres de base	-----------------------------
compo_nom 	= "Loggia fin"	
compo_type	=	#loggiaFin
compo_toolTip =	""




--- les rollout du composant	---------
rollout compo_dialog "Loggia fin" width:180 height:70	(
	local m_rollPrt
	local m_compo
	local m_plug
	fn actualiser =()
)

--- les parametres du composant	---------
struct compo_params	(
	longueur = 0,
	profondeur	= 100
)



--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		norm_dir:		 this:		onConstruitLaDalle:false	 		onConstruit_gardeCorps:	compo_debut:	=(
	
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
		local vec_longueur 	= norm_dir 	* 	longueur 		* 	-1
		local vec_prof			= ( norm_dir * rotateZ ( matrix3 1 ) 90 ) 	*  this.params.profondeur 
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= pts_accroches[1]
		local id_ptAccroche_2 	= pts_accroches[2]
		local id_ptAccroche_3 	= pts_accroches[3] 
		
		local ptAccroche_1		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	) 
		local ptAccroche_2		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	) 
		local ptAccroche_3		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	) 
		
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		- 	vec_prof
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
		local nvlFace 	= ptr_geo.face 		#( id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3 )		 
		ptr_geo.set_matID 	nvlFace		#mur 	
		
		--- Result -------------
		pt_result_3 		= pts_ids[1]
		
		
		
		
		
		---- Les FACEs DU SOL  -----------------------------------------------------------------------		
		---face du dessus ---
		-------	Creation des points 	--------
		local pt_sol_1 		= ptAccroche_2
		local pt_sol_2 		= pt_sol_1 		- 	vec_prof
		local pt_sol_3 		= pt_sol_2 		+ 	vec_longueur
		local pt_sol_4		= pt_sol_3 		+ 	vec_prof
		
		--- creation des points --------------
		local pts_pos 	= #( pt_sol_1, pt_sol_2, pt_sol_3, pt_sol_4 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		local nvlFace 	= ptr_geo.face 		#( pts_ids[4], 	pts_ids[3], pts_ids[2], pts_ids[1])		  
		ptr_geo.set_matID 	nvlFace		#mur 	
		
		
		
		---face du dessous ---
		-------	Creation des points 	--------
		local pt_solDessous_1 		= ptAccroche_3
		local pt_solDessous_2 		= pt_solDessous_1 		- 	vec_prof
		local pt_solDessous_3 		= pt_solDessous_2 		+ 	vec_longueur
		local pt_solDessous_4		= pt_solDessous_3 		+ 	vec_prof
		
		--- creation des points --------------
		local ptsDessous_pos 	= #( pt_solDessous_1, pt_solDessous_2, pt_solDessous_3, pt_solDessous_4 )
		local ptsDessous_ids 	= ptr_geo.points 	ptsDessous_pos		
		
		-------	Creation des faces 	--------
		local nvlFace 	= ptr_geo.face 		#( ptsDessous_ids[4], 	ptsDessous_ids[3], ptsDessous_ids[2], ptsDessous_ids[1])		 
		ptr_geo.set_matID 	nvlFace		#mur 	
		
		
		
		
		---face avant ---
		-------	Creation des points 	--------
		local pt_avant_1 				= ptAccroche_1  - 	vec_prof
		local pt_avant_2 				= pt_avant_1 	+ 	vec_longueur
		
		--- creation des points --------------
		local ptsAvant_pos 	= #( pt_avant_1, pt_avant_2 )
		local ptsAvant_ids 	= ptr_geo.points 	ptsAvant_pos		
		
		-------	Creation des faces 	--------
		local nvlFace 	= ptr_geo.face 		#( ptsAvant_ids[2], 	ptsAvant_ids[1], pts_ids[2],  pts_ids[3])		 
		ptr_geo.set_matID 	nvlFace		#mur 	
		
		
		
		
		
		----------- Garde corps	-------------
		if compo_debut.params.gardeCorps	!=undefined and 	onConstruit_gardeCorps		do (
			compo_debut.params.gardeCorps.construire	_plug 	#(pt_sol_2 , pt_sol_3)  norm_dir:norm_dir
		)
			
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
		
		
)
	

	


------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 		nom:compo_nom	type:compo_type	params:(compo_params()) 	dialog:compo_dialog	fnConstruire:compo_fnConstruire		invisible:true


	
	
	
	
	
	
) ----	FileIn ----