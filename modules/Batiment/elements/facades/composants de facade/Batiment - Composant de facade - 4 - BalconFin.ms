
	
	
( ----	FileIn ----
	


--- parametres de base	-----------------------------
compo_nom 	= "Balcon fin"	
compo_type	=	#balconFin
compo_toolTip =	""




--- les rollout du composant	---------
rollout compo_dialog "Balcon fin" width:180 height:70	(
	local m_rollPrt
	local m_compo
	local m_plug
	fn actualiser =()
)

--- les parametres du composant	---------
struct compo_params	(
	longueur 		= 0,
	etirable			=	false,
	profondeur	= 100,
	private
		longueur_etirer =0,
	public
		fn set_longueur_etirer 	_lg = longueur_etirer = _lg,
		fn get_longueur_etirer = (
			local result = longueur_etirer
-- 			longueur_etirer = 0
			result
		)
)


--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		norm_dir:		 this:		onConstruitLaDalle:false	 		onConstruit_gardeCorps:true	compo_debut:	=(
	
	
	-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		
	-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
	
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= pts_accroches[1]
		local id_ptAccroche_2 	= pts_accroches[2]
		local id_ptAccroche_3 	= pts_accroches[3] 
		
		local ptAccroche_1		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	) 
		local ptAccroche_2		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	) 
		local ptAccroche_3		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	) 
		
	
	
		local ep_dalle 			= ptr_plug.const_dalle_epaisseur
		local ht_niveaux 		= distance ptAccroche_2 	ptAccroche_3
		local longueur 			= ptr_composant.params.longueur
		
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3
		
		--- Vecteurs ------------
		local vec_ep_dalle 	= [0,0,1] 		* 	ep_dalle
		local vec_ht 				= [0,0,1] 		* 	ht_niveaux
		local vec_longueur 	= norm_dir 	* 	longueur 		* 	-1
		local vec_prof			= ( norm_dir * rotateZ ( matrix3 1 ) 90 ) 	*   compo_debut.params.profondeur 
		local vec_balcon		= ( norm_dir * rotateZ ( matrix3 1 ) 90 ) 	*   -compo_debut.params.largeur 
		
		
				
		
	-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------

		
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		- 	vec_prof
		local pt_3 		= pt_2					+	vec_ep_dalle 
		
		--- creation des points --------------
		local pts_pos 	= #( pt_2, pt_3 )
		local pts_ids_result 	= ptr_geo.points 	pts_pos		
		--- Result -------------
		pt_result_1 = pts_ids_result[1]
		pt_result_2 = pts_ids_result[2]
		
		-------	Creation des faces 	--------
		ptr_geo.face 		#( pts_ids_result[1] , pts_ids_result[2], 			id_ptAccroche_2, 	id_ptAccroche_1	)		 matID:#mur
		
		
		
		---- LE MUR -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_1 		= pt_3 +	vec_ht 
-- 		local pt_2 		= pt_3 +	vec_ht 
		
		--- creation des points --------------
		local pts_pos 	= #( pt_1 )
		local pts_ids 	= ptr_geo.points 	pts_pos	
		--- Result -------------
		pt_result_3 		= pts_ids[1]	
		
		-------	Creation des faces 	--------
		ptr_geo.face 		#( id_ptAccroche_2, 		id_ptAccroche_3, 		pts_ids[1], 		pts_ids_result[2] )	matID:#mur
		
		
		
		
		
		
		
		
		---- LE  BALCON  -----------------------------------------------------------------------		
		---face du dessus ---
		-------	Creation des points 	--------
		local pt_sol_1 		= ptAccroche_2
		local pt_sol_2 		= pt_sol_1 		+ 	vec_balcon
		local pt_sol_3 		= pt_sol_2 		+ 	vec_longueur
		local pt_sol_4		= pt_sol_3 		- 	vec_balcon
		
		--- creation des points --------------
		local pts_pos 	= #( pt_sol_1, pt_sol_2, pt_sol_3, pt_sol_4 )
		local pts_dessus_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		ptr_geo.face 		#( pts_dessus_ids[4], 	pts_dessus_ids[3], pts_dessus_ids[2], pts_dessus_ids[1])		  matID:#mur
		
		
		---face du plafond ---
		-------	Creation des points 	--------
		local pt_plafond_1 		= pt_sol_1 +	vec_ht		--	- vec_ep_dalle
		local pt_plafond_2 		= pt_sol_2 +	vec_ht		--	- vec_ep_dalle
		local pt_plafond_3 		= pt_sol_3 +	vec_ht		--	- vec_ep_dalle
		local pt_plafond_4		= pt_sol_4 +	vec_ht		--	- vec_ep_dalle
		
		--- creation des points --------------
		local pts_pos 	= #( pt_plafond_1, pt_plafond_2, pt_plafond_3, pt_plafond_4 )
		local pts_dessous_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		ptr_geo.face 		#( pts_dessous_ids[1], 	pts_dessous_ids[2], pts_dessous_ids[3], pts_dessous_ids[4])		  matID:#mur
		
		
		---face de devant ---
		-------	Creation des points 	--------
		local pt_dessous_1 		= pt_sol_1 	- vec_ep_dalle
		local pt_dessous_2 		= pt_sol_2 	- vec_ep_dalle
		local pt_dessous_3 		= pt_sol_3 	- vec_ep_dalle
		local pt_dessous_4		= pt_sol_4 	- vec_ep_dalle
		
		--- creation des points --------------
		local pts_pos 	= #( pt_dessous_1, pt_dessous_2, pt_dessous_3, pt_dessous_4 )
		local pts_dessous_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		ptr_geo.face 		#( pts_dessus_ids[2], 	pts_dessous_ids[2], pts_dessous_ids[3], pts_dessus_ids[3])		  matID:#mur
		
		
		-------	Creation des cotés 	--------
		if 	compo_debut.params.largeur  > compo_debut.params.profondeur  do (
		
			ptr_geo.face 		#( pts_dessus_ids[3], 	pts_dessus_ids[4], pts_dessous_ids[4], pts_dessous_ids[3])		  matID:#mur
			ptr_geo.face 		#( pts_dessus_ids[2], 	pts_dessus_ids[1], pts_dessous_ids[1], pts_dessous_ids[2])		  matID:#mur
		
		
		)
		
		
		
		----------- Garde corps	-------------
		if compo_debut.params.gardeCorps	!=undefined and 	onConstruit_gardeCorps		do (
			
			compo_debut.params.gardeCorps.construire	_plug 	#(pt_sol_3 , pt_sol_2 )  --	norm_dir:norm_dir
			
			if 	compo_debut.params.largeur  > compo_debut.params.profondeur  do (
				
				compo_debut.params.gardeCorps.construire	_plug 	#( pt_sol_2, pt_sol_2 - vec_prof - vec_balcon )  --norm_dir:(normalize -vec_balcon )
				
				compo_debut.params.gardeCorps.construire	_plug 	#( pt_sol_3- vec_prof - vec_balcon  , pt_sol_3 )  --norm_dir:(normalize  -vec_balcon )
			)
			
		)
			
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
		
	
	
	/* 
	
	
	local ptr_geo 				= 	_plug.core.get_geo ()
	
	--- Result -------------
	local pt_result_1, pt_result_2, pt_result_3
	
	--- Vecteurs ------------
	local vec_ep_dalle 	= [0,0,1] 			* 	_plug.const_dalle_epaisseur			
	local vec_longueur 	= norm_dir 		* 	this.params.longueur
	local norm_balcon		= norm_dir * rotateZ ( matrix3 1 ) -90
	local vec_largeur		= norm_balcon 	*	 this.params.largeur				
	
	--- Points d'accroche ------------
	local id_ptAccroche_1 	= pts_accroches[1]
	local id_ptAccroche_2 	= pts_accroches[2]
	local id_ptAccroche_3 	= pts_accroches[3]
	
	local ptAccroche_1		=	polyop.getVert 	_plug.delegate		id_ptAccroche_1	
	local ptAccroche_2		=	polyop.getVert 	_plug.delegate		id_ptAccroche_2	
	local ptAccroche_3		=	polyop.getVert 	_plug.delegate		id_ptAccroche_3	
	
	
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
	
	--- Result -------------
	pt_result_1 = pts_ids[1]
	pt_result_2 = pts_ids[2]
	
	-------	Creation des faces 	--------
	local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[5], 		pts_ids[8], 		pts_ids[4] )
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[7] , 	pts_ids[8] )	
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[6], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[7] )	
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[6], 		pts_ids[5] )	
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[8], 		pts_ids[7], 		pts_ids[3], 		pts_ids[4] )	
	ptr_geo.set_matID 	nvlFace	#mur 		 				
	
	
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
	
	
	
	
	----------- Garde corps	-------------
	if onConstruit_gardeCorps do
		if this.params.gardeCorps	!=undefined  			do ( 
			-- garde corps de face -------
			this.params.gardeCorps.construire	_plug 	#(pt_6 + 	vec_ep_dalle	, pt_5 + 	vec_ep_dalle	)  norm_dir:norm_dir
			-- garde gauche -------
			this.params.gardeCorps.construire	_plug 	#(pt_5 + 	vec_ep_dalle	, pt_1 + 	vec_ep_dalle	)  norm_dir:norm_balcon
			-- garde droite -------
			this.params.gardeCorps.construire	_plug 	#(pt_2 + 	vec_ep_dalle	, pt_6 + 	vec_ep_dalle	)  norm_dir:-norm_balcon
		)
		
	--- on reinitialise la longueur à 0 --------
	this.params.longueur = 	0
	
	
-- 	---- Result final -----------------------------------------------------------------------
-- 	#( pt_result_1, pt_result_2, pt_result_3 )
	
	#()
	
	 */
	)
	
	
	


------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  		nom:compo_nom	type:compo_type	params:(compo_params () ) 	dialog:compo_dialog	fnConstruire:compo_fnConstruire		invisible:true

	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
	
	
	