


	
( ----	FileIn ----
	
	



--- parametres de base	-----------------------------
compo_nom 	= "Chaîne de refend"	
compo_type	=	#chaine
compo_toolTip =	"Ajouter un mur plein de longueur fixe."

--- les parametres du composant	---------
struct compo_params	(
	longueur 	= 50.,
	hauteur 		= 35.,
	epaisseur 	= 2.,
	etirable		=	false,
	
	private
		longueur_etirer =0,
	public
		fn set_longueur_etirer 	_lg = (),
		fn get_longueur_etirer = (
			local result = longueur_etirer
-- 			longueur_etirer = 0
			result
		)
)

--- les rollout du composant	---------
rollout compo_dialog "Chaîne de refend" width:180 height:98
(
	local m_rollPrt
	local m_compo
	local m_plug
	
	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:69 align:#left
	label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	label 'lbl2' "Hauteur" pos:[13,53] width:49 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[96,52] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	label 'lbl5' "Epaisseur" pos:[13,69] width:49 height:13 align:#left
	spinner 'spn_epaisseur' "" pos:[96,68] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_longueur.value 	= 	m_compo.params.longueur
		spn_hauteur.value 	= 	m_compo.params.hauteur
		spn_epaisseur.value 	= 	m_compo.params.epaisseur
		
		edt_nom.text 			=	m_compo.nom
	)

	
	on edt_nom entered txt 	do
	(
			m_compo.nom = txt
			m_rollPrt.actualiser 	sans_params_1:true		
			m_rollPrt.changer_un_truc ()
		)
	on spn_longueur changed val do
	(
			m_compo.params.longueur = val
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
		)
	on spn_hauteur changed val do
	(
			m_compo.params.hauteur = val
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
		)
	on spn_epaisseur changed val do
	(
			m_compo.params.epaisseur = val
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
		)
)

--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		norm_dir:		 			onConstruitLaDalle:true		this:			coin_de_mur:#aucun		= (
	
	
-- 	format "coin_de_mur :%\n" coin_de_mur
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		
-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= pts_accroches[1]
		local id_ptAccroche_2 	= pts_accroches[2]
		local id_ptAccroche_3 	= pts_accroches[3] 
		
		local ptAccroche_1		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	) -- + vec_prof
		local ptAccroche_2		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	)  --+ vec_prof
		local ptAccroche_3		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	)  --+ vec_prof
		
		
		local ep_dalle 			= ptr_plug.const_dalle_epaisseur
		local ht_niveaux 			= distance ptAccroche_2 	ptAccroche_3
		local longueur 			= ptr_composant.params.longueur --+ ( ptr_composant.params.get_longueur_etirer () )
		local nbr_pierres_vertic	=	floor ( ht_niveaux / ptr_composant.params.hauteur )
		local hauteur_pierre		=	ht_niveaux / nbr_pierres_vertic
		local ep_pierre			=	ptr_composant.params.epaisseur
		
		--- Vecteurs ------------
		local vec_ep_dalle 		= [0,0,1] 		* 	ep_dalle
		local vec_ht 				= [0,0,1] 		* 	ht_niveaux
		local vec_longueur 		= norm_dir 		* 	longueur
		
		local 	vec_longueur_pierre  			=  norm_dir * ptr_composant.params.longueur
-- 		local 	vec_longueur_pierre_crte  	=  norm_dir * ptr_composant.params.longueur	* 2. /	3.
		local 	vec_longueur_plat  				=  norm_dir * ptr_composant.params.longueur	/	4.
		
		local 	vec_hauteur_pierre  	=  [0,0,1] * hauteur_pierre
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		
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
		
				
		---- La chaine		 -----------------------------------------------------------------------	
		local pierre_courte	=	true
		local pt_accroche_pierres	=	ptAccroche_2
		for i = 1 to nbr_pierres_vertic do (
			case coin_de_mur of (
				#aucun: (
					
						if pierre_courte do (
							--- le plat ----
							local pt_1 = pt_accroche_pierres 
							local pt_2 = pt_1 + vec_longueur_plat
							local pt_3 = pt_2 + vec_hauteur_pierre
							local pt_4 = pt_1 + vec_hauteur_pierre
							local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
							
							
							pt_result_3 = pts_ids[3]
							
							local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )		matID:#mur
							
						)
						
						
						--- la pierre ----
						local pt_1
						if pierre_courte then pt_1 = pt_2 
							else pt_1 = pt_accroche_pierres 
						
						
						local pt_2 = pt_1 + vec_longueur_pierre 
						
						if pierre_courte do pt_2 = pt_2 - 2* vec_longueur_plat
						
						local pt_3 = pt_2 + vec_hauteur_pierre
						local pt_4 = pt_1 + vec_hauteur_pierre
						
							local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
						pt_result_3 = pts_ids[3]
						
						
						local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )		matID:#mur
						ptr_geo.biseauter	 	nvlFace_pierre 	0	-2.5 
						ptr_geo. extruder 	nvlFace_pierre 	ep_pierre
						
						if pierre_courte do (
							--- le plat ----
							local pt_1 = pt_2
							local pt_2 = pt_1 + vec_longueur_plat
							local pt_3 = pt_2 + vec_hauteur_pierre
							local pt_4 = pt_1 + vec_hauteur_pierre
							local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
							
							pt_result_3 = pts_ids[3]
							
							local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )		matID:#mur
							
							
						)
						
						
						
						
					)
					
					
					#gauche:(
					
						--- la pierre ----
						local pt_1 = pt_accroche_pierres 
						local pt_2 = pt_1 + vec_longueur_pierre 
						
						if pierre_courte do pt_2 = pt_2 -  vec_longueur_plat
						
						local pt_3 = pt_2 + vec_hauteur_pierre
						local pt_4 = pt_1 + vec_hauteur_pierre
						
						local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
						
						pt_result_3 = pts_ids[3]
						
						local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )		matID:#mur
						ptr_geo.biseauter	 	nvlFace_pierre 	0	-2.5 
						ptr_geo. extruder 	nvlFace_pierre 	ep_pierre
						
						if pierre_courte do (
							--- le plat ----
							local pt_1 = pt_2
							local pt_2 = pt_1 + vec_longueur_plat
							local pt_3 = pt_2 + vec_hauteur_pierre
							local pt_4 = pt_1 + vec_hauteur_pierre
							local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
							
							pt_result_3 = pts_ids[3]
							
							local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )		matID:#mur
							
							
						)
					
					
					)
						
					
					#droite:(
					
					
						if pierre_courte do (
							--- le plat ----
							local pt_1 = pt_accroche_pierres 
							local pt_2 = pt_1 + vec_longueur_plat
							local pt_3 = pt_2 + vec_hauteur_pierre
							local pt_4 = pt_1 + vec_hauteur_pierre
							local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
							
							
							pt_result_3 = pts_ids[3]
							local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )		matID:#mur
							
						)
						
						
						--- la pierre ----
						local pt_1
						if pierre_courte then pt_1 = pt_2 
							else pt_1 = pt_accroche_pierres 
						
						
						local pt_2 = pt_1 + vec_longueur_pierre 
						
						if pierre_courte do pt_2 = pt_2 -  vec_longueur_plat
						
						local pt_3 = pt_2 + vec_hauteur_pierre
						local pt_4 = pt_1 + vec_hauteur_pierre
						
						local pts_ids 	= ptr_geo.points 	#(pt_1, pt_2, pt_3, pt_4 )
						
						pt_result_3 = pts_ids[3]
						
						local nvlFace_pierre = ptr_geo.face 		#(pts_ids[1], pts_ids[2], pts_ids[3], pts_ids[4] )			matID:#mur
						ptr_geo.biseauter	 	nvlFace_pierre 	0	-2.5 
						ptr_geo. extruder 	nvlFace_pierre 	ep_pierre
					
					)
					
					
				)  -- fin case coins ---------
				
			
			
			
			
			
			pt_accroche_pierres += vec_hauteur_pierre
			pierre_courte = not pierre_courte
		)

/* 		
		-------	Creation des points 	--------
		local pt_4 		= pt_3 +	vec_ht
		
		--- creation des points --------------
		local pts_pos 	= #( pt_4 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		local nvlFace = ptr_geo.face 		#( id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3 )		 
		ptr_geo.set_matID 	nvlFace		#mur 	
		 */
		--- Result -------------
-- 		pt_result_3 = id_pt_accroche_pierres_final
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:( compo_params () )	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
